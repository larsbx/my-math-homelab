# Surjective arithmetic realization invariance

Claim: **ABC-SURJECTIVE-REALIZATION-INVARIANCE**.

Domain: essential integer realizations in free ambient lattices, with
$m(\varnothing)=m(E)=1$. The equality $m(E)=1$ is an additional
hypothesis. The original **ABC-MAIN** and
**ABC-REALIZATION-INVARIANCE** remain retracted on their stated domain.

This record gives a self-contained labeled representation argument and
the arbitrary-modulus bicycle theorem. Representation uniqueness in
this domain is established in the literature; see the
[source audit](../sources/surjective-representation-equivalence.md).
No novelty of that uniqueness result is claimed.

## Statement and conventions

Let $A,A'\in\mathbb Z^{r\times e}$ have full row rank and generate
their declared lattices:

$$
A\mathbb Z^e=A'\mathbb Z^e=\mathbb Z^r.
$$

Suppose a prescribed bijection of column labels identifies their
complete arithmetic-matroid data. Then there are
$U\in\operatorname{GL}_r(\mathbb Z)$ and a signed permutation matrix
$S$ with that prescribed underlying bijection such that

$$
A'=UAS.
$$

Put $Q_A=AA^\top$,
$K_A=\mathbb Z^r/Q_A\mathbb Z^r$, and
$\operatorname{Bic}_n(A)=\operatorname{im}(A^\top\bmod n)
\cap\ker(A\bmod n)$ for every integer $n\ge2$. There are
$\mathbb Z/n$-module isomorphisms

$$
\Phi_{A,n}:\operatorname{Bic}_n(A)\longrightarrow K_A[n],
\qquad A^\top y\bmod n\longmapsto[Q_Ay/n].
$$

One witness $(U,S)$ induces, simultaneously for every modulus,

$$
b\longmapsto S^\top b,\qquad [d]\longmapsto[Ud].
$$

These maps commute with $\Phi$ and its inverse and with both reduction
and inflation across dividing moduli. Consequently the tower's
isomorphism class, and the isomorphism class of $K_A$, depend only on
the surjective torsion-free arithmetic matroid. Comparison maps can
depend on the chosen witness.

For coordinates, target column $j$ equals
$s_jU A_{p(j)}$; thus $(S^\top b)_j=s_jb_{p(j)}$.
Rank zero, empty ground sets, loops, coloops, and disconnected
matroids are allowed. Empty matrices use the usual zero-dimensional
identity and trivial quotient conventions.

## 1. An integral splitting without a unit basis

Surjectivity is equivalent to having all $r$ nonzero Smith factors
equal to one. If a Smith certificate gives

$$
PAV=[I_r\mid0],\qquad
P\in\operatorname{GL}_r(\mathbb Z),\quad
V\in\operatorname{GL}_e(\mathbb Z),
$$

and $J:\mathbb Z^r\to\mathbb Z^e$ inserts the first $r$ coordinates,
then $T=VJP$ is integral and $AT=I_r$.
This also follows by choosing preimages of a lattice basis.
In particular $T^\top A^\top=I_r$, so $A^\top$ is injective modulo
every integer $n$.

No individual maximal minor need be a unit. For example
$A=(2,3)$ is surjective, as is

$$
A_0=\begin{pmatrix}2&0&1\\0&3&1\end{pmatrix};
$$

its maximal minors are $6,2,-3$. Their gcd is one but none is a unit.
The lattice is kept fixed throughout; replacing a nonsurjective
realization by its generated sublattice changes the arithmetic object.

## 2. Arbitrary-modulus isomorphism for a fixed surjection

The matrix $Q=AA^\top$ is nonsingular by the integer Cauchy–Binet
identity $\det(Q)=\sum_{|F|=r}\det(A_F)^2$. Full row rank gives
a nonzero integer maximal minor, so this finite sum is positive.
For rank zero the empty determinant is one. Hence $K_A$ is finite.

For $b=A^\top y\bmod n$ in the bicycle module, choose an integral
lift $y$. Its cycle condition says $Qy\in n\mathbb Z^r$, so $Qy/n$
is integral. Also $n[Qy/n]=[Qy]=0$.

