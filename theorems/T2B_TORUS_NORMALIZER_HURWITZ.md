# T2B — Rank-One Torus Normalizer as the Minimal Nonabelian Enlargement

## Scope

A rank-one torus by itself is too abelian to retain pure-braid dynamics. The smallest natural enlargement is its normalizer.

Assume a chosen Weyl representative exists over the base field, so that
[
N(T)cong Ttimes C_2,
]
where the nontrivial element of (C_2) acts on (T) by inversion.

Write elements as
[
(a,arepsilon),qquad ain T,quad arepsilonin{0,1},
]
and let
[
s(arepsilon):=(-1)^{arepsilon}.
]

The group law is
[
(a,arepsilon)(b,delta)
=
(a,b^{s(arepsilon)}, arepsilon+deltamod 2).
]

## Lemma T2B.1 — Inverse

[
(a,arepsilon)^{-1}
=
(a^{-s(arepsilon)},arepsilon).
]

This is immediate from the semidirect-product law.

## Proposition T2B.2 — Closed Hurwitz update law in the normalizer

Use the Hurwitz convention
[
eta(x,y)=(y,y^{-1}xy).
]

Let
[
x=(a,arepsilon),qquad
y=(b,delta).
]

Then
[
eta(x,y)
=
left(
(b,delta),
left(
a^{s(delta)}
b^{s(delta)(s(arepsilon)-1)},
arepsilon
ight)
ight).
]

### Proof

Since
[
y^{-1}=(b^{-s(delta)},delta),
]
we obtain
[
y^{-1}x
=
left(
b^{-s(delta)}a^{s(delta)},
delta+arepsilon
ight).
]
Multiplying by (y) gives torus coordinate
[
b^{-s(delta)}a^{s(delta)}
b^{s(delta+arepsilon)}
=
a^{s(delta)}
b^{s(delta)(s(arepsilon)-1)}.
]
The parity is
[
delta+arepsilon+delta=arepsilon.
]
(square)

## Corollary T2B.3 — Weyl parity is permuted, not conjugated

Under a Hurwitz move, the parity pair
[
(arepsilon,delta)
]
becomes
[
(delta,arepsilon).
]

Hence the projection
[
N(T)^r	o C_2^r
]
intertwines braid action with the ordinary permutation action.

In particular:

- the number of reflection-coset entries is invariant;
- the pure braid group fixes the parity vector;
- nontrivial pure-braid dynamics occurs entirely in the torus coordinates.

## Proposition T2B.4 — Product-one criterion

For a tuple
[
((a_1,arepsilon_1),ldots,(a_r,arepsilon_r)),
]
define prefix parities
[
E_j:=arepsilon_1+cdots+arepsilon_jpmod 2,
qquad E_0:=0.
]

Then
[
prod_{i=1}^r(a_i,arepsilon_i)
=
left(
prod_{i=1}^r a_i^{s(E_{i-1})},
E_r
ight).
]

Therefore the tuple has product one iff

1. (E_r=0), and
2. the twisted torus product satisfies
   [
   prod_{i=1}^r a_i^{s(E_{i-1})}=1.
   ]

This is the exact product-one law for normalizer-valued tuples.

## Proposition T2B.5 — Pure braid can act nontrivially

Consider one adjacent pair.

If
[
x=(a,0),qquad y=(b,1),
]
then
[
eta^2(x,y)
=
ig((a^{-1},0),(ba^2,1)ig).
]

Thus the pure braid generator is nontrivial whenever the torus coordinate (a) is not 2-torsion.

This proves that adjoining the Weyl (C_2)-decoration is enough to restore pure-braid dynamics that is impossible in the torus alone.

## Proposition T2B.6 — Monomial linearization of pure braid action

For a fixed parity pair, (eta^2) acts monomially on torus coordinates.

Writing multiplicative coordinates additively on the character lattice, the four parity cases give:

### parity (0,0)

[
(a,b)mapsto(a,b),
qquad
M_{00}=
egin{pmatrix}
1&0\
0&1
end{pmatrix}.
]

### parity (0,1)

[
(a,b)mapsto(a^{-1},ba^2),
qquad
M_{01}=
egin{pmatrix}
-1&0\
2&1
end{pmatrix}.
]

### parity (1,0)

[
(a,b)mapsto(ab^{-2},b^{-1}),
qquad
M_{10}=
egin{pmatrix}
1&-2\
0&-1
end{pmatrix}.
]

### parity (1,1)

[
(a,b)mapsto(a^{-1}b^2,a^{-2}b^3),
qquad
M_{11}=
egin{pmatrix}
-1&2\
-2&3
end{pmatrix}.
]

Each matrix lies in (GL_2(mathbb Z)).

Hence, after fixing the parity vector, the pure-braid action on (T^r) is piecewise given by integral Laurent-monomial transformations.

## Finite-field consequence

For a rank-one torus over (mathbb F_q), the rational point group is cyclic:

- split case: (|T(mathbb F_q)|=q-1);
- nonsplit norm-one case: (|T(mathbb F_q)|=q+1).

After choosing a generator of (T(mathbb F_q)), monomial braid actions become linear actions on exponent vectors modulo (q-1) or (q+1).

This gives a concrete route to a nontrivial T3 theorem:

> compare orbit structure of the same integral braid matrices modulo (q-1) and modulo (q+1).

That comparison uses the split/nonsplit arithmetic in a way stronger than merely counting the sizes of the two groups.

## Status

The semidirect-product formulas are elementary internal lemmas.

Potential novelty begins only with:

- classification of braid orbit sizes for prescribed parity patterns;
- split/nonsplit comparison theorems over finite fields;
- interaction with Nielsen generation conditions;
- identification of arithmetic statistics stable across families.
