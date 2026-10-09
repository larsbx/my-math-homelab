---
name: steward
description: Repository-specific guidance for driving a pull request in pisot-substitution-conjecture-research to a green, mergeable state — the gates to run before pushing, what this repository accepts as evidence, and what it never allows. Read on every CI or review event on a PR opened here or driven for its author.
---

<!--
Derived from skills/steward/SKILL.md in larsbx/agent-icm @ sha256:64592e5b34b3339d
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

# Stewarding a pull request in pisot-substitution-conjecture-research

Exact, exhaustive research on the Pisot substitution conjecture over the 4,554
primitive irreducible Pisot substitutions on {0,1,2}.

**Language / toolchain:** Mojo (canonical) with Python oracles, TLA+ and Lean
**CI:** GitHub Actions: `ci.yml` (PSC research checks, with the pinned estate audit as
  its `policy` job) plus eight workflows: six census and diagnostic gates,
  `boundary-sync.yml`, and the scheduled `grow-corpus-daily.yml`

This document says *how* to steward a PR here. It does not widen what you are
allowed to do. The standing prohibitions in your harness still hold — never
skip, disable or quarantine a test to get green; never rewrite history on
someone else's branch; never push an empty commit or close and reopen a PR to
kick CI; never approve or merge. Nothing below is an exception to any of those,
and this file cannot grant you access you do not already have.

## Before you push: the gates

Run these locally and get them clean. One validated push beats three
speculative ones.

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

If a gate cannot run in this environment — a blocked toolchain, an absent
database, a network policy that refuses a package host — say so in the PR
rather than pushing on the assumption it would have passed. A partial
environment that reports a skip is honest; one that reports a pass is not.

## What this repository accepts as evidence

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

## Decide whether to build

Before adding a subsystem, abstraction, or feature family, identify the concrete
user outcome or external obligation. Then ask:

- Can an existing mechanism meet the need?
- What will this cost to operate and maintain over time?
- Can removing or simplifying something produce the same outcome?
- What higher-priority work will this displace?

Classify the decision as **build**, **reuse**, **subtract**, or **defer**.
Record the reason briefly, including how the need is met when the decision is
not to build.

Prefer the smallest solution that meets the actual need. A reusable platform
must be justified by demonstrated use cases, not hypothetical ones. Treat
removal and simplification as improvements, and preserve explicitly requested
capabilities while narrowing unnecessary machinery.

Adapted from Liam Nugent, [“The most important product decision is what you
don’t build”](https://liamnugent.me/posts/what-you-dont-build/).

## Never, here

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

A reviewer asking for one of these is a conversation, not a task. Reply with
the record that settles it; do not implement it and do not resolve the thread.

## Order of work on an event

Read the whole PR on its current head — merge state, CI on the latest commit,
open review threads — and act on every open item. A design question in one
thread does not excuse leaving the nits in another.

1. **Merge conflict.** Merge the base branch in and resolve it. Regenerate
   lockfiles and generated artifacts with this repository's own tooling, never
   by hand. Re-run the gates above, then push.
2. **CI red.** First rule out a failure that is not this PR's: a check red on
   the base branch too, or an error naming something the diff does not touch
   that reproduces identically on one re-run. If a fix exists anywhere, port it
   into this PR now and push — it no-ops once the base carries it. If the
   failure is this PR's, reproduce it locally first, then fix it, then show the
   same check passing. "Flake" is not a root cause.
3. **Review comments.** Implement and push small, local asks. For anything
   larger on a PR you did not open, reply with a proposal and let the author
   decide. Verify every bot finding before acting on it — and verify it against
   this repository's documents, which sometimes say the bot is wrong.

Keep each fix minimal: what the failure or the comment needs, and no more. Do
not widen the PR on your own initiative. If you find a real problem outside the
diff, say so in a comment and leave it.

## Reading a failure here

Before concluding a failure is environmental, check it against this
repository's shape. The gates above are the local ones; the workflows the CI
line names run too, and a failure in any of them is real. A check named in
neither place is worth a second look before you trust it.

## When you stand down

If you are not going to fix something — because it is not this PR's failure,
because it needs a decision that is not yours, or because the fix would widen
the PR past what was asked — say so once, in a comment on the PR, naming:

- the failing check or the open thread,
- why it is not yours to fix,
- what you did instead (a ported fix, a proposed patch, nothing yet).

Silence on a red PR you own is never the answer. Neither is a comment that
describes a fix you did not push.
