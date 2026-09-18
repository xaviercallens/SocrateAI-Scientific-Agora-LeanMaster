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
full = {json.loads(l)["name"] for l in (ROOT / ".leancache/depgraph.jsonl").read_text().splitlines() if l.startswith("{")}
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
unresolved = sorted({n for s in per_file.values() for n in s if n not in full and n not in tails and n not in ALLOW})
# allowlisted names that claim a real target must have that target exist
unresolved += sorted({t for t in ALLOW.values() if t != "-"} - set(unresolved))
# Everything not in the project's own dump goes to Lean itself (Mathlib and core names, namespaces).
import subprocess, tempfile
IMPORTS = ["Mathlib", "DualScaleStream2", "StringTheoryFormalization", "DualScaleCosmology", "DualScaleM24Formalization"]
PRELUDE = "".join(f"import {m}\n" for m in IMPORTS) + "open Matrix\n"  # quoted code uses `open Matrix`
probe = PRELUDE + "".join(
    f"#check @{n}\n" for n in unresolved)
with tempfile.NamedTemporaryFile("w", suffix=".lean", delete=False, dir=ROOT / ".leancache") as fh:
    fh.write(probe)
out = subprocess.run(["lake", "env", "lean", fh.name], cwd=ROOT, capture_output=True, text=True).stdout
Path(fh.name).unlink()
bad_lines = {int(m.group(1)) for m in re.finditer(r":(\d+):\d+: error", out)}
unknown = {n for i, n in enumerate(unresolved, start=PRELUDE.count("\n") + 1) if i in bad_lines}
bad_targets = sorted(t for t in unknown if t in set(ALLOW.values()))
# a namespace or module path is not a constant: accept prefixes of known names
prefixes = {".".join(n.split(".")[:k]) for n in full for k in range(1, len(n.split(".")))}
# a module path (file under a first-party library) is a legitimate thing to name in prose
LIBS = ["DualScaleStream2", "StringTheoryFormalization", "StringTheoryFoundation", "DualScaleM24Formalization",
        "DoubleFieldTheory", "DualScaleValidation", "Lean5Corpus", "DualScaleCosmology"]
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
