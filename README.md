# Finite-Regime Julia Set Research

This repository develops a finite, certificate-carrying formulation of
quadratic Julia set computation at exactly representable parameters. It is the
dynamical-plane companion to `larsbx/finite-mandelbrot-research`, and it
shares that program's exact-arithmetic substrate, rank-2 ontology,
theorem-tag discipline, and fail-closed doctrine.

It is not the same research question. The design argument is in:

```text
docs/julia-program-design-analysis-2026-09-19.md
```

## Why a separate program

In the parameter plane the frontier is one open conjecture. MLC can be
isolated; it cannot be closed, and the repository's priority-zero block waits
on it.

In the dynamical plane the frontier is stratified. Local connectivity of
`J_c` is a classical theorem for hyperbolic, postcritically finite, and
parabolic parameters, and it **fails** for Cremer parameters, and for parameters
with a Siegel disk whose boundary contains no critical point. So the top-level
object here is a
regime ledger, not a conjecture, and two things become available that the
parameter plane cannot offer:

1. **A test of the separator calculus against known answers.** If catalogue
   adequacy is sound it must stabilize where local connectivity is a theorem,
   and fail to stabilize where local connectivity is false. That is
   detectable now.
2. **Finite certificates of fiber non-triviality.** Where local connectivity
   fails, the honest finite object is a witness that the catalogue
   permanently fails to separate a named pair. That direction is closable.

## Core thesis

At a Gaussian-rational parameter `c`, the substrate is

```text
f_c^0(z) = z        f_c^{n+1}(z) = f_c^n(z)^2 + c        in Q(i)[z]
```

and every finite verdict is reached with integer and rational arithmetic
alone: no floats, no limits, no transcendental or trigonometric functions, no
circles as rank-2 primitives, and no analytic point primitives. Classical
conclusions enter only as named theorem tags.

Two consequences make the dynamical plane easier than the parameter plane,
and the repository states them as such rather than importing the parameter
plane's open questions:

- **Escape is exactly decidable, and now derived.** `N(z) > max(4, N(c))`
  implies escape, the test is a quadrance against a rational bound, and the
  implication is no longer an unnamed import: `docs/escape-criterion.md`
  carries a certificate with a rational growth ratio, proved with two
  polynomial forms and no square root.
- **Interior certification does not touch density of hyperbolicity.** `IN` is
  a *trap*: a box that an iterate maps strictly inside itself, verified
  directly, so no multiplier and no theorem about basins is needed
  (`docs/three-valued-classifier.md`). A parabolic parameter has no such box,
  and the classifier answers `UNKNOWN` there rather than guessing.

## Exactly representable data reaches every regime

With `z^2 + c = z` and multiplier `lam = 2z`, the parameterization
`c = lam (2 - lam) / 4` sends any `lam` in `Q(i)` of quadrance 1 to a
Gaussian-rational parameter with an indifferent fixed point. The four roots of
unity of `Q(i)` give the parabolic parameters; the Niven multiplier
`lam = (3 + 4i)/5` gives

```text
c = (37 + 16i)/100
```

an exactly representable parameter with an irrationally indifferent fixed
point. Its algebraic multiplier is Diophantine and hence Brjuno in the
classical interpretation, by
`docs/literature-gate-2026-10-06-algebraic-multiplier.md`. The accepted
linearization and Herman imports give a Siegel disk with the critical point
on its boundary. Local connectivity at this rotation number remains open.

**Rational multiplier dichotomy.** A quadrance-1 element of `Q(i)` is a root
of unity exactly when it is one of `1, -1, i, -i`; the proof is section 6 of
the design analysis. So *rationally versus irrationally indifferent* is
finitely decidable on this data. The dichotomy alone does not decide
linearizability; the separate algebraic-multiplier import does for the
irrationally indifferent rows. The regime ledger keeps the exact multiplier
class distinct from the open local-connectivity cell.

## The corpus and the ledger

