# Repository architecture

This repository adopts the estate repository template `estate-repository-v1`,
whose canonical source is `larsbx/estate-governance`.

The machine-readable source of repository structure and authority is
[`ESTATE.toml`](ESTATE.toml): this repository's estate position (SPEC_estate v0.1)
and its layout. The contract, `estate-repository-template-v2`, and the audit live
only in `larsbx/estate-governance`; nothing from it is vendored here. CI checks
governance out at the commit the `estate-governance` `[[dep]]` pins and runs the
audit from there, and the audit verifies its own sha256 against that pin.
The ordering rule is:

```text
authority -> mathematical/domain concern -> implementation language
```

Mojo under `kernel/` is the one canonical executable. Python under `reference/`
is reference semantics and `oracles/` holds research oracles; neither is an
acceptance path. `tools/` is audits and generators only. Packages pinned in
`vendored.toml` live under `vendor/mojo/` and `vendor/python/`, which are their
include roots; Mojo entrypoints run with `-I vendor/mojo`.

The layout is canonical: every plane in `ESTATE.toml` maps exactly its `target`
(root-level files aside), every top-level directory is some plane's target, and
no migration step is pending; the audit enforces all three. Directory renames
alone must not change claim status, acceptance, or authority.
