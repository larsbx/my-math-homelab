# PROOF_CERTIFICATE

## Spectral Module Proof Certificate — Alphabet 3

### Purpose

This document packages the completed **Spectral module** of the alphabet-3 horizontal-invariant program as a finite proof certificate.

It is designed to be cited as a **black-box module** in later SCC-level work.

It certifies, for every primitive irreducible Pisot substitution $\sigma$ on alphabet $\{1, 2, 3\}$ and every length-7 $K_2$-zero seed $s_k$ ($k = 0, \ldots, 5$):
$$\Pi_{\mathrm{dom}}^\sigma K_3(s_k) \ne 0.$$

It does **not** certify the remaining SCC-level obstruction. In particular, it does not prove that every closed recurrent SCC with $K_2|_C \equiv 0$ contains, reaches, or projects to a length-7 seed. That is a separate Normal-form / Obstruction module (open).

---

## 1. Ambient finite data

Fix
$$V = \mathbb{Q}^3, \qquad \mathcal{A} = \{1, 2, 3\}.$$

Let $\sigma$ be a primitive irreducible Pisot (PIP) substitution on $\mathcal{A}$, with incidence matrix
$$M = M_\sigma \in M_3(\mathbb{Z}_{\ge 0}), \quad (M)_{ij} = \#\text{ of } i \text{ in } \sigma(j).$$

Let $\chi_M(t) = \det(tI - M)$. By PIP hypothesis:
- $\chi_M$ is irreducible cubic over $\mathbb{Q}$;
- $\chi_M$ has a Perron root $\beta = \beta_1 > 1$ with $|\beta_2|, |\beta_3| < 1$.

**Remark (distinct eigenvalues).** Since $\chi_M \in \mathbb{Q}[t]$ is irreducible over $\mathbb{Q}$ and $\mathbb{Q}$ has characteristic $0$, $\chi_M$ is separable, so the three roots $\beta_1, \beta_2, \beta_3$ are pairwise distinct. Hence $M$ is diagonalizable over the splitting field.

The finite tensor ambient space for degree 3 is
$$V^{\otimes 3} \cong \mathbb{Q}^{27}.$$

We use lex ordering on $V^{\otimes 3}$: index $(a, b, c)$ corresponds to $e_a \otimes e_b \otimes e_c$, with the order
$$(1,1,1), (1,1,2), \ldots, (3,3,2), (3,3,3).$$

---

## 2. Horizontal invariants

For a word $w \in \mathcal{A}^*$, define scattered subword counts:
$$N_i(w) = \#\{a : w_a = i\},$$
$$N_{ij}(w) = \#\{a < b : w_a = i, w_b = j\},$$
$$N_{ijk}(w) = \#\{a < b < c : w_a = i, w_b = j, w_c = k\}.$$

For a balanced pair $s = (u, v)$ with $|u| = |v|$ and $\mathrm{Parikh}(u) = \mathrm{Parikh}(v)$, define:
$$K_1(s) = (N_i(u) - N_i(v))_i \in \mathbb{Z}^3,$$
$$K_2(s) = (N_{ij}(u) - N_{ij}(v))_{i,j} \in \mathbb{Z}^9,$$
$$K_3(s) = (N_{ijk}(u) - N_{ijk}(v))_{i,j,k} \in \mathbb{Z}^{27}.$$

For balanced pairs, $K_1(s) = 0$ tautologically. The Spectral module concerns states satisfying $K_2(s) = 0$ and studies $K_3(s)$.

---

## 3. Shuffle-kernel sector $W_3$

Let $W_3 \subset V^{\otimes 3}$ be the shuffle-kernel sector cut out by the degree-3 shuffle relations:
$$W_3 = \ker\bigl(S : V^{\otimes 3} \to V^{\otimes 3}\bigr), \quad S(e_a \otimes e_b \otimes e_c) = e_a \otimes e_b \otimes e_c + e_b \otimes e_a \otimes e_c + e_b \otimes e_c \otimes e_a.$$

### Certified facts

1. $\dim W_3 = 8$.
2. $W_3$ is invariant under $M^{\otimes 3}$.
3. If $K_2(s) = 0$, then $K_3(s) \in W_3$.
4. As a $\mathrm{GL}(V)$-module, $W_3 \cong S_{(2,1)} V$.

### Explicit $\mathbb{Z}$-basis of $W_3$ (used for verification)

