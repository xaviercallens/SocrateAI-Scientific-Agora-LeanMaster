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
DECL = re.compile(r'(?:/--(?P<doc>.*?)-/\s*)?^\s*(?:@\[[^\]]*\]\s*)?'
                  r'(?:(?:private|protected|noncomputable|partial|unsafe|scoped|local)\s+)*'
                  r'(?:theorem|lemma)\s+(?P<name>[A-Za-z_][\w\'.]*)', re.M | re.S)
# A base name can be shared by several declarations in different namespaces -- this repo has
# three `k3_euler_characteristic`. Keep ALL homonyms: binding the name to whichever file was
# read first produced a false positive against a declaration that *is* correctly disclosed,
# while the book distinguished them by fully-qualified name and this tool could not.
decls = collections.defaultdict(list)
for lib in LIBS:
    for p in pathlib.Path(lib).rglob('*.lean'):
        src = p.read_text(encoding='utf-8')
        for m in DECL.finditer(src):
            decls[m.group('name')].append((str(p), m.group('doc') or ''))

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

# Flag only when NO homonym carries the language: when the prose does not disambiguate,
# a disclosure on any declaration of that name is the honest benefit of the doubt.
missing, ok = [], []
for name, srcs in sorted(near.items()):
    cands = decls[name]
    files = ', '.join(f for f, _ in cands)
    if any(VAC.search(doc) for _, doc in cands):
        ok.append((name, files, sorted(srcs)))
    else:
        missing.append((name, files + (f"   [{len(cands)} homonyms]" if len(cands) > 1 else ''),
                        sorted(srcs)))


# --- self-test: a scan that cannot SEE a declaration reports it as clean -----------------
# `add_pos`/`add_neg` (both `@[simp]`) were invisible to axiom_audit.py and statement_lock.py
# until the v3.17.0 gate fix, and invisible again to the first version of these tools: three
# tools, one anchoring bug, the same two theorems. Stream 1 found 41 of 465 invisible on their
# side (modifier-prefixed). An empty report is NOT a clean bill.
if '--self-test' in sys.argv:
    _missing = [n for n in ('add_pos', 'add_neg') if n not in decls]
    print('SELF-TEST ' + ('FAIL -- parser cannot see: ' + ', '.join(_missing) if _missing
                          else 'ok -- attribute-prefixed controls visible'), file=sys.stderr)
    sys.exit(1 if _missing else 0)

print("=== DISCLOSED IN PROSE BUT NOT AT THE DECLARATION ===")
for name, f, srcs in missing:
    print(f"  {name}\n      lean: {f}\n      prose: {', '.join(srcs[:3])}")
print(f"\n{len(missing)} candidates; {len(ok)} correctly disclosed at source "
      f"({len(near)} declarations named near vacuity language in prose)")
