<!--
Derived from templates/docs/CONTRIBUTING.md in larsbx/agent-icm @ sha256:88bf9172c22bc8da
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

# Contributing to pisot-substitution-conjecture-research

Exact, exhaustive research on the Pisot substitution conjecture over the 4,554
primitive irreducible Pisot substitutions on {0,1,2}.

**Language / toolchain:** Mojo (canonical) with Python oracles, TLA+ and Lean
**CI:** GitHub Actions: `ci.yml` (PSC research checks, with the pinned estate audit as
  its `policy` job) plus eight workflows: six census and diagnostic gates,
  `boundary-sync.yml`, and the scheduled `grow-corpus-daily.yml`

Read these first — they are normative, not background:

- `ESTATE.toml`
- `ARCHITECTURE.md`
- `AGENTS.md`
- `README.md`
- `claim_governance.toml`
- `vendored.toml`
- `docs/`

---

## The gates

Run these before you open a pull request. Paste what they said into the PR's
evidence table.

1. every verification layer, reporting skips honestly —

   ```sh
   ./tools/verify_all.sh
   ```

2. Mojo regressions plus claim receipts —

   ```sh
   ./kernel/run_tests.sh
   ```

3. the ledger is still generated, not hand-edited —

   ```sh
   python tools/make_ledger.py --check
   ```

4. the math catalogue is still generated —

   ```sh
   python tools/make_math_catalogue.py --check
   ```

5. claim governance —

   ```sh
   PYTHONPATH=tools python -m claim_governance.cli --root .
   ```

6. every claim is guarded by a test a run actually reached —

   ```sh
   PYTHONPATH=tools python -m claim_governance.cli --root . --check coverage
   ```

7. vendored packages still match their pins —

   ```sh
   python tools/vendoring/check_vendored_sync.py
   ```

8. suite —

   ```sh
   pixi run test
   ```

9. TLA+ models —

   ```sh
   ./proof/tla/check.sh
   ```

A check you did not run is not evidence. Say which ones you skipped and why;
the pull request template has a place for exactly that.

## What counts as evidence here

- A test under `kernel/tests/` ends its `main` with `require_claim("<Name>")`
  or `require_contract("<what it pins>")`, placed after the assertions it
  stands behind.
- Receipts are collected from the tests that *passed*: a declaration no run
  reached guards nothing.
- A new theorem-facing diagnostic or promoted lemma is preceded by a targeted
  stop/go literature note in `docs/` — three to six primary sources,
  hypotheses that transfer and those that do not, and the decision.
- An exploratory search labels itself: a seeded generator or a stated stride,
  an explicit budget, and output distinguishing an exhausted budget from a
  mathematical verdict.

## Standing prohibitions

- Never merge new theorem-support code as Python-only while a Mojo
  implementation is possible. Mojo is canonical; Python is an oracle.
- Never let randomness enter a certificate, a census, or proof-support code.
- Never use a floating approximation for PIP screening, equality,
  factorization, rank, or a certificate decision.
- Never patch a vendored file, add a file beside one, or reintroduce a local
  copy of what a package provides. Change it upstream in
  `larsbx/finite-math-kernels`, re-vendor, re-pin.
- Never hand-edit a generated artifact: `proof/tla/ledger.json`,
  `proof/tla/Ledger.tla`, the `proof/tla/MCLedger*` models,
  `docs/ledger-index.md`, `docs/claim-relationship-graph.json`, or generated
  claim entries in `claim_governance.toml`.
- Never claim beyond what the exact executable or the formal proof actually
  establishes.
- Never return an empty structure where an invariant is impossible. Fail
  closed — it could be misread as mathematical evidence.

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
