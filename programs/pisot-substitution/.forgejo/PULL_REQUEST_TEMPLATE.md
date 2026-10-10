<!--
Derived from templates/github/PULL_REQUEST_TEMPLATE.md in larsbx/agent-icm @ sha256:1e174a33ab48cac7
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

## What changed

<!-- The behaviour change, in one or two sentences. Not the effort — the difference. -->

## Why

<!-- The problem, and why this is the shape of the fix. Link the issue, spec item, decision record or task id. -->

## Evidence

<!--
Paste what you ran and what it said. A check you did not run is not evidence;
say so plainly rather than leaving the line blank.
-->

| Check                                                   | Command                                                                     | Result  |
| ------------------------------------------------------- | --------------------------------------------------------------------------- | ------- |
| every verification layer, reporting skips honestly      | `./tools/verify_all.sh`                                                     | not run |
| Mojo regressions plus claim receipts                    | `./kernel/run_tests.sh`                                                     | not run |
| the ledger is still generated, not hand-edited          | `python tools/make_ledger.py --check`                                       | not run |
| the math catalogue is still generated                   | `python tools/make_math_catalogue.py --check`                               | not run |
| claim governance                                        | `PYTHONPATH=tools python -m claim_governance.cli --root .`                  | not run |
| every claim is guarded by a test a run actually reached | `PYTHONPATH=tools python -m claim_governance.cli --root . --check coverage` | not run |
| vendored packages still match their pins                | `python tools/vendoring/check_vendored_sync.py`                             | not run |
| suite                                                   | `pixi run test`                                                             | not run |
| TLA+ models                                             | `./proof/tla/check.sh`                                                      | not run |

## What this does *not* establish

<!--
Required. Name the bound.
 - A search that stopped at a limit says where it stopped.
 - A refusal is not a clean answer.
 - A test that could not run is not a test that passed.
 - Claim exactly what the run, the proof or the certificate establishes — no more.
Write "nothing outstanding" only if that is true.
-->

## Risk and reversibility

<!-- What breaks if this is wrong, and how it is backed out. -->

## Checklist

- [ ] The gates above were run, and the table says honestly which were not.
- [ ] New behaviour is covered by a test that fails without this change.
- [ ] Generated artifacts were regenerated with their tooling, never hand-edited.
- [ ] Documentation and status surfaces that name this behaviour were updated in this PR.
- [ ] No secret, token or credential is in the diff.
- [ ] The repository's standing prohibitions (see `AGENTS.md` / `CONTRIBUTING.md`) still hold.
