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

Python under `kernel/langlands/` is the canonical executable. Lean under `proof/langlands/` is the
proof plane: it recomputes and certifies identities on exported data, and holds
claim state, not acceptance authority over the Python kernel.

The layout is canonical: every plane in `ESTATE.toml` maps exactly its `target`
(root-level files aside) and no migration step is pending; the audit enforces
both. Directory renames alone must not change claim status, acceptance, or
authority.
