# Euclidean code-hull tower interface

Claim: **ABC-CODE-HULL-TOWER**. Status: proved by the ring arguments
below, independently of finite enumeration. This closes research task
**ABC-HULL-01**; the task ID is not a theorem ID. No novelty or
machine-checked formal proof is claimed.

## 1. Domain and presentations

Fix any integer matrix A of shape r by e. No essentiality, surjectivity,
TU, or nonzero-rank hypothesis is imposed. Let n >= 2, R_n = Z/n,
E_n = R_n^e and P_n = R_n^r. All vectors are columns. Use the standard
bilinear coordinate pairing x^T z on E_n (also in characteristic two).
Write

\[
C_n=\operatorname{im} A^T,\quad G=AA^T,\quad
K_n=\ker(G:P_n\to P_n),\quad N_n=\ker(A^T:P_n\to E_n),
\quad Q_n=K_n/N_n.
\]

For x in E_n, orthogonality to C_n means y^T A x=0 for every y in
P_n. Testing coordinate unit vectors gives Ax=0, and Ax=0 gives the
converse. Hence

\[
C_n^\perp=\ker A,\qquad
H_n:=\operatorname{Hull}(C_n)=C_n\cap C_n^\perp
=\operatorname{Bic}_n(A).
\]

Since G=A A^T, N_n is contained in K_n. The restriction A^T|K_n
has kernel N_n and image H_n: its images are cycles, and any
x=A^T y in the hull satisfies Gy=Ax=0. Thus the following sequence
is exact and induces the displayed R_n-module isomorphism:

\[
0\longrightarrow N_n\longrightarrow K_n\xrightarrow{A^T}H_n
\longrightarrow0,\qquad
\phi_n:Q_n\xrightarrow{\sim}H_n,\quad [y]\mapsto A^T y.
\]

The inverse sends x to the class of any potential y with A^T y=x.
Such y lies in K_n; two choices differ by N_n. Both inverse identities
follow immediately. The quotient is essential: for A=(2), n=4,
K_4 has four elements, N_4 has two, and H_4={0,2} has two.
Neither a division by a nonunit nor a field-rank argument occurs.
The same statements include zero rows, zero columns, and redundant rows.
At n=1 all modules and maps are trivial; the executable convention is n>=2.

## 2. Transition maps on all three terms

For n dividing m, set d=m/n. Define coordinate maps on potentials and
edges by

\[
\rho_{m,n}(v\bmod m)=v\bmod n,\qquad
\iota_{n,m}(v\bmod n)=d v\bmod m.
\]

Reduction is well defined since n divides m. Inflation is independent
of an integer lift: replacing v by v+nz changes dv by mz. It is
injective on the ambient coordinate groups since m divides dv
coordinatewise exactly when n divides v. Both maps are additive and
Z-linear; reduction is linear with respect to R_m -> R_n. Inflation
is R_m-linear if its domain is an R_m-module through this reduction.
It is not a unital ring inclusion R_n -> R_m; do not presume a
canonical R_n-module structure on the whole target.

Every integer matrix commutes with these coordinate maps. Reduction
therefore preserves K, N, cuts and cycles. If Gy=0 mod n, then
G(dy)=dGy=0 mod m; if A^T y=0 mod n, the same calculation preserves N.
If x=A^T y is a cycle mod n, then dx=A^T(dy) is a cycle mod m.
Consequently the quotient transitions are precisely

\[
\bar\rho_{m,n}([y]_m)=[y\bmod n]_n,\qquad
\bar\iota_{n,m}([y]_n)=[dy\bmod m]_m.
\]

Changing y by a member of N in either source changes its image by a
member of N in the target, so these maps are independent of quotient
representatives as well as integer lifts. The identities

\[
\phi_n\bar\rho_{m,n}=\rho_{m,n}\phi_m,\qquad
\phi_m\bar\iota_{n,m}=\iota_{n,m}\phi_n
\]

are both the equality A^T(dy)=dA^T y or its reduction version.
Thus the exact sequences in section 1 commute with both transitions.
Inflation on Q is injective: if dy belongs to N_m, then dA^T y=0
mod m, so A^T y=0 mod n and y belongs to N_n. Reduction need not
be surjective on H or Q: for A=(1,1), H_2={(0,0),(1,1)}, whereas
H_4={(0,0),(2,2)} reduces to zero.

For n|m|l the reduction maps compose and inflation maps compose,
since (l/m)(m/n)=l/n. Equal-modulus maps are identities. At both
levels, the two round trips for n|m are multiplication by d:

\[
\rho_{m,n}\iota_{n,m}=d\,\mathrm{id}_{H_n},\qquad
\iota_{n,m}\rho_{m,n}=d\,\mathrm{id}_{H_m},
\]

and identically on Q. For the second equality, changing v to its
reduction changes dv by a multiple of m. These maps are generally
not inverses. No assertion that kernels commute with tensor reduction
or that every small-modulus hull element lifts by reduction is used.

## 3. Coordinate equivalences and naturality

