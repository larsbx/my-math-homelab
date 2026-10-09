# EXACT BD CONVENTION, EXHAUSTIVE b₁ CENSUS, AND THE BACKWARD-BRANCHING ADJUDICATION (2026-06-13)

**Headline: (1) the proxy BD gluing is replaced by the exact BBJS/BD3 convention, read at
source, with a free connectivity corollary verified 4,554/4,554; (2) the exhaustive k=3 b₁
census supersedes the 150-specimen proxy (support {0,1,2,4} confirmed; 68.1% loop-free;
1,740 unimodular homological-Pisot specimens = the unconditional cr≥3 stratum); (3) the
queue's "backward branching" target (STRATA §5(i)) is ADJUDICATED AGAINST as stated —
branching is automatic in any trapped component and recognizability does not bear on it
(ledger correction); the refutable object is b₁(G₀^ER(Σ_C)) = closed ALTERNATING chains of
branchings; (4) a new conditional placement: unimodular PSC ⟸ Q-A + CRC, via an
unconditional Leg-Factor Lemma giving cr(Σ_C) ≥ 2 for every trapped component.**

## 1. The exact convention (BBJS §2, read at source this session; supersedes the proxy)

Barge–Bruin–Jones–Sadun, Israel J. Math. 188 (2012) [arXiv:1001.2027], citing BD3
(Barge–Diamond, Proc. AMS 136 (2008)):

- G: one edge e_i per letter, one edge v_ij per legal 2-word a_i a_j. Gluing: end(e_i) ≡
  begin(v_ij), end(v_ij) ≡ begin(e_j). Hence **G₀ (the v-edges alone) is BIPARTITE**:
  v_ij runs out_i → in_j, and **out_i ≠ in_i** (e_i is not in G₀). Any convention that
  identifies end_i with begin_i is wrong.
- Substitution on G₀: v_ij ↦ v_kl, k = last(σ(a_i)), l = first(σ(a_j)). G₀^ER = eventual
  range; the substitution permutes its edges.
- Exact sequence: 0 → H̃⁰(G₀^ER) → lim→ A^T → Ȟ¹(Ω_φ) → H¹(G₀^ER) → 0, every map
  commuting with substitution; image of H̃⁰ lies in the +1 eigenspace of A^T.
- dim Ȟ¹ = d iff (1) spec(A^T) ⊆ {0, 1} ∪ {λ and conjugates}; (2) alg. mult of
  eigenvalue 1 = #components(G₀^ER) − 1; (3) G₀^ER loop-free.

**Connectivity corollary (PROVED, new to our ledger).** For an irreducible Pisot
substitution, 1 is not an eigenvalue of A (the char poly is the irreducible minpoly of β;
1 is neither β nor a conjugate, all of which lie in the open unit disk; this persists for
every power by the Pisot field identity). The +1 eigenspace of (A^T)^N is therefore 0, so
H̃⁰(G₀^ER) = 0: **G₀^ER is connected for every irreducible Pisot substitution**, and

    dim Ȟ¹(Ω_σ, ℚ) = k + b₁(G₀^ER),   homological Pisot ⟺ b₁ = 0 ⟺ no asymptotic cycles.

This is also a per-specimen implementation validator: C ≠ 1 on an irreducible specimen
would falsify the instrument or the reading. Observed violations: 0/4,554.

For the trapped Σ_C (reducible, χ_A·q(x)), connectivity is NOT free; all three conditions
are live for Q-A.

## 2. Instrument and census (exhaustive; proxy SUPERSEDED)

