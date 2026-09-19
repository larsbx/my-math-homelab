# T2 Research Note — Hurwitz Action on Trace-Gram Data

## Convention

Let
[
mathbf g=(g_1,ldots,g_r)
]
be a product-one tuple in a finite group (G), and let
[
ho:G	o GL(V)
]
be a finite-dimensional self-dual representation over a field (F). Write
[
chi(g)=operatorname{Tr}(ho(g)).
]

For an orthogonal representation, self-duality is supplied by the preserved nondegenerate bilinear form.

Define the pairwise trace-Gram matrix
[
K(mathbf g)=(K_{ab}),qquad
K_{ab}:=chi(g_a g_b^{-1}).
]

We use the Hurwitz generator
[
eta_i:(x,y)longmapsto (y,y^{-1}xy)
]
on positions (i,i+1).

## Lemma T2.1 — Symmetry

If (ho) is self-dual, then
[
K_{ab}=K_{ba}.
]

### Proof

Self-duality gives
[
chi(h)=chi(h^{-1})
]
for every (hin G). Hence
[
K_{ba}
=chi(g_b g_a^{-1})
=chi((g_a g_b^{-1})^{-1})
=chi(g_a g_b^{-1})
=K_{ab}.
]
(square)

For an orthogonal representation this is also the Gram matrix of the matrices (ho(g_a)) with respect to the adjoint trace pairing
[
langle X,Yangle_{mathrm{tr}}
:=operatorname{Tr}(XY^*).
]

## Proposition T2.2 — Exact Hurwitz update law

Let
[
x=g_i,qquad y=g_{i+1},
]
and set
[
mathbf g'=eta_i(mathbf g).
]
Thus
[
g'_i=y,qquad g'_{i+1}=y^{-1}xy,
]
while all other entries are unchanged.

Then:

1. if (a,b
otin{i,i+1}),
   [
   K'_{ab}=K_{ab};
   ]

2. for (j
otin{i,i+1}),
   [
   K'_{ij}=K_{i+1,j};
   ]

3. for (j
otin{i,i+1}),
   [
   K'_{i+1,j}
   =
   chi(y^{-1}xyg_j^{-1});
   ]

4. the adjacent entry is preserved:
   [
   K'_{i,i+1}=K_{i,i+1};
   ]

5. diagonal entries remain
   [
   K'_{ii}=K'_{i+1,i+1}=dim V.
   ]

By symmetry, the corresponding column formulas also hold.

### Proof

Items 1–3 follow by direct substitution.

For item 4,
[
K'_{i,i+1}
=
chi!left(
y(y^{-1}xy)^{-1}
ight)
=
chi(x^{-1}y).
]
Since (ho) is self-dual,
[
chi(x^{-1}y)
=
chi((xy^{-1})^{-1})
=
chi(xy^{-1})
=
K_{i,i+1}.
]
(square)

## Corollary T2.3 — Pairwise trace-Gram data is not a closed braid state

In general, (K(mathbf g')) is **not determined by** (K(mathbf g)).

The obstruction is the new word trace
[
chi(y^{-1}xyg_j^{-1}),
]
which is not, for a general representation, a function of the pairwise quantities
[
chi(g_a g_b^{-1}).
]

Therefore a braid-equivariant state requires a larger trace algebra or additional representation-specific identities.

This eliminates the naive program "iterate the braid action using only the pairwise trace-Gram matrix" in general dimension.

## Proposition T2.4 — Abelian-image collapse

Suppose (ho(G)) is abelian. Then every Hurwitz generator acts on the image tuple only by swapping adjacent entries:
[
(ho(x),ho(y))
longmapsto
(ho(y),ho(x)).
]

Consequently, the braid-group action on the represented tuple factors through
[
B_r	woheadrightarrow S_r,
]
and the pure braid group acts trivially.

### Proof

If (ho(x)) and (ho(y)) commute, then
[
ho(y^{-1}xy)=ho(x).
]
Hence the Hurwitz move becomes the adjacent transposition.
(square)

## Consequence T2.5 — A rank-one torus cannot retain nonabelian braid information by itself

Any representation whose image lies in a rank-one torus is abelian. Therefore a direct projection of Nielsen data into such a torus forgets all pure-braid dynamics.

This is a structural obstruction, not an implementation limitation.

A successful bridge must retain additional nonabelian data, for example through:

- the normalizer of a torus rather than the torus alone;
- a higher-dimensional orthogonal representation;
- an enriched trace algebra;
- a semidirect-product decoration;
- or a paired finite-group/torus state.

## Counterexample T2.6 — Determinant, rank, characteristic polynomial, and principal-minor multiset are not braid invariants

Take (G=S_3) with its 3-dimensional permutation representation, which is orthogonal for the standard bilinear form.

Use the product-one tuple
[
mathbf g=((23),(23),(123),(132)).
]

Apply (eta_2):
[
((23),(23),(123),(132))
longmapsto
((23),(123),(12),(132)).
]

The corresponding trace-Gram matrices are
[
K=
egin{pmatrix}
3&3&1&1\
3&3&1&1\
1&1&3&0\
1&1&0&3
end{pmatrix},
]
and
[
K'=
egin{pmatrix}
3&1&0&1\
1&3&1&0\
0&1&3&1\
1&0&1&3
end{pmatrix}.
]

They satisfy
[
det K=0,qquad det K'=45,
]
and
[
operatorname{rank}(K)=3,qquad
operatorname{rank}(K')=4.
]

Their characteristic polynomials are
[
t^4-12t^3+41t^2-42t
]
and
[
t^4-12t^3+50t^2-84t+45.
]

The principal-minor multisets also change.

Hence the following are **not** full braid invariants in general:

- determinant;
- rank;
- characteristic polynomial;
- principal-minor multiset.

## Revised T2 target

The correct problem is no longer "find an invariant of the pairwise matrix (K)." It is:

> Determine the smallest trace-word state closed under Hurwitz action for useful representation classes, and then identify invariants of that closed state.

Promising special cases:

1. 2-dimensional self-dual representations, where Fricke-type trace identities may close the required trace algebra;
2. representations with image in a torus normalizer, where the nonabelian information is a finite Weyl-group decoration;
3. finite classical groups with bounded trace-word generation;
4. orbit-averaged invariants of a finite braid orbit, computed from the full trace-word closure rather than from one pairwise matrix.

## Immediate next lemma

For a chosen representation class (mathcal R), define the trace-word algebra generated by
[
chi(w(g_1,ldots,g_r))
]
for words (w) appearing under Hurwitz substitution.

The next theorem target is a finite-generation/closure statement for this algebra in a restricted but nontrivial class of representations.
