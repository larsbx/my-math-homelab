# Dossier: three Langlands entry points, executed

Status vocabulary: **COMPUTED** = both sides produced by exact arithmetic in this
repo and compared; **IMPORTED** = a theorem quoted to interpret a match, not
verified here.  Every COMPUTED line is a pytest assertion.

## Branch 2 — Brandt matrices, trace formulas, Jacquet–Langlands, Ramanujan

### 2.1 Supersingular locus (COMPUTED)
Roots of the Hasse polynomial H_p(λ) = Σ C(m,i)² λ^i in 𝔽_{p²}, pushed to j.
Counts agree with ⌊p/12⌋ + {0,1,1,2}[p mod 12] and with Eichler's mass formula
tr B(1) = (p−1)/12 + ¼(1−(−4/p)) + ⅓(1−(−3/p)) for all p ∈ [11, 73].

### 2.2 Brandt matrices (COMPUTED)
B(ℓ)_{ij} = multiplicity of j_j as a root of Φ_ℓ(j_i, Y) in 𝔽_{p²}[Y].  Checked:
row sums ℓ+1; B(2)B(3) = B(3)B(2); B(ℓ)·diag|Aut E_j| symmetric (dual isogeny).

Example, p = 11 (j = 0, 1728, |Aut| = 6, 4):
```
B(2) = [[0, 3], [2, 1]]      B(3) = [[1, 3], [2, 2]]
```

### 2.2b Brandt matrices by Vélu (COMPUTED; `velu.py`)
For odd ℓ ≠ p: twist each supersingular j to the model over 𝔽_{p²} with
#E = (p ∓ 1)², so Frobenius is the scalar ±p and every ℓ-subgroup is rational;
factor the division polynomial f_ℓ over 𝔽_{p²} into its degree-k Frobenius-orbit
factors (k = ord of ±p mod ℓ up to sign), lift each to 𝔽_{p^{2k}}, group the
x-coordinates into the ℓ+1 subgroups by x-only multiplication, and apply Vélu.
B(3) by Vélu equals B(3) by Φ₃ for all p ≤ 31; B(5), B(7) commute with B(2), B(3).

### 2.3 Eichler's trace formula (COMPUTED, both sides)
Spectral side: tr B(n) for n ∈ {1,2,3,4,6,8,9,12} and, with Vélu, n ∈
{5,7,10,14,15,21,25,35,49}, from adjacency and the Hecke relations
B(ℓ²) = B(ℓ)² − ℓ, B(mn) = B(m)B(n).
Geometric side, class numbers only:

    tr B(n) = [n = □]·(p−1)/12 + Σ_{s² < 4n} Σ_{f: p∤f} h(d)/w(d) · (1 − (d/p)),  d = (s²−4n)/f².

Equal for every p ∈ {11,…,53} and every n above.  Derivation used (IMPORTED for
the *derivation*, but the equality itself is COMPUTED): Deuring's correspondence
between optimal embeddings O_d ↪ End(E_i) and CM lifts; the local condition at
p kills orders with p | f.

Sample traces (p: n → tr):

| p | 1 | 2 | 3 | 4 | 6 | 8 | 9 | 12 |
|---|---|---|---|---|---|---|---|---|
| 11 | 2 | 1 | 3 | 9 | 14 | 15 | 11 | 26 |
| 37 | 3 | 1 | 2 | 7 | 18 | 15 | 17 | 20 |
| 53 | 5 | 1 | 4 | 7 | 12 | 15 | 21 | 26 |

### 2.4 Eichler–Selberg at level 1 (COMPUTED, both sides)
Zagier's form, tr T_n | S_k = −½ Σ_{t²≤4n} P_k(t,n) H(4n−t²) − ½ Σ_{dd'=n} min(d,d')^{k−1},
reproduces τ(n) for n ≤ 30 (τ from Δ = q∏(1−qⁿ)²⁴, independently), dim S_k for
k ≤ 36, and a₂ = 216, −528, 456 for k = 16, 18, 20, tr T₂ = 1080 for k = 24.

### 2.4b Eichler–Selberg at level N (COMPUTED, both sides)
`eichler_selberg(N, k, n)` for Γ₀(N), trivial character, gcd(n, N) = 1 (Cohen–Zagier /
Schoof–van der Vlugt form): A₁ = [n = □] n^{k/2−1}(k−1)ψ(N)/12, the elliptic term with
weighted class numbers and the local factor μ(t,f,n) = ψ(N)/ψ(N/N_f)·#{x mod N :
x² − tx + n ≡ 0 (mod N N_f)}, the hyperbolic term with φ(gcd(c, N/c)), and A₄ = Σ_{t|n,
gcd(N,n/t)=1} t at weight 2.  Checked for every N ≤ 40 and n ≤ 12 prime to N against
½·tr T_n on cuspidal modular symbols (weight 2), against Zagier's level-1 form, and at
prime level against Eichler's Brandt formula minus the Eisenstein eigenvalue σ(n): three
routes to the same numbers.  The reading of μ's x-sum ("x mod N, condition mod N·N_f")
was fixed by these tests; it is well defined because the congruence forces N_f | 2x − t.
At higher weight (`ManinSymbolsK`: Manin symbols with polynomial coefficients, Hecke via
the same Heilbronn matrices, cuspidal part = kernel of the weight-k boundary map, whose
convention was fixed by requiring dimension 2·dim S_k and Hecke stability at squarefree
and non-squarefree levels alike): for N ≤ 12 with k ∈ {4,6,8,12}, plus (16,4), (18,6),
(25,4), (27,4), and n ≤ 7 prime to N, the formula equals ½·tr T_n on cuspidal weight-k
symbols; at level 1 the weight-12 operator traces are τ(n), and S₂₄ gives tr T₂ = 1080 as
an operator.  A tempting shortcut — cuspidal = complement of the eigenvalue σ_{k−1}(ℓ) —
is wrong at non-squarefree N (level 9 has Eisenstein series with T₂-eigenvalue −2049 from
the character pair (χ, χ̄) mod 3); the boundary map is the right object.
KERNEL (`eichler_selberg_level_N`): Lean recomputes the level-N geometric side and certifies
it against exported spectral traces on a smaller grid than the Python tests: weight 2 for
N ≤ 20 with n ≤ 7, weights 4 and 6 for N ≤ 6 with n ≤ 5, and level 1 at weight 12 with
n ≤ 6 (always n prime to N).

### 2.5 Jacquet–Langlands as an integer oracle (COMPUTED; modularity IMPORTED)
For each rational newform of prime level p ≤ 101 (Cremona model, discriminant
checked to be ±p^k), a₂, a₃ are point counts over 𝔽₂, 𝔽₃.  A common eigenvector
of B(2), B(3) with exactly these eigenvalues exists and the joint eigenspace has
dimension = number of such forms (multiplicity one).  For levels ≤ 37 the joint
eigenvector of B(2), B(3), B(5), B(7) with eigenvalues a₂, a₃, a₅, a₇ exists too.
Hecke polynomials:

| p | H₂(x) |
|---|---|
| 23 | x² + x − 1 |
| 29 | x² + 2x − 1 |
| 31 | x² − x − 1 |
| 37 | x(x + 2)  ← 37a (a₂ = −2), 37b (a₂ = 0) |
| 43 | (x + 2)(x² − 2) |
| 47 | x⁴ − x³ − 5x² + 5x − 1 |

For p ∈ {11, 17, 19, 37} (all forms rational) the class-number side gives
tr B(ℓ) − (ℓ+1) = Σ_E a_ℓ(E) for ℓ ≤ 31 — Eichler's formula against point counts at
primes where no Φ_ℓ is available.

### 2.5b Modular symbols: an independent automorphic oracle (COMPUTED)
`modular_symbols.py`: Manin symbols (c : d) ∈ ℙ¹(ℤ/N) with the S- and T-relations,
H₁(X₀(N), cusps; ℚ) as an exact quotient, the boundary map through Cremona's cusp
equivalence criterion, and Hecke operators through Merel's Heilbronn matrices.  For every
N ≤ 60: dim = 2g + c − 1 and the cuspidal part has dimension 2g (genus and cusp formulas
IMPORTED as the reference).  For prime p ≤ 53 and ℓ ∈ {2,3,5,7}: the characteristic
polynomial of T_ℓ on cuspidal modular symbols equals the square of the Brandt Hecke
polynomial — Jacquet–Langlands checked between two independent automorphic
computations, with no elliptic curve involved.  At the composite genus-one levels
14, 15, 20, 27, 32, 36 the point counts of the curves used in the Tate tests are the
T_p-eigenvalues for p ≤ 13 (modularity at composite level).

### 2.6 Ramanujan–Petersson (COMPUTED; Deligne IMPORTED as the reason)
For p ≤ 71 and ℓ ∈ {2,3}, and p ≤ 37 and ℓ ∈ {5,7}: the Hecke polynomial is real-rooted and no root has
λ² > 4ℓ (Sturm counts on H and on the resultant G(y) = ∏(y − λᵢ²)).  So each
graph is Ramanujan.  The Apollonian λ₂ measurements are *not* this theorem:
there the spectral gap for congruence quotients comes from Selberg's 3/16 and
Kim–Sarnak θ₇ = 7/64 bounds on Maass forms, which are weaker than RP for
holomorphic weight-2 forms (Deligne = Weil for the Jacobian).  RP is the
statement that Frobenius traces are as small as the Weil bound allows, so a
"floor via Frobenius trace" cannot hide below 2√ℓ.

## Branch 1 — GL₁ geometric CFT on E = 37a1 (y² = x³ − 1296x + 11664) mod p

