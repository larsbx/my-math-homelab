# G0 literature gate: the S-adic Pisot conjecture

**Status:** literature gate (methodology phase G0). It records imported
statements and their exact hypotheses. It proves nothing and promotes no claim.
Each row is labelled by how it was checked:

- **verified:** read in the arXiv text;
- **abstract:** checked against the abstract or bibliographic record only;
- **unverified:** not checked against a source.

Only verified rows may be cited as imported theorems on other surfaces.

Conventions: `d` is the number of letters. BST19 writes `M_{[k,l)} = M_k ... M_{l-1}`.

## 1. The conjecture

**S-adic Pisot conjecture** (BST19, Conjecture 3.5). *Verified.* Let `S` be a
finite or infinite set of unimodular substitutions over `d` letters. Let
`σ ∈ S^ℕ` be a primitive, algebraically irreducible and recurrent directive
sequence with balanced language `L_σ`. Then the collection `C₁` of
translated Rauzy fractals forms a tiling of `1^⊥`, and `(X_σ, Σ, μ)` is
measurably conjugate to a translation on `T^{d-1}`. In particular, it has pure
discrete spectrum.

BST19 note that "Pisot" enters only through balance. This repository tracks
the conjecture as the claim `SAdicPisotConjecture`, status **open**.

Berthé–Delecroix (2014) states no numbered conjecture of this form (*verified*).
Its Theorem 6.4 gives μ-a.e. balance from `θ₂ < 0`.

## 2. Imported statements

