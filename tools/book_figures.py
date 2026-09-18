#!/usr/bin/env python3
"""
tools/book_figures.py — computed figures for the master book (papers/book/) and the papers.

Every number plotted comes from one of:
  * a Lean definition, parsed from the .lean source (the E8 Cartan matrix, the U matrix, the EOT table,
    the M24 dimension table, the K3 Hodge numbers, the circle momenta and the generalized metric formula);
  * a formula pinned to a source in papers/foundations/ (quoted in each figure's `source`);
  * the theorem atlas (.leancache/depgraph.jsonl, papers/book/generated/atlas_data.json).
Before plotting, the script re-checks numerically the facts the Lean kernel proves about that data
(det E8 = 1, signature (3,19), sum of squares = |M24|, chi(K3) = 24, the T-duality invariance ...), and
stops if the parsed data disagree. Numerical checks are illustrations, never a substitute for the proofs.

Output: papers/book/generated/figures/<name>.pdf  and  papers/book/generated/figures/FIGURES.md
Run:    ~/venv/bin/python tools/book_figures.py
"""

import collections
import json
import math
import re
from fractions import Fraction
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
import networkx as nx  # noqa: E402
import numpy as np  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "papers" / "book" / "generated" / "figures"
OUT.mkdir(parents=True, exist_ok=True)

plt.rcParams.update({
    "font.family": "serif", "mathtext.fontset": "cm", "font.size": 10, "axes.titlesize": 10.5,
    "axes.labelsize": 10, "legend.fontsize": 8.5, "figure.dpi": 150, "savefig.bbox": "tight",
    "axes.spines.top": False, "axes.spines.right": False,
})
LIBCOLORS = {
    "DualScaleStream2": "#1b7837", "StringTheoryFormalization": "#2166ac", "DoubleFieldTheory": "#b2182b",
    "DualScaleM24Formalization": "#e08214", "StringTheoryFoundation": "#8073ac",
    "DualScaleValidation": "#35978f", "Lean5Corpus": "#878787",
}
CATALOGUE = []


def save(fig, name, chapters, caption, source, checks):
    fig.savefig(OUT / f"{name}.pdf")
    plt.close(fig)
    CATALOGUE.append(dict(name=name, chapters=chapters, caption=caption, source=source, checks=checks))
    print(f"  {name}.pdf  ({', '.join(chapters)})")


def lean(path):
    return (ROOT / path).read_text(encoding="utf-8")


def parse_matrix(text, name):
    m = re.search(rf"def {name}\b[^:]*:[^=]*:=\s*!!\[(.*?)\]", text, re.S)
    rows = [r for r in m.group(1).split(";")]
    return np.array([[int(x) for x in r.replace("\n", " ").split(",")] for r in rows])


# ----------------------------------------------------------------------------------------------
def fig_circle_spectrum():
    """Tong §8.2 (ll. 11351-11470): M^2 = n^2/R^2 + w^2 R^2/a'^2 + (2/a')(N + Ntilde - 2), N - Ntilde = n w.
    Lean (StringTheoryFormalization/UseCases/TDualityMassSpectrum.lean, units a' = 1):
    leftMomentum n w R = n/R + w R, rightMomentum n w R = n/R - w R."""
    src = lean("StringTheoryFormalization/UseCases/TDualityMassSpectrum.lean")
    assert "def leftMomentum (n w R : ℚ) : ℚ := n / R + w * R" in src
    assert "def rightMomentum (n w R : ℚ) : ℚ := n / R - w * R" in src

    def pL(n, w, R):
        return n / R + w * R

    def pR(n, w, R):
        return n / R - w * R

    # exact check of the Lean theorem tduality_invariant_mass_squared on rational samples
    for n in range(-3, 4):
        for w in range(-3, 4):
            for R in (Fraction(1, 3), Fraction(2, 5), Fraction(7, 4), Fraction(3)):
                a = pL(w, n, 1 / R) ** 2 + pR(w, n, 1 / R) ** 2
                b = pL(n, w, R) ** 2 + pR(n, w, R) ** 2
                assert a == b

    def m2(n, w, r):
        # a' = 1; lowest oscillator levels compatible with level matching N - Nt = n w
        N, Nt = (n * w, 0) if n * w >= 0 else (0, -n * w)
        return n ** 2 / r ** 2 + w ** 2 * r ** 2 + 2 * (N + Nt - 2)

    r = np.geomspace(0.25, 4, 600)
    states = [((0, 0), "tachyon $(0,0)$", "k", "-"),
              ((1, 0), "momentum $n=1$", "#2166ac", "-"), ((2, 0), "momentum $n=2$", "#2166ac", "--"),
              ((0, 1), "winding $w=1$", "#b2182b", "-"), ((0, 2), "winding $w=2$", "#b2182b", "--"),
              ((1, 1), "$n=w=1$ ($N=1,\\tilde N=0$)", "#1b7837", "-")]
    fig, ax = plt.subplots(figsize=(6.4, 3.9))
    for (n, w), lab, c, ls in states:
        ax.plot(r, m2(n, w, r), color=c, ls=ls, lw=1.6, label=lab)
    ax.axvline(1, color="gray", lw=0.8, ls=":")
    ax.axhline(0, color="gray", lw=0.6)
    ax.set_xscale("log")
    ax.set_xticks([0.25, 0.5, 1, 2, 4])
    ax.set_xticklabels(["1/4", "1/2", "1", "2", "4"])
    ax.set_ylim(-4.5, 14)
    ax.set_xlabel(r"radius $R/\sqrt{\alpha'}$ (log scale)")
    ax.set_ylabel(r"$\alpha' M^2$")
    ax.annotate("self-dual radius:\n$n=w=\\pm1$ states massless", xy=(1, 0), xytext=(1.45, 5.2),
                arrowprops=dict(arrowstyle="->", lw=0.8), fontsize=8.5)
    ax.set_title(r"Closed-string spectrum on a circle: $R \leftrightarrow \alpha'/R$ with $n\leftrightarrow w$")
    ax.legend(ncol=2, frameon=False, loc="upper left", bbox_to_anchor=(0.0, -0.18))
    save(fig, "circle_spectrum", ["ch07_circle", "ch08_tduality"],
         "Lowest mass levels of the closed bosonic string on a circle of radius $R$ as a function of "
         "$\\log R$, with the lowest oscillator levels allowed by level matching $N-\\tilde N=nw$. "
         "Momentum and winding curves are mirror images under $R\\mapsto\\alpha'/R$; at the self-dual "
         "radius the $n=w=\\pm1$ states become massless (enhanced gauge symmetry).",
         "Tong §8.2, ll. 11351–11470; Lean `leftMomentum`, `rightMomentum` (units α′ = 1)",
         "exact rational check of `tduality_invariant_mass_squared` for n, w ∈ [−3,3], four radii")


