#!/usr/bin/env python3
"""
tools/e4_omega_kummer.py — Stream 8, E4 on the tau = omega Kummer surface (D = 12).

Exact rational arithmetic; a computation, not a kernel check (the kernel-checked part is
DualScaleDyons/KummerOmegaE4.lean).

1. Right multiplication by the 24 Hurwitz units maps the D4 = Hurwitz lattice to itself and fixes the three
   Kaehler forms omega_I, omega_J, omega_K. It therefore fixes the whole positive 3-plane Sigma, so it is
   holomorphic, symplectic and Kaehler for EVERY left complex structure u in the hyperkaehler S^2, in
   particular u = i (Taormina-Wendland's tetrahedral Kummer, D = 16) and u = (i+j+k)/sqrt3 (the omega structure
   of G2, D = 12).
2. On the Kummer surface, G = (Z2)^4 x| A4 (order 192). Lefschetz numbers chi(g) = 2 + tr(g | Lambda^2 H^1) +
   #(fixed nodes), and the Frame shape of g from chi(g^k), k | ord g.
3. Holomorphic isometries of the D4 torus fixing 0, for three complex structures: all 1152 lattice automorphisms,
   those commuting with L_u, and the order of their action on H^{2,0}.
4. Taormina-Wendland's Z3-symmetric torus T(3) (1107_3834.txt (5.1), ll. 2716-2720): its transcendental lattice.
"""
import itertools
from collections import Counter
from fractions import Fraction as F

import sympy as sp


def qmul(p, q):
    a1, b1, c1, d1 = p
    a2, b2, c2, d2 = q
    return (a1*a2 - b1*b2 - c1*c2 - d1*d2, a1*b2 + b1*a2 + c1*d2 - d1*c2,
            a1*c2 - b1*d2 + c1*a2 + d1*b2, a1*d2 + b1*c2 - c1*b2 + d1*a2)


dot = lambda v, w: sum(x*y for x, y in zip(v, w))
h = F(1, 2)
H = [(h, h, h, h), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1)]          # Hurwitz basis
coords = lambda v: (2*v[0], v[1] - v[0], v[2] - v[0], v[3] - v[0])   # coordinates in that basis
inH = lambda v: all(F(c).denominator == 1 for c in coords(v))
PAIRS = list(itertools.combinations(range(4), 2))


def lam2(M):
    """Pull-back on 2-forms: (f^* a)(e_p, e_q) = a(f e_p, f e_q), rows of M = coords of f(e_p)."""
    return [[M[p][r]*M[q][s] - M[p][s]*M[q][r] for (r, s) in PAIRS] for (p, q) in PAIRS]


apply = lambda L, a: [sum(L[i][j]*a[j] for j in range(6)) for i in range(6)]
form = lambda X: [dot(qmul(X, H[i]), H[j]) for i, j in PAIRS]
I, J, K = (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1)
fI, fJ, fK = form(I), form(J), form(K)

r = [F(-1), -h, F(0), h, F(1)]
units = [v for v in itertools.product(r, repeat=4) if dot(v, v) == 1 and inH(v)]
mat = lambda f: [coords(f(H[p])) for p in range(4)]

# --- 1. right units fix Sigma --------------------------------------------------------------------------
ok = len(units) == 24
for b in units:
    M = mat(lambda x: qmul(x, b))
    ok &= all(F(c).denominator == 1 for row in M for c in row)
    L = lam2(M)
    ok &= all(apply(L, f) == f for f in (fI, fJ, fK))
print('1. 24 right units preserve D4 and fix omega_I, omega_J, omega_K:', ok)

# --- 2. the Kummer group and its Frame shapes ----------------------------------------------------------
reps, seen = [], set()
for b in units:
    key = frozenset([b, tuple(-c for c in b)])
    if key not in seen:
        seen.add(key)
        reps.append(b)
F2 = list(itertools.product(range(2), repeat=4))


def element(b, t):
    """(integer matrix M_b on H, node map on F2^4) of x -> x b + t/2."""
    M = [[int(c) for c in row] for row in mat(lambda x: qmul(x, b))]
    node = {a: tuple((sum(a[p]*M[p][q] for p in range(4)) + t[q]) % 2 for q in range(4)) for a in F2}
    return M, node