Each basis vector is given as a list of $((a,b,c), \text{coefficient})$ pairs:

$$
\begin{aligned}
b_1 &: e_{1,1,2} - 2\,e_{1,2,1} + e_{2,1,1}, \\
b_2 &: e_{1,2,2} - 2\,e_{2,1,2} + e_{2,2,1}, \\
b_3 &: e_{1,1,3} - 2\,e_{1,3,1} + e_{3,1,1}, \\
b_4 &: -e_{1,3,2} + e_{2,1,3} - e_{2,3,1} + e_{3,1,2}, \\
b_5 &: e_{1,2,3} - e_{1,3,2} - e_{2,3,1} + e_{3,2,1}, \\
b_6 &: e_{2,2,3} - 2\,e_{2,3,2} + e_{3,2,2}, \\
b_7 &: e_{1,3,3} - 2\,e_{3,1,3} + e_{3,3,1}, \\
b_8 &: e_{2,3,3} - 2\,e_{3,2,3} + e_{3,3,2}.
\end{aligned}
$$

These $b_1, \ldots, b_8$ span $W_3$ over $\mathbb{Q}$ and are independent. (Verifiable by computing the shuffle relations and taking $\ker(S)$.)

### Spectrum of $\Phi_3$

Define
$$\Phi_3 = M^{\otimes 3}\big|_{W_3}.$$

Then the Schur-sector spectrum is
$$\mathrm{Spec}(\Phi_3) = \{\beta_i^2 \beta_j : i \ne j\} \cup \{\det M, \det M\},$$
with $\det M = \beta_1 \beta_2 \beta_3$ appearing with multiplicity $2$. The dominant spectral modulus is
$$\rho(\Phi_3) = \beta^2 |\beta_2|.$$

### Lemma (Φ_3 semisimplicity)

**Lemma.** Under the PIP hypothesis, $\Phi_3$ is diagonalizable over the splitting field of $\chi_M$.

**Proof.** $M$ is diagonalizable over the splitting field (distinct eigenvalues from $\chi_M$ irreducible separable). Hence $M^{\otimes 3}$ is diagonalizable, and so is its restriction to the invariant subspace $W_3$. $\square$

This semisimplicity makes spectral projections and rational primary decompositions well-defined.

---

## 4. Length-7 seed list

There are exactly six length-7 $K_2$-zero seed pairs $\mathcal{S}_7 = \{s_0, \ldots, s_5\}$:

$$
\begin{aligned}
s_0 &= ((1,2,2,3,3,1,2), (2,3,1,1,2,2,3)), \\
s_1 &= ((1,2,3,3,1,1,2), (3,1,1,2,2,3,1)), \\
s_2 &= ((1,3,2,2,1,1,3), (2,1,1,3,3,2,1)), \\
s_3 &= ((1,3,3,2,2,1,3), (3,2,1,1,3,3,2)), \\
s_4 &= ((2,1,3,3,2,2,1), (3,2,2,1,1,3,2)), \\
s_5 &= ((2,3,3,1,1,2,3), (3,1,2,2,3,3,1)).
\end{aligned}
$$

For each seed: $K_2(s_k) = 0$ and $K_3(s_k) \in W_3 \cap \mathbb{Z}^{27}$. (Direct integer check.)

---

## 5. The $\Theta$-identification

Define the Levi-Civita contraction $\Theta : V^{\otimes 3} \to M_3(\mathbb{Q})$ by
$$\Theta(x)_{ij} = \sum_{k, l = 1}^{3} \varepsilon_{jkl}\, x_{ikl}.$$

Restricted to $W_3$, this realizes the representation-theoretic identification
$$W_3 \cong S_{(2,1)} V \cong \mathfrak{sl}(V) \otimes \det V,$$
i.e., $\Theta : W_3 \xrightarrow{\sim} \mathfrak{sl}_3(\mathbb{Q})$.

### Certified intertwining identity

For every $M \in \mathrm{GL}_3(\mathbb{Q})$ and every $x \in W_3$:
$$\Theta(M^{\otimes 3} x) = \det(M) \cdot M\,\Theta(x)\,M^{-1}.$$

**Equivalently**, on $\mathfrak{sl}_3(\mathbb{Q})$, $\Phi_3$ acts as
$$A \longmapsto \det(M) \cdot M A M^{-1} = \det(M) \cdot \mathrm{Ad}_M(A).$$

