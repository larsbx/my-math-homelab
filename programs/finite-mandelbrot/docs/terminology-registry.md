# Terminology Registry

Status: controlled vocabulary registry.

Machine-readable analytic-to-finite mappings and their executable bindings are
normative in `schemas/regime_correspondences.toml`. This prose registry governs
readable mathematical terminology; the correspondence specification governs
which properties an implementation may inherit from an analytic concept.

This registry exists so the research program does not drift into private jargon. Mathematical language should be recognizable in the field. Project-specific names are allowed only when their status is explicit.

## Established field terms

These terms may be used without a project terminology declaration, provided they are used in their ordinary field sense:

- Mandelbrot set
- Mandelbrot local connectivity
- MLC
- fiber
- trivial fiber
- rational external ray
- parameter ray
- landing
- Misiurewicz parameter
- parabolic parameter
- hyperbolic component
- wake
- kneading sequence
- orbit portrait
- cyclic order
- dyadic box
- interval arithmetic
- Krawczyk method
- squarefree polynomial
- rational address
- doubling map
- quadrance
- spread
- incidence relation
- vertex
- theorem tag

## Project terms with declarations

### PointVertex

Terminology declaration: `PointVertex` is a project term for a finite incidence object whose carrier is a finite set of vertices.

Genealogy: It comes from incidence-geometry language and the user's project rule that a point is a vertex of vertices. It is not the analytic point of complex dynamics.

Bridge claim: Definition-only project term. It is not claimed to be isomorphic to a classical point.

Known leaks: A classical point can carry topological and analytic structure; `PointVertex` carries only finite incidence data. It cannot by itself express neighborhoods, connectedness, metric distance, or local connectivity.

Use discipline: Use only for finite certificate carriers such as root handles, ray-address sets, and dyadic boxes. Do not use as an analytic singleton.

### rank-2 coordinate record

Terminology declaration: A rank-2 coordinate record is a finite pair `(x,y)` with polynomial operations such as `(x,y) star (u,v) = (xu-yv, xv+yu)`.

Genealogy: It is inherited from coordinate algebra for the quadratic family and from rational-trigonometry style use of quadrance and spread. It is also the finite-regime replacement for informal complex-number language inside the certificate core.

Bridge claim: Conditional formal translation, not an ontological identification. Classical complex arithmetic can be translated into rank-2 polynomial arithmetic for the operations used in certificates.

Known leaks: The record does not supply analytic topology, limits, circles, disks, arcs, arguments, or measured angles. At rank 2, a circle is undefined; `Q(x,y)=r` is only a polynomial constraint unless lifted to a higher incidence/constraint layer.

Use discipline: Use for polynomial recurrence, quadrance, determinant, spread, and operator matrices only.

### finite rational-ray nest

Terminology declaration: A finite rational-ray nest is a finite prefix of certified rational-ray separator data around incidence objects.

Genealogy: It is derived from Schleicher-style fiber definitions using rational rays and separation, plus finite certificate and interval-refinement practice.

Bridge claim: Conditional bridge theorem target. Under `SeparatorCatalogueAdequacy`, the finite stream of separator prefixes matches the classical rational-ray separation relation.

Known leaks: A finite prefix is not a classical fiber. Absence of separation in one prefix does not prove same fiber. Stabilization of all prefixes requires an additional global argument with MLC-strength unless restricted to established cases.

Use discipline: Use only with an explicit prefix level or stream-level quantifier.

### SeparatorCatalogueAdequacy

Terminology declaration: `SeparatorCatalogueAdequacy` is the project term for the two-sided bridge between finite separator-catalogue prefixes and the classical rational-ray separation relation used in fiber theory.

Genealogy: It packages standard rational-ray separation, wake combinatorics, orbit portraits, kneading data, and finite rational-address encodings. It replaces the deprecated phrase `catalogue extensionality`.

Bridge claim: Conditional bridge theorem. It follows only from separate proofs of `SeparatorCatalogueSoundness` and `SeparatorCatalogueCompleteness`.

