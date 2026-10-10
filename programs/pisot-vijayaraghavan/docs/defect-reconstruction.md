# Normalized defects, reconstruction, and the recurrent endpoint

**Status: PROVED**, except for the explicitly **IMPORTED** theorem in
Section 5. This note closes PV-REDUCTION-CONVERSE, PV-POLY-EQUIV, and
PV-SALEM-EXCLUSION under the hypotheses stated below. It does not infer a
recurrence from merely vanishing approximation error.

Write

\[
r_n=\frac{a_{n+1}}{a_n},\qquad
c_n=a_na_{n+2}-a_{n+1}^2,\qquad
\delta_n=\frac{c_n}{a_n}.
\]

Here an **expanding tail** means that the integers `a_n` are positive and
`r_n>=b>1` for every sufficiently large `n`, for some fixed `b`.
This includes every positive tail with `r_n->alpha>1`. Unbounded growth
alone is insufficient; Section 2 gives an exact counterexample.

## 1. Two tail sums reconstruct the witness

**Theorem (PV-REDUCTION-CONVERSE).** An expanding integer tail with
`delta_n->0` determines unique `alpha>=b>1` and `lambda>0` such that

\[
r_n\longrightarrow\alpha,\qquad
a_n=\lambda\alpha^n+e_n,\qquad e_n\longrightarrow0.
\tag{1}
\]

If `eta_n=sup_(j>=n)|delta_j|`, then, on the expanding tail,

\[
|e_n|\le\frac{\eta_n}{(b-1)(\alpha-1)}.
\tag{2}
\]

Eventually `a_n` is the unique nearest integer to `lambda alpha^n`, and
also the quadratic nearest-integer rule holds. No rounding rule is needed
as an additional assumption.

**Proof.** The exact ratio identity is

\[
r_{n+1}-r_n=\frac{\delta_n}{a_{n+1}}.
\tag{3}
\]

Expansion gives `a_n>=a_N b^(n-N)`. Since `delta_n` is bounded, the right
side of (3) is absolutely summable. Thus `r_n` has a finite limit
`alpha>=b`. Set `d_n=a_(n+1)-alpha a_n`. Summing (3) to infinity gives
the first exact tail sum:

\[
d_n=-a_n\sum_{j=n}^{\infty}\frac{\delta_j}{a_{j+1}}.
\tag{4}
\]

Because `a_n/a_(j+1)<=b^(-(j-n+1))`,

\[
|d_n|\le\frac{\eta_n}{b-1}\longrightarrow0.
\tag{5}
\]

For `q_n=a_n/alpha^n` we have
`q_(n+1)-q_n=d_n/alpha^(n+1)`. This is absolutely summable, so the
positive sequence `q_n` tends to a finite `lambda>=0`. Its tail sum is

\[
a_n-\lambda\alpha^n
=-\sum_{k=n}^{\infty}\alpha^{n-k-1}d_k.
\tag{6}
\]

Equations (5)-(6) prove (2). If `lambda=0`, (2) would give `a_n->0`,
contradicting the positive expanding integer tail. Thus `lambda>0`.
The ratio limit and the limit of `q_n` give uniqueness. Since `e_n->0`,
the witness's nearest integer is eventually `a_n`. Finally
`a_(n+2)-a_(n+1)^2/a_n=delta_n->0`, so the quadratic rounding is
eventually unique as well. This proves the theorem.

Combined with PV-REDUCTION-FWD, this gives the equivalence between a PV
witness and an expanding integer tail with vanishing normalized defect.
It proves neither algebraicity nor recurrence in this generality.

## 2. The expansion boundary and finite identities

For `a_n=n`, starting at `n>=3`, one has

\[
c_n=-1,\qquad\delta_n=-1/n\longrightarrow0,\qquad
\frac{a_{n+1}^2}{a_n}=n+2+1/n.
\]

Thus the quadratic nearest-integer rule holds, `a_n->infinity`, and
`r_n>1`; nevertheless `r_n->1`. No `lambda>0, alpha>1` can approximate
this tail with error tending to zero. A fixed expansion gap above one is
a sufficient hypothesis, and cannot be replaced by these weaker growth
statements.

