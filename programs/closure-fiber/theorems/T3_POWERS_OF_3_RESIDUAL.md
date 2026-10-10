# T3 Residual — The \(3^k\) Cyclotomic Equality Problem

## Problem

After the mod-\(3\) sign theorem and the exact finite certificate, odd prime-power equality reduces to

\[
J_2(3^k-1)=J_2(3^k+1),
\qquad k\ge6.
\]

No equality is currently known.

This file records the admissible reduction and the proof obligations for the residual family.

## Why the previous argument stops

For \(q\not\equiv0\pmod3\), one of \(q-1,q+1\) is divisible by \(3\), producing a fixed \(8/9\) Jordan penalty. For

\[
q=3^k,
\]

neither \(q-1\) nor \(q+1\) is divisible by \(3\).

Thus the mod-\(3\) comparison theorem supplies no directional bias.

Moreover, exact computation shows that

\[
\Delta_k
:=
J_2(3^k+1)-J_2(3^k-1)
\]

takes both signs. Hence no monotone-sign statement is admissible.

## First exact values

The signs for the first twenty exponents are:

| \(k\) | sign of \(\Delta_k\) |
|---:|:---:|
| 1 | \(+\) |
| 2 | \(+\) |
| 3 | \(+\) |
| 4 | \(+\) |
| 5 | \(+\) |
| 6 | \(-\) |
| 7 | \(+\) |
| 8 | \(+\) |
| 9 | \(-\) |
| 10 | \(-\) |
| 11 | \(+\) |
| 12 | \(+\) |
| 13 | \(+\) |
| 14 | \(-\) |
| 15 | \(-\) |
| 16 | \(+\) |
| 17 | \(-\) |
| 18 | \(-\) |
| 19 | \(+\) |
| 20 | \(+\) |

This table is exploratory evidence only.

## Cyclotomic decomposition

The minus side has the standard factorization

\[
3^k-1
=
\prod_{d\mid k}\Phi_d(3).
\]

The plus side can be written as the quotient

\[
3^k+1
=
\frac{3^{2k}-1}{3^k-1}
=
\prod_{\substack{d\mid 2k\\ d\nmid k}}\Phi_d(3).
\]

Thus every prime divisor on either side is controlled by multiplicative-order data for \(3\).

The two integers satisfy

\[
\gcd(3^k-1,3^k+1)=2.
\]

## Jordan-factor formulation

For any \(n\),

\[
J_2(n)
=
\prod_{p^a\parallel n}
p^{2a-2}(p^2-1).
\]

Therefore equality would require an exact identity

\[
\prod_{p^a\parallel 3^k-1}
p^{2a-2}(p^2-1)
=
\prod_{r^b\parallel 3^k+1}
r^{2b-2}(r^2-1).
\]

A primitive prime divisor of \(3^m-1\) does not automatically divide \(J_2(3^m-1)\) when it occurs only to the first power: its contribution is \(p^2-1\), not \(p\). Any Zsigmondy argument therefore has to track prime divisors of the factors \(p^2-1\), not merely primitive primes of the cyclotomic values themselves.

This is the main obstruction to a naive primitive-divisor proof.

## Valuation program

Equality implies, for every prime \(\ell\),

\[
v_\ell(J_2(3^k-1))
=
v_\ell(J_2(3^k+1)).
\]

Priority valuations are \(\ell=2,3\), since every odd prime contribution \(p^2-1\) is even, and every \(p\ne3\) satisfies

\[
p^2\equiv1\pmod3.
\]

However, small-exponent experiments show that neither \(2\)-adic nor \(3\)-adic valuations alone separate all exponents.

The next useful lemma should therefore combine:

- valuation data,
- multiplicative orders of \(3\) modulo prime divisors,
- and the disjoint cyclotomic supports of \(3^k-1\) and \(3^k+1\).

## Admissible theorem targets

A valid next result may be any of:

1. equality is impossible for every \(k\ge6\);
2. equality is impossible outside an explicit arithmetic progression in \(k\);
3. equality forces an explicit finite list of cyclotomic/valuation constraints;
4. equality is reduced to a finite computation by a genuine global theorem.

## Non-results to avoid

Do not claim:

- a fixed finite set of small primes controls all exponents;
- the sign of \(\Delta_k\) is eventually constant;
- primitive prime divisors alone distinguish the Jordan values;
- the absence of equality in a large finite search proves finiteness.
