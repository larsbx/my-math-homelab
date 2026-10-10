# Native Krawczyk computation for P21

Status: implemented as native Mojo-shaped interval computation over the current rational interval scaffold.

## Target

For the antenna-tip Misiurewicz point `c=-2`, the squarefree localization polynomial is

```text
P21(C) = C(C+2)
```

with derivative

```text
dP21(C) = 2C+2
```

At the target center `m=-2`,

```text
P21(m) = 0

dP21(m) = -2
```

so the exact inverse approximation used in the witness is

```text
A = -1/2
```

## Native witness formula

The committed `kernel/mojo/certificates/krawczyk_witness.mojo` now computes

```text
K(beta) = m - A P(m) + (1 - A P'(beta))(beta - m)
```

with rational complex intervals. The demo status no longer returns a hard-coded acceptance bit; it calls

```text
verify_p21_krawczyk_c_minus_2(8)
```

and stores the computed result.

## Scope

This is still not final certificate-grade arithmetic because the rational backend is currently `Int64`, not arbitrary precision. But the control flow is now correct:

1. evaluate the squarefree polynomial on intervals;
2. evaluate the derivative on the same box;
3. compute the Krawczyk image;
4. require strict inclusion in the original box;
5. feed that result into the joint certificate gate.

## Remaining hard target

`P41` / `M_{4,1}` remains placeholder-only until native polynomial interval evaluation supports the full squarefree polynomial

```text
P41(C)=C(C+2)(C^3+2C^2+2C+2)F7
```

and a dyadic inverse enclosure for `1/P41'(m)`. The validator must not accept `M_{4,1}` before that lands.
