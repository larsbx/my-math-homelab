# Literature gate — algebraic indifferent multipliers

Status: classical imports accepted with the qualifications below. This gate
repairs the missing authority advertised by PR #7. It changes no executable
verdict and proves no local-connectivity or classifier-completeness claim.
Analytic quantities in this document belong to the classical layer.

## Proposed step and decision

The finite hypothesis is an exactly computed multiplier `lam` in `Q(i)` with
quadrance 1 and outside `{1, -1, i, -i}`. This is the irrationally indifferent
branch of the existing `classify_multiplier` checker. The four-element test
is proved in `docs/julia-program-design-analysis-2026-09-19.md`, section 6.

**`AlgebraicMultiplierDiophantine`: ACCEPTED WITH QUALIFICATION.** An algebraic
number of modulus 1 that is not a root of unity has a Diophantine rotation
number. This yields Brjuno and, through the already accepted
`BrjunoYoccozQuadraticLinearization` import, linearization at the `niven`
fixed point. The qualification is that this is a literature-layer conclusion,
not a new multiplier class or a finite-core certificate.

**`HermanUnicriticalSiegelCriticalBoundary`: ACCEPTED WITH QUALIFICATION.** For
the fixed Siegel disk of the unicritical quadratic, a Diophantine rotation
number forces the critical point onto its boundary. This does not imply local
connectivity. Neither tag replaces the ledger's local-connectivity tag column.

The Laurent route, a numerical Brjuno bound for `niven`, and an effective
rotation-domain `IN` certificate are **not accepted deliverables** of this
gate. Finding 7 gives a conditional tail estimate and names the missing work.

## Findings

### 1. The exact `niven` hypothesis holds

For `c = (37 + 16i)/100`, the fixed point is `z0 = (3 + 4i)/10` and
`lam = 2 z0 = (3 + 4i)/5`. The identity `z0^2 + c = z0` and quadrance 1
are exact. The multiplier is algebraic (it satisfies `5 X^2 - 6 X + 5 = 0`)
and is outside `{1, -1, i, -i}`. The existing corpus and multiplier checker
supply these finite hypotheses, without a continued-fraction prefix.

### 2. Route D: linear forms in logarithms imply Diophantine

Ferreira–Ribas, Theorem 1.1 and section 3, state and derive precisely the
needed algebraic-number result.[^1] Their input is Baker–Wüstholz's effective
lower bound for a nonzero integer linear form in logarithms.[^2] For fixed
algebraic inputs, its dependence on the integer coefficients is linear in
`log B`, not quadratic. The reduction can be checked directly:

Write `lam = exp(2 pi i theta)` with `-1/2 < theta <= 1/2`, and use
`Log(-1) = pi i`. For `q >= 1` and an integer `p` nearest to `q theta`,

```text
Lambda = q Log(lam) - 2p Log(-1) = 2 pi i (q theta - p).
```

It is nonzero, since zero would give `lam^q = 1`. Also
`B = max(q, 2|p|, 3) <= 3q`. Absorbing the fixed heights and logarithms into
an effective constant `C`, the imported bound gives

```text
|Lambda| >= (3q)^(-C),
||q theta|| >= A q^(-C),    A = 3^(-C)/(2 pi) > 0.
```

Enlarge `C` to at least 1 and decrease `A` to at most 1 if necessary.
Thus `|theta - p/q| >= A q^(-(C+1))` for every rational `p/q`: the nearest
integer minimizes the left side. This is the Diophantine conclusion. No
bounded-type conclusion follows from this finite exponent.

The gate checked the reduction and the cited theorem statements, not the
original Baker–Wüstholz proof. It adopts no numerical height normalization
or value of `C` from the Ferreira–Ribas preprint; none is needed for this
qualitative implication.

### 3. Diophantine implies Brjuno

Let `p_n/q_n` be the convergents of the representative of `theta` in `(0, 1)`.
The standard continued-fraction estimate and finding 2 give

```text
A q_n^(-C) <= ||q_n theta|| < 1/q_(n+1),
log q_(n+1) <= D + C log q_n,    D = -log A >= 0.
```

Convergent denominators satisfy `q_(n+2) >= 2 q_n` once they increase.
Consequently `sum_n (log q_(n+1))/q_n` converges. This is a derivation of the
Brjuno condition from the imported Diophantine bound, not an inference from
any finite prefix.

### 4. Linearization and the critical boundary

Translation to the fixed point gives `f_c(z0 + w) - z0 = lam w + w^2`.
The accepted `BrjunoYoccozQuadraticLinearization` tag in
`docs/literature-gate-2026-09-19.md`, finding 5, therefore applies. Yoccoz's
primary account, introduction and Chapter II, section 1.8, gives the
quadratic result.[^3] His normalization `lam z (1 - z)` is conjugate to
`lam w + w^2` by `w = -lam z`. At `niven` there is a Siegel disk in the
classical interpretation.

Chéritat–Roesch's introduction states that Diophantine numbers lie in Herman's
class and states Herman's theorem for fixed Siegel disks of unicritical
polynomials, without assuming a Jordan boundary.[^4] Both hypotheses apply
here. The sole finite critical point `0` is on the boundary of that disk.
Neither linearization nor critical-boundary incidence supplies a theorem of
local connectivity at this particular rotation number. Its ledger cell stays
`OPEN`, and `J1` stays `UNDECIDED`.

### 5. Noncomputability does not obstruct `RC` as defined

`RC(c)` in `docs/survey-assessment-2026-10-05.md` asks only for the area of the
unclassified part of a fixed bounded observation window to tend to zero. It
specifies no computable modulus and no Hausdorff error bound. Braverman–
Yampolsky define set computability using prescribed-accuracy Hausdorff
approximation (section 2, Definition 2.3).[^5] They do not rule out this weaker
area-convergence assertion. Even an effective area bound alone would not
control thin unresolved sets in Hausdorff distance.

