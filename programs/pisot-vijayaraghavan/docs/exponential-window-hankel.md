# The exponential defect window and the contiguous Hankel bridge

**Status: PROVED.** This note closes issue #2's exponential-window implication.
It does not solve the PV problem with merely vanishing approximation error or
subexponential defect saving. The withdrawn limsup-concavity argument is not
used.

## 1. Statement and standing data

Let `(a_n)` be an integer sequence that is positive on a tail, and suppose

\[
r_n:=\frac{a_{n+1}}{a_n}\longrightarrow\alpha>1,
\qquad c_n:=a_na_{n+2}-a_{n+1}^2,
\qquad |c_n|=O(\alpha^{\gamma n}),\quad\gamma<1.
\tag{1}
\]

No lower Hankel determinant, gcd condition, nearest-integer rule, or
genericity assumption is imposed. Eventual negative sign can be handled by
replacing `a_n` with `-a_n`. The ratio-limit hypothesis can also be replaced
by `a_n>0` eventually and `a_n^{1/n}->alpha>1`; see the end of Section 2.

Put

\[
\rho=\alpha^{\gamma-1}<1,\qquad
D_k(n)=\det(a_{n+i+j})_{0\le i,j<k},\qquad D_0(n)=1.
\]

**Theorem (PV-H3 / PV-EXP-WINDOW).** There is a constant `lambda>0` such that

\[
a_n=\lambda\alpha^n+O(\rho^n).
\tag{2}
\]

For every fixed integer `k>=2`,

\[
D_k(n)=O\!\left(\alpha^{[1-(k-1)(1-\gamma)]n}\right).
\tag{3}
\]

Consequently `D_k(n)=0` for every sufficiently large `n` whenever

\[
\boxed{(k-1)(1-\gamma)>1.}
\tag{4}
\]

The least integer size guaranteed by this estimate is

\[
\boxed{k_{\min}=\left\lfloor\frac1{1-\gamma}\right\rfloor+2.}
\tag{5}
\]

The sequence satisfies a constant-coefficient rational tail recurrence of
order `r<k_min`; its infinite tail Hankel matrix has rank `r`. Moreover the
minimal monic recurrence polynomial is in `Z[X]`, is the minimal polynomial
of `alpha`, and all conjugates of `alpha` other than `alpha` have modulus at
most `rho<1`. In particular `alpha` is Pisot, with

\[
[\mathbb Q(\alpha):\mathbb Q]=r
\le\left\lfloor\frac1{1-\gamma}\right\rfloor+1,
\qquad \lambda\in\mathbb Q(\alpha).
\tag{6}
\]

The recurrence bridge is proved in Section 4 for the exact family in (3):
one **fixed size, all sufficiently large starting indices**. It is not an
appeal to a theorem about only leading determinants of increasing sizes.

## 2. Ratio summation without assuming growth comparability

The exact identity is

\[
r_{n+1}-r_n=\frac{c_n}{a_na_{n+1}}.
\tag{7}
\]

First choose `b` with `max(1,alpha^(gamma/2))<b<alpha`. This is possible
because `gamma<1`. The ratio limit implies `a_n>=C b^n` on a tail for some
`C>0`. Hence, with `q=alpha^gamma/b^2<1`,

\[
|r_{n+1}-r_n|=O(q^n),\qquad
r_n-\alpha=-\sum_{j=n}^{\infty}(r_{j+1}-r_j)=O(q^n).
\tag{8}
\]

In particular `sum |r_n/alpha-1|<infinity`. The positive infinite product
converges to a finite nonzero limit:

\[
\frac{a_n}{\alpha^n}
=\frac{a_N}{\alpha^N}\prod_{j=N}^{n-1}\frac{r_j}{\alpha}
\longrightarrow\lambda>0.
\tag{9}
\]

This establishes `a_n asymp alpha^n`; it was not assumed when deriving (8).
Return to (7) with this stronger comparison. For
`tau=alpha^(gamma-2)<1`, we now obtain

