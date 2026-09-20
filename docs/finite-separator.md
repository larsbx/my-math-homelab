# The separator, restated in what the finite layer carries

**Status:** derivation, dated 2026-09-20. Phase 3's second bullet asked for
`Separated_k^c`, built from landed ray pairs. `docs/angle-types-and-landing.md`
section 4 reported that it could not be written down: landing gives a point,
a ray pair cuts the plane with a pair of *curves*, and a curve is not an
object at rank 2. This is the restatement. Sections 2 to 5 are proved here.
Section 6 says exactly what the restatement gives up, and names the import
that would buy it back.

## 1. A cut is a form, not a curve

```text
L(x, y) = a x + b y - e,    a, b, e exact rationals, (a, b) != (0, 0)
```

A box `B` is on the **positive side** of `L` when the enclosure `L(B)` is
strictly positive, on the **negative side** when it is strictly negative, and
**undecided** otherwise. That is the three-valued sign of
`docs/rational-interval-arithmetic-spec.md` section 2.4, applied to a linear
form, and it needs no geometry: no point of the line is ever constructed, and
`L` is never evaluated anywhere except on a box.

`UNDECIDED` is the fail-closed answer. It means the enclosure met the line,
which a wide box does whether or not any of its points is near it.

**A cut is a declared witness and needs no verification.** A trap has to be
checked before a verdict rests on it; a cut does not, because section 2 is
sound for *every* line. A badly placed cut is uninformative and cannot be
wrong. That asymmetry is the reason this restatement is possible at all: the
work a ray pair does is topological, and the work a cut does is arithmetic.

## 2. Separation, and what it proves

**Definition.** For a finite catalogue `C` of cuts and a level `k`, boxes `A`
and `B` are **separated at level k** when there are `n <= k` and `L in C` with
`F^n(A)` and `F^n(B)` on decided and opposite sides of `L`.

**Soundness.** *If `A` and `B` are separated at level `k`, then for every
`a in A` and `b in B` the iterates `f^n(a)` and `f^n(b)` lie strictly on
opposite sides of `L`. In particular `a != b`.*

*Proof.* By inclusion monotonicity `f^n(a) in F^n(A)`, and the whole of
`F^n(A)` satisfies `L > 0` while the whole of `F^n(B)` satisfies `L < 0`, or
the reverse. []

That is the entire claim. It says nothing about fibers, nothing about
components, and nothing about the curve `L = 0`.

## 3. The nest is monotone

**If `A` and `B` are separated at level `k`, they are separated at every
level above `k`, with the same cut and the same step.**

*Proof.* The steps searched at level `k` are a prefix of those searched at
`k + 1`. []

So non-separation is decreasing in `k`: the relations
`NotSep_0 ⊇ NotSep_1 ⊇ NotSep_2 ⊇ ...` form a nest, and "the nest stabilizes"
is a finite, checkable event at each level rather than a limit.

## 4. Adequacy, and why it must be relative

**If `A` and `B` are disjoint, the catalogue `{coordinate_cut_between(A, B)}`
separates them at level `0`, and that cut is written down rather than
asserted to exist.**

*Proof.* Boxes are axis aligned, so two disjoint boxes are disjoint in a
coordinate: some `A.re.hi < B.re.lo` or the reverse, or the same in the
imaginary coordinate. The line halfway between them in that coordinate has
rational coefficients, and each box is strictly on one side of it. []

This is good news and bad news in one statement. The good: separation is not
a weak notion; an unrestricted catalogue separates every pair of boxes that
are distinguishable at all. The bad, and it is the important half:

> **With an unrestricted catalogue every class is a single point, so the
> question Phase 4 exists to ask has no content there.**

A non-triviality witness -- a pair the catalogue *permanently* fails to
separate -- is only possible against a **declared, finite** catalogue.
Adequacy and non-triviality are therefore statements about a catalogue, never
about the parameter alone, and any row claiming either has to name its
catalogue. That is a real change from the ray-pair formulation, where the
catalogue was determined by the dynamics.

## 5. Non-separation is a tolerance, not an equivalence

**Level-`k` non-separation is reflexive and symmetric, and is not
transitive.**

*Proof.* Reflexive because no cut puts a box on two different decided sides
of itself; symmetric by symmetry of the definition. For transitivity, take
`c = 0` and the vertical cut `x = 0`, and the boxes of radius `1/16` around
`1/2`, `0`, and `-1/2`. The middle box straddles the cut at every step, since
it is a trap at the origin, so it is never separated from either of the
others; the outer two are separated at step `0`. []

`tests/test_separator.py` pins exactly that triple. The consequence is a rule,
not a curiosity: **a class of non-separation is not a fiber and must never be
called one**, because the relation does not partition anything. The
terminology registry carries this as a declared leak.

## 6. What `J1` becomes

`docs/J1_proof_definition.md` states the bridge as two obligations. Under the
restatement they split three ways, and the split is the point:

| original | status here |
| --- | --- |
| `J1-A`: the finite catalogue relation is extensionally fiber separation | **not restated.** Extensional equality with fiber separation is exactly the part that needs rays. It becomes an import, below. |
| `J1-B`: a finite nest stabilizes exactly when the fiber is trivial | **split.** That the nest is decreasing and its stabilization decidable at each level is section 3, proved. That stabilization means *triviality of a fiber* is the same import. |
| -- | **new, and proved:** sections 2, 4 and 5 -- soundness, relative adequacy, and the tolerance-not-equivalence warning. |

The import that would restore the classical reading:

```text
the cut catalogue separates exactly what a landed ray-pair catalogue separates
    [CutCatalogueRayEquivalence: NOT GATED, NOT USED]
```

It is named here so that nothing uses it by accident, and it is **not** gated,
because nothing in this repository needs it yet: every statement above is
about cuts, and none of them mentions a fiber. `RationalRayLanding`
(`docs/literature-gate-2026-09-20-landing.md`) is a different tag and does not
imply this one -- landing tells you a ray reaches a point, not that a straight
cut through that point separates what the ray pair separates.

## 7. What this does not claim

It does not claim the relation is fiber separation, that a class is a fiber,
or that the classes are connected. It does not claim any catalogue is
adequate; adequacy is section 4's, and it is relative to the catalogue. It
does not settle whether a declared finite catalogue can permanently fail to
separate a pair, which is Phase 4 and is now at least *expressible*. And it
discharges no block of `docs/J1_proof_definition.md` -- it says which blocks
are now provable here and which have become a named import.
