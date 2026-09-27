# The escape criterion, derived

**Status:** derivation, dated 2026-09-20. It states what
`kernel/julia_orbit.mojo` was entitled to conclude from its escape test, what it
was not, and the finite certificate that closes the gap. The proofs below are
elementary and are this repository's own; nothing classical is imported and no
theorem tag is added.

## 0. The issue

The test is

```text
N(z) > max(4, N(c)),        N(x, y) = x^2 + y^2
```

and it is a **sound criterion**: every `z` past that bound does have an
unbounded orbit. The problem was never that the bound is wrong. It is that
the repository was treating the *conclusion* as verified when only the *test*
was.

- What the code computes is that a quadrance passed a bound at step `n`.
- What `ESCAPES(n)` was read to mean, in the ledger's verified column and in
  `docs/J1_finite_classical_dictionary.md`, is that the orbit tends to
  infinity.
- The step between them is the classical escape criterion. It was derived
  nowhere in this repository and tagged nowhere in
  `docs/literature-gate-2026-09-19.md`, which covers only the Cantor structure
  of the resulting Julia set.

So a decided verdict rested on an unnamed import, which is the one thing the
programme's own rules do not allow. A gate that had been run would have caught
it; the escape criterion never went through one.

The usual textbook derivation would not have helped much, because it is not a
statement this layer can make: it runs through `|z^2 + c| >= |z|^2 - |c|` and
`|<z^2, c>| <= |z| |c|`, both natural in the modulus and both leaving the
polynomial world. What follows avoids the modulus entirely.

## 1. The certificate

Write `t = N(z)` and `m = N(c)`, both exact rationals. A **rational ratio**
`r > 1` certifies escape from `t` when

```text
m <= t,    t > 1 + r,    T(t, r) > 0
```

where

```text
T(t, r) = t^2 - 2t(1 + r) + (r - 1)^2
```

The claim the certificate makes is not about a limit:

```text
N(f_c(z)) >= r * t,    and the same r certifies the next step
```

so `N(f_c^n(z)) >= r^n * t`, which is unbounded because `r > 1`. Every
quantity is rational, every comparison is exact, and no square root occurs.

## 2. Why it holds

Expand the quadrance of one step, with `<a, b> = a_x b_x + a_y b_y`:

```text
N(z^2 + c) = t^2 + 2<z^2, c> + m
```

By Cauchy-Schwarz `<z^2, c>^2 <= N(z^2) N(c) = t^2 m`, so the step is bounded
below by `t^2 + m` minus twice the largest that cross term can be. Asking for
`N(f_c(z)) >= r t` is therefore asking for

```text
t^2 + m - r t >= 2 |<z^2, c>|,    which follows from    (t^2 + m - r t)^2 >= 4 t^2 m
```

once the left side is non-negative, which `t > 1 + r > r` gives. Expand that
square as a quadratic in `m`:

```text
G(t, m, r) = (t^2 + m - r t)^2 - 4 t^2 m = m^2 - 2t(t + r) m + t^2 (t - r)^2
```

`G` is a parabola in `m` with vertex at `m = t(t + r)`, which exceeds `t`, so
on `0 <= m <= t` it is decreasing and its minimum is at `m = t`. There

```text
G(t, t, r) = t^2 * T(t, r)
```

which is positive by hypothesis. So `G >= 0` on the whole range of `m` the
certificate allows, and the growth claim follows.

**Preservation.** The next quadrance is at least `r t > t`, and `T` is
increasing in `t` past its vertex `t = 1 + r`, so both `t > 1 + r` and
`T(t, r) > 0` still hold at `r t`, and `m <= t <= r t` still holds. One
certificate covers the forward orbit. []

## 3. The trap, and why the vertex condition is there

`T(t, r)` has roots `(sqrt(r) - 1)^2` and `(sqrt(r) + 1)^2`, so **`T > 0` holds
on both sides of the parabola**, and only the upper side is the one the proof
uses. The first draft of this certificate omitted `t > 1 + r` and accepted the
lower branch, where the claim is false: at

```text
t = 163/31,    m = 98/19,    r = 263/19
```

`T(t, r) > 0` and yet the true next quadrance is about `5.4`, far below
`r t = 72.8`. A randomised search over rationals found this in seconds. It is
now `test_the_lower_branch_is_rejected` in
`tests/test_escape_certificate.py`, and the vertex condition is the fix.

The admissible ratios are exactly the interval `1 < r < (sqrt(t) - 1)^2`,
which is nonempty precisely when `t > 4`. So the certificate and the classical
threshold agree about where they apply, and the strict inequality in
`kernel/julia_orbit.mojo` is the right one: at `t = 4` the interval is empty.

## 4. What `ESCAPES` now means

| | before | after |
| --- | --- | --- |
| computed | the quadrance passed `max(4, N(c))` at step `n` | unchanged |
| concluded | the orbit tends to infinity | the quadrance grows by at least a rational `r > 1` at every step from `n` on |
| rests on | an unnamed classical import | section 2, in this repository |

`reference/escape_certificate.py` and `kernel/escape_certificate.mojo` compute the
ratio; `reference/julia_reference.py` attaches it to the verdict, and a test
asserts that every `ESCAPES` row of the corpus carries one. A parameter with
no certificate is not thereby bounded: absence is the fail-closed reading,
not a claim.

## 5. What this does not do

It does not prove that the Julia set of an escaping parameter is a Cantor set;
that remains the imported tag `FatouJuliaEscapingCantorSet` in
`docs/literature-gate-2026-09-19.md`, and it is a statement about the set, not
about one orbit. It does not make the bound tight: the certificate is exactly
as strong as the criterion it replaces, and the only thing that changed is
that the implication is now written down.
