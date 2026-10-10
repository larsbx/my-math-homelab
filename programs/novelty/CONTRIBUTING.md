# Contributing to novelty-lab

A calibration-first laboratory that turns mathematically plausible ideas into
auditable research claims.

**Language / toolchain:** Python (canonical), with a Lean oracle and TLA+
models. **CI:** GitHub Actions, `verify.yml` (policy, Python and TLC jobs)
and `lean-oracle.yml`.

Read these first. They are normative, not background:

- `AGENTS.md`
- `ARCHITECTURE.md` and `ESTATE.toml`
- `docs/calibration.md` and `docs/verification.md`
- `claim_governance.toml` and `vendored.toml`

---

## The gates

One runner covers all of them:

```sh
scripts/verify_all.sh          # every group
scripts/verify_all.sh python   # registries, vendoring, ledger, governance + coverage, tests, every census --check, paper tables
scripts/verify_all.sh lean     # Lean oracle build and self-check, mutation suite, F3 export cross-check
scripts/verify_all.sh tla      # TLC on the generated ledger models (TLA2TOOLS=path/to/tla2tools.jar)
```

It prints PASS, FAIL or SKIP for each gate. Exit status 0 means every gate ran
and passed, 1 means a gate failed, and 3 means none failed but some were
skipped. A skipped gate is not a passed gate. In the PR's evidence table, say
which gates were skipped and why.

The estate layout audit runs only in CI (the `policy` job). It downloads the
pinned audit, verifies its hash, and runs it (`ARCHITECTURE.md`).

## What counts as evidence

- A test under `tests/` declares `GUARDS_CLAIM` or `GUARDS_CONTRACT`. Its
  docstring says what is computed and what the match instantiates.
- Every committed data file has a `--check` replay, and its ledger record
  carries the file's digest.
- A new theorem-facing diagnostic, tested universal invariant, or promoted
  lemma is preceded by a literature stop/go note in `docs/literature/`.
- A sampled computation labels itself: a seed, a budget, and output that
  distinguishes an exhausted budget from a verdict.

## Standing prohibitions

- Never decide equality, rank, norm, a characteristic polynomial, or a
  certificate with floating point.
- Never let randomness enter a certificate or a finite-domain record.
- Never hand-edit a generated surface. These are `docs/ledger-index.md`,
  `tla/*`, the generated `[[claim]]` block of `claim_governance.toml`,
  committed `data/` outputs, and paper tables. Never hand-edit a ledger
  identifier either: reseal with `tools/seal_ledger.py`.
- Never patch a vendored file. Change it upstream in
  `larsbx/finite-math-kernels`, re-vendor, re-pin, and update the `ESTATE.toml`
  pin.
- Never vendor the estate audit. CI downloads it by pin.
- Never let a script promote anything to `novel result`.
- Never set `proof_reviewed = true` without a recorded independent review.
- Never claim beyond what the exact computation, the certificate, or the
  reviewed proof establishes.

These rules are not style preferences. Each one is settled in the documents
above, and changing one takes a decision record, not a pull request comment.

## Working shape

1. **Branch** from `main`.
2. **Write the failing case first.** A new test must fail without your
   change.
3. **Run the gates**: all of them, or name the ones you did not run.
4. **Update the surfaces.** Documentation, dossiers, the ledger, registries and
   generated artifacts that name the changed behaviour are part of the change,
   not a follow-up.
5. **Open the pull request** with the template, and fill in *What this does not
   establish*.

## Claim discipline

State exactly what your change establishes, and no more. `AGENTS.md` has the
full list. In short:

- a search that stopped at a limit says where it stopped;
- a bounded failure is not an absence;
- a refusal is not a clean answer;
- "verified" always says by what.

## Commits

Write the subject in the imperative, present tense, describing the difference:
for example, `Compute the H3 integral nulls exactly over all pairs`. The body
carries the reasoning when the subject cannot.
