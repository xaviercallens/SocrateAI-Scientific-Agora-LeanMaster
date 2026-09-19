"""
leanstack/scheduler.py — memory-aware build scheduler with an RSS guard.

The failures it is designed around (observed on the 29 GB VM, 2026-09-19):
  a) one `decide +kernel` theorem reached 11–28 GB and was OOM-killed; the kernel's memory
     accumulates over all such calls in one file;
  b) each OOM kill evicted the page cache, after which every compile re-read Mathlib's .oleans
     at ~2 MB/s for 20–40 min;
  c) parallel compiles multiplied memory (`lake build <Lib>` runs its Lean jobs in parallel and,
     in Lake 4.33.1, has no --jobs flag — checked in the toolchain's src/lean/lake/Lake/CLI);
  d) `lake env lean` ignores lakefile options (LL.md S2.4).

What it does:
  * orders first-party modules topologically from their `import` lines;
  * skips modules whose fingerprint already has an 'ok' result (LeanCache), unless forced;
  * estimates each module's memory from its history in LeanMemory (largest observed anonymous
    peak × margin), else a default; modules with `decide +kernel` and no history count as heavy;
  * builds one module per `lake build <Module>` call, in dependency order, so each call compiles
    exactly one file (its imports are already built) — that is what bounds Lake's parallelism;
  * runs light modules concurrently only while the sum of estimates stays under the global budget;
    heavy modules always run alone;
  * guards every run: polls /proc for the whole process group (lake + the lean it spawns), and
    kills the group at the per-module budget or when MemAvailable falls under a floor — before the
    kernel OOM killer fires and takes the page cache with it;
  * records every run (status, wall time, peak memory, log) in LeanMemory.

`--dry-run` prints the plan and runs nothing.
"""

import os
import signal
import subprocess
import time
from dataclasses import dataclass, field
from pathlib import Path

from leanstack import source
from leanstack.cache import Fingerprinter, LeanCache
from leanstack.memory import LeanMemory

GB = 1024 * 1024  # in kB, the unit of /proc

DEFAULT_LIGHT_KB = 3 * GB      # a module that imports Mathlib; an assumption until history exists
DEFAULT_CORE_KB = 1 * GB       # a module with no Mathlib in its import closure
DEFAULT_HEAVY_KB = 16 * GB     # `decide +kernel` present, never measured
HEAVY_THRESHOLD_KB = 8 * GB
MARGIN = 1.25


# ---- /proc probes ------------------------------------------------------------------------------
def read_status(pid: int, proc: Path = Path("/proc")) -> dict[str, int]:
    """VmRSS / RssAnon / RssFile / VmHWM of one process in kB ({} if it is gone)."""
    out = {}
    try:
        for line in (proc / str(pid) / "status").read_text().splitlines():
            key, _, rest = line.partition(":")
            if key in ("VmRSS", "RssAnon", "RssFile", "VmHWM"):
                out[key] = int(rest.split()[0])
    except (OSError, ValueError, IndexError):
        return {}
    return out


def group_pids(pgid: int, proc: Path = Path("/proc")) -> list[int]:
    """All processes in a process group. `lake` runs `lean` as a child in the same group, so
    polling only the lake pid would miss the process that actually uses the memory."""
    pids = []
    for entry in proc.iterdir():
        if not entry.name.isdigit():
            continue
        try:
            stat = (entry / "stat").read_text()
        except OSError:
            continue
        # fields after the parenthesised command: state ppid pgrp ...
        fields_ = stat[stat.rfind(")") + 2:].split()
        if len(fields_) > 2 and int(fields_[2]) == pgid and fields_[0] != "Z":  # zombies hold no memory
            pids.append(int(entry.name))
    return pids


def group_memory(pgid: int, proc: Path = Path("/proc")) -> dict[str, int]:
    total = {"VmRSS": 0, "RssAnon": 0, "RssFile": 0, "n": 0}
    for pid in group_pids(pgid, proc):
        st = read_status(pid, proc)
        for k in ("VmRSS", "RssAnon", "RssFile"):
            total[k] += st.get(k, 0)
        total["n"] += 1
    return total