`reference/parameter_corpus.py` is the single source. Ten parameters cover every
regime, each with the witness a checker needs, and they include **every**
postcritically finite parameter of `Q(i)` -- there are five, by section 3.3 of
`docs/tiling-connections-2026-09-20.md`, and `tests/test_parameter_corpus.py`
fails if the corpus holds any other number of them. `tools/make_regime_ledger.py`
renders three surfaces from it -- `docs/J1_regime_ledger.md`, `corpus.json`,
and `kernel/parameter_corpus.mojo` -- filling the verified columns by re-running
the exact oracle, so a surface can only say what was decided or what a row
declared as an unverified tag. A hand-edited surface fails
`make_regime_ledger.py --check` rather than drifting.

Two implementations decide every row: the Mojo kernel `kernel/julia_orbit.mojo`
over the vendored `finite_exact` and `quadratic_orbit` packages, and the
Python reference oracle
`reference/julia_reference.py`. `tests/test_mojo_replay.py` compares their
transcripts line for line, so neither one is the reason the other is believed.

## Fail closed, and which way closed points

Adopted from `larsbx/finite-mandelbrot-research`, which adopted the
distinction from `larsbx/native-deployment-control-plane`: for gates, failing
closed means refusing to proceed; for destructive operations, it means
refusing to delete.

| Operation | Closed means | Because |
| --- | --- | --- |
| A step or bit budget is exhausted | refuse to conclude | `CAPPED` names the budget that ran out; it is not `IN` and not `OUT` |
| A multiplier has quadrance exactly 1 | refuse to decide attracting or repelling | the indifferent case is a class, not a rounding problem |
| A generated surface disagrees with the corpus table | refuse the run | the surface is a function of the table, so disagreement is drift |
| A vendored file differs from its pin | refuse the run | a local patch to vendored code is a fork, announced or not |
| A theorem tag has no literature gate | refuse to call it verified | a named import is not a checked one |
| A pinned corpus row or transcript is to be regenerated | **refuse to overwrite** | the pinned bytes are what a reader replays |

The first five refuse to proceed; the last refuses to destroy. When a new gate
is added, say which column it is in; when it is not obvious, it is the second.

## Exact arithmetic

Every certificate-relevant number is a normalized rational or a
rational-endpoint interval, never a float. The contract is
`docs/rational-interval-arithmetic-spec.md`, the canonical copy from
`larsbx/finite-math-kernels`; this repository's binding table is
`docs/exact-arithmetic-binding.md`, one row per module that instantiates a
layer, and `tools/audit_exact_arithmetic.py` enforces both. An arithmetic
consumer with no binding row fails the build, as does a bound module that does
not cite the specification, a decimal literal in the kernel scope, and a
quarantine that is not allowlisted or an allowlist entry that is not
quarantined. The allowlist is empty: this repository has never had a
floating-point substrate.

## Terminology

`docs/terminology-registry.md` says which words this repository may use and
which it may not. Until now it said so only to readers: the executable check
banned the circle family as *identifiers* and never read a sentence, so the
phrase "the unit circle" reached `docs/enclosure-width-lemma.md` and passed
every gate. `tools/audit_terminology.py` closes that. It scans the prose and
comments of every non-vendored document and source file, and an occurrence of
the circle family passes only if it is a field term registered in the
registry, is denied by the clause it sits in, sits under a heading that
forbids, or carries an explicit `<!-- terminology-exempt: reason -->` marker.
Literature gates, which quote classical statements verbatim, are scanned as
the classical layer they declare themselves to be. The engine is the vendored
`lexical_audit` package; the policy is this repository's.

## References

Prose names files and tasks, and a renamed file leaves the sentence behind.
`tools/check_references.py` reads every tracked text file, collects backticked
paths and `pixi run` phrases, and fails the build on one that resolves to
nothing. A reference that lives in another repository is attested by a
sentence naming that repository rather than exempted. The engine is the
vendored `references` package; the policy is this repository's.

## Repository layout

