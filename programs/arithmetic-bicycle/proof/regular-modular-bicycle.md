# Fixed-TU regular-matroid modular bicycle theorem

Claim: ABC-REGULAR-MODULAR-BICYCLE.

## Statement

Let $A\in\mathbb Z^{r\times e}$ have full row rank and be totally
unimodular (TU): every square minor has determinant in $\{-1,0,1\}$.
Define

$$
Q=AA^\top,\qquad K_A=\mathbb Z^r/Q\mathbb Z^r,
$$

and, for every integer $n\ge2$,

$$
\operatorname{Bic}_n(A)=\operatorname{im}(A^\top\bmod n)
\cap\ker(A\bmod n)\subseteq(\mathbb Z/n)^e.
$$

**Theorem.** There is a natural $\mathbb Z/n$-module isomorphism

$$
\Phi_n:\operatorname{Bic}_n(A)\longrightarrow K_A[n],
\qquad \Phi_n(A^\top y\bmod n)=[Qy/n].
\tag{1}
$$

Its inverse sends $[d]\in K_A[n]$ to

$$
\Psi_n([d])=A^\top y\bmod n\quad\text{where }Qy=nd,\ y\in\mathbb Z^r.
\tag{2}
$$

The maps commute with reduction and inflation across dividing moduli.
They are equivariant under signed permutations of the columns and
under integral unimodular changes of row coordinates, as described below.
This is a theorem about a **fixed representation**. It does not identify
arbitrary representations of the same matroid.

For $r=0$, both modules are zero, regardless of the number of columns,
and all assertions hold trivially. In the proof below take $r>0$.

## 1. Integral right inverse and nonsingular Gram matrix

Full row rank supplies an $r$-column submatrix $C$ with nonzero determinant.
Total unimodularity makes $\det C=\pm1$, so $C^{-1}$ is integral.
Embed its rows at those column indices, with zeros at the remaining
indices, to obtain $R\in\mathbb Z^{e\times r}$ satisfying

$$
AR=I_r,\qquad R^\top A^\top=I_r.
\tag{3}
$$

Thus $A^\top$ is injective over every $\mathbb Z/n$, including composite
rings: apply the left inverse $R^\top$. In particular,