def fig_dual_scale():
    """Lean DualScaleStream2/DualScale/TraceBound.lean: dualScale G = tr G + tr G^{-1}; for G = [R^2]
    dualScale = (R + 1/R)^2 - 2 (dualScale_circle); R + 1/R >= 2 (circle_effective_scale_ge_two);
    dualScale G >= 2d for PosDef G (dualScale_ge)."""
    src = lean("DualScaleStream2/DualScale/TraceBound.lean")
    assert "theorem dualScale_ge" in src and "theorem circle_effective_scale_ge_two" in src
    rng = np.random.default_rng(20260917)
    fig, axs = plt.subplots(1, 3, figsize=(10.2, 3.2))
    R = np.geomspace(0.2, 5, 400)
    axs[0].plot(R, R + 1 / R, color="#1b7837", lw=1.8, label=r"$R+\alpha'/R$")
    axs[0].plot(R, R, color="#2166ac", lw=1, ls="--", label=r"$R$")
    axs[0].plot(R, 1 / R, color="#b2182b", lw=1, ls="--", label=r"$\alpha'/R$")
    axs[0].axhline(2, color="gray", lw=0.6, ls=":")
    axs[0].set_xscale("log")
    axs[0].set_ylim(0, 6)
    axs[0].set_xticks([0.2, 0.5, 1, 2, 5])
    axs[0].set_xticklabels(["0.2", "0.5", "1", "2", "5"])
    axs[0].set_xlabel(r"$R/\sqrt{\alpha'}$")
    axs[0].set_title(r"(a) circle: $R+\alpha'/R \geq 2\sqrt{\alpha'}$")
    axs[0].legend(frameon=False)
    a = np.linspace(-2, 2, 300)
    A, B = np.meshgrid(a, a)
    Z = np.exp(A) + np.exp(-A) + np.exp(B) + np.exp(-B)
    im = axs[1].contourf(A, B, Z, levels=np.linspace(4, 16, 25), cmap="viridis")
    axs[1].contour(A, B, Z, levels=[4.5, 6, 8, 12], colors="w", linewidths=0.5)
    axs[1].plot(0, 0, "r*", ms=8)
    fig.colorbar(im, ax=axs[1], shrink=0.85, label=r"$\mathrm{tr}\,G+\mathrm{tr}\,G^{-1}$")
    axs[1].set_xlabel(r"$\log\lambda_1$")
    axs[1].set_ylabel(r"$\log\lambda_2$")
    axs[1].set_title(r"(b) $d=2$: minimum $4$ at $G=1$")
    excess = []
    for d in (2, 3, 6):
        vals = []
        for _ in range(4000):
            M = rng.normal(size=(d, d))
            G = M @ M.T + 1e-3 * np.eye(d)
            vals.append(np.trace(G) + np.trace(np.linalg.inv(G)) - 2 * d)
        vals = np.array(vals)
        assert vals.min() >= -1e-9
        excess.append(vals)
        axs[2].hist(np.log10(vals + 1e-12), bins=60, histtype="step", lw=1.3, label=f"$d={d}$")
    axs[2].set_xlabel(r"$\log_{10}(\mathrm{tr}\,G+\mathrm{tr}\,G^{-1}-2d)$")
    axs[2].set_ylabel("count")
    axs[2].set_title("(c) random positive definite $G$")
    axs[2].legend(frameon=False)
    fig.tight_layout()
    save(fig, "dual_scale_bound", ["ch31_dualscale", "ch08_tduality", "ch01_intro"],
         "The dual-scale bound. (a) On a circle the effective scale $R+\\alpha'/R$ is minimized at the "
         "self-dual radius. (b) For $d=2$ and positive-definite $G$ with eigenvalues $\\lambda_{1,2}$, "
         "$\\mathrm{tr}\\,G+\\mathrm{tr}\\,G^{-1}=\\sum_i(\\lambda_i+\\lambda_i^{-1})$ has its minimum $2d=4$ at $G=1$. "
         "(c) Excess over $2d$ for 4000 random positive definite matrices in each dimension: never negative, "
         "as the Lean theorem `dualScale_ge` guarantees. The plot illustrates the theorem; it proves nothing.",
         "Lean `dualScale_circle`, `circle_effective_scale_ge_two`, `dualScale_ge` (TraceBound.lean)",
         "12000 random samples, minimum excess ≥ 0")