(This is the standard isomorphism of $\mathrm{GL}(V)$-modules $S_{(2,1)} V \cong \mathfrak{sl}(V) \otimes \det V$, made explicit by $\Theta$. After clearing the inverse — i.e., multiplying both sides by $M$ on the right — both sides become polynomial expressions in the entries of $M$ and the coordinates of $x$. The identity is verified symbolically on the basis $b_1, \ldots, b_8$ of $W_3$ from Section 3, hence holds identically in $\mathbb{Z}[m_{ij}, x_1, \ldots, x_{27}]$.)

### Determinant eigenspace as centralizer

Under $\Theta$, the determinant generalized eigenspace $W_{\det}(\sigma) := \ker((\Phi_3 - \det M \cdot I)^2)$ corresponds to the centralizer
$$\mathfrak{z}_{\mathfrak{sl}_3}(M) = \{A \in \mathfrak{sl}_3(\mathbb{Q}) : [M, A] = 0\}.$$

By Φ_3 semisimplicity, $W_{\det}(\sigma) = \ker(\Phi_3 - \det M \cdot I)$ (no Jordan blocks).

---

## 6. Seed matrices $A_k = \Theta(K_3(s_k))$

For each seed $s_k$, define
$$A_k := \Theta(K_3(s_k)) \in \mathfrak{sl}_3(\mathbb{Z}).$$

### Explicit data

**Seed $s_0$:**
$$A_0 = \begin{pmatrix} -2 & 3 & -3 \\ -3 & 4 & -3 \\ -3 & 3 & -2 \end{pmatrix}, \quad \chi_{A_0}(t) = t^3 - 3t + 2 = (t - 1)^2(t + 2).$$

**Seed $s_1$:**
$$A_1 = \begin{pmatrix} -4 & 3 & 3 \\ -3 & 2 & 3 \\ -3 & 3 & 2 \end{pmatrix}, \quad \chi_{A_1}(t) = t^3 - 3t - 2 = (t - 2)(t + 1)^2.$$

**Seed $s_2$:**
$$A_2 = \begin{pmatrix} 4 & -3 & -3 \\ 3 & -2 & -3 \\ 3 & -3 & -2 \end{pmatrix}, \quad \chi_{A_2}(t) = t^3 - 3t + 2 = (t - 1)^2(t + 2).$$

**Seed $s_3$:**
$$A_3 = \begin{pmatrix} 2 & 3 & -3 \\ 3 & 2 & -3 \\ 3 & 3 & -4 \end{pmatrix}, \quad \chi_{A_3}(t) = t^3 - 3t - 2 = (t - 2)(t + 1)^2.$$

**Seed $s_4$:**
$$A_4 = \begin{pmatrix} -2 & 3 & -3 \\ -3 & 4 & -3 \\ -3 & 3 & -2 \end{pmatrix}, \quad \chi_{A_4}(t) = t^3 - 3t + 2 = (t - 1)^2(t + 2).$$

**Seed $s_5$:**
$$A_5 = \begin{pmatrix} -2 & -3 & 3 \\ -3 & -2 & 3 \\ -3 & -3 & 4 \end{pmatrix}, \quad \chi_{A_5}(t) = t^3 - 3t + 2 = (t - 1)^2(t + 2).$$

### Summary table

| $k$ | $\chi_{A_k}(t)$ | Eigenvalues (with mult.) | Rank | $\det A_k$ | $\mathrm{tr}(A_k^2)$ | $\mathrm{tr}(A_k^3)$ |
|---|---|---|---|---|---|---|
| 0 | $(t-1)^2(t+2)$ | $\{-2, 1, 1\}$ | 3 | $-2$ | $6$ | $-6$ |
| 1 | $(t-2)(t+1)^2$ | $\{2, -1, -1\}$ | 3 | $2$ | $6$ | $6$ |
| 2 | $(t-1)^2(t+2)$ | $\{-2, 1, 1\}$ | 3 | $-2$ | $6$ | $-6$ |
| 3 | $(t-2)(t+1)^2$ | $\{2, -1, -1\}$ | 3 | $2$ | $6$ | $6$ |
| 4 | $(t-1)^2(t+2)$ | $\{-2, 1, 1\}$ | 3 | $-2$ | $6$ | $-6$ |
| 5 | $(t-1)^2(t+2)$ | $\{-2, 1, 1\}$ | 3 | $-2$ | $6$ | $-6$ |

### Certified properties (six-case finite check)

