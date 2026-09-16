#!/usr/bin/env python3
"""
tools/prover_loop.py — kernel-gated local-LLM proof search.

For every `theorem/lemma ... := by\n  sorry` in the given files, ask one or more local
Ollama prover models for a proof, splice each candidate in, and compile with
`lake env lean`. A candidate is ACCEPTED only if the file compiles with zero errors
and exactly one fewer `sorry` warning than before. The model never grades itself;
the Lean kernel is the only judge.

Every attempt (accepted or not) is appended to `.leancache/prover_attempts.jsonl`
so tier/model effectiveness is measured, not asserted.

Usage:
  python3 tools/prover_loop.py DualScaleStream2/Lattice/E8.lean ... \
      --models hf.co/unsloth/DeepSeek-Prover-V2-7B-GGUF:Q8_0 \
               hf.co/mradermacher/Goedel-Prover-V2-8B-GGUF:Q6_K \
      --rounds 2
"""

import argparse
import json
import re
import subprocess
import tempfile
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOG = ROOT / ".leancache" / "prover_attempts.jsonl"
OLLAMA = "http://127.0.0.1:11434/api/chat"
FORBIDDEN = re.compile(r"\b(sorry|admit|native_decide)\b|^\s*axiom\b", re.MULTILINE)
# The statement body may span lines but must not run into the next declaration —
# otherwise, once an earlier goal is solved, its match stretches forward and swallows
# the next goal's `sorry` (observed in the first smoke test: 2 of 7 goals silently skipped).
GOAL = re.compile(
    r"^(?P<head>(?:theorem|lemma)\s+(?P<name>[A-Za-z0-9_'.]+)"
    r"(?:(?!^(?:theorem|lemma|def|noncomputable|structure|instance|end)\b)[\s\S])*?:=\s*by)"
    r"[ \t]*\n(?P<indent>[ \t]*)sorry\b",
    re.MULTILINE,
)
DECL_START = re.compile(r"^(theorem|lemma|def|noncomputable|structure|instance|end\b|/--|@\[|namespace|section)", re.MULTILINE)


def compile_lean(text: str, timeout: int) -> tuple[int, int, str]:
    """Return (error_count, sorry_warning_count, output)."""
    with tempfile.NamedTemporaryFile("w", suffix=".lean", dir="/tmp", delete=False) as f:
        f.write(text)
        tmp = f.name
    try:
        r = subprocess.run(["lake", "env", "lean", tmp], cwd=ROOT, capture_output=True, text=True, timeout=timeout)
        out = r.stdout + r.stderr
    except subprocess.TimeoutExpired:
        return 1, -1, "TIMEOUT"
    finally:
        Path(tmp).unlink(missing_ok=True)
    errors = len(re.findall(r":\d+:\d+: error", out))
    if r.returncode != 0 and errors == 0:
        errors = 1
    return errors, len(re.findall(r"declaration uses `sorry`", out)), out


