# Obstruction to the universal torsion-model strengthening

Claim: ABC-UNIVERSAL-TORSION-MODEL (retracted strengthening).

## The rejected statement

The bootstrap README asserted that realization invariance of the bicycle
tower for torsion-free representable arithmetic matroids was equivalent
to its representation by a canonical finite abelian group $H$, with
$H[n]\cong\operatorname{Bic}_n(A)$ for every $n\ge2$.

The group assertion fails even for a one-element, rank-one arithmetic
matroid. This record withdraws that strengthening while preserving the
realization-invariance conjecture as an open question.

## A torsion-free representable arithmetic matroid

Take the vector $2$ in the ambient lattice $\mathbb Z$, represented by
$A=[2]$. Its underlying matroid has one nonloop element. Its multiplicities
are

$$
m(\varnothing)=1,\qquad m(\{e\})=[\mathbb Z:2\mathbb Z]=2.
$$

It is torsion-free in the usual arithmetic-matroid sense
$m(\varnothing)=1$. It is not surjective, since $m(E)=2$.
These are distinct conditions; torsion-free does not require the columns
to generate the ambient lattice. See Pagaria–Paolini, Section 2, in
[sources](../sources/regular-matroid-background.md).

## Literal modular computation

For every integer $n\ge2$,

$$
\operatorname{Bic}_n([2])
=\{2y\bmod n:\ 4y\equiv0\pmod n\}
=\ker(4:\mathbb Z/n\to\mathbb Z/n)/
  \ker(2:\mathbb Z/n\to\mathbb Z/n).
$$

The last equality is an isomorphism induced by $y\mapsto2y$.
Both kernels are cyclic, and their quotient is cyclic of order

$$
|\operatorname{Bic}_n([2])|
=\frac{\gcd(n,4)}{\gcd(n,2)}.
$$

In particular,

$$
\operatorname{Bic}_2([2])=\{0\},\qquad
\operatorname{Bic}_4([2])=\{0,2\}\cong\mathbb Z/2.
$$

For any abelian group $H$, $H[2]=0$ implies $H[4]=0$:
if $4x=0$, then $2x\in H[2]$, so $2x=0$, hence $x\in H[2]$ and $x=0$.
Consequently no group $H$, finite or otherwise, has this bicycle tower
as its family of torsion subgroups.

## Consequences for the research program

- The unconditional torsion-group strengthening is retracted.
- ABC-MAIN continues to assert realization invariance of the compatible
  modular bicycle tower, without the rejected equivalent formulation.
- This example contains one realization, not a pair of inequivalent
  realizations with matching arithmetic data. It does not decide
  ABC-REALIZATION-INVARIANCE.
- The graph and full-row-rank TU theorems remain valid: their splitting
  hypotheses exclude this example.
- Any arithmetic extension of the finite-group model must add hypotheses
  or replace its representing object. Those choices remain research
  obligations; this record does not select one.

The checked-in non-TU negative control verifies the entire modular edge
set and both ambiguous potential images over composite moduli. The
two explicit modules above and the elementary group argument are the
proof, independently of finite enumeration.
