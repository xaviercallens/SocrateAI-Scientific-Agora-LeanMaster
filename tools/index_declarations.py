#!/usr/bin/env python3
"""
tools/index_declarations.py
============================
Full-corpus SQLite declaration indexer (the "RAG" retrieval backend).

Unlike `leangraph.base_graph.BaseLeanGraphBuilder._index_key_declarations`,
which only scans a hand-picked list of ~27 "landmark" files, this walks every
`.lean` file in the project's own libraries -- including
`StringTheoryFormalization` (which that hardcoded list omits entirely) -- and
indexes every theorem/lemma/def/structure into `.leancache/declarations.db`
via the existing, real `leangraph.cache.LeanCacheManager` (SQLite schema and
incremental file-hash caching already implemented there; this script only
supplies the missing full-corpus walk).

Usage:
  python3 tools/index_declarations.py [--verbose]
"""

import argparse
import re
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT_DIR))

from leangraph.cache import LeanCacheManager

# Every real, first-party Lean library in this project (own lean_lib targets
# per lakefile.lean), not the vendored lean4basesource/ submodules.
OWN_LIBRARIES = [
    "StringTheoryFoundation",
    "DoubleFieldTheory",
    "DualScaleM24Formalization",
    "DualScaleValidation",
    "Lean5Corpus",
    "StringTheoryFormalization",
]

# Line-anchored: matches the START of a declaration regardless of how complex
# or how many lines its signature spans (the base_graph.py pattern this was
# initially copied from tries to also capture the full multi-arg signature in
# one regex and silently drops any declaration whose signature doesn't fit
# its two alternatives -- confirmed undercounting StringTheoryFormalization by
# >2x against a plain `grep -c '^theorem '`-style count; anchoring on just the
# declaration head and treating the rest of that first line as a preview
# avoids that failure mode entirely).
DECL_HEAD_PATTERN = re.compile(
    r"^(?P<kind>theorem|lemma|def|noncomputable\s+def|structure)\s+"
    r"(?P<name>[A-Za-z0-9_'.]+)(?P<rest_of_line>.*)$",
    re.MULTILINE,
)
DOC_COMMENT_PATTERN = re.compile(r"/--([\s\S]*?)-/\s*\Z")


def extract_declarations(fpath: Path) -> list[dict]:
    content = fpath.read_text(encoding="utf-8", errors="ignore")
    decls = []
    for m in DECL_HEAD_PATTERN.finditer(content):
        name = m.group("name")
        kind = re.sub(r"\s+", " ", m.group("kind")).replace("noncomputable ", "")
        preceding = content[: m.start()]
        doc_match = DOC_COMMENT_PATTERN.search(preceding.rstrip())
        docstring = doc_match.group(1).strip() if doc_match else ""
        decls.append(
            {
                "id": f"decl:{fpath.stem}:{name}",
                "name": name,
                "module": str(fpath.relative_to(ROOT_DIR)).replace("/", ".").removesuffix(".lean"),
                "decl_type": kind,
                "signature": m.group("rest_of_line").strip()[:160],
                "docstring": docstring[:200],
                "paper": "",
            }
        )
    return decls


def main():
    parser = argparse.ArgumentParser(description="Index all first-party Lean declarations into SQLite")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    cache = LeanCacheManager(ROOT_DIR)

    files_scanned = 0
    total_decls = 0
    per_library: dict[str, int] = {}

    for lib in OWN_LIBRARIES:
        lib_dir = ROOT_DIR / lib
        if not lib_dir.exists():
            print(f"  [SKIP] {lib}/ does not exist")
            continue
        lib_decl_count = 0
        for fpath in sorted(lib_dir.rglob("*.lean")):
            decls = extract_declarations(fpath)
            cache.update_cached_file(fpath, decls, repository=lib, domain=lib)
            files_scanned += 1
            total_decls += len(decls)
            lib_decl_count += len(decls)
            if args.verbose:
                print(f"    {fpath.relative_to(ROOT_DIR)}: {len(decls)} declarations")
        per_library[lib] = lib_decl_count
        print(f"  [{lib}] {lib_decl_count} declarations indexed")

    cache.save_hashes()

    print("=" * 60)
    print(f"Files scanned:        {files_scanned}")
    print(f"Declarations indexed: {total_decls}")
    print("By library:")
    for lib, n in per_library.items():
        print(f"  - {lib:<30}: {n}")
    stats = cache.get_stats()
    print(f"\nSQLite DB total rows (cumulative, incl. any prior indexing): {stats['total_declarations']}")
    print(f"DB path: {cache.db_path}")


if __name__ == "__main__":
    main()
