# Lean oracle layer

The oracle independently replays the committed eight-dimensional model over
(mathbb F_3) from an explicit multiplication tensor.

## Executed checks

The CI job builds the Lean project and runs `lake exe oracle-selfcheck`.
The executable checks:

1. trial-division primality of 3;
2. tensor dimensions and the two-sided basis identity;
3. alternativity through antisymmetry of the trilinear associator on every
   basis triple;
4. norm composition through all diagonal and polarized cross coefficients of
   (L_x^T L_x=N(x)I), with (N(x)=sum_i x_i^2);
5. the nonflat pentagon witness ((e_0,e_1,e_2,e_4)), whose third and fifth
   edges are (e_7) and (-e_7);
6. the closed total pentagon boundary.

Python independently reconstructs the tensor by three scalar
Cayley–Dickson doublings. Its canonical SHA-256 digest is
`747ace028b8a34fb95f5b7c39e99f3004e39ad4fb3401a7caa3b6e3a4e2e2f4b`,
computed from the tensor read directly from the Lean `productIndex` and
`productCoeff` literal arrays. `verify.yml` executes this independent replay.
The reader refuses unsupported syntax, malformed dimensions, and out-of-range
entries; it does not normalize mismatches away.

`lake exe export-f3` emits canonical JSON from the evaluated
`OctonionF3.table` through `provenanceSerialization`. The `lean-oracle` workflow
compares those exact bytes (plus the output newline) with Python's canonical
serialization before accepting the digest. There is no independent Lean digest
literal. Discovered negative regressions change one index, one coefficient,
and one exported tensor entry and require provenance verification to fail.

## Self-check suite (`NoveltyLab/SelfCheck.lean`)

`lake exe oracle-selfcheck` prints every named check, and CI runs it after the
build. The suite contains:

- the scalar sanity case;
- the 𝔽₃ certificate above (`OctonionF3.selfCheck`), plus a check that each of its edges is the
  difference of the two parenthesizations it joins;
- the generated 𝔽₅ fixture (`NoveltyLab/Fixture.lean`, written by
  `experiments/n2/lean_fixture.py` from `experiments/n2/pentagon.py`).

The fixture holds a second 8×8×8 Cayley–Dickson tensor and three quadruples.
Two of them have all five edges nonzero. For each case the suite requires:

- the boundary closes;
- the edges equal the values Python computed;
- each edge equals its vertex difference;
- negating any nonzero edge breaks the boundary;
- in discriminating cases, moving the outer factor of [a,b,c]d or a[b,c,d]
  to the other side breaks the boundary.

Six mutations of `Oracle.lean` (edge signs, factor order, argument order,
a globally negated associator, a transposed tensor) were each confirmed to
fail the suite. See `docs/theorems/pentagon-boundary.md`.

## Boundary

This is an executable finite certificate, not a kernel-level Lean proof that
the Boolean checker implies Mathlib's abstract composition-algebra classes.
That soundness theorem is the next formalization layer.
