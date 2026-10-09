# P1-B — balanced-pair to overlap realization bridge

**Status:** completed local realization interface plus one open global coverage bridge. *Update 2026-09-13:* `docs/overlap-finiteness-and-coincidence-density-2026-09-13.md` proves the seed-patch overlap graph finite (Theorem 2.1 / manuscript Theorem 4.22), proves the path-valued realization, cut, and coincidence dictionary (Lemmas 1.1, 3.1, 3.2 and Theorem 4.1), and supplies the exact finite census. The remaining obligation is not a local dictionary lemma: it is to transfer productivity from the finite swapped-patch graph to every overlap class in a complete literature overlap algorithm for one fixed translation. This note does **not** prove that coverage transfer, G1b-2, overlap productivity, or PDS. See `docs/seed-patch-to-literature-overlap-audit-2026-09-13.md`.

## 1. Why this route is being tested

The affine-ancestry work explains the last retained finite sidewise-abelian collision by a symbolic pump, but its remaining uniform theorem still has two clauses:

1. repeated affine states must be removable without leaving the relevant realizability/context class;
2. loop-free realizable traces must form a uniformly finite family under a fixed discrepancy bound.

The geometric overlap formulation is useful because **realized** tile overlaps are the native objects in which finite-local-complexity/Meyer arguments apply. The literature connection must nevertheless be kept separate from the repository's formal balanced-pair graph.

Literature targets to pin before any ledger promotion:

- Sirvent--Solomyak, *Pure Discrete Spectrum for One-dimensional Substitution Systems of Pisot Type* (2002), for the one-dimensional relation between balanced-pair and overlap algorithms;
- Akiyama--Lee, *Algorithm for determining pure pointedness of self-affine tilings* (2011), for overlap coincidence and pure point spectrum in the stated self-affine/Meyer setting;
- Lee--Solomyak, *Pisot family self-affine tilings, discrete spectrum, and the Meyer property* (2012), for the precise hypotheses under which the Pisot-family condition gives the Meyer property;
- Minervino--Thuswaldner, *The geometry of non-unit Pisot substitutions* (2014), for the non-unimodular representation-space setting.

These are citation targets, not imported theorem nodes in this note.

## 2. Exact geometric coordinate and rational interval layer

Let `M` be the incidence matrix and `beta` its irreducible cubic Pisot Perron root. A positive left Perron eigenvector gives tile lengths

```text
ell^T M = beta ell^T.
```

The canonical Mojo kernel represents every length and displacement exactly in

```text
Z[beta] = {a0 + a1 beta + a2 beta^2 : ai in Z}
```

modulo the monic characteristic polynomial.

### 2.1 Rational interval arithmetic is the first enclosure layer

The Perron root is first enclosed in an exact rational interval (endpoints are the unbounded `finite_exact` rationals of `kernel/finite_exact/`)

```text
beta in [p/q, r/s].
```

The box is obtained from an integer sign-change bracket and a bounded number of exact rational bisections, computed once per substitution (`PerronEnclosure`). Every endpoint operation is normalized; there is no magnitude bound, so refinement depth is limited by cost only. A rejected endpoint or interval (an invalid enclosure) fails closed rather than widening silently.

For any cubic-field element

```text
x = a0 + a1 beta + a2 beta^2,
```

the kernel evaluates the **natural rational interval extension** of

```text
a0 + a1 X + a2 X^2
```

over the current beta enclosure. This produces a certified rational interval `I(x)` satisfying

```text
x(beta) in I(x).
```

The sign rule is deliberately strict:

```text
I(x) entirely > 0  =>  x(beta) > 0
I(x) entirely < 0  =>  x(beta) < 0
0 in I(x)           =>  unknown
```

An interval containing zero is never interpreted as equality, failure, or a negative result. This is the key theorem-facing discipline: interval arithmetic supplies positive enclosure certificates only.

### 2.2 Exact algebraic fallback

When the rational enclosure straddles zero, or the enclosure is rejected as invalid, the kernel delegates to the independent specialized Sturm--Tarski signed-remainder query. That fallback uses checked integer arithmetic and no rational refinement.

Thus the order-decision architecture is

```text
exact rational interval enclosure
        |
        +-- strict sign certified --> accept sign
        |
        +-- zero contained / rejected --> exact Sturm--Tarski fallback
```

The Codex near-Perron counter-calibration

```text
-152138 + 67035 beta
```

is intentionally retained: a modest rational interval remains ambiguous, while the algebraic fallback resolves the sign exactly. This prevents the interval layer from being mistaken for a completeness oracle.

No floating point, inverse incidence matrix, Euclidean stable-space lattice, or unimodularity assumption is used. Rational arithmetic is unbounded; the integer-width Sturm--Tarski oracle and the cubic-field arithmetic remain overflow-checked and fail closed, making a finite run inconclusive rather than wrong.

The current PIP-validation boundary is deliberately restricted to an audited finite domain: non-erasing three-letter substitutions with every image length at most `MAX_CERTIFIED_COLUMN_SUM = 6` (raised from three on 2026-10-01 for the total-length corpus; the overflow bound is stated in `kernel/psc/perron_field3.mojo`). This finite precondition is checked before calling the PIP predicate and the checked integer cubic-field arithmetic. Larger incidence matrices are rejected as unsupported rather than risk overflow in that cubic-field layer and false classification.

For an oriented overlap state

```text
(i, j, t),
```

the top tile is `[0, ell_i]` and the bottom tile is `[t, t + ell_j]`. It is an interior overlap exactly when

```text
t < ell_i,
t + ell_j > 0.
```

