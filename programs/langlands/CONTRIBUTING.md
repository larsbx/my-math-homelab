<!--
Derived from templates/docs/CONTRIBUTING.md in larsbx/agent-icm @ sha256:88bf9172c22bc8da
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

# Contributing to langlands-lab

Exact finite-field instrumentation of three entry points into the Langlands
correspondence, sequenced 2 → 1 → 3: Brandt matrices and trace formulas,
geometric class field theory for GL₁, and the function-field act.

**Language / toolchain:** Python (canonical kernel) with Lean 4 as proof plane and oracle
**CI:** GitHub Actions: `ci.yml`, one job per authority plane: `policy` (the pinned
  estate audit), `kernel` (pytest without the Lean gate) and `proof` (the Lean
  gate)

Read these first — they are normative, not background:

- `ESTATE.toml`
- `ARCHITECTURE.md`
- `README.md`
- `docs/dossier.md`

---

## The gates

Run these before you open a pull request. Paste what they said into the PR's
evidence table.

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

A check you did not run is not evidence. Say which ones you skipped and why;
the pull request template has a place for exactly that.

## What counts as evidence here

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

These are not style preferences. Each one is settled somewhere in the documents
above; changing one is a decision record, not a pull request comment.

## Working shape

1. **Branch** from the default branch.
2. **Make the failing case first** where this repository's discipline requires
   it, and in every case make sure the new test fails without your change.
3. **Run the gates.** All of them, or name the ones you did not.
4. **Update the surfaces.** Documentation, status tables, ledgers and generated
   artifacts that name the behaviour you changed are part of the change, not a
   follow-up. Regenerate generated files with their tooling; never hand-edit one.
5. **Open the pull request** using the template. Fill in *What this does not
   establish* — it is required, and it is the section reviewers read first.

## Claim discipline

State exactly what your change establishes and no more.

- A search that stopped at a limit reports where it stopped.
- A bounded failure is not an absence.
- A refusal is not a clean answer.
- A translation preserves or lowers authority; it never raises it.
- "Verified" unqualified is not a claim. Say verified *by what*.

## Commits

Imperative, present tense, describing the difference: `Add the M-adic ball
carrier`, `Reject a singular M before the zeroth power`. The body carries the
reasoning when the subject cannot.
