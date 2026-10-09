---
name: steward
description: Repository-specific guidance for driving a pull request in novelty-lab to a green, mergeable state. Covers the gates to run before pushing, what this repository accepts as evidence, how to read its typical failures, and what it never allows. Read it on every CI or review event on a PR opened here or driven for its author.
---

# Stewarding a pull request in novelty-lab

This document says *how* to steward a PR here. It does not widen what you are
allowed to do. The standing prohibitions in your harness still hold, and
nothing below is an exception to them:

- never skip, disable or quarantine a test to get green;
- never rewrite history on someone else's branch;
- never push an empty commit, or close and reopen a PR, to kick CI;
- never approve or merge unless your user asked.

## Before you push

Run the gates in `CONTRIBUTING.md` § *The gates*, at least
`scripts/verify_all.sh python`, and get them clean. One validated push beats
three speculative ones.

If a gate cannot run here (no `lake`, no `java`, a network policy), the runner
says SKIP. Say so in the PR rather than pushing on the assumption it would
have passed. CI treats a skip as a failure (exit status 3).

What counts as evidence, and the standing prohibitions, are in
`CONTRIBUTING.md` and `AGENTS.md`. A reviewer asking for one of those
prohibited things starts a conversation, not a task: reply with the record
that settles it, do not implement it, and do not resolve the thread.

## Reading a failure here

| Symptom | Usual cause | Fix |
|---|---|---|
| `census X is current` fails | a code change altered the output | rerun `python experiments/n2/X.py` (no `--check`). Update the data digest in the ledger record, reseal, regenerate. Then update every figure the paper, dossier and registries cite from that file. |
| `ledger surfaces are generated` fails | `research/ledger.json` edited without regenerating | `python tools/seal_ledger.py`, then the generator without `--check` |
| claim governance `coverage` fails | a new test with no `GUARDS_*`, or a guard naming no record | declare what the test guards; add the ledger record first if it is new |
| claim governance `promotion` fails | prose near a pending claim says "is proved" or similar | restate it as pending, or record the review that settles it |
| `policy` job fails on a `finite-math-kernels` pin | `vendored.toml` changed without updating `ESTATE.toml` | recompute the vendored digest (`ARCHITECTURE.md`) and update the `[[dep]]` pin |
| `policy` job fails on a top-level directory | a new top-level directory belongs to no plane | add it to a plane's `current` in `ESTATE.toml`, or move it under an existing target |
| Lean job fails | oracle or fixture drift | regenerate the fixture with its script; never edit the Lean data by hand |

Review bots here (Codex) often report mathematical errors: a wrong rank, a
miscounted null, an overstrong statement. Verify each finding against the
committed data and the proof before acting on it. When it holds:

1. Fix the statement everywhere it appears: paper, ledger statement, dossier,
   registries.
2. Reply on the thread naming the commit.
3. Resolve the thread.

## Order of work on an event

Read the whole PR on its current head: merge state, CI on the latest commit,
and open review threads. Then act on every open item, in this order:

1. **Merge conflict.** Merge the base branch in. Regenerate the ledger
   surfaces, data and paper tables with their tools, never by hand. Re-run the
   gates, then push.
2. **CI red.** First rule out a failure that is not this PR's. Otherwise
   reproduce it locally, fix it, and show the same gate passing.
   "Flake" is not a root cause. The checks here are deterministic and seeded.
3. **Review comments.** Implement small, local asks. For anything larger on a
   PR you did not open, reply with a proposal.

Keep each fix minimal. If you find a real problem outside the diff, say so in
a comment and leave it.

## When you stand down

If you are not going to fix something, say so once in a comment on the PR,
naming:

- the failing check or the thread;
- why it is not yours to fix;
- what you did instead.

Silence on a red PR you own is never the answer.
