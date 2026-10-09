# Multiset bridge program

**Status:** staged theorem program. The algebraic identities in stages B0 and
B1, the simple-residue-root subcertificate, one replayable Hensel step from
modulo `p` to modulo `p^2` are executable in
`kernel/mojo/dynamics/critical_relation_bridge.mojo`, together with bounded factor provenance
for monic linear factors. The rational `c = -2` subcase now also has an
executable B3 root-handle replay into the dyadic localization calculus. The
unbounded lift, general factor correspondence, and later stages require the
stated certificates or imported theorems. This program keeps
multisets in the primary research toolbox without identifying an arbitrary
finite-field statistic with the classical Mandelbrot set.

## Objective

Construct explicit bridges from multiplicity-bearing finite objects to
characteristic-zero parameter information for

```text
f_c(z) = z^2 + c,
Q_0(C) = 0,
Q_{n+1}(C) = Q_n(C)^2 + C.
```

The word `multiset` is an interface. Every instance must declare what its
coefficient counts. Different coefficient semantics support different bridges.

## Bridge ladder

### B0 — Common integral recurrence

Each `Q_n` lies in `Z[C]`. Therefore formation of the critical-orbit sequence
commutes exactly with reduction modulo every prime:

```text
reduce_p(Q_n)(c_bar) = f_bar_c^n(0).
```

This is an equality of finite algebraic computations, not an asymptotic
analogy.

### B1 — Critical-relation divisors

For `ell >= 0` and `k >= 1`, define

```text
A_{ell,k}(C) = Q_{ell+k}(C) - Q_ell(C).
```

The effective root divisor

```text
R_{ell,k} = div_0(A_{ell,k})
```

is a multiset: each parameter root is counted with its algebraic multiplicity.
Its reduction modulo `p` is computed by reducing the same integral polynomial.
This gives a canonical finite multiset with a direct characteristic-zero
ancestor.

`A_{ell,k}(c) = 0` proves only a return relation. Exact preperiod and period
require exclusions of every earlier or unintended collision. The repository's
existing intended/forbidden collision partition is the required starting
certificate.

The first multiplicity calculation is now executable. For
`A_{2,1}(C)=C^3(C+2)`, repeated exact division gives

```text
div_0(A_{2,1}) = 3[0] + [-2].
```

Filtering by the minimal collision pattern removes `C=0`, whose critical
orbit already has type `(0,1)`, and retains `C=-2` with exact type `(2,1)`:

```text
D^{exact}_{2,1} = [-2].
```

Thus root multiplicity is not exact-type multiplicity. The executable
`CriticalRelationDivisorMultiset` records both cycles and checks that the raw
multiplicities sum to the degree before applying the exact-type filter.

The next relation demonstrates where the rational subcase stops. Exact
factorization gives

```text
A_{4,1}(C) =
  C^5(C+2)(C^3+2C^2+2C+2)F_7(C),
deg(F_7)=7.
```

Repeated exact division removes the known lower-type contribution
`5[0]+[-2]` and produces a degree-10 residual candidate divisor

```text
div_0((C^3+2C^2+2C+2)F_7(C)).
```

The executable `R41ResidualDivisorMultiset` checks the factorization and
degree accounting. The follow-on `R41AlgebraicRootCertificate` uses exact
Euclidean gcd calculations after reduction modulo 5. It verifies that both
non-rational factors are squarefree and coprime, that the cubic factor divides
the earlier collision `Q_4-Q_3`, and that `F_7` is coprime to every
unintended collision through the required horizon. Thus the cubic is a
lower-type contribution, while

```text
D^{exact}_{4,1} = div_0(F_7)
```

has seven distinct algebraic roots of exact critical-orbit type `(4,1)`.
This is an algebraic factor and collision certificate. It does not choose or
localize any embedding, so it supplies no B3 root handle and makes no density,
equidistribution, or C1 claim.

#### Exact-type counts over `F_p` (research-only)

`kernel/mojo/dynamics/critical_type_sieve.mojo` counts, for each prime `p`,

```text
N_p(ell,k) = #{ c in F_p : the critical orbit of c has exact type (ell,k) mod p }.
```

