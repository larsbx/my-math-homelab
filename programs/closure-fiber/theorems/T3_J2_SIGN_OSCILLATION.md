# T3 Theorem — Mod-3 Sign Law for Shifted Jordan Totients

## Statement

Let
\[
\Delta(q):=J_2(q+1)-J_2(q-1)
\]
for odd integers \(q>1\) with \(3\nmid q\).

Then:

1. if
   \[
   q\equiv1\pmod3,
   \]
   then
   \[
   \Delta(q)>0;
   \]

2. if
   \[
   q\equiv-1\pmod3
   \]
   and \(q\ge322\), then
   \[
   \Delta(q)<0.
   \]

Consequently both signs occur infinitely often among primes.

For the finite-field Nielsen families
\[
S_-(q)=\frac{J_2(q-1)}6,
\qquad
S_+(q)=\frac{J_2(q+1)}6,
\]
the nonsplit orbit is larger on every prime \(q\equiv1\pmod3\), while the split orbit is larger for every prime \(q\equiv-1\pmod3\) with \(q\ge322\).

## Proof

For even \(n\), write
\[
J_2(n)=\frac34n^2\eta(n),
\qquad
\eta(n):=
\prod_{\substack{p\mid n\\p\text{ odd}}}
\left(1-\frac1{p^2}\right).
\]

### Lemma 1 — the \(3\)-penalty

If
\[
3\mid n,
\]
then
\[
\eta(n)\le1-\frac1{3^2}=\frac89.
\]

### Lemma 2 — a uniform lower bound away from \(3\)

If
\[
3\nmid n,
\]
then
\[
\eta(n)>\frac9{10}.
\]

#### Proof

Every odd prime divisor of \(n\) is at least \(5\). For finitely many \(0\le a_i\le1\),
\[
\prod_i(1-a_i)\ge1-\sum_i a_i.
\]
Hence
\[
\eta(n)
\ge
1-\sum_{\substack{p\mid n\\p\ge5}}\frac1{p^2}.
\]

For the primes below \(31\),
\[
\frac1{5^2}
+\frac1{7^2}
+\frac1{11^2}
+\frac1{13^2}
+\frac1{17^2}
+\frac1{19^2}
+\frac1{23^2}
+\frac1{29^2}
<
\frac1{25}+\frac{11}{250}
=
\frac{21}{250}.
\]

For primes \(p\ge31\), use the blocks
\[
(30k,30(k+1)],
\qquad k\ge1.
\]
A prime \(p\ge31\) is coprime to \(30\), so in each block there are at most eight possible residue classes containing such primes. Therefore, for some finite \(K\),
\[
\sum_{\substack{p\mid n\\p\ge31}}\frac1{p^2}
<
\sum_{k=1}^{K}\frac8{(30k)^2}
=
\frac2{225}\sum_{k=1}^{K}\frac1{k^2}.
\]

Every finite partial sum satisfies
\[
\sum_{k=1}^{K}\frac1{k^2}<\frac53.
\]
Indeed,
\[
\sum_{k=1}^{5}\frac1{k^2}=\frac{5269}{3600},
\]
and for \(k\ge6\),
\[
\frac1{k^2}<\frac1{k(k-1)}
=
\frac1{k-1}-\frac1k,
\]
so the remaining finite tail is \(<1/5\). Thus
\[
\frac{5269}{3600}+\frac15
=
\frac{5989}{3600}
<
\frac53.
\]

Hence
\[
\sum_{\substack{p\mid n\\p\ge31}}\frac1{p^2}
<
\frac2{135}.
\]

Combining the bounds,
\[
\sum_{\substack{p\mid n\\p\ge5}}\frac1{p^2}
<
\frac{21}{250}+\frac2{135}
=
\frac{667}{6750}
<
\frac1{10}.
\]

Therefore
\[
\eta(n)>\frac9{10}.
\]
\(\square\)

## Positive residue class

Suppose
\[
q\equiv1\pmod3.
\]
Then \(3\mid(q-1)\) and \(3\nmid(q+1)\). Hence
\[
\eta(q-1)\le\frac89,
\qquad
\eta(q+1)>\frac9{10}.
\]

Therefore
\[
\frac{J_2(q+1)}{J_2(q-1)}
>
\left(\frac{q+1}{q-1}\right)^2
\frac{9/10}{8/9}
=
\left(\frac{q+1}{q-1}\right)^2
\frac{81}{80}
>1.
\]

Thus
\[
\Delta(q)>0.
\]

## Negative residue class

Suppose
\[
q\equiv-1\pmod3.
\]
Then \(3\mid(q+1)\) and \(3\nmid(q-1)\). Hence
\[
\eta(q+1)\le\frac89,
\qquad
\eta(q-1)>\frac9{10}.
\]

Thus
\[
\frac{J_2(q+1)}{J_2(q-1)}
<
\left(\frac{q+1}{q-1}\right)^2
\frac{8/9}{9/10}
=
\left(\frac{q+1}{q-1}\right)^2
\frac{80}{81}.
\]

It is enough that
\[
\left(\frac{q+1}{q-1}\right)^2<\frac{81}{80}.
\]

This is equivalent to
\[
q^2-322q+1>0,
\]
which holds for every integer
\[
q\ge322.
\]

Therefore
\[
\Delta(q)<0
\]
for every \(q\equiv-1\pmod3\) with \(q\ge322\).

\(\square\)

## Corollary — infinite sign changes among primes

Every prime \(q>3\) is congruent to \(\pm1\pmod3\).

Dirichlet's theorem gives infinitely many primes in each residue class. Therefore both signs occur infinitely often among primes.

## Corollary — exact classification of prime equality

For an odd prime \(q\),
\[
J_2(q-1)=J_2(q+1)
\]
if and only if
\[
q\in\{29,41,71\}.
\]

### Proof

The theorem excludes every prime \(q\equiv1\pmod3\).

It also excludes every prime \(q\equiv-1\pmod3\) with \(q\ge322\).

The remaining primes \(q<322\) with \(q\equiv-1\pmod3\) are checked exactly in
\[
\texttt{experiments/T3\_PRIME\_EQUALITY\_CERTIFICATE.md}.
\]
Only \(29,41,71\) have \(\Delta(q)=0\).

The prime \(q=3\) is not a solution.

\(\square\)

## Corollary — reduction of the odd prime-power equality problem

Let \(q=p^k\) be an odd prime power. If
\[
J_2(q-1)=J_2(q+1),
\]
then either
\[
q\in\{29,41,71\},
\]
or
\[
q=3^k
\]
for some \(k\ge6\).

Indeed, if \(p\ne3\) and \(q\ge322\), the mod-\(3\) sign law excludes equality. The proper odd prime powers below \(322\) are checked exactly in the finite certificate and yield no equality. The powers \(3,9,27,81,243\) also yield no equality.

Thus the only unresolved prime-power family is
\[
q=3^k,\qquad k\ge6.
\]

## Optional analytic corollary

If one invokes the prime number theorem in arithmetic progressions, then the positive and negative sign sets each have relative prime density
\[
\frac12.
\]

This analytic density statement is not required for the finite/algebraic core theorem.

## Priority boundary

The literature contains substantial work on shifted averages and correlations of Jordan totients. The targeted search did not surface this exact pointwise mod-\(3\) sign law or the resulting prime equality classification.

That absence is not, by itself, a priority claim. Treat these as internal theorems pending a dedicated number-theory priority review.
