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
parabolic parameters, and it **fails** for Cremer parameters and for Siegel
parameters of non-Brjuno rotation number. So the top-level object here is a
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

- **Escape is exactly decidable.** `N(z) > max(4, N(c))` implies escape, and
  the test is a quadrance against a rational bound: rank-2 legal, no radius,
  no square root.
- **Interior certification does not touch density of hyperbolicity.** For
  fixed hyperbolic `c` the interior of `K_c` is the union of preimages of the
  immediate basin, so `IN` is a pullback certificate from one attracting-cycle
  witness, decided exactly by `lam = 2^k prod z_j` and `N(lam) < 1`.

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
point whose Siegel-or-Cremer status turns on the Brjuno condition. Exact data,
open dynamics.

**Rational multiplier dichotomy.** A quadrance-1 element of `Q(i)` is a root
of unity exactly when it is one of `1, -1, i, -i`; the proof is section 6 of
the design analysis. So *rationally versus irrationally indifferent* is
finitely decidable on this data, while *Siegel versus Cremer* is not. The
regime ledger therefore carries a provably decidable cell next to a provably
open one, on the same parameter.

## The corpus and the ledger

`tools/parameter_corpus.py` is the single source. Nine parameters cover every
regime, each with the witness a checker needs. `tools/make_regime_ledger.py`
renders three surfaces from it -- `docs/J1_regime_ledger.md`, `corpus.json`,
and `src/parameter_corpus.mojo` -- filling the verified columns by re-running
the exact oracle, so a surface can only say what was decided or what a row
declared as an unverified tag. A hand-edited surface fails
`make_regime_ledger.py --check` rather than drifting.

Two implementations decide every row: the Mojo kernel `src/julia_orbit.mojo`
over the vendored `finite_exact` stack, and the Python reference oracle
`tools/julia_reference.py`. `tests/test_mojo_replay.py` compares their
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

## Repository layout

```text
README.md
ROADMAP.md
docs/
  julia-program-design-analysis-2026-09-19.md   why this program, and its decisions
  J1_proof_definition.md                        what J1 claims and what discharges it
  J1_finite_classical_dictionary.md             finite object <-> classical referent
  J1_regime_ledger.md                           GENERATED from tools/parameter_corpus.py
  terminology-registry.md                       declared vocabulary
  terminology-governance.md                     mirrored governance process
  rational-interval-arithmetic-spec.md          mirrored exact-arithmetic contract
src/
  julia_orbit.mojo          exact orbit, escape bound, multiplier classification
  corpus_replay.mojo        the kernel run against the corpus
  corpus_transcript.mojo    the transcript the differential test consumes
  parameter_corpus.mojo     GENERATED
  smoke_tests.mojo          the canonical Mojo smoke suite
  finite_exact/             vendored from larsbx/finite-math-kernels, pinned in vendored.toml
tools/
  gaussian_q.py             exact Gaussian-rational coordinate records
  julia_reference.py        the Python reference oracle
  parameter_corpus.py       the single source of the corpus
  make_regime_ledger.py     renders every generated surface; --check gates them
  check_vendored_sync.py    copied from the Mandelbrot repository pending extraction
tests/
corpus.json                 GENERATED
backend.toml                arithmetic backend readiness
vendored.toml               vendored digests
```

## Boundary of claims

This repository does not claim local connectivity of any Julia set, any
Brjuno or Diophantine property of any rotation number, or that any classical
statement it cites has been verified against its literature. Every classical
statement enters as a named theorem tag and is unverified until that tag's
literature gate is run. No regime is discharged.

## Status

Phase 0: scaffold, governed terminology, vendored exact arithmetic, the
parameter corpus with exactly verified witnesses, two agreeing
implementations, and the generated regime ledger.

## Verification

```bash
pixi run test            # Python suite, including the Mojo/Python differential replay
pixi run mojo-smoke      # the canonical Mojo smoke suite
pixi run ledgers-check   # generated surfaces are current
pixi run vendored        # vendored digests match their pins
```

The Mojo replay test skips where no Mojo toolchain is present; CI installs one.
