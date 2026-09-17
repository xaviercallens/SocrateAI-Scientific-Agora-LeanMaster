#!/usr/bin/env python3
"""
tools/stream2_progress.py — mechanical progress count for DualScaleStream2.

Counts, per module, the theorems whose proof body still contains `sorry`. This is a
*static* count of designed goals; a theorem is only kernel-clean once
`tools/axiom_audit.py` also passes (a sorry-free proof can still depend on a sorry'd lemma).

Usage: python3 tools/stream2_progress.py
"""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DECL = re.compile(r"^(theorem|lemma)\s+([A-Za-z0-9_'.]+)", re.MULTILINE)
NEXT = re.compile(r"^(?:theorem |lemma |def |noncomputable def |structure |instance |end |/--)", re.MULTILINE)


def main() -> None:
    total = open_ = 0
    rows = []
    for f in sorted((ROOT / "DualScaleStream2").rglob("*.lean")):
        text = f.read_text(encoding="utf-8")
        decls = list(DECL.finditer(text))
        n_open = 0
        for m in decls:
            nxt = NEXT.search(text, m.end())
            body = text[m.end(): nxt.start() if nxt else len(text)]
            if re.search(r"\bsorry\b", body):
                n_open += 1
        rows.append((str(f.relative_to(ROOT)), len(decls), n_open))
        total += len(decls)
        open_ += n_open
    for path, n, o in rows:
        pct = 100 * (n - o) / n if n else 100
        print(f"{path:<48} {n - o:>3}/{n:<3} {pct:5.1f}%")
    print(f"{'TOTAL':<48} {total - open_:>3}/{total:<3} {100 * (total - open_) / total:5.1f}%")


if __name__ == "__main__":
    main()
