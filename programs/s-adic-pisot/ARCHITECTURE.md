# Repository architecture

This repository adopts the estate repository template `estate-repository-v2`
(canonical source `larsbx/estate-governance`). [`ESTATE.toml`](ESTATE.toml) is
the machine-readable source of structure and authority; CI downloads the
estate audit pinned there, checks its SHA-256 and runs it.

```text
authority -> mathematical/domain concern -> implementation language
```

| Plane | Path | Authority |
|---|---|---|
| policy | `ESTATE.toml`, `claim_governance.toml`, `vendored.toml` | governance |
| kernel | `kernel/` (Mojo include root, pixi workspace) | canonical executable |
| proof | `CLAIMS.md` | claim state |
| reference | `reference/sadic_reference/` (exact Python oracle) | non-authoritative |
| conformance | `tests/` (pytest) | evidence |
| tooling | `tools/` | repository tooling |
| docs | `docs/`, `README.md`, `ARCHITECTURE.md`, `AGENTS.md` | exposition |

Vendored from `larsbx/finite-math-kernels` and pinned file by file in
`vendored.toml`: `kernel/{finite_exact,finite_automata,finite_graph,substitution_dynamics,mojo_smoke}`
and `tools/{claim_governance,vendoring}`. They are never edited locally; a
change goes upstream first and is re-vendored with
`tools/vendoring/check_vendored_sync.py pin NAME COMMIT` (methodology rule R6).

The repository's own code is `kernel/sadic/` (canonical: `directive`, `cocycle`,
`balance`, `spectrum`, `periodic`, `overlap`), the drivers `kernel/vectors.mojo` and
`kernel/brun_census.mojo`, `reference/sadic_reference/` (oracle: the package,
`spectrum`, `periodic`, `bpa`, `overlap`) and `tools/cross_check.py`, which fails closed when the two disagree on
the battery printed by `kernel/vectors.mojo`.
