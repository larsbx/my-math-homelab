# Finite-Regime Mandelbrot Research

**Canonical repository:** `larsbx/finite-mandelbrot-research` is the sole active development home for the finite-regime Mandelbrot research program. The former `larsbx/NLAP-JT` repository is historical; migration provenance and cutover details are recorded in `MIGRATION.md`.

This repository develops a finite, certificate-carrying formulation of Mandelbrot-set computation.

The authoritative definition of the quadratic family, its marked critical
orbit, the critical-orbit polynomials, and the classical Mandelbrot parameter
locus is `docs/mandelbrot-defining-family.md`. In particular, the defining
object is the family `f_c(z) = z^2 + c` with marked critical point zero;
the finite-field and projective-multiset layers are typed shadows of that
family, not alternative definitions of the Mandelbrot set.

Multisets remain a first-class research tool. The current bridge program in
`docs/multiset-bridge-program.md` begins with integral critical-orbit divisors,
good-reduction and lifting certificates, and characteristic-zero localization;
it also isolates the additional theorem needed to connect basin-cardinality
weights to that algebraic route.

### Current algebraic multiset milestone

For the marked critical orbit (Q_0(C)=0),
(Q_{n+1}(C)=Q_n(C)^2+C), define the return polynomial

```text
A_{ell,k}(C) = Q_{ell+k}(C) - Q_ell(C).
```

The executable certificate for (A_{4,1}) now verifies the factorwise
exact-type refinement over `Z[C]`. The cubic factor
`C^3+2C^2+2C+2` belongs to the earlier collision `Q_4-Q_3`, while

```text
D^{exact}_{4,1} = div_0(F_7)
```

has seven distinct algebraic roots of exact critical-orbit type `(4,1)`.
Exact integer division establishes factor membership. Reduction modulo 5 is
used only for squarefreeness and coprimality witnesses, including exclusion of
every unintended collision through the required horizon.

This is an algebraic divisor certificate, not a localization certificate. It
does not choose a complex embedding, produce a B3 root handle, or prove
density, equidistribution, MLC, or C1. The implementation is
`kernel/mojo/dynamics/r41_algebraic_root_certificate.mojo`; the complete
bridge boundary is recorded in `docs/multiset-bridge-program.md`.

The project goal is not to replace the classical analytic Mandelbrot set with a false finite exact object. Instead, it formalizes a hierarchy of finite algebraic certificates that reproduce the observable content available at finite resolution while isolating the single generic-boundary obstruction as MLC / fiber triviality.

## Priority-zero conjecture

The source of truth for what would prove C1 is:

```text
docs/C1_proof_definition_and_priority.md
```

C1 proof work is `PRIORITY_ZERO`. A completion claim must establish every required proof block in that document and supply a finite proof object checked by the Mojo theorem kernel. The current highest-priority open block is:

```text
ResidualClosureNoMissingLinks
```

A final C1 proof may not leave a `MissingTheoremCatalogueLink` exit open.

## Core thesis

A Mandelbrot generator can be specified without primitive reliance on real numbers, analytic complex-number objects, limits, transcendental functions, trigonometric functions, circles as rank-2 primitives, or infinite series by using:

- integer polynomial critical-orbit recurrences;
- dyadic rational boxes as finite interval objects;
- squarefree polynomial localization;
- pointwise exact-type exclusions;
- symbolic rational ray-address combinatorics;
- rank-2 coordinate records for executable algebra;
- finite incidence objects instead of analytic point primitives;
- named external theorem dependencies for analytic landing/fiber results.

## Mojo-first implementation and theorem-kernel policy

Mojo is the default first-class language for executable finite computations, certificate encodings, and finite proof-object checking in this repository. Python remains acceptable for CI linting, reference oracles, and migration scaffolds, but Mojo owns the primary certificate kernels once a Mojo implementation exists.

Mojo code should prioritize:

- value-like structs with explicit fields;
- normalized integer/rational representations;
- allocation-light polynomial and interval kernels;
- Horner evaluation for polynomial computations;
- batchable catalogue and interval scans;
- explicit backend boundaries for arbitrary-precision integers;
- separation of debug/demo paths from proof-grade paths.

