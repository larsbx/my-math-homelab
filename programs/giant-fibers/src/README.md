# Implementation scaffold

Mojo is the intended first-class language for exact kernels in this repository.

Planned modules:

- `field.mojo` — prime-field arithmetic and deterministic inverses;
- `projective.mojo` — canonical projective representatives;
- `quadratic_form.mojo` — Gram matrices, (Q), (B), rank/discriminant;
- `witt.mojo` — split/nonsplit diagnostics in dimension four;
- `descartes.mojo` — frozen Descartes normalization;
- `fibers.mojo` — exact (N_c(a)) enumeration;
- `certificates.mojo` — deterministic run records and hashes;
- `apollonian.mojo` — congruence orbit generation and random-walk diagnostics.

Implementation should begin only after the normalization in claim P0 is frozen, so code does not accidentally canonize an unreviewed convention.