\[
r_{n+1}-r_n=O(\tau^n),\qquad r_n-\alpha=O(\tau^n).
\tag{10}
\]

Taking the tail of the logarithm of (9) gives

\[
\log\frac{a_n}{\lambda\alpha^n}
=-\sum_{j=n}^{\infty}\log\frac{r_j}{\alpha}
=O(\tau^n).
\tag{11}
\]

Exponentiation proves
`a_n-lambda alpha^n=O(alpha^n tau^n)=O(rho^n)`, as asserted.
If the defect hypothesis is little-o instead of big-O, the sharpened
geometric tail sums in (10)-(11) are little-o as well, and the error in (2)
is `o(rho^n)`.

If only the positive root-growth limit is assumed, it still yields
`a_n>=C b^n` with the same choice of `b`. Absolute convergence in (7) first
gives a finite limit `L>=0` for `r_n`. The possibility `L=0` would force
`a_n^{1/n}->0`: for every `epsilon>0` all late ratios would be at most
`epsilon`. For `L>0`, the Cesaro average of `log r_n` shows that the
root-growth limit is `L`. Thus `L=alpha`, and the preceding proof applies.

## 3. Rank-one estimate and every threshold case

For fixed `k`, write the actual contiguous Hankel matrix as

\[
H_k(n)=\lambda\alpha^n u v^T+E_k(n),\qquad
u_i=\alpha^i,\quad v_j=\alpha^j,\quad
(E_k(n))_{ij}=e_{n+i+j}.
\tag{12}
\]

Each main column is `O(alpha^n)` and each error column is `O(rho^n)`.
The constants may depend on the fixed size `k`. Expand the determinant
multilinearly in its columns. Every term with two main columns is zero,
since those columns are proportional. The surviving terms therefore have
either one main column and `k-1` error columns, or `k` error columns.
The Leibniz formula, or Hadamard's inequality, yields

\[
|D_k(n)|\le C_k\alpha^n\rho^{(k-1)n}+C'_k\rho^{kn}.
\tag{13}
\]

The second term is bounded by a constant times the first, since
`rho/alpha<1`. This proves (3). Under (4) the right side tends to zero;
`D_k(n)` is an integer, so it vanishes for **all** late `n`.

| Defect exponent | Smallest size from (13) | Boundary treatment |
| --- | --- | --- |
| `gamma<0` | `2` | The integer defect itself is eventually zero. |
| `gamma=0` | `3` | Size `2` is only bounded, and can remain nonzero. |
| `0<gamma<1`, `1/(1-gamma)` not an integer | `floor(1/(1-gamma))+2` | Strict inequality (4). |
| `gamma=1-1/m`, integer `m>=1` | `m+2` | Size `m+1` gives only `O(1)`. |
| Same reciprocal-integer case with `c_n=o(alpha^(gamma n))` | `m+1` | Now (13) is `o(1)`; integrality does give vanishing. |
| `gamma=1` | No size guaranteed | There is no decaying error in (2). |

The floor in (5) is intentional. Replacing it by
`ceil(1/(1-gamma))+1` loses the strict inequality precisely at reciprocal
integers. The estimate is sharp as a rank-one perturbation estimate; it
does not assert that every integer sequence has the maximal allowed rank.

**Integer boundary controls.** The Lucas sequence
`L_0=2, L_1=1, L_(n+2)=L_(n+1)+L_n` has
`alpha=(1+sqrt(5))/2`, error `(-1/alpha)^n`, and
`D_2(n)=5(-1)^n`. It satisfies the `gamma=0` defect bound, but its size-2
layer never vanishes.

For `gamma=1/2`, use the power traces of `f(X)=X^3-3X^2-1`:

\[
a_0=3,\quad a_1=3,\quad a_2=9,\qquad
a_{n+3}=3a_{n+2}+a_n.
\tag{14}
\]

