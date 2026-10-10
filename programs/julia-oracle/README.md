# Julia Oracle Lab

Shared, non-authoritative Julia research oracles and experimental spikes for the larsbx research estate.

The lab provides reusable exact/numerical research infrastructure, reproducibility envelopes, registry validation, and differential-test harnesses. Domain repositories retain their claims, fixtures, and authoritative-checker bindings.

Julia may return only `agrees`, `disagrees`, `inconclusive`, or `oracle_error`. It does not prove claims, accept certificates, authorize effects, or control deployments.

## Active research integrations

- **PSC Tier 2 Growth Bridge:** `docs/GROWTH_BRIDGE_LOOP_GAIN_ORACLE.md`
  specifies an independent exact oracle for cycle bases, loop gains, and the
  generated arithmetic module of a recurrent packet component. PSC remains the
  domain owner and Mojo remains authoritative.

## Install from Git

The package is currently available directly from its public repository:

```julia
using Pkg
Pkg.add(url = "https://github.com/larsbx/julia-oracle-lab.git")
```

For reproducible use, pin the merged conformance commit:

```julia
using Pkg
Pkg.add(url = "https://github.com/larsbx/julia-oracle-lab.git", rev = "0d7b48ffc843fd2b0db9166cb400c542ec010fa8")
```

The package requires Julia 1.11. It is not yet registered in Julia's General registry.

## First exact oracle

```julia
using JuliaOracleLab

encoded = canonical_bigint_bytes(big"-1000000001")
@assert bytes2hex(encoded) == "0200000000000000043b9aca01"

expected = hex2bytes("0200000000000000043b9aca01")
@assert compare_bytes(encoded, expected) == agrees

corrupted = hex2bytes("0200000000000000043b9aca00")
@assert compare_bytes(encoded, corrupted) == disagrees
```

The encoding is bound to the canonical BigInt byte contract in `larsbx/finite-math-kernels`, boundary `shared-finite-kernel`. The historical `NLAP-JT` name is not a stable package or oracle identity during its migration.

## Status and authority

A successful oracle comparison is independent evidence only. It does not become a proof or certificate-acceptance result. Canonical Forgejo reconciliation and Woodpecker execution remain required by the estate workflow.

See [the authority boundary](docs/AUTHORITY_BOUNDARY.md), [oracle registry](registry/oracles.toml), and [legacy NLAP provenance policy](docs/LEGACY_NLAP_PROVENANCE.md).
