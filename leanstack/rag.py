"""
leanstack/rag.py — LeanRAG: retrieval over the declarations in LeanMemory.

Three signals, fused by reciprocal-rank fusion (RRF, k = 60), each optional except the first:
  1. lexical  BM25 over name tokens (split on `.`, `_` and camelCase), statement text and docstring;
  2. dense    an `embed(texts) -> vectors` callable you pass in (none is bundled: no model runs here);
  3. graph    after ranking, each hit's kernel-level neighbours (edges table, from depgraph.jsonl)
              are added below it with the relation that brought them in ('uses' / 'used by').

Every hit carries file, line, statement and the declaration's kernel status, because retrieval is
for finding what exists — the answer to "is it proved" is always the gate, never the index.

Scale note: this BM25 is pure Python and builds its index in memory on first query (fine for
~10^4 declarations; LeanMaster has ~1.5·10^3). For 10^5+ switch `LexicalIndex` to SQLite FTS5
(same table, `bm25()` ranking) — see docs/LEAN_SCALE_ARCHITECTURE.md §6.
"""

import math
import re
from collections import Counter

from leanstack.datastore import kernel_status
from leanstack.memory import LeanMemory

TOKEN = re.compile(r"[A-Z]+(?![a-z])|[A-Za-z][a-z0-9']*|\d+|[∑∏√≤≥≠⁻ᵀ⬝∀∃ΓΘΦχσ]")


def tokens(text: str) -> list[str]:
    """Lower-cased tokens; identifiers are split on `.`, `_` and camelCase so that
    `thetaShift_isODD` matches a query for 'theta shift odd'."""
    out = []
    for word in re.split(r"[\s._(){}\[\],:;=+\-*/<>|`'\"]+", text):
        out.extend(t.lower() for t in TOKEN.findall(word))
    return out


class LexicalIndex:
    def __init__(self, docs: dict[str, str], k1: float = 1.2, b: float = 0.75):
        self.k1, self.b = k1, b
        self.tf = {key: Counter(tokens(text)) for key, text in docs.items()}
        self.len = {key: sum(c.values()) for key, c in self.tf.items()}
        self.avg = (sum(self.len.values()) / len(self.len)) if self.len else 0.0
        df = Counter(t for c in self.tf.values() for t in c)
        n = len(self.tf)
        self.idf = {t: math.log(1 + (n - f + 0.5) / (f + 0.5)) for t, f in df.items()}

    def search(self, query: str, k: int = 20) -> list[tuple[str, float]]:
        q = tokens(query)
        scores = {}
        for key, tf in self.tf.items():
            s = 0.0
            for t in q:
                f = tf.get(t, 0)
                if f:
                    s += self.idf[t] * f * (self.k1 + 1) / (f + self.k1 * (1 - self.b + self.b * self.len[key] / self.avg))
            if s > 0:
                scores[key] = s
        return sorted(scores.items(), key=lambda kv: -kv[1])[:k]


def rrf(rankings: list[list[str]], k: int = 60) -> list[tuple[str, float]]:
    score: dict[str, float] = {}
    for ranking in rankings:
        for i, key in enumerate(ranking):
            score[key] = score.get(key, 0.0) + 1.0 / (k + i + 1)
    return sorted(score.items(), key=lambda kv: -kv[1])


class Retriever:
    def __init__(self, memory: LeanMemory, embed=None, kinds: tuple[str, ...] | None = None):
        self.memory = memory
        self.embed = embed
        where, params = "1=1", ()
        if kinds:
            where = "kind IN (" + ",".join("?" for _ in kinds) + ")"
            params = tuple(kinds)
        self.rows = {r["name"]: r for r in memory.declarations(where, params)}
        self.docs = {name: f"{name} {name} {r.get('statement') or ''} {r.get('docstring') or ''}"
                     for name, r in self.rows.items()}
        self._lex = None
        self._vecs = None

    @property
    def lexical(self) -> LexicalIndex:
        if self._lex is None:
            self._lex = LexicalIndex(self.docs)
        return self._lex

    def _dense(self, query: str, k: int) -> list[str]:
        if self.embed is None:
            return []
        keys = list(self.docs)
        if self._vecs is None:
            self._vecs = dict(zip(keys, self.embed([self.docs[key] for key in keys])))
        qv = self.embed([query])[0]

        def cos(a, b):
            na = math.sqrt(sum(x * x for x in a)) or 1.0
            nb = math.sqrt(sum(x * x for x in b)) or 1.0
            return sum(x * y for x, y in zip(a, b)) / (na * nb)

        return [key for key, _ in sorted(((key, cos(qv, v)) for key, v in self._vecs.items()),
                                         key=lambda kv: -kv[1])[:k]]

    def search(self, query: str, k: int = 10, expand: int = 3) -> list[dict]:
        lex = [key for key, _ in self.lexical.search(query, k=4 * k)]
        dense = self._dense(query, 4 * k)
        fused = rrf([r for r in (lex, dense) if r])[:k]
        hits, seen = [], set()
        for name, score in fused:
            hits.append(self._hit(name, score, via=None))
            seen.add(name)
        if expand:
            for h in list(hits):
                nb = self.memory.neighbours(h["name"])
                extra = [(n, "dependency of") for n in nb["uses"]] + [(n, "depends on") for n in nb["used_by"]]
                added = 0
                for n, rel in extra:
                    if n in seen or n not in self.rows:  # only the project's own declarations
                        continue
                    hits.append(self._hit(n, h["score"] / 2, via=f"{rel} {h['name']}"))
                    seen.add(n)
                    added += 1
                    if added >= expand:
                        break
        return hits

    def _hit(self, name: str, score: float, via: str | None) -> dict:
        r = self.rows[name]
        return {"name": name, "score": round(score, 5), "kind": r.get("kind"), "file": r.get("file"),
                "line": r.get("line"), "statement": (r.get("statement") or "")[:300],
                "docstring": (r.get("docstring") or "")[:200], "kernel_status": kernel_status(r), "via": via}

    def prior_attempts(self, theorem: str) -> dict:
        """What provers already tried on this theorem, and the failure patterns seen — so an
        agent does not repeat an approach that already failed."""
        short = theorem.split(".")[-1]
        attempts = self.memory.attempts_for(short)
        return {"attempts": len(attempts), "accepted": sum(a["accepted"] for a in attempts),
                "models": sorted({a["model"] for a in attempts}),
                "failures": [{"pattern": f["pattern"], "count": f["count"]} for f in self.memory.failures(decl=short)]}
