# T3 Powers-of-3 Residual — Valuation Counterexamples

## Purpose

A natural first attempt at the residual equation

\[
J_2(3^k-1)=J_2(3^k+1)
\]

is to compare small-prime valuations of the two Jordan values.

This file records exact counterexamples showing that matching the \(2\)-adic and \(3\)-adic valuations is not sufficient to imply equality.

## Case \(k=19\)

\[
q=3^{19}=1162261467.
\]

Factorizations:

\[
q-1
=
2\cdot1597\cdot363889,
\]

\[
q+1
=
2^2\cdot2851\cdot101917.
\]

Jordan values:

\[
J_2(q-1)
=
1013138389258087680,
\]

\[
J_2(q+1)
=
1013138665255699200.
\]

Hence

\[
\Delta_{19}
=
275997611520
\ne0.
\]

Nevertheless,

\[
v_2(J_2(q-1))
=
v_2(J_2(q+1))
=
8,
\]

and

\[
v_3(J_2(q-1))
=
v_3(J_2(q+1))
=
4.
\]

Thus simultaneous agreement of \(v_2\) and \(v_3\) does not force equality.

## Case \(k=25\)

\[
q=3^{25}=847288609443.
\]

Factorizations:

\[
q-1
=
2\cdot11^2\cdot8951\cdot391151,
\]

\[
q+1
=
2^2\cdot61\cdot151\cdot22996651.
\]

Jordan values:

\[
J_2(q-1)
=
533973703184052595200000,
\]

\[
J_2(q+1)
=
538255184486583513600000.
\]

Hence

\[
\Delta_{25}
=
4281481302530918400000
\ne0.
\]

But again,

\[
v_2(J_2(q-1))
=
v_2(J_2(q+1))
=
12,
\]

and

\[
v_3(J_2(q-1))
=
v_3(J_2(q+1))
=
4.
\]

## Case \(k=37\)

A weaker warning occurs at \(k=37\):

\[
v_2(J_2(3^{37}-1))
=
v_2(J_2(3^{37}+1))
=
14,
\]

while

\[
v_3(J_2(3^{37}-1))=3,
\qquad
v_3(J_2(3^{37}+1))=5.
\]

So even the \(2\)-adic valuation alone fails to separate all exponents.

## Consequence

The residual proof cannot rely solely on:

- \(v_2\);
- \(v_3\);
- or the pair \((v_2,v_3)\).

A useful valuation theorem must either:

1. incorporate a prime \(\ell\) selected from cyclotomic/order data depending on \(k\);
2. combine valuations with structural information about primitive divisors;
3. or prove that equality forces an impossible global pattern across many valuations.

These examples should remain regression fixtures for any proposed valuation-only proof.