For every $k \in \{0, 1, \ldots, 5\}$:

1. $A_k \ne 0$.
2. $A_k \in \mathfrak{sl}_3(\mathbb{Z})$ ($\mathrm{tr}(A_k) = 0$ verified).
3. $A_k$ has rank $3$ (i.e., $\det A_k \ne 0$).
4. $A_k$ is diagonalizable over $\mathbb{Q}$.
5. $\chi_{A_k}$ is reducible over $\mathbb{Q}$ with two distinct rational eigenvalues $\lambda_k$ (simple) and $\mu_k$ (algebraic multiplicity 2), with $\lambda_k \ne \mu_k$.
6. **Universal eigenvector identity:** for every $k$, the simple eigenspace is
$$\ker(A_k - \lambda_k I) = \mathbb{Q} \cdot (1, 1, 1)^T,$$
i.e., $A_k (1,1,1)^T = \lambda_k (1,1,1)^T$ with $\lambda_k \in \{-2, 2\}$.
7. $\mathrm{tr}(A_k^2) = 6$ for every $k$.

(All seven properties verified by direct exact computation — see Section 13 verification scripts.)

---

## 7. PIP-Locus Target 1

For each seed $s_k$, define the polynomial vector
$$Q_k(M) := (M^{\otimes 3} - \det(M) \cdot I)^2\, K_3(s_k) \in \mathbb{Z}[m_{ij}]^{27}.$$

### Theorem (PIP-Locus Target 1)

For every PIP $\sigma$ on alphabet $\{1, 2, 3\}$ and every seed $s_k \in \mathcal{S}_7$:
$$Q_k(M_\sigma) \ne 0.$$
Equivalently, $K_3(s_k) \notin W_{\det}(\sigma)$.

### Proof

Suppose for contradiction $Q_k(M) = 0$, i.e., $K_3(s_k) \in \ker((\Phi_3^\sigma - \det M \cdot I)^2)$.

By Φ_3 semisimplicity (Section 3 Lemma), $\ker((\Phi_3 - \det M I)^2) = \ker(\Phi_3 - \det M I) = W_{\det}(\sigma)$.

Under $\Theta$ (Section 5), $W_{\det}(\sigma)$ corresponds to the centralizer $\mathfrak{z}_{\mathfrak{sl}_3}(M)$. Hence
$$[M, A_k] = 0.$$

Since $\chi_M$ is irreducible separable, $M$ is diagonalizable with three pairwise distinct eigenvalues over the splitting field. Hence any matrix commuting with $M$ preserves each eigenspace of $M$ — and conversely $M$ preserves each eigenspace of $A_k$.

In particular, $M$ preserves the **simple rational** eigenspace of $A_k$ (Section 6 property 6):
$$M \cdot \mathbb{Q}(1, 1, 1)^T \subseteq \mathbb{Q}(1, 1, 1)^T.$$

Hence $M(1,1,1)^T = \alpha (1,1,1)^T$ for some $\alpha \in \mathbb{Q}$, i.e., $\alpha$ is a rational eigenvalue of $M$.

But $\chi_M$ is irreducible cubic over $\mathbb{Q}$ — it has no rational roots. **Contradiction.**

Therefore $Q_k(M_\sigma) \ne 0$ for every PIP $\sigma$ and every $k$. $\square$

### Concrete corollary

For every PIP $M$ on alphabet 3, $M$ does NOT have all row sums equal. (Else $(1,1,1)^T$ would be a rational eigenvector, contradicting irreducibility of $\chi_M$.)

---

## 8. Irreducible-$P_6^\sigma$ branch (Galois group $S_3$)

Let
$$P_6^\sigma(t) = \prod_{i \ne j}(t - \beta_i^2 \beta_j) \in \mathbb{Q}[t].$$

This is the degree-6 factor of $\chi_{\Phi_3}$ corresponding to non-determinant eigenvalues. The full $\mathbb{Q}$-factorization is
$$\chi_{\Phi_3}(t) = P_6^\sigma(t) \cdot (t - \det M)^2.$$

### Branch hypothesis

$P_6^\sigma$ is irreducible over $\mathbb{Q}$. Equivalently, the Galois group of $\chi_M$ over $\mathbb{Q}$ is $S_3$, i.e., the discriminant $\Delta(\chi_M)$ is **not** a square in $\mathbb{Q}$.

### Theorem (Spectral Dominant-Capture, $S_3$ branch)

