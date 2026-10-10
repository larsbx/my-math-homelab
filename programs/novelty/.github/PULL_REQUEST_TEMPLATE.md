## What changed

<!-- The behaviour change, in one or two sentences. Describe the difference, not the effort. -->

## Why

<!-- The problem, and why this is the shape of the fix. Link the candidate (N1–N5), ledger record, literature note or issue. -->

## Evidence

<!--
Paste what you ran and what it said. A check you did not run is not evidence;
say so plainly rather than leaving the line blank. `scripts/verify_all.sh`
prints one PASS / FAIL / SKIP line per gate.
-->

| Gate group | Command | Result |
| --- | --- | --- |
| registries, vendoring, ledger, governance + coverage, tests, censuses, paper tables | `scripts/verify_all.sh python` | not run |
| Lean oracle, mutation suite, F3 export | `scripts/verify_all.sh lean` | not run |
| TLC ledger models | `scripts/verify_all.sh tla` | not run |
| estate layout audit | CI `policy` job | not run |
| paper builds without warnings (if `paper/` changed) | `latexmk -pdf main.tex` | not run |

## What this does *not* establish

<!--
Required. Name the bound.
 - A sampled census says it was sampled, with seed and budget; an exhaustive one says over what.
 - A proof written here is pending until independently reviewed.
 - A literature check is clearance, not novelty.
 - A test that could not run is not a test that passed.
Write "nothing outstanding" only if that is true.
-->

## Ledger and status changes

<!-- New or changed records (kind, status), retired claims (KILL-nn), registry gates. "None" is a valid answer. -->

## Risk and reversibility

<!-- What breaks if this is wrong, and how it is backed out. -->

## Checklist

- [ ] The gates were run, and the table says honestly which were not.
- [ ] New behaviour is covered by a test that fails without this change and declares what it guards.
- [ ] Generated surfaces were regenerated with their tooling, never hand-edited; ledger identifiers were resealed.
- [ ] A theorem-facing addition has a literature stop/go note, or names the earlier note it relies on.
- [ ] Documentation, dossiers and status surfaces that name this behaviour were updated in this PR.
- [ ] No secret, token or credential is in the diff.
- [ ] The standing prohibitions of `CONTRIBUTING.md` still hold.
