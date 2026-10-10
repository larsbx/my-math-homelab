# Mojo source scaffold

Mojo is the first-class language for exact computational experiments in this repository.

Initial modules should cover:

- `quadratic_etale.mojo` — rank-two algebra (F[t]/(t^2-d)) using matrix records;
- `norm_one.mojo` — norm-one membership and multiplication;
- `finite_field.mojo` — exact finite-field backends;
- `nielsen.mojo` — product-one tuple and Hurwitz-move machinery;
- `trace_gram.mojo` — exact trace-Gram matrices and candidate invariants.

No floating-point geometry should appear in theorem-supporting code.