The executable checks use finite identities, retaining their terminal
terms. For every finite `m>=n`,

\[
r_m-r_n=\sum_{j=n}^{m-1}\frac{\delta_j}{a_{j+1}},\qquad
\frac{a_m}{\alpha^m}-\frac{a_n}{\alpha^n}
=\sum_{k=n}^{m-1}\frac{d_k}{\alpha^{k+1}},
\tag{7}
\]

and, for arbitrary trial `lambda` and `alpha!=0`,

\[
e_n=\alpha^{n-m}e_m
-\sum_{k=n}^{m-1}\alpha^{n-k-1}d_k,
\qquad d_{n+1}-r_nd_n=\delta_n.
\tag{8}
\]

These are algebraic identities even when the trial parameters are wrong.
Dropping the terminal term in (8) requires the infinite-tail argument;
finite agreement does not certify its hypotheses or a PV witness.

## 3. Polynomial approximation and polynomial defect are equivalent

**Theorem (PV-POLY-EQUIV).** Let `A>0` be real. For an integer sequence
positive on a tail with `r_n->alpha>1`, the following are equivalent:

\[
c_n=O(\alpha^n n^{-A});
\tag{9}
\]

\[
\text{there exists a unique }\lambda>0\text{ with }
a_n=\lambda\alpha^n+O(n^{-A}).
\tag{10}
\]

In (10), `a_n` is eventually the nearest integer. Consequently, at the
level of existence of a witness and its nearest-integer sequence, (9) is
equivalent to `||lambda alpha^n||=O(n^-A)`, with `lambda!=0` (its sign
can be reversed).

**Proof of (9) => (10).** Comparability with `alpha^n` must first be
proved. Choose `B` with `sqrt(alpha)<B<alpha`. The ratio limit gives
`a_n>=C B^n`. Equation (3), written as
`r_(n+1)-r_n=c_n/(a_n a_(n+1))`, yields

\[
|r_{n+1}-r_n|=O(q^n n^{-A}),\qquad q=\alpha/B^2<1.
\]

Summing to the already given limit `alpha` shows
`|r_n-alpha|=O(q^n n^-A)`. In particular
`sum |r_n/alpha-1|<infinity`. The positive infinite product

\[
\frac{a_n}{\alpha^n}
=\frac{a_N}{\alpha^N}\prod_{j=N}^{n-1}\frac{r_j}{\alpha}
\longrightarrow\lambda>0
\tag{11}
\]

therefore gives `a_n asymp alpha^n` without assuming it. Now
`delta_n=O(n^-A)`, so `eta_n=O(n^-A)`. Apply (2), using any late ratio
floor `1<b<alpha`, to obtain (10). The `lambda` is the same limit in
(11).

**Proof of (10) => (9).** Expand the defect with
`e_n=a_n-lambda alpha^n`:

\[
c_n=\lambda\alpha^n\cdot
\bigl(e_{n+2}+\alpha^2e_n-2\alpha e_{n+1}\bigr)
+e_ne_{n+2}-e_{n+1}^2.
\tag{12}
\]

The linear-error bracket is `O(n^-A)` and the quadratic remainder is
`O(n^(-2A))`, proving (9) since `alpha>1`. If instead one
starts with the norm formulation, choose the nearest integers on the
positive witness tail; these have the required ratio limit. This closes
both directions.

The restriction `A>0` supplies a vanishing error and eventual unique
rounding. A bounded error at `A=0` is possible for arbitrary
transcendental `alpha>1` by `a_n=floor(alpha^n)`; it gives
`c_n=O(alpha^n)` without a rational recurrence. Even for `A>0`, the
fixed-size rank-one estimate is only
`D_k(n)=O(alpha^n n^(-A(k-1)))`. It supplies no integer vanishing for
any fixed `k`. Section 5 uses a separate imported theorem in its range.

## 4. Vanishing error excludes unit roots once recurrence is known