Mojo is the trusted finite theorem kernel for repository proof objects. Classical analytic conclusions require explicit theorem-tag imports and adapter lemmas; Mojo does not silently reprove imported analytic theorems.

## Current mathematical focus

The current research focus is C1, now phrased as separator catalogue adequacy plus the residual fiber-triviality frontier:

```text
SeparatorCatalogueSoundness:
  Separated_k(A,B) -> ClassicallySeparated(A,B)

SeparatorCatalogueCompleteness:
  ClassicallySeparated(A,B) -> exists k. Separated_k(A,B)

SeparatorCatalogueAdequacy:
  soundness + completeness
```

After adequacy, persistent finite non-separation presents the classical same-fiber relation on the covered domain. Therefore any theorem that eliminates all distinct persistent non-separation has fiber-triviality / MLC strength under global coverage. The repository marks this as `OPEN_FRONTIER`, not as solved.

## Rank-2 layer rule

At the rank-2 certificate layer, the available objects are coordinate records, coefficient operations, polynomial operations, polynomial predicates, and quadrance scalars.

The following are not primitive constructors, APIs, or inference rules at rank 2:

- circle;
- disk;
- arc;
- circumference;
- polar angle;
- connected component;
- interior;
- boundary;
- analytic locus.

Such concepts require an explicit higher-layer adapter and cannot be imported merely from the polynomial expression `Q(x,y)=x^2+y^2`.

## Exact arithmetic policy

Every certificate-relevant number is a normalized rational or a rational-endpoint interval, never a float. The contract, its conformance criteria, and the binding of each kernel module to it are in:

```text
docs/rational-interval-arithmetic-spec.md
```

That file is mirrored verbatim in the PSC research repository and is enforced here by `tools/audit_exact_arithmetic.py`, the `tools/exact_arithmetic_allowlist.md` quarantine list, the `backend.toml` policy keys, and the law tests in `kernel/mojo/smoke/smoke_tests.mojo` and `tests/test_exact_arithmetic_spec.py`.

## Fail closed, and which way closed points

"Fail closed" appears throughout this repository as though it had one meaning.
It has two, and they point opposite ways. `larsbx/native-deployment-control-plane`
is the repository in this estate that says so, and this section adopts its
distinction rather than reaching it independently:

> For deploy gates, failing closed means refusing to proceed. For a destructive
> operation, failing closed means refusing to delete. Uncertainty is never
> resolved in favour of deletion.

Sorted by effect, not by name:

| Operation | Closed means | Because |
| --- | --- | --- |
| A prefix-graph or catalogue cap is reached | refuse to conclude | an exhausted budget is not a verdict; a capped run reports as capped (`UW-2`) |
| A separator is not admissible | refuse to measure | an unproved cut reported as a decided measure is worse than no measure |
| A rejected exact value enters an arithmetic chain | refuse and stay rejected | rejection is sticky, so a doubtful number cannot be laundered by later operations |
| A generated surface disagrees with `proof/c1/records.toml` | refuse the run (`make_ledger.py --check`) | the surface is a projection of the declarative proof state, so disagreement is drift, not a new fact |
| A proof block is to be demoted or a tag withdrawn | **refuse to demote** | the block stays in the ledger with its status visible; an uncertain withdrawal removes the record the doubt was about |
| A pinned certificate or reference transcript is to be regenerated | **refuse to overwrite** | the pinned bytes are what a reader replays; a doubtful regeneration destroys the evidence rather than the doubt |

The first four refuse to *proceed*. The last two refuse to *destroy*, and a
rule that only knew the word would have had them delete. When a new gate is
added, say which column it is in; when it is not obvious, it is the second,
because that is the direction that cannot be undone.

What fails closed is the *uncertain* case. A demotion or a regeneration whose
evidence is clear is a deliberate, attributable act, and this rule does not
stand in its way.

## Repository layout