a_p(37a1) by point count: p ↦ −2, −1, −5, −2, 0, 0, 2 for p = 5, 7, 11, 13, 17, 19, 23.
E(𝔽₅) ≅ ℤ/8, E(𝔽₇) ≅ ℤ/9 (cyclic in both cases).

### 1.1 Galois side: the Lang isogeny (COMPUTED)
L(P) = Frob(P) − P.  Among E(𝔽_{pⁿ}), the fiber over x ∈ E(𝔽_p) is nonempty iff
n·x = O, has exactly #E(𝔽_p) points, and Frob acts on it as translation by x
(n = 2, 3, 4).  On the χ-isotypic line of ℚ̄_ℓ[fiber], Frob acts by χ(x): checked
for all 8 (resp. 9) characters and all fibers.  This is tr(Frob_x | L_χ) = χ(x).

### 1.2 Character sheaf traces (COMPUTED)
tr(Frob_{pᵏ} | A_χ) on Pic⁰(𝔽_{pᵏ}) = E(𝔽_{pᵏ}) is χ∘N (N = Frobenius trace to
E(𝔽_p)); it is a character of E(𝔽_{pᵏ}) for k = 2, 3, and restricts to χᵏ on E(𝔽_p).

### 1.3 Descent along Abel–Jacobi (COMPUTED)
For every line y = λx + μ and x = c over 𝔽_p, the zeros (found in 𝔽_{p⁶},
including tangencies, e.g. x − 2 is tangent at the 2-torsion point (2,0) over 𝔽₅)
sum to O in E: χ(div f) = 1, so χ is a character of Pic, i.e. A_χ is multiplicative.

### 1.4 Weil reciprocity with the Deligne sign (COMPUTED)
Tame symbols (f,g)_P = (−1)^{v(f)v(g)} (f^{v(g)}/g^{v(f)})(P) from Laurent
expansions in a uniformizer at every P (u = x − x_P, u = y at 2-torsion,
t = −x/y at O).  For two non-vertical lines, (f,g)_O = (−1)⁹ = −1 and the product
over finite points is −1, total 1.  This sign is the (−1)^{ord·ord} of the
rigidified biextension law.

### 1.5 The L-function (COMPUTED; cohomological prediction IMPORTED)
L(χ, T) = ∏_x (1 − χ(Nx) T^{deg x})⁻¹ in ℤ[ℤ/N][[T]] over closed points to
degree 4 (p = 5: 8, 12, 32, 152 closed points of degree 1..4) and 3 (p = 7).
- χ ≠ 1: every coefficient of T^n, n ≥ 1, is 0 in ℤ[ζ_N] — but not termwise —
  matching dim H¹(Ē, L_χ) = 2g − 2 = 0.
- χ = 1: coefficients 1, 8, 48, 248, 1248 (p = 5) = those of
  Z(E,T) = (1 + 2T + 5T²)/((1−T)(1−5T)); the a_p = −2 here is the Frobenius trace on
  H¹, and it is the same 37a1 eigenvalue Brandt sees at level 37.
The degree twist χ·α^{deg} gives L(χ, αT); nothing new.

### 1.6 Ramified: modulus 𝔪 = 2P₀ and the generalized Jacobian (COMPUTED; Rosenlicht–Serre and Weil IMPORTED as predictions)
`ramified_cft.py`: Cl⁰_𝔪 = J_𝔪(𝔽_p), the extension 0 → 𝔽_p → J_𝔪 → E → 0, realised as pairs
(S, a): S the sum of the divisor in E(𝔽_p), a the u-coefficient at P₀ of the function
realising D − R(S) (Miller-style accumulation of line functions for any principal divisor,
Laurent expansion at P₀, normalised).  The group law comes from its 2-cocycle, checked
symmetric and associative; the inertia subgroup {(O, a)} is 𝔽_p with the additive law.
Its invariant factors come from a recursive decomposition (`abelian.py`: an element of
maximal order, the quotient decomposed recursively, generators lifted and corrected), which
handles non-cyclic cases such as y² = x³ + 8 over 𝔽₁₃ with E(𝔽₁₃) ≅ ℤ/4 × ℤ/4, where a
greedy search for direct complements fails (review finding on PR #6).
Cl⁰_𝔪 ≅ ℤ/40 for 37a1 mod 5 and has order 63 mod 7.  Characters through a basis; then
L_𝔪(χ, T) = ∏_{x ≠ P₀}(1 − χ(x)T^{deg x})⁻¹ in ℤ[ℤ/N][[T]] to order 4 (mod 5) and 3 (mod 7):
- the 32 (resp. 54) ramified characters (nontrivial on inertia, conductor exactly 𝔪, wild):
  L is a polynomial of degree 2g − 2 + deg 𝔪 = 2, with |c₂|² = q² and every conjugate of
  |c₁|² at most 4q (the Riemann hypothesis, by an exact Sturm count on the conjugates
  polynomial);
- unramified nontrivial χ: L_𝔪 = 1 − χ(P₀)T, the P₀ factor removed from L = 1 (§1.5);
- trivial χ: Z(E, T)(1 − T).
This is the Artin–Schreier layer of geometric class field theory for GL₁ on E, executed.

### 1.7 The Poincaré biextension over ℚ: Law B stratum-uniformly and the strict second law (COMPUTED + PROVED; `biextension.py`, `BiextensionSign.lean`)
Continues the H10/ℚ biextension thread ("Novel Contributions" ledger; Dossiers I, II), whose next increment
fixed its acceptance test in advance.  E = 37a1 in the minimal model y² + y = x³ − x, P₀ = (0, 0), exact ℚ
arithmetic; uniformiser t = x/y at O, so chords (ord −3), verticals (ord −2) and Miller functions
g_{A,B} = chord/vertical (ord −1) are tame-monic and regularise to 1 at O (C6).  Factor systems in the
frame s: β₁ = κ(c; a₁, a₂) = g_{a₁,a₂}(c), naive β₂ = κ'_a(c₁, c₂) = g_{c₁,c₂}(a).
- Rebuilt independently of the original harness: T1 (nP₀, hand values to 5P₀ = (1/4, −5/8)), T3
  (rigidification), T4 and T6 (both laws symmetric 2-cocycles, exact equality).
- T8/T8v (Law B): for every (a₁, a₂, c₁, c₂) ∈ {nP₀ : |n| ≤ 4}⁴ off the supports, the naive exchange ratio
  equals (−1)^{ord_O g_{a₁,a₂} · ord_O g_{c₁,c₂}} — −1 on chord/chord, +1 on all eight other strata, all nine
  populated (a support hit is skipped and never counted).
- Stratum-uniform proof (PROVED for any commutative group, `ordO_odd_iff`, `deligne_uniform`,
  `generic_eq_du`): ord_O g_{a,b} ∈ {0, −2, −1} is odd exactly on the generic stratum, whose indicator is
  the coboundary δu of u(a) = [a ≠ O] mod 2; so the Deligne sign is (−1)^{δu(a)·δu(c)} on every stratum at once.
- The strict second law: β₂ = (−1)^{u(a)·δu(c₁,c₂)} · g_{c₁,c₂}(a).  PROVED: it cancels the sign
  (`exchange_strict`), the twist is a symmetric rigidified 2-cocycle (`twist_cocycle`, `twist_symm`,
  `twist_rigid_left`, `twist_rigid_base`), and no frame change could have done it, the exchange ratio
  being frame-invariant (`no_frame_fix`).  COMPUTED: the acceptance test — exchange ratio +1 on every
  sample of every stratum.
IMPORTED: tame Weil reciprocity (Deligne, *Le symbole modéré*), which produces the sign; measured, not proved.

### 1.8 Over 𝔽_q: the Weil pairing is the commutator of the strict biextension, and E^∨ parametrises the characters of Pic⁰ (COMPUTED + PROVED)
The same factor systems over 𝔽_{p^k} (`FF`, `over`; 37a1 minimal model, transported to the lab's short
model by (x, y) ↦ (36x, 108(2y + 1))):
- **Commutator = Weil pairing.** For P, Q ∈ E[m] independent, Π_{i<m} β₁(Q; iP, P) / Π_{i<m} β₂(P; iQ, Q)
  — the m-fold first law against the m-fold strict second law along the Miller chain — equals e_m(P, Q) as
  computed independently by `galois_rep.weil_pairing` (divisor-based Miller, short model), on every
  independent pair, p ∈ {5, 7, 11, 13}, ℓ ∈ {2, 3}; the naive swap gives (−1)^ℓ e_ℓ.  PROVED
  (`chain_order`): for Q of exact order m ≥ 2 the twists along the chain multiply to (−1)^m when P ≠ O
  (m − 2 generic steps), which is the classical (−1)^m of e_m = (−1)^m f_{m,P}(Q)/f_{m,Q}(P) for normalised
  Miller functions: Law B, summed.  The strict presentation carries it with no extra convention.
- **Duality (geometric CFT at level ℓ).** For c ∈ E(𝔽_p)[ℓ] and x ∈ E(𝔽_p), χ_c(x) = e_ℓ(Frob y − y, c)
  with ℓy = x is the Frobenius eigenvalue at x of the [ℓ]-cover local system with character e_ℓ(·, c).
  At (p, ℓ) = (5, 2) over 𝔽₆₂₅ and (7, 3) over 𝔽₃₄₃: independent of y, a character of Pic⁰(𝔽_p) = E(𝔽_p),
  multiplicative in c, and c ↦ χ_c is a bijection onto the characters of order dividing ℓ — exactly the
  ones in `gl1.all_characters` (short model) with ℓχ = 0.  So E^∨(𝔽_p)[ℓ] ≅ Hom(E(𝔽_p), μ_ℓ): the dual
  curve parametrises the unramified GL₁ automorphic forms of order ℓ, through the biextension.
- **Sheaf level beyond rational points.** p = 7, ℓ = 3, over 𝔽_{7⁶}: at all 54 closed points of degree 2 and
  all three c, Frob² acts on the [3]-cover local system by χ_c(x + Frob x) — the trace function of the Lang
  local system L_{χ_c} of §1.1.  The two covers ([3] and Lang) give the same rank-1 local system at every
  closed point of degree ≤ 2; that they are isomorphic (Chebotarev) is IMPORTED.
IMPORTED: Weil reciprocity (the sign's origin) and the identification of Frobenius on the fibre of a
torsor with the translation Frob y − y (the sheaf–function dictionary, as in §1.1).

### 1.9 κ_tame on 37a1 is an elliptic-net quotient (COMPUTED; σ-derivation IMPORTED)
Dossier II §8, open item 2: "whether the elliptic-net structure visible in the appendix data yields a closed
form for κ_tame on 37a1 — tabulated, not conjectured".  The candidate came from the σ-factorisation
g_{u,v}(z) = σ(z−u)σ(z−v)σ(u+v)/(σ(z−u−v)σ(z)σ(u)σ(v)) and W_j = σ(ju)/σ(u)^{j²} (the σ(u)-exponents cancel
identically), with the sign left free; the oracle fixed it, then every sample was checked exactly:
- Ward EDS of (37a1, P₀) from ψ₂, ψ₃, ψ₄ at P₀ and the duplication recurrences: 0, 1, 1, −1, 1, 2, −1, −3,
  −5, 7, −4, −23, 29 (W₁₂² = 841, the appendix numerator); den x(nP₀) = W_n², den y(nP₀) = |W_n|³ (T2).
- Generic stratum: κ_tame(kP₀; mP₀, nP₀) = −W_{k−m} W_{k−n} W_{m+n} / (W_{k−m−n} W_k W_m W_n);
  vertical stratum: x(kP₀) − x(mP₀) = −W_{k+m} W_{k−m} / (W_k² W_m²) — on every (k, m, n) ∈ [−8, 8]³ off the
  supports.  The sign −1 is (t/z)^{ord_O} with t = x/y ~ −z: the monic-in-t frame of C6 against the
  σ-normalised one; it is +1 on the vertical stratum (ord −2) — the parity of §1.7 again.
- The Miller chain telescopes: f_{N,P₀}(kP₀) = Π_{i<N} g_{iP₀,P₀}(kP₀) = (−1)^{N−1} W_N W_{k−1}^N / (W_{k−N} W_k^{N−1})
  (N ≤ 8, k ≤ N + 11).
So on the rank-1 lattice ℤP₀ both partial laws are Laurent monomials in the EDS, and every value the harness
tabulates is a ratio of W's.  IMPORTED: the σ-function derivation (a proof over ℚ̄ via the elliptic net
axioms of Ward/Stange is the algebraic route, not done).

## Lean 4 in the oracle loop (`proof/langlands/`, core Lean 4.34, no Mathlib)

Status vocabulary extension: **KERNEL** = the statement is a `theorem` closed by
`decide` or `decide +kernel`; the Lean kernel evaluated both sides.  No
`native_decide`, no `sorry`, no axioms beyond Lean's core.

| certificate | statement | side recomputed in Lean |
|---|---|---|
| `class_numbers` | Gauss's table for 23 discriminants | reduced-form enumeration |
| `eichler_selberg_tau` | tr T_n | S₁₂ = τ(n), n ≤ 20, division by 24 exact | Hurwitz numbers, Zagier's formula, Δ's product |
| `eichler_selberg_dims` | dim S_k for k ≤ 26 | same |
| `fermat_carlitz_small` | C_P ≡ x^{|P|} (mod P), 8 cases | Carlitz p-polynomials over 𝔽_p[t] |
| `brandt_certificates` | for p ≤ 37 and ℓ ∈ {2,3,5,7}: row sums ℓ+1, commutation, B·diag(w) symmetric, 12·tr B(n) = Eichler's formula for n ∈ {1, ℓ, ℓ², ℓℓ'} | class numbers, Legendre symbols, Eichler's formula, Hecke relations (data: Python) |
| `lseries_certificates` | 37a1 mod 5, 7: every L(χ,T) coefficient vanishes mod Φ_N for χ ≠ 1 (not termwise); χ = 1 gives Z(E,T) | Φ_N by divisor recursion, polynomial remainder over ℤ, zeta recursion (data: Python) |
| `isogeny_graphs_recomputed` | for every exported locus p ∈ {11,…,37}: Lean's own supersingular j's (Hasse polynomial roots in 𝔽_{p²} = 𝔽_p[s]/(s²−c)) and Φ₂-, Φ₃-root multiplicities give the exported B(2), B(3) up to a simultaneous relabelling; the number of curves is tr B(1) | 𝔽_{p²} arithmetic, Deuring's criterion, Φ₂, Φ₃, synthetic division, permutations (nothing imported from Python but the matrices being certified) |
| `eichler_selberg_level_N` | 24·tr T_n \| S_k(Γ₀(N)) = 12·(trace on cuspidal Manin symbols) for weight 2, N ≤ 20, n ≤ 7; weights 4 and 6, N ≤ 6, n ≤ 5; level 1, weight 12, n ≤ 6 (n prime to N) | ψ(N), class numbers, local factors μ, φ(gcd(c, N/c)), Chebyshev P_k (data: modular-symbol traces from Python) |