Known leaks: Adequacy of the separator catalogue does not prove all fibers are trivial. It does not prove local connectivity, puzzle-piece shrinkage, a priori bounds, or MLC. It only aligns the finite separation predicate with the classical separation predicate.

Use discipline: Use for the two-sided bridge. Use `SeparatorCatalogueSoundness` for finite-to-classical and `SeparatorCatalogueCompleteness` for classical-to-finite. Do not use it as evidence that C1 is solved.

### persistent non-separation

Terminology declaration: Persistent non-separation is the meta-level condition `forall k, not Separated_k(A,B)`.

Genealogy: It comes from the classical definition of fibers as equivalence classes under non-separation by rational rays, translated through separator-catalogue prefixes.

Bridge claim: Conditional bridge theorem target, not a finite computation. It becomes classical same-fiber only after `SeparatorCatalogueAdequacy` is proved and invoked.

Known leaks: No bounded search establishes it. It does not imply singleton fibers, local connectivity, or C1 by itself.

Use discipline: Always state the universal-prefix quantifier. Never use it as a synonym for same fiber unless the needed bridge theorem is explicitly invoked.

### persistent wake ambiguity

Terminology declaration: Persistent wake ambiguity is a structured obstruction candidate extracted from persistent non-separation when unresolved wake-side evidence appears cofinally.

Genealogy: It comes from wake decompositions in parameter-space combinatorics and the project’s finite side-assignment witnesses.

Bridge claim: Proof-route abstraction, not an established field term or theorem.

Known leaks: Wake ambiguity may be an artifact of incomplete separator catalogues, missing landing tags, or inadequate side-witness extraction. It must not be treated as a classical obstruction until those alternatives are discharged.

Use discipline: Use only inside F1 obstruction extraction and WakeAmbiguityElimination documents.

### Mojo theorem kernel

Terminology declaration: `Mojo theorem kernel` is the project term for a small trusted checker for finite proof objects, rule applications, and certificate derivations written in Mojo.

Genealogy: It follows LCF-style proof-kernel discipline and proof-carrying certificate systems, but is specialized to this repository's finite algebraic and combinatorial proof objects.

Bridge claim: Definition-only project architecture with a future implementation target. It does not make Mojo a replacement for classical complex-dynamics literature. External analytic theorems enter only as explicit theorem tags or axioms with source metadata.

Known leaks: The kernel can check finite derivations encoded in its rule set. It cannot by itself prove analytic landing theorems, MLC, puzzle shrinkage, a priori bounds, or fiber triviality for generic boundary parameters.

Use discipline: Use Mojo as the first-class computation language and the first-class finite proof-object checker. Do not treat an unchecked theorem tag as a proved internal theorem.

### residual directive carrier

Terminology declaration: `residual directive carrier` is the project term for a finite list of renormalization levels, each an exact periodic rational ray address with the tuning pattern (0/1 kneading prefix and twist) it determines; its kneading prefix is the star product of the levels' patterns (`docs/C1_residual_directive_carrier.md`).

Genealogy: It joins the C1 carrier vocabulary to the directive-sequence vocabulary of S-adic substitution dynamics, through the Douady–Hubbard tuning operator written on kneading sequences.

Bridge claim: Definition-only project term. The identification of a level's substitution with tuning on kneading sequences is the scaffolded theorem tag `TuningKneadingSubstitution`.

Known leaks: It carries dynamical-plane combinatorics only; parameter-plane shrinking needs a priori bounds. Levels compare by address, not by component. Agreement to every finite depth restates the persistent non-separation frontier.

Use discipline: Use in C1 files or with a pointer to this registry. Never as evidence of same-fibre membership.

### separated-pair density

Terminology declaration: the `separated-pair density` of a finite separator-catalogue prefix is the exact rational measure of the pairs of external angles that the prefix's rational cut addresses place in different arcs, `1 - sum_j |I_j|^2` for the arcs `I_j` the distinct cuts induce (`docs/C1_separated_pair_density.md`).

Genealogy: It is the product-measure form of the standard coincidence probability of a finite partition, and the parameter-space counterpart of the common fraction `f_m` of the balanced-pair overlap route in `larsbx/pisot-substitution-conjecture-research`.

