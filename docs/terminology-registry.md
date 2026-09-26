# Terminology Registry

Status: controlled vocabulary registry.

The governance process is `docs/terminology-governance.md`, mirrored from
`larsbx/finite-mandelbrot-research`. Terms shared with the parameter-plane
program keep the sense that registry gives them; this file records the
dynamical-plane vocabulary and the deltas.

## Established field terms

Usable without a terminology declaration, in their ordinary field sense:

- Julia set
- filled Julia set
- Fatou set
- critical orbit
- postcritically finite
- Misiurewicz parameter
- parabolic parameter
- hyperbolic parameter
- indifferent cycle
- rationally indifferent, irrationally indifferent
- Siegel disk, Cremer point
- circular points (the ideal elements `I` and `J` of `P^2`)
- Brjuno condition, rotation number
- multiplier
- attracting, superattracting, repelling
- local connectivity
- fiber, trivial fiber
- dynamical ray, external ray, landing
- doubling map
- kneading sequence, orbit portrait
- dyadic box, interval arithmetic
- Krawczyk method, squarefree polynomial
- Ford circles (the Farey tangency family; also inside the sibling repository
  slug `mandelbrot-bulbs-and-ford-circles-research`)
- quadrance, spread, incidence relation, vertex
- Markov partition, transition matrix, transfer matrix
- kneading prefix, critical itinerary, tuning, tuning pattern, star product
- substitution, incidence matrix, primitive substitution
- Perron root, Perron-Frobenius theorem, spectral radius
- characteristic polynomial, algebraic integer, conjugate, Pisot number
- topological entropy, symbolic dynamics, admissible word

## Declared terms

### Gaussian-rational parameter

Status: definition-only.
Genealogy: `Q(i)` as the field of coordinates; the rank-2 coordinate record of
`docs/rank2-coordinate-substrate.md` in the parameter-plane program.
Bridge claim: a pair of exact rationals with polynomial operations and a
quadrance scalar. It is not an analytic complex number and carries no circle,
disk, arc, polar angle, or connected component.
Known leaks: an exactly representable parameter can have dynamics that no
finite test decides; see the irrationally indifferent row of the ledger.
Use discipline: the Phase 0 parameter domain. Algebraic parameters and
interval parameters are both Phase 4 and are **two** different terms, not
one: an algebraic parameter keeps exact equality and so keeps every verdict
that reads one, and an interval parameter does not. `ROADMAP.md`, Phase 4,
carries the distinction.

### Rational multiplier dichotomy

Status: theorem, proved in
`docs/julia-program-design-analysis-2026-09-19.md`, section 6.
Genealogy: the degree of cyclotomic extensions; Kronecker-style constraints on
algebraic numbers of unit modulus.
Bridge claim: a quadrance-1 element of `Q(i)` is a root of unity exactly when
it is one of `1, -1, i, -i`, so rationally versus irrationally indifferent is
decided by a four-element membership test.
Known leaks: it decides nothing about Siegel versus Cremer, which turns on the
Brjuno condition for the rotation number.
Use discipline: cite it wherever the parabolic case is separated from the
irrationally indifferent case; never cite it for a linearizability claim.

### Homogeneous coordinate record

Status: novel bridge term.
Genealogy: homogeneous coordinates of classical projective geometry; the
rank-2 coordinate record of `docs/rank2-coordinate-substrate.md`.
Bridge claim: a pair of rank-2 coordinate records `[Z : W]`, taken modulo
scaling by a nonzero record. Every operation on it in
`docs/projective-completion-and-escape.md` is polynomial, and the quadratic
map lifts to it as a morphism with no base point.
Known leaks: it is not an ideal point. `[1 : 0]` is a class of records, not an
element of the plane, and nothing about it may be evaluated as if it were a
value; the no-points invariant of the parameter-plane program applies here
unchanged. Reading `[Z : W]` as a value also requires a chart, and a chart is
a division with a nonzero-quadrance domain.
Use discipline: use it only for the `P^1(C)` completion of section 1 of
`docs/projective-completion-and-escape.md`. The circular points of the other
completion are a different layer and are not reachable from this term.

### Chart at infinity

Status: definition-only.
Genealogy: the standard second affine chart of `P^1`; inverse by conjugate
over quadrance, as the parameter-plane program computes it.
Bridge claim: the substitution `u = W / Z`, under which the quadratic map
reads `u -> u^2 / (1 + c u^2)` and infinity is a superattracting fixed
element of order two.
Known leaks: the chart is undefined where the quadrance vanishes, and over a
box it is undefined unless the quadrance interval excludes zero. A box that
straddles the origin is outside the chart, and the verdict there is
`UNKNOWN`, never a chart value computed anyway.
Use discipline: name the chart whenever a statement is made about infinity.
"Escape" without a chart is the affine inequality of
`src/julia_orbit.mojo` and nothing more.

### Escape certificate

Status: novel bridge term.
Genealogy: the classical escape radius of quadratic dynamics; the
certificate-carrying discipline of the parameter-plane program.
Bridge claim: a rational ratio `r > 1`, together with the two quadrances it
was checked against, such that the quadrance of the orbit grows by at least
`r` at every step from that point on. The claim is per step and is proved in
`docs/escape-criterion.md`; it is not a statement about a limit.
Known leaks: a parameter with no certificate is not thereby bounded, and the
certificate says nothing about the Julia set of the parameter, whose Cantor
structure remains an imported tag. The ratio is a lower bound on growth, not
the growth.
Use discipline: attach it wherever `ESCAPES` is reported. An escape index
without a ratio is a threshold crossing, which is a weaker statement than the
word escape suggests.