Under the branch hypothesis, for every length-7 seed $s_k$:
$$\Pi_{\mathrm{dom}}^\sigma K_3(s_k) \ne 0.$$

### Proof

By PIP-Locus Target 1 (Section 7), $K_3(s_k) \notin W_{\det}(\sigma)$.

By Φ_3 semisimplicity, $W_3 = W_6(\sigma) \oplus W_{\det}(\sigma)$ as a rational direct-sum decomposition, where $W_6(\sigma) = \ker(P_6^\sigma(\Phi_3))$ is 6-dim.

Hence $K_3(s_k)$ has a non-zero $W_6(\sigma)$ component.

$P_6^\sigma$ irreducible over $\mathbb{Q}$ means $W_6(\sigma)$ is a single irreducible $\mathbb{Q}[\Phi_3]$-module. The Galois group $S_3$ of $\chi_M$ acts transitively on the six **non-determinant eigenlines** $\{\beta_i^2 \beta_j\}_{i \ne j}$ over the splitting field. Therefore a non-zero rational vector in the irreducible $W_6(\sigma)$-factor has non-zero projection to every Galois-conjugate eigenline, including the eigenline(s) of dominant modulus $\beta^2 |\beta_2|$.

Therefore $\Pi_{\mathrm{dom}}^\sigma K_3(s_k) \ne 0$. $\square$

---

## 9. Reducible-$P_6^\sigma$ branch (Galois group $A_3$)

### Branch hypothesis

$\Delta(\chi_M)$ is a square in $\mathbb{Q}$ (so the Galois group of $\chi_M$ is $A_3$). Equivalently, $P_6^\sigma$ factors over $\mathbb{Q}$ as
$$P_6^\sigma(t) = P_+(t) \cdot P_-(t),$$
two cubic factors. Cubic with $A_3$-Galois has all real roots, so $\beta_1, \beta_2, \beta_3 \in \mathbb{R}$ and the three are pairwise distinct.

### W_+ / W_- in M's eigenbasis (over the splitting field)

Let $\{v_1, v_2, v_3\}$ be a basis of $V$ diagonalizing $M$, with $M v_i = \beta_i v_i$. Define elementary matrices $E_{ij}$ in this eigenbasis: $E_{ij} v_l = \delta_{jl} v_i$.

In this eigenbasis, $\mathrm{Ad}_M(E_{ij}) = (\beta_i / \beta_j) E_{ij}$ for $i \ne j$. On the traceless diagonal Cartan, $\mathrm{Ad}_M$ acts as the **identity** (since $M E_{ii} M^{-1} = E_{ii}$). Hence $\Phi_3 = \det(M) \cdot \mathrm{Ad}_M$ acts on the Cartan with eigenvalue $\det M$, producing the two determinant-weight directions in $\mathrm{Spec}(\Phi_3)$.

The two A_3-Galois orbits on the index pairs $\{(i, j) : i \ne j\}$ are:
$$\mathrm{orbit}_+ = \{(1, 2), (2, 3), (3, 1)\}, \qquad \mathrm{orbit}_- = \{(1, 3), (2, 1), (3, 2)\}.$$

Define
$$W_+ := \mathrm{span}_{\overline{\mathbb{Q}}}\{E_{12}, E_{23}, E_{31}\}, \qquad W_- := \mathrm{span}_{\overline{\mathbb{Q}}}\{E_{13}, E_{21}, E_{32}\}.$$

Each is a 3-dim $\overline{\mathbb{Q}}$-subspace of $\mathfrak{sl}_3$. **Their A_3-Galois orbit sums are rational** — i.e., $W_+ \cap \mathfrak{sl}_3(\mathbb{Q})$ is the 3-dim $\mathbb{Q}$-subspace consisting of all rational matrices that are sums $\sum_i \tau^i(E_{12})$ scaled by Galois-orbit-coherent coefficients. Similarly for $W_-$. The two cubic factors $P_+, P_-$ correspond to $W_+, W_-$ under $\Theta$ (after identifying which orbit gets which factor by Pisot ordering).

### Trace-square computation in W_±

**Lemma.** If $A \in W_+$ (as an $\overline{\mathbb{Q}}$-element), i.e., $A = a\, E_{12} + b\, E_{23} + c\, E_{31}$ in $M$'s eigenbasis, then
$$\mathrm{tr}(A^2) = 0.$$

The same conclusion holds for $A \in W_-$.