```text
README.md
ROADMAP.md
docs/
  julia-program-design-analysis-2026-09-19.md   why this program, and its decisions
  J1_proof_definition.md                        what J1 claims and what discharges it
  J1_finite_classical_dictionary.md             finite object <-> classical referent
  J1_regime_ledger.md                           GENERATED from reference/parameter_corpus.py
  literature-gate-2026-09-19.md                 the tags, judged
  literature-gate-2026-09-19-transfer.md        the filled-Julia transfer, judged
  exact-arithmetic-binding.md                   this repository's binding table
  escape-criterion.md                           escape, derived rather than imported
  three-valued-classifier.md                    the box certificates and their soundness
  enclosure-width-lemma.md                      the width bound, and completeness
  classifier-census.md                          GENERATED: how a grid comes out per parameter
  projective-completion-and-escape.md           where escape meets the algebra
  terminology-registry.md                       declared vocabulary
  terminology-governance.md                     mirrored governance process
  rational-interval-arithmetic-spec.md          mirrored exact-arithmetic contract
kernel/                     canonical Mojo executable
  julia_orbit.mojo          orbit verdicts, cycle checks, multiplier classification
  box_classifier.mojo       OUT, IN and UNKNOWN over boxes
  enclosure_bound.mojo      how far an enclosure drifts from its orbit
  corpus_replay.mojo        the kernel run against the corpus
  corpus_transcript.mojo    the transcript the differential test consumes
  parameter_corpus.mojo     GENERATED
  smoke_tests.mojo          the canonical Mojo smoke suite
reference/                  Python reference semantics, never an acceptance path
  gaussian_q.py             exact Gaussian-rational coordinate records
  julia_reference.py        the Python reference oracle
  parameter_corpus.py       the single source of the corpus
  box_classifier.py         the classifier and adaptive refinement, Python side
  enclosure_bound.py        the width bounds, Python side
  escape_certificate.py     the escape derivation, Python side
oracles/
  parabolic_index.py        research oracle; accepts nothing
vendor/                     pinned in vendored.toml; never edited here
  mojo/                     Mojo include root (-I vendor/mojo)
    finite_exact/           vendored from larsbx/finite-math-kernels
    quadratic_orbit/        the orbit of z^2 + c, its escape test and certificate, the multiplier trichotomy, same upstream
    mojo_smoke/             the smoke reporter, same upstream
  python/
    references/             the reference-check engine, same upstream
    vendoring/              the vendoring checker, same upstream
    closed_interval/        exact rational boxes and dyadic rounding, same upstream
    exact_arithmetic_audit/ the spec section 7 audit engine, same upstream
    lexical_audit/          the terminology audit engine, same upstream
    claim_governance/       the lexer both audit engines use, same upstream
    polyglot_envelope/      renders .polyglot/ from polyglot.manifest.toml, same upstream
tools/
  make_regime_ledger.py     renders every generated surface; --check gates them
  audit_exact_arithmetic.py the binding-table and no-float policy (vendored engine)
  audit_terminology.py      the rank-2 vocabulary policy (vendored engine)
  check_references.py       this repository's reference policy
tests/
ESTATE.toml                 estate manifest; audited from a pinned larsbx/estate-governance
corpus.json                 GENERATED
backend.toml                arithmetic backend readiness
vendored.toml               vendored digests
```

## Boundary of claims

This repository does not prove local connectivity or analytic linearization
internally. The algebraic-multiplier gate accepts the named classical imports
above; those conclusions do not become finite-core verdicts. Every classical
statement enters only through its stated literature-gate boundary. Local
connectivity at `niven`, residual-measure completeness, and a quantitative
rotation-domain `IN` certificate remain open obligations. No regime is
discharged.

## Status

Phase 0: scaffold, governed terminology, vendored exact arithmetic, the
parameter corpus with exactly verified witnesses, two agreeing
implementations, and the generated regime ledger. Phase 1: the escape
criterion, the three-valued box classifier, the enclosure-width lemma and the
refinement theorem. Phase 2, first rung: preperiodic certificates on
`R^c_{l,k} = f^{l+k} - f^l`, by exclusion and by the Krawczyk hypothesis
(`docs/preperiodic-certificates.md`).

## Verification

```bash
pixi run test            # Python suite, including the Mojo/Python differential replay
pixi run mojo-smoke      # the canonical Mojo smoke suite
pixi run ledgers-check   # generated surfaces are current
pixi run vendored        # vendored digests match their pins
pixi run exact-arithmetic  # every arithmetic consumer is bound and exact
pixi run references      # every path and task a document names resolves
pixi run terminology     # the registry's forbidden usages, in prose as well as code
```

The Mojo replay test skips where no Mojo toolchain is present, so a run that
reports it skipped has checked only one of the two implementations.
