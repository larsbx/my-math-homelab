# Preperiodic certificates, and the one import they need

**Status:** derivation, dated 2026-09-20. It states the two certificates of
`tools/preperiodic.py` and the vendored `quadratic_orbit/preperiodic.mojo`,
proves the one that is this repository's own, and names the one that is not.
This is Phase 2's first rung: root isolation in dyadic boxes, Krawczyk
uniqueness, and pointwise exact-type exclusion, on

```text
R^c_{l,k}(z) = f_c^{l+k}(z) - f_c^l(z)
```

## 0. What is not here, and why

The roadmap asks for `P^c_{l,k} = sqfree(R^c_{l,k})`. There is no squarefree
part in this layer, and no polynomial either.

The parameter plane forms the polynomial because it is already working with
coefficients in `Z`. Here the coefficients would be in `Q(i)` and would depend
on `c`, and the point of the squarefree part is to make the roots simple so
that a contraction test applies. That property is directly checkable: what
`sqfree` buys is `R'(root) != 0`, and the certificate below tests an enclosure
of `R'` instead. So `R` is evaluated as what it is, a difference of two orbit
terms, and `R'` by the chain rule,

```text
(f^n)'(z) = prod_{j < n} 2 f^j(z),        R' = (f^{l+k})' - (f^l)'
```

along the same orbit. No coefficient list, no degree, no gcd.

## 1. Exclusion, which is proved here

**If `0` is not in the enclosure `R^c_{l,k}(Z)`, then no point of `Z` has
preperiod `l` and period dividing `k`.**

*Proof.* Interval arithmetic is inclusion monotone, so `R(z)` is in `R(Z)` for
every `z` in `Z`. If the enclosure misses the origin then no `R(z)` is zero,
and `R(z) = 0` is what having that type means. []

The converse fails and the certificate never claims it: an enclosure that
meets the origin says nothing, because a wide enclosure meets the origin
whether or not a root is there. `excludes` returning false is a statement
about the box, never about the points.

## 2. Isolation, which is imported

**If `K(Z)` is strictly inside `Z`, then `Z` contains exactly one root of
`R^c_{l,k}`, and that root is simple**, where

```text
K(Z) = m - Y R(m) + (1 - Y R'(Z))(Z - m),    m = the centre of Z,  Y = 1/R'(m)
```

This is the Krawczyk-Moore theorem. It is **not** proved here. It enters as
the tag `KrawczykMooreUniqueness`, which
`docs/literature-gate-2026-09-20-krawczyk.md` judges, including the step that
reads a complex polynomial as a map of the plane.

What the code returns is the **hypothesis**, not the conclusion:
`isolates_preperiodic_point` is true exactly when the strict inclusion holds.
Reading it as "there is a root here" is reading the import, and the import is
named.

One thing the exact regime gets for free. `K` is normally written with an
*approximate* inverse of the derivative at the centre, because in floating
point there is no other kind, and the theorem is stated for any linear
isomorphism `Y` precisely to allow that. Over `Q(i)` the centre is a singleton
and `Y = 1/R'(m)` is exact, so the operator inherits no error from it.

Strictness here is not decoration, and it is the opposite of the trap
certificate of `docs/three-valued-classifier.md`, which asks only for
inclusion. The difference is what each claims: a trap claims boundedness,
which invariance gives; `K` claims a unique root, which is a contraction
statement and needs room.

## 3. Exact type, which is proved here

Isolation names an upper bound rather than a type. If `z` has preperiod `l_0`
and period `k_0`, then

```text
f^{l_0 + k_0}(z) = f^{l_0}(z)  =>  f^{l + k}(z) = f^l(z)   for every l >= l_0, k_0 | k
```

-- apply `f^{l - l_0}` to both sides for the first, and iterate the period for
the second. So every root of a smaller type is a root of `R_{l,k}` too.

**If `Z` isolates a root of `R_{l,k}` and excludes every `(l', k')` with
`l' <= l` and `k' | k` other than `(l, k)` itself, then that root has exact
type `(l, k)`.**

*Proof.* The isolated root has some exact type `(l_0, k_0)`, and by the
display above `l_0 <= l` and `k_0 | k`. Every such pair but one is excluded
from `Z`, and the root is in `Z`. []

That is the "pointwise exact-type exclusion" the roadmap names, and it is
finitely many exclusion certificates on one box.

## 4. Where it stops

**The critical point is not isolable above preperiod zero.** The chain rule
puts the factor `2 f^0(0) = 0` into both products, so `R'(0) = 0` whenever
`l >= 1`: the critical point is a multiple root of its own residual. `Y` does
not exist, the operator refuses, and the certificate declines. At `c = i`,
where the critical point has type `(2, 2)`, this is exactly what happens, and
`test_the_critical_point_is_never_isolable_above_preperiod_zero` pins it.

This is not a defect of the certificate and it is not repaired by `sqfree`
either: the multiplicity is real, and a Misiurewicz point is a multiple root
of the dynamical residual by construction. Reaching it needs the deflated
residual or a different certificate, and neither is built here.

**Width costs resolution.** The certificates fire on enclosures, so the same
point at the same type can fail on a wide box and succeed on a narrow one --
at `c = 0` and type `(1, 1)` the box of radius `1/8` around `-1` fails and the
box of radius `1/64` succeeds. `docs/enclosure-width-lemma.md` is what says
refining is guaranteed to help, and `refine_until_certified` is the
constructive side. Reported residue is a budget that ran out, never a claim.

## 5. The witnesses

`tools/parameter_corpus.py` declares six boxes across three parameters, each
isolated at its type and exact by section 3: the fixed point `1` and the
preperiodic `-1` at `c = 0`, the critical point on the 2-cycle and the
**irrational** fixed point `(1 + sqrt 5)/2` at `c = -1`, and both points of
the 2-cycle the critical orbit falls into at `c = i`.

The irrational one is the one worth looking at. Nothing in this layer can name
that root, and nothing needs to: the certificate is about a box with rational
corners, and what it establishes is that exactly one root of `z^2 - 1 - z`
lies in it. An exact statement about an irrational point, from exact rational
data.

`src/preperiodic_witness.mojo` checks the same six boxes at the same six
types against the vendored kernel, so the two implementations agree witness
for witness.

## 6. What this does not claim

It does not claim the isolated roots are in `J_c`, though the repelling ones
are; it does not enumerate the roots of any `R_{l,k}`, only certifies boxes
handed to it; it does not give the exact type of any root the certificate
declines; and it discharges no block of `docs/J1_proof_definition.md`.
