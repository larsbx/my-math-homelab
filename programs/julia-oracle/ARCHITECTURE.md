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

Julia is canonical only for the lab's own registry and binding validation
(`src/JuliaOracleLab.jl`). Every oracle is non-authoritative: it may return
`agrees`, `disagrees`, `inconclusive`, or `oracle_error`, never an acceptance
verdict (`docs/AUTHORITY_BOUNDARY.md`).

Oracles live under `oracles/<domain>/`, outside the package's `src/`, which
holds only the kernel; `src/JuliaOracleLab.jl` includes them from there.

The layout is canonical: every plane in `ESTATE.toml` maps exactly its `target`
(root-level files aside), every top-level directory is some plane's target, and
no migration step is pending; the audit enforces all three. Directory renames
alone must not change claim status, acceptance, or authority.