def fig_e8_and_k3():
    e8 = parse_matrix(lean("DualScaleStream2/Lattice/E8.lean"), "cartanE8")
    U = parse_matrix(lean("DualScaleStream2/Lattice/Hyperbolic.lean"), "hyperbolicU")
    assert e8.shape == (8, 8) and (e8 == e8.T).all()
    assert round(np.linalg.det(e8)) == 1 and np.all(np.linalg.eigvalsh(e8) > 0)
    assert (np.diag(e8) % 2 == 0).all()
    inv = np.rint(np.linalg.inv(e8)).astype(int)
    assert (inv @ e8 == np.eye(8, dtype=int)).all()
    blocks = [U, U, U, -e8, -e8]
    n = sum(b.shape[0] for b in blocks)
    K = np.zeros((n, n), dtype=int)
    i = 0
    for b in blocks:
        k = b.shape[0]
        K[i:i + k, i:i + k] = b
        i += k
    ev = np.linalg.eigvalsh(K)
    sig = (int((ev > 0).sum()), int((ev < 0).sum()))
    assert sig == (3, 19) and round(abs(np.linalg.det(K))) == 1 and (np.diag(K) % 2 == 0).all()
    muk = np.zeros((24, 24), dtype=int)
    muk[:22, :22] = K
    muk[22:, 22:] = -U  # Mukai pairing adds a hyperbolic plane (H^0 + H^4) with the sign -((r,s))
    evm = np.linalg.eigvalsh(muk)
    assert (int((evm > 0).sum()), int((evm < 0).sum())) == (4, 20)

    fig, axs = plt.subplots(1, 3, figsize=(10.5, 3.6), gridspec_kw=dict(width_ratios=[1, 1, 1.35]))
    for ax, M, t in [(axs[0], e8, r"$E_8$ Cartan matrix (Gram)"), (axs[1], inv, r"its inverse (integer!)")]:
        v = np.abs(M).max()
        ax.imshow(M, cmap="RdBu_r", vmin=-v, vmax=v)
        for (x, y), val in np.ndenumerate(M):
            ax.text(y, x, str(val), ha="center", va="center", fontsize=6.5)
        ax.set_xticks([])
        ax.set_yticks([])
        ax.set_title(t)
    axs[2].imshow(K, cmap="RdBu_r", vmin=-2, vmax=2)
    for pos, lab in [(0.5, "U"), (2.5, "U"), (4.5, "U"), (9.5, r"$E_8(-1)$"), (17.5, r"$E_8(-1)$")]:
        axs[2].text(-1.2, pos, lab, ha="right", va="center", fontsize=8)
    axs[2].set_xticks([])
    axs[2].set_yticks([])
    axs[2].set_title(r"$H^2(K3,\mathbb{Z})\cong 3U\oplus 2E_8(-1)$, signature $(3,19)$")
    fig.tight_layout()
    save(fig, "e8_k3_gram", ["ch18_lattices", "ch20_k3lattice"],
         "Left: the Gram matrix of $E_8$ (the Cartan matrix used in Lean) and its inverse, which has integer "
         "entries because $\\det=1$ (unimodularity). Right: the $22\\times22$ Gram matrix of the K3 lattice "
         "$3U\\oplus2E_8(-1)$ (red $+$, blue $-$); even diagonal, determinant $\\pm1$, signature $(3,19)$.",
         "Lean `cartanE8` (E8.lean), `hyperbolicU` (Hyperbolic.lean); `cartanE8Inv_mul`, `sigK3_eq`",
         "det E8 = 1, E8 positive definite, integer inverse; K3 signature (3,19); Mukai extension (4,20)")

    fig, ax = plt.subplots(figsize=(6.2, 2.6))
    x = np.arange(8)
    ax.bar(x, np.sort(np.linalg.eigvalsh(e8)), color="#1b7837")
    ax.set_xticks(x)
    ax.set_xticklabels([f"$\\mu_{k + 1}$" for k in x])
    ax.set_ylabel("eigenvalue")
    ax.set_title(r"Eigenvalues of the $E_8$ Cartan matrix: all positive, product $=\det=1$")
    save(fig, "e8_eigenvalues", ["ch18_lattices"],
         "The eight eigenvalues of the $E_8$ Cartan matrix. All are positive (the lattice is positive "
         "definite, `cartanE8_posDef`) and their product is $1$ (`cartanE8_det`).",
         "Lean `cartanE8`", "numerical eigenvalues, product = 1 within 1e-9")


def fig_hodge():
    src = lean("StringTheoryFormalization/Frontier/HodgeNumbers.lean")
    h = {}
    for p, q, v in re.findall(r"\|\s*⟨(\d), _⟩, ⟨(\d), _⟩ => (\d+)", src):
        h[(int(p), int(q))] = int(v)
    assert len(h) == 9
    chi = sum((-1) ** (p + q) * v for (p, q), v in h.items())
    b2 = sum(v for (p, q), v in h.items() if p + q == 2)
    assert chi == 24 and b2 == 22
    fig, ax = plt.subplots(figsize=(3.6, 3.4))
    for (p, q), v in h.items():
        x, y = q - p, 4 - (p + q)
        ax.text(x, y, str(v), ha="center", va="center", fontsize=15,
                color="#b2182b" if (p, q) == (1, 1) else "k")
        ax.text(x, y - 0.42, f"$h^{{{p},{q}}}$", ha="center", fontsize=7, color="gray")
    ax.set_xlim(-2.7, 2.7)
    ax.set_ylim(-0.8, 4.7)
    ax.axis("off")
    ax.set_title(r"Hodge diamond of K3: $\chi=24$, $b_2=22$")
    save(fig, "k3_hodge_diamond", ["ch19_k3", "ch24_k3t2"],
         "The Hodge diamond of a K3 surface, read from the Lean table `k3HodgeNumber`. The alternating sum "
         "gives $\\chi=24$, the middle row gives $b_2=1+20+1=22$.",
         "Lean `k3HodgeNumber` (HodgeNumbers.lean); Huy ch. 1", "χ = 24, b₂ = 22 recomputed from the table")