Bridge claim: Definition-only project term, computed exactly over unbounded rationals. The measure is Lebesgue measure on external angles; identifying it with harmonic measure on the boundary of `M` is the scaffolded theorem tag `HarmonicMeasureAlmostEveryFibreTrivial`.

Known leaks: A density approaching one would make the undecided pairs null, never empty. It says nothing about any named pair, gives no bound on the limit from any finite prefix, and is not a fibre-triviality or local-connectivity statement.

Use discipline: Use in C1 files or with a pointer to this registry, and only for the measure of a prefix. Never as evidence that a particular pair is separated.

### exact-type catalogue

Terminology declaration: the `exact-type catalogue` of type `(l, k)` is the finite set of rational ray addresses whose exact preperiod under doubling is `l` and whose exact period is `k`, enumerated over the common denominator `2^l (2^k - 1)` (`docs/C1_misiurewicz_catalogue.md`).

Genealogy: Misiurewicz parameters with their exact preperiod and period are standard in complex dynamics, and reading both off the denominator of a rational external angle is the standard symbolic fact about the doubling map. The catalogue names the finite set, not a new invariant.

Bridge claim: Definition-only project term. The catalogue holds finite symbolic addresses. Associating a parameter with an address needs a landing tag and an adapter, and triviality of the corresponding fibres is the imported tag `KnownTrivialFiberClass`.

Known leaks: A catalogue is finite and bounded by construction; an exhausted small type says nothing about a larger one, and the counting identity is exact arithmetic rather than evidence about the parameter plane.

Use discipline: Use in C1 files or with a pointer to this registry, and only for sets of addresses. Never as a statement that a parameter is located or a fibre decided.

### prefix obstruction

Terminology declaration: a `prefix obstruction` of a separator prefix is a sink component of the pairs of ray addresses that no iterate of doubling separates (`docs/C1_misiurewicz_prefix_graph.md`).

Genealogy: It is the recurrent-core normal form the Pisot overlap route extracts from its overlap graph, and abstractly the finite obstruction object route F1 asks for. A backward productivity fixpoint followed by sink components is standard graph theory.

Bridge claim: Definition-only project term. It is a statement about one finite prefix graph, not about any parameter and not about any fibre. The boundary and interior kinds are the aligned and strict-zipper cases of the overlap route.

Known leaks: One prefix is not every prefix; an empty obstruction set at a prefix says nothing about a finer one, and persistent non-separation quantifies over all of them. A refusal at the bound is not an empty obstruction set.

Use discipline: Use in C1 files or with a pointer to this registry, and only for sink components of one named prefix. Never as a statement that a parameter is located, a fibre decided, or C1 settled.

## Deprecated project terms

- `catalogue extensionality`: deprecated. Use `SeparatorCatalogueAdequacy`, `SeparatorCatalogueSoundness`, or `SeparatorCatalogueCompleteness`.

## Banned rank-2 locus language

At rank 2, do not use the following as primitives:

- circle
- unit circle
- disk
- arc
- circumference
- point locus
- angular coordinate
- polar coordinate

Allowed replacement language:

- polynomial constraint
- quadrance equation
- finite incidence carrier
- higher-rank constraint object
- rational address interval

## Novel bridge checklist

Any new term claiming to connect two fields must include the five headings:

1. `Terminology declaration`
2. `Genealogy`
3. `Bridge claim`
4. `Known leaks`
5. `Use discipline`

Any phrase such as `isomorphic to`, `equivalent to`, `same as`, `analogue of`, or `bridge between` must state whether it is:

- theorem-backed;
- conditional on named lemmas;
- definition-only;
- analogy/metaphor.

## Executable correspondence tags

Public Mojo types and functions implementing an analytic-to-finite translation
must carry an immediately preceding `# Regime correspondence: <registry-id>`
tag. The identifier must exist in `schemas/regime_correspondences.toml`, whose
entry must bind the exact `path::symbol`.

A tag grants only the properties listed under `preserves`; every item under
`does_not_inherit` remains unavailable. Shared terminology, notation, or
genealogy never transfers an unstated theorem.
