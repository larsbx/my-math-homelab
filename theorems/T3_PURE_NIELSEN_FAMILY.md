# T3 Calibration Theorem — Pure Nielsen Orbits for Four Reflections

## Setup

Let
\[
D_{2n}
=
\langle g,s\mid g^n=s^2=1,\ sgs=g^{-1}\rangle
\]
with even \(n\ge4\).

There are two reflection conjugacy classes:
\[
C_0=\{g^{2k}s\},
\qquad
C_1=\{g^{2k+1}s\}.
\]

Fix an ordered four-position class pattern containing exactly two entries from \(C_0\) and two entries from \(C_1\).

Let
\[
\operatorname{PNi}^{\mathrm{in}}(D_{2n},\mathbf C)
\]
denote the generating product-one four-tuples of that ordered type modulo simultaneous inner conjugation.

## Theorem T3.1 — Pure-braid transitivity

The pure braid group \(P_4\) acts transitively on
\[
\operatorname{PNi}^{\mathrm{in}}(D_{2n},\mathbf C).
\]

Moreover,
\[
\left|
\operatorname{PNi}^{\mathrm{in}}(D_{2n},\mathbf C)
\right|
=
\frac{J_2(n)}6.
\]

### Step 1 — Normalize the alternating pattern

It is enough to prove the claim for the ordered pattern
\[
(C_0,C_1,C_0,C_1).
\]

Indeed, \(B_4\) permutes ordered class patterns and \(P_4\triangleleft B_4\), so transitivity for one two-and-two pattern transports to every other such pattern.

Write reflections as
\[
r_x:=g^x s.
\]

A tuple of the alternating type can be normalized by simultaneous inner conjugation to
\[
T(a,b)
=
(r_0,r_a,r_b,r_{b-a}),
\]
with
\[
a\equiv1\pmod2,
\qquad
b\equiv0\pmod2.
\]

The product-one relation is automatic in this form.

The tuple generates \(D_{2n}\) iff
\[
\gcd(n,a,b)=1.
\]

Simultaneous conjugation by a reflection identifies
\[
(a,b)\sim(-a,-b).
\]

Hence the inner Nielsen class is identified with primitive vectors
\[
(a,b)\in(\mathbb Z/n\mathbb Z)^2
\]
satisfying
\[
(a,b)\equiv(1,0)\pmod2,
\]
modulo sign.

## Step 2 — Explicit pure-braid generators

For reflection exponents, a Hurwitz generator acts by
\[
\beta(x,y)=(y,2y-x).
\]

Therefore
\[
\beta^2(x,y)=(2y-x,3y-2x).
\]

### Lower shear

Applying \(\beta_1^2\) to
\[
T(a,b)=(r_0,r_a,r_b,r_{b-a})
\]
and renormalizing the first exponent to \(0\) gives
\[
(a,b)\longmapsto(a,b-2a).
\]

Thus \(\beta_1^2\) acts through
\[
L=
\begin{pmatrix}
1&0\\
-2&1
\end{pmatrix}.
\]

### Upper shear

Let
\[
A_{13}:=\beta_2\beta_1^2\beta_2^{-1}\in P_4.
\]

A direct calculation gives
\[
(a,b)\longmapsto(a+2b,b),
\]
so \(A_{13}\) acts through
\[
U=
\begin{pmatrix}
1&2\\
0&1
\end{pmatrix}.
\]

The matrices \(U\) and \(L\) generate the level-two congruence subgroup
\[
\Gamma(2)\le SL_2(\mathbb Z)
\]
up to its central element \(-I\), which is invisible after quotienting by
\[
(a,b)\sim(-a,-b).
\]

## Step 3 — Transitivity of the \(\Gamma(2)\)-action

Let
\[
v=(a,b)
\]
be primitive modulo \(n\) with
\[
(a,b)\equiv(1,0)\pmod2.
\]

Choose \(c,d\) modulo \(n\) such that
\[
ad-bc\equiv1\pmod n.
\]