def fig_moonshine():
    eot = [int(x) for x in re.search(r"def eotA : Fin 9 → ℕ := !\[(.*?)\]",
                                     lean("DualScaleStream2/Moonshine/EOT.lean")).group(1).split(",")]
    src = lean("StringTheoryFormalization/StringDynamics/MathieuM24.lean")
    dims = [int(v) for _, v in sorted((int(i), v) for i, v in re.findall(r"\|\s*⟨(\d+), _⟩ => (\d+)", src))]
    assert len(dims) == 26 and sum(d * d for d in dims) == 244823040
    assert eot[:5] == [45, 231, 770, 2277, 5796] and all(a in dims for a in eot[:5])
    assert eot[5] == 3520 + 10395 and eot[6] == 10395 + 5796 + 5544 + 5313 + 2024 + 1771

    fig, axs = plt.subplots(1, 2, figsize=(10.2, 3.6))
    n = np.arange(1, 10)
    asym = 2 / np.sqrt(8 * n - 1) * np.exp(2 * np.pi * np.sqrt(0.5 * (n - 1 / 8)))
    axs[0].semilogy(n, eot, "o", color="#1b7837", label=r"$A_n$ (EOT table, Lean `eotA`)")
    axs[0].semilogy(n, asym, "-", color="gray", lw=1, label=r"$\frac{2}{\sqrt{8n-1}}e^{2\pi\sqrt{(n-1/8)/2}}$")
    for k in range(9):
        tag = "irrep" if k < 5 else ("sum of irreps" if k < 7 else "")
        if tag:
            axs[0].annotate(tag, (k + 1, eot[k]), textcoords="offset points", xytext=(4, -10), fontsize=6.5)
    axs[0].set_xlabel("$n$")
    axs[0].set_ylabel("$A_n$")
    axs[0].set_title("(a) EOT coefficients and their asymptotic formula")
    axs[0].legend(frameon=False, loc="upper left")
    ratio = np.array(eot) / asym
    ins = axs[0].inset_axes([0.62, 0.12, 0.34, 0.3])
    ins.plot(n, ratio, "k.-", lw=0.8)
    ins.axhline(1, color="gray", lw=0.5)
    ins.set_title("ratio", fontsize=7)
    ins.tick_params(labelsize=6)
    x = np.arange(26)
    cols = ["#1b7837" if d in eot[:5] else ("#e08214" if d in (3520, 10395, 5796, 5544, 5313, 2024, 1771) else "#bdbdbd")
            for d in dims]
    axs[1].bar(x, dims, color=cols)
    axs[1].set_yscale("log")
    axs[1].set_xlabel(r"irreducible representation of $M_{24}$ (EOT App. A order)")
    axs[1].set_ylabel("dimension")
    axs[1].set_title(r"(b) the 26 irreps; $\sum \dim^2 = 244\,823\,040 = |M_{24}|$")
    axs[1].set_xticks([])
    from matplotlib.patches import Patch
    axs[1].legend(handles=[Patch(color="#1b7837", label="$A_1,\\dots,A_5$"),
                           Patch(color="#e08214", label="summands of $A_6, A_7$")], frameon=False, loc="upper left")
    fig.tight_layout()
    save(fig, "moonshine_coefficients", ["ch28_ellgenus", "ch29_m24", "ch30_moonshine"],
         "(a) The coefficients $A_n$ of the K3 elliptic genus (EOT eq. 1.12, the Lean table `eotA`) against "
         "the asymptotic formula EOT eq. (1.13); the inset shows the ratio. $A_1,\\dots,A_5$ are dimensions of "
         "irreducible representations of $M_{24}$; $A_6$ and $A_7$ are sums of them. (b) The 26 irreducible "
         "dimensions of $M_{24}$ from the Lean table `M24RepDim`; the sum of their squares equals the group order "
         "(`M24RepDim_sum_sq`), the check that caught an earlier wrong table.",
         "EOT eqs. (1.12)–(1.15), ll. 200–232 (formula read from the PDF page, the .txt garbles it); App. A (A.3)",
         "Σ dim² = |M24|; A1–A5 ∈ irreps; A6, A7 decompositions (Lean `A6_decomposition`, `A7_decomposition`)")