Instrument `bd_exact.py` (pure functions, exact set/integer arithmetic): legal 2-words via
crossing-map closure; ER via nested image stabilization; b₁ = E − V + C on the bipartite
incidence; ER permutation cycle type. **Validation gate 4/4 before corpus use**: Fibonacci
(C=1, b₁=0 ✓), Tribonacci (C=1, b₁=0 ✓), BBJS's asymptotic-cycle specimen 1↦21112, 2↦121
(C=1, b₁=1, dim H¹ = 3 ✓ against the paper's stated value), and BBJS Example 1 φ₂
(6-letter, reducible, cr=3 triple cover: C=3, b₁=0 ✓ against "3 components, each
contractible"). Hand-verification of the corpus extremal (idx 1746, ER = K₃,₃, cycles
(3,6), b₁ = 4) exact.

Census `bd_census.py`, full exhaustive k=3 |σ(a)| ≤ 3 PIP corpus (4,554 specimens — no
sampling; the proxy's 150-specimen stratification is obsolete):

| | b₁=0 | b₁=1 | b₁=2 | b₁=4 | total |
|---|---|---|---|---|---|
| all PIP | 3,102 (68.1%) | 552 | 720 | 180 | 4,554 |
| \|det\|=1 | **1,740** | 396 | 408 | 84 | 2,628 |
| \|det\|=2 | 1,362 | 156 | 312 | 96 | 1,926 |

- Support is exactly {0, 1, 2, 4}; b₁ = 3 is absent. (b₁ ≤ 4 = b₁(K₃,₃) is the k=3
  ceiling, attained 180 times. The absence of 3 is an OBSERVATION, k=3 |σ(a)|≤3 only;
  no derivation; do not build on it.)
- Proxy calibration: proxy reported 99/150 = 66% loop-free with support {0,1,2,4};
  exact exhaustive gives 68.1%, same support. Proxy direction confirmed at aggregate
  level; proxy retired.
- ER permutation cycle types (asymptotic-orbit periods of σ): max period 6; full
  distribution in `bd_rows.jsonl`.
- **The cr ≥ 3 triple import (LITERATURE_CONTACT_MAP §2a) is now exhaustively scoped:
  it is unconditional on exactly 1,740 of the 2,628 unimodular k=3 specimens** (the
  homological-Pisot stratum). On the 888 unimodular b₁ > 0 specimens, dim Ȟ¹ = 3 + b₁ > 3,
  σ is not homological Pisot, and B15's cr ≠ 2 exclusion does not apply as stated — the
  Barge–Olimb extension question (queue) is exactly about this stratum.

## 3. ADJUDICATION: STRATA §5(i) "backward branching" — RETRACTED AS A TARGET (ledger correction)

The ledgered framing was: *"two trapped pasts of one tail, all inside a finite C, against
Mossé/BSTY recognizability of Σ_C — the most refutable-looking statement now on the
board."* This is wrong on both counts.

**(a) Backward branching is automatic.** X_{Σ_C} is a primitive aperiodic substitution
subshift (primitivity by normalization, Thm 6.7; aperiodicity because a periodic
transversal would decode to flow-periodic σ-tilings via the leg map of §4, and Ω_σ has
none). Every primitive aperiodic substitution subshift contains right-asymptotic pairs —
classical, and for substitutions they are classified and finite in number (Barge–Diamond
2001). Every point of the hull of τ decodes to a fully trapped pair (all letters are
C-states; coincidence letters are excluded by noncoincidence of C; unit-step compatibility
passes to the closure). Hence a right-asymptotic pair x ≠ y of X_{Σ_C} IS "two trapped
pasts of one tail" — present in every hypothetical trapped component without exception.
The statement has zero discriminating power: it can be neither refuted (it is a theorem,
given a trapped component) nor used as an over-constraint.

**(b) Recognizability was misattributed.** Mossé/BSTY recognizability of Σ_C says
desubstitution is unique (the substitution map on the hull is injective up to the natural
identifications). It is compatible with — and coexists with — asymptotic pairs in every
known primitive aperiodic substitution. The session-note intuition conflated *uniqueness
of preimage under inflation* with *backward determinism of the shift*. They are unrelated.
Logged so the route is not re-attempted.

**(c) The correct refutable object.** Per the now-pinned machinery, what obstructs Q-A
condition (3) is not branching but a **loop of G₀^ER(Σ_C)**: a closed ALTERNATING chain

    v_{s₁t₁}, v_{s₂t₁}, v_{s₂t₂}, v_{s₃t₂}, …, v_{sₙtₙ}, v_{s₁tₙ}

of ER 2-words of the transversal language — branchings (shared in-vertices: two distinct
cells that can precede a given cell; shared out-vertices: two distinct successors) closing
up into a cycle of the bipartite incidence. A single branching is free; b₁ > 0 requires a
closed chain of them, all 2-words in the EVENTUAL RANGE (i.e., surviving infinite
desubstitution). Q-A.3 ⟺ b₁(G₀^ER(Σ_C)) = 0.

Structure available for the attack, carried over intact: every ER edge has a static I/J
type (Lemma 6.9: exactly one letter changes across a trapped-transversal boundary), the ER
permutation preserves type (Lemma 6.11) and fibers per type over σ's own (connected,
loop-free on the b₁(σ)=0 stratum) base complex. The type-pure subgraphs fiber over the
base; **the genuinely new hazard is type-MIXED alternating cycles**, which the
fibering does not see. This replaces queue item (i).

## 4. New: the Leg-Factor Lemma and the stakes of Q-A (CANDIDATE → companion-grade after one more pass)

**Lemma (Leg factor).** Let C be a trapped component of a PIP σ, normalized as in Thm 6.7,
Σ_C its transversal substitution. Then (Ω_{Σ_C}, ℝ) factors onto (Ω_σ, ℝ).

*Proof.* A transversal tiling S in the hull assigns to ℝ a cell sequence with widths w(s).
Boundary types are well defined (Lemma 6.9; no shared cuts in a trapped transversal). Merge
maximal runs of cells between consecutive type-I boundaries and label each merged tile by
the common i-letter; locally every patch of S is a translate of a patch of τ, where the
merged tiles are exactly the I-grid tiles of the frozen ray (widths summing to L_i), so the
merged object is locally allowed for σ and π₁(S) ∈ Ω_σ. Type-I boundaries are syndetic
(each I-tile has length ≤ L_max, cells have width ≥ min w > 0). π₁ is a local rule, hence
continuous, and commutes with translation; its image is a nonempty closed invariant subset
of the minimal Ω_σ, hence all of Ω_σ. ∎

**Corollary (unconditional).** cr(Σ_C) ≥ 2 for every trapped component. (cr(Σ_C) = 1 ⟺
Ω_{Σ_C} has PDS [BK/BBK, applicable since the dilatation of Σ_C is the Pisot β]; PDS
passes to factors; Ω_σ is a factor; but σ carries a trapped component, hence ¬OC, hence
¬PDS by Akiyama–Lee.)

**Conditional chain (placement, not progress on the open core):** suppose σ is UNIMODULAR
and non-PDS. Then a trapped component exists (failure of overlap coincidence produces the
leak ≡ 0 shape; companion Rmk 3.9 / Thm 2.2), and the dilatation β of Σ_C has norm ±1.

- **Q-A alone** (Σ_C homological Pisot): B15's theorem (odd norm excludes cr = 2 for
  homological Pisot) upgrades the corollary to **cr(Σ_C) ≥ 3**.