The bridge is `tools/export_lean_data.py`; the gate `tests/test_lean_gate.py`
regenerates the data (must be byte-identical), runs `lake build`, and runs
`proof/langlands/Audit.lean` (`#print axioms`): every certificate depends on at most `propext`
and `Quot.sound` — no `sorryAx`, no `Lean.ofReduceBool`.

## Branch 3 — Carlitz module, seed of the function-field act

C_t(x) = tx + x^p over A = 𝔽_p[t].  COMPUTED for p ∈ {2,3,5}, deg P ≤ 3:
- Fermat–Carlitz: C_P(x) ≡ x^{p^{deg P}} (mod P) as p-polynomials.
- Reciprocity: for P ∤ M, in 𝔽_P = 𝔽_p(θ), θ a root of P, and the extension of
  degree ord_M(P) that splits C_M: every λ ∈ C[M] satisfies λ^{|P|} = C_P(λ).
- Decomposition: the 𝔽_P-degree of λ is the order of P in (A/ann λ)^× — P splits
  in K(C[M]) exactly as p splits in ℚ(ζ_m).
- C[M] ≅ A/M (|M| distinct roots, a generator exists).

## Branch 3, second act — Bruhat–Tits tree and Drinfeld's dictionary (`bruhat_tits.py`, `ec_function_field.py`)

