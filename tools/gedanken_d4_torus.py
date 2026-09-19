#!/usr/bin/env python3
"""
tools/gedanken_d4_torus.py — Stream 8, thought experiment G2 ("trapping in four dimensions").

Transcendental lattice T(A) of the complex torus A = R^4/L (L = Z^4 or the Hurwitz order D4), for the complex
structure given by left multiplication by a unit imaginary quaternion u (u = i, or u = (i+j+k)/sqrt3, the
complex structure commuting with the Hurwitz unit omega = (-1+i+j+k)/2). The holomorphic 2-form spans the
plane of Kaehler forms omega_v(x, y) = <v x, y> with v perpendicular to u; T(A) is the lattice of integral
2-forms in that plane, with the wedge pairing. Exact rational arithmetic; a computation, not a kernel check.
Sanity checks against Taormina-Wendland (1107_3834.txt): Z^4 with u = i gives T(A) = diag(2,2), so
T(Km A) = T(A)(2) = diag(4,4), their (3.3), ll. 1044-1055; D4 with u = i gives the same, as TW state for the
tetrahedral Kummer surface, ll. 1961-1970.
"""
import itertools
from fractions import Fraction as F
def qmul(p,q):
    a1,b1,c1,d1=p; a2,b2,c2,d2=q
    return (a1*a2-b1*b2-c1*c2-d1*d2, a1*b2+b1*a2+c1*d2-d1*c2, a1*c2-b1*d2+c1*a2+d1*b2, a1*d2+b1*c2-c1*b2+d1*a2)
dot=lambda v,w: sum(x*y for x,y in zip(v,w))
PAIRS=list(itertools.combinations(range(4),2))
def form(X,B): return [dot(qmul(X,B[i]),B[j]) for i,j in PAIRS]
def wedge(a,b): return a[0]*b[5]-a[1]*b[4]+a[2]*b[3]+a[3]*b[2]-a[4]*b[1]+a[5]*b[0]
I,J,K=(0,1,0,0),(0,0,1,0),(0,0,0,1)
def TA(B,perp):
    fI,fJ,fK=form(I,B),form(J,B),form(K,B)
    om=lambda c:[F(c[0])*x+F(c[1])*y+F(c[2])*z for x,y,z in zip(fI,fJ,fK)]
    a,b=om(perp[0]),om(perp[1])
    # pick coordinates p,q with nonzero minor
    for p,q in itertools.combinations(range(6),2):
        det=a[p]*b[q]-a[q]*b[p]
        if det!=0: break
    pts=[]
    for xp in range(-8,9):
        for xq in range(-8,9):
            s=(xp*b[q]-xq*b[p])/det; t=(a[p]*xq-a[q]*xp)/det
            x=[s*a[k]+t*b[k] for k in range(6)]
            if all(v.denominator==1 for v in x) and any(x): pts.append(tuple(int(v) for v in x))
    pts.sort(key=lambda v: abs(wedge(v,v)))
    v1=pts[0]
    def gen(v1,v2):
        d=wedge(v1,v1)*wedge(v2,v2)-wedge(v1,v2)**2
        return d
    best=None
    for v2 in pts[1:]:
        d=gen(v1,v2)
        if d!=0 and (best is None or abs(d)<abs(best[0])): best=(d,v2)
    v2=best[1]
    return [[wedge(v1,v1),wedge(v1,v2)],[wedge(v2,v1),wedge(v2,v2)]], best[0]
h=F(1,2)
hurwitz=[(h,h,h,h),(0,1,0,0),(0,0,1,0),(0,0,0,1)]
square=[(1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1)]
for name,B in (('Z^4 (square)',square),('D4 = Hurwitz',hurwitz)):
    for cs,perp in (('u = i',[(0,1,0),(0,0,1)]),('u = (i+j+k)/sqrt3 (omega)',[(1,-1,0),(1,1,-2)])):
        G,d=TA(B,perp); print(f'{name:14} {cs:28} T(A) Gram {G}  det {d}')