Graph construction decides these two inequalities with the exact Sturm--Tarski oracle directly: only the sign is needed, both paths are exact, and the integer-width oracle is cheaper than interval arithmetic over unbounded rationals. The rational-interval-first path above is used where interval certification is itself the reported result, in the margin audit of `psc.overlap_interval_audit`: if the box certifies the sign, the box is finite evidence; if not, the exact fallback decides the comparison and the margin is counted as fallback, not certified.

If the selected top and bottom children have geometric prefix translations `p` and `q`, inflation sends the displacement to

```text
t' = beta t + q - p.
```

A tile coincidence is exactly

```text
i = j,
t = 0.
```

All of these predicates are exact in the finite executable kernel.

## 3. Repository seed-patch overlap graph

The first diagnostic starts from the same unordered letter pairs `a < b` used by the repository BPA, but geometrizes the two seed words:

```text
ab
ba
```

with their left boundaries aligned. Every pair of seed tiles with nonempty interior intersection produces an oriented overlap state. The graph then repeatedly applies the exact inflation rule above and retains only child pairs that still overlap.

Coincidence states are terminal for the same finite productivity question used by `B_sigma`: whether every reachable state can reach a tile coincidence.

The construction has a state cap. A capped run is inconclusive, and productivity queries on a capped graph fail closed.

### Scope warning

This seed-patch graph is **not yet the literature overlap graph**. The literature algorithm ranges over the appropriate realized overlap classes/return translations of the tiling. The current graph is a deliberately auditable subset generated from the repository seed patches. Agreement of its productivity verdict with the BPA on a finite corpus is evidence for the dictionary, not proof of it.

## 4. The bridge is path-valued, not vertex-valued

A reduced balanced pair `(u,v)` spans an interval between two simultaneous boundaries of two aligned patches. In general that interval contains several top and bottom tiles. Therefore it should not be identified with one overlap vertex.

The appropriate candidate map is

```text
realizable reduced balanced pair
    -> finite ordered chain of tile-overlap states
```

covering the common geometric interval between its two simultaneous boundaries.

This corrects an overstrong possible interpretation of the cross-program audit: the desired correspondence is not a graph isomorphism between BPA vertices and overlap vertices.

The local commutative diagram is now proved:

1. **realization:** each occurring reduced balanced pair determines a finite ordered overlap chain;
2. **inflation compatibility:** substitution of the pair and refinement of its overlap chain have the same children;
3. **cut compatibility:** common Parikh-prefix returns are exactly simultaneous-boundary cuts;
4. **coincidence compatibility:** a letter coincidence is exactly a common full tile;
5. **finite seed type:** all overlap types occurring in inflated swapped patches belong to an explicitly bounded finite set.

These facts are Lemmas 1.1, 3.1, 3.2 and Theorems 2.1, 4.1 of the overlap note. They do not make the finite seed-patch graph the complete overlap graph of Sirvent--Solomyak. The exact remaining theorem target is the **coverage transfer** stated in `docs/seed-patch-to-literature-overlap-audit-2026-09-13.md`: for one prefix translation `x(W)`, productivity of the relevant seed-patch vertices must force productivity of every class in `G_O(T,x(W))`. Once that is proved, Sirvent--Solomyak Theorem 4.1(b) gives PDS. A uniform bound on chains between simultaneous boundaries is a separate, stronger G1b-2 target.

## 5. Relation to the affine pump program

The affine state

```text
(top_current_letter, bottom_current_letter, x_t)
```

records ordered substitution ancestry and exact prefix displacement information. A repeated affine state is a symbolic loop candidate. The overlap chain supplies the missing geometric question: does deleting that ancestry loop preserve the same realizable overlap/context class?

Thus the two approaches are complementary:

```text
affine trace       -> exact symbolic loop candidate
rational intervals -> certified geometric enclosures
overlap geometry   -> realizability / finite geometric type
```

Neither implication is assumed. A future proof should make the compatibility explicit rather than replacing one representation by the other by analogy.

## 6. Immediate executable acceptance criteria

For a controlled PIP specimen, the Mojo diagnostic must:

- construct positive Perron tile lengths exactly;
- construct an exact rational interval enclosing the Perron root;
- implement natural rational interval extension for integer polynomials;
- certify a sign only when the complete rational enclosure excludes zero;
- retain a near-boundary regression where interval arithmetic is intentionally inconclusive and exact algebraic fallback is required;
- fail closed on a rejected enclosure and on interval division across zero;
- enumerate seed-patch overlaps without floating point;
- fail closed on malformed/non-PIP input;
- reject substitutions outside the audited image-length-at-most-three input domain before invoking the PIP validator and the checked cubic-field arithmetic;
- terminate below the state cap or report inconclusive;
- reject productivity queries on capped partial graphs;
- retain exact coincidence reachability;
- compare its finite productivity verdict with the repository BPA without asserting equivalence.

Only after these regressions are pinned should the same comparison be run over the full 4,554-specimen finite corpus.

The canonical Mojo run for the determinant-two calibration produces exactly

```text
initial seed-overlap states: 9
reachable seed-overlap states: 628
nonproductive reachable states: 0
```

These three finite counts are pinned in regression coverage. They apply only to the stated seed-patch construction for this specimen; they do not identify it with the complete realized-overlap graph or establish any uniform bound.

## 7. Theorem boundary

A clean finite corpus does not prove the seed-to-literature coverage transfer, uniform relative density of simultaneous boundaries, bounded overlap-chain length, G1b-2, G1, general overlap productivity, or PDS.

The local realization interface is complete. The next mathematical question is now singular and falsifiable: can a nonproductive class in the complete graph `G_O(T,x(W))` exist while every overlap generated by the finite swapped patch is productive? Either a proof excludes this, or an exact realized class supplies a countermodel to the proposed transfer. The finite Mojo graph remains a fail-closed diagnostic; it is not a certificate for the complete literature graph.