| Key | Statement (abridged; exact hypotheses in the source) | Source | Check |
|---|---|---|---|
| BST19-3.1 | Hypotheses: `σ` primitive and algebraically irreducible over unimodular `S`, and there is `C` such that for every `ℓ` some `n` has `σ_{[n,n+ℓ)} = σ_{[0,ℓ)}` with `L_σ^{(n+ℓ)}` C-balanced. Conclusions: minimal and uniquely ergodic; subtiles compact with null boundary; `C₁` a multiple tiling; a finite-fibre toral factor. Under strong coincidence, measurable conjugacy to a domain exchange. **`C₁` tiles iff geometric coincidence holds**, and then pure discrete spectrum, natural coding and bounded remainder sets follow. | Berthé–Steiner–Thuswaldner, Ann. Inst. Fourier 69 (2019) 1347–1409, arXiv:1410.0331 | verified |
| BST19-PRICE | Definition 5.8 packages Primitivity, Recurrence, algebraic Irreducibility, C-balance along the return times, and a recurrent left Eigenvector. Lemma 5.9 shows the hypotheses of Theorem 3.1 imply PRICE. | BST19 | verified |
| BST19-3.3 | Setting: an ergodic S-adic graph edge shift with a log-integrable cocycle, the Pisot condition `θ₁ > 0 > θ₂`, positive mass on every cylinder, and **some cylinder whose substitution has a positive incidence matrix**. Conclusion: for a.e. walk, Theorem 3.1 (i)–(v) hold, and (vi)–(viii) hold if `C₁` tiles. **Tiling is not automatic.** arXiv v5 allows infinite graphs; the published version needs finite ones. | BST19 | verified |
| BST19-3.7 | Arnoux–Rauzy, `d=3`: for every ergodic `ν` with full support, a.e. `σ` tiles and is conjugate to a translation on `T²`. Pisot input from Avila–Delecroix. | BST19 | verified |
| BST19-3.8 | Arnoux–Rauzy, every sequence of a class: contains each `α_i`, recurrent, with bounded weak partial quotients. Corollary 3.9: linearly recurrent AR words with recurrent directive sequence have pure discrete spectrum. | BST19 | verified |
| BST19-3.10 | Brun, `d=3`: same conclusion as 3.7 for `{β₁, β₂, β₃}`. | BST19 | verified |
| BMST16 | `d=2`: uniform C-balance (as in BST19-3.1) gives strong coincidence (Theorem 1, unimodularity not needed). With unimodularity it gives conjugacy to a rotation (Theorem 2). There is an a.e. version on sofic shifts (Theorem 3). This is **not** the full conjecture for `d=2`, since uniform C-balance is still assumed. | Berthé–Minervino–Steiner–Thuswaldner, Topology Appl. 205 (2016), arXiv:1501.07085 | verified (volume and pages: abstract) |
| BSTY19 | A morphism of full rank, on two letters, or left/right permutative is fully recognizable for aperiodic points (Theorem 3.1). Hence every unimodular directive sequence is recognizable for aperiodic points (Theorem 4.6). | Berthé–Steiner–Thuswaldner–Yassawi, ETDS 39 (2019), arXiv:1705.00167 | verified |
| BST23-3.1/3.5 | A positive continued fraction algorithm with the Pisot condition, a faithful substitutive realization, and **one periodic Pisot point whose substitution has pure discrete spectrum** gives a.e. bounded natural codings, hence pure discrete spectrum. Theorems 3.3/3.6 drop the periodic point at the price of an acceleration. | Berthé–Steiner–Thuswaldner, JEMS 25 (2023), arXiv:2005.13038 | verified |
| BST23-6.x | a.e. pure discrete spectrum: Cassaigne–Selmer `d=3` (Theorem 6.2); Arnoux–Rauzy, every `d` (Theorem 6.5); Jacobi–Perron `d=3` (Theorem 6.6); Brun `d=4` (Theorem 6.7), whose periodic points were certified with the balanced pair algorithm. | BST23 | verified |
| BST21 | Selmer `θ₂ < 0`: `d=3` (Theorem 5.1); `d=4`, computer-assisted with rigorous error control (Theorem 5.4). Brun and Jacobi–Perron: heuristic `θ₂ < 0` up to 10 letters and `> 0` from 11. | Berthé–Steiner–Thuswaldner, Math. Comp. 90 (2021), arXiv:1910.09386 | verified |
| CLL22 | Cassaigne algorithm: for ergodic `μ` with `μ([12121212]) > 0`, μ-a.e. C-adic word is balanced and `θ₂ < 0` (Theorem C). No claim of pure discrete spectrum. | Cassaigne–Labbé–Leroy, Mosc. J. Comb. Number Theory 11 (2022), arXiv:2102.10093 | verified |
| AD15 | Pisot property of the fully subtractive and Brun monoids. This is the Pisot input of BST19-3.7, 3.10 and of Avila–Hubert–Skripchenko. | Avila–Delecroix, arXiv:1506.03692 | abstract |
| AHS16 | Rauzy-gasket diffusion; uses AD15 for the Pisot property. | Avila–Hubert–Skripchenko, Invent. Math. 206 (2016), arXiv:1412.7913 | verified |
| CFZ00 | There is an unbalanced Arnoux–Rauzy word, hence one that is not a natural coding. | Cassaigne–Ferenczi–Zamboni, Ann. Inst. Fourier 50 (2000) | abstract |
| CFM08 | There are weakly mixing Arnoux–Rauzy systems. | Cassaigne–Ferenczi–Messaoudi, Ann. Inst. Fourier 58 (2008) | abstract |
| BD14 | Survey; Theorem 6.4: `θ₂ < 0` implies a.e. balance. | Berthé–Delecroix, RIMS Kôkyûroku Bessatsu B46 (2014), arXiv:1309.3960 | verified |

Read only for metadata or abstract, with no theorem imported:

- Thuswaldner, LNM 2273 (2020) survey;
- Fougeron–Skripchenko, arXiv:1904.13297;
- Fougeron, arXiv:2001.01367;
- Arnoux–Berthé–Minervino–Steiner–Thuswaldner, arXiv:2508.16441.

## 3. Status matrix

Status of a.e. pure discrete spectrum for the natural measure.