Each residue parameter is counted once, after imposing the exact-type
collision exclusions over `F_p`; algebraic root multiplicities are not counted.
The smoke checks three exact laws on every residue for
`p in {2, 3, 5, 7, 13, 101, 1009}` and horizon `8`:

- `#roots of R_{ell,k} in F_p = sum_{mu <= ell, lambda | k} N_p(mu,lambda)`;
- the counts and the unresolved residues partition `F_p`;
- `N_p(1,k) = 0` for odd `p`.

`tests/test_critical_type_sieve.py` recomputes its golden counts from the
exact integer polynomials, by root counting and inversion over that order.

Let `E_{ell,k}` be the monic characteristic-zero polynomial whose distinct
roots have exact type `(ell,k)` (for `(4,1)`, it is the `F_7` above). A sufficient
good-prime condition is

```text
p does not divide disc(squarefree_part(A_{ell,k})).
```

The squarefree part contains every exact-type factor below `(ell,k)` once.
Its discriminant excludes both multiple roots of each factor and collisions
between different factors, detected by their pairwise resultants. Under this
condition, reduction preserves the exact-type root sets and `N_p(ell,k)` equals
the number of distinct `F_p`-roots of `E_{ell,k} mod p`. The relation-root law
and its inversion remain exact at bad primes too, but this identification can
fail there. For example, `E_{2,2}=C^2+1` has discriminant `-4` and two simple
roots modulo 5, yet `N_5(2,2)=1`: the root `C=3=-2 mod 5` has type `(2,1)`.
The collision is detected by `Res(C^2+1,C+2)=5`, not by `disc(E_{2,2})`.

