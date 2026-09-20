# Projective completion and escape

**Status:** design note, dated 2026-09-20. It states where "escape to infinity"
meets the rank-2 algebra, which projective completion carries the dynamics and
which does not, and what a projective `OUT` certificate would cost. It proves
nothing: the lift below is standard, no theorem obligation is discharged, and
no certificate in this repository changes until Phase 1 implements one.

## 0. What escape is in this repository today

`src/julia_orbit.mojo` decides escape by an affine test:

```text
N(z) > max(4, N(c)),        N(x, y) = x^2 + y^2
```

a quadrance against a rational bound. That is rank-2 legal and it is exact.
Two things about it are worth saying plainly.

- **Infinity is not an object anywhere in this tree.** "Escape to infinity" is
  a name inherited from the analytic picture; the finite content is that a
  quadrance left a bound, plus a classical fact that it never comes back.
- **That classical fact is imported, not proved here.** The usual argument
  runs through `|z^2 + c| >= |z|^2 - |c|` and the Cauchy-Schwarz bound on
  `Re(conj(z)^2 c)`, both natural in `|.|` and awkward in quadrance: each step
  needs squaring back into polynomial form before it is a statement this layer
  can make. Nothing in this repository carries that derivation. Phase 1's
  completeness proof is where it would have to land, in one form or another.

The projective vocabulary is already present in the estate, but only in the
negative: `docs/no-points-invariant.md` forbids treating an *ideal point* as
directly available, and the vendored `finite_exact` boxes assert in comments
that no ideal point is introduced. The word is known and banned.

## 1. Two completions, and only one of them has the dynamics

This is the load-bearing section. Both completions below are projective
geometry over the same rank-2 coordinate records, and confusing them would put
the dynamics on the wrong space.

| | completion | what is added | does `z -> z^2 + c` extend? |
| --- | --- | --- | --- |
| the plane as a **one-dimensional complex** object | `P^1(C)` | one ideal element, `[1 : 0]` | **yes**, as a degree-2 morphism |
| the plane as a **two-dimensional rank-2** object | `P^2` and its complexification | an ideal *line*, containing the circular points `I = [1 : i : 0]` and `J = [1 : -i : 0]` | **no** |

The second row is where the quadrance form degenerates: `Q(x, y) = x^2 + y^2`
vanishes on the null directions `y = ±ix`, and those directions are exactly
`I` and `J`. That is the classical device by which every circle-like locus
passes through two fixed ideal elements, and it is therefore the completion to
reach for if the higher incidence layer that
`docs/rank2-coordinate-substrate.md` defers is ever built. It is **not** the
completion escape lives in.

The first row is the dynamical one. A quadratic map of the plane is not a
projective transformation of `P^2`; it is a morphism of `P^1(C)`. Any note,
tag, or module that mixes the two rows is wrong regardless of what it proves.

## 2. The homogeneous lift

Write a pair of rank-2 coordinate records `[Z : W]`, modulo scaling by a
nonzero record. Then

```text
F([Z : W]) = [Z^2 + c W^2 : W^2]
```

is a polynomial map of records: no division, no limit, no analytic operation,
and nothing that the rank-2 rule forbids.

Three facts follow by algebra alone, and each replaces something that is
currently a limit or an inequality.

1. **Infinity is a fixed point of the algebra.** `∞ = [1 : 0]` and
   `F([1 : 0]) = [1 : 0]`. It is fixed because the coordinates say so, not
   because a sequence tends to it.
2. **The lift has no base point.** `Z^2 + c W^2` and `W^2` vanish together
   only at `Z = W = 0`, which is not a projective element. So `F` is a
   morphism of degree 2, everywhere defined, with no exceptional locus to
   special-case.
3. **The fiber over infinity is totally invariant, with multiplicity two.**
   `F^{-1}(∞)` is `W = 0`, doubled. That multiplicity is the reason the basin
   of infinity carries a degree-2 branched cover, and it is the algebraic
   source of the angle doubling `t -> 2t` that this repository already uses as
   symbolic ray-address data.

## 3. The chart at infinity

Put `u = W / Z`. In that chart the same map reads

```text
u -> u^2 / (1 + c u^2)
```

with `u = 0` fixed and its derivative zero: infinity is **superattracting of
order two**, the same kind of object as the attracting cycles an `IN`
certificate already handles.

The chart swap is not new machinery. It is inverse-by-conjugate-over-quadrance,
which the parameter-plane program already implements in
`src/complex_inverse.mojo` for Krawczyk witnesses, with a caller contract that
the quadrance is nonzero. That contract is precisely the chart's domain, and
over a box it strengthens to *the quadrance interval excludes zero*, which is a
three-valued test this repository already has. A box straddling the origin is
not in this chart, and the answer there is `UNKNOWN`, fail-closed in the
refuse-to-proceed direction.

## 4. What `OUT` becomes

| | today | under the lift |
| --- | --- | --- |
| `OUT` | quadrance exceeds a rational bound | the orbit enters a box around `u = 0` on which `F` is a strict contraction |
| `IN` | attracting cycle, then basin pullback | unchanged |
| witness | an inequality | a Krawczyk inclusion, the same shape as `IN` |

Two attractors, one certificate kind. The affine inequality does not go away:
by section 3.2 of `docs/rational-interval-arithmetic-spec.md` it is exactly
the cheap filter that runs before the exact test, and it keeps that job. What
changes is that it stops being the *reason* a box is `OUT` and becomes the
reason the expensive check is worth running.

## 5. What that is worth, beyond tidiness

- **The soundness path shortens.** A contraction certificate at `[1 : 0]` is
  polynomial and interval-checkable end to end, where the escape inequality of
  section 0 is imported. Whether the inequality can be derived cleanly in this
  layer is a separate question; the point is that the projective route does
  not need it.
- **A theorem tag gets a binding site.** Phase 3 needs dynamical rays, and the
  Böttcher coordinate is analytic and must stay an import. The `u`-chart
  neighbourhood of `[1 : 0]` is where that tag attaches: a named chart with a
  stated domain, rather than "the plane". The combinatorial half of ray data,
  doubling on `Q/Z`, is finite and already this repository's own.
- **The basin of infinity acquires a coordinate.** It is where external rays
  live, and section 2's multiplicity-two fiber is why they are indexed by
  angles at all.

## 6. What adopting it costs here

- **A terminology declaration.** `docs/no-points-invariant.md` forbids the
  word *ideal point* and `tools/audit_no_points.py` enforces it in the
  parameter-plane program. A homogeneous record pair is not an ideal point
  smuggled in: it is rank-2 polynomial data modulo scaling, and every
  operation above is polynomial. But the claim has to be declared and its
  leaks named, not assumed. `docs/terminology-registry.md` now carries that
  declaration.
- **A home in the kernels repository.** Both planes escape: the parameter
  plane iterates a critical orbit that either stays bounded or does not. By
  the standing obligation in `ROADMAP.md`, a layer two consumers need is
  lifted to `larsbx/finite-math-kernels` and vendored twice, not written
  twice.
- **One sentence that cannot be skipped.** Whichever module is written must
  say that it works in `P^1(C)`, the completion of section 1's first row. The
  circular points belong to the other row and to a layer this program has not
  built.

## 7. What this note does not claim

It does not prove the escape bound, does not establish local connectivity of
anything, and does not discharge any block of `docs/J1_proof_definition.md`.
The lift is textbook; what is new here is only the decision about which
completion this program means, and the observation that the `OUT` certificate
and the `IN` certificate can have one shape instead of two. No code in this
repository changes on account of this note.