| Algorithm | `d = 2` | `d = 3` | `d ≥ 4` |
|---|---|---|---|
| Arnoux–Rauzy | Sturmian classical; BMST16 under uniform C-balance | a.e. (BST19-3.7). Every sequence of a class (BST19-3.8). **False without a balance restriction** (CFZ00, CFM08) | a.e., every `d` (BST23-6.5) |
| Brun | as above | a.e. (BST19-3.10) | `d=4` a.e. (BST23-6.7). `5 ≤ d ≤ 10`: numerical Pisot evidence only, **open**. `d ≥ 11`: Pisot numerically false |
| Cassaigne–Selmer | as above | a.e. (BST23-6.2) | Selmer `d=4`: `θ₂ < 0` computer-assisted (BST21), pure discrete spectrum **open**. `d ≥ 5`: Pisot numerically false |
| Jacobi–Perron | as above | a.e. (BST23-6.6) | `4 ≤ d ≤ 10`: numerical Pisot only, **open** |
| Fully subtractive, Poincaré | — | unverified | unverified |

Conjecture 3.5 itself is **open** for every `d ≥ 3`. For `d = 2` it is known
only under uniform C-balance. In every `d`, the tiling still needs geometric
coincidence (BST19-3.1(v)).

## 4. Consequences for the plan

1. **Reduction lever (G3).** BST23-3.1 reduces a.e. pure discrete spectrum for
   a whole algorithm to a Pisot-condition input plus **one periodic point whose
   substitution has pure discrete spectrum**. Deciding the second input is the
   PSC kernel's balanced pair algorithm on the composite, which is how BST23
   certified Brun `d=4`. The open cells this lever can reach are Selmer `d=4`
   (Pisot input already computer-assisted in BST21) and Brun and Jacobi–Perron
   for `5 ≤ d ≤ 10` (Pisot input still numerical, so evidence only until certified).
2. **Exact hypotheses the kernel can certify.**
   - BST19-3.3's "some cylinder has a positive incidence matrix" is exactly
     `sadic.cocycle.positive_blocks`.
   - BST19-3.1's recurrence of a block is a property of the directive sequence.
   - C-balance can only be **refuted** by a finite computation
     (`sadic.balance.image_balance` is a lower bound). It is never certified that way.
3. **Negative controls (R4).** The CFZ00 and CFM08 Arnoux–Rauzy sequences have
   to come out unbalanced or inconclusive, never certified.
4. **Recognizability is free in the unimodular regime** (BSTY19-4.6). The
   standing hypotheses need not carry it separately.
5. **Uniform certificates (G5).** The everywhere results (BST19-3.8) need
   bounded weak partial quotients. A uniform balanced-pair graph over a sofic
   directive shift is the candidate route to every-sequence statements for
   other classes. It awaits a novelty gate (methodology R7).

## 5. Addendum (2026-10-09, second pass)

All entries below were read in the arXiv text of BST23 (arXiv:2005.13038).

| Key | Statement | Check |
|---|---|---|
| BST23-P6.1 | Proposition 6.1 (after [BST10, Theorem 5.8.8]): a unimodular Pisot irreducible substitution has pure discrete spectrum **iff** the balanced pair algorithm started from `I₀ = {(ij, ji) : i ≠ j}` terminates. Terminates means: no new irreducible balanced pairs after finitely many steps, and every pair reached eventually contains a coincidence. | verified |
| BST23-§6.5 | Unordered Brun family `β_{i,j}: j ↦ ij`, `k ↦ k` (6.9), with the sofic admissibility condition (6.10). The periodic point `τ = β₁₂∘β₂₃∘β₃₄∘β₄₁` (`1 ↦ 12341`, `2 ↦ 12`, `3 ↦ 123`, `4 ↦ 1234`) is a Pisot point; "using the balanced pair algorithm, one can show that τ has purely discrete spectrum". This is the finite input of Theorem 6.7. | verified |
| BST23-§6.2 end | For Selmer in higher dimensions, "two problems occur": a substitutive realization of factor complexity `(d−1)n + 1` has to be found, and the second Lyapunov exponent seems to be negative only for `d ≤ 4`. | verified |