def ask(model: str, prefix: str, temperature: float, max_tokens: int, timeout: int) -> tuple[str, float]:
    prompt = (
        "Complete the following Lean 4 code (Lean 4 + Mathlib). Replace the final `sorry` "
        "with a complete tactic proof. Do not use `sorry`, `admit`, or `native_decide`. "
        "Output the complete final theorem in one ```lean4 code block.\n\n"
        f"```lean4\n{prefix}\n```"
    )
    body = json.dumps({
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "stream": False,
        "options": {"temperature": temperature, "num_predict": max_tokens, "num_ctx": 8192},
    }).encode()
    t0 = time.time()
    req = urllib.request.Request(OLLAMA, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        content = json.load(resp)["message"]["content"]
    return content, time.time() - t0


def extract_proof(response: str, name: str) -> str | None:
    blocks = re.findall(r"```(?:lean4|lean)?\s*\n([\s\S]*?)```", response)
    for block in reversed(blocks):
        m = re.search(rf"(?:theorem|lemma)\s+{re.escape(name)}\b[\s\S]*?:=\s*by\b", block)
        if not m:
            continue
        rest = block[m.end():]
        nxt = DECL_START.search(rest)
        proof = (rest[: nxt.start()] if nxt else rest).strip("\n")
        if proof.strip():
            return proof
    return None


def splice(text: str, match: re.Match, proof: str) -> str:
    indent = match.group("indent") or "  "
    lines = [ln.rstrip() for ln in proof.splitlines() if ln.strip()]
    common = min((len(ln) - len(ln.lstrip()) for ln in lines), default=0)
    body = "\n".join(indent + ln[common:] for ln in lines)
    start = match.start("indent")
    end = match.end()
    return text[:start] + body + text[end:]


def log(entry: dict) -> None:
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(json.dumps(entry) + "\n")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+")
    ap.add_argument("--models", nargs="+", required=True)
    ap.add_argument("--rounds", type=int, default=1)
    ap.add_argument("--max-tokens", type=int, default=2048)
    ap.add_argument("--llm-timeout", type=int, default=600)
    ap.add_argument("--lean-timeout", type=int, default=600)
    args = ap.parse_args()

    summary = []
    for rel in args.files:
        path = ROOT / rel
        text = path.read_text(encoding="utf-8")
        base_err, base_sorry, _ = compile_lean(text, args.lean_timeout)
        if base_err:
            print(f"[SKIP] {rel}: does not compile before search ({base_err} errors)")
            continue
        names = [m.group("name") for m in GOAL.finditer(text)]
        print(f"[FILE] {rel}: {len(names)} open goals, baseline sorry warnings = {base_sorry}")
        for name in names:
            closed_by = None
            for rnd in range(args.rounds):
                temperature = 0.2 if rnd == 0 else 0.8
                for model in args.models:
                    m = next((g for g in GOAL.finditer(text) if g.group("name") == name), None)
                    if m is None:
                        log({"ts": time.time(), "file": rel, "theorem": name, "model": model,
                             "round": rnd, "accepted": False, "reason": "goal_not_found"})
                        break
                    prefix = text[: m.end()]
                    entry = {"ts": time.time(), "file": rel, "theorem": name, "model": model,
                             "round": rnd, "temperature": temperature}
                    try:
                        response, latency = ask(model, prefix, temperature, args.max_tokens, args.llm_timeout)
                    except Exception as exc:  # network/timeout: record, move on
                        log({**entry, "accepted": False, "reason": f"llm_error: {exc}"})
                        continue
                    entry["llm_latency_s"] = round(latency, 1)
                    proof = extract_proof(response, name)
                    if proof is None:
                        log({**entry, "accepted": False, "reason": "no_proof_extracted"})
                        continue
                    if FORBIDDEN.search(proof):
                        log({**entry, "accepted": False, "reason": "forbidden_token", "proof": proof})
                        continue
                    candidate = splice(text, m, proof)
                    err, sorry_n, out = compile_lean(candidate, args.lean_timeout)
                    ok = err == 0 and sorry_n == base_sorry - 1
                    reason = "accepted" if ok else (f"compile_errors={err}" if err else f"sorry_count={sorry_n}")
                    first_err = next((ln for ln in out.splitlines() if ": error" in ln), "")
                    log({**entry, "accepted": ok, "reason": reason, "proof": proof, "first_error": first_err[:300]})
                    print(f"   {name:<38} {model.split('/')[-1][:28]:<28} r{rnd} -> {reason}")
                    if ok:
                        text, base_sorry, closed_by = candidate, sorry_n, f"{model} r{rnd}"
                        path.write_text(text, encoding="utf-8")
                        break
                if closed_by:
                    break
            summary.append((rel, name, closed_by or "OPEN"))

    print("\n=== SUMMARY (kernel-verified) ===")
    for rel, name, who in summary:
        print(f"{Path(rel).name:<22} {name:<40} {who}")
    closed = sum(1 for *_, w in summary if w != "OPEN")
    print(f"\nclosed {closed}/{len(summary)}")


if __name__ == "__main__":
    main()