If $y$ is replaced by $y+nz$, the divisor changes by $Qz$, which
represents zero in $K_A$. If another potential $y'$ represents the
same modular cut, then $A^\top(y'-y)\equiv0\bmod n$; multiplying
by $T^\top$ gives $y'-y\in n\mathbb Z^r$. Thus this argument covers
both a change of lift and a change of potential representative.
An edge lift has no independent role: $\Phi$ is defined using a
potential for the modular edge vector. Addition and integer scalar
multiplication of potentials show that $\Phi$ is $\mathbb Z/n$-linear.

For the inverse, let $[d]\in K_A[n]$, with $d\in\mathbb Z^r$.
By the definition of annihilation there is $y\in\mathbb Z^r$ with

$$
Qy=nd.
$$

Define $\Psi_{A,n}([d])=A^\top y\bmod n$. This is a cut and a
cycle. The integral solution $y$ is unique since $Q$ is nonsingular.
If $d'=d+Qz$, its solution is $y'=y+nz$, so the resulting edge
vector is unchanged. Thus $\Psi$ is well defined on divisor classes.

For a bicycle represented by $y$, its forward divisor is exactly
$d=Qy/n$, so the inverse returns the original $A^\top y\bmod n$.
For a torsion divisor with $Qy=nd$, the forward map of its inverse
returns $[Qy/n]=[d]$. These prove both inverse identities and hence
injectivity and surjectivity for every composite $n$ as well.
Equivalently, if $\Phi(b)=0$, then $Qy=nQz$ for an integral $z$;
nonsingularity gives $y=nz$, hence $b=0$.

The splitting and $Q^{-1}$ used by the executable routines are
computational choices. The module map itself is the representative-
independent formula above.

## 3. Both maps between moduli

For $m=kn$, define

$$
\rho_{m,n}(b)=b\bmod n,\qquad
\iota_{n,m}(b)=kb\bmod m.
$$

Reduction takes cuts and cycles to cuts and cycles.
If $b=A^\top y\bmod n$ is a cycle, then
$Q(ky)=kQy\in m\mathbb Z^r$, so inflation is also a bicycle.
Changing an edge lift by $nz$ changes its inflated lift by $mz$,
so inflation is well defined; it is injective as a map of edge modules.

Using the same integral potential in the formulas gives

$$
\Phi_{A,n}\rho_{m,n}=k\Phi_{A,m},\qquad
\Phi_{A,m}\iota_{n,m}=\Phi_{A,n},
$$

where the second right side is followed by the inclusion
$K_A[n]\subseteq K_A[m]$. Multiplication by $k$ indeed sends
$K_A[m]$ to $K_A[n]$. Both equations are equalities of classes;
chosen normalized potentials can change the displayed divisors by
$Q$-multiples. Reduction need not be surjective.

For $n\mid m\mid\ell$, reductions compose, and inflations compose
because $(\ell/m)(m/n)=\ell/n$. This specifies both directions of
compatibility rather than relying on a field-valued rank count.

## 4. Arithmetic data give rational row/sign equivalence

First align the column labels and suppress the permutation.
The rank-zero case is immediate, so assume $r>0$.
For every $r$-element column set $F$, the arithmetic data determine
$|\det A_F|$: it is $m(F)$ for a basis and zero otherwise.
Choose a common basis $B$, with matrices $C=A_B$ and $C'=A'_B$.
Set

$$
H=C^{-1}A,\qquad H'=C'^{-1}A'.
$$

Both have the identity in columns $B$ and have rational entries.
Cramer's rule, using a basis-column replacement, gives equal
magnitudes for corresponding entries of $H$ and $H'$.
More generally, if $I$ is a set of basis-row indices and
$J\subseteq E\setminus B$ has $|J|=|I|$, completion by the identity
columns $B\setminus I$ gives

$$
|\det H[I,J]|=
\frac{|\det A_{(B\setminus I)\cup J}|}{|\det C|}.
$$

The same formula holds for $H'$. Thus corresponding such minors
have equal absolute determinant, including zero. This step uses
the entire maximal-minor magnitude profile supplied by the
arithmetic data; normalized support alone would be insufficient.

Make the bipartite support graph whose vertices are the $r$ rows
and the nonbasis columns. On every nonzero entry set
$t_{ij}=H'_{ij}/H_{ij}\in\{1,-1\}$.

For a chordless cycle of length $2q$, its selected $q$-by-$q$
submatrix has exactly the cycle edges as its nonzero positions.
Its determinant has precisely two nonzero matching terms.
Let their positive magnitudes be $a,b$. According to their relative
signs, the determinant magnitude is $a+b$ or $|a-b|$.
These are distinct since $a,b>0$, even when $a=b$.
The two matrices have the same entry magnitudes and determinant
magnitude, so the relative signs of their two terms must agree.
The product of the ratios $t_{ij}$ around this cycle is therefore
one.

Any cycle with a chord splits into two shorter cycles; multiplying
their ratio products cancels the chord since $t^2=1$.
Induction proves product one around every cycle.
Choose a sign at a root of each support component and propagate
along a spanning tree. The cycle condition ensures consistent
vertex signs $\alpha_i,\beta_j\in\{1,-1\}$ with
$t_{ij}=\alpha_i\beta_j$ on every support edge.
Isolated vertices cause no obstruction.

Let $D_R=\operatorname{diag}(\alpha_i)$ and assign column sign
$\beta_j$ off $B$ and $\alpha_i$ to basis column $B_i$.
For the resulting diagonal sign matrix $D_E$,

$$
H'=D_R H D_E,\qquad
A'=UAD_E,\qquad U=C'D_R C^{-1}\in\operatorname{GL}_r(\mathbb Q).
$$

The basis-column signs make $D_R I D_E|_B=I$, as required.
Restoring the prescribed label permutation gives $A'=UAS$.
At this point $U$ is only rational. In particular, this argument
alone would not establish invariance for nonsurjective realizations.

## 5. The precise use of surjectivity

Since both column lattices equal $\mathbb Z^r$ and $S$ preserves
$\mathbb Z^e$,

$$
\mathbb Z^r=A'\mathbb Z^e=UA S\mathbb Z^e=U\mathbb Z^r.
$$

Thus $U$ maps the integral lattice onto itself and belongs to
$\operatorname{GL}_r(\mathbb Z)$.
Explicitly, if $AT=I$, then $U=A'S^{-1}T$ is integral;
the target splitting similarly makes $U^{-1}$ integral.
This is why a unit basis is unnecessary and why the full-index-one
hypothesis cannot be omitted.

For comparison, the retracted-ABC pair
$A=((1,1),(0,5))$, $A'=((1,2),(0,5))$
has a rational row equivalence
$A'A^{-1}=((1,1/5),(0,1))$.
Neither column lattice is the whole declared ambient lattice.
The local rational argument does not make that matrix integral.
Their differing bicycle orders remain a counterexample.

## 6. Transport of the entire tower and Gram identifications

A signed permutation is orthogonal over $\mathbb Z$. Therefore

$$
Q_{A'}=UQ_AU^\top.
$$

The map $[d]\mapsto[Ud]$ is an isomorphism of Gram cokernels:
$UQ_Az=Q_{A'}U^{-\top}z$, with $U^{-\top}z$ integral.
For $b=A^\top y\bmod n$, put $y'=U^{-\top}y$. Then

$$
(A')^\top y'=S^\top A^\top y,\qquad
A'S^\top b=UAb,\qquad
Q_{A'}y'=UQ_Ay.
$$

Thus $S^\top$ takes cuts to cuts and cycles to cycles and has
the inverse induced by the inverse witness. Moreover

$$
\Phi_{A',n}(S^\top b)=[UQ_Ay/n]
=U_*\Phi_{A,n}(b).
$$

The inverse square commutes as well: if $Q_Ay=nd$, then
$Q_{A'}U^{-\top}y=nUd$.
Integral linearity of $S^\top$ makes it commute with reduction
and with multiplication by $m/n$ in inflation. The same $(U,S)$
works for every $n$; no separate modulus-dependent choices occur.

Witnesses compose as
$(U_2,S_2)\circ(U_1,S_1)=(U_2U_1,S_1S_2)$ in the equation
convention above and invert as $(U^{-1},S^{-1})$.
The induced maps respect those operations.
They need not be unique: for $A=(2,3)$, both
$(U,S)=(1,I)$ and $(-1,-I)$ are self-equivalences, and they
act differently on the nonzero $13$-torsion bicycles.
Only the tower's isomorphism class is asserted to be intrinsic.

## 7. Executable evidence and boundaries

The candidate requires essentiality and a verified all-unit Smith
diagonal in the original ambient lattice. It constructs $T$ from
both Smith transformations, normalizes a rational basis, solves
support signs, and verifies the entire integral witness equation
and unit determinant.

The independent oracle imports no kernel code. Arithmetic data and
surjectivity use gcds of Bareiss minors; witnesses use exhaustive
column-sign search and a different rational basis with Cramer's rule.
Modular cuts use lattice-index equality for $[A^\top\mid nI]$,
after independently filtering edge vectors by the cycle equations.
Literal potential enumeration supplies a third finite check.
Gram quotient representatives and Smith factors are computed
independently of either theorem map.

The versioned packet has ten positive pairs, 38 modulus cases,
three source fixtures without a unit maximal minor, two arithmetic
negative pairs, and three nonsurjective rejection fixtures.
It includes $C_{13}$ at $13,26,52,169$, $C_{49}$ at $7,14,49$,
noncyclic $C_3\oplus C_3$, loops, a support six-cycle, and coordinate
changes that lose literal TU. A complete ternary 2-by-3 census
contains 552 surjections in ten arithmetic buckets, including
96 non-TU matrices, with 2,208 modulus cases and 90 ordered
cross-bucket rejections.

The tests additionally cover both inverse identities, representative
changes, linearity, every fixture divisibility chain, witness
composition, large composite moduli without enumeration, and
nonunique comparisons. Reduction at $169\to13$ for $(2,3)$ is zero
despite nonzero target bicycles; field counts cannot infer such a
map. At modulus $49$, the rank-two fixture contains elements of
order $49$, information invisible in its mod-$7$ module.

These are exhaustive checks within the stated finite scopes, with
no silent truncation. The integral proof establishes the theorem;
Python remains candidate code without acceptance authority.
The original unrestricted claims and the universal torsion-model
claim remain retracted. The proved graph and regular TU records
retain their separate statements and pinned evidence.