**Correction to §4.1.** The Selmer `d = 4` cell is **not** reachable by the
BST23 lever as it stands. Its Pisot input exists (BST21 Theorem 5.4), but the
"faithful substitutive realization" hypothesis of BST23 Theorems 3.1/3.5 has
no known instance for Selmer `d = 4`. Constructing one is a prior open
problem. For Brun, the realization (6.9)/(6.10) is defined for every `d`, so for
`5 ≤ d ≤ 10` the missing input is a certified Pisot condition: BST21 has only
numerics there, and a periodic-point census in those dimensions is evidence
until that input exists. A Jacobi–Perron realization for `d ≥ 4` is
unverified. The first calibration of the G3
pipeline is therefore the **replication** of BST23 §6.5 (Brun `d = 4`), in
`docs/sadic-g3-brun4-census.md`.

## 6. Return-time overlap import (2026-10-09)

**Verified:** BST19 arXiv:1410.0331v5, Definition 5.8, Lemma 5.9, and the
proof of Lemma 5.11 were read directly. PRICE (P) places the same positive
matrix B at the end of every selected recurring prefix; (R) repeats each
substitution of that prefix, `σ_{n_k+r} = σ_r` for `0 ≤ r < ℓ_k`; (C)
supplies balance at `n_k + ℓ_k`. Footnote 3 explicitly
distinguishes this from recurrence of a positive block alone. Lemma 5.9
derives PRICE from Theorem 3.1's hypotheses. Lemma 5.11 already uses the
suffix to compare image sizes.

