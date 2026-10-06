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

| Check                                                                 | Command                     | Result  |
| --------------------------------------------------------------------- | --------------------------- | ------- |
| the canonical Mojo smoke binary builds                                | `pixi run mojo-build`       | not run |
| vendored packages still match their pins                              | `pixi run vendored`         | not run |
| the canonical Mojo finite-core smoke suite                            | `pixi run mojo-smoke`       | not run |
| every arithmetic consumer is bound and exact                          | `pixi run exact-arithmetic` | not run |
| every path and task a document names resolves                         | `pixi run references`       | not run |
| the terminology registry's forbidden usages, in prose as well as code | `pixi run terminology`      | not run |
| generated surfaces (regime ledger, corpus, Mojo corpus) are current   | `pixi run ledgers-check`    | not run |
| the polyglot envelope is the rendering of its vendored template       | `pixi run polyglot-check`   | not run |
| full tests, including the Mojo/Python differential replay             | `pixi run test`             | not run |

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
