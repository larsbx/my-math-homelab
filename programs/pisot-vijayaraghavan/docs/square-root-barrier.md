# The square-root defect barrier

**Status: PROVED (PV-SQRT-BARRIER).** The little-o threshold gives
eventual contiguous size-three Hankel vanishing. Under the explicit
expansion hypothesis it also gives a Pisot endpoint of degree at most
two. The big-O boundary can have degree three.

## Statement

Let `a_n` be integers positive on a tail and let
`c_n=a_n a_(n+2)-a_(n+1)^2`. If

\[
a_{n+j}\asymp a_n\quad\text{for each fixed nearby }j,
\qquad |c_n|=o(a_n^{1/2}),
\tag{1}
\]

then `D_3(n)=det(a_(n+i+j))_(0<=i,j<3)=0` for every sufficiently
large `n`. The contiguous-layer bridge gives a rational tail recurrence
of order at most two.

In particular, assume instead the explicit expanding-tail condition
`a_(n+1)/a_n>=b>1` eventually, together with the defect bound in (1).
Then the comparison in (1) follows, and there are `lambda>0` and
`alpha>1` with `a_n=lambda alpha^n+o(1)`. The number `alpha` is Pisot of
degree at most two, and `lambda in Q(alpha)`.

## Proof

Desnanot-Jacobi gives exactly

\[
a_{n+2}D_3(n)=c_nc_{n+2}-c_{n+1}^2.
\tag{2}
\]

The fixed-shift comparisons in (1) make the right side `o(a_n)`;
division by `a_(n+2) asymp a_n` gives `D_3(n)=o(1)`. The determinant
is an integer, so it is zero at every late shift. Apply
[PV-HANKEL-RANK-BRIDGE](exponential-window-hankel.md#4-a-bridge-with-exactly-the-contiguous-layer-hypothesis)
with `K=3` to obtain the rational recurrence of order less than three.

For the expanding variant, `a_n->infinity` and
`delta_n=c_n/a_n=o(a_n^(-1/2))->0`.
[Reconstruction](defect-reconstruction.md#1-two-tail-sums-reconstruct-the-witness)
first gives a finite ratio limit `alpha>=b>1` and vanishing witness
error. This ratio limit supplies the fixed-shift comparisons, so the
previous determinant argument applies. The
[recurrent endpoint](defect-reconstruction.md#4-vanishing-error-excludes-unit-roots-once-recurrence-is-known)
then gives the Pisot assertion; its degree is the minimal recurrence
order, at most two. This proof assumes no nonzero lower Hankel layer.

## Why little-o is necessary at this boundary

The integer power-trace sequence

\[
a_0=3,\quad a_1=3,\quad a_2=9,\qquad
a_{n+3}=3a_{n+2}+a_n
\]

has dominant root `alpha>3` of `X^3-3X^2-1`. The two other roots have
modulus `alpha^(-1/2)`, so `a_n=alpha^n+O(alpha^(-n/2))` and
`c_n=O(alpha^(n/2))=O(a_n^(1/2))`. Nevertheless `D_3(n)=-135` at
every shift and `D_4(n)=0`. The polynomial has no rational root and
is irreducible, so the degree is three. The proof and exact determinant
control are in the exponential-window note and `tests/test_hankel.py`.
Thus big-O at the threshold cannot force size-three vanishing or a
degree-two endpoint. This does not close the general vanishing-defect
or subexponential frontier.