**Theorem (PV-SALEM-EXCLUSION).** Suppose an integer sequence has

\[
a_n=\lambda\alpha^n+o(1),\qquad\lambda>0,\quad\alpha>1,
\tag{13}
\]

and a constant-coefficient rational tail recurrence is independently
established. Then its minimal tail recurrence polynomial is the minimal
polynomial of `alpha`, belongs to `Z[X]`, and has all its other roots
strictly inside the unit disk. Thus `alpha` is Pisot and
`lambda in Q(alpha)`. Equivalently, an expanding integer tail with
`delta_n->0` and an independently established rational recurrence has
this conclusion by Section 1.

**Proof.** A recurrence of order `R` makes `D_(R+1)(n)=0` for all late
`n`. Apply [the contiguous-layer bridge](exponential-window-hankel.md#4-a-bridge-with-exactly-the-contiguous-layer-hypothesis)
over `Q`. On a later tail starting at `M`, choose its minimal order
`r>=1` with `D_r(n)!=0` for every `n>=M`, and write its monic
polynomial as `p(X)=X^r-sum(q_j X^j)`.

For clarity, integrality uses the infinite tail, not one integer window.
Let `C_j=(a_(M+i+j))_(i>=0)` and `V=span_Q{C_j}`. The first `r`
coordinates give an injective map from `V` into `Q^r`, because
`D_r(M)!=0`. The group `L=sum Z C_j` embeds in `Z^r`, is free of rank
`r`, and is preserved by shift. The shift's integer matrix in a basis of
`L` has a monic integer characteristic polynomial of degree `r`.
Minimality identifies it with `p`, so `p in Z[X]`. The determinant
identity `D_r(n+1)=(-1)^(r-1)q_0 D_r(n)` gives `p(0)!=0`.

The generating function `F(z)=sum_(j>=0) a_(M+j) z^j` is rational over
`Q`, with reduced denominator `Q(z)=z^r p(1/z)`. A denominator
cancellation would lower the minimal tail order. Let

\[
E(z)=F(z)-\frac{\lambda\alpha^M}{1-\alpha z}
=\sum_{j\ge0}e_{M+j}z^j.
\tag{14}
\]

Since `e_n->0`, this series is analytic in `|z|<1`. Thus the only pole
of `F` in that disk is the simple pole `1/alpha`. In particular
`p(alpha)=0`, and `alpha` is a simple root of `p`.

It remains to exclude poles *on* the unit circle; analyticity in the
open disk alone does not do this. For `|zeta|=1` and `0<t<1`,

\[
(1-t)|E(t\zeta)|\le(1-t)\sum_{j\ge0}|e_{M+j}|t^j
\longrightarrow0.
\tag{15}
\]

Indeed, split at an index where all remaining coefficients have absolute
value at most `epsilon`. The finite initial sum tends to zero after
multiplication by `1-t`, while the tail is at most `epsilon`.
A pole of order `h>=1` at `zeta` would instead give
`E(t zeta)=C(1-t)^(-h)(1+o(1))` with `C!=0`, contradicting (15).
Hence every other root of `p` has modulus strictly less than one.

The irreducible monic integer factor containing `alpha` has multiplicity
one. Any remaining monic integer factor would have a nonzero integer
constant term whose absolute value is the product of numbers less than
one, which is impossible. Therefore `p` is the minimal polynomial of
`alpha`. The coefficient `(1-alpha z)F(z)` at `z=1/alpha` lies in
`Q(alpha)` and equals `lambda alpha^M`; hence `lambda in Q(alpha)`.

**Boundary.** Bounded error is insufficient: `a_n=2^n+1` has the unit
root `1`, error `1`, defect `2^n`, and
`delta_n=2^n/(2^n+1)->1`. Likewise `a_n=2^n+(-1)^n` has a unit root
`-1` and defect `9(-2)^n`. These are exact recurrent controls, not
counterexamples to the PV problem. This theorem excludes a Salem branch
only after recurrence has been supplied; it does not supply recurrence.

## 5. An imported square-summability route and its polynomial range

**Imported theorem (PV-L2-RECURRENCE).** Charles Pisot,
*La répartition modulo 1 et les nombres algébriques*, Annali della
Scuola Normale Superiore di Pisa, series 2, **7** (1938), 205-248,
Chapter III, Theorem I, statement on printed pages 230-231 and proof
through page 232:
<https://www.numdam.org/item/ASNSP_1938_2_7_3-4_205_0.pdf>.

The specialization used here is: if `u_n` satisfies a constant-coefficient
linear recurrence, `a_n` are rational integers, and
`sum |u_n-a_n|^2<infinity`, then `a_n` also satisfies a
constant-coefficient linear recurrence. The theorem permits arbitrary
constant coefficients for the given `u_n`; it does not require `alpha`
to be algebraic in advance. A finite initial change is handled by
starting at a later index. This is an imported dependency, not a new
proof of Pisot's theorem. The PDF's page indices 26-28 correspond to
these printed pages (there is a cover page).

**Corollary (PV-POLY-L2-RANGE).** If the hypotheses of PV-POLY-EQUIV
hold with `A>1/2`, then `alpha` is Pisot and `lambda in Q(alpha)`.
The same conclusion holds for any witness with square-summable nearest
integer errors.

**Proof.** Section 3 gives `e_n=O(n^-A)` and hence
`sum |e_n|^2<infinity` when `2A>1`. Apply the imported theorem to
`u_n=lambda alpha^n`, which satisfies an order-one recurrence. Even
if the supplied recurrence initially has coefficients in `C`, it makes
some fixed contiguous Hankel layer of the integer sequence vanish at
every late shift. The bridge over `Q` supplies a rational recurrence.
Since square summability implies `e_n->0`, Section 4 applies. For the
norm formulation use the nearest integer sequence directly.

The bound `O(n^-1/2)` alone does not imply square summability. For an
explicit rational error control, put `v_n=2^(-j)` on
`4^j<=n<4^(j+1)`. Then `v_n=O(n^-1/2)` and each block contributes
exactly `3` to `sum v_n^2`. Even little-o at this boundary is
insufficient for this criterion: divide block `j>=1` by `ceil(sqrt(j))`.
Now `v_n=o(n^-1/2)`, but grouping
`(k-1)^2<j<=k^2` gives square mass `3(2k-1)/k^2>=3/k`, which diverges.
These controls concern error bounds, not errors of an actual PV witness.
They refute an invalid summability inference, not a Pisot conclusion.
No counterexample or complete characterization for `0<A<=1/2` is
asserted here. Recurrence outside a verified recurrence or summability
hypothesis remains the unresolved interface in this repository.

## 6. Audit obligations and executable scope

| Obligation | Resolution |
| --- | --- |
| Meaning of expansion | A uniform ratio floor above one; `a_n=n` rejects weaker readings. |
| Existence and positivity of the amplitude | Absolute convergence of both tails; zero amplitude would force the positive integers to tend to zero. |
| Division by exponential size in the polynomial proof | Lower-growth bootstrap and a nonzero infinite product establish comparability first. |
| Polynomial boundary | Real `A>0` for approximation; `A>1/2` only for the imported square-sum route. |
| Unit-circle roots | The Abel estimate (15), beyond analyticity in the open disk. |
| Integer recurrence coefficients | The shift-invariant lattice of the infinite integer tail. |
| Recurrence for the general PV witness | Remains unproved; Section 4 is conditional, Section 5 imported. |

`kernel/pv/reconstruction.py` and `tests/test_reconstruction.py` check
(7)-(8), the exact expansion counterexample, terminal-term controls,
the defect expansion, recurrent unit-root controls, and rational
square-sum boundary blocks. They certify finite identities only. The
two written defect expansions are also checked coefficient by coefficient
in `tests/test_documented_defect_expansion.py`, including the erroneous
plus-sign form as a negative control. The
proofs above and the cited theorem, not enumeration, support the claim
statuses.