$$
A^\top(y'-y)\equiv0\pmod n\ \Longrightarrow\ y'-y=nz
\quad\text{for some }z\in\mathbb Z^r.
\tag{4}
$$

If $Qw=0$ for an integral $w$, then
$w^\top Qw=\sum_j(A^\top w)_j^2=0$ forces $A^\top w=0$ and hence $w=0$.
Clearing denominators gives the same conclusion over $\mathbb Q$.
Consequently $Q$ is nonsingular, $K_A$ is finite, and an integral
solution of $Qy=nd$, when it exists, is unique.

The proof only needs an **integral right inverse** of $A$, not every
TU minor condition. Accordingly the same formulas are valid for any
split-surjective integral matrix $A$. TU is a sufficient, explicitly
verified hypothesis in this contribution's executable interface.

## 2. Forward map and both kinds of representative independence

For a bicycle $b=A^\top y\bmod n$, the cycle condition is
$Qy\equiv0\pmod n$. Therefore $d=Qy/n$ is integral, and
$n[d]=[Qy]=0$ in $K_A$.

Changing an integral lift from $y$ to $y+nz$ changes $d$ by $Qz$.
More generally, any two potentials giving the same bicycle differ by
$nz$ by (4). Their images in $K_A$ are therefore the same.
This proves independence of lifts and modular potential representatives.

Adding potentials proves additivity; scaling them by integers proves
linearity. Since the target is annihilated by $n$, this is
$\mathbb Z/n$-linearity.

## 3. Injectivity

If $\Phi_n(b)=0$, then $Qy/n=Qz$ for an integral $z$.
Hence $Q(y-nz)=0$. Nonsingularity gives $y=nz$, so $b=0$.

The argument is integral and does not infer injectivity from a
prime-field rank or a cardinality comparison.

## 4. Surjectivity and inverse representative independence

For $[d]\in K_A[n]$, the condition $n[d]=0$ means $nd=Qy$
for some integral $y$. Its gradient $b=A^\top y\bmod n$ is a cut,
and $Ab=Qy\bmod n=0$, so it is a bicycle. Formula (1) gives
$\Phi_n(b)=[d]$.

For a fixed divisor $d$, the integral solution $y$ is unique.
If $d$ is replaced by $d+Qz$, the solution is replaced by $y+nz$,
whose modular gradient is the same. Thus (2) is independent of the
divisor representative and of the choice of a solution.

## 5. Both inverse identities

Starting with $b=A^\top y\bmod n$, take $d=Qy/n$. The same potential
solves $Qy=nd$, so $\Psi_n\Phi_n(b)=b$.

Starting with $[d]$, choose $Qy=nd$. Then
$\Phi_n\Psi_n([d])=[Qy/n]=[d]$.

## 6. Compatible modulus maps

For $m=kn$, ordinary reduction preserves both cuts and cycles, and
inflation $b\bmod n\mapsto kb\bmod m$ is well defined and injective.
The corresponding group maps are:

| Bicycle map | Torsion map | Identity |
| --- | --- | --- |
| $\rho_{m,n}(b)=b\bmod n$ | $K_A[m]\to K_A[n],\ x\mapsto kx$ | $\Phi_n\rho_{m,n}=k\Phi_m$ |
| $\iota_{n,m}(b)=kb\bmod m$ | Inclusion $K_A[n]\hookrightarrow K_A[m]$ | $\Phi_m\iota_{n,m}=\Phi_n$ |

For reduction, use the same potential and $[Qy/n]=k[Qy/m]$.
For inflation, use $ky$ and $[Q(ky)/m]=[Qy/n]$.
For $n\mid m\mid\ell$, both families compose, because the scale factors
multiply. Both composites $\rho\iota$ and $\iota\rho$ are multiplication
by $k$ on their respective modules. Reduction can fail to be surjective;
injectivity of inflation does not imply otherwise.

## 7. Coordinate equivariance and the remaining regular-matroid gate

Let $S$ be a signed permutation matrix of column coordinates and
$U\in\operatorname{GL}_r(\mathbb Z)$. Put $A'=UAS$. Then

$$
Q'=UQU^\top,\qquad b'=S^\top b,\qquad y'=U^{-\top}y.
$$

The bicycle modules correspond through $S^\top$: the row change is
invertible modulo every $n$. The cokernel map
$[d]\mapsto[Ud]$ is well defined and invertible because
$Q'\mathbb Z^r=UQ\mathbb Z^r$. Substituting $y'$ gives

$$
\Phi'_n(S^\top b)=[Q'y'/n]=[UQy/n].
$$

If a row change produces a non-TU matrix, it still has the integral
right inverse $S^\top R U^{-1}$, so the split-surjective lemma applies.

This proves compatibility for **specified** coordinate equivalences.
It does not prove that every pair of TU representations of a labeled
regular matroid is related by such transformations. Establishing and
sourcing that representation theorem remains Phase 3 of the roadmap.

## 8. Exact evidence and graph specialization

The implementation verifies every TU minor and full row rank, constructs
an integral right inverse, enumerates normalized potentials, and compares
classes using exact rational elimination. A separate oracle computes
Smith factors from all-minor gcds, completes cycles from nonbasis
coordinates using integral Cramer inverses, checks the cut condition, and
enumerates the finite quotient independently of the proposed map.

The fixtures include rank zero, loops, coloops, parallel elements, reduced
graph incidence matrices, and a four-row fundamental-cycle representation
of the cographic matroid of $K_{3,3}$. Its Gram Smith factors are
$(1,3,3,9)$, so moduli $3$, $6$, and $9$ exercise noncyclic torsion and a
prime-power exponent that mod-$3$ rank alone cannot recover.

For a connected graph, drop one row of the incidence matrix to obtain
a full-row-rank TU matrix $A$. Dropping the same coordinate identifies
degree-zero divisors modulo $L\mathbb Z^V$ with
$\mathbb Z^{V-1}/AA^\top\mathbb Z^{V-1}$. Set the omitted potential to zero:
the graph and matrix formulas then agree. This supplies a regression
bridge to the existing graph proof, without altering its source files.

## 9. Scope at the arithmetic boundary

The nonprimitive matrix $A=[2]$ has no integral right inverse. Modulo
$2$, its single zero bicycle has potentials $0$ and $1$, whose proposed
images $[4y/2]$ are distinct in $\mathbb Z/4$. Thus the forward formula is
not well defined without the splitting hypothesis.

More strongly, its bicycle modules are zero modulo $2$ and nonzero
modulo $4$. The [separate counterexample record](arithmetic-torsion-model-obstruction.md)
therefore rejects the unconditional finite-group torsion-model
strengthening in the bootstrap formulation. Realization invariance is a
different statement and remains open. Non-TU alone is not an obstruction:
$A=[1,2]$ has an integral right inverse and satisfies the lemma.

The fixed-TU theorem promotes ABC-REGULAR-MODULAR-BICYCLE only after its
proof audit and independent exact evidence pass. The integral proof is
authority; finite computation supplies implementation evidence.

## 10. Literature context

The TU definition and Gram-cokernel Jacobian background are recorded in
[sources/regular-matroid-background.md](../sources/regular-matroid-background.md),
including Goemans, Section 3.5, and Backman–Baker–Yuen, Proposition 2.1.2.
The explicit integral proof above supplies the repository claim authority;
the source record does not import an unproved representation-invariance step.
