#!/usr/bin/env python3
"""Does the disclosure reach whoever meets the declaration?

Method contributed by Stream 1 (2026-09-21). It asks what name-vs-statement triage
structurally cannot: not "does the statement match the name" but "is the warning
written where the reader of the declaration will see it".

Step 1: find declaration identifiers occurring NEAR vacuity/disclosure language in PROSE.
Step 2: check whether that declaration's OWN docstring carries the same language.
A hit = the disclosure exists but does not travel with the declaration.
"""
import re, pathlib, sys, collections

VAC = re.compile(r'vacuou|vacuit|disclos|placeholder|content-free|carries no|says nothing|'
                 r'proves less|not a proof|trivially true|is not evidence|beside the point|⚠', re.I)
LIBS = ["DualScaleDyons","StringTheoryFoundation","DualScaleStream2","DualScaleMoonshine",
        "DualScaleCosmology","DoubleFieldTheory","StringTheoryFormalization",
        "DualScaleM24Formalization","DualScaleValidation","Lean5Corpus"]

# --- build declaration -> (file, own docstring) ---
DECL = re.compile(r'(?:/--(?P<doc>.*?)-/\s*)?^\s*(?:@\[[^\]]*\]\s*)?(?:theorem|lemma)\s+(?P<name>[A-Za-z_][\w\'.]*)',
                  re.M | re.S)
decls = {}
for lib in LIBS:
    for p in pathlib.Path(lib).rglob('*.lean'):
        src = p.read_text(encoding='utf-8')
        for m in DECL.finditer(src):
            decls.setdefault(m.group('name'), (str(p), m.group('doc') or ''))

# --- scan prose ---
prose = []
for pat in ['README.md','LL.md','docs/**/*.md','papers/book/chapters/*.tex',
            'papers/book/*.md','papers/*/*.tex','papers/*.md']:
    prose += [q for q in pathlib.Path('.').glob(pat) if q.is_file()]

ID = re.compile(r'`([A-Za-z_][\w\'.]*)`|\\lean\{([A-Za-z_\\][\w\'.\\]*)\}')
near = collections.defaultdict(set)
for q in prose:
    try: lines = q.read_text(encoding='utf-8').splitlines()
    except Exception: continue
    for i, line in enumerate(lines):
        if not VAC.search(line): continue
        window = '\n'.join(lines[max(0,i-1):i+2])          # +-1 line
        for m in ID.finditer(window):
            name = (m.group(1) or m.group(2) or '').replace('\\_','_').replace('\\','')
            if name in decls: near[name].add(str(q))

missing, ok = [], []
for name, srcs in sorted(near.items()):
    f, doc = decls[name]
    (ok if VAC.search(doc) else missing).append((name, f, sorted(srcs)))

print("=== DISCLOSED IN PROSE BUT NOT AT THE DECLARATION ===")
for name, f, srcs in missing:
    print(f"  {name}\n      lean: {f}\n      prose: {', '.join(srcs[:3])}")
print(f"\n{len(missing)} candidates; {len(ok)} correctly disclosed at source "
      f"({len(near)} declarations named near vacuity language in prose)")