### Cut

Status: novel bridge term.
Genealogy: the landed ray pairs of the classical separator; the three-valued
interval sign of `docs/rational-interval-arithmetic-spec.md` section 2.4.
Bridge claim: an exact rational linear form `a x + b y - e`, together with
the side of it a box is enclosed on, three-valued. The claim a cut makes is
`docs/finite-separator.md` section 2 and nothing more: two boxes on decided
opposite sides hold points whose iterates are on opposite sides of that line.
Known leaks: a cut is not a ray and a pair of cuts is not a ray pair. It does
not bound a region and does not cut the plane into components in any sense
this repository can check. Separating by a cut is **not** separating by the
classical catalogue, and that is settled rather than open: a cut separates
points inside `K_c` where no ray pair can, so the two are blind in different
places (`docs/literature-gate-2026-09-20-cut-equivalence.md`). A cut needs no verification, so an
uninformative cut is not a defective one.
Use discipline: a cut is declared data. Report the step and the cut that
decided a separation, never the bare verdict, and never say a box is "inside"
or "outside" a cut.

### Level-k non-separation

Status: novel bridge term.
Genealogy: `SameFiberLevel_k^c` of the parameter-plane program's separator
catalogue; the finite nests of `docs/J1_proof_definition.md`.
Bridge claim: no cut of a declared catalogue, at any step up to `k`, puts the
two boxes on decided opposite sides. Decreasing in `k`
(`docs/finite-separator.md` section 3).
Known leaks: it is reflexive and symmetric and **not transitive**, so it
partitions nothing and has no classes. It is relative to a declared
catalogue, so it is never a statement about the parameter alone. Two boxes
not separated may hold the same point, different points, or nothing at all.
Use discipline: always name the catalogue and the level. Never call a set of
mutually non-separated boxes a class, a component, or a fiber.

### Regime ledger

Status: novel bridge term.
Genealogy: the proof-block ledger of the parameter-plane program; the
classical classification of quadratic parameters.
Bridge claim: a generated table indexed by regime whose verified columns are
recomputed by exact arithmetic and whose tag columns name unverified imported
theorems. It records status; it promotes nothing.
Known leaks: a row is a statement about one parameter, never about its
regime. A regime is discharged by `docs/J1_proof_definition.md`, not by a row.
Use discipline: the ledger is generated. A hand edit fails the build.

### CAPPED

Status: definition-only.
Genealogy: the capped-run convention of the parameter-plane program
(`UW-2`: an exhausted budget is not a verdict).
Bridge claim: the critical orbit neither escaped nor repeated within the
stated budget, and the run names which budget ran out.
Known leaks: a capped run says nothing about boundedness. Exact iteration
doubles coordinate size per step, so `CAPPED` is the *expected* outcome for
every parabolic and irrationally indifferent parameter, not a defect.
Use discipline: never read `CAPPED` as `IN`, as `OUT`, or as evidence for
either.

## Rejected bridge claims

A claim that was named, judged, and found false. It stays here so that it
cannot be reintroduced as an open question.

### CutCatalogueRayEquivalence

Status: rejected bridge claim.
Genealogy: the separator restatement of `docs/finite-separator.md`; the
landed ray-pair catalogue of the classical fiber theory.
Bridge claim, as it was proposed: the cut catalogue separates exactly what a
landed ray-pair catalogue separates.
Verdict: **rejected**, `docs/literature-gate-2026-09-20-cut-equivalence.md`.
A ray lies in the basin of infinity, so a ray pair meets `K_c` only at its
landing point; no ray pair separates two interior points of `K_c`, and a cut
separates them at once. No weakening of the claim survives.
Use discipline: never as a hypothesis, a conditional, or a future gate. Cite
it only as a rejected claim, and only with its gate.

## Forbidden usages

- calling the quadrance-1 locus of `J_0` a circle, or deriving an arc, an
  angle, or a circumference from it;
- calling a capped run bounded or unbounded;
- calling a homogeneous coordinate record an ideal point, or evaluating one
  without naming a chart;
- placing the quadratic map on the projective completion that carries the
  circular points, where it is not a morphism;
- calling an irrationally indifferent parameter Siegel or Cremer;
- using `J1` without naming the regime it is claimed on;
- calling a set of mutually non-separated boxes a fiber, a class, or a
  component, or reporting non-separation without naming its catalogue and
  level;
- citing `CutCatalogueRayEquivalence` as anything but a rejected claim.

## Enforcement of the forbidden usages

`tools/audit_terminology.py` (`pixi run terminology`) reads this file and
scans every non-vendored `docs/*.md`, `tools/*.py`, and `src/*.mojo` for the
circle-family vocabulary of the first forbidden usage. An occurrence passes
only if it is a field term registered above, is denied in its own clause, sits
under a heading that forbids, or carries an explicit
`<!-- terminology-exempt: reason -->` marker. The bare word *angle* is not
scanned: the prohibition is on deriving an angle from the quadrance-1 locus,
not on the rational angles of `Q/Z`, which Phase 3 needs.

It also reads the rejected-claims section above and requires every mention of
a claim listed there to carry a rejection word within reach, so a claim that
was judged false cannot quietly become an open question again. That rule
caught a stale citation in `docs/permanent-non-separation.md` on its first
run.

The audit is the reason this registry is a rule rather than a note. It was
added after the vocabulary it forbids reached `docs/enclosure-width-lemma.md`
and survived every gate.
