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
