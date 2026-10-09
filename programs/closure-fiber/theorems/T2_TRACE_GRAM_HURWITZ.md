# T2 Research Note — Hurwitz Action on Pairwise Trace Data

## Convention

Let
\[
\mathbf g=(g_1,\ldots,g_r)
\]
be a product-one tuple in a finite group \(G\), and let
\[
\rho:G\to GL(V)
\]
be a finite-dimensional self-dual representation over a field \(F\). Write
\[
\chi(g)=\operatorname{Tr}(\rho(g)).
\]

Define
\[
K(\mathbf g)=(K_{ab}),\qquad
K_{ab}:=\chi(g_a g_b^{-1}).
\]

We use the Hurwitz generator
\[
\beta_i:(x,y)\longmapsto (y,y^{-1}xy)
\]
on positions \(i,i+1\).

## Lemma T2.1 — Symmetry

If \(\rho\) is self-dual, then
\[
K_{ab}=K_{ba}.
\]

### Proof

Self-duality gives
\[
\chi(h)=\chi(h^{-1})
\]
for every \(h\in G\). Hence
\[
K_{ba}
=\chi(g_b g_a^{-1})
=\chi((g_a g_b^{-1})^{-1})
=\chi(g_a g_b^{-1})
=K_{ab}.
\]
\(\square\)

For an orthogonal representation, \(K\) is also the Gram matrix of the matrices \(\rho(g_a)\) with respect to the adjoint trace pairing
\[
\langle X,Y\rangle_{\mathrm{tr}}
:=\operatorname{Tr}(XY^*).
\]

## Proposition T2.2 — Exact Hurwitz update law

Let
\[
x=g_i,\qquad y=g_{i+1},
\]
and set
\[
\mathbf g'=\beta_i(\mathbf g).
\]
Thus
\[
g'_i=y,\qquad g'_{i+1}=y^{-1}xy,
\]
while all other entries are unchanged.

Then:

1. if \(a,b\notin\{i,i+1\}\),
   \[
   K'_{ab}=K_{ab};
   \]

2. for \(j\notin\{i,i+1\}\),
   \[
   K'_{ij}=K_{i+1,j};
   \]

3. for \(j\notin\{i,i+1\}\),
   \[
   K'_{i+1,j}
   =
   \chi(y^{-1}xyg_j^{-1});
   \]

4. the adjacent entry is preserved:
   \[
   K'_{i,i+1}=K_{i,i+1};
   \]

5. diagonal entries remain
   \[
   K'_{ii}=K'_{i+1,i+1}=\dim V.
   \]

By symmetry, the corresponding column formulas also hold.

### Proof

Items 1–3 follow by direct substitution. For item 4,
\[
K'_{i,i+1}
=
\chi\!\left(y(y^{-1}xy)^{-1}\right)
=
\chi(x^{-1}y).
\]
Since \(\rho\) is self-dual,
\[
\chi(x^{-1}y)
=
\chi((xy^{-1})^{-1})
=
\chi(xy^{-1})
=
K_{i,i+1}.
\]
\(\square\)

## Observation T2.3 — Closure is representation-dependent

The update formula introduces the word trace
\[
\chi(y^{-1}xyg_j^{-1}).
\]

Pairwise data \(K_{ab}=\chi(g_a g_b^{-1})\) therefore does not yield an immediately closed recurrence by formal substitution alone.

This does **not** prove that \(K'\) cannot be recovered from \(K\): in special representation classes, trace identities may express longer word traces in terms of finitely many shorter coordinates. The \(SL_2\) Fricke–Vogt–Horowitz theory is a standard example.

Accordingly, the correct research question is:

> For which representation classes is there a finite trace-coordinate state, containing or refining \(K\), that is closed under Hurwitz substitution?

A proof of genuine non-closure for \(K\) alone would require either two inputs with the same \(K\) and different \(K'\), or another argument excluding any universal update function.

## Proposition T2.4 — Abelian-image collapse

Suppose \(\rho(G)\) is abelian. Then every Hurwitz generator acts on the image tuple only by swapping adjacent entries:
\[
(\rho(x),\rho(y))
\longmapsto
(\rho(y),\rho(x)).
\]

Consequently, the braid-group action on the represented tuple factors through
\[
B_r\twoheadrightarrow S_r,
\]
and the pure braid group acts trivially.

### Proof

If \(\rho(x)\) and \(\rho(y)\) commute, then
\[
\rho(y^{-1}xy)=\rho(x).
\]
Hence the Hurwitz move becomes the adjacent transposition.
\(\square\)

## Consequence T2.5 — Rank-one torus images lose pure-braid data

Any representation whose image lies in a rank-one torus is abelian. Therefore a direct projection of Nielsen data into such a torus forgets pure-braid dynamics.

A bridge that aims to retain nonabelian braid information must keep additional structure, for example:

- the normalizer of a torus;
- a higher-dimensional representation;
- a larger trace-coordinate algebra;
- a semidirect-product decoration;
- or a coupled finite-group/torus state.

## Counterexample T2.6 — Several naive invariants of K are not braid invariants

Over \(F=\mathbb Q\), take \(G=S_3\) with its 3-dimensional permutation representation and the product-one tuple
\[
\mathbf g=((23),(23),(123),(132)).
\]

Apply \(\beta_2\):
\[
((23),(23),(123),(132))
\longmapsto
((23),(123),(12),(132)).
\]

The corresponding trace matrices are
\[
K=
\begin{pmatrix}
3&3&1&1\\
3&3&1&1\\
1&1&3&0\\
1&1&0&3
\end{pmatrix},
\qquad
K'=
\begin{pmatrix}
3&1&0&1\\
1&3&1&0\\
0&1&3&1\\
1&0&1&3
\end{pmatrix}.
\]

Over \(\mathbb Q\),
\[
\det K=0,\qquad \det K'=45,
\]
and
\[
\operatorname{rank}(K)=3,\qquad
\operatorname{rank}(K')=4.
\]

Their characteristic polynomials and principal-minor multisets also differ.

Thus determinant, rank, characteristic polynomial, and principal-minor multiset of \(K\) are not full braid invariants in general.

This counterexample does **not** prove that \(K'\) is not a function of \(K\).

## Revised T2 target

The current target is to determine a finite Hurwitz-closed coordinate state for useful representation classes and then identify braid invariants of that state.

Priority directions:

1. treat classical \(SL_2\) trace-coordinate closure as prior art, not novelty;
2. study torus normalizers as an exact nonabelian benchmark;
3. study orthogonal character varieties where ordinary traces do not generate the full coordinate ring;
4. compare pairwise trace data with complete character coordinates;
5. preserve explicit counterexamples to failed candidate invariants.
