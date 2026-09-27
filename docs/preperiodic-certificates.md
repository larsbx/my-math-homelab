# Preperiodic certificates, and the one import they need

**Status:** derivation, dated 2026-09-20. It states the two certificates of
`reference/preperiodic.py` and the vendored `quadratic_orbit/preperiodic.mojo`,
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

## 4. Named roots, which need no box at all

A box is only needed where the root cannot be named. The critical point can:
it is `0`, and every iterate of it is a Gaussian rational. For such a point

```text
R^c_{l,k}(z) = 0
```

is an identity over `Q(i)`, decided by exact arithmetic with no enclosure, no
contraction, and no import. `is_exact_root` is that decision.

Its multiplicity is exact too, and the recursion that gives it is the
structural reason the critical point was a problem in section 2. For `l >= 1`,

```text
R^c_{l,k}(z) = f^{l+k}(z) - f^l(z) = R^c_{l-1,k}(f(z))
```

because `f^{n}(z) = f^{n-1}(f(z))`. So `R_{l,k}` is a shorter residual
composed with `f`, and

```text
mult_z(R_{l,k}) = mult_{f(z)}(R_{l-1,k}) · mult_z(f - f(z))
```

The second factor is `1` everywhere but the critical point: `f(w) - f(z) =
(w - z)(w + z)`, which is simple at `w = z` unless `z = 0`, where it is
double. **The critical point's multiplicity is the two-to-one branching of
`f`, nothing else**, and it compounds once per step of preperiod.

At the base, `l = 0`, the multiplicity is `1` exactly when `R'_{0,k}(z) != 0`.
A vanishing `R'_{0,k}` means the cycle has multiplier one, a parabolic
parameter, and the recursion has no base case there. That is a limit of the
*account*, not of the question, and the account is not how the number is
computed.

**The computation is a jet.** A jet of order `m` at `w` is the coefficient
list of `g(w + e)` modulo `e^(m+1)`, with exact Gaussian-rational
coefficients. Pushing the seed jet `(w, 1, 0, ..., 0)` through `z -> z^2 + c`
gives every derivative of `f^n` at `w` at once, because truncated
multiplication is a finite convolution and that is all the map needs. The
multiplicity is then the index of the first nonzero coefficient of the
residual's jet, with no case analysis at all:

| parameter | point | type | multiplicity |
| --- | --- | --- | --- |
| `c = 0` | `0` | `(1, 1)` | `2` |
| `c = i` | `0` | `(2, 2)` | `2` |
| `c = 1/4` | `1/2` | `(0, 1)` | `2` |
| `c = -3/4` | `-1/2` | `(0, 2)` | `3` |

The last two are the parabolic cases, and the last one is worth reading: a
cycle of multiplier `-1` has two attracting petals for `f^2`, and the
multiplicity is `1 + 2`. Nothing in this repository knows what a petal is;
the jet counted it.

`reference/jet.py` is the layer and `branching_multiplicity` is kept beside
`exact_multiplicity` deliberately: the recursion explains *why* the critical
point is degenerate, the jet computes *how much*, and
`tests/test_preperiodic.py` checks they agree wherever both are defined. A
jet that is flat to the order computed returns `None`, which is a budget and
not a multiplicity of zero.

The layer is a differential pair like every other: `kernel/jet.mojo` is the
canonical side and `reference/jet.py` the independent oracle, and the smoke suite
replays the multiplicities above.

An earlier draft of this note claimed the Mojo side was impossible, because
`List[ComplexIQ]` would need `ComplexIQ` to be `Movable` and it is not. That
was wrong: `ComplexIQ` is not *implicitly copyable*, which is why every
assignment here calls `.copy()`, and that is a different conformance. The
claim was a workaround written up as a constraint, and it is recorded here
because the distinction is easy to make again.

## 5. Enumeration, and when it is complete

Every preperiodic point has a bounded orbit, so by `docs/escape-criterion.md`
its quadrance never passes the escape bound and both coordinates lie inside a
box of integer half-side. That box is not a guess about where the roots are:
it is the region outside which there are none.

