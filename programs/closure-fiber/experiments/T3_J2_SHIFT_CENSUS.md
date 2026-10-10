# T3 Census — Shifted Jordan-Totient Comparison

## Definition

For odd prime powers q>=5 define

Delta(q)=J_2(q+1)-J_2(q-1),

and the corresponding fixed-pattern pure-Nielsen sizes

S_-(q)=J_2(q-1)/6,
S_+(q)=J_2(q+1)/6.

By the T3 pure-Nielsen calibration theorem, sign(Delta(q)) is exactly the sign of the nonsplit-minus-split orbit-size difference.

## Exact census through q<=10000

Odd prime powers tested: 1267.

- Delta(q)>0: 650 cases
- Delta(q)=0: 3 cases
- Delta(q)<0: 614 cases

The equality cases in this range are:

- q=29: S_-=96, S_+=96;
- q=41: S_-=192, S_+=192;
- q=71: S_-=576, S_+=576.

First negative cases:

- q=47: 264 versus 256;
- q=53: 336 versus 324;
- q=59: 420 versus 384;
- q=83: 840 versus 768;
- q=89: 960 versus 864.

These computations are exact integer arithmetic and are evidence only, not proof of any asymptotic statement.

## Exact factorization formula

For odd q, the 2-primary factor cancels in the ratio, giving

J_2(q+1)/J_2(q-1)
=
((q+1)/(q-1))^2
*
[prod_{p odd | q+1}(1-p^{-2})]
/
[prod_{p odd | q-1}(1-p^{-2})].

This shows that the sign is governed by a competition between the obvious size factor and the squarefree prime-divisor penalties.

## Equality reduction

Write a=(q-1)/2, so a+1=(q+1)/2.

If q≡1 mod 4, equality Delta(q)=0 is equivalent to

4 J_2(a)=3 J_2(a+1).

If q≡3 mod 4, equality is equivalent to

3 J_2(a)=4 J_2(a+1).

Thus the equality problem reduces to a consecutive-value equation for J_2 with fixed rational multiplier 3/4 or 4/3.

## Literature boundary

The literature contains shifted-convolution and mean-value results for Jordan totients, but the current review did not locate a source addressing this specific pointwise sign/equality problem along odd prime powers.

That absence is not a novelty proof. A dedicated number-theory literature search is required before publication claims.

## Candidate conjectures

These are computationally motivated only:

### Theorem now proved — mod-3 sign law

The sign theorem is now stronger than the original sign-oscillation conjecture:

- \(q\equiv1\pmod3\) forces \(\Delta(q)>0\);
- \(q\equiv-1\pmod3\), \(q\ge322\), forces \(\Delta(q)<0\).

This completely classifies prime equality after one finite check below \(322\):

\[
J_2(q-1)=J_2(q+1)
\quad\text{for prime }q
\iff
q\in\{29,41,71\}.
\]

For odd prime powers, the only unresolved equality family is \(q=3^k\) with \(k\ge6\).

### Conjecture B — Prime-power equality on powers of 3

The equation Delta(q)=0 has density zero among odd prime powers.

Do not strengthen Conjecture B to finiteness: the current census is far too small for that claim.

## Next proof routes

1. Rewrite J_2 through Möbius inversion and analyze shifted sums.
2. Use CRT to construct finite families forcing many small-prime penalties onto q-1 or q+1.
3. Separate prime q from proper prime powers q=p^k.
4. Check whether sieve methods can prove infinitely many sign changes conditionally or unconditionally.
5. Search literature on shifted multiplicative functions and Jordan-totient correlations before committing to a theorem statement.