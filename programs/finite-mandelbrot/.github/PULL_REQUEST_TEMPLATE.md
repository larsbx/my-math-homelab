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

| Check                                                                                        | Command                                                                                  | Result  |
| -------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- | ------- |
| vendored packages still match their pins                                                     | `pixi run vendored`                                                                      | not run |
| the polyglot envelope is the rendering of its vendored template                              | `pixi run polyglot-check`                                                                | not run |
| governed theorem and claim usage (CI sets `PYTHONPATH: vendor/python`)                       | `PYTHONPATH=vendor/python python3 -m claim_governance.cli --root .`                      | not run |
| backend manifest and proof-grade boundary                                                    | `python3 tools/audit_backend_manifest.py`                                                | not run |
| governed terminology                                                                         | `python3 tools/audit_terminology.py`                                                     | not run |
| the canonical Mojo smoke binary builds                                                       | `pixi run mojo-build`                                                                    | not run |
| the canonical Mojo finite-core smoke suite                                                   | `pixi run mojo-smoke`                                                                    | not run |
| no forbidden analytic primitives in the executable core                                      | `python3 tools/audit_no_trig.py`                                                         | not run |
| no forbidden analytic point APIs in the executable core                                      | `python3 tools/audit_no_points.py`                                                       | not run |
| the exact-arithmetic boundary                                                                | `python3 tools/audit_exact_arithmetic.py`                                                | not run |
| generated ledger surfaces are current (Mojo mirror, block table, claims, index, TLA+, graph) | `python3 tools/make_ledger.py --check`                                                   | not run |
| exact-arithmetic property oracle                                                             | `pixi run property`                                                                      | not run |
| exact polynomial reference identities                                                        | `python3 reference/python/polynomial/poly_reference.py`                                  | not run |
| interval exclusion reference checks                                                          | `python3 reference/python/interval/interval_exclusion_reference.py`                      | not run |
| declared input distributions of the differential oracles                                     | `python3 reference/python/arithmetic/exact_arithmetic_property_oracle.py --distribution` | not run |
| manuscript claim language                                                                    | `python3 tools/audit_paper_language.py`                                                  | not run |
| full tests                                                                                   | `pixi run test`                                                                          | not run |

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