At a fixed modulus, an R_n-linear coordinate map x -> Sx preserves
the standard pairing on all vectors if and only if S^T S=I mod n.
Indeed the pairing difference is x^T(S^T S-I)z; testing pairs of
coordinate units proves necessity. Sufficiency is immediate. This
condition implies invertibility, with inverse S^T: determinants give
a unit determinant and the adjugate gives an inverse over R_n.
These are precisely the orthogonal coordinate transformations.

Let U be any invertible r by r matrix over R_n, let S be orthogonal,
and take A'=U A S^T mod n. Then

\[
C'_n=S C_n,\quad (C'_n)^\perp=S C_n^\perp,\quad H'_n=S H_n,
\quad G'=U G U^T.
\]

The potential map T=U^{-T} carries K_n onto K'_n and N_n onto N'_n,
because G'Ty=UGy and A'^T Ty=S A^T y. It induces an isomorphism
Q_n -> Q'_n, [y] -> [U^{-T}y], and the quotient-to-hull square
commutes. The inverse maps use U^T and S^T. This is a specified
witness, not a canonical comparison inferred from arithmetic data.

For an entire tower, use compatible families U_n, S_n whose reductions
from m to n agree whenever n|m, with U_n invertible and S_n orthogonal
at every level. Their inverses also reduce compatibly. Both coordinate
squares commute with reduction. They commute with inflation because
S_m-S_n and U_m^{-T}-U_n^{-T}, using any lifts, have entries divisible
by n, and multiplication by d makes these differences zero modulo m.
The resulting target matrices A'_n=U_n A S_n^T form a compatible
matrix family; they need not arise from one fixed integer matrix.
Unrelated fixed-modulus witnesses do not supply a tower equivalence.

In particular, a fixed U in GL_r(Z) and fixed integral S with S^T S=I
give A'=UAS^T over the integers and work at every modulus. Such integral
S are exactly signed permutations: each column has integer squares
summing to one, hence exactly one nonzero entry, equal to +/-1, and
orthogonality forces distinct positions. Conversely signed permutations
satisfy S^T S=I. If a single integer S preserves the standard pairing
at every n>=2, each entry of S^T S-I is divisible by every n, hence
zero; the same classification applies. Fixed-modulus isometries can
be broader: [[2,3],[3,-2]] has S^T S=13I, so it is orthogonal mod 12
and its divisors, but not over Z or at every modulus. A fixed integer
U invertible at every modulus has determinant +/-1, since any prime
divisor of its determinant would obstruct invertibility.

This characterizes preservation of the pairing on the full coordinate
module, not all accidental hull isomorphisms. Unit similitudes can also
preserve orthogonality and hulls without preserving the pairing itself.
Neither those nor arbitrary general linear maps are implicitly admitted
by this standard-pairing isometry interface.

## 4. Transporting a different pairing and negative controls

For arbitrary invertible S, the transformed code is S C_n, but its
standard dual is S^{-T}C_n^perp, which need not equal S C_n^perp.
To transport the original bilinear pairing, use the matrix
J'=S^{-T}S^{-1}; then (Sx)^T J'(Sz)=x^T z. This gives
Hull_{J'}(SC_n)=S Hull_I(C_n). With A'=A S^T, the transported dual
is ker(A'J')=ker(A S^{-1}), not generally ker A'. It therefore is
not the standard bicycle of A'.

Two explicit obstructions are retained:

1. A=[[1,1],[0,5]] and right shear T=[[1,1],[0,1]] give
   AT=[[1,2],[0,5]]. Their standard hull orders at 5 are one and
   five. Here the edge map is S=T^T and is not orthogonal. Even the
   complete labeled arithmetic data agree; the unrestricted
   realization-invariance conjecture remains disproved.
2. For A=(2,3), the edge (2,3) is a hull element modulo 13, but its
   unscaled integer lift fails modulo 26 since A(2,3)^T=13.
   Scaling gives (4,6), which is in the hull modulo 26. Unscaled
   representatives also fail to define a well-defined additive map
   Z/13 -> Z/26. The potential y=1 lies in K_13 but not K_26;
   dy=2 lies in K_26, so the same failure is visible in the quotient.

## 5. Scope of proof and executable evidence

Sections 1–4 prove the structural statement for every integer matrix
and every n>=2. The new candidate [interface](../kernel/code_hull.py)
uses exhaustive kernels and lexicographic coset representatives; this
choice is an encoding, not extra mathematical structure. The
[replay](../conformance/replay_code_hull.py) checks actual fibers,
representatives, quotient operations, both commuting squares, both
round trips and three-level composition on finite fixtures. Literal
dot-product orthogonality and the independent lattice-index edge oracle
check the hulls; the existing potential implementation is also checked
on all six original essential realizations. Redundant-row and empty
shapes extend the executable domain beyond that implementation.

The [receipt](../conformance/receipts/code-hull-tower-v1.json) is finite
non-authoritative evidence with no claim promotions. Proof authority is
this record, not the receipt, code, or research queue. No general
nonsurjective classification, efficient algorithm, universal torsion
group, or arithmetic-data-only reconstruction is asserted.