### 3.1 The tree and Serre's half-line (COMPUTED)
𝒯 = tree of PGL₂(𝔽_q((1/t))) in the chart (k, u), u ∈ K_∞/π^k𝒪_∞: (q+1)-regular,
symmetric adjacency (random vertices, q ∈ {2,3,5}).  GL₂(𝔽_q[t]) acts through the
Iwasawa normal form.  The continued-fraction reduction returns γ ∈ GL₂(A) (polynomial
entries, unit determinant) with γ·v = v_n = [𝒪 ⊕ π^n𝒪]: Serre's quotient
GL₂(A)\𝒯 = v₀ — v₁ — v₂ — ⋯ is exhibited on every vertex tried, not quoted.
Stab(v_n) = {[[a,b],[0,d]] : deg b ≤ n} fixes v_n and identifies all q down-neighbours
of v_n with v_{n−1} (n ≥ 1); GL₂(𝔽_q) is transitive on the neighbours of v₀.
IMPORTED: that these are the *full* stabilisers (Aut(𝒪 ⊕ 𝒪(n)), Weil's dictionary).

### 3.2 Γ₀(𝔫)\𝒯 and cusp forms (COMPUTED; genus formula IMPORTED as the reference)
Γ₀(𝔫)\Γ = ℙ¹(A/𝔫) by the bottom row; quotient vertices over v_n are the
Stab(v_n)-orbits, quotient oriented edges are labelled by reducing the origin.  A
cochain is a function on positive-oriented quotient edges below a truncation depth;
harmonicity is imposed at every quotient vertex through the q+1 tree edges at a
representative.  The nullspace dimension equals Gekeler's genus and the first
Betti number of the quotient core, independently of the depth:

| q | 𝔫 | genus | cusps |
|---|---|---|---|
| 2 | t, t²+t+1 | 0 | 2 |
| 2 | t³+t+1, t³+t²+1 | 2 | 2 |
| 2 | t⁴+t+1 | 4 | 2 |
| 3 | t²+1 | 0 | 2 |
| 3 | t³+2t+1 | 3 | 2 |
| 5 | t³+t+1 | 5 | 2 |
| 2 | t³ | 1 | 4 |
| 2 | t⁴ | 3 | – |
| 3 | t³ | 2 | – |

### 3.3 Hecke operators (COMPUTED; Drinfeld's Ramanujan bound IMPORTED as the reason)
T_𝔭 from the q^{deg 𝔭}+1 representatives [[1,b],[0,𝔭]], [[𝔭,0],[0,1]]; T_𝔭 preserves the
cusp forms (asserted), the T_𝔭 commute, and every characteristic polynomial is
real-rooted with |λ| ≤ 2q^{deg 𝔭/2} (exact Sturm counts).
- 𝔫 = t³+t+1 over 𝔽₂: T_t: x²+2x−1, T_{t+1}: x²−2, T_{t²+t+1}: x²−2x−1 — irreducible,
  so no rational eigenform; the exhaustive search over a_i of degree ≤ i (2²¹ models)
  finds no elliptic curve of conductor 𝔫∞, consistently.
- 𝔫 = t³+2t+1 over 𝔽₃: T_t = T_{t+1} = T_{t+2} up to conjugacy (𝔫 is invariant under
  t ↦ t+c): x³+x²−4x+1, irreducible.
- 𝔫 = t³ over 𝔽₂: genus 1, eigenvalues a_{t+1} = −1, a_{t²+t+1} = 1, a_{t³+t+1} = 1,
  a_{t³+t²+1} = −3.
- 𝔫 = t⁴ over 𝔽₂: genus 3 = the t³ form twice + one newform with a_{t+1} = 1,
  a_{t²+t+1} = −1, a_{t³+t+1} = 1, a_{t³+t²+1} = 3.

### 3.4 Drinfeld's dictionary executed (COMPUTED; the theorem IMPORTED as the interpretation)
Galois side: elliptic curves over 𝔽₂(t) found by exhaustive search among models with
bad reduction only at t and ∞ and split multiplicative reduction at ∞ (tangent cone
of the node split over the residue field, computed):

| curve | a-invariants | a_𝔭 at t+1, t²+t+1, t³+t+1, t³+t²+1 | L(E,T) | level |
|---|---|---|---|---|
| E_{t³}: y² + txy = x³ + x | (t, 0, 0, 1, 0) | −1, 1, 1, −3 | 1 | t³ |
| E_{t⁴}: y² + txy + t²y = x³ + x + t³+t²+t | (t, 0, t², 1, t³+t²+t) | 1, −1, 1, 3 | 1 + 2T | t⁴ |

The traces are point counts over 𝔽_𝔭 = GF(2, 𝔭); they coincide with the Hecke
eigenvalues above at every 𝔭 ∤ t of degree ≤ 3, and the L-functions (Euler products
over all places of degree ≤ 5, ∞ included) are polynomials of degree deg N − 4
(Grothendieck), with the functional-equation coefficient ±q in the degree-1 case.

**Conductors by Tate's algorithm** (`tate.py`, COMPUTED; Ogg–Saito IMPORTED for f):
Tate's algorithm over an exact DVR in every residue characteristic, validated over
ℤ_(p) on ten Cremona curves (Kodaira types, conductor exponents, Tamagawa numbers,
split/nonsplit consistent with the root numbers of 11a1, 37a1, 37b1, 43a1).  At the
wild place t it gives type III, f = 3 for E_{t³} and type II, f = 4 for E_{t⁴} over 𝔽₂,
and type II, f = 3 for both 𝔽₃ curves; at ∞ split I₈, I₈, I₉, I₉.  So the conductors
are t³∞, t⁴∞, t³∞, t³∞: the Galois-side conductor equals the level found on the tree,
deg Δ_min = 12 in each case, and deg N − 4 = deg L.
KERNEL: `function_field_l_functions` recomputes both Euler products in Lean from the
exported local data.
Over 𝔽₃(t), level t³ has genus 2 with two rational eigensystems; the search (with
deg a₂ = 2, forced by c₄ = a₂² in characteristic 3) finds them:

| curve | a_𝔭 at t+1, t+2, t²+1, t²+t+2, t²+2t+2 | L(E,T) |
|---|---|---|
| y² = x³ + t²x² + tx + 1 | 1, −2, 1, 4, −2 | 1 |
| y² = x³ + t²x² + 2tx + 1 | −2, 1, 1, −2, 4 | 1 |

Each is a joint eigenvector of the five T_𝔭 on the cusp forms; the two are swapped
by t ↦ 2t, as are t+1 and t+2.
Over 𝔽₅(t): X₀(t³) has genus 4 and Hecke polynomials (x² − 2x − 4)(x² + 3x + 1) at every
degree-1 prime, no rational root — as it must be, since in characteristic ≥ 5 Tate's
algorithm gives conductor exponent exactly 2 at an additive place (tame), so no elliptic
curve over 𝔽₅(t) has conductor t³∞.

## Branch 3, third act — the excursion algebra in Lean (`proof/langlands/LanglandsOracles/Excursion*.lean`, `Pseudocharacter.lean`, `excursion.py`)

Status vocabulary: **PROVED** = a Lean theorem with a term-level proof (no `decide`);
**KERNEL** as before.

### 3.5 The excursion relations, abstractly (PROVED, core Lean, no Mathlib)
`Grp`, `Hom`, and `LRInvariant g f` (functions on Ĝ^I invariant under left and right
diagonal multiplication: 𝒪(Ĝ\Ĝ^I/Ĝ)).  `ExcursionData gΓ gĜ k` packages V. Lafforgue's
relations for a character of the excursion algebra with values in k:
- (E0) `map_unit`: Θ_I(f)(1,…,1) = f(1,…,1) for f ∈ 𝒪(Ĝ\Ĝ^I/Ĝ) (`map_const`: constants are fixed);
- (E1) `functorial`: Θ_J(f^ζ)(γ) = Θ_I(f)(γ∘ζ) for ζ: I → J;
- (E2) `map_mul`, `map_add`: f ↦ Θ_I(f)(γ) is a ring homomorphism;
- (E3) `compose`: Θ_I(f)(γ_iγ'_i) = Θ_{I⊔I⊔I}(f̃)(γ ⊔ γ' ⊔ 1), f̃(x⊔x'⊔x'') = f(x_i x''_i⁻¹ x'_i).

Theorems: `lrInvariant_pullback`, `lrInvariant_tilde` (the constructions stay in
𝒪(Ĝ\Ĝ^I/Ĝ)); `ExcursionData.ofHom ρ` — every homomorphism ρ: Γ → Ĝ gives excursion data
Θ_I(f)(γ) = f(ρ∘γ) satisfying (E1)–(E3) (the Galois-to-excursion direction);
`ofHom_const` — on constant tuples the value is f(1,…,1); `heckeFun`, `lrInvariant_heckeFun`,
and `hecke_eq_character`: the unramified Hecke operator is the excursion operator of
f_V(g₀,g₁) = χ_V(g₀g₁⁻¹) at (Frob_v, 1), with value χ_V(ρ(Frob_v)) on ρ-data;
`excursion_comm`.

**The converse for GL₁ (PROVED, `ExcursionGL1.lean`).**  For φ: Ĝ → k multiplicative into a
commutative monoid k (Ĝ = GL₁ = k^×, φ = id) and f_φ(x₀,x₁) = φ(x₀x₁⁻¹), *every* excursion datum
D satisfying (E0)–(E3) yields a character χ(γ) := Θ_{Bool}(f_φ)(γ,1):
`gl1_character`: χ(γγ') = χ(γ)χ(γ'), and `gl1_character_one`: χ(1) = 1.  The proof is the
abelian case of Lafforgue's argument: (E3) rewrites χ(γγ') as Θ(f̃)(γ,γ',1); f̃ factors
pointwise as (f_φ∘pr₁)(f_φ∘pr₂)(f_φ^{swap}∘pr₃) (`tilde_hecke_factors`, using only that φ is
multiplicative and k commutative); (E2) and (E1) split the product into
χ(γ)χ(γ')Θ(f_φ^{swap})(1,1), and (E0) evaluates the last factor to φ(1) = 1.  Axioms:
propext, Quot.sound.

**Excursion data ⇒ pseudocharacter, rank 2 (PROVED, `ExcursionGL2.lean`).**  For T: Ĝ → k a
class function (T(xy) = T(yx)) satisfying the 2×2 Procesi identity on Ĝ,
T(x)T(y)T(z) + T(xyz) + T(xzy) = T(xy)T(z) + T(xz)T(y) + T(yz)T(x), and f_T(x₀,x₁) = T(x₀x₁⁻¹),
every excursion datum D gives χ(γ) := Θ_{Bool}(f_T)(γ,1) satisfying the same identity on Γ
(`gl2_pseudocharacter`), with χ(1) = T(1) (`exChar_one`, by (E0)) and χ(γγ') = χ(γ'γ)
(`exChar_comm`): a 2-dimensional pseudocharacter in Taylor's sense.  Proof: on the index set
Idx = {o,a,b,c} with q = (1,γ₁,γ₂,γ₃), every function of the differences h_i = g_i g_o⁻¹ through
a conjugation-invariant Φ lies in 𝒪(Ĝ\Ĝ^Idx/Ĝ) (`lrInvariant_ofRel`); (E1) and one or two
(E3)s identify Θ_Idx of T(h_i), T(h_ih_j), T(h_ih_jh_l) at q with χ(γ_i), χ(γ_iγ_j), χ(γ_iγ_jγ_l)
(`theta_t1`–`theta_t3`); (E2) assembles the two sides of the identity into Θ_Idx(F_L)(q),
Θ_Idx(F_R)(q), and F_L = F_R pointwise by the identity on Ĝ at (h_a,h_b,h_c).
Over a commutative semiring (`ExcursionGL2Ring.lean`, `CommSemiring.lean`): `IsCSR R` packages
the commutative-semiring laws on the ambient `+`, `*` (instances ℕ, ℤ, and 𝔽_p = Fin p for every
p, via `Fin.val` and ℕ-modular arithmetic); `M2.procesi` PROVES the Procesi identity for 2×2
matrices over any such R, both sides distributing to the same multiset of 24 monomials (`ac_rfl`),
with `M2.mul_assoc`, `M2.trace_mul_comm` alongside.  GL₂(R) is the group of pairs (x, y) with
xy = yx = 1 (inverse as witness, no determinants), `grpGL2`.  `gl2_ring_pseudocharacter`: for
every commutative semiring R, every excursion datum for GL₂(R) with values in R is a
2-dimensional pseudocharacter Γ → R, with χ(1) = 1 + 1 and χ(γγ') = χ(γ'γ);
(Inverses in ℤ/p for p ∈ {2, 3, 5, 7} are decided, `fin3_inverses` etc., and `fin4_not_field`; the
field property for every `IsPrime p` needs Bézout and is not proved here.)
`gl2_Zmod_pseudocharacter` is the case Ĝ = GL₂(ℤ/n), k = ℤ/n for every n ≥ 1, and
`gl2_Fp_pseudocharacter`, gated by the decidable class `IsPrime p` (ℤ/4 is not 𝔽₄), the field case
Ĝ = GL₂(𝔽_p), k = 𝔽_p of the mod-ℓ parameters of Branch 1.
Axioms: propext, Quot.sound.

IMPORTED (not formalised): the remaining step for non-abelian Ĝ, pseudocharacter ⇒ semisimple
parameter (Taylor for GL₂, Lafforgue's Ĝ-pseudocharacters and geometric invariant theory in general),
and the excursion relations for GL_n, n ≥ 3, where the identity is Procesi's for n×n matrices.

### 3.6 GL₂-pseudocharacters (PROVED + KERNEL)
`procesi_GL2_F2`, `procesi_GL2_F3`: Σ_{σ∈S₃} sgn(σ) T_σ(g₁,g₂,g₃) = 0 for T = trace on every
triple of GL₂(𝔽₂) (6³) and GL₂(𝔽₃) (48³ = 110 592 triples), the
defining relation of a 2-dimensional pseudocharacter.  Python checks the same (`procesi_identity_holds`).
The identity is PROVED over every commutative semiring in `M2.procesi` (§3.5).
`procesi_GL2_F3` now derives its unchanged Boolean statement `Mat2.procesiHolds 3 = true` from
that theorem and `isCSR_fin 3`: a kernel check on 3⁶ scalar tuples converts the subtraction-free
identity to the signed form, and `List.all_eq_true` lifts it to the enumerated group without
evaluating matrix triples.  `procesi_GL2_F2` remains an independent kernel cross-check of the
signed form; the exhaustive Python checks over both groups also remain.  The audit still names
`procesi_GL2_F3`; its structural proof stays within propext / Quot.sound.
Matched serialized clean builds on one CI runner measured `Pseudocharacter` at 10.42 GiB before
and 0.53 GiB after (67.11 s → 0.74 s); the largest process of the candidate build is now
`BrandtCertificates` at 3.99 GiB.  [Protocol, exact measurements and audit comparison](benchmarks/procesi-memory-2026-10-06.md).

### 3.7 An arithmetic excursion instance: the mod-3 parameter of 37a1 (KERNEL + COMPUTED)
- `brandt_eigenvector_37a1`: the exported v = (−1, 1, 0) on the supersingular locus at p = 37
  satisfies B(ℓ)v = a_ℓ v for ℓ ∈ {2,3,5,7} with (a₂,a₃,a₅,a₇) = (−2,−3,−2,−1) (automorphic
  side: the JL form of 37a1); `brandt_eigenvalues_match_point_counts`: a₅, a₇ agree with
  Lean's own point counts on y² = x³ − 1296x + 11664; `ap_37a1_table` for all good p ≤ 61.
- `mod3_excursion_37a1`: for every good p ≤ 61, [ψ₃ has an 𝔽_p-root] ⇔ [x² − a_p x + p has a
  root ±1 mod 3].  Galois side: ρ̄₃(Frob_p) has an eigenvector in E[3] with eigenvalue ±1 iff
  some 3-torsion point has rational x-coordinate; automorphic side: the Hecke eigenvalue a_p.
  The class function "has eigenvalue ±1" is the excursion evaluation used.
- Python (`test_branch3_excursion.py`): the same equivalence for all 15 Cremona curves and
  all good p < 400, and the mod-2 version: the class of Frob_p in Gal(ℚ(E[2])/ℚ) ⊆ GL₂(𝔽₂) = S₃
  read from the factorisation of the 2-division cubic has trace a_p mod 2 — the mod-2
  Langlands correspondence for these curves, fully explicit.
- `ExcursionData.of_hom` on GL₂(𝔽₂) with (E1)–(E3) checked exhaustively for |I| = 2 on the
  Hecke functions: the finite shadow of the Lean structure.

### 3.8 The mod-ℓ parameter as a computed matrix; the Weil pairing as biextension commutator (COMPUTED + KERNEL)
`galois_rep.py`: E[ℓ] is found over its splitting field 𝔽_{p^k} (division-polynomial roots
and square roots by the generic root finder, no enumeration), a basis is chosen, and
Frob_p is written in it: ρ̄_ℓ(Frob_p) ∈ GL₂(𝔽_ℓ).  For all 15 Cremona curves, all good
p ≤ 31 and ℓ ∈ {2, 3}: tr ≡ a_p and det ≡ p (mod ℓ) — Eichler–Shimura mod ℓ as a matrix
identity — and the splitting degree k equals the order of the matrix.
KERNEL (`frobenius_matrices_mod3_37a1`): the exported matrices for 37a1 at all good p ≤ 61
have trace a_p (Lean's point counts) and determinant p mod 3.

**The image of ρ̄_{37a1,3} is all of GL₂(𝔽₃) (PROVED + KERNEL, `ImageMod3.lean`).**  The
exported matrices are ρ̄(Frob_p) up to a choice of basis of E[3], i.e. up to conjugacy; the
invariants (tr, det, scalar?) are conjugation-invariant.  ρ̄(Frob_5) has (tr, det) = (1, 2):
order 8; ρ̄(Frob_7) has (tr, det) = (2, 1), non-scalar: unipotent of order 3 (`frob5_ord8`,
`frob7_unip`, kernel).  `pairs_generate` (kernel): for every order-8 g and every non-scalar
unipotent h in GL₂(𝔽₃), the multiplicative closure of {g, h} contains all 48 elements (12 × 8
breadth-first closures on base-3 indices with a bitmask of seen elements).  Soundness of the
closure is PROVED (`generatedIdx_sub`: every index whose bit is set decodes to a product of the
generators), hence `generated_by_ord8_unip`: a multiplicatively closed subset of GL₂(𝔽₃) meeting
both classes is GL₂(𝔽₃), and `mod3_image_37a1_full`: the image of ρ̄_{37a1,3}, which is such a
subset, is full.  Consequently Gal(ℚ(37a1[3])/ℚ) ≅ GL₂(𝔽₃), the mod-3 excursion data of 37a1 are
`ExcursionData.ofHom` of an isomorphism, and `gl2_Fp_pseudocharacter` (p = 3) applies with
χ(Frob_p) = a_p mod 3.  Python (`test_mod3_image_of_37a1_is_full`) mirrors the check, with the
negative control that two unipotents (⊆ SL₂) or an order-8 element with a scalar never generate.
Axioms: propext, Quot.sound.

**The image of ρ̄₂ for all fifteen curves (PROVED + KERNEL, `ImageMod2.lean`, `mod2_image.py`).**
GL₂(𝔽₂) = S₃ permutes the roots of ψ₂ = 4x³ + b₂x² + 2b₄x + b₆.  Python (`mod2_image`) finds the
exact type from the rational roots (rational root theorem) and the discriminant: S₃ for twelve
curves, C₂ for 17a1, 73a1, 89b1 (rational 2-torsion x = 11/4, 3/4, −5/4), never C₃ or trivial;
and checks Dedekind's consistency at every good p ≤ 31: ρ̄₂(Frob_p) (computed matrix) has order
3, 2, 1 exactly when ψ₂ mod p has 0, 1, 3 roots.  Exported (`galoisMod2Data`) and kernel-checked
(`mod2_data_certified`): every witness matrix has (tr, det) = (a_p, p) mod 2 with a_p from Lean's own
point count of the Weierstrass model; the S₃ curves carry an order-3 and an order-2 witness; the C₂
curves carry an order-2 witness and their rational root is a root of ψ₂.  Group theory from kernel
facts: `generated_by_ord3_ord2` (every (order-3, order-2) pair generates S₃) and `image_C2` (a
multiplicatively closed set fixing v ≠ 0 with an order-2 element is exactly Stab(v), of size 2,
`stab_length`).  The closure machinery is now generic in n (`Generation.lean`, `generated_of_pairs`),
shared by the mod-3 and mod-2 certificates.  Imported inputs: "exported matrix = ρ̄(Frob_p) up to
conjugacy" and "a rational 2-torsion point is fixed by the image".  Axioms: propext, Quot.sound.

The Weil pairing e_ℓ(P, Q) = f_P(D_Q)/f_Q(D_P) by Miller's algorithm is the commutator
pairing of the Poincaré biextension (the same tame-symbol bookkeeping as §1.4); checked
bilinear, alternating, antisymmetric, of exact order ℓ, and Galois-equivariant
e(Frob P, Frob Q) = e(P, Q)^p, which is det ρ̄_ℓ = cyclotomic character read off the
biextension rather than the matrix.

### 3.9 Pseudocharacter ⇒ representation for finite Γ, by search (KERNEL + PROVED; `PseudocharSearch.lean`, `pseudochar.py`)
Taylor's theorem (p > 2): a 2-dimensional pseudocharacter T: Γ → 𝔽_p is the trace of a
semisimple representation.  For Γ = GL₂(𝔽₃) = Gal(ℚ(37a1[3])/ℚ) (§3.8) this is a finite
search, and Lean runs it in the kernel: det g = (T(g)² − T(g²))/2 is determined by T; the images
of the generating pair (ρ̄₃(Frob₅), ρ̄₃(Frob₇)) (generating by `pairs_generate`) range over the
matrices with the prescribed (tr, det); a candidate is extended along breadth-first words (the
table is one natural number in base 128) and accepted iff the generator relations
ρ(xg) = ρ(x)ρ(g) hold on all of Γ.  The found table is then certified independently:
multiplicativity on all 48² pairs and trace on all 48 elements (`certified`).
- `rep_certified`: for T′(g) = det(g)·tr(g), the pseudocharacter of ρ̄₃ ⊗ χ_cyc — on Frobenius
  elements p·a_p mod 3 (`Tprime_frobenius`, kernel) — the search finds a representation and
  the certificate passes; `trace_rep_certified`: the same for T = tr (recovering ρ̄₃).
- PROVED `Tprime_procesi`: T′ satisfies the Procesi identity, because g ↦ det(g)·g is a
  homomorphism (kernel, 48² pairs) and `M2.procesi` holds for its values.
- Negative control `bad_not_realised`: T(g) = tr(g) + det(g) − 1 has T(1) = 2 and is central
  (`Tbad_one`, `Tbad_central`) but is not a pseudocharacter (tr ρ̄ ⊕ (det − 1) is a virtual, not
  a genuine, 2-dimensional character), and the exhaustive search finds nothing.
- Python (`pseudochar.py`): `is_pseudocharacter` (exhaustive Procesi check) and
  `find_representation` for any finite group given by elements, multiplication and generators;
  tests realise tr, det·tr and the contragredient on GL₂(𝔽₃), show the found ρ for det·tr is
  conjugate to g ↦ det(g)g, and reject the control.
- Uniqueness (`rep_unique`, `trace_rep_unique`, kernel): the search finds exactly
  24 = |GL₂(𝔽₃)|/|centre| representations with trace T′ (resp. tr), all conjugate to the first —
  a conjugator is found on the two generators and verified on all 48 elements.  Python
  (`find_all_representations`, `are_conjugate`) mirrors this.  This is the other half of Taylor's
  statement for the instance.
IMPORTED: Taylor's theorem itself (the search is the finite instance, not the proof); its split,
absolutely irreducible case is PROVED for every group in §3.9b.

### 3.9b Pseudocharacter ⇒ representation for every group, by Rouquier's construction (PROVED; `PseudocharRep.lean`, `RingNorm.lean`, `pseudochar.py`)
`pseudochar_rep` (PROVED, propext / Quot.sound): let Γ be any group, R any commutative ring with 2
invertible, and T : Γ → R a 2-dimensional pseudocharacter (T(1) = 1 + 1, T(xy) = T(yx), Procesi).  If some
g ∈ Γ has λ + μ = T(g) and 2λμ = T(g)² − T(g²) with λ − μ a unit, and the pairing B(x₀, y₀) below is a unit
for some x₀, y₀, then
   ρ(x) = [[a(x), B(x, y₀)], [B(x₀, x)·B(x₀, y₀)⁻¹, T(x) − a(x)]]
satisfies ρ(1) = 1, ρ(xy) = ρ(x)ρ(y) and tr ρ = T.  Every entry is a polynomial in values of T:
a(x) = κT(gx) − κμT(x) (`aF_eq`, κ = (λ − μ)⁻¹) and B(x, y) = tr(e x f y) with e = κ(g − μ), f = −κ(g − λ).
The proof works in the formal group ring (finite formal sums, `FS`, `tr`, `fmul`) and reduces everything
to one identity, the rank-one property tr(e z e w) = tr(e z)·tr(e w) for all formal sums z, w (`qe`), and
its twin for f.  For group elements it is a linear combination of four Procesi instances — P(gx, g, y),
P(g, g, x), P(g, g, xy), P(g, x, y) — and the quadratic μ² − T(g)μ + λμ = 0 (`rank1`); it extends to formal
sums by bilinearity.  With linearity, cyclicity (`tr_rot`) and e + f = 1 under tr (`ef_front`) it gives
ee = e, ef = fe = 0 under tr, the rank-one pairing B(x, y₀)B(x₀, y) = B(x, y)B(x₀, y₀) (`B_rank_one`), and
each of the four entries of ρ(xy) = ρ(x)ρ(y) (`entry_a` … `entry_d`) in a few lines.
`excursion_rep_Zmod` composes it with `gl2_Zmod_pseudocharacter`: for any excursion datum D for
GL₂(ℤ/n) with values in ℤ/n, the pseudocharacter χ = Θ(f_tr)(·, 1) is the trace of the representation
built from χ alone, under the same hypotheses on χ — the step "pseudocharacter ⇒ parameter" of
V. Lafforgue's construction for GL₂, proved rather than imported in this case.
Polynomial identities are closed by `ring_eq`, a reflective normalizer for commutative rings
(`RingNorm.lean`): expressions are normalized to sorted sums of monomials with integer coefficients,
`denote_norm` (PROVED, propext / Quot.sound) preserves the value, and `decide +kernel` compares normal
forms; `lin_comb`/`lc_add` check "a − b is the stated combination of hypotheses".  It exists because `grind`
and core's own normalizer depend on `Classical.choice`, which the audit rejects; a false identity cannot
produce equal normal forms (spot-checked).
Python (`rouquier_representation`, `rouquier_data`): the same construction from T alone; tests check it
is a homomorphism with trace T on all of GL₂(𝔽₃) for tr, det·tr and the contragredient (conjugate to the
search result of §3.9) and on all 480² pairs of GL₂(𝔽₅) for det(g)^k·tr(g), k = 0, …, 3; for tr + det − 1 on
GL₂(𝔽₅), central with T(1) = 2 but not Procesi, every other hypothesis is met and ρ is not a homomorphism.
Not established here: the reducible case (B ≡ 0), the case with no element of distinct eigenvalues in R
(over a finite field one passes to 𝔽_{p²}; not formalized), characteristic 2, and uniqueness up to
conjugacy in general (only the finite instance of §3.9 is checked); for ℓ-adic coefficients, continuity
of ρ is not addressed.

### 3.10 The image of ρ̄_ℓ forced from point counts alone (COMPUTED; `mod_ell_image.py`)
For a good p, ρ̄_ℓ(Frob_p) has characteristic polynomial x² − a_p x + p mod ℓ, so the image is a
subgroup H ⊆ GL₂(𝔽_ℓ) meeting, for each observed polynomial χ, the set C_χ of elements with that
polynomial (a conjugacy class, or two when the roots coincide: scalar and non-scalar).
`forced_full(ℓ, polys)` decides rigorously whether every such H is GL₂(𝔽_ℓ), with no classification
of maximal subgroups: a recursion over subgroups generated by one element from each class in turn
(states = subgroups, carried with their short generator lists; the first element up to conjugacy;
distinct next states only; classes visited in decreasing element order).  A branch that exhausts
the classes below GL₂(𝔽_ℓ) is a proper subgroup meeting every observed class, i.e. the data do not
force surjectivity.  Results from p ≤ 60:
- ℓ = 5: forced full for 14 of the 15 curves; not for 11a1, which has a rational 5-torsion point
  (its image lies in a Borel, and the recursion finds a Borel meeting every class — a genuine
  obstruction, as the test checks: 1 − a_p + p ≡ 0 mod 5 for every good p ≤ 200).
- ℓ = 7: forced full for all 15 curves (≈ 2 s each after ordering classes by element order;
  50–150 s for some curves before).
- ℓ = 3: characteristic polynomials alone *cannot* force surjectivity even for 37a1: (x − 1)² is
  shared by 1 and the unipotents, and the normaliser of the non-split Cartan (order 16) meets every
  observed class.  Refining (x − 1)² to its non-scalar part — what the computed matrix at p = 7
  supplies — forces GL₂(𝔽₃); this is exactly the criterion `ImageMod3.lean` certifies.
Controls: single classes inside a Borel are never forced.  The ℓ = 3 case is the kernel certificate
of §3.8; ℓ = 5 and ℓ = 7 are certified in Lean below.

**ρ̄₅ and ρ̄₇ surjective in Lean, for all covered curves (PROVED + KERNEL, `ImageModL.lean`,
`CertTypes.lean`).**  Closures of ⟨g, h⟩ over 480 or 2016 elements are too expensive in the kernel
(a first mod-5 attempt with 600 column closures exhausted memory).  The reduction is a *word
certificate*: (1) S = {E₁₂(1), E₂₁(1), diag(1, ζ)} generates GL₂(𝔽_ℓ) — a THEOREM (`gl2_generated`):
for c ≠ 0, E₂₁(−c)·E₁₂(t)·g·E₁₂(−b₁) = diag(1, δ) with t = (1 − a)c⁻¹, every step undone by the inverse
elementary matrix, E₁₂(u) = E₁₂(1)^u, diag(1, δ) = diag(1, ζ)^k, and c = 0 is reduced to c ≠ 0 by
E₂₁(1); the scalar inverse c⁻¹ comes from the GL₂ inverse of diag(c, 1), δ ≠ 0 from the product staying
in the enumerated GL₂ (`mul_mem_gl`); the only kernel input is that ζ generates 𝔽_ℓ^× (`zetaGen`, ℓ²
operations), so nothing about S is enumerated; (2) for a class pair (A, B) — characteristic polynomials with distinct roots, hence single
conjugacy classes without scalars — a fixed representative gRep of A, and for every h ∈ B three words
in {gRep, h} (length ≤ 30 in the committed data through ℓ = 31, each packed as one natural) whose values are the elements of S, verified by a few dozen products each;
(3) for every g ∈ A a conjugator C with C·gRep·C⁻¹ = g.  Soundness (`pair_sound`, PROVED): a
multiplicatively closed H ∋ g ∈ A, h ∈ B is conjugated by C⁻¹ to H′ ∋ gRep, C⁻¹hC; C⁻¹hC is again in
B because tr is invariant by `trace_mul_comm` and det by Cayley–Hamilton (`det_conj`: 2·det = tr² − tr(x²),
2 invertible), so no determinant multiplicativity is needed; the words put S in H′, so H′ ⊇ GL₂(𝔽_ℓ) by `gl2_generated`, and conjugating back uses that conjugation
by a unit preserves the enumerated GL₂(𝔽_ℓ), PROVED without determinant multiplicativity: a
left-invertible matrix kills no nonzero vector, while a singular 2×2 matrix kills (d, −c) or (−b, a)
(`kernel_vectors`, decided per ℓ; `det_ne_zero_of_left_inverse`).  Everything specific to ℓ is a
`FieldFacts ℓ` record (decided per ℓ in ℓ² operations: Cayley–Hamilton for tr², the negation facts, the scalar
inverse table).  The data (`mod5Cert`, `mod7Cert`, exported) are chosen by a greedy cover: mod 5, three
pairs cover the 14 curves other than 11a1 (rational 5-torsion); mod 7, four pairs cover all 15.
The same for ℓ = 11 (13 200 elements), ℓ = 13 (26 208), ℓ = 17 (78 336), ℓ = 19 (123 120), ℓ = 23 (267 168), ℓ = 29 (682 080) and ℓ = 31 (892 800): the matrix inverse is
PROVED (`adj_left_inverse`: u·adj(z)·z = 1 when u·det z = 1, a ring identity; `inv_of_invTable`) over the
scalar inverse table (`invTable`, ℓ² operations), so `FieldFacts.of` assembles the ℓ-specific facts from
three ℓ²-sized decided statements and nothing of size ℓ⁴ is enumerated outside the pair certificates, and the certified pairs
are found lazily (most-covering candidate pair first; a pair is certified exactly when the words the
kernel will check exist, found by breadth-first search with early exit; no multiplication table above
2016 elements).  Kernel: `pairsℓ_ok` (all witnesses and words), `curvesℓ_ok` (for each
curve, a_{p₁}, a_{p₂} mod ℓ from Lean's point counts of the Weierstrass model match the pair), for
ℓ ∈ {5, 7, 11, 13, 17, 19, 23, 29, 31}, one declaration per certified pair so the kernel frees its cache between them.  Headlines
`mod5_images_full`, …, `mod31_images_full` (`data_sound`): for every listed curve, any multiplicatively closed subset of
GL₂(𝔽_ℓ) containing elements with the characteristic polynomials of ρ̄_ℓ(Frob_{p₁}), ρ̄_ℓ(Frob_{p₂})
is all of GL₂(𝔽_ℓ); with Eichler–Shimura mod ℓ as the only imported input, ρ̄₅ is surjective for
the 14 curves other than 11a1 and ρ̄₇, ρ̄₁₁, ρ̄₁₃, ρ̄₁₇, ρ̄₁₉, ρ̄₂₃, ρ̄₂₉, ρ̄₃₁ for all 15.  Together with §3.8,
the exact certified scope is:

| ℓ | curves and conclusion |
|---|---|
| 2 | the stated 15 curves: S₃ or C₂ as listed in §3.8 |
| 3 | 37a1: full GL₂(𝔽₃) |
| 5 | the stated 14 curves other than 11a1: full GL₂(𝔽₅) |
| 7, 11, 13, 17, 19, 23, 29, 31 | the stated 15 curves: full GL₂(𝔽_ℓ) |

No claim is made for ℓ > 31 or for curves outside the stated set.  The surjectivity interpretation
imports Eichler–Shimura mod ℓ; the Lean headline proves the finite closed-set criterion above,
with the Frobenius trace and determinant equalities as hypotheses.  Axioms propext, Quot.sound.
Python mirror: `test_word_certificates_are_valid` checks exactly what Lean checks (S generates,
conjugators, words) for ℓ = 5, 7, 11, 13, 17, 19, 23, 29, 31 and the full pair closures for ℓ ≤ 7.  The instances
(one module `ModLℓ` per ℓ, checked in parallel by `lake`) build in ≈ 7 min wall from a clean checkout (434 s;
the critical path is ℓ = 31: data 56 s, instances 195 s).  Measured alone on that run's machine: a certified
pair at ℓ = 29 or ℓ = 31 ≈ 20–23 s, an instance module ≤ 209 s under 2.6 GB, a data module `DataModLℓ` (words
packed as naturals) ≤ 51 s under 1.6 GB, against 120 s under 3.1 GB for the former single 1.7 MB data file
through ℓ = 29; the field facts and `S_generates` take under a second.  The heaviest process of that build
was `Pseudocharacter` (10.6 GB), which does not touch the certificates; the subsequent structural
Procesi proof removes this hotspot (§3.6 and its matched clean-build measurements).
CORRECTION: an earlier version of this
paragraph attributed that 10.6 GB peak to the single data file, and a 4.1 GB peak (that of
`BrandtCertificates`) to the ℓ = 29 data module; both were the build's maximum over all processes.  Kernel bookkeeping that made
this feasible (`Generation.lean`, `ImageModL.lean`): the kernel caches the normal form of every closed
term it meets until the declaration is checked, so memory is the number of distinct terms evaluated, not
the size of the data.  Hence (i) every arithmetic step is a `Nat.*` call on literals — an operator's
instance chain (`HMod.hMod → Mod.mod → Nat.mod`) is unfolded and cached link by link at every call,
and writing `Nat.mod` directly divides the kernel's memory by 2.5 and its time by 3; (ii) the closure
keeps the visited set as a bitmask and the frontier as a list of codes and never scans the code range
(the scan of n⁴ codes per layer was 3× slower and 2× larger than the list); (iii) membership in a class
is tested on codes (`trCode`, `detCode`, `allCodes`, PROVED equal to the `Fin` trace and determinant)
rather than on filtered lists of matrices, whose lazy construction the kernel also caches element by
element; (iv) every intermediate mask is forced by a cheap GMP test (`Nat.beq (s % 2) 2`) — an unforced
fold carries a chain of unevaluated operations and hits the kernel's recursion limit, and forcing with
a `match` against `Nat.succ` makes the kernel carry the value as `Nat.succ` of a literal and lose
accelerated arithmetic (300 s instead of 2 s); (v) `Nat.log2` is not GMP-accelerated (3 s per call on a
14 000-bit number); (vi) the ℓ ≥ 11 checks lift the default heartbeat limit; (vii) the closure's
generators are maps on codes, so right multiplication by a *known* generator is specialised (x·E₁₂(1)
= [[a, a+b], [c, c+d]], x·T = [[a+b, ζb], [c+d, ζd]]: a handful of operations instead of the generic
product, PROVED equal to it through the digit lemmas), and S has two elements rather than three, so
the closure does two products per element; (viii) one declaration per certified pair, since the cache
is freed between declarations (ℓ = 13: 7.5 GB for the eight pairs together, 1.5 GB each alone).
Before (i)–(iii) the ℓ = 13 checks were killed at 13.6 GB; before (vii) the ℓ = 17 closure took 11.3 GB.  (ix) Finally the closure is gone: `gl2_generated` proves once that
E₁₂(1), E₂₁(1), diag(1, ζ) generate GL₂(𝔽_ℓ), so the only enumeration left per ℓ is the class-pair
certificates, and ℓ = 19 costs no more than a pair does; (x) likewise the inverse check (ℓ⁴ codes, 64 s and 4.2 GB
at ℓ = 19) is replaced by the adjugate identity over an ℓ² table of scalar inverses; (xi) and the classes are
enumerated rather than found by scanning ℓ⁴ codes: a class {tr = t, det = d} has at most ℓ² + ℓ elements
(`classMats`: the (2,2) entry is t − a, and c = (a(t − a) − d)·b⁻¹ when b ≠ 0), PROVED complete
(`mem_classMats`), so a pair certificate is ℓ² conjugators and ℓ² × 3 words and nothing of size ℓ⁴ is
evaluated anywhere; (xii) and the certificate lists them in the class's enumeration order, so the kernel walks
the two lists pointwise (`pointwise`, `pointwise_sound`) instead of searching the list for every element
(ℓ⁴/2 comparisons: an ℓ = 23 pair went from 53 s to 18 s).  (xiii) On the Python side the word search is bidirectional (forward from the
generators, backward from each target through the inverse generators, always expanding the smaller frontier,
each layer costing its own size): 7.5 ms instead of 86 ms per search at ℓ = 23, so the export of all eight ℓ,
which the gate re-runs as its bridge check, takes ≈ 6.5 min with ℓ = 29 included (11 min before, without it); with ℓ = 31 it takes 278 s on the
roughly twice faster machine of that run.
The search reconstructs positive words: a backward edge is x·g = parent(x), so its letter is appended
in that order after the reversed forward path.  Each frontier contains a whole BFS layer and only
unseen vertices enter it; reuse across targets preserves that invariant, and finite exhaustion
returns an unreachable result.  An empty generator list has no nonempty words, including at the
identity target.  Plain-BFS comparisons check minimal length on GL₂(𝔽₅) and GL₂(𝔽₇), with target-order,
duplicate-generator and unreachable controls on GL₂(𝔽₂) and GL₂(𝔽₃).  For larger ℓ, the certificate
checks establish word validity; no experimental minimality claim is made.
`forced_full_classes` (Python) now prunes the first set to conjugacy representatives only when every
set is conjugation-invariant (review fix; counterexample test in GL₂(𝔽₂)).

## Branch 3, fourth act — the Satake isomorphism for PGL₂ (`proof/langlands/LanglandsOracles/Satake.lean`, `satake.py`)

### 3.11 The algebra, for every q (PROVED)
G = PGL₂(F), K = PGL₂(𝒪), residue field of size q, 𝒯 = G/K.  A_n = 1_{K diag(πⁿ,1) K} (sum over the
sphere of radius n) spans the spherical Hecke algebra.  With an end ω fixed, the horocycles (N-orbits)
are indexed by the height, and the unnormalised Satake transform is the horocycle profile of the sphere,
𝒮(A_n) = Σ_h #{d(o,v) = n, ht v = h} Xʰ ∈ ℤ[q][X^{±1}], on which W = S₂ acts by X ↦ qX⁻¹ (the δ^{1/2}
twist).  Degree-n elements are coefficient functions j ↦ [X^{n−2j}]; q is an arbitrary integer, so each
theorem is the identity in ℤ[q]:
- `sphere_eq_sat`: the walk from o (up the ray to ω, then down: q − 1 choices off the ray, q afterwards,
  q from o itself) gives 𝒮(A_n) = Xⁿ + Σ_{0<j<n} (q−1)q^{j−1} X^{n−2j} + qⁿX⁻ⁿ;
- `sat_weyl`: [X^{−k}] = q^k [X^k] (twisted W-invariance); `sat_hecke`, `sat_hecke_one`: 𝒮 carries
  A₁A_n = A_{n+1} + qA_{n−1}, A₁² = A₂ + (q+1)A₀ to multiplication by χ₁ = X + qX⁻¹, so 𝒮 is the ring
  homomorphism ℤ[A₁] → ℤ[q][X^{±1}], A₁ ↦ X + qX⁻¹;
- `sat_eq_chi_sub`: 𝒮(A_n) = χ_n − χ_{n−2}, χ_n = Σ_j q^j X^{n−2j} = q^{n/2} tr Sym^n of Ĝ = SL₂ at
  diag(q^{−1/2}X, q^{1/2}X⁻¹): root-datum duality in its smallest case, K\G/K ↔ dominant weights of Ĝ;
- `chi_clebsch_gordan`: χ₁χ_{n+1} = χ_{n+2} + qχ_n (Clebsch–Gordan for SL₂ after the twist);
- `ball_eq_chi`: χ_n = 𝒮(A_n + A_{n−2} + ⋯): the Hecke operator of Sym^n is the ball of the parity of n,
  classically T(𝔭ⁿ);
- `invariant_decomposes` (+ `sat_zero`, `lift_zero`): every twisted-invariant element of degree n is a
  ℤ[q]-combination of χ_n, χ_{n−2}, …, and 𝒮(A_n) is unitriangular in them — 𝒮 is an isomorphism
  H(G, K) ≅ ℤ[q][X^{±1}]^W;
- `hecke_seq_eq_h`, `power_sum_eq`: at a Satake parameter {α, β} (α + β = a, αβ = q) the T(𝔭ⁿ)-eigenvalues
  e_{n+1} = a e_n − q e_{n−1} are h_n(α, β), i.e. Σ e_n Yⁿ = 1/(1 − aY + qY²), and αⁿ + βⁿ = h_n − q h_{n−2}.
Core Lean, no Mathlib, no `decide`, no `grind` (its ring solver pulls in `Classical.choice`): a small
`satake_arith` macro splits the `if`s, distributes and AC-normalises with `simp`, and closes with
`omega` on monomial atoms; four default simp lemmas proved classically (`Nat.add_eq_right` and its
mirrors) are erased in the file.  Axioms: propext, Quot.sound — now enforced by the audit gate, which
also rejects `Classical.choice`.
IMPORTED in Lean (COMPUTED below): that the walk model is the tree seen from an end, and the Hecke
relation A₁A_n = A_{n+1} + qA_{n−1}.

### 3.12 The inputs on the tree of PGL₂(𝔽_q((1/t))) (COMPUTED)
In the Iwasawa chart (k, u) of `bruhat_tits.Tree` (π = 1/t) the unique neighbour with smaller k points
to the end of the ray (k, 0), k → −∞, so the height is −k:
- the sphere of radius n about v₀, sorted by k, has profile 𝒮(A_n) for q ∈ {2, 3, 5}, n ≤ 4 (q = 2:
  (1,1,2,4,16); q = 3: (1,2,6,18,81));
- the structure constants #{w ~ o : d(w, u) = n} depend only on d(o, u) and are 1 at n+1, q at n−1
  (q + 1 when n = 1), 0 otherwise (q ∈ {2, 3}, n ≤ 3);
- K diag(π^a, π^{n−a}) K / K, 0 ≤ a ≤ n (column Hermite form, b ∈ 𝒪/π^a) is each vertex at distance
  n, n − 2, … exactly once (q ∈ {2, 3}, n ≤ 4): T(πⁿ) = A_n + A_{n−2} + ⋯.

### 3.13 The output on Drinfeld eigenforms (COMPUTED)
Here the place is finite (𝔭 ∤ 𝔫, residue field of size |𝔭|), which is why the Lean statements are for
every q.  T(𝔭ⁿ) acts on Γ₀(𝔫)\𝒯 cochains through [[𝔭^a, b], [0, 𝔭^{n−a}]], b mod 𝔭^{n−a}
(`hecke_representatives(q, prime, power)`, which for power 1 is the old T_𝔭):
- level t³ over 𝔽₂(t), 𝔭 = t + 1 (n ≤ 4) and t² + t + 1 (n ≤ 2): T(𝔭ⁿ) = e_n(a_𝔭) = h_n(α, β), and
  e_n − |𝔭| e_{n−2} = |𝔭|ⁿ + 1 − #E_{t³}(𝔽_{𝔭,n}) by point counts over the degree-n extension
  (a_{t+1} = −1: αⁿ + βⁿ = −1, −3, 5, 1);
- level t³ over 𝔽₃(t) (genus 2), 𝔭 = t + 1: T(𝔭²) = T(𝔭)² − 3, T(𝔭³) = T(𝔭)T(𝔭²) − 3T(𝔭) as matrices,
  and both curves' eigensystems satisfy the power-sum identity against their own point counts over 𝔽_{3ⁿ}.
The Galois side (Frobenius powers on H¹ of the curve) and the automorphic side (the ball operators on
the quotient graph) meet exactly through the Satake parameter: Drinfeld's dictionary at every 𝔭ⁿ, not
only at 𝔭.

## Open items and next steps (recorded, not started)

### The H10/ℚ biextension thread (Dossier II §8)
| item | status |
|---|---|
| strict presentation of β₂ and Law B stratum-uniformly (the fixed next increment) | done: §1.7 (PROVED sign algebra + acceptance test +1 everywhere) |
| 1. stratum-uniform proof of Law B | done modulo tame Weil reciprocity (IMPORTED, measured) |
| 2. elliptic-net closed form for κ_tame on 37a1 | done: §1.9 (measured exactly; σ-derivation IMPORTED) |
| 3. a finite-type V with existential projection onto the ρ-graph of C2 | open — this is the actual problem; nothing here constrains it |
| 4. sufficiency → equivalence without Mazur's conjecture | open, not attempted |
| selection of a candidate (V, α), soundness and completeness separately | deferred by design until the harness is complete |

### Next steps, by branch
- **Branch 1 (GL₁ on E).**
  - The full duality E^∨(𝔽_p) ≅ Hom(E(𝔽_p), ℚ̄^×) beyond level ℓ (e.g. ℓ = 9 on E(𝔽₇) ≅ ℤ/9): [ℓ]-preimages by
    division polynomials and root finding instead of point enumeration.
  - Lean kernel certificates for the Lang fibres, Abel descent and tame reciprocity of §1.1, §1.3, §1.4
    (currently Python only), and for the §1.7 acceptance table on exported samples.
  - An algebraic proof of the §1.9 closed form from the elliptic-net recurrences (no σ-function).
  - Port Law A (C7) and the Miller-ladder test T9, and cross-check against the original
    `biextension_oracle_37a1.py` if it becomes available.
- **Branch 2 (Brandt / trace formula).**
  - Quantify the LH-floor remark of §2.6: what a Frobenius-trace floor can hide given |a_ℓ| ≤ 2√ℓ.
  - Connect the supersingular isogeny graphs to the expander and PQC threads (none yet).
- **Branch 3 (function fields).**
  - Satake inputs as theorems: the walk model of a tree seen from an end, and A₁A_n = A_{n+1} + qA_{n−1},
    proved for the abstract (q+1)-regular tree rather than computed on the lattice tree.
  - Satake for GL₂ (central character) and PGL_n / root-datum duality beyond SL₂.
  - Drinfeld modular forms ↔ Carlitz module (the Carlitz side stops at GL₁ CFT).
  - Rank-2 ℓ-adic local systems on ℙ¹ constructed directly, not only through elliptic curves.
  - Excursion: pseudocharacter ⇒ parameter is PROVED in the split, absolutely irreducible case for every
    group (§3.9b); open: the reducible case, extension of scalars when no element splits over the
    coefficients, uniqueness up to conjugacy in general, and continuity for ℓ-adic coefficients.
