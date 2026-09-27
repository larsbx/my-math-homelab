# Angle types, the counting identity, and the one import Phase 3 needs

**Status:** derivation, dated 2026-09-20. It proves the two finite facts of
`reference/angle.py` and the vendored `angle_doubling/angle.mojo`, states the
counting identity that ties the angle side to Phase 2's point side, and names
the import that everything further in Phase 3 rests on. This is Phase 3's
first rung.

Nothing in this layer is geometry. No angle is derived from a locus, no locus
from an angle, and the package does not know what a ray is. That is what lets
it live in the kernels at all.

## 1. An angle's type is its denominator, not a search

**Let `t = p/q` in lowest terms, with `q = 2^a m` and `m` odd. Then under
`t -> 2t` modulo one, `t` has preperiod exactly `a` and period exactly
`ord_m(2)`.**

*Proof.* For `l >= 0` and `k >= 1`,

```text
2^(l+k) t - 2^l t = 2^l p (2^k - 1) / q
```

is an integer exactly when `q | 2^l p (2^k - 1)`, and since `gcd(p, q) = 1`,
exactly when `q | 2^l (2^k - 1)`. Write `q = 2^a m`. Both `m` and `2^k - 1`
are odd, so the power of two must come entirely from `2^l` and the odd part
entirely from `2^k - 1`:

```text
2^(l+k) t = 2^l t   <=>   l >= a   and   m | 2^k - 1   <=>   l >= a  and  ord_m(2) | k
```

The least such `l` is `a` and the least such `k` is `ord_m(2)`. []

So `has_type` reads the type off the denominator. `tests/test_angle.py`
checks the formula against the orbit it describes for every angle with
denominator up to forty -- first repetition at exactly that preperiod, at
exactly that period, and at no proper divisor of it -- which is the check that
catches a wrong formula rather than a lucky example.

**Corollary (the count).** The angles with `2^(l+k) t = 2^l t` are exactly the
`j / (2^l (2^k - 1))`, so there are `2^l (2^k - 1)` of them.

## 2. The counting identity, and where it meets the points

```text
2^l (2^k - 1) + 2^l = 2^(l+k)
```

is arithmetic. What makes it worth writing down is what each summand counts.
The right side is `deg R^c_{l,k}`, the number of roots of the preperiodic
residual with multiplicity (`docs/preperiodic-certificates.md`, section 5).
The left summand is the number of angles of that type. And at `c = 0` the
remaining `2^l` is exactly the multiplicity of the critical point:
`R^0_{l,k}(z) = z^(2^(l+k)) - z^(2^l)`, whose root at the origin has order
`2^l`, which is also what Phase 2's recursion gives, since `f(0) = 0` there
and every step of preperiod doubles.

So at `c = 0` the identity says: **the roots of the residual are the critical
point, with multiplicity, together with exactly as many simple roots as there
are angles of that type.** Two finite counts computed in different layers, by
different arguments, that have to agree -- and do.

This is a cross-check, not a correspondence. It says the two sides have the
same size at `c = 0`. It does not say which angle goes with which root, and
nothing in this repository does.

## 3. The import: rays land

The step from the counting to a correspondence is the landing theorem. A
dynamical ray at a rational angle lands, and at a preperiodic point of the
matching type; a repelling periodic point is the landing point of finitely
many, and at least one, rational rays. That is Douady and Hubbard's, it is
**not** proved here, and it is the tag `RationalRayLanding`, which
`docs/literature-gate-2026-09-20-landing.md` judges.

It is worth being exact about what the import is *for*, because the layer
below it does not need it. Sections 1 and 2 are finite combinatorics and
finite algebra, and hold whether or not a single ray lands. What needs
landing is everything Phase 3 was named for: a ray *pair* at two angles that
land together cuts the plane in two, and `Separated_k^c` asks which side of
such a cut a box is on.

## 4. What is not built

`Separated_k^c` and `SameFiberLevel_k^c` are **not** implemented. Deciding
which side of a ray pair a box lies on is a statement about the rays as
curves, and a curve is not available in this layer: the finite data names the
angles, and the cut they make is geometry the repository has not built and has
no certificate for. Naming the predicate would be naming a search nobody can
run.

What exists after this rung is the angle side of Phase 3, complete and proved,
and the count that says it is the right size to be the other half of the
correspondence at the one parameter where both halves can be counted.

It claims no ray, no cut, no side, and no fiber, and it discharges no block of
`docs/J1_proof_definition.md`.
