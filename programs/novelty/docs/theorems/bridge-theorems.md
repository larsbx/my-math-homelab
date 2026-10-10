# Surviving bridge theorems

N2-T01 and N3-T01 retain their mathematical status. N1-T01 is pending
independent review, matching `ZeroDivisorCertificateSoundness` in the ledger.
None is promoted as a novelty claim.

## N1-T01 — zero-product witness soundness

**Status:** pending (written argument; independent proof review not recorded).

**Statement.** Let (A) be a division algebra, in the operational sense that
left and right division by every nonzero element is uniquely possible. If
(a,bin A) are nonzero, then (ab
e0). Hence exact data
(a
e0, b
e0, ab=0) certify that (A) is not a division algebra.

**Proof.** If (a
e0), left multiplication by (a) is injective in a division
algebra. From (ab=0=a0), injectivity gives (b=0), a contradiction. The
right-division formulation gives the symmetric proof. ∎

**Boundary.** This is only a sound rejection certificate. It does not make the
search complete and does not prove that absence of a found witness implies
division.

## N2-T01 — normalized octonionic left multiplication

**Statement.** Let (A) be an eight-dimensional real positive-definite
composition algebra with norm (N). For nonzero (xin A), define
(U_x=L_x/sqrt{N(x)}). Then (U_xin SO(A,N)cong SO(8)).

**Proof.** Polarizing the identity
(N(xy)=N(x)N(y)) shows that
(langle xy,xz
angle=N(x)langle y,z
angle). Therefore
(L_x^{*}L_x=N(x)I), so (U_x) is orthogonal. Its determinant is (+1):
the map (xmapsto U_x) is continuous on (Asetminus{0}), which is
connected because (dim_{mathbb R}A=8>1); the determinant takes values in
the discrete set ({-1,+1}), so it is constant. At (x=1), (U_x=I), and
the determinant is (+1). ∎

**Bridge.** Non-associativity blocks (xmapsto L_x) from being a
multiplicative parametrization, but it does not block the matrices (U_x)
from serving as individual (SO(8)) generators. Products must be taken in
the associative matrix group.

**Boundary.** This says nothing about arithmeticity, density, buildings,
finite-image size, expansion, or covering exponents.

## N3-T01 — factorial collision moments

**Statement.** Let (X,S) be finite sets, (r:X	o S), and
(m_s=|r^{-1}(s)|). For (kge1),
[
sum_{sin S}(m_s)_k
=
|{(x_1,ldots,x_k)in X^k:
x_i	ext{ pairwise distinct and }r(x_1)=cdots=r(x_k)}|,
]
where ((m)_k=m(m-1)cdots(m-k+1)).

**Proof.** Partition the tuples on the right by their common image (s).
Inside the fiber (r^{-1}(s)), the number of ordered selections of (k)
distinct elements is ((m_s)_k). Summing over the disjoint fibers proves the
identity. ∎

For (k=2), this yields
[
sum_s m_s(m_s-1)
=
|{(x,y)in X^2:x
e y, r(x)=r(y)}|.
]
Adding the diagonal gives
[
sum_s m_s^2
=
|{(x,y)in X^2:r(x)=r(y)}|.
]

**Bridge.** Once (X) is an arithmetic shell and equality of reductions is
written as congruence conditions, empirical factorial moments become exact
representation counts. This is the correct handoff to theta-series methods.

**Novelty boundary.** The counting identity is elementary and classical.
Whether the particular arithmetic application and a uniform Poisson theorem
are new remains unassessed.