The polynomial has one real root `alpha>3`: both stationary values, at
`0` and `2`, are negative. Its other roots are a complex-conjugate pair,
their product is `1/alpha`, and their common modulus is `alpha^(-1/2)`.
Thus (2) holds with `lambda=1` and `rho=alpha^(-1/2)`. Direct expansion of
the defect gives `c_n=O((alpha rho)^n)=O(alpha^(n/2))`.
The Vandermonde factorization of the trace Hankel matrix gives

\[
D_3(n)=\operatorname{disc}(f)(\alpha\beta\bar\beta)^n
=-135\ne0,\qquad D_4(n)=0.
\tag{15}
\]

These examples satisfy the integer and expanding hypotheses, and rule out
turning the equality case of (4) into a vanishing assertion.

For every integer `m>=1`, a rational boundary control for the estimate is

\[
b_n=2^{mn}+m\,2^{-n}\mathbf1_{m\mid n}.
\tag{16}
\]

It is the sum of the powers of `alpha=2^m` and of the `m` distinct numbers
`beta_j=(1/2) exp(2 pi i j/m)`. The latter sum is exactly the rational
second term of (16). With `gamma=1-1/m`, Vandermonde factorization gives
`D_(m+1)(n)=D_(m+1)(0)(-1)^((m-1)n)` with nonzero initial determinant,
while the next layer vanishes. These rational examples show sharpness of
the estimate for every reciprocal integer; they are not used as integer
counterexamples or to apply the integrality step.

At `gamma=1`, choose any transcendental `alpha>1` and
`a_n=floor(alpha^n)`. Then the ratios tend to `alpha`, the error is `O(1)`,
and expansion shows `c_n=O(alpha^n)`. A rational tail recurrence would,
after division by `a_n` and taking limits, give a nonzero polynomial over
`Q` vanishing at `alpha`, a contradiction. Thus the strict hypothesis
`gamma<1` cannot simply be dropped.

## 4. A bridge with exactly the contiguous-layer hypothesis

**Theorem (PV-HANKEL-RANK-BRIDGE).** Let `(a_n)` be a sequence over any
field `F`. If for some fixed `K>=1` and `N`,

\[
D_K(n)=0\quad\text{for every }n\ge N,
\tag{17}
\]

then there exist `M` with `N<=M<=N+K-1` and an order `0<=r<K` such that
the tail has a constant-coefficient recurrence

\[
a_{n+r}=\sum_{j=0}^{r-1}q_j a_{n+j}\quad(n\ge M),\qquad q_j\in F.
\tag{18}
\]

Order zero means `a_n=0` for every `n>=M`. For a nonzero tail, the order
can be chosen minimal and satisfies `D_r(n)!=0` for every `n>=M`.
The infinite matrix `(a_(M+i+j))_(i,j>=0)` then has rank exactly `r`.

**Proof: descent supplies the nonvanishing.** Desnanot-Jacobi, with the
empty determinant equal to one, is the polynomial identity

\[
D_{s+1}(n)D_{s-1}(n+2)
=D_s(n)D_s(n+2)-D_s(n+1)^2\quad(s\ge1).
\tag{19}
\]

For completeness, (19) does not require an invertible inner block. With
indeterminate entries, take the inner `(s-1)`-square block `B` and move the
two boundary rows and columns last. Its two-by-two Schur complement `S`
gives `det(H_(s+1))=det(B) det(S)`. The diagonal entries multiplied by
`det(B)` are `D_s(n)` and `D_s(n+2)`, and each off-diagonal entry multiplied
by `det(B)` is `(-1)^(s-1) D_s(n+1)`. Multiplying the Schur determinant by
`det(B)` proves (19) in the generic case. Clearing denominators makes this
an identity of polynomials over `Z`, valid under every specialization,
including `det(B)=0` and in any characteristic. For `s=1`, it is simply
the two-by-two determinant formula with the empty block determinant one.

Suppose `D_(s+1)(n)=0` for every `n>=T`. The lower layer
`x_n=D_s(n)` therefore obeys