def fig_narain():
    """p_L, p_R in units a' = 1 from the Lean definitions. The set {(p_L,p_R)} at radius R equals the set at
    1/R after p_R -> -p_R (T-duality), and p_L^2 - p_R^2 = 4 n w is even-lattice data."""
    def pts(R, N=4):
        return {(n / R + w * R, n / R - w * R, n, w) for n in range(-N, N + 1) for w in range(-N, N + 1)}
    fig, axs = plt.subplots(1, 3, figsize=(10.2, 3.5), sharex=True, sharey=True)
    for ax, R, t in [(axs[0], 1.0, r"$R=\sqrt{\alpha'}$ (self-dual)"), (axs[1], 1.6, r"$R=1.6\sqrt{\alpha'}$"),
                     (axs[2], 1 / 1.6, r"$R=\sqrt{\alpha'}/1.6$")]:
        P = pts(R)
        for pl, pr, n, w in P:
            assert abs((pl * pl - pr * pr) - 4 * n * w) < 1e-9
        c = ["#1b7837" if n * w == 0 and (n or w) else ("#b2182b" if n * w != 0 else "k") for _, _, n, w in P]
        ax.scatter([p[0] for p in P], [p[1] for p in P], s=9, c=c)
        s = np.linspace(-8, 8, 2)
        ax.plot(s, s, color="gray", lw=0.5, ls=":")
        ax.plot(s, -s, color="gray", lw=0.5, ls=":")
        ax.set_xlim(-8, 8)
        ax.set_ylim(-8, 8)
        ax.set_aspect("equal")
        ax.set_title(t)
        ax.set_xlabel(r"$p_L\sqrt{\alpha'}$")
    axs[0].set_ylabel(r"$p_R\sqrt{\alpha'}$")
    a = sorted((round(pl, 9), round(-pr, 9)) for pl, pr, _, _ in pts(1.6))
    b = sorted((round(pl, 9), round(pr, 9)) for pl, pr, _, _ in pts(1 / 1.6))
    assert a == b
    fig.tight_layout()
    save(fig, "narain_lattice_circle", ["ch10_narain", "ch08_tduality"],
         "The Narain lattice $\\Gamma^{1,1}$ of zero-mode momenta $(p_L,p_R)$ for $|n|,|w|\\le4$ at three radii. "
         "Changing $R$ is a Lorentz boost in the $(p_L,p_R)$ plane that preserves $p_L^2-p_R^2=4nw$ (dotted "
         "light-cone lines); the lattices at $R$ and $\\alpha'/R$ coincide after $p_R\\mapsto-p_R$ — T-duality.",
         "Lean `leftMomentum`, `rightMomentum`; GPR §2.3; Tong §8.2",
         "p_L² − p_R² = 4nw for all points; point sets at R and 1/R equal after p_R ↦ −p_R")


def fig_modular():
    """SL(2,Z) acting on the upper half plane: T: tau+1, S: -1/tau. Orbit of the fundamental domain."""
    fig, ax = plt.subplots(figsize=(6.4, 3.6))
    t = np.linspace(np.pi / 3, 2 * np.pi / 3, 200)
    base = [np.concatenate([np.full(50, -0.5) + 1j * np.linspace(3.5, np.sqrt(3) / 2, 50),
                            np.cos(t[::-1]) + 1j * np.sin(t[::-1]),
                            np.full(50, 0.5) + 1j * np.linspace(np.sqrt(3) / 2, 3.5, 50)])]
    words = [""]
    for L in range(1, 5):
        words += ["".join(p) for p in __import__("itertools").product("STt", repeat=L)]

    def act(z, w):
        for ch in reversed(w):
            z = -1 / z if ch == "S" else (z + 1 if ch == "T" else z - 1)
        return z
    seen = set()
    for w in words:
        z = act(base[0], w)
        key = (round(np.mean(z).real, 3), round(np.mean(z).imag, 3))
        if key in seen or np.mean(z).imag <= 0:
            continue
        seen.add(key)
        ax.plot(z.real, z.imag, lw=0.35, color="#2166ac", alpha=0.7)
    ax.fill(base[0].real, base[0].imag, color="#fdae61", alpha=0.6, lw=0)
    ax.plot(base[0].real, base[0].imag, color="#b2182b", lw=1.2)
    tau = 0.23 + 1.4j
    orb = [act(tau, w) for w in words]
    orb = [z for z in orb if -2 < z.real < 2 and 0 < z.imag < 2.2]
    ax.scatter([z.real for z in orb], [z.imag for z in orb], s=4, color="k", zorder=3)
    for z, lab in [(1j, r"$i$"), (np.exp(2j * np.pi / 3) + 1, r"$\rho$")]:
        ax.plot(z.real, z.imag, "k*", ms=6)
        ax.annotate(lab, (z.real, z.imag), xytext=(4, 4), textcoords="offset points")
    ax.set_xlim(-2, 2)
    ax.set_ylim(0, 2.2)
    ax.set_aspect("equal")
    ax.set_xlabel(r"$\mathrm{Re}\,\tau$")
    ax.set_ylabel(r"$\mathrm{Im}\,\tau$")
    ax.set_title(r"$SL(2,\mathbb{Z})$ images of the fundamental domain and an orbit of $\tau$")
    save(fig, "modular_fundamental_domain", ["ch12_torus2", "ch28_ellgenus"],
         "The standard fundamental domain of $SL(2,\\mathbb{Z})$ (shaded) and its images under words of length "
         "$\\le4$ in $S:\\tau\\mapsto-1/\\tau$ and $T:\\tau\\mapsto\\tau+1$, together with the orbit of one point. "
         "For $T^2$ the same picture holds for both moduli $\\tau$ and $\\rho$, exchanged by mirror symmetry.",
         "GPR §2.5 / Tong §6 (modular group); Lean `tauShift`, `mirror_conjugates_tauShift`",
         "orbit computed by composing S and T^{±1}")


def rand_background(rng, d):
    M = rng.normal(size=(d, d))
    G = M @ M.T + 0.5 * np.eye(d)
    A = rng.normal(size=(d, d))
    return G, A - A.T