- **Q-A + CRC** (CRC applied to Σ_C: "the tiling flow of a unimodular homological Pisot
  substitution has pure discrete spectrum"): Ω_{Σ_C} has PDS ⟹ Ω_σ has PDS —
  contradiction. **Hence unimodular PSC ⟸ Q-A + CRC.**

Honest placement: CRC is open precisely in the cr ≥ 3 regime this chain lands in (proved
only d=1 and cr=2), and Q-A is open; this transfers the unimodular conjecture into the
orbit of the topological (homological-Pisot/CRC) program rather than resolving anything.
But it makes Q-A's stakes exact, and it is the first chain on our board in which the
trapped shape is attacked through invariants of Σ_C itself rather than of σ.

Promotion path: the Leg-Factor Lemma and corollary are proof-complete at note grade; one
adversarial pass (the "locally a translate of a patch of τ" step should be written against
the precise hull definition, and the ¬OC ⟹ trapped-component step cited to [2,3] with the
power-normalization spelled out) before merging into companion v8 alongside §1–§3 here.

## 5. Caveats (standing discipline)

- The census is elimination on σ's own complex; b₁(σ) bears on which literature applies
  to which specimen, not on uniform H3′. No census evidence can bear on uniform Q∞.
- BD3 itself was not re-read; the exact sequence and conventions are taken from BBJS's
  statement of it (read in full at source). One-step provenance, flagged.
- The b₁ = 3 absence and the cycle-type table are sampled-corpus observations at
  k=3, |σ(a)| ≤ 3 only.
- The Q-A/CRC chain is conditional two conjectures deep; nothing in it proves PSC or
  uniform trapped anchoring; the no-coarse-quotient meta-theorem still governs the
  positional residue.

## 6. Queue (replacing STRATA §5)

1. **Q-A.3 sharpened:** type-mixed alternating cycles of G₀^ER(Σ_C) — can the fibering
   over σ's loop-free base (b₁(σ)=0 stratum) together with cut-disjointness exclude them?
   The fiber-monodromy lever (×β orbit coding) now applies per type-pure segment.
2. **Barge–Olimb caveat, now exactly scoped:** the 888 unimodular b₁>0 specimens; read
   Barge–Olimb at source for the asymptotic-cycle extension of the cr machinery.
3. Companion v8 merge: §1 connectivity corollary, §2 census table, §3 adjudication
   (as a remark correcting the Q-A.3 formulation), §4 Leg-Factor Lemma + corollary +
   conditional chain (after the adversarial pass).
4. Q-B triple geometry unchanged (the triple stratum is now the 1,740-specimen-calibrated
   unconditional shape).
5. k=4 b₁ census with the same instrument (k-general already; gate on a k=4 hand case
   first).

## Artifacts

`bd_exact.py` (gated instrument), `bd_census.py` (driver, gate-on-every-run),
`bd_rows.jsonl` (4,554 rows: idx, images, det, ER size, components, b₁, perm cycle type).