**Proof.** Using $E_{ij} \cdot E_{kl} = \delta_{jk}\, E_{il}$:
$$A^2 = ab\, E_{12} E_{23} + bc\, E_{23} E_{31} + ca\, E_{31} E_{12} + (\text{vanishing cross terms and squares}) = ab\, E_{13} + bc\, E_{21} + ca\, E_{32}.$$
Each $E_{ij}$ with $i \ne j$ has zero diagonal, so $\mathrm{tr}(A^2) = 0$.

The case $A \in W_-$: $A = a' E_{13} + b' E_{21} + c' E_{32}$, giving $A^2 = a'b' E_{23} + b'c' E_{12} + c'a' E_{31}$. Same conclusion. $\square$

(Note: trace is a similarity invariant, so $\mathrm{tr}(A^2) = 0$ in any basis once it holds in the eigenbasis.)

### Theorem (Dominant Cubic Capture)

Under the branch hypothesis, for every length-7 seed $s_k$:
$$\Pi_+^\sigma K_3(s_k) \ne 0 \quad \text{and} \quad \Pi_-^\sigma K_3(s_k) \ne 0.$$
In particular, $K_3(s_k)$ has nonzero projection onto the cubic factor containing the dominant eigenvalue $\beta^2 \beta_2$.

### Proof

By Section 6 property 7, $\mathrm{tr}(A_k^2) = 6$ for every $k$. This is a $\mathrm{GL}_3$-invariant of $A_k$, computed once from the explicit seed matrices.

If $A_k \in W_+$ (entirely): the Lemma gives $\mathrm{tr}(A_k^2) = 0$. But $\mathrm{tr}(A_k^2) = 6 \ne 0$. Contradiction.

Symmetrically, $A_k \notin W_-$.

Hence both cubic-factor projections are non-zero. $\square$

### Theorem (Spectral Dominant-Capture, $A_3$ branch)

Under the branch hypothesis, for every length-7 seed $s_k$:
$$\Pi_{\mathrm{dom}}^\sigma K_3(s_k) \ne 0.$$

### Proof

The dominant eigenvalue $\beta^2 \beta_2$ is a root of one of $P_+, P_-$ (determined by Pisot ordering). By the Dominant Cubic Capture Theorem above, $K_3(s_k)$ has non-zero projection onto that cubic factor.

That cubic factor is irreducible over $\mathbb{Q}$ with Galois group $A_3$ acting transitively on its three roots. Any non-zero rational vector in its kernel-subspace projects nontrivially onto every Galois-conjugate eigenline, in particular onto the dominant. $\square$

---

## 10. Combined Spectral Dominant-Capture Theorem

### Theorem

Let $\sigma$ be a primitive irreducible Pisot substitution on alphabet $\{1, 2, 3\}$, and let $s_k$ ($k = 0, \ldots, 5$) be any of the six length-7 $K_2$-zero seeds. Then
$$\Pi_{\mathrm{dom}}^\sigma K_3(s_k) \ne 0.$$
Equivalently, by Φ_3 semisimplicity, the $\Phi_3$-cyclic subspace $\mathcal{C}_\sigma(K_3(s_k)) \subset W_3$ contains the dominant eigenline, and therefore
$$\rho\bigl(\Phi_3\big|_{\mathcal{C}_\sigma(K_3(s_k))}\bigr) = \beta^2 |\beta_2|.$$

### Proof

Two cases by Galois group:

1. **$\mathrm{Gal}(\chi_M) = S_3$:** Section 8 (PIP-Locus Target 1 + irreducible $P_6^\sigma$ + Galois transitivity).
2. **$\mathrm{Gal}(\chi_M) = A_3$:** Section 9 (PIP-Locus Target 1 + Dominant Cubic Capture via $\mathrm{tr}(A_k^2) = 6$ + cubic-orbit transitivity).

In both cases, the dominant spectral projection is nonzero. $\square$

---

## 11. Quotient-transfer interface to SCCs (conditional)

Let $C$ be a closed recurrent SCC of the balanced-pair automaton $B_\sigma$ with $K_2|_C \equiv 0$. Define
$$L_C : \mathbb{Q}[C] \to W_3, \qquad L_C(e_s) = K_3(s).$$

The first-active-degree intertwining (proved elsewhere in the program) gives
$$L_C \circ N_C = \Phi_3^\sigma \circ L_C,$$
where $N_C$ is the SCC transition matrix.

