# Exact Counterexample Fixture — S3 permutation representation

Purpose: preserve a smallest explicit witness that naive trace-Gram spectral data is not invariant under a Hurwitz move.

## Representation

(G=S_3) acting by permutation matrices on (F^3).

For a permutation (h),
[
chi(h)=#operatorname{Fix}(h).
]

Hence
[
K_{ij}=chi(g_i g_j^{-1}).
]

## Input tuple

[
((23),(23),(123),(132)).
]

The product is the identity.

## Hurwitz convention

[
eta_i(x,y)=(y,y^{-1}xy).
]

Apply (eta_2):

[
((23),(23),(123),(132))
mapsto
((23),(123),(12),(132)).
]

## Before

[
K=
egin{pmatrix}
3&3&1&1\
3&3&1&1\
1&1&3&0\
1&1&0&3
end{pmatrix}.
]

Exact diagnostics:

- determinant: (0)
- rank: (3)
- characteristic polynomial:
  [
  t^4-12t^3+41t^2-42t
  ]
- principal minors by size:
  - size 1: ([3,3,3,3])
  - size 2: ([0,8,8,8,8,9])
  - size 3: ([0,0,21,21])
  - size 4: ([0])

## After

[
K'=
egin{pmatrix}
3&1&0&1\
1&3&1&0\
0&1&3&1\
1&0&1&3
end{pmatrix}.
]

Exact diagnostics:

- determinant: (45)
- rank: (4)
- characteristic polynomial:
  [
  t^4-12t^3+50t^2-84t+45
  ]
- principal minors by size:
  - size 1: ([3,3,3,3])
  - size 2: ([8,8,8,8,9,9])
  - size 3: ([21,21,21,21])
  - size 4: ([45])

## Research significance

This fixture falsifies, in one exact example, braid invariance of:

- (det K),
- (operatorname{rank}K),
- the characteristic polynomial of (K),
- the multiset of principal minors.

Retain this fixture permanently as a regression test for any proposed "trace-Gram invariant."