```text
README.md
ARCHITECTURE.md
ESTATE.toml
ROADMAP.md
docs/
  mandelbrot-defining-family.md
  multiset-bridge-program.md
  C1_proof_definition_and_priority.md
  alignment_audit_deep_research_findings.md
  mojo_first_execution_policy.md
  terminology-governance.md
  terminology-registry.md
  terminology-use-manifest.md
  finite-certificate-calculus.md
  rational-interval-arithmetic-spec.md
  atlas-dataset.md
  literature-notes.md
  C1_*.md
examples/
  misiurewicz-c-minus-2.md
  stress-test-m41.md
reference/
  python/                     # non-authoritative independent semantics
    arithmetic/
    polynomial/
    interval/
    c1/
kernel/mojo/                 # canonical Mojo; include roots -I kernel/mojo -I vendor/mojo
  c1/                        # the C1 proof track
    bridge/ separator/ carrier/ residual/ wake/ theorem_tags/ proof/
  arithmetic/ polynomial/ dynamics/
  certificates/              # finite certificate calculus
    c_minus_2/               # the checked c = -2 path
  theorem_kernel/ smoke/
  entrypoints/               # atlas_dataset.mojo (pixi run atlas-dataset), critical_type_sieve.mojo (pixi run type-sieve), run_examples.mojo
vendor/                      # pinned in vendored.toml; never edited here
  mojo/                      # finite_exact/, finite_polynomial/, substitution_dynamics/, finite_field_orbit/, mojo_smoke/, quadratic_orbit/, rational_dynamics/, angle_doubling/ from larsbx/finite-math-kernels
  python/                    # claim_governance/, proof_records/, oracle_refinement/, vendoring/, exact_arithmetic_audit/, closed_interval/, polyglot_envelope/, same upstream
proof/
  c1/
    records.toml              # canonical C1 claim/proof state
    README.md
    models/tla/
      ProofArchitecture.tla   # vendored dependency state machine
      Ledger.tla, MCLedger*   # generated from ledger.json
experiments/julia/           # disposable Julia spikes
schemas/                     # regime correspondences
tools/
  *_reference.py              # compatibility shims only; semantics live in reference/python
  *_oracle.py                 # compatibility shims only where retained
  audit_*.py
  exact_arithmetic_allowlist.md
  mojo_include.py            # the Mojo include roots, for every Python call site
  make_ledger.py             # validates records.toml and renders every ledger surface
tests/
  test_*.py
claim_governance.toml        # repository policy for the vendored audit
ledger.json                  # serialized proof-record projection; generated
```

`claim_governance.toml` restates the terminology, no-trigonometry, no-points,
rank-2 locus, and paper-language rules as configuration for the vendored
`vendor/python/claim_governance` package. Its `[[claim]]` block is no longer written by
hand: `proof/c1/records.toml` is the single source of the C1 proof-block statuses, and the Mojo mirror
`kernel/mojo/c1/proof/final_proof_block_ledger.mojo`, the block table of
`docs/C1_final_proof_block_ledger.md`, the claim entries, the index
`docs/C1_ledger_index.md`, the TLA+ ledger with its TLC models, and the typed
relationship graph `docs/C1_claim_relationship_graph.json` are all rendered
from it through `tools/make_ledger.py` (`pixi run ledgers`). Whether the final object *requires* a block is the dependency edge `C1 -> block`, not a field anyone sets. CI runs
`tools/make_ledger.py --check` beside the audit, so a hand-edited surface fails
the build rather than drifting. The `tools/audit_*.py` scripts remain the
executable record of the same rules until they are retired.

## Boundary of claims

This project does not claim an unconditional finite co-landing certificate for generic Mandelbrot boundary points. For generic boundary points, finite certificate streams can be produced, but their singleton stabilization is exactly the MLC/fiber-triviality frontier unless a new proof is supplied.

No finite bounded search, renderer, numerical picture, local carrier refinement, or terminology declaration proves C1 by itself.

## Status

Active research kernel with enforced terminology, rank-2 ontology, C1 proof-status gates, a Mojo-first executable certificate policy, and a Mojo finite theorem-kernel boundary. The multiset bridge currently includes the certified seven-root exact-type divisor `D^{exact}_{4,1} = div_0(F_7)`; embedding selection and localization remain open.
