---
name: steward
description: Repository-specific guidance for driving a pull request in finite-mandelbrot-research to a green, mergeable state — the gates to run before pushing, what this repository accepts as evidence, and what it never allows. Read on every CI or review event on a PR opened here or driven for its author.
---

<!--
Derived from skills/steward/SKILL.md in larsbx/agent-icm @ sha256:64592e5b34b3339d
Edit the canonical template or estate.toml in larsbx/agent-icm, then re-render there: make estate
Hand-edits here are drift, and agent-icm's `make estate-check` fails on them.
-->

# Stewarding a pull request in finite-mandelbrot-research

A finite, certificate-carrying formulation of Mandelbrot-set computation:
integer critical-orbit polynomials, dyadic rational boxes and rank-2
coordinate records, with the C1 separator-adequacy conjecture as priority
zero.

**Language / toolchain:** Mojo 1.0.0 (canonical theorem kernel, `kernel/mojo/`) with Python reference
  oracles and audits, under pixi; a TLA+ ledger model
**CI:** GitHub Actions: `no-trig-audit.yml`, one job per authority plane: `policy`
  (the pinned estate audit, vendored digests, polyglot envelope, claim
  governance, backend manifest, terminology), `kernel` (Mojo build and smoke,
  no-trig, no-points and exact-arithmetic audits), `proof` (generated ledger
  surfaces), `reference` (property oracle and reference checks), `paper`
  (manuscript claim language), then `integration` (full tests)

This document says *how* to steward a PR here. It does not widen what you are
allowed to do. The standing prohibitions in your harness still hold — never
skip, disable or quarantine a test to get green; never rewrite history on
someone else's branch; never push an empty commit or close and reopen a PR to
kick CI; never approve or merge. Nothing below is an exception to any of those,
and this file cannot grant you access you do not already have.

## Before you push: the gates

Run these locally and get them clean. One validated push beats three
speculative ones.

1. vendored packages still match their pins —

   ```sh
   pixi run vendored
   ```

2. the polyglot envelope is the rendering of its vendored template —

   ```sh
   pixi run polyglot-check
   ```

3. governed theorem and claim usage (CI sets `PYTHONPATH: vendor/python`) —

   ```sh
   PYTHONPATH=vendor/python python3 -m claim_governance.cli --root .
   ```

4. backend manifest and proof-grade boundary —

   ```sh
   python3 tools/audit_backend_manifest.py
   ```

5. governed terminology —

   ```sh
   python3 tools/audit_terminology.py
   ```

6. the canonical Mojo smoke binary builds —

   ```sh
   pixi run mojo-build
   ```

7. the canonical Mojo finite-core smoke suite —

   ```sh
   pixi run mojo-smoke
   ```

8. no forbidden analytic primitives in the executable core —

   ```sh
   python3 tools/audit_no_trig.py
   ```

9. no forbidden analytic point APIs in the executable core —

   ```sh
   python3 tools/audit_no_points.py
   ```

10. the exact-arithmetic boundary —

   ```sh
   python3 tools/audit_exact_arithmetic.py
   ```

11. generated ledger surfaces are current (Mojo mirror, block table, claims,
   index, TLA+, graph) —

   ```sh
   python3 tools/make_ledger.py --check
   ```

12. exact-arithmetic property oracle —

   ```sh
   pixi run property
   ```

13. exact polynomial reference identities —

   ```sh
   python3 reference/python/polynomial/poly_reference.py
   ```

14. interval exclusion reference checks —

   ```sh
   python3 reference/python/interval/interval_exclusion_reference.py
   ```

15. declared input distributions of the differential oracles —

   ```sh
   python3 reference/python/arithmetic/exact_arithmetic_property_oracle.py --distribution
   ```

16. manuscript claim language —

   ```sh
   python3 tools/audit_paper_language.py
   ```

17. full tests —

   ```sh
   pixi run test
   ```

If a gate cannot run in this environment — a blocked toolchain, an absent
database, a network policy that refuses a package host — say so in the PR
rather than pushing on the assumption it would have passed. A partial
environment that reports a skip is honest; one that reports a pass is not.

## What this repository accepts as evidence

- `docs/C1_proof_definition_and_priority.md` is the source of truth for what
  would prove C1. A completion claim establishes every required proof block
  there and supplies a finite proof object checked by the Mojo theorem kernel.
- Proof state is declared in `proof/c1/records.toml`. The ledger index, the
  TLA+ ledger and its TLC models, and `docs/C1_claim_relationship_graph.json`
  are rendered from it by `tools/make_ledger.py` (`pixi run ledgers`), and
  `--check` in CI is what proves they are current.
- Every certificate-relevant number is a normalized rational or a
  rational-endpoint interval, under
  `docs/rational-interval-arithmetic-spec.md`, enforced by
  `tools/audit_exact_arithmetic.py` with the
  `tools/exact_arithmetic_allowlist.md` quarantine list.
- Classical analytic conclusions enter only as explicit theorem-tag imports
  with adapter lemmas. The Mojo kernel does not silently reprove imported
  analytic theorems.
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

- Never use a float for a certificate-relevant number (README, Exact
  arithmetic policy).
- Never use a circle, disk, arc, circumference, polar angle, connected
  component, interior, boundary or analytic locus as a primitive constructor,
  API or inference rule at rank 2; each needs an explicit higher-layer adapter
  (README, Rank-2 layer rule).
- Never claim C1 from a finite bounded search, a renderer, a numerical
  picture, a local carrier refinement or a terminology declaration alone, and
  never leave a `MissingTheoremCatalogueLink` exit open in a final C1 proof
  (README, Priority-zero conjecture and Boundary of claims).
- Never hand-edit a surface generated from `proof/c1/records.toml`; edit the
  records and run `pixi run ledgers`.
- Never demote a proof block or withdraw a tag on uncertain evidence, and
  never regenerate a pinned certificate or reference transcript on uncertain
  evidence: those operations fail closed by refusing (README, Fail closed).
- Never edit anything under `vendor/`. It is pinned in `vendored.toml`; change
  it upstream in `larsbx/finite-math-kernels`, re-vendor and re-pin (README,
  Repository layout).
- Never let a directory rename alone change theorem status, certificate
  acceptance, imported-theorem assumptions, or the Mojo finite-checker
  boundary (ARCHITECTURE.md).

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