Chebotarev density and the orbit-counting lemma give a **limiting** prime mean
equal to the number of distinct `Q`-irreducible factors of `E_{ell,k}`. The
finitely many bad primes do not change that limit, but can change a finite
mean. The exact-type polynomial construction is given by Hutz and Towsley,
[*Misiurewicz points for polynomial maps and transversality*, Theorem 1.1](https://nyjm.albany.edu/j/2015/21-13v.pdf);
the prime-mean principle is described by Stevenhagen and Lenstra,
[*Chebotarev and his density theorem*, p. 32](https://pub.math.leidenuniv.nl/~lenstrahw/PUBLICATIONS/1996d/art.pdf).
`pixi run type-sieve` prints raw totals over all 2261 odd primes
`p <= 20000`, including bad primes, for every `(ell,k)` with
`ell + k <= 8`, `ell != 1`:

- the linear types `(0,1)`, `(0,2)`, `(2,1)` total exactly 2261;
- every other total lies in `[2166, 2301]`, a mean in `[0.958, 1.018]`;
- `(4,1)` totals 2219.

Two distinct irreducible factors would give a limiting mean of 2. A uniform
permutation in the full symmetric group on `d >= 2` roots has a fixed-point
count with mean 1 and variance 1 (the linear types have variance 0). If the
Frobenius observations are additionally modeled as independent samples from
that distribution, the model standard error is `1/sqrt(2261)`, near `0.021`.
Chebotarev alone supplies neither that independence assumption nor an error
bound at `p <= 20000`; this is a heuristic scale, not a confidence interval
or a Galois-group certificate.

Subject to sufficient convergence at this bound and control of the finite
bad-prime contribution, the table supports irreducibility as a research
hypothesis for the Gleason and Misiurewicz polynomials in range. The sweep
itself proves no irreducibility, Galois-group, or C1 claim. The certificates
below separately supply the proof for this range and for `ell + k <= 10`.

#### Irreducibility certificates for `ell + k <= 10`

`kernel/mojo/dynamics/exact_type_irreducibility.mojo` certifies that every
exact-type polynomial `E_{ell,k}` with `ell + k <= 10` is irreducible over `Q`:

- 3 linear types: `C`, `C + 1`, `C + 2`;
- 43 types of degree 2 through 495, the largest being the period-10 Gleason
  polynomial.

Over `Z`,

```text
R_{ell,k} = E_{ell,k} * prod_{mu <= ell, lambda | k, (mu,lambda) != (ell,k)} E_{mu,lambda}^{m}
```

with every factor monic, so `E_{ell,k} mod p` is an exact quotient over `F_p`.

A certificate lists primes at which `E mod p` is squarefree, together with
its factor degrees from distinct-degree factorization. Any factorization
`E = GH` over `Q` has monic integral factors (Gauss), so `deg G` would be a
subset sum of the factor degrees at every listed prime. The certificate
holds when the common subset sums are only `0` and `deg E`. Every type needs
at most five primes, all drawn from `{3, 5, 7, 11, 13, 17, 19}`.

The multiplicities `m` are read off by exact division. They are the true
multiplicities only once the lower `E` are irreducible, so the types are
certified in increasing order.

`reference/python/polynomial/exact_type_irreducibility.py` recomputes three
things independently, and `tests/test_exact_type_irreducibility.py` binds the
two implementations:

- `E` over `Z`;
- the multiplicity table, together with the identity above;
- every factor pattern, with its own factorization.

The smoke checks three further things:

- each pattern's linear factors against a root count;
- that a product of two exact-type polynomials never certifies;
- the replay itself.

The certificate says nothing past `ell + k = 10` and names no Galois group.

### B2 — Good-reduction and lifting certificate

A residue-class root may be used in the bridge only with a certificate that
records:

1. `A_{ell,k}(c_bar) = 0` modulo `p`;
2. the derivative is nonzero modulo `p`, or a separately verified
   multiplicity treatment;
3. all exact-type collision exclusions;
4. the relevant discriminant and resultant nonvanishing conditions;
5. a factor/root correspondence or Hensel lift.

For a simple residue root, Hensel lifting supplies a unique root in the chosen
`p`-adic residue class. Because it satisfies the same integral
critical-relation polynomial, its algebraic conjugates in characteristic zero
are postcritically finite parameters after the exact-type exclusions are
verified. Their critical orbits are finite, hence bounded, so their complex
embeddings lie in the classical Mandelbrot set.

This stage bridges a certified root multiset to a postcritically finite
submultiset of `M`; it does not bridge every finite-field parameter to `M`.

Current executable boundary: the checker verifies bounded primality,
commutation of polynomial reduction with direct iteration, the minimal-horizon
exact collision pattern, and a nonzero modular derivative. From an accepted
simple root it computes the unique correction digit and verifies the compatible
root modulo `p^2`. This is a finite Hensel step, not an asserted infinite
`p`-adic lift. The checker does not yet produce a characteristic-zero factor
correspondence, complex embedding, localization, or discriminant/resultant
evidence.

The polynomial checker materializes `Q_n` with `Int` coefficients, so it
answers horizons `ell + k <= 7` and primes `p <= 2^20`: `Q_8` has 72-bit
coefficients. `verify_simple_residue_root_by_census`
(`kernel/mojo/dynamics/critical_type_census.mojo`) issues the same simple
residue root certificate for every prime `p < 2^32` and horizon below `2^32`
without materializing a polynomial. It evaluates `R_{ell,k}` and `R'_{ell,k}`
at the residue through the B0 recurrence and `Q'_{n+1} = 2 Q_n Q'_n + 1`,
both identities in `Z[C]` that reduction modulo `p` preserves, and reads the
exact collision pattern from the vendored orbit census. It agrees with the
polynomial checker field by field on that checker's domain for the small
primes, and its golden vectors past both bounds are recomputed from exact
integer polynomials in `tests/test_critical_relation_census.py`. The Hensel
step and factor provenance keep their polynomial bounds.

The first characteristic-zero factor subcase is also executable: for a bounded
integer root, the checker replays synthetic division by `C - r`, exact
recomposition, simple-root differentiation, and agreement of `r` with the
certified residues modulo `p` and `p^2`. This proves factor provenance for
rational PCF parameters such as `c = -2`. It is not a general factorization
algorithm and says nothing yet about non-rational complex embeddings.

### B3 — Localization into the existing certificate calculus

For a selected complex embedding, the bridge must construct the existing
finite root handle:

```text
(squarefree factor, dyadic localization box, uniqueness witness).
```

The output can then use the ordinary landing, ray-address, and theorem-tag
interfaces. The finite-field record is provenance for the candidate and its
multiplicity; the characteristic-zero localization is what admits it to the
classical certificate layer.

The first executable B3 subcase is `RationalB3RootHandle` in
`kernel/mojo/dynamics/multiset_b3_localization.mojo`. For `c = -2`, it composes:

1. the modular simple-root and one-step Hensel provenance at `p = 5`;
2. exact characteristic-zero factor provenance for `C + 2`;
3. the dyadic box for `P_{2,1}=C(C+2)`;
4. the exact Krawczyk contraction proving a unique root in that box; and
5. direct integer replay of the critical orbit `0,-2,2,2`.

The rational root has a canonical characteristic-zero embedding, but the
current BigZ/Q backend is still designated non-proof-grade. Accordingly,
`arithmetic_replay_accepted()` records the successful finite composition while
`accepted()` and `proof_grade_accepted()` remain false until the repository
proof-backend gate opens. This does not yet close the acceptance-bearing B3
handoff. General algebraic factors, conjugate selection, and non-rational
complex embeddings remain fail-closed.

### B4 — Distributional bridge

Postcritically finite parameter divisors are not merely isolated examples.
Published equidistribution results provide a route in which normalized
postcritically finite parameter multisets converge to the bifurcation measure
in polynomial parameter spaces. In the quadratic family this is the measure
supported on the Mandelbrot bifurcation locus.

The repository must pin the precise family, normalization, allowed
combinatorics, exceptional sets, and convergence mode before importing this as
a theorem tag. Relevant primary sources include:

- Charles Favre and Thomas Gauthier, *Distribution of postcritically finite
  polynomials*, arXiv:1302.0810;
- Thomas Gauthier and Gabriel Vigny, *Distribution of postcritically finite
  polynomials II: Speed of convergence*, arXiv:1505.07325;
- Thomas Gauthier and Gabriel Vigny, *Distribution of postcritically finite
  polynomials III: Combinatorial continuity*, arXiv:1602.00925.

B4 is the proposed global bridge from a sequence of algebraic multisets to a
canonical measure on the classical boundary. It is not yet an imported theorem
in the project ledger.

## Coefficient-semantics matrix

| Multiset coefficient | Immediate bridge | Missing obligation |
|---|---|---|
| algebraic root multiplicity of `A_{ell,k}` | B0–B3 | good reduction, exact type, localization |
| exact-type witness count | B1–B3 after quotienting duplicate encodings | canonical witness equivalence |
| Frobenius-orbit multiplicity | arithmetic descent data | embedding and lift certificate |
| critical-basin cardinality over `F_p` | finite functional-graph invariant only | comparison theorem to a critical-relation divisor or height |
| projective intersection multiplicity at infinity | divisor-theoretic escape data | relation to the marked critical section |
| certified dyadic escape-witness count | subset of the classical complement | coverage and overlap normalization |

The basin multiset introduced in `kernel/mojo/dynamics/projective_multiset.mojo` therefore
remains in the toolbox. It is not discarded; it occupies a different bridge
column from algebraic root multiplicity.

## First implementable theorem target

For fixed bounded `(ell,k,p)`, produce a replayable record containing:

```text
A_{ell,k} over Z
its reduction modulo p
the residue root and derivative
all forbidden-collision evaluations
the squarefree characteristic-zero factor
a dyadic localization witness for one complex embedding
the equality between declared multiplicity and the factor/root calculation
```

Acceptance proves that the localized characteristic-zero parameter has the
declared exact critical-orbit type and lies in `M`. It makes no density,
boundary-coverage, or MLC claim.

## Non-claims

- Large finite-field basin weight does not presently imply proximity to the
  classical boundary.
- Reduction modulo one prime does not recover a complex parameter uniquely.
- Hensel lifting alone does not choose a complex embedding or localization.
- Equidistribution does not imply setwise convergence, local connectivity, or
  that any finite level covers the boundary.
