#!/usr/bin/env python3
"""
tools/p82_charge_enumeration.py — Stream 8, P8.2: charge pairs (p, q) in U + U versus reduced binary forms.

Enumerates all pairs with coordinates in [-B, B] (coordinates (e1, f1, e2, f2), e.f = 1), keeps those with
p^2 > 0, positive definite Q_{p,q} (Moore hep-th/9807087 (3.4)-(3.5)), reduces the form (a, b, c) = (p^2/2, p.q, q^2/2)
under SL(2, Z), and compares the classes found for each D = 4ac - b^2 with the reduced forms (WhichK3.reducedForms).
Primitive L_{p,q} (gcd of 2x2 minors = 1) realise every class, imprimitive forms included, as Moore's (3.18)
requires. A computation, not a kernel check; the kernel-checked box B = 1 is
DualScaleDyons/AttractorCharges.lean (charge_classes_small).
"""
import itertools, math
from collections import defaultdict
def pair(x,y): return x[0]*y[1]+x[1]*y[0]+x[2]*y[3]+x[3]*y[2]
def reduce(a,b,c):
    while True:
        if c<a: a,b,c=c,-b,a; continue
        if abs(b)>a:
            k=(a-b)//(2*a)  # b -> b+2ak in (-a,a]
            b2=b+2*a*k; c=(b2*b2+(4*a*c-b*b))//(4*a); b=b2; continue
        break
    if b<0 and (-b==a or a==c): b=-b
    return (a,b,c)
def reduced_forms(D):
    out=[]
    for a in range(1,D+1):
        if 3*a*a>D: break
        for b in range(-a+1,a+1):
            num=b*b+D
            if num%(4*a): continue
            c=num//(4*a)
            if c<a or (b<0 and c==a): continue
            out.append((a,b,c))
    return out
def minors_gcd(p,q):
    g=0
    for i,j in itertools.combinations(range(4),2): g=math.gcd(g,p[i]*q[j]-p[j]*q[i])
    return g
for B in (1,2):
    found=defaultdict(set); foundimp=defaultdict(set)
    R=range(-B,B+1)
    vecs=list(itertools.product(R,repeat=4))
    for p in vecs:
        a2=pair(p,p)
        if a2<=0: continue
        for q in vecs:
            c2=pair(q,q); b=pair(p,q)
            D=4*(a2//2)*(c2//2)-b*b
            if c2<=0 or D<=0: continue
            f=reduce(a2//2,b,c2//2)
            (found if minors_gcd(p,q)==1 else foundimp)[D].add(f)
    ok=[D for D in range(3,40) if D%4 in (0,3) and set(reduced_forms(D))==found[D]]
    extra=[D for D in found if not found[D]<=set(reduced_forms(D))]
    print('B',B,'complete D:',ok,'bad:',extra)
    print("  forms reached only by imprimitive L (not needed):", sum(len(v - found[k]) for k, v in foundimp.items()))