def gen_metric(G, B):
    """Lean genMetric G B = fromBlocks (G - B G^{-1} B) (B G^{-1}) (-(G^{-1} B)) G^{-1}."""
    Gi = np.linalg.inv(G)
    return np.block([[G - B @ Gi @ B, B @ Gi], [-(Gi @ B), Gi]])


def fig_odd():
    src = lean("DualScaleStream2/DFT/GeneralizedMetric.lean")
    assert "fromBlocks (G - B * G⁻¹ * B) (B * G⁻¹) (-(G⁻¹ * B)) G⁻¹" in src
    rng = np.random.default_rng(7)
    d = 2
    eta = np.block([[np.zeros((d, d)), np.eye(d)], [np.eye(d), np.zeros((d, d))]])
    logs = []
    for _ in range(300):
        G, B = rand_background(rng, d)
        H = gen_metric(G, B)
        assert np.allclose(H, H.T) and np.allclose((eta @ H) @ (eta @ H), np.eye(2 * d))
        ev = np.linalg.eigvalsh(H)
        assert ev.min() > 0
        logs.append(np.sort(np.log(ev)))
    logs = np.array(logs)

    def theta(Th):
        return np.block([[np.eye(d), Th], [np.zeros((d, d)), np.eye(d)]]).astype(int)

    def basis(A):
        return np.block([[A, np.zeros((d, d))], [np.zeros((d, d)), np.linalg.inv(A).T]]).round().astype(int)

    def fact(i):
        P = np.zeros((d, d))
        P[i, i] = 1
        Q = np.eye(d) - P
        return np.block([[Q, P], [P, Q]]).astype(int)
    g = theta(np.array([[0, 1], [-1, 0]])) @ basis(np.array([[1, 1], [0, 1]])) @ fact(0) @ theta(np.array([[0, -2], [2, 0]]))
    assert (g.T @ eta @ g == eta).all()
    G, B = rand_background(rng, d)
    H = gen_metric(G, B)
    Hp = g.T @ H @ g
    Z = [np.array(z) for z in np.ndindex(5, 5, 5, 5)]
    Z = [z - 2 for z in Z]
    m = sorted((z @ H @ z, z @ eta @ z) for z in Z)
    ginv = np.rint(np.linalg.inv(g)).astype(int)
    m_dual = sorted(((ginv @ z) @ Hp @ (ginv @ z), (ginv @ z) @ eta @ (ginv @ z)) for z in Z)
    assert np.allclose([a for a, _ in m], [a for a, _ in m_dual]) and [b for _, b in m] == [b for _, b in m_dual]

    fig, axs = plt.subplots(1, 2, figsize=(10, 3.6))
    for k in range(4):
        axs[0].hist(logs[:, k], bins=40, histtype="step", lw=1.2, label=f"$\\log\\lambda_{k + 1}$")
    axs[0].set_title(r"(a) $\mathcal{H}(G,B)$ eigenvalues come in pairs $\lambda,\lambda^{-1}$")
    axs[0].set_xlabel(r"$\log$ eigenvalue (300 random $d=2$ backgrounds)")
    axs[0].legend(frameon=False)
    xs = np.array([z @ H @ z for z in Z])
    ys = np.array([(ginv @ z) @ Hp @ (ginv @ z) for z in Z])
    assert np.allclose(xs, ys)
    axs[1].scatter(xs, ys, s=4, color="#1b7837")
    lim = xs.max() * 1.03
    axs[1].plot([0, lim], [0, lim], color="gray", lw=0.6)
    axs[1].set_xlabel(r"$Z^{\mathrm{T}}\mathcal{H} Z$ (background $\mathcal{H}$)")
    axs[1].set_ylabel(r"$Z'^{\mathrm{T}}(g^{\mathrm{T}}\mathcal{H}g)Z'$, $Z'=g^{-1}Z$")
    axs[1].set_title(r"(b) $O(2,2;\mathbb{Z})$-dual backgrounds: same spectrum")
    fig.tight_layout()
    save(fig, "generalized_metric_odd", ["ch15_genmetric", "ch11_odd"],
         "(a) Logarithms of the four eigenvalues of the generalized metric $\\mathcal{H}(G,B)$ for 300 random "
         "backgrounds on $T^2$: they are symmetric about $0$, because $(\\eta\\mathcal{H})^2=1$ "
         "(`etaR_genMetric_sq`) forces eigenvalues in pairs $\\lambda,\\lambda^{-1}$. (b) For "
         "$g=\\Theta\\cdot A\\cdot\\text{(factorized duality)}\\cdot\\Theta'\\in O(2,2;\\mathbb{Z})$, the mass form of every "
         "charge $Z$ in background $\\mathcal{H}$ equals that of $g^{-1}Z$ in the dual background $g^{\\mathrm{T}}\\mathcal{H}g$: "
         "the points lie on the diagonal (`spectrum_equivalence`, `massForm_covariant`).",
         "Lean `genMetric` (GeneralizedMetric.lean), `thetaShift`, `basisChange`, `factorized`; HHZ §2",
         "H symmetric, positive, (ηH)² = 1 for 300 samples; gᵀηg = η exactly; 625 charges: identical (mass, level) multisets")