\[
x_nx_{n+2}=x_{n+1}^2\quad(n\ge T).
\tag{20}
\]

If `x_(T+1)=0`, (20) at `T+1` implies `x_(T+2)=0`, and induction makes
the whole lower layer zero from `T+1` onward. Descend one size and advance
the starting index by one. If `x_(T+1)!=0`, (20) at `T` implies both
`x_T!=0` and `x_(T+2)!=0`; subsequent applications make every `x_n`
nonzero for `n>=T`. Stop with `r=s` and `M=T`. Starting from `(K,N)`,
this either stops at a positive order, or descends to `D_1(n)=a_n=0`
on a tail. There are at most `K-1` advances. This proves the asserted
bound on `M` and includes singular layers and the eventually zero tail.

**Proof: overlapping windows make the coefficients constant.** In the
nonzero case, `D_(r+1)(n)=0` and `D_r(n)!=0` for every `n>=M`.
For each such `n` the first `r` equations

\[
a_{n+i+r}=\sum_{j=0}^{r-1}q_j(n)a_{n+i+j}
\quad(0\le i<r)
\tag{21}
\]

have a unique solution, by invertibility of `H_r(n)`. Subtract that
linear combination from the last column of `H_(r+1)(n)`. Its first `r`
entries become zero. Expanding along that column yields

\[
0=D_{r+1}(n)=D_r(n)
\left(a_{n+2r}-\sum_{j=0}^{r-1}q_j(n)a_{n+r+j}\right).
\tag{22}
\]

The final residual is zero. Equations (21)-(22) with `i=1,...,r` are
exactly the `r` equations defining `q(n+1)`. Their solution is unique,
so `q(n+1)=q(n)` on the whole tail. This proves (18).

Let `C_j=(a_(M+i+j))_(i>=0)` be the infinite Hankel columns. Equation
(18), for every row index, expresses each `C_(j+r)` using the preceding
`r` columns. Thus the rank is at most `r`. The minor `D_r(M)!=0` makes
the first `r` columns independent, so the rank is exactly `r`, and no
smaller tail recurrence can exist. This finishes the proof. There was no
division by a lower minor until its nonvanishing had been established.

**Why every late shift matters.** For the integer sequence
`a_(2j)=0, a_(2j+1)=2^(j^2)`, all size-3 minors starting at even indices
vanish, but

\[
D_3(2j+1)=b_{j+1}(b_jb_{j+2}-b_{j+1}^2)\ne0,
\quad b_j=2^{j^2}.
\tag{23}
\]

Its superexponential subsequence rules out any constant-coefficient
recurrence: such recurrences have at most exponential growth, as follows
by bounding their finite-dimensional companion matrix powers. Thus one
vanishing moving minor, a sparse set of shifts, or an arbitrary finite
prefix does not supply (17).

## 5. The algebraic and Pisot endpoints

Apply Section 4 over `Q` after the integer vanishing step. The tail is
nonzero because it is expanding, so `1<=r<k_min`. Dividing (18) by `a_n`
and using the ratio limit gives

\[
p(\alpha)=0,\qquad
p(X)=X^r-\sum_{j=0}^{r-1}q_jX^j\in\mathbb Q[X].
\tag{24}
\]

This already closes the rational-recurrence-to-algebraicity implication.
The following argument also proves the stronger assertions in (6), without
importing an integer-series rationality theorem.

Let `V=span_Q{C_j:j>=0}`, of dimension `r`, and let `S` be the shift
`(x_0,x_1,...)->(x_1,x_2,...)`. It maps `C_j` to `C_(j+1)` and preserves
`V`. Projection to the first `r` coordinates is injective on `V`, because
its matrix on `C_0,...,C_(r-1)` has determinant `D_r(M)!=0`.
The group `L=sum_(j>=0) Z C_j` therefore embeds in `Z^r`. It is a finitely
generated free abelian group of rank `r`, spans `V`, and satisfies
`S(L) subset L`. In a `Z`-basis of `L`, `S` has an integer matrix `T`.
Cayley-Hamilton gives a monic integer annihilating polynomial of degree
`r`. The recurrence in (18) has minimal order `r`, so this characteristic
polynomial must be `p`. Hence `p in Z[X]`.

