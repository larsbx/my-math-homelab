# Finite signing parity criterion

Status: executable diagnostic, not a proof of SCC Producer.

This note records the finite-regime version of the Perron-compatible signing test used in the signed ordered-defect program.

## Context

For a recurrent noncoincident SCC `C`, the mass-balance layer produces the unsigned within-SCC child matrix `N_C`.  The ordered-defect layer also records orientation of child copies, giving

```text
N_C = N_C^+ + N_C^-
S_C = N_C^+ - N_C^-
Q_C = N_C - |S_C|
```

When `Q_C != 0`, opposite orientations of the same child type occur and the SCC is in the cancellation branch.

When `Q_C = 0`, every support edge has a well-defined sign.  The support graph then has an edge signing

```text
omega(e) in {+1, -1}
```

encoded over `F_2` by

```text
b(e) = 0  when omega(e) = +1
b(e) = 1  when omega(e) = -1
```

## Period and wrap cochain

Let `h` be the period of the irreducible support graph:

```text
h = gcd(length(gamma) : gamma is a directed cycle in C).
```

Choose cyclic classes

```text
C = C_0 disjoint-union ... disjoint-union C_{h-1}
```

so every edge goes from `C_i` to `C_{i+1 mod h}`.  Define the wrap cochain

```text
lambda(e) = 1  if e : C_{h-1} -> C_0
lambda(e) = 0  otherwise.
```

Then every directed cycle `gamma` satisfies

```text
sum_{e in gamma} lambda(e) = length(gamma) / h   mod 2.
```

## Perron compatibility over F2

The signing is Perron-compatible iff there exists

```text
q in F_2
x : vertices(C) -> F_2
```

such that for every edge `e : s -> t`,

```text
b(e) = x(s) + x(t) + q * lambda(e)   mod 2.
```

Equivalently,

```text
b + q lambda is a coboundary.
```

Cycle form:

```text
sum_{e in gamma} b(e) = q * length(gamma) / h   mod 2
```

for every directed cycle `gamma`.

There are two compatible classes:

- `q = 0`: ordinary switched-positive signing;
- `q = 1`: half-period Perron phase.

If neither `q = 0` nor `q = 1` solves the coboundary system, the signing is Perron-strict.

## Mojo implementation

Canonical implementation:

```text
kernel/finite_graph/signing.mojo   (vendored from larsbx/finite-math-kernels)
```

Regression tests:

```text
kernel/tests/test_signing.mojo
```

Run locally from `kernel/` with:

```bash
pixi run mojo run -I . tests/test_signing.mojo
```

or through the full regression loop, which runs every `tests/test_*.mojo` and
so already covers this one:

```bash
pixi run check
```

## Role in the PSC proof program

The finite classification branch is:

```text
Q_C != 0
  | Q_C = 0 and signing Perron-compatible
  | Q_C = 0 and signing Perron-strict
```

This is a diagnostic layer on top of mass balance and boundary synchronization.  It does not prove SCC Producer by itself.  Its purpose is to classify candidate closed nonproductive SCCs before applying the boundary-trap and ordered-defect arguments.
