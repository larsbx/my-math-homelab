# PscVerif — Lean 4 proofs for the PSC Spectral module

Lean checks the exact algebraic statements in these modules. A partial binding
does not prove its full parent claim; the tensor, intertwining, semisimplicity
and Galois arguments are not completely formalized. Universal PSC and uniform
G1/PDS remain unresolved. See [the proof bank](../../docs/proof-bank.md),
[verification architecture](../../docs/verification-architecture.md), and
[the spectral module](PscVerif/Spectral.lean) for scope and evidence.

From the repository root:

```bash
./tools/setup_lean.sh
./tools/check_lean.sh
```

Both scripts force the checked-in compiler release and reject executable
version mismatches. Setup prepares the development environment; formal audit
credit requires the isolated checker. It excludes caller compiled caches,
verifies clean pinned dependency sources, obtains Mathlib artifacts from the
fixed upstream source-hash cache, compiles PSC and replays the complete local
declaration audit. The compiler and upstream cache remain explicit trust inputs.
Every inventoried proof must be reached. Only `propext`, `Classical.choice` and
`Quot.sound` are accepted; `sorryAx`, local axioms, missing proofs or a missing
completion receipt refuse verification. Inventory and individual `#print axioms`
lines alone do not satisfy this gate.