def mem_available_kb(proc: Path = Path("/proc")) -> int:
    for line in (proc / "meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            return int(line.split()[1])
    return 0


def mem_total_kb(proc: Path = Path("/proc")) -> int:
    for line in (proc / "meminfo").read_text().splitlines():
        if line.startswith("MemTotal:"):
            return int(line.split()[1])
    return 0


# ---- guarded execution ----------------------------------------------------------------------
@dataclass
class RunResult:
    status: str                 # ok | error | killed_budget | killed_low_memory | timeout
    returncode: int | None
    wall_s: float
    peak_rss_kb: int
    peak_anon_kb: int
    output: str
    note: str = ""


def kill_group(pgid: int, grace_s: float = 5.0) -> None:
    for sig in (signal.SIGTERM, signal.SIGKILL):
        try:
            os.killpg(pgid, sig)
        except ProcessLookupError:
            return
        deadline = time.time() + grace_s
        while time.time() < deadline:
            if not group_pids(pgid):
                return
            time.sleep(0.1)


def run_guarded(cmd: list[str], cwd: Path, budget_kb: int, min_available_kb: int = 0,
                timeout_s: float | None = None, poll_s: float = 0.5, log_path: Path | None = None,
                metric: str = "RssAnon") -> RunResult:
    """Run `cmd` in its own process group and kill the group if its memory (`metric`, summed over
    the group) exceeds `budget_kb`, or if system MemAvailable drops below `min_available_kb`.

    The default metric is RssAnon: the file-backed part of RSS is the mmapped .olean files, which is
    shared page cache the kernel can reclaim; the anonymous part is what the elaborator and the kernel
    actually allocate and what drives the machine into the OOM killer."""
    log_path = log_path or Path(os.devnull)
    t0 = time.time()
    peak_rss = peak_anon = 0
    status, note = None, ""
    with open(log_path, "wb") as log:
        proc = subprocess.Popen(cmd, cwd=cwd, stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        pgid = proc.pid
        while proc.poll() is None:
            mem = group_memory(pgid)
            peak_rss = max(peak_rss, mem["VmRSS"])
            peak_anon = max(peak_anon, mem["RssAnon"])
            if mem.get(metric, 0) > budget_kb:
                status, note = "killed_budget", f"{metric} {mem[metric]} kB > budget {budget_kb} kB"
            elif min_available_kb and mem_available_kb() < min_available_kb:
                status, note = "killed_low_memory", f"MemAvailable < {min_available_kb} kB"
            elif timeout_s and time.time() - t0 > timeout_s:
                status, note = "timeout", f"> {timeout_s} s"
            if status:
                kill_group(pgid)
                break
            time.sleep(poll_s)
        rc = proc.wait()
    wall = time.time() - t0
    out = Path(log_path).read_text(errors="replace") if log_path != Path(os.devnull) else ""
    if not status:
        status = "ok" if rc == 0 else "error"
    return RunResult(status, rc, wall, peak_rss, peak_anon, out, note)


# ---- planning ------------------------------------------------------------------------------
@dataclass
class Step:
    module: str
    fingerprint: str
    estimate_kb: int
    heavy: bool
    action: str                  # 'build' or 'skip'
    reason: str
    deps: list[str] = field(default_factory=list)


def topo_order(graph: dict[str, list[str]]) -> list[str]:
    """Kahn's algorithm over first-party edges; ties broken by name so plans are reproducible."""
    indeg = {m: 0 for m in graph}
    users: dict[str, list[str]] = {m: [] for m in graph}
    for m, deps in graph.items():
        for d in deps:
            if d in graph:
                indeg[m] += 1
                users[d].append(m)
    ready = sorted(m for m, k in indeg.items() if k == 0)
    order = []
    while ready:
        m = ready.pop(0)
        order.append(m)
        for u in sorted(users[m]):
            indeg[u] -= 1
            if indeg[u] == 0:
                ready.append(u)
        ready.sort()
    if len(order) != len(graph):
        raise ValueError("import cycle among: " + ", ".join(sorted(set(graph) - set(order))))
    return order


def imports_mathlib(module: str, graph: dict[str, list[str]], fp: Fingerprinter, memo: dict) -> bool:
    if module in memo:
        return memo[module]
    memo[module] = False
    res = any((not fp.is_own(i)) and i.split(".")[0] == "Mathlib" for i in fp.imports(module)) or \
        any(imports_mathlib(d, graph, fp, memo) for d in graph.get(module, []))
    memo[module] = res
    return res


def plan(modules: list[str] | None, memory: LeanMemory, fp: Fingerprinter, force: bool = False,
         heavy_threshold_kb: int = HEAVY_THRESHOLD_KB) -> list[Step]:
    """A build plan for `modules` and their first-party import closure (all own modules if None)."""
    root = fp.root
    wanted = list(modules) if modules else list(source.own_modules(root))
    graph: dict[str, list[str]] = {}
    todo = list(wanted)
    while todo:
        m = todo.pop()
        if m in graph:
            continue
        if not fp.is_own(m):
            raise ValueError(f"{m} is not a first-party module under {root}")
        graph[m] = [i for i in fp.imports(m) if fp.is_own(i)]
        todo.extend(graph[m])
    cache = LeanCache(memory, fp)
    memo: dict[str, bool] = {}
    steps = []
    for m in topo_order(graph):
        f = fp.fingerprint(m)
        text = source.path_of(m, root).read_text(encoding="utf-8", errors="ignore")
        heavy_decls = source.heavy_kernel_decls(text)
        seen = memory.peak_memory_kb(m)
        if seen:
            est, why = int(seen * MARGIN), f"history peak {seen / GB:.1f} GB x {MARGIN}"
        elif heavy_decls:
            est, why = DEFAULT_HEAVY_KB, f"{sum(d['calls'] for d in heavy_decls)} decide +kernel, never measured"
        elif imports_mathlib(m, graph, fp, memo):
            est, why = DEFAULT_LIGHT_KB, "default (imports Mathlib)"
        else:
            est, why = DEFAULT_CORE_KB, "default (Mathlib-free)"
        heavy = est >= heavy_threshold_kb
        if not force and cache.is_fresh(m, "build"):
            steps.append(Step(m, f, est, heavy, "skip", "cached: fingerprint has an ok build", graph[m]))
        else:
            steps.append(Step(m, f, est, heavy, "build", why, graph[m]))
    return steps


def format_plan(steps: list[Step], budget_kb: int) -> str:
    n_build = sum(s.action == "build" for s in steps)
    lines = [f"{len(steps)} modules, {n_build} to build, {len(steps) - n_build} cached; "
             f"global budget {budget_kb / GB:.1f} GB", ""]
    for i, s in enumerate(steps, 1):
        flag = "HEAVY-ALONE" if s.heavy and s.action == "build" else ""
        lines.append(f"{i:4d}. {s.action:5s} {s.module:<48s} {s.fingerprint[:12]}  "
                     f"~{s.estimate_kb / GB:5.1f} GB {flag:11s} {s.reason}")
    return "\n".join(lines)


# ---- execution ----------------------------------------------------------------------------
def command_for(module: str, fp: Fingerprinter, action: str) -> list[str]:
    if action == "check":
        # Single-file check: pass the lakefile options explicitly (LL.md S2.4).
        return ["lake", "env", "lean", *source.lake_lean_options(fp.root), str(source.path_of(module, fp.root))]
    return ["lake", "build", module]


def execute(steps: list[Step], memory: LeanMemory, fp: Fingerprinter, budget_kb: int,
            min_available_kb: int = 2 * GB, max_parallel: int = 1, action: str = "build",
            timeout_s: float | None = None, runner=run_guarded, stop_on_failure: bool = True,
            module_budget_kb: int | None = None) -> dict:
    """Run the plan. Light steps run concurrently (threads, one guarded process each) only while
    the sum of their estimates fits `budget_kb`; heavy steps run alone. A module starts only after
    all its first-party imports finished OK; dependents of a failure are skipped.

    Per-module kill threshold: `module_budget_kb` if given, else max(2 x estimate, estimate + 1 GB),
    capped by the global budget. A killed run is recorded with its peak, so the next plan's estimate
    is at least that peak x 1.25 — the budget learns upward from kills."""
    import concurrent.futures as cf

    cache = LeanCache(memory, fp)
    status: dict[str, str] = {s.module: ("ok" if s.action == "skip" else "pending") for s in steps}
    pending = [s for s in steps if s.action == "build"]
    running: dict = {}
    summary = {"ok": [], "failed": [], "skipped_dep": [], "cached": [s.module for s in steps if s.action == "skip"]}

    def launch(step: Step):
        per_module_budget = min(budget_kb, module_budget_kb or max(step.estimate_kb * 2, step.estimate_kb + GB))
        log_path = memory.root / "logs" / f"{step.module}.{int(time.time())}.log"
        started = time.time()
        res = runner(command_for(step.module, fp, action), fp.root, per_module_budget,
                     min_available_kb=min_available_kb, timeout_s=timeout_s, log_path=log_path)
        return step, started, res, log_path

    with cf.ThreadPoolExecutor(max_workers=max(1, max_parallel)) as pool:
        while pending or running:
            # drop steps whose dependencies failed
            for s in list(pending):
                if any(status.get(d) in ("failed", "skipped_dep") for d in s.deps):
                    status[s.module] = "skipped_dep"
                    summary["skipped_dep"].append(s.module)
                    pending.remove(s)
            in_use = sum(s.estimate_kb for s in running.values())
            heavy_running = any(s.heavy for s in running.values())
            for s in list(pending):
                if len(running) >= max(1, max_parallel) or heavy_running:
                    break
                if any(status.get(d) != "ok" for d in s.deps):
                    continue
                if s.heavy and running:
                    continue  # heavy waits until it can run alone
                if running and in_use + s.estimate_kb > budget_kb:
                    continue
                pending.remove(s)
                running[pool.submit(launch, s)] = s
                in_use += s.estimate_kb
                heavy_running = heavy_running or s.heavy
            if not running:
                if pending:  # nothing runnable: remaining steps wait on failed deps
                    for s in pending:
                        status[s.module] = "skipped_dep"
                        summary["skipped_dep"].append(s.module)
                    pending.clear()
                break
            done, _ = cf.wait(list(running), return_when=cf.FIRST_COMPLETED)
            for fut in done:
                step, started, res, log_path = fut.result()
                del running[fut]
                cache.record(step.module, action, res.status, command=command_for(step.module, fp, action),
                             returncode=res.returncode, wall_s=res.wall_s, peak_rss_kb=res.peak_rss_kb,
                             peak_anon_kb=res.peak_anon_kb, started=started, log=res.output or None,
                             note=res.note)
                Path(log_path).unlink(missing_ok=True)  # the log now lives in the blob store
                if res.status == "ok":
                    status[step.module] = "ok"
                    summary["ok"].append(step.module)
                else:
                    status[step.module] = "failed"
                    summary["failed"].append(step.module)
                    memory.record_failure(res.status, first_error(res.output) or res.note, res.output[-2000:],
                                          module=step.module)
                    if stop_on_failure:
                        for s in pending:
                            status[s.module] = "skipped_dep"
                            summary["skipped_dep"].append(s.module)
                        pending.clear()
    return summary


def first_error(output: str) -> str:
    """The first `error:` line with its file position removed, so the same error in two runs
    produces the same failure pattern."""
    for line in output.splitlines():
        if ": error" in line or line.startswith("error:"):
            return line.split("error:", 1)[-1].strip()[:300]
    return ""


def default_budget_kb(reserve_kb: int = 8 * GB) -> int:
    """MemTotal minus a reserve for the OS and the .olean page cache. Measured on this VM: the import
    closure of DualScaleDyons is ~7.0 GB of .olean + .olean.server + .olean.private files; anonymous
    memory beyond MemTotal minus that working set starts evicting it (failure b). Raise the reserve
    for libraries with a larger closure (`python -m leanstack warm --closure Lib --dry-run`)."""
    return max(GB, mem_total_kb() - reserve_kb)
