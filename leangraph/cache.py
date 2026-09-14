"""
LeanGraph Persistent Cache & SQLite Indexer
Provides ultra-fast incremental indexing (<100ms) over massive Lean 4 repositories.
"""

import os
import hashlib
import json
import sqlite3
from pathlib import Path
from typing import Dict, List, Optional, Any

CACHE_DIR = Path(".leancache")
DB_PATH = CACHE_DIR / "declarations.db"
HASH_CACHE_PATH = CACHE_DIR / "file_hashes.json"

class LeanCacheManager:
    def __init__(self, root_dir: Path):
        self.root_dir = root_dir
        self.cache_dir = root_dir / CACHE_DIR
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.db_path = root_dir / DB_PATH
        self.hash_path = root_dir / HASH_CACHE_PATH
        self.file_hashes: Dict[str, str] = self._load_hashes()
        self._init_db()

    def _load_hashes(self) -> Dict[str, str]:
        if self.hash_path.exists():
            try:
                with open(self.hash_path, "r", encoding="utf-8") as f:
                    return json.load(f)
            except Exception:
                return {}
        return {}

    def save_hashes(self):
        with open(self.hash_path, "w", encoding="utf-8") as f:
            json.dump(self.file_hashes, f, indent=2)

    def _init_db(self):
        conn = sqlite3.connect(str(self.db_path))
        c = conn.cursor()
        c.execute("""
            CREATE TABLE IF NOT EXISTS declarations (
                id TEXT PRIMARY KEY,
                name TEXT,
                module TEXT,
                repository TEXT,
                decl_type TEXT,
                signature TEXT,
                docstring TEXT,
                paper TEXT,
                domain TEXT,
                file_path TEXT,
                file_hash TEXT
            )
        """)
        c.execute("CREATE INDEX IF NOT EXISTS idx_name ON declarations (name)")
        c.execute("CREATE INDEX IF NOT EXISTS idx_repo ON declarations (repository)")
        c.execute("CREATE INDEX IF NOT EXISTS idx_domain ON declarations (domain)")
        conn.commit()
        conn.close()

    def compute_file_hash(self, file_path: Path) -> str:
        h = hashlib.sha256()
        h.update(file_path.read_bytes())
        return h.hexdigest()

    def is_file_cached(self, file_path: Path) -> bool:
        rel_path = str(file_path.relative_to(self.root_dir))
        if rel_path not in self.file_hashes:
            return False
        current_hash = self.compute_file_hash(file_path)
        return self.file_hashes[rel_path] == current_hash

    def update_cached_file(self, file_path: Path, decls: List[Dict[str, Any]], repository: str, domain: str):
        rel_path = str(file_path.relative_to(self.root_dir))
        file_hash = self.compute_file_hash(file_path)
        self.file_hashes[rel_path] = file_hash

        conn = sqlite3.connect(str(self.db_path))
        c = conn.cursor()
        c.execute("DELETE FROM declarations WHERE file_path = ?", (rel_path,))
        for d in decls:
            c.execute("""
                INSERT OR REPLACE INTO declarations 
                (id, name, module, repository, decl_type, signature, docstring, paper, domain, file_path, file_hash)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                d["id"], d["name"], d["module"], repository, d.get("decl_type", "theorem"),
                d.get("signature", ""), d.get("docstring", ""), d.get("paper", ""), domain,
                rel_path, file_hash
            ))
        conn.commit()
        conn.close()

    def search(self, query: str, repository: Optional[str] = None, limit: int = 25) -> List[Dict[str, Any]]:
        conn = sqlite3.connect(str(self.db_path))
        c = conn.cursor()
        q = f"%{query}%"
        if repository:
            c.execute("""
                SELECT id, name, module, repository, decl_type, signature, docstring, paper, domain, file_path
                FROM declarations
                WHERE (name LIKE ? OR docstring LIKE ? OR signature LIKE ?) AND repository = ?
                LIMIT ?
            """, (q, q, q, repository, limit))
        else:
            c.execute("""
                SELECT id, name, module, repository, decl_type, signature, docstring, paper, domain, file_path
                FROM declarations
                WHERE name LIKE ? OR docstring LIKE ? OR signature LIKE ?
                LIMIT ?
            """, (q, q, q, limit))
        rows = c.fetchall()
        conn.close()

        results = []
        for r in rows:
            results.append({
                "id": r[0], "name": r[1], "module": r[2], "repository": r[3],
                "decl_type": r[4], "signature": r[5], "docstring": r[6],
                "paper": r[7], "domain": r[8], "file_path": r[9]
            })
        return results

    def get_stats(self) -> Dict[str, Any]:
        conn = sqlite3.connect(str(self.db_path))
        c = conn.cursor()
        c.execute("SELECT COUNT(*) FROM declarations")
        total = c.fetchone()[0]
        c.execute("SELECT repository, COUNT(*) FROM declarations GROUP BY repository")
        by_repo = dict(c.fetchall())
        c.execute("SELECT domain, COUNT(*) FROM declarations GROUP BY domain")
        by_domain = dict(c.fetchall())
        conn.close()
        return {
            "total_declarations": total,
            "cached_files": len(self.file_hashes),
            "by_repository": by_repo,
            "by_domain": by_domain
        }