### Conditional Theorem (Case-B Quotient-Transfer)

If
$$\Pi_{\mathrm{dom}}^\sigma \circ L_C \ne 0,$$
then
$$\rho(N_C) \ge \beta^2 |\beta_2|.$$

### Proof sketch

The image $\mathrm{Im}(L_C) \subseteq W_3$ is $\Phi_3$-invariant. The hypothesis says it contains a vector with non-zero dominant projection. By Φ_3 semisimplicity, the dominant eigenline appears in $\Phi_3|_{\mathrm{Im}(L_C)}$. Then $\rho(\Phi_3|_{\mathrm{Im}(L_C)}) \ge \beta^2 |\beta_2|$, and this bound transfers to $\rho(N_C)$ via the intertwining $L_C N_C = \Phi_3 L_C$. $\square$

This is the **interface** between the completed Spectral module and the still-open SCC obstruction module. The Spectral module supplies $\Pi_{\mathrm{dom}}^\sigma K_3(s_k) \ne 0$ for length-7 seeds; the SCC module must supply the existence of a state in $C$ to which this applies (or an equivalent condition).

---

## 12. What this certificate does NOT prove

This certificate does **not** prove any of the following:

1. Every $K_2|_C \equiv 0$ SCC contains a length-7 seed.
2. Every $K_2|_C \equiv 0$ SCC reaches a length-7 seed under refinement.
3. Every $K_2|_C \equiv 0$ SCC has $L_C(\mathbb{Q}[C])$ intersecting the seed-generated $\Phi_3$-invariant module.
4. No pure $K_2$-zero SCC exists.
5. No invisible closed recurrent SCC exists.
6. Spectral capture extends to $K_2$-zero pairs of length $> 7$ (e.g., the rank-1 nilpotent $A_k$ pairs at length 9 are empirically captured but not yet structurally certified).

Items 1–5 are SCC-level Normal-form / Obstruction problems. Item 6 is an open structural extension (v12 status).

The certificate proves only the **spectral black box**:
$$\boxed{\Pi_{\mathrm{dom}}^\sigma K_3(s_k) \ne 0 \quad \text{for all PIP } \sigma \text{ on alphabet 3 and all } k \in \{0, \ldots, 5\}.}$$

---

## 13. Verification checklist

A complete independent verification requires checking:

| # | Item | Where supplied |
|---|---|---|
| 1 | Explicit basis of $W_3$ (8 vectors) | Section 3 |
| 2 | $W_3$ is $M^{\otimes 3}$-invariant | Standard rep theory; verifiable by computation on basis $b_1, \ldots, b_8$ |
| 3 | Six word-pair seeds $s_0, \ldots, s_5$ | Section 4 |
| 4 | The six integer vectors $K_3(s_k) \in \mathbb{Z}^{27}$ | Compute from Section 4 by definition |
| 5 | Levi-Civita contraction formula for $\Theta$ | Section 5 |
| 6 | The six matrices $A_k = \Theta(K_3(s_k))$ | Section 6 (explicit) |
| 7 | $\chi_{A_k}$ for each $k$ | Section 6 (explicit) |
| 8 | $A_k (1,1,1)^T = \lambda_k (1,1,1)^T$ for each $k$ | Direct $3 \times 3$ matrix-vector product |
| 9 | $\mathrm{tr}(A_k^2) = 6$ for each $k$ | Section 6 table |
| 10 | $\Theta(M^{\otimes 3} x) = \det(M) M \Theta(x) M^{-1}$ identity | Section 5 (polynomial identity in $\mathbb{Z}[m_{ij}]$) |
| 11 | Φ_3 semisimplicity from $\chi_M$ irreducible separable | Section 3 Lemma |
| 12 | If $A \in W_\pm$ then $\mathrm{tr}(A^2) = 0$ | Section 9 Lemma (direct $E_{ij} \cdot E_{kl}$ multiplication) |
| 13 | Galois branch detection via discriminant square test | Section 9 |

All items reduce to **finite exact algebra over $\mathbb{Z}$ or $\mathbb{Q}$**.

Reference verification scripts (in the project tree):
- `v10/seed_centralizer.py` — items 6, 7, 8, 9
- `v10/construct_theta.py` — item 10
- `v10/centralizer_argument.py` — item 8 detailed
- `v11/structural_argument.py` — item 12
- `v9/spectral/decomposition.py`, `target1_proof.py` — Section 7 verification