This is a comparison of definitions, not a proof of `RC(niven)`. A zero-area
import and exhaustive interior coverage remain separate obligations; finding
4 produces neither. No failure of `RC`, or impossibility of all non-strict
traps, is adopted from the unlanded claims in PR #7's body.

### 6. The advertised route B is withdrawn

Laurent 2008, Theorem 2 and Corollary 1, require multiplicatively independent
algebraic inputs.[^6] The reduction in finding 2 uses `lam` and `-1`; those
inputs fail that requirement because `(-1)^2 = 1`. Theorem 1 has other
conditions, and this gate does not supply an instantiation satisfying them.
Accordingly it accepts no Laurent `exp(-C (log q)^2)` bound for this row,
and no numerical tail or radius derived from that advertised route. This
withdrawal leaves route D intact.

### 7. A qualified consumer for exact continued-fraction prefixes

Route D supplies effective constants in principle. **Once a consumer has
audited explicit `A, C` valid for this multiplier**, finding 3 gives a useful
tail bound. For a prefix through `q_N >= 3`, put

```text
S_N = sum_(n=0)^(N-1) (log q_(n+1))/q_n,
T_N = sum_(n=N)^infinity (log q_(n+1))/q_n.
T_N <= 4 (D + C log(2 q_N))/q_N.
```

Proof: `g(x) = (D + C log x)/x` decreases for `x >= 3`. For each `k >= 0`,
both `q_(N+2k)` and `q_(N+2k+1)` are at least `2^k q_N`. Pairing terms
bounds the tail by `2 sum_k g(2^k q_N)`. The identities
`sum_k 2^(-k) = 2` and `sum_k k 2^(-k) = 2` give the displayed expression.

This derived, conditional estimate explains a possible consumer of an exact
rotor prefix. A finite kernel need supply only the partial quotients and
denominators; logarithm enclosures, the theorem constants and all analytic
interpretation belong to the consumer. It would still need an audited
quantitative linearization theorem and a replayable certificate to turn a
Brjuno upper bound into an `IN` verdict. No explicit `A, C` for `niven`,
numerical Brjuno bound, radius, rotor-prefix kernel or rotation-domain checker
is implemented or certified by this gate.

## Verdicts and propagation

| Statement | Verdict | Boundary |
| --- | --- | --- |
| `AlgebraicMultiplierDiophantine` | ACCEPTED WITH QUALIFICATION | finite exact hypotheses; imported Diophantine conclusion; no numerical constants |
| `BrjunoYoccozQuadraticLinearization` at `niven` | existing accepted import applies | analytic Siegel conclusion, not a multiplier-checker output |
| `HermanUnicriticalSiegelCriticalBoundary` at `niven` | ACCEPTED WITH QUALIFICATION | critical point on boundary; local connectivity remains open |
| Laurent route B for this row | WITHDRAWN | required specialization was not supplied |
| Prefix plus numerical tail or linearization radius | OPEN implementation target | finding 7 is conditional, not an existing certificate |
| Noncomputability-based exclusion from `RC` | REJECTED inference | area convergence does not imply prescribed-accuracy Hausdorff computation |

The survey, README, design analysis, dictionary, proof-definition status,
terminology registry and earlier gate must use these conclusions. The corpus
note is updated at `reference/parameter_corpus.py`; the ledger is regenerated
with `tools/make_regime_ledger.py`. Its verified classes, local-connectivity
tag column and `J1` status do not acquire analytic acceptance authority.

## What this gate did not do

It did not prove a classical theorem internally, instantiate a numerical
Baker–Wüstholz constant, decide bounded type, settle local connectivity or
Julia-set area, establish `RC`, or build a new `IN` certificate. It read the
primary statements and the algebraic-to-Diophantine reduction cited above,
and independently derived findings 3 and 7 from their stated hypothesis.

[^1]: G. C. G. Ferreira and S. Ribas, *Arithmetic properties of arguments of algebraic numbers on the unit circle*, arXiv:2602.23597v1 (2026), Theorem 1.1 and section 3, pp. 3 and 6–7. https://arxiv.org/html/2602.23597v1
[^2]: A. Baker and G. Wüstholz, *Logarithmic forms and group varieties*, Journal für die reine und angewandte Mathematik 442 (1993), 19–62, DOI 10.1515/crll.1993.442.19. The fixed-input bound used here is restated in [^1], Theorem 2.3. https://doi.org/10.1515/crll.1993.442.19
[^3]: J.-C. Yoccoz, *Théorème de Siegel, nombres de Bruno et polynômes quadratiques*, in *Petits diviseurs en dimension 1*, Astérisque 231 (1995), 1–88, introduction and Chapter II, section 1.8. https://www.numdam.org/item/AST_1995__231__1_0.pdf
[^4]: A. Chéritat and P. Roesch, *Herman's condition and Siegel disks of bi-critical polynomials*, arXiv:1111.4629v3, introduction, pp. 1–2: Herman's class contains the Diophantine numbers; the stated unicritical theorem applies to fixed disks. https://arxiv.org/pdf/1111.4629v3
[^5]: M. Braverman and M. Yampolsky, *Non-computable Julia sets*, arXiv:math/0406416v2, section 2, Definition 2.3 and Theorem 2.2. https://arxiv.org/pdf/math/0406416v2
[^6]: M. Laurent, *Linear forms in two logarithms and interpolation determinants II*, Acta Arithmetica 133 (2008), 325–348, Theorem 2 and Corollary 1, pp. 327–328. https://www.impan.pl/shop/publication/transaction/download/product/82485
