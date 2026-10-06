<!--
Derived from templates/docs/AGENTS.md in larsbx/agent-icm @ sha256:e0ea75600e3d136a
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

# Agent policy — finite-julia-set-research

A finite, certificate-carrying formulation of quadratic Julia set computation
at exactly representable (Gaussian-rational) parameters: the dynamical-plane
companion to finite-mandelbrot-research, organized as a regime ledger rather
than one conjecture.

**Language / toolchain:** Mojo 1.0.0 (canonical, `kernel/`) with a Python reference oracle
  (`reference/`), under pixi
**CI:** GitHub Actions: `ci.yml`, one `audit` job: the pinned estate audit, then the
  Mojo build, vendored digests, Mojo smoke suite, exact-arithmetic, reference,
  terminology, ledger and polyglot audits, the full tests, and the vendored
  digests again

This file is for whoever is working here next, human or otherwise. It states
what is settled, so that it does not get re-litigated by someone reading only
the code.

## Read first

- `ESTATE.toml`
- `ARCHITECTURE.md`
- `README.md`
- `ROADMAP.md`
- `docs/julia-program-design-analysis-2026-09-19.md`
- `docs/J1_proof_definition.md`
- `docs/rational-interval-arithmetic-spec.md`
- `docs/exact-arithmetic-binding.md`
- `docs/terminology-registry.md`
- `vendored.toml`

## Gates

Before proposing a change as finished, run:

1. the canonical Mojo smoke binary builds —

   ```sh
   pixi run mojo-build
   ```

2. vendored packages still match their pins —

   ```sh
   pixi run vendored
   ```

3. the canonical Mojo finite-core smoke suite —

   ```sh
   pixi run mojo-smoke
   ```

4. every arithmetic consumer is bound and exact —

   ```sh
   pixi run exact-arithmetic
   ```

5. every path and task a document names resolves —

   ```sh
   pixi run references
   ```

6. the terminology registry's forbidden usages, in prose as well as code —

   ```sh
   pixi run terminology
   ```

7. generated surfaces (regime ledger, corpus, Mojo corpus) are current —

   ```sh
   pixi run ledgers-check
   ```

8. the polyglot envelope is the rendering of its vendored template —

   ```sh
   pixi run polyglot-check
   ```

9. full tests, including the Mojo/Python differential replay —

   ```sh
   pixi run test
   ```

Report honestly which ran. A partial environment that reports a skip is worth
more than one that passes vacuously.

## What this repository treats as evidence

- Two implementations decide every corpus row: the Mojo kernel
  `kernel/julia_orbit.mojo` over the vendored packages, and the Python
  reference oracle `reference/julia_reference.py`. `tests/test_mojo_replay.py`
  compares their transcripts line for line. The replay skips where no Mojo
  toolchain is present, and a run that reports that skip has checked only one
  of the two.
- Classical conclusions enter only as named theorem tags, each judged by a
  literature gate under `docs/`. A tag with no literature gate is not called
  verified.
- Every certificate-relevant number is a normalized rational or a
  rational-endpoint interval. Each module that instantiates an arithmetic
  layer has a row in `docs/exact-arithmetic-binding.md`, and
  `tools/audit_exact_arithmetic.py` fails the build on an unbound consumer.
- The regime ledger, the classifier census, `corpus.json` and
  `kernel/parameter_corpus.mojo` are generated from
  `reference/parameter_corpus.py` by `tools/make_regime_ledger.py`. `--check`
  is what proves they are current.
- Vendored packages are pinned per file in `vendored.toml`, and the
  `finite-math-kernels` pin in `ESTATE.toml` is derived from it by the
  vendored checker.

## Standing prohibitions

- Never use a float for a certificate-relevant number: rationals and
  rational-endpoint intervals only (README, Exact arithmetic). The allowlist
  is empty.
- Never edit anything under `vendor/`. A vendored file that differs from its
  pin refuses the run; change it upstream in `larsbx/finite-math-kernels`,
  re-vendor and re-pin (README, fail-closed table and Repository layout).
- Never hand-edit a generated surface (`docs/J1_regime_ledger.md`,
  `docs/classifier-census.md`, `corpus.json`, `kernel/parameter_corpus.mojo`).
  Edit `reference/parameter_corpus.py` and regenerate with `pixi run ledgers`.
- Never overwrite a pinned corpus row or transcript: the pinned bytes are what
  a reader replays (README, fail-closed table).
- Never call a theorem tag verified without its literature gate, and never let
  a classical conclusion become a finite-core verdict (README, Boundary of
  claims).
- Never treat `reference/` as an acceptance path. It is reference semantics;
  `kernel/` is the one canonical executable (ARCHITECTURE.md).
- Never use the circle family as a rank-2 primitive or in ungoverned prose. An
  occurrence passes `tools/audit_terminology.py` only as a registered field
  term, a denial, under a forbidding heading, or with an explicit
  `terminology-exempt` marker.
- Never let a directory rename alone change claim status, acceptance, or
  authority (ARCHITECTURE.md).

## Scope discipline

- Make the change that was asked for. If the surrounding code is wrong in a way
  the task did not name, say so — do not widen the diff to fix it.
- If something is blocked, finish everything that is not, and say precisely what
  was left and why.
- Where a decision is already recorded, follow it or reopen it explicitly. Do
  not route around it in code.
