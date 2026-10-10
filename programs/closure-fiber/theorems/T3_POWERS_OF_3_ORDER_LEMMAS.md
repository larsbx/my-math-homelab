# T3 Powers-of-3 Residual — Multiplicative-Order and Primitive-Divisor Lemmas

## 1. Multiplicative-order dichotomy

Let
\[
k=2^s m,
\qquad m\ \text{odd},
\]
and let \(p\) be an odd prime with \(p\nmid3\).

### Lemma 1.1 — divisors of \(3^k+1\)

If
\[
p\mid 3^k+1,
\]
then
\[
\operatorname{ord}_p(3)\mid2k
\]
but
\[
\operatorname{ord}_p(3)\nmid k.
\]

Consequently,
\[
v_2(\operatorname{ord}_p(3))=s+1.
\]

### Proof

Set
\[
d=\operatorname{ord}_p(3).
\]

Since
\[
3^{2k}\equiv1\pmod p,
\]
we have
\[
d\mid2k.
\]

But
\[
3^k\equiv-1\pmod p,
\]
so
\[
d\nmid k.
\]

Writing \(k=2^s m\) with \(m\) odd, any divisor of \(2k=2^{s+1}m\) that does not divide \(k=2^sm\) must have 2-adic valuation exactly \(s+1\). Therefore
\[
v_2(d)=s+1.
\]
\(\square\)

### Corollary 1.2 — congruence of plus-side prime divisors

Every odd prime divisor \(p\mid3^k+1\) satisfies
\[
2^{s+1}\mid p-1,
\]
hence
\[
p\equiv1\pmod{2^{s+1}}.
\]

This follows because
\[
\operatorname{ord}_p(3)\mid p-1.
\]

For even \(k\), this already gives
\[
p\equiv1\pmod4.
\]

For \(4\mid k\), every odd prime divisor of \(3^k+1\) satisfies
\[
p\equiv1\pmod8.
\]

## 2. Minus-side comparison

If
\[
p\mid3^k-1,
\]
then
\[
\operatorname{ord}_p(3)\mid k.
\]

Therefore
\[
v_2(\operatorname{ord}_p(3))\le s.
\]

Unlike the plus side, this does not force all odd prime divisors into a single congruence class modulo \(2^{s+1}\).

This asymmetry is potentially useful for valuation bounds but is not, by itself, an equality obstruction.

## 3. Primitive divisors

The Bang–Zsigmondy theorem gives a primitive prime divisor of
\[
3^n-1
\]
for every \(n>1\) except the standard exceptional \(n=2\) case when \(3+1\) is a power of \(2\).

### Proposition 3.1 — primitive divisor on the plus side

For every
\[
k\ge2,
\]
there exists an odd prime \(p_k^+\) such that
\[
p_k^+\mid3^k+1
\]
and
\[
\operatorname{ord}_{p_k^+}(3)=2k.
\]

### Proof

Apply Bang–Zsigmondy to
\[
3^{2k}-1.
\]

For \(k\ge2\), the exponent \(2k\ge4\) is not exceptional for base \(3\). Hence there is a primitive prime divisor \(p\) of \(3^{2k}-1\), so
\[
\operatorname{ord}_p(3)=2k.
\]

Since \(p\) is primitive at exponent \(2k\), it cannot divide
\[
3^k-1.
\]

But
\[
3^{2k}-1=(3^k-1)(3^k+1),
\]
so
\[
p\mid3^k+1.
\]
\(\square\)

### Proposition 3.2 — primitive divisor on the minus side

For every
\[
k\ge3,
\]
there exists a prime \(p_k^-\) dividing
\[
3^k-1
\]
with
\[
\operatorname{ord}_{p_k^-}(3)=k.
\]

This is the direct Bang–Zsigmondy primitive divisor for exponent \(k\).

## 4. Congruence consequences

The primitive divisors satisfy
\[
p_k^+\equiv1\pmod{2k},
\]
and
\[
p_k^-\equiv1\pmod{k}.
\]

Thus the two sides always contain primes whose multiplicative orders encode the full exponent \(k\).

In particular, for
\[
k=2^s m,
\]
the plus-side primitive divisor satisfies
\[
p_k^+\equiv1\pmod{2^{s+1}},
\]
while the minus-side primitive divisor is only forced by order considerations to satisfy
\[
p_k^-\equiv1\pmod{2^s}.
\]

## 5. Why this still does not solve Jordan equality

The Jordan factor associated with a prime power
\[
p^a\parallel n
\]
is
\[
p^{2a-2}(p^2-1).
\]

If a primitive divisor \(p\) appears only to the first power, then \(p\) itself does **not** divide its Jordan contribution; the contribution is
\[
p^2-1.
\]

Therefore the existence of a prime divisor unique to one cyclotomic side does not directly imply a prime divisor unique to the corresponding Jordan value.

A successful primitive-divisor argument must instead control factors of
\[
(p_k^\pm)^2-1
\]
or combine primitive divisors with valuations.

## 6. Immediate valuation consequence

For any odd
\[
p\mid3^k+1,
\]
with \(s=v_2(k)\),

\[
v_2(p^2-1)
=
v_2(p-1)+v_2(p+1).
\]

If \(s\ge1\), then
\[
p\equiv1\pmod4,
\]
so
\[
v_2(p+1)=1
\]
and
\[
v_2(p^2-1)\ge s+2.
\]

Hence every odd prime divisor of the plus side contributes at least \(s+2\) to the 2-adic valuation of its square-minus-one factor.

This is a real structural asymmetry, but the existing \(k=19,25\) fixtures show that small-prime valuation equality can still occur after all contributions are combined.

## 7. Next proof obligation

The most promising next statement is not merely the existence of primitive divisors, but a **cross-side incompatibility lemma** of the following type:

> for at least one cyclotomic primitive divisor \(p_k^\pm\), some prime divisor of \((p_k^\pm)^2-1\) has a valuation or order pattern that cannot be reproduced by the Jordan factors on the opposite side.

Until such a lemma is proved, Bang–Zsigmondy remains structural input rather than a solution.
