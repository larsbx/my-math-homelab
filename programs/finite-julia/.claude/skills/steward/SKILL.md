---
name: steward
description: Repository-specific guidance for driving a pull request in finite-julia-set-research to a green, mergeable state — the gates to run before pushing, what this repository accepts as evidence, and what it never allows. Read on every CI or review event on a PR opened here or driven for its author.
---

<!--
Derived from skills/steward/SKILL.md in larsbx/agent-icm @ sha256:64592e5b34b3339d
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

# Stewarding a pull request in finite-julia-set-research

A finite, certificate-carrying formulation of quadratic Julia set computation
at exactly representable (Gaussian-rational) parameters: the dynamical-plane
companion to finite-mandelbrot-research, organized as a regime ledger rather
than one conjecture.

**Language / toolchain:** Mojo 1.0.0 (canonical, `kernel/`) with a Python reference oracle
  (`reference/`), under pixi
**CI:** GitHub Actions: `ci.yml`, one `audit` job: the pinned estate audit, then the
  Mojo build, vendored digests, Mojo smoke suite, exact-arithmetic, reference,
  terminology, ledger and polyglot audits, the full tests, and the vendored
  digests again

This document says *how* to steward a PR here. It does not widen what you are
allowed to do. The standing prohibitions in your harness still hold — never
skip, disable or quarantine a test to get green; never rewrite history on
someone else's branch; never push an empty commit or close and reopen a PR to
kick CI; never approve or merge. Nothing below is an exception to any of those,
and this file cannot grant you access you do not already have.

## Before you push: the gates

Run these locally and get them clean. One validated push beats three
speculative ones.

1. the canonical Mojo smoke binary builds —

   ```sh
   pixi run mojo-build
   ```

2. vendored packages still match their pins —

   ```sh
   pixi run vendored
   ```

3. the canonical Mojo finite-core smoke suite —

   ```sh
   pixi run mojo-smoke
   ```

4. every arithmetic consumer is bound and exact —

   ```sh
   pixi run exact-arithmetic
   ```

5. every path and task a document names resolves —

   ```sh
   pixi run references
   ```

6. the terminology registry's forbidden usages, in prose as well as code —

   ```sh
   pixi run terminology
   ```

7. generated surfaces (regime ledger, corpus, Mojo corpus) are current —

   ```sh
   pixi run ledgers-check
   ```

8. the polyglot envelope is the rendering of its vendored template —

   ```sh
   pixi run polyglot-check
   ```

9. full tests, including the Mojo/Python differential replay —

   ```sh
   pixi run test
   ```

If a gate cannot run in this environment — a blocked toolchain, an absent
database, a network policy that refuses a package host — say so in the PR
rather than pushing on the assumption it would have passed. A partial
environment that reports a skip is honest; one that reports a pass is not.

## What this repository accepts as evidence

- Two implementations decide every corpus row: the Mojo kernel
  `kernel/julia_orbit.mojo` over the vendored packages, and the Python
  reference oracle `reference/julia_reference.py`. `tests/test_mojo_replay.py`
  compares their transcripts line for line. The replay skips where no Mojo
  toolchain is present, and a run that reports that skip has checked only one
  of the two.
- Classical conclusions enter only as named theorem tags, each judged by a
  literature gate under `docs/`. A tag with no literature gate is not called
  verified.
- Every certificate-relevant number is a normalized rational or a
  rational-endpoint interval. Each module that instantiates an arithmetic
  layer has a row in `docs/exact-arithmetic-binding.md`, and
  `tools/audit_exact_arithmetic.py` fails the build on an unbound consumer.
- The regime ledger, the classifier census, `corpus.json` and
  `kernel/parameter_corpus.mojo` are generated from
  `reference/parameter_corpus.py` by `tools/make_regime_ledger.py`. `--check`
  is what proves they are current.
- Vendored packages are pinned per file in `vendored.toml`, and the
  `finite-math-kernels` pin in `ESTATE.toml` is derived from it by the
  vendored checker.

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

- Never use a float for a certificate-relevant number: rationals and
  rational-endpoint intervals only (README, Exact arithmetic). The allowlist
  is empty.
- Never edit anything under `vendor/`. A vendored file that differs from its
  pin refuses the run; change it upstream in `larsbx/finite-math-kernels`,
  re-vendor and re-pin (README, fail-closed table and Repository layout).
- Never hand-edit a generated surface (`docs/J1_regime_ledger.md`,
  `docs/classifier-census.md`, `corpus.json`, `kernel/parameter_corpus.mojo`).
  Edit `reference/parameter_corpus.py` and regenerate with `pixi run ledgers`.
- Never overwrite a pinned corpus row or transcript: the pinned bytes are what
  a reader replays (README, fail-closed table).
- Never call a theorem tag verified without its literature gate, and never let
  a classical conclusion become a finite-core verdict (README, Boundary of
  claims).
- Never treat `reference/` as an acceptance path. It is reference semantics;
  `kernel/` is the one canonical executable (ARCHITECTURE.md).
- Never use the circle family as a rank-2 primitive or in ungoverned prose. An
  occurrence passes `tools/audit_terminology.py` only as a registered field
  term, a denial, under a forbidding heading, or with an explicit
  `terminology-exempt` marker.
- Never let a directory rename alone change claim status, acceptance, or
  authority (ARCHITECTURE.md).

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
