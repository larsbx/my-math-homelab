# Python reference plane

These modules are independent, non-authoritative executable semantics used for
differential checking, exact regression vectors, and research validation.

They may disagree with the canonical Mojo kernel. Such disagreement fails the
relevant conformance gate; it does not transfer authority to Python.

- `arithmetic/` — exact arithmetic differential model and canonical-byte checks.
- `polynomial/` — integer-polynomial reference identities and exact-type irreducibility certificates.
- `interval/` — rational interval exclusion semantics.
- `c1/` — finite C1 combinatorics, catalogues, prefix graphs, tuning and density.
- `atlas/` — exact checks for the names atlas (`schemas/structure_names.toml`).

Files of the same historical names under `tools/` are compatibility shims.
New code, tests, and CI use `reference/python/` directly.
