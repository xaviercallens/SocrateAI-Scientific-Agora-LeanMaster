#!/usr/bin/env python3
"""
tools/check_book_lean_names.py — every Lean identifier printed in the book must exist.

Scans papers/book/chapters/*.tex for \\lean{...} and leancode `theorem|def|lemma <name>` headers and checks
each against the compiled environment (.leancache/depgraph.jsonl): full names, or a unique/any declaration
whose name ends with the cited suffix. Exit code 1 if anything is missing.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FIRST_PARTY = ("DualScaleStream2", "StringTheoryFormalization", "StringTheoryFoundation", "DualScaleM24Formalization",
               "DoubleFieldTheory", "DualScaleValidation", "Lean5Corpus", "DualScaleCosmology", "DualScaleMoonshine",
               "DualScaleDyons")
_dump = [json.loads(l) for l in (ROOT / ".leancache/depgraph.jsonl").read_text().splitlines() if l.startswith("{")]
# The dump is a snapshot. A first-party declaration that has since been removed or renamed in the sources
# must not be accepted from it (a removed theorem passed silently until 2026-09-18): keep a first-party
# dump entry only if its name, or its parent (structure fields, auto-generated lemmas), is still declared.
_DECL_ANY = re.compile(r"^(?:@\[[^\]]*\]\s*)?(?:(?:private|protected|noncomputable|partial|unsafe)\s+)*"
                       r"(?:theorem|lemma|def|abbrev|structure|inductive|class|instance)\s+([A-Za-z0-9_'.₀-₉]+)", re.M)
_NS = re.compile(r"^(namespace|end)\s+([A-Za-z0-9_.]+)\s*$", re.M)
def _source_names():
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from statement_lock import strip_comments
    out = set()
    for lib in FIRST_PARTY:
        for f in (ROOT / lib).rglob("*.lean"):
            text = strip_comments(f.read_text(encoding="utf-8"))
            ev = sorted([(m.start(), "ns", m.group(1), m.group(2)) for m in _NS.finditer(text)]
                        + [(m.start(), "decl", m.group(1), None) for m in _DECL_ANY.finditer(text)])
            stack = []
            for _, kind, x, y in ev:
                if kind == "ns":
                    if x == "namespace":
                        stack.append(y)
                    elif stack and stack[-1] == y:
                        stack.pop()
                else:
                    out.add(".".join(stack + [x]))
    return out
_src = _source_names()
def _alive(e):
    if not str(e.get("module", "")).startswith(FIRST_PARTY):
        return True
    n = e["name"]
    parts = n.split(".")
    return any(".".join(parts[:k]) in _src for k in range(1, len(parts) + 1))
STALE = sorted(e["name"] for e in _dump if not _alive(e))
full = {e["name"] for e in _dump if _alive(e)}
tails = {}
for n in full:
    parts = n.split(".")
    for i in range(len(parts)):
        tails.setdefault(".".join(parts[i:]), set()).add(n)
TACTICS = set("""simp simp_all ring ring_nf norm_num decide rfl exact apply intro intros rw rwa omega linarith nlinarith
positivity field_simp fin_cases ext constructor refine use obtain rcases cases induction unfold dsimp show have calc
by sorry native_decide trivial aesop gcongr push_cast norm_cast exact_mod_cast subst congr funext ac_rfl split_ifs
specialize contradiction exfalso left right tauto abel noncomm_ring bound fun def theorem lemma structure where
instance abbrev axiom example else end if then match with do let open namespace section variable import axioms propext Quot.sound Classical.choice True False true false Prop Type Sort lean_lib push_neg""".split())


# shell commands printed in \\lean{} (e.g. `lake build`, `lake exe cache get`) are not declarations
SHELL = {"lake", "build", "exe", "cache", "get", "env", "lean", "update"}


def candidates(t):
    out = set()
    # layout devices that split one name across lines or across two \\lean{} groups
    t = t.replace("}\\allowbreak\\lean{", "").replace("\\newline ", "").replace("\\newline", "")
    raw = [m.group(1) for m in re.finditer(r"\\lean\{([^}]*)\}", t)]
    for block in re.findall(r"\\begin\{leancode\}(.*?)\\end\{leancode\}", t, re.S):
        if "not yet proved" in block.lower() or "sorry" in block:
            continue
        raw += re.findall(r"^\s*(?:@\[[^\]]*\]\s*)?(?:noncomputable\s+)?(?:theorem|lemma|def|abbrev|structure)\s+([\w'.₀-₉]+)", block, re.M)
    for r in raw:
        for x in re.split(r"[,\s{}()]+", r.replace("\\_", "_")):
            x = x.strip(".:;`").rstrip("ᵀ")  # postfix transpose is notation, not part of the name
            if (len(x) < 3 or x.startswith("_") or x in TACTICS or x in SHELL or not re.fullmatch(r"[A-Za-z][\w'.₀-₉]*", x)
                    or x.endswith((".lean", ".py", ".md", ".json")) or re.fullmatch(r"[A-Z][a-z]?", x)):
                continue
            out.add(x)
    return out


files = sorted((ROOT / "papers/book/chapters").glob("*.tex"))
per_file = {f: candidates(f.read_text(encoding="utf-8")) for f in files}
ALLOW = {}
for line in (ROOT / "papers/book/generated/lean_name_allowlist.tsv").read_text().splitlines():
    if line.strip() and not line.startswith("#"):
        name, target, _reason = line.split("\t")
        ALLOW[name] = target
# The dependency dump can lag behind the sources (it is regenerated with the theorem atlas, not on every
# commit). Theorems declared in the sources but missing from the dump are resolved through their source
# declaration, and each one actually cited is then verified by Lean under its fully qualified name.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from axiom_audit import qualified_names
SRC_LIBS = ["DualScaleStream2", "StringTheoryFormalization", "StringTheoryFoundation", "DualScaleCosmology",
            "DualScaleM24Formalization", "DualScaleValidation", "DualScaleMoonshine", "DualScaleDyons"]
src_tails = {}
for lib in SRC_LIBS:
    for f in (ROOT / lib).rglob("*.lean"):
        for q in qualified_names(f):
            if q not in full:
                parts = q.split(".")
                for i in range(len(parts)):
                    src_tails.setdefault(".".join(parts[i:]), set()).add(q)
mentions = {n for s_ in per_file.values() for n in s_}
SRC_VERIFY = sorted({q for n in mentions if n in src_tails and n not in full and n not in tails for q in src_tails[n]})
unresolved = sorted({n for n in mentions if n not in full and n not in tails and n not in ALLOW and n not in src_tails})
unresolved += [q for q in SRC_VERIFY if q not in unresolved]
# mentions that only the stale part of the dump knows: verify each candidate under its full name
stale_tails = {}
for q in STALE:
    parts = q.split(".")
    for i in range(len(parts)):
        stale_tails.setdefault(".".join(parts[i:]), set()).add(q)
STALE_CITED = {n: sorted(stale_tails[n]) for n in mentions
               if n in stale_tails and n not in full and n not in tails and n not in ALLOW and n not in src_tails}
unresolved = [n for n in unresolved if n not in STALE_CITED]
unresolved += sorted({q for qs in STALE_CITED.values() for q in qs} - set(unresolved))
# allowlisted names that claim a real target must have that target exist
unresolved += sorted({t for t in ALLOW.values() if t != "-"} - set(unresolved))
# Everything not in the project's own dump goes to Lean itself (Mathlib and core names, namespaces).
import subprocess, tempfile
IMPORTS = ["Mathlib", "DualScaleStream2", "StringTheoryFormalization", "StringTheoryFoundation", "DualScaleCosmology",
           "DualScaleM24Formalization", "DualScaleValidation", "DualScaleMoonshine", "DualScaleDyons"]
PRELUDE = "".join(f"import {m}\n" for m in IMPORTS) + "open Matrix\nopen DualScaleCosmology DualScaleMoonshine DualScaleDyons\nopen DualScaleCosmology.Stream6Verdict DualScaleCosmology.Stream7CA DualScaleCosmology.Stream7CB\n"  # quoted code uses `open Matrix`; chapters 39-41 cite names relative to these namespaces
probe = PRELUDE + "".join(
    f"#check @{n}\n" for n in unresolved)
with tempfile.NamedTemporaryFile("w", suffix=".lean", delete=False, dir=ROOT / ".leancache") as fh:
    fh.write(probe)
out = subprocess.run(["lake", "env", "lean", "-DmaxErrors=1000000", fh.name], cwd=ROOT, capture_output=True,
                     text=True).stdout
# Lean stops reporting after `maxErrors` errors; every name after that point would silently pass.
if "maximum number of errors" in out:
    sys.exit("check_book_lean_names: Lean hit maxErrors in the probe; the result would be incomplete")
Path(fh.name).unlink()
bad_lines = {int(m.group(1)) for m in re.finditer(r":(\d+):\d+: error", out)}
unknown = {n for i, n in enumerate(unresolved, start=PRELUDE.count("\n") + 1) if i in bad_lines}
bad_targets = sorted(t for t in unknown if t in set(ALLOW.values()) or t in set(SRC_VERIFY))
# a mention known only to the stale dump is unknown when none of its candidates exists any more
unknown |= {n for n, qs in STALE_CITED.items() if all(q in unknown for q in qs)}
unknown -= {q for qs in STALE_CITED.values() for q in qs}
# a namespace or module path is not a constant: accept prefixes of known names
prefixes = {".".join(n.split(".")[:k]) for n in full for k in range(1, len(n.split(".")))}
# a module path (file under a first-party library) is a legitimate thing to name in prose
LIBS = ["DualScaleStream2", "StringTheoryFormalization", "StringTheoryFoundation", "DualScaleM24Formalization",
        "DoubleFieldTheory", "DualScaleValidation", "Lean5Corpus", "DualScaleCosmology", "DualScaleMoonshine",
        "DualScaleDyons"]
modules = set(LIBS)
for lib in LIBS:
    for f in (ROOT / lib).rglob("*.lean"):
        parts = [lib] + list(f.relative_to(ROOT / lib).with_suffix("").parts)
        modules |= {".".join(parts[i:j]) for i in range(len(parts)) for j in range(i + 1, len(parts) + 1)}
# names bound locally (have / binders / intro) in the project's own Lean sources are local
# hypotheses or variables quoted from real proofs, not declarations
LOCALS = set()
BIND = re.compile(r"\bhave\s+([A-Za-z_][\w']*)\s*:|\(([A-Za-z_][\w']*)\s*:|\bintros?\s+([A-Za-z_][\w' ]*)")
for lib in LIBS:
    for f in (ROOT / lib).rglob("*.lean"):
        for m in BIND.finditer(f.read_text(encoding="utf-8")):
            for g in m.groups():
                if g:
                    LOCALS |= set(g.split())
unknown = {n for n in unknown if n not in prefixes and n not in modules
           and n not in LOCALS and n.split(".")[0] not in LOCALS}
missing = 0
for f in files:
    bad = sorted(per_file[f] & unknown)
    if bad:
        missing += len(bad)
        print(f"{f.name}: {len(bad)} unknown: {', '.join(bad)}")
# a parse error in the probe can swallow the next #check and hide a genuinely unknown name
parse_errors = [l for l in out.splitlines() if "unexpected token" in l]
if parse_errors:
    missing += len(parse_errors)
    print("probe parse errors (can hide neighbouring names):", *parse_errors, sep="\n  ")
if bad_targets:
    missing += len(bad_targets)
    print(f"allowlist targets that do not exist: {bad_targets}")
print(f"{len(files)} chapters checked; {sum(len(s) for s in per_file.values())} identifier mentions; {missing} unknown to Lean")
sys.exit(1 if missing else 0)
