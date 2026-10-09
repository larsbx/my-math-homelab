<!--
Derived from templates/docs/AGENTS.md in larsbx/agent-icm @ sha256:e0ea75600e3d136a
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

# Agent policy — finite-mandelbrot-research

A finite, certificate-carrying formulation of Mandelbrot-set computation:
integer critical-orbit polynomials, dyadic rational boxes and rank-2
coordinate records, with the C1 separator-adequacy conjecture as priority
zero.

**Language / toolchain:** Mojo 1.0.0 (canonical theorem kernel, `kernel/mojo/`) with Python reference
  oracles and audits, under pixi; a TLA+ ledger model
**CI:** GitHub Actions: `no-trig-audit.yml`, one job per authority plane: `policy`
  (the pinned estate audit, vendored digests, polyglot envelope, claim
  governance, backend manifest, terminology), `kernel` (Mojo build and smoke,
  no-trig, no-points and exact-arithmetic audits), `proof` (generated ledger
  surfaces), `reference` (property oracle and reference checks), `paper`
  (manuscript claim language), then `integration` (full tests)

This file is for whoever is working here next, human or otherwise. It states
what is settled, so that it does not get re-litigated by someone reading only
the code.

## Read first

- `ESTATE.toml`
- `ARCHITECTURE.md`
- `README.md`
- `MIGRATION.md`
- `docs/C1_proof_definition_and_priority.md`
- `docs/mandelbrot-defining-family.md`
- `docs/rational-interval-arithmetic-spec.md`
- `claim_governance.toml`
- `proof/c1/records.toml`
- `vendored.toml`

## Gates

Before proposing a change as finished, run:

1. vendored packages still match their pins —

   ```sh
   pixi run vendored
   ```

2. the polyglot envelope is the rendering of its vendored template —

   ```sh
   pixi run polyglot-check
   ```

3. governed theorem and claim usage (CI sets `PYTHONPATH: vendor/python`) —

   ```sh
   PYTHONPATH=vendor/python python3 -m claim_governance.cli --root .
   ```

4. backend manifest and proof-grade boundary —

   ```sh
   python3 tools/audit_backend_manifest.py
   ```

5. governed terminology —

   ```sh
   python3 tools/audit_terminology.py
   ```

6. the canonical Mojo smoke binary builds —

   ```sh
   pixi run mojo-build
   ```

7. the canonical Mojo finite-core smoke suite —

   ```sh
   pixi run mojo-smoke
   ```

8. no forbidden analytic primitives in the executable core —

   ```sh
   python3 tools/audit_no_trig.py
   ```

9. no forbidden analytic point APIs in the executable core —

   ```sh
   python3 tools/audit_no_points.py
   ```

10. the exact-arithmetic boundary —

   ```sh
   python3 tools/audit_exact_arithmetic.py
   ```

11. generated ledger surfaces are current (Mojo mirror, block table, claims,
   index, TLA+, graph) —

   ```sh
   python3 tools/make_ledger.py --check
   ```

12. exact-arithmetic property oracle —

   ```sh
   pixi run property
   ```

13. exact polynomial reference identities —

   ```sh
   python3 reference/python/polynomial/poly_reference.py
   ```

14. interval exclusion reference checks —

   ```sh
   python3 reference/python/interval/interval_exclusion_reference.py
   ```

15. declared input distributions of the differential oracles —

   ```sh
   python3 reference/python/arithmetic/exact_arithmetic_property_oracle.py --distribution
   ```

16. manuscript claim language —

   ```sh
   python3 tools/audit_paper_language.py
   ```

17. full tests —

   ```sh
   pixi run test
   ```

Report honestly which ran. A partial environment that reports a skip is worth
more than one that passes vacuously.

## What this repository treats as evidence

- `docs/C1_proof_definition_and_priority.md` is the source of truth for what
  would prove C1. A completion claim establishes every required proof block
  there and supplies a finite proof object checked by the Mojo theorem kernel.
- Proof state is declared in `proof/c1/records.toml`. The ledger index, the
  TLA+ ledger and its TLC models, and `docs/C1_claim_relationship_graph.json`
  are rendered from it by `tools/make_ledger.py` (`pixi run ledgers`), and
  `--check` in CI is what proves they are current.
- Every certificate-relevant number is a normalized rational or a
  rational-endpoint interval, under
  `docs/rational-interval-arithmetic-spec.md`, enforced by
  `tools/audit_exact_arithmetic.py` with the
  `tools/exact_arithmetic_allowlist.md` quarantine list.
- Classical analytic conclusions enter only as explicit theorem-tag imports
  with adapter lemmas. The Mojo kernel does not silently reprove imported
  analytic theorems.
- Vendored packages are pinned per file in `vendored.toml`, and the
  `finite-math-kernels` pin in `ESTATE.toml` is derived from it by the
  vendored checker.

## Standing prohibitions

- Never use a float for a certificate-relevant number (README, Exact
  arithmetic policy).
- Never use a circle, disk, arc, circumference, polar angle, connected
  component, interior, boundary or analytic locus as a primitive constructor,
  API or inference rule at rank 2; each needs an explicit higher-layer adapter
  (README, Rank-2 layer rule).
- Never claim C1 from a finite bounded search, a renderer, a numerical
  picture, a local carrier refinement or a terminology declaration alone, and
  never leave a `MissingTheoremCatalogueLink` exit open in a final C1 proof
  (README, Priority-zero conjecture and Boundary of claims).
- Never hand-edit a surface generated from `proof/c1/records.toml`; edit the
  records and run `pixi run ledgers`.
- Never demote a proof block or withdraw a tag on uncertain evidence, and
  never regenerate a pinned certificate or reference transcript on uncertain
  evidence: those operations fail closed by refusing (README, Fail closed).
- Never edit anything under `vendor/`. It is pinned in `vendored.toml`; change
  it upstream in `larsbx/finite-math-kernels`, re-vendor and re-pin (README,
  Repository layout).
- Never let a directory rename alone change theorem status, certificate
  acceptance, imported-theorem assumptions, or the Mojo finite-checker
  boundary (ARCHITECTURE.md).

## Scope discipline

- Make the change that was asked for. If the surrounding code is wrong in a way
  the task did not name, say so — do not widen the diff to fix it.
- If something is blocked, finish everything that is not, and say precisely what
  was left and why.
- Where a decision is already recorded, follow it or reopen it explicitly. Do
  not route around it in code.