def compose(g1, g2):  # g2 after g1
    (M1, n1), (M2, n2) = g1, g2
    M = [[sum(M1[p][k]*M2[k][q] for k in range(4)) for q in range(4)] for p in range(4)]
    return M, {a: n2[n1[a]] for a in F2}


def chi(g):
    M, node = g
    L = lam2(M)
    return 2 + sum(L[i][i] for i in range(6)) + sum(node[a] == a for a in F2)


ID4 = [[int(p == q) for q in range(4)] for p in range(4)]


def is_id(g):
    M, node = g
    return (M == ID4 or M == [[-x for x in row] for row in ID4]) and all(node[a] == a for a in F2)


def frame(g):
    pw, k = [g], 1
    while not is_id(pw[-1]):
        pw.append(compose(pw[-1], g))
    n = len(pw)
    chis = {k: chi(pw[k-1]) for k in range(1, n+1)}
    mob = {1: 1, 2: -1, 3: -1, 4: 0, 6: 1}
    shape = []
    for d in range(1, n+1):
        if n % d == 0:
            ad = sum(mob[d//e]*chis[e] for e in range(1, d+1) if d % e == 0) // d
            if ad:
                shape.append((d, ad))
    return n, tuple(shape)


shapes = Counter(frame(element(b, t)) for b in reps for t in F2)
print('2. Kummer group order', sum(shapes.values()), '; (order, Frame shape): count')
for k, v in sorted(shapes.items()):
    print('     ', k, v)

# --- 3. holomorphic isometries of the D4 torus ---------------------------------------------------------
gram = [[dot(H[p], H[q]) for q in range(4)] for p in range(4)]
auts = [im for im in itertools.product(units, repeat=4)
        if all(dot(im[p], im[q]) == gram[p][q] for p in range(4) for q in range(p, 4))]
lin = lambda A, x: tuple(sum(coords(x)[p]*A[p][m] for p in range(4)) for m in range(4))
print('3. |Aut(D4)| =', len(auts))
for name, u, perp in (('i', I, [J, K]), ('omega', (0, 1, 1, 1), [(0, 1, -1, 0), (0, 1, 1, -2)]),
                      ('(i+j)/sqrt2', (0, 1, 1, 0), [(0, 1, -1, 0), K])):
    hol = [A for A in auts if all(lin(A, qmul(u, H[p])) == qmul(u, lin(A, H[p])) for p in range(4))]
    fa, fb = form(perp[0]), form(perp[1])
    p, q = next((p, q) for p, q in itertools.combinations(range(6), 2) if fa[p]*fb[q] - fa[q]*fb[p] != 0)
    d = fa[p]*fb[q] - fa[q]*fb[p]
    orders = Counter()
    for A in hol:
        L = lam2([coords(A[m]) for m in range(4)])
        m2 = [[(g[p]*fb[q] - g[q]*fb[p])/d, (fa[p]*g[q] - fa[q]*g[p])/d] for g in (apply(L, fa), apply(L, fb))]
        P, n = m2, 1
        while P != [[1, 0], [0, 1]]:
            P = [[sum(P[i][k]*m2[k][j] for k in range(2)) for j in range(2)] for i in range(2)]
            n += 1
        orders[n] += 1
    print(f'   u = {name:12} holomorphic isometries fixing 0: {len(hol):3}; order on H^(2,0): {dict(sorted(orders.items()))}')

# --- 4. TW's Z3-symmetric torus T(3) -------------------------------------------------------------------
s3 = sp.sqrt(3)
lam = [(1, 0), (sp.I, 0), (sp.Rational(1, 2), s3/2), (-sp.I/2, sp.I*s3/2)]
Om = [sp.expand(lam[a][0]*lam[b][1] - lam[a][1]*lam[b][0]) for a, b in PAIRS]
re, im = [sp.re(x) for x in Om], [sp.im(x) for x in Om]
wedge = lambda a, b: a[0]*b[5] - a[1]*b[4] + a[2]*b[3] + a[3]*b[2] - a[4]*b[1] + a[5]*b[0]
v1, v2 = [sp.nsimplify(x*2/s3) for x in re], [sp.nsimplify(x*2/s3) for x in im]
# v1, v2 have entries in {0, +-1} on disjoint supports, so they are a Z-basis of the integral 2-forms in the plane
print('4. T(3): Re Omega, Im Omega proportional to', v1, v2,
      '; Gram', [[wedge(v1, v1), wedge(v1, v2)], [wedge(v2, v1), wedge(v2, v2)]])
