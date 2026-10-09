<!--
Derived from templates/docs/AGENTS.md in larsbx/agent-icm @ sha256:e0ea75600e3d136a
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

# Agent policy — langlands-lab

Exact finite-field instrumentation of three entry points into the Langlands
correspondence, sequenced 2 → 1 → 3: Brandt matrices and trace formulas,
geometric class field theory for GL₁, and the function-field act.

**Language / toolchain:** Python (canonical kernel) with Lean 4 as proof plane and oracle
**CI:** GitHub Actions: `ci.yml`, one job per authority plane: `policy` (the pinned
  estate audit), `kernel` (pytest without the Lean gate) and `proof` (the Lean
  gate)

This file is for whoever is working here next, human or otherwise. It states
what is settled, so that it does not get re-litigated by someone reading only
the code.

## Read first

- `ESTATE.toml`
- `ARCHITECTURE.md`
- `README.md`
- `docs/dossier.md`

## Gates

Before proposing a change as finished, run:

1. kernel and conformance, as the `kernel` job runs it —

   ```sh
   python -m pytest --ignore=tests/test_lean_gate.py
   ```

2. Lean gate: `lake build`, the axiom audit and exported-data freshness —

   ```sh
   python -m pytest tests/test_lean_gate.py
   ```

3. the Lean data bridge is current —

   ```sh
   python tools/export_lean_data.py --check
   ```

Report honestly which ran. A partial environment that reports a skip is worth
more than one that passes vacuously.

## What this repository treats as evidence

- Every test docstring says which side is computed and which theorem the match
  instantiates. A match is evidence only for the theorem it names.
- A result lands in `docs/dossier.md` labelled by what was done: COMPUTED,
  PROVED, or IMPORTED. An imported theorem is stated as imported, never as
  checked.
- Lean certificates use `decide` or `decide +kernel` only, and `Audit.lean`
  prints the axioms of every certificate: nothing beyond `propext` and
  `Quot.sound`.
- The Lean gate fails, never skips, when Lean is missing.

## Standing prohibitions

- Never use floating point. Everything is exact: Python ints, immutable
  tuples, sympy over ℤ.
- Never bring in Mathlib, `native_decide` or `sorry`. The axiom audit fails on
  `sorryAx`, `ofReduceBool` and `Classical.choice`.
- Never hand-edit `proof/langlands/LanglandsOracles/Data.lean`. It is exported
  by `tools/export_lean_data.py`, and the gate fails when it is stale.
- Never give Lean acceptance authority over the Python kernel. Lean holds
  claim state; `kernel/langlands/` is the canonical executable.
- Never let a directory rename alone change claim status, acceptance, or
  authority.

## Scope discipline

- Make the change that was asked for. If the surrounding code is wrong in a way
  the task did not name, say so — do not widen the diff to fix it.
- If something is blocked, finish everything that is not, and say precisely what
  was left and why.
- Where a decision is already recorded, follow it or reopen it explicitly. Do
  not route around it in code.
