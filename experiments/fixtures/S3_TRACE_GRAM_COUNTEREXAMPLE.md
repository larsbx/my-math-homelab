# Exact Counterexample Fixture — \(S_3\) Permutation Representation

## Base field

All calculations in this fixture are over
\[
F=\mathbb Q.
\]

The displayed rank, determinant, characteristic-polynomial, and principal-minor diagnostics are claims over \(\mathbb Q\). They are not asserted unchanged after reduction modulo arbitrary primes.

## Representation

Let
\[
G=S_3
\]
act by permutation matrices on \(\mathbb Q^3\).

For a permutation \(h\),
\[
\chi(h)=\#\operatorname{Fix}(h),
\]
so
\[
K_{ij}=\chi(g_i g_j^{-1}).
\]

## Input tuple

\[
\mathbf g=((23),(23),(123),(132)).
\]

Its product is the identity.

## Hurwitz convention

\[
\beta_i(x,y)=(y,y^{-1}xy).
\]

Applying \(\beta_2\) gives
\[
((23),(23),(123),(132))
\longmapsto
((23),(123),(12),(132)).
\]

## Before

\[
K=
\begin{pmatrix}
3&3&1&1\\
3&3&1&1\\
1&1&3&0\\
1&1&0&3
\end{pmatrix}.
\]

Exact diagnostics over \(\mathbb Q\):

- determinant: \(0\);
- rank: \(3\);
- characteristic polynomial:
  \[
  t^4-12t^3+41t^2-42t;
  \]
- principal minors by size:
  - size 1: \([3,3,3,3]\);
  - size 2: \([0,8,8,8,8,9]\);
  - size 3: \([0,0,21,21]\);
  - size 4: \([0]\).

## After

\[
K'=
\begin{pmatrix}
3&1&0&1\\
1&3&1&0\\
0&1&3&1\\
1&0&1&3
\end{pmatrix}.
\]

Exact diagnostics over \(\mathbb Q\):

- determinant: \(45\);
- rank: \(4\);
- characteristic polynomial:
  \[
  t^4-12t^3+50t^2-84t+45;
  \]
- principal minors by size:
  - size 1: \([3,3,3,3]\);
  - size 2: \([8,8,8,8,9,9]\);
  - size 3: \([21,21,21,21]\);
  - size 4: \([45]\).

## What this fixture proves

A single Hurwitz move can change:

- \(\det K\);
- \(\operatorname{rank}K\);
- the characteristic polynomial of \(K\);
- the multiset of principal minors.

Therefore none of these is a full braid invariant in general.

## What this fixture does not prove

It does not prove that the post-Hurwitz matrix \(K'\) is not determined by \(K\) through some representation-independent or representation-specific rule. A genuine non-closure proof needs stronger evidence.
