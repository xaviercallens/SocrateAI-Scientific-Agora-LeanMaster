#!/usr/bin/env python3
"""
tools/statement_lock.py — detect changed theorem statements and definitions.

Why: the Lean kernel checks that a proof proves its statement, but not that the statement is
still the one that was designed and reviewed. An agent (or a person) can make a goal
"provable" by weakening it. This tool locks what was reviewed:

* for `theorem`/`lemma`: the statement text from the keyword up to the top-level `:=`
  (so replacing `:= by sorry` with `:= rfl` or a tactic proof is NOT a change);
* for `def`/`abbrev`/`structure`/`noncomputable def`: the whole declaration, body included
  (changing a definition changes the meaning of every statement that uses it).

Comments (`-- ...`, `/- ... -/`, docstrings, module docs) are removed and whitespace is normalized
before hashing, so documentation can be improved freely without touching the lock.

Usage:
  python3 tools/statement_lock.py --update DualScaleStream2/**/*.lean   # after statement review (gate G2)
  python3 tools/statement_lock.py --check  DualScaleStream2/**/*.lean   # before accepting any proof
Exit code 1 on --check if any locked declaration changed or disappeared. Newly added
declarations (e.g. helper lemmas) are reported but do not fail the check.
"""

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOCK = ROOT / "docs" / "statement_lock.json"
HEAD = re.compile(
    r"^(?P<kind>theorem|lemma|def|abbrev|structure|noncomputable def)\s+(?P<name>[A-Za-z0-9_'.]+)",
    re.MULTILINE,
)
NEXT = re.compile(
    r"^(?:theorem |lemma |def |abbrev |structure |noncomputable |instance |end |namespace |section |/--|@\[)",
    re.MULTILINE,
)
OPEN, CLOSE = "([{⟨", ")]}⟩"


def strip_comments(text: str) -> str:
    """Remove Lean comments, keeping the text length-independent of documentation. Block comments
    nest in Lean, so this is a small scanner rather than a regex."""
    out, i, depth, n = [], 0, 0, len(text)
    while i < n:
        two = text[i:i + 2]
        if two == "/-":
            depth += 1
            i += 2
        elif two == "-/" and depth:
            depth -= 1
            i += 2
        elif depth:
            i += 1
        elif two == "--":
            j = text.find("\n", i)
            i = n if j < 0 else j
        else:
            out.append(text[i])
            i += 1
    return "".join(out)


def statement_text(text: str, start: int, kind: str) -> str:
    nxt = NEXT.search(text, text.index("\n", start) + 1 if "\n" in text[start:] else len(text))
    end = nxt.start() if nxt else len(text)
    chunk = text[start:end]
    if kind in ("theorem", "lemma"):
        depth = 0
        for i, ch in enumerate(chunk):
            if ch in OPEN:
                depth += 1
            elif ch in CLOSE:
                depth -= 1
            elif ch == ":" and depth == 0 and chunk[i + 1: i + 2] == "=":
                chunk = chunk[:i]
                break
    return " ".join(chunk.split())


def scan(files: list[str]) -> dict[str, dict[str, str]]:
    out: dict[str, dict[str, str]] = {}
    for f in files:
        p = Path(f)
        text = strip_comments(p.read_text(encoding="utf-8"))
        decls = {}
        for m in HEAD.finditer(text):
            body = statement_text(text, m.start(), m.group("kind"))
            decls[m.group("name")] = hashlib.sha256(body.encode()).hexdigest()[:16]
        out[str(p.resolve().relative_to(ROOT))] = decls
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--update", action="store_true")
    g.add_argument("--check", action="store_true")
    ap.add_argument("files", nargs="+")
    args = ap.parse_args()

    current = scan(args.files)
    lock = json.loads(LOCK.read_text()) if LOCK.exists() else {}

    if args.update:
        lock.update(current)
        LOCK.parent.mkdir(parents=True, exist_ok=True)
        LOCK.write_text(json.dumps(lock, indent=2, sort_keys=True) + "\n")
        print(f"locked {sum(len(v) for v in current.values())} declarations in {len(current)} files")
        return 0

    bad = 0
    for f, decls in current.items():
        locked = lock.get(f)
        if locked is None:
            print(f"UNLOCKED  {f} (no lock entry — run --update after statement review)")
            continue
        for name, h in locked.items():
            if name not in decls:
                print(f"REMOVED   {f} :: {name}")
                bad += 1
            elif decls[name] != h:
                print(f"CHANGED   {f} :: {name}")
                bad += 1
        for name in decls.keys() - locked.keys():
            print(f"ADDED     {f} :: {name} (new declaration — review it)")
    print("statement lock: OK" if bad == 0 else f"statement lock: {bad} locked declaration(s) changed")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
