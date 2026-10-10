# Applying estate repository template v1 to finite Mandelbrot

Status: first consumer; migration complete (`layout_status = "canonical"`).

This repository is intentionally the first adopter because its current tree already
contains every important estate role: canonical Mojo kernels, claim/proof state,
Python references and audits, Julia oracle/spike lanes, generated ledgers, vendored
packages, schemas, conformance tests, research documentation, and a paper.

No mathematical claim changes in this adoption.

## Layout

| Authority plane | Location |
| --- | --- |
| policy | root TOML manifests (`ESTATE.toml`, `backend.toml`, `claim_governance.toml`, `polyglot.manifest.toml`, `vendored.toml`), which the tools locate at the root |
| canonical kernel | `kernel/mojo/<domain>/` |
| C1 proof state | `proof/c1/` (`records.toml`, `models/tla/`); `ledger.json` is its generated projection at the root |
| mathematical references | `reference/python/<domain>/` |
| research oracles | `oracles/julia/` |
| experiments | `experiments/julia/` |
| schemas | `schemas/` (the polyglot envelope schemas stay in the shared `.polyglot/` scaffold) |
| conformance | `tests/` |
| vendored source | `vendor/mojo/`, `vendor/python/` |
| repository tooling | `tools/` |
| documentation | `docs/` |
| publication | `paper/` |
| examples | `examples/` |

## How the migration stayed semantic-preserving

The architecture was declared first, with every existing path live, and each
later slice moved one boundary with its imports, tests and documentation in the
same change. Moving files never changed claim status: the ledger surfaces are
regenerated from `proof/c1/records.toml` and `tools/make_ledger.py --check`
proves them current, and the smoke suite, the full test suite and every audit
pass unchanged.

## Follow-on migrations

### 1. Declarative C1 proof plane — implemented

The authoritative C1 claim-state data now lives in `proof/c1/records.toml`.
`tools/make_ledger.py` validates and renders it; the generator no longer embeds
the theorem-status table. Generated surfaces remain at their historical paths
for now so this slice does not mix source-of-truth extraction with path moves.

The eventual fully migrated shape remains:

```text
proof/c1/
  records.toml                 # canonical claim/proof record data
  imports/
  models/tla/
  generated/
    ledger.json
    ledger.md
    relationship-graph.json
    mojo/
```

Generators contain mechanism, not the authoritative theorem-status table. This first migration satisfies that rule; moving generated projections under `proof/c1/generated/` is deferred until consumers can move atomically.

### 2. Reference/tool split — implemented

Independently written mathematical semantics now live under `reference/python/`
by domain. Repository maintenance, audits and generators remain under `tools/`.
Historical `tools/*_reference.py` and `tools/*_oracle.py` entrypoints are thin
compatibility shims only; CI and new tests target the reference plane directly.

### 3. Kernel namespaces — implemented

The flat `C1_*.mojo` pseudo-namespace is replaced by domain packages; inside
`c1/` the `C1_` prefix is dropped because the package carries it. Every Mojo
import is the dotted package path (`from c1.separator.separator_codes import ...`):

```text
kernel/mojo/
  c1/{bridge,separator,carrier,residual,wake,theorem_tags,proof}/
  arithmetic/  polynomial/  dynamics/
  certificates/  certificates/c_minus_2/
  theorem_kernel/  smoke/  entrypoints/
```

This is a semantic-preserving import migration: every entrypoint compiles and
the smoke suite reports the same 65 cases.

### 4. Vendor boundary — implemented

The finite-math-kernels packages live under `vendor/mojo/` and `vendor/python/`,
the roots `vendored.toml` names. No pinned byte changed: the digest check passes
before and after the move. Mojo entrypoints run with `-I kernel/mojo -I
vendor/mojo`; Python call sites take the same roots from `tools/mojo_include.py`.

### 5. CI authority lanes — implemented

The core audit runs as policy, kernel, proof, reference/oracle, paper, and a final
integration lane that needs the other five. A failing lane identifies which
authority plane is red.

## Invariants during migration

- Mojo remains the current canonical executable certificate/proof-object checker.
- Julia and Python remain non-authoritative for acceptance.
- C1 status cannot change as a side effect of a path move.
- Imported analytic theorem assumptions remain explicit.
- Vendored digest checks remain fail-closed.
- Generic boundary completeness remains open unless separately proved.