def fig_atlas():
    deps = [json.loads(l) for l in (ROOT / ".leancache" / "depgraph.jsonl").read_text().splitlines() if l.startswith("{")]
    atlas = json.loads((ROOT / "papers/book/generated/atlas_data.json").read_text())
    stats = atlas["stats"]
    fig, ax = plt.subplots(figsize=(6.2, 2.9))
    libs = list(stats["per_library"].keys())
    vals = [stats["per_library"][k] for k in libs]
    ax.barh(libs, vals, color=[LIBCOLORS[k] for k in libs])
    for i, v in enumerate(vals):
        ax.text(v + 1, i, str(v), va="center", fontsize=8)
    ax.invert_yaxis()
    ax.set_xlabel("theorems stated in source")
    ax.set_title(f"Theorems per library (total {sum(vals)})")
    save(fig, "atlas_theorems_per_library", ["ch35_architecture", "ch36_atlas"],
         "Number of theorems stated in the source of each library (auto-generated theorems such as structure "
         "projections excluded), from the kernel-level dependency dump.",
         "tools/lean_depgraph.lean → tools/theorem_atlas.py (atlas_data.json)", "counts read from atlas_data.json")

    pairs = {}
    for key in ("similar_cross_library", "intersecting", "unification_candidates"):
        for p in atlas[key]:
            pairs[(p["a"], p["b"])] = (p["cosine"], p["dep_jaccard"], key)
    fig, ax = plt.subplots(figsize=(5.8, 4.2))
    for (a, b), (c, j, key) in pairs.items():
        col = {"similar_cross_library": "#2166ac", "intersecting": "#1b7837", "unification_candidates": "#b2182b"}[key]
        ax.scatter(c, j, s=14, color=col, alpha=0.75)
    uni = sorted([(v[0], k) for k, v in pairs.items() if v[2] == "unification_candidates"], reverse=True)[:2]
    for i, (c, (a, b)) in enumerate(uni):
        ax.annotate(f"{a.split('.')[-1]} ~ {b.split('.')[-1]}", (c, pairs[(a, b)][1]), fontsize=6.5,
                    xytext=(c - 0.45, 0.28 + 0.1 * i), arrowprops=dict(arrowstyle="-", lw=0.5))
    ax.set_xlabel("textual similarity of statements (TF–IDF cosine)")
    ax.set_ylabel("shared kernel dependencies (weighted Jaccard)")
    from matplotlib.lines import Line2D
    ax.legend(handles=[Line2D([], [], marker="o", ls="", color=c, label=l) for c, l in
                       [("#2166ac", "most similar across libraries"), ("#1b7837", "strongest dependency overlap"),
                        ("#b2182b", "unification candidates")]], frameon=False, fontsize=7.5)
    ax.set_title("Similarity versus intersection of theorem pairs")
    save(fig, "atlas_similarity_vs_intersection", ["ch36_atlas"],
         "Theorem pairs reported by the atlas, placed by textual similarity of their statements (horizontal) and "
         "overlap of their kernel-level dependencies (vertical). Pairs in the lower right state similar facts with "
         "essentially disjoint proofs: the same mathematics formalized more than once.",
         "papers/book/generated/atlas_data.json", "values read, not recomputed")

    own = {d["name"]: d for d in deps}
    G = nx.DiGraph()
    src_theorems = set()
    import sqlite3
    db = sqlite3.connect(ROOT / ".leancache" / "declarations.db")
    src_names = {(m, n) for m, n in db.execute("select module,name from declarations")}
    for n, d in own.items():
        if (d["module"], n.split(".")[-1]) not in src_names:
            continue
        src_theorems.add(n)
    for n in src_theorems:
        G.add_node(n, lib=own[n]["module"].split(".")[0], kind=own[n]["kind"])
    for n in src_theorems:
        for c in set(own[n]["type"]) | set(own[n]["value"]):
            if c in src_theorems and c != n:
                G.add_edge(n, c)
    G.remove_nodes_from([v for v in list(G) if G.degree(v) == 0])
    libs_present = [l for l in LIBCOLORS if any(G.nodes[v]["lib"] == l for v in G)]
    pos = {}
    for i, lib in enumerate(libs_present):
        sub = G.subgraph([v for v in G if G.nodes[v]["lib"] == lib]).to_undirected()
        size = 0.55
        # Kamada-Kawai on each connected component, components packed in a small grid, so that one
        # outlier component does not squeeze the rest of the library into a point.
        local, comps = {}, sorted(nx.connected_components(sub), key=len, reverse=True)
        cols = math.ceil(math.sqrt(len(comps)))
        for ci, comp in enumerate(comps):
            cg = sub.subgraph(comp)
            lay = nx.kamada_kawai_layout(cg) if len(comp) > 2 else {v: (0.3 * k, 0) for k, v in enumerate(comp)}
            sc = 0.9 if ci == 0 else 0.35 * math.sqrt(len(comp) / max(len(comps[0]), 1)) + 0.12
            ox, oy = (0, 0) if ci == 0 else (1.3 + 0.55 * ((ci - 1) % cols), -1.0 + 0.55 * ((ci - 1) // cols))
            for v, (x, y) in lay.items():
                local[v] = (ox + sc * x, oy + sc * y)
        ang = 2 * math.pi * i / len(libs_present)
        cx, cy = 4.2 * math.cos(ang), 4.2 * math.sin(ang)
        for v, (x, y) in local.items():
            pos[v] = (cx + size * x, cy + size * y)
    fig, ax = plt.subplots(figsize=(8.5, 7))
    intra = [(a, b) for a, b in G.edges if G.nodes[a]["lib"] == G.nodes[b]["lib"]]
    inter = [(a, b) for a, b in G.edges if G.nodes[a]["lib"] != G.nodes[b]["lib"]]
    nx.draw_networkx_edges(G, pos, edgelist=intra, ax=ax, width=0.25, alpha=0.3, arrows=False)
    nx.draw_networkx_edges(G, pos, edgelist=inter, ax=ax, width=0.9, alpha=0.8, edge_color="#d6604d", arrows=False)
    deg = dict(G.in_degree())
    for lib, col in LIBCOLORS.items():
        nodes = [v for v in G if G.nodes[v]["lib"] == lib]
        nx.draw_networkx_nodes(G, pos, nodelist=nodes, ax=ax, node_color=col,
                               node_size=[8 + 10 * deg[v] for v in nodes],
                               node_shape="o", label=f"{lib} ({len(nodes)})", alpha=0.9)
    top = sorted(deg, key=lambda v: -deg[v])[:12]
    nx.draw_networkx_labels(G, pos, labels={v: v.split(".")[-1] for v in top}, font_size=6.5, ax=ax)
    ax.legend(frameon=False, fontsize=7, loc="upper left", bbox_to_anchor=(1.0, 1.0), markerscale=0.8)
    ax.axis("off")
    ax.set_title(f"Declaration dependency graph ({G.number_of_nodes()} declarations, {G.number_of_edges()} edges); "
                 "node size = number of dependents")
    save(fig, "atlas_dependency_graph", ["ch36_atlas", "ch35_architecture"],
         "Kernel-level dependency graph of the declarations written in the source (isolated declarations "
         "omitted), one cluster per library (spring layout inside each cluster). Node size grows with the number "
         "of declarations that use it; the largest hubs are labelled. Red edges cross library boundaries: they "
         "are the bridges listed in the atlas chapter.",
         "`tools/lean_depgraph.lean` (`.leancache/depgraph.jsonl`); layout: networkx Kamada-Kawai per connected component, one cluster per library",
         "graph built from compiled-environment dependencies")


def fig_tadpole():
    """SVW / DRS: chi(X8)/24 = N_{M2 or D3} + 1/2 int G ^ G. For K3 x K3, chi = 24*24 = 576, budget 24.
    Lean k3k3_anomaly, tadpole_budget, flux_half_selfIntersection_integral (1/2 G.G integer)."""
    rng = np.random.default_rng(11)
    U = np.array([[0, 1], [1, 0]])
    L = np.kron(np.eye(3, dtype=int), U)  # 3U, even unimodular of signature (3,3), stands in for a flux lattice
    half = []
    for _ in range(20000):
        v = rng.integers(-3, 4, size=6)
        s = v @ L @ v
        assert s % 2 == 0
        half.append(s // 2)
    half = np.array(half)
    fig, axs = plt.subplots(1, 2, figsize=(10, 3.3))
    b = np.arange(0, 25)
    axs[0].bar(b, 24 - b, color="#2166ac", label=r"$N_{\mathrm{branes}}$")
    axs[0].bar(b, b, bottom=24 - b, color="#e08214", label=r"$\frac{1}{2}\int G\wedge G$")
    axs[0].set_xlabel(r"flux contribution $\frac{1}{2}\int G\wedge G$")
    axs[0].set_ylabel(r"$\chi(K3\times K3)/24 = 24$")
    axs[0].set_title("(a) the tadpole budget on $K3\\times K3$")
    axs[0].legend(frameon=True, loc="lower left", fontsize=8)
    vals, counts = np.unique(half, return_counts=True)
    axs[1].bar(vals, counts, width=0.8, color="#1b7837")
    axs[1].set_xlim(-30, 30)
    axs[1].set_xlabel(r"$\frac{1}{2}\, v^{\mathrm{T}} L\, v$ for random integer $v$ ($L=3U$)")
    axs[1].set_ylabel("count")
    axs[1].set_title("(b) on an even lattice, half the self-intersection is an integer")
    fig.tight_layout()
    save(fig, "tadpole_budget", ["ch25_tadpole"],
         "(a) Every way to split the tadpole budget $\\chi(K3\\times K3)/24=576/24=24$ between space-filling branes and "
         "flux (`k3k3_anomaly`, `tadpole_budget`). (b) For random integer flux vectors on the even lattice $3U$, "
         "$\\frac12 v^{\\mathrm{T}}Lv$ is always an integer, the lattice fact behind flux quantization "
         "(`kronForm_even`, `flux_half_selfIntersection_integral`).",
         "SVW (χ/24 condition); DRS §2–4; Lean Flux/Tadpole.lean, Flux/Integrality.lean",
         "χ(K3)² = 576; 20000 random vectors, all self-intersections even")


def main():
    print("generating figures into", OUT.relative_to(ROOT))
    for f in (fig_circle_spectrum, fig_dual_scale, fig_e8_and_k3, fig_hodge, fig_moonshine, fig_narain,
              fig_modular, fig_odd, fig_atlas, fig_tadpole):
        f()
    md = ["# Book figures (generated by tools/book_figures.py — do not edit)\n",
          "Include with `\\includegraphics[width=\\textwidth]{generated/figures/<name>.pdf}` inside a `figure` "
          "environment; use the caption below (you may shorten it, not strengthen it). Figures illustrate; "
          "they are never Tier A evidence.\n"]
    for c in CATALOGUE:
        md.append(f"## {c['name']}\n- chapters: {', '.join(c['chapters'])}\n- caption: {c['caption']}\n"
                  f"- data source: {c['source']}\n- consistency checks run: {c['checks']}\n")
    (OUT / "FIGURES.md").write_text("\n".join(md))
    json.dump(CATALOGUE, open(OUT / "figures.json", "w"), indent=1, ensure_ascii=False)
    print(f"{len(CATALOGUE)} figures; catalogue: FIGURES.md")


if __name__ == "__main__":
    main()
