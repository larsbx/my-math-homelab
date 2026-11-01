# Repository architecture

`my-math-homelab` is the estate's consolidated mathematics workspace: an
`estate-repository-v2` repository in `multi_program` mode
([multi-program contract](https://github.com/larsbx/estate-governance/blob/main/docs/architecture/multi-program-repository-v1.md)).
[`ESTATE.toml`](ESTATE.toml) is the machine-readable authority; every program and
shared component is locked to a source commit in
[`policy/source-locks.toml`](policy/source-locks.toml).

| Plane | Path | Content |
| --- | --- | --- |
| policy | `policy/` | source locks: repository, commit, visibility, import mode |
| kernel | `kernel/` | `workspace.py`, the import verifier (canonical, Python) |
| programs | `programs/<id>/` | one durable research program each, with `PROGRAM.toml` |
| shared | `shared/<id>/` | components consumed by named programs |
| conformance | `tests/` | baseline plus one rejecting mutation per verifier rule |
| tooling | `tools/` | `import_source.py`, the history-preserving importer |
| docs | `docs/` | migration record |

## Programs

| Program | Namespace | Source | Import |
| --- | --- | --- | --- |
| arithmetic-bicycle | AB | arithmetic-bicycle-conjecture-research | history |
| bulb-ford | BFC | mandelbrot-bulbs-and-ford-circles-research | history |
| closure-fiber | CFM | closure-fiber-of-multiplication-research | history |
| finite-julia | FJ | finite-julia-set-research | history |
| finite-mandelbrot | FM | finite-mandelbrot-research | history |
| giant-fibers | GF | giant-fibers-finite-fields-thin-groups | history |
| julia-oracle | JO | julia-oracle-lab | history |
| langlands | LL | langlands-lab | history |
| novelty | NL | novelty-lab | history |
| pisot-substitution | PS | pisot-substitution-conjecture-research | history |
| pisot-vijayaraghavan | PV | pisot-vijayaraghavan-problem-research | history |
| s-adic-pisot | SAP | s-adic-pisot-conjecture-research | history |
| tiling-theory | TT | tiling-theory-research | history |
| vizing-domination | VD | vizing-domination-conjecture-research | history |

Shared components: `finite-math-kernels` (exact finite-mathematics kernels;
consumers FM, FJ, BFC, NL, PS, SAP) and `math-vizops` (manim surfaces; consumers
FM, BFC). `finite-dynamics`, the earlier four-program pilot, is superseded: its
programs are imported here from their original sources. `oracles` is empty and
not imported.

## Authority boundary

Every source retains its authority: claims, theorem status, gates, releases
and issues stay with the source repository until a reviewed, per-program
transfer. Imported trees are byte-identical copies; nested `ESTATE.toml` files
and workflows are preserved historical files and are not executed by this
repository's CI. The root canonical language declares
`acceptance_authority = true` over one boundary, **import acceptance**: the
workspace accepts an imported or metadata-only root only when it passes
`kernel/workspace.py`, the boundary's single implementation. Accepting an
import never transfers or re-issues a source's claim, theorem or release
verdict. The check requires:

- each `history` import has its locked commit as an ancestor of `HEAD`, the
  locked commit count, and an identical tree (mode, type, object id) under its root;
- each `metadata_only` root publishes nothing but its `PROGRAM.toml`;
- `ESTATE.toml`, `PROGRAM.toml` and the locks agree, and no root is unlocked.

## Public boundary

This repository is public. The owner decided on 2026-10-09 that every math
source is public, so all programs are full history imports. The verifier still
fails closed on a lock marked `private` with `import = "history"`, and a
`metadata_only` root may publish nothing but its `PROGRAM.toml`.

## Scheduled cross-program research orchestration (non-authoritative)

The root workspace may schedule experiments against exact source revisions
without transferring a programme's theorem/claim authority or editing
locked imported history. The first such workload is the AKN atlas study,
registered under `policy/research-schedules.toml`, implemented by
`tools/research_schedule.py`, and scheduled through the root workflow
`.github/workflows/akn-math-research.yml`. Its research statement,
source PRs, evidence and frontier are documented in
`docs/research/akn-automated-research.md`.

This is **tooling and policy metadata**, not a second mathematical kernel
or an acceptance boundary for tiling claims. The coordinator only reads
the source repository and runs its independently checkable experiment at
the exact inspected PR head (or the independently inspected source `main`
after that PR merges). It checks the fetched SHA, stores certificates
and errors, and never rewrites `programs/tiling-theory`,
`policy/source-locks.toml`, claim ledgers, or source PR state. All
global theorem claims require separate source-governed acceptance.

Daily status snapshots and Monday full experiments are UTC-scheduled,
with manually dispatched reruns for diagnosis. GitHub's schedule only
becomes active once its workflow is merged into this repository's
default branch.

## Every-mathematics-programme research orchestration

All 14 active programme source locks and both active shared-component
locks are registered one-to-one in
`policy/math-research-portfolio.toml`. The read-only portfolio
coordinator `tools/math_research_portfolio.py` and workflow
`.github/workflows/math-estate-research.yml` do daily source evidence
acquisition and a four-shard weekly mathematical-obligation triage.

The portfolio performs exact-revision source file/claim-surface
fingerprints, independent Git blob digest replay, CI/issue/PR
reconciliation and explicit negative evidence; it cannot grant claim
authority and does not execute unreviewed arbitrary source code. It
reports which 15 programme-specific independent mathematics adapters
have not yet been built. The already established AKN specialist
`tools/research_schedule.py` remains scheduled separately and is
classified as an independently checked finite experiment, subject to
its original source acceptance gate.

See `docs/research/math-estate-programme.md` for the scientific
process and honest completion boundary. All changes are in root
`policy`, `tools`, `docs`, `.github/workflows`, and `tests`;
they do not modify imported `programs/*` or `shared/*` content and
do not transfer source claim authority.
