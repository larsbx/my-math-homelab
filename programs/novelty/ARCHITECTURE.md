# Repository architecture

This repository adopts the estate repository template `estate-repository-v2`,
whose canonical source is `larsbx/estate-governance`, in the form used by
`larsbx/langlands-lab`.

[`ESTATE.toml`](ESTATE.toml) is the machine-readable source of repository
structure and authority. It records this repository's estate position
(SPEC_estate v0.1) and its layout. The audit lives in `larsbx/estate-governance`
and nothing from it is vendored here. The `policy` job of
`.github/workflows/verify.yml` works as follows:

1. Download the audit for the pinned `estate-governance` `[[dep]]` revision
   from the public mirror in `larsbx/finite-math-kernels`, at an immutable
   commit.
2. Verify its SHA-256 against the dependency pin before running anything.
3. Run it against this checkout.

A pin mismatch fails the job; nothing is skipped.

The ordering rule is:

```text
authority -> mathematical/domain concern -> implementation language
```

| Plane | Target | Authority | Holds |
|---|---|---|---|
| policy | `ESTATE.toml` | governance | the manifest, `claim_governance.toml`, `AGENTS.md`, `CONTRIBUTING.md` |
| kernel | `kernel/` | canonical executable | exact certificate checkers (Python, `int`/`Fraction` only) |
| proof | `research/` | claim state | `research/ledger.json`, the registries, and the generated `tla/` models |
| oracle | `NoveltyLab/` | non-authoritative oracle | the Lean pentagon oracle and the 𝔽₃ structure-tensor export |
| experiments | `experiments/` | non-authoritative experiment | census drivers and searches; seeded, budgeted, labelled |
| data | `data/` | evidence | committed census outputs, each hashed in the ledger |
| conformance | `tests/` | evidence | regressions; each file names the claim or contract it guards |
| contract | `schemas/` | contract | versioned certificate formats |
| vendor | `vendor/` | pinned external | byte-for-byte copies from `larsbx/finite-math-kernels`, pinned in `vendored.toml` |
| tooling | `tools/` | repository tooling | `tools/` and `scripts/`: sealing, checkers, generators |
| docs | `docs/` | exposition | dossiers, policies, audits, `README.md`, this file |
| publication | `paper/` | publication | manuscripts whose tables are generated from `data/` |

Python is the one canonical language. Lean and TLA+ are supporting
languages and have no acceptance authority. If the Lean oracle disagrees with
the Python kernel, that fails closed. Directory renames alone must not change
claim status, acceptance or authority.

## Why the layout is transitional

Two census drivers under `experiments/n2/` (`rank_law.py` and
`word_defects.py`) produce the committed data behind two finite-domain ledger
records. A canonical layout would move them under `kernel/`, because the
non-authoritative experiment plane should not carry finite-domain authority.
`[migration].next` lists that move, together with two consolidations (`scripts/`
into `tools/`, and `tla/` under `research/`). Each one is a boundary-first move
with its own pull request. When the queue is empty, `layout.status` becomes
`canonical`.

## Changing the vendored packages

The `finite-math-kernels` `[[dep]]` pin is the audit's digest of the
`vendored.toml` rows for that repository: each package's name, commit, root,
and recorded and actual file hashes. Re-vendor and re-pin with
`vendor/vendoring/check_vendored_sync.py pin NAME COMMIT`, then run
`python tools/estate_pins.py --write` in the same pull request. Otherwise the
local `ESTATE.toml vendoring pins` gate and the CI policy job fail.