Source: [BST19, arXiv v5](https://arxiv.org/pdf/1410.0331v5), §5.2,
printed pp. 17–18. The repository's T1′ applies this import to its
swap-pair type triples; its proof and scope are in
[`t1-uniform-overlap-finiteness.md`](t1-uniform-overlap-finiteness.md).
The independent source audit and validation reconciliation are recorded in
[`t1-prime-audit-2026-10-09.md`](t1-prime-audit-2026-10-09.md).

## 7. Arnoux–Rauzy balance for the anchor example (2026-10-09)

**Verified:** BST19 arXiv:1410.0331v5, Proposition 9.3 (printed p. 33)
states that, on three letters, if every Arnoux–Rauzy label occurs infinitely
often and no run of `h+1` identical labels occurs, every shifted language
is `(2h+1)`-balanced. The source attributes this to BCS13 Theorem 7 and
its proof. Setting `h = 1` supplies the `C = 3` bound used by Corollary A
in [`all-depth-bounded-anchors.md`](all-depth-bounded-anchors.md).

Source: [BST19, arXiv v5](https://arxiv.org/pdf/1410.0331), §9.1.
The example's primitivity, positive suffixes, bounded anchor gaps, and
nonperiodicity are checked separately in its proof.

## 8. Barge's class (2026-10-09)

Both entries were read in the arXiv text,
[arXiv:1403.7826](https://arxiv.org/abs/1403.7826). The paper is M. Barge,
*Pure discrete spectrum for a class of one-dimensional substitution tiling
systems*, Discrete Contin. Dyn. Syst. 36 (2016) 1159–1173.

| Key | Statement | Check |
|---|---|---|
| Barge16-3.13 | Theorem 3.13: if `φ` is primitive, Pisot (Pisot inflation), injective on initial letters and constant on final letters, then the tiling dynamical system `(Ω_φ, R)` has pure discrete spectrum. Remark 3.14: "constant on final letters" may be weakened to "eventually constant". No irreducibility or unimodularity is assumed. | verified |
| Barge16-§4.2 | Arnoux–Rauzy substitutions, the 3-letter Brun substitutions of [BBJS] and the Jacobi–Perron substitutions satisfy the hypotheses (Brun and Jacobi–Perron "follow immediately from Theorem 3.13 and Remark 3.14"). | verified |
| Barge16-R4.2 | Remark 4.2: for an irreducible unit β-substitution, pure discrete spectrum of the tiling flow transfers to the symbolic `Z`-action, citing [BKw] and Clark–Sadun [CS]. | cited only; the primary sources are not read here |

Barge's theorem concerns the tiling **flow**. BST23 Theorem 3.1 asks for pure
discrete spectrum of the **symbolic** system `(X_σ, Σ)` of a periodic point.
The repository uses Barge only for the flow. The symbolic statement it takes
from BST23 Proposition 6.1 (balanced pairs, verified) wherever that applies,
and §8 does not import the transfer between the two; §9 gates it.

**Consequence for §5.** For Brun with `5 ≤ d ≤ 10` the realization exists in
every dimension. The periodic-point input of BST23 Theorem 3.1 is now
supplied for `d = 5, 6` by points that pass the balanced pair algorithm
(`docs/sadic-g6-brun-higher-census.md`, Theorem C). So for those two
dimensions the Pisot condition is the only missing input.

## 9. Flow-to-symbolic transfer (2026-10-09)

The transfer that §8 left as "cited only" is gated here from primary texts.

| Key | Statement | Check |
|---|---|---|
| SS02-def | Sirvent–Solomyak, *Pure discrete spectrum for one-dimensional substitution systems of Pisot type*, Canad. Math. Bull. 45 (2002) 697–710, [doi:10.4153/CMB-2002-062-3](https://doi.org/10.4153/CMB-2002-062-3), p. 699: "The substitution ζ is said to be of Pisot type if the Perron-Frobenius eigenvalue of the matrix Mζ is a Pisot number and the characteristic polynomial is irreducible". Such a substitution is primitive. | verified |
| SS02-§4 | p. 703: the prototiles are intervals whose lengths form a left Perron–Frobenius eigenvector `(t₁, …, t_d)`. `X_T` is the tiling space of the self-similar tiling `T` built from the fixed point, and `(X_T, Γ_x)` is the translation R-action. This R-action is conjugate to the suspension flow over `(Ω_ζ, σ)` with height `t_i` on the cylinder of `i`. | verified |
| SS02-5.2 | Corollary 5.2: "Let ζ be a substitution of Pisot type. If the R-action (X_T, Γ_x) has pure discrete spectrum, then the Z-action (Ω_ζ, σ) has pure discrete spectrum." Unimodularity is not assumed. | verified |
| Barge16-§2 | Barge's prototiles are `ρ_i = ([0, ω_i], i)`, with `ω` the positive left eigenvector of the abelianization. The inflation is its eigenvalue `λ`. These are the self-similar lengths of SS02-§4, so `(Ω_φ, R)` and `(X_T, Γ_x)` are the same translation action on the same tiling space. | verified |
| CS03-3.1 | Clark–Sadun, *When size matters*, ETDS 23 (2003), arXiv:math/0201152. Theorem 3.1 and Corollary 3.2 give topological conjugacy of suspension flows with different roof functions. The equivalence of Z- and R-action spectra for irreducible Pisot substitutions is drawn from it in the introduction and in the Akiyama–Barge–Berthé–Lee–Siegel survey (2015), §3.4 and §4. | read by a delegated reader; not load-bearing |

Irreducibility is essential for this direction. For reducible
β-substitutions, Ei–Ito give flows with pure discrete spectrum whose
substitutive systems do not have it (Barge 2016 Remark 4.2; survey §4).

**Consequence for §5.** Corollary B′ (§8) and SS02-5.2 together give pure
discrete spectrum of the symbolic system for every primitive Brun composite
with an irreducible Pisot characteristic polynomial, in every dimension
(`docs/sadic-g6-brun-higher-census.md` §5). The periodic-point hypothesis of
BST23 Theorem 3.1 therefore needs only one exact certificate: primitivity,
irreducibility and the Pisot property of one admissible periodic word. The
balanced pair algorithm is no longer needed for it.