Because \(a\) is odd and \(b\) is even, replacing
\[
(c,d)\mapsto(c+ta,d+tb)
\]
for a suitable \(t\) makes \(c\) even while \(d\) remains odd.

Hence
\[
M=
\begin{pmatrix}
a&c\\
b&d
\end{pmatrix}
\in SL_2(\mathbb Z/n\mathbb Z)
\]
and
\[
M\equiv I\pmod2.
\]

The reduction map
\[
SL_2(\mathbb Z)\to SL_2(\mathbb Z/n\mathbb Z)
\]
is surjective. Since \(n\) is even, any lift of \(M\) is automatically congruent to \(I\) modulo \(2\), hence lies in \(\Gamma(2)\).

Therefore \(\Gamma(2)\) acts transitively on primitive parity vectors of type \((1,0)\), and \(P_4\) acts transitively on the corresponding inner Nielsen class.

## Step 4 — Cardinality

Write
\[
n=2^e m
\]
with \(m\) odd.

The number of raw generating tuples of the fixed ordered type is
\[
\frac{n^3}{8}
\prod_{p\mid m}
\left(1-\frac1{p^2}\right).
\]

For a generating tuple, the stabilizer under simultaneous inner conjugation is
\[
Z(D_{2n}),
\]
which has order \(2\). Since
\[
|D_{2n}|=2n,
\]
each inner-conjugacy orbit has size \(n\).

Therefore
\[
\left|
\operatorname{PNi}^{\mathrm{in}}(D_{2n},\mathbf C)
\right|
=
\frac{n^2}{8}
\prod_{p\mid m}
\left(1-\frac1{p^2}\right).
\]

Since
\[
J_2(n)
=
n^2
\left(1-\frac14\right)
\prod_{p\mid m}
\left(1-\frac1{p^2}\right),
\]
we obtain
\[
\left|
\operatorname{PNi}^{\mathrm{in}}(D_{2n},\mathbf C)
\right|
=
\frac{J_2(n)}6.
\]

\(\square\)

## Corollary T3.2 — Full braid orbit

Berger's finite-dihedral classification implies that all generating product-one four-reflection tuples with two reflections from each reflection class lie in a single full braid orbit.

The full orbit decomposes into the six ordered two-and-two class patterns, each a single pure-braid orbit of size
\[
\frac{J_2(n)}6.
\]

Hence the corresponding inner Nielsen class has cardinality
\[
J_2(n).
\]

## Corollary T3.3 — Split versus nonsplit finite-field family

For odd \(q\ge5\), define
\[
n_-=q-1,
\qquad
n_+=q+1.
\]

For the split and nonsplit rank-one torus normalizers over \(\mathbb F_q\), the fixed-pattern pure Nielsen orbit sizes are
\[
S_-(q)=\frac{J_2(q-1)}6,
\qquad
S_+(q)=\frac{J_2(q+1)}6.
\]

Therefore
\[
\frac{S_+(q)}{S_-(q)}
=
\left(\frac{q+1}{q-1}\right)^2
\frac{
\prod_{p\mid q+1,\ p\text{ odd}}(1-p^{-2})
}{
\prod_{p\mid q-1,\ p\text{ odd}}(1-p^{-2})
}.
\]

The comparison is thus controlled by the prime-divisor structures of \(q-1\) and \(q+1\), not merely by their sizes.

## Corollary T3.4 — No monotone size principle

All three orderings occur:

- \(q=31\):
  \[
  S_-(31)=96<S_+(31)=128;
  \]

- \(q=29\):
  \[
  S_-(29)=S_+(29)=96;
  \]

- \(q=47\):
  \[
  S_-(47)=264>S_+(47)=256.
  \]

Hence the larger rational-point torus does not necessarily yield the larger Nielsen orbit.

## Status

This theorem is an internal coordinate refinement of known finite-dihedral Hurwitz theory.

The full-braid classification is prior art; the value here is the explicit pure-braid / level-two congruence description and its arithmetic reduction to \(J_2(q\pm1)\).

The next theorem is recorded in
\[
\texttt{T3\_J2\_SIGN\_OSCILLATION.md}.
\]
