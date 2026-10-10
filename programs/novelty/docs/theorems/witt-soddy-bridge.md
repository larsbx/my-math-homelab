# Witt-stabilized Soddy–Gossett bridge

## Setup

Let (F=mathbb F_q) have odd characteristic, let (nge6), and assume
(operatorname{char}F
mid n). The normalized Descartes form on
(F^{n+2}) is
[
Q_{D,n}(b)=sum_i b_i^2-rac1nleft(sum_i b_iight)^2.
]
Its Gram matrix is (I-rac1nJ). It has eigenvalue (1) on the
((n+1))-dimensional sum-zero subspace and eigenvalue (-2/n) on the
all-ones line. Hence
[
det Q_{D,n}=-2/n.
]

Let ((C,N)) be the split eight-dimensional octonion norm space. Its
determinant square class is (1).

## N2-T06 — canonical stabilization up to conjugacy

For (n>6), choose a nondegenerate quadratic space (T_n) of dimension
(n-6) and determinant square class (-2/n). For example, the diagonal
representative
[
T_n=langle1,ldots,1,-2/nangle
]
has the required dimension and determinant. Then
[
(C,N)perp T_n
]
and ((F^{n+2},Q_{D,n})) have the same dimension and determinant. The
classification of nondegenerate quadratic forms over finite fields of odd
order therefore gives an isometry
[
phi_n:(C,N)perp T_noverset{sim}{longrightarrow}
(F^{n+2},Q_{D,n}).
]

For an octonionic defect (Deltain O(C,N)), define
[
iota_{phi_n}(Delta)
=
phi_n(Deltaperp I_{T_n})phi_n^{-1}.
]
This is an injective homomorphism into (O(Q_{D,n})).

If (phi_n') is another selected isometry, then
(g=phi_n'phi_n^{-1}in O(Q_{D,n})), and
[
iota_{phi_n'}(Delta)
=
g,iota_{phi_n}(Delta),g^{-1}.
]
Changing the representative of (T_n) also changes the construction only by
conjugacy, using finite-field classification and Witt extension. Thus the
embedded subgroup, its orbit sizes, fixed-point counts, and conjugacy-class
statistics are canonical up to orthogonal conjugacy. ∎

For (n=6), no complement is available. A direct isometry exists precisely
when (-2/6=-1/3) is a square. For prime fields of characteristic greater
than three this is equivalent to (-3) being a square; in particular, it
holds for primes (ellequiv1pmod3).

## Full configuration action

The bridge is not limited to bend vectors. Higher-dimensional augmented
curvature-center configurations satisfy
[
W^TQ_{D,n}W=Q_{W,n}.
]
If (Ain O(Q_{D,n})), then
[
(AW)^TQ_{D,n}(AW)=W^TQ_{D,n}W=Q_{W,n}.
]
Therefore the transported defects act on the entire finite ACC configuration
variety, not merely on its curvature null cone.

## Why this is the canonical construction

No tensor product, Clifford representation, repeated octonion block, basis
ordering, or chosen square root is needed. The only added object is the
minimal-dimensional quadratic complement forced by dimension and
discriminant. Coordinate choices disappear after passing to orthogonal
conjugacy invariants.

The quadratic-form ingredients are classical. The research candidate is the
comparison between transported defect strata, reduced Apollonian orbits, and
their combined finite action.