Also `q_0!=0`: replacing the last column by (18) gives

\[
D_r(n+1)=(-1)^{r-1}q_0D_r(n),
\tag{25}
\]

and both determinants are nonzero. Thus `p(0)!=0`.

The tail generating series is a rational function over `Q`. Its reduced
denominator is `z^r p(1/z)`, normalized to have constant term one; a
cancellation would lower the recurrence order. On the other hand, (2)
gives the meromorphic representation

\[
\sum_{j\ge0}a_{M+j}z^j
=\frac{\lambda\alpha^M}{1-\alpha z}
 +\sum_{j\ge0}e_{M+j}z^j,
\tag{26}
\]

where the second series is analytic for `|z|<1/rho`. In this disk the
only pole is the simple pole at `1/alpha`. Therefore `alpha` is a simple
root of `p`, and all other roots of `p` have modulus at most `rho<1`.

The irreducible monic integer factor containing `alpha` is its minimal
polynomial. Any remaining monic integer factor of `p` would have only
roots of modulus less than one and a nonzero constant term. The absolute
value of that integer constant term would be a product strictly less
than one, which is impossible. Thus `p` itself is the minimal polynomial
of `alpha`: `alpha` is Pisot and `r` is its degree. The coefficient of
the simple pole in the rational function (26) lies in `Q(alpha)`;
dividing by `alpha^M` proves `lambda in Q(alpha)`.

## 6. Evidence, provenance, and remaining scope

The general proofs above are the basis for promotion. Exact finite
regressions in `tests/test_hankel.py` check the ratio identity,
Desnanot-Jacobi in singular and signed cases, rank-one multilinearity,
the threshold floor, both integer boundary examples, rational boundary
examples, overlapping recurrence windows, descent controls, and the
sparse-shift counterexample. The kernel returns local recurrence candidates
and finite residuals; it does not certify an infinite tail from a prefix.

Claim mapping for the two source October 5 bootstraps:

| Bootstrap #1 identifier | Governed bootstrap #5 identifiers | Audited status here |
| --- | --- | --- |
| `PV-H3` (PROVISIONAL) | `PV-EXP-WINDOW` (CANDIDATE) and `PV-HANKEL-RANK-BRIDGE` (OPEN) | All three are PROVED under the hypotheses in (1). |

Sources inspected: the original #1 at
`11f4f3a69914c7641bd584e8b45e9ccc127df288`, #5 at
`7fa380f9e6ada21e860e3b491fa316fdf017146b`, the consolidated #1 at
`5d068d525a8f40180256f1cdc7bf36d35e2f2d11`, and issue #2 as retrieved on
October 5, 2026. During this audit #1 incorporated both bootstraps. This
focused change uses that consolidated source and updates its single
authoritative ledger and dossier. The original source statuses record the
state before this proof.

For background, Aitor Iribar Lopez's *The Carlson-Polya theorem on rational
functions*, Section 2, Theorem 1, states Kronecker's criterion using leading
Hankel determinants of **increasing order**. That formulation is not the
hypothesis obtained here, so Section 4 proves the needed bridge directly:
<https://people.math.ethz.ch/~airibar/Polya_Carlson.pdf>.

The general PV problem and the recurrence gap for merely vanishing or
general subexponential errors remain open, as do the bounded-gcd period-four
and coprime-tail programs. The subsequent
[normalized-defect note](defect-reconstruction.md) proves reconstruction,
polynomial equivalence, and the recurrent endpoint separately, and pins an
imported square-summability theorem for the polynomial range `A>1/2`.
Those follow-up results do not extend the fixed-size rank-one argument
here or reuse the withdrawn limsup shortcut.