`enumerate_roots` subdivides it, drops what excludes, keeps what isolates, and
clusters what is left. The clustering is not cosmetic. The grid is dyadic and
so are many roots, so a root lands on a cut line as often as not, and then
every cell around it has the root on a boundary where no contraction is
possible -- which is why a straight subdivision isolates nothing at `c = 0`.
The cells that stay undecided are the ones near a root, and their component's
bounding box is centred on it.

**Counting theorem.** `deg R^c_{l,k} = 2^(l+k)`, since `f^{l+k}` and `f^l`
have different degrees and cannot cancel, so `R` has exactly `2^(l+k)` roots
counted with multiplicity. If the isolated boxes hold pairwise distinct simple
roots, the named roots are distinct from each other and from those, and

```text
(number of isolated boxes) + (sum of named multiplicities) = 2^(l+k)
```

then **those are all the roots**. *Proof.* The listed roots already exhaust
the multiplicity count, so another root would push the total past the degree.
[]

The undecided boxes therefore need no explaining under that identity, which is
the pleasant part: the certificate is a count, and a search that leaves
residue can still be complete. What does need checking is checked --- that the
named points are roots, that their multiplicities are computed rather than
taken on trust, and that nothing is counted twice. Two isolated boxes can
share an edge, so disjointness is the wrong test; two are distinct when their
shared region excludes a root, which is exclusion again.

Six enumerations are pinned in `tests/test_preperiodic.py`, including
`(l, k) = (1, 1)` at `c = 0`, where two simple roots and the double root at
the critical point make `2 + 2 = 4`. At `c = i` and type `(2, 2)` the budget
runs out --- six of sixteen --- and the count refuses, which is the answer a
search is allowed to give.

## 6. Where it stops

**The critical point is not isolable by section 2, and does not need to be.**
The chain rule puts the factor `2 f^0(0) = 0` into both products, so
`R'(0) = 0` whenever `l >= 1`, the operator refuses, and the certificate
declines. `sqfree` would not have repaired it either: the multiplicity is
real, and by section 4 it is exactly the branching of `f`. What repairs it is
that the point is *named*: section 4 decides it by identity and gives its
multiplicity, and section 5 counts it. No box was ever the right tool for a
point one can write down.

What remains is the box case: a box that happens to contain a multiple root
is undecided by both certificates, and stays so however far it is refined.
Under the counting theorem that costs nothing when the root is named, and
everything when it is not.

**Width costs resolution.** The certificates fire on enclosures, so the same
point at the same type can fail on a wide box and succeed on a narrow one --
at `c = 0` and type `(1, 1)` the box of radius `1/8` around `-1` fails and the
box of radius `1/64` succeeds. `docs/enclosure-width-lemma.md` is what says
refining is guaranteed to help, and `refine_until_certified` is the
constructive side. Reported residue is a budget that ran out, never a claim.

## 7. The witnesses

`reference/parameter_corpus.py` declares six boxes across three parameters, each
isolated at its type and exact by section 3: the fixed point `1` and the
preperiodic `-1` at `c = 0`, the critical point on the 2-cycle and the
**irrational** fixed point `(1 + sqrt 5)/2` at `c = -1`, and both points of
the 2-cycle the critical orbit falls into at `c = i`.

The irrational one is the one worth looking at. Nothing in this layer can name
that root, and nothing needs to: the certificate is about a box with rational
corners, and what it establishes is that exactly one root of `z^2 - 1 - z`
lies in it. An exact statement about an irrational point, from exact rational
data.

`kernel/preperiodic_witness.mojo` checks the same six boxes at the same six
types against the vendored kernel, so the two implementations agree witness
for witness.

## 8. What this does not claim

It does not claim the isolated roots are in `J_c`, though the repelling ones
are. A multiplicity from a jet is the order of vanishing of the residual and
nothing else: it counts petals only in the sense that the classical count
happens to agree, and no petal is constructed here. It does not give the exact type of a root the certificate declines. An
enumeration whose count refuses is a budget that ran out and never a claim
that the missing roots are absent. And it discharges no block of
`docs/J1_proof_definition.md`.