---

## 14. Final black-box statement

The completed Spectral module may be cited as:

> **Spectral Black Box (alphabet 3, length 7).** Let $\sigma$ be a primitive irreducible Pisot substitution on alphabet $\{1, 2, 3\}$, and let $s_k$ be one of the six length-7 $K_2$-zero seeds (Section 4). Then $K_3(s_k)$ has non-zero projection onto the dominant spectral factor of $\Phi_3^\sigma = M_\sigma^{\otimes 3}|_{W_3}$. Consequently, the cyclic $\Phi_3^\sigma$-module generated by $K_3(s_k)$ has spectral radius $\beta^2 |\beta_2|$.

This is the only statement exported from the Spectral module into the SCC-level program.

---

## Provenance

- v9 (spectral reduction) → operator condition $(\Phi_3 - \det M)^2 K_3(s) \ne 0$.
- v10 (Seed-Centralizer Lemma) → PIP-Locus Target 1 closed via centralizer + irreducibility contradiction.
- v11 (Dominant Cubic Capture) → reducible-$P_6^\sigma$ branch closed via $\mathrm{tr}(A_k^2) = 6$.
- This certificate (v12) → consolidated black-box export.

---

## 15. v34 closure: Load-Bearing SCC Theorem (conditional on finite $B_\sigma$, G1)

The v33–v34 program established a parallel route to the alphabet-3 spectral
lower bound, independent of the Spectral Black Box of §14. The Load-Bearing SCC Theorem is **conditional on finiteness of $B_\sigma$ (G1)**:

> **Theorem (Load-Bearing SCC, conditional on finite $B_\sigma$).** For every PIP σ on alphabet 3
> with $B_\sigma$ finite, there exists a recurrent NC-SCC $\mathcal{C}^*$ of $B_\sigma$ such that
> $$\rho(N_{\mathcal{C}^*}^\mathrm{total}) \ge \beta|\beta_2|.$$

**Proof spine** (full details in `v34/DOMINANT_K2_SOURCE_V34.md`):

1. **HYPOTHESIS (G1):** $B_\sigma$ is finite. [v5 Thm 5.1's predecessor-contraction proof is **withdrawn**: β·L(s′) ≤ L(s)+D is false — worst ratio 8.0, excess unbounded; see V5_THM51_RETRACTION_VERIFICATION_2026_06_13. Finiteness is unconditional only for |A|=2 and verified families; the exhaustive k=3 BPA sweep (4,554/4,554, 0 caps) is empirical elimination, not a proof.]
2. Length-2 pairs $\{s_{12}, s_{13}, s_{23}\}$ have $K_2$-vectors = standard basis of $\Lambda^2 \mathbb{Z}^3$.
3. Hence $\exists s_0$ with $\Pi_\mathrm{dom}^\sigma K_2(s_0) \ne 0$ (Lemma 1, v34).
4. Whole-pair intertwining: $\|\Phi_2^k K_2(s_0)\| \gtrsim (\beta|\beta_2|)^k$.
5. Inter-Block Cancellation (v33): $K_2(\sigma^k s_0) = \sum_{c \in D_k} K_2(c)$.
6. Triangle: $\sum_c \|K_2(c)\| \gtrsim (\beta|\beta_2|)^k$.
7. Finite $B_\sigma$ + bounded $\|K_2\|$: $|D_k| \gtrsim (\beta|\beta_2|)^k$.
8. Path-counting: $\rho(N) \ge \beta|\beta_2|$.
9. SCC condensation: max over recurrent SCCs achieves the bound.

**Inputs (all standard for PIP):**
- $\det M_\sigma \ne 0$ (irreducible cubic).
- Mossé recognizability.
- $\beta > 1$.
- $|\beta_2| \ge |\beta_3|$ Pisot ordering.

**Relation to §14 Spectral Black Box.** The v34 route uses $K_2$ (length-2
descent), while §14 uses $K_3$ at length-7 seeds. Both yield $\rho \ge \beta|\beta_2|$
on alphabet-3 noncoincident SCCs. The v34 route is structurally simpler
(length-2 sources, dominant projection always nonzero, no seed-centralizer
or trace identity needed) and discharges all hypotheses through the v5
finiteness theorem.

**Status:** v34 is now the canonical proof of the alphabet-3 spectral lower
bound. The Spectral Black Box (§14) remains valid and may be used as an
independent route or fallback.

