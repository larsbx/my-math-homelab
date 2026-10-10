# Repository architecture

This repository adopts the estate repository template `estate-repository-v2`,
whose canonical source is `larsbx/estate-governance`.

The machine-readable source of repository structure and authority is
[`ESTATE.toml`](ESTATE.toml): this repository's estate position (SPEC_estate v0.1)
and its layout. The contract, `estate-repository-template-v2`, and the audit live
in `larsbx/estate-governance`; nothing from it is vendored here. CI downloads
the audit for the pinned `estate-governance` `[[dep]]` revision from a public
mirror at an immutable commit, verifies its SHA-256 against the dependency
pin before execution, and runs it against this repository. Fork and Dependabot
pull requests use the same fail-closed path without repository secrets.
The ordering rule is:

```text
authority -> mathematical/domain concern -> implementation language
```

Mojo under `kernel/` is the canonical executable (see `AGENTS.md`). Python under
`reference/psc_research/` is a non-authoritative reference layer, and the
oracles under `oracles/` (Python census oracles) never carry
acceptance. Lean under `proof/PscVerif/` and TLA+ under `proof/tla/` are the
proof plane: they hold claim state, not acceptance authority over the Mojo
kernel. Recorded run outputs live in `evidence/` and imported external sources
in `sources/`, both verbatim and pinned by `SHA256SUMS`. `claim_governance.toml`
and `vendored.toml` are policy alongside the manifest; packages vendored from
`larsbx/finite-math-kernels` are pinned there and, as a whole, by the
`finite-math-kernels` `[[dep]]`, whose pin `tools/vendoring/check_vendored_sync.py`
derives and checks.

The layout is canonical: every plane in `ESTATE.toml` maps exactly its `target`
(root-level files aside), every top-level directory is some plane's target, and
no migration step is pending; the audit enforces all three. Directory renames
alone must not change claim status, acceptance, or authority.
