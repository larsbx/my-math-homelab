# Methodology: attacking a generalization from an existing programme

**Status:** planning methodology. This document is not a proof source. It states
no theorem and moves no claim status. Every literature statement in it is a
*candidate import* until it passes a literature gate (§3, G0).

## 1. Setting

There is a **parent programme** 𝒫: a conjecture `C_P`, its proved and imported
results, and its exact infrastructure (kernels, oracles, census corpora, a claim
ledger, a proof plane). There is a **generalization** 𝒢: a conjecture `C_G` over a
parameter space `Ω`. A **specialization map** `ι : P-instances → Ω` sends parent
instances to the special points of `Ω`, and `C_G ∘ ι ⇒ C_P` on the regime where
the hypotheses match.

The method rests on three premises:

1. **Do not restart.** 𝒢 inherits 𝒫's governance and executable kernels by
   vendoring them, never by copying.
2. **Look for a reduction lever.** Known theorems for 𝒢 often reduce a claim
   over `Ω` to finitely many 𝒫-type checks on finite data. Those checks are what
   the existing kernels already decide.
3. **Separate truth from proof target.** A 𝒫-result transfers to 𝒢 only through
   an explicit ledger entry, with the hypothesis it needs (§3, G4).

## 2. Invariant rules

These rules hold in every phase.

- **R1. Status vocabulary.** The vocabulary is the parent's: proved, imported,
  finite-domain, conditional, open, bridge, evidence, retired. Every statement
  carries exactly one status. Changing a status means changing it on every
  surface in the same commit.
- **R2. Exact or labelled.** A decision is made in exact arithmetic or by a
  finite certificate. Floating-point output (Lyapunov exponents, spectra,
  pictures) is *evidence* and never enters an exact kernel.
- **R3. Fail closed.** A budget-exhausted or capped computation is
  *inconclusive*. It is never read as a counterexample or as a proof.
- **R4. Hypothesis fidelity.** An import carries its exact hypotheses. A
  hypothesis that 𝒫 derives may not be silently assumed in 𝒢, and a hypothesis
  of 𝒢 may not be silently dropped. Known counterexamples to the unrestricted
  statement are recorded as negative controls.
- **R5. Test first, with an oracle.** Every kernel module is preceded by its
  regression tests and paired with an independently written reference oracle.
  Cross-language disagreement fails closed.
- **R6. Library before repository.** A primitive needed by two repositories is
  extracted to the shared kernel library and vendored. It is never duplicated.
- **R7. Novelty gate.** Before a tool or result is called new, it passes a
  literature and novelty audit.

## 3. Phases

Each phase ends in a mergeable unit with its exit criterion met.

| Phase | Goal | Output | Exit criterion |
|---|---|---|---|
| **G0 Literature gate** | Fix the precise statements of `C_G` and its known partial results | Gate document: per-result hypothesis table, then a matrix of results (proved / a.e. or generic / numerical / open) over 𝒢's natural sub-families | Every citation the plan relies on is pinned with its hypotheses; at least one open cell is chosen as the target |
| **G1 Scaffold** | Inherit 𝒫's governance | Estate manifest, claim-governance policy with 𝒫's vocabulary, vendoring manifest, build workspace, CI | Governance audit passes on an empty kernel |
| **G2 Embedding** | Make `ι` executable and inherit 𝒫 at the special points | Kernel for 𝒢's objects, plus a test that `ι` followed by 𝒢's kernel equals 𝒫's kernel | 𝒫's corpus reproduces bit-for-bit through `ι` |
| **G3 Reduction lever** | Identify and gate the theorem that reduces `Ω`-claims to finite 𝒫-type checks | Imported-theorem entry with exact hypotheses; drivers that run 𝒫's deciders on the finite data it names | The lever's hypotheses are checkable or certifiable by kernel predicates (R2) |
| **G4 Transfer ledger** | Classify each 𝒫-claim as *lifts*, *lifts with hypothesis H*, *fails* (with witness) or *unknown* | Ledger file plus prose; first proof targets drawn from the *lifts with hypothesis* entries | Every load-bearing 𝒫-claim is classified |
| **G5 Uniform certificates** | Lift 𝒫's finite-state objects to finite skew products over a finite presentation of `Ω` (an automaton, a sofic shift or a cylinder partition) | One finite certificate covering every point of the presented subspace; it restricts to 𝒫's object at special points | Regression: the restriction equals 𝒫's construction |
| **G6 Censuses** | Exhaustive finite-domain theorems and calibrated evidence | Census drivers over 𝒢's natural families, negative controls included | Negative controls never certify; positive results are stated as finite-domain theorems |
| **G7 Formalization** | Move the smallest load-bearing lifts into the proof plane | Lean statements and proofs, and the dependency model updated | Ledger statuses agree with the proof plane |

Ordering: G0 and G1 come first and can run in parallel. G2 precedes G3–G6. G4
selects the targets of G5 and G7. G6 runs continuously from G2 onwards.

## 4. Choosing targets

Rank candidate targets by **leverage ÷ cost**.

- **Leverage.** The best targets turn a claim over all of `Ω` into finitely many
  checks (G3, G5). Next come targets that make a 𝒫-necessary condition
  𝒢-necessary, because an infinite certificate object then *refutes* `C_G`.
  Last come those that discharge a whole sub-family cell of the G0 matrix.
- **Cost.** Prefer targets whose primitives already exist in the shared library,
  and lifts whose 𝒫-proof uses only one hypothesis that 𝒢 replaces by a standing
  assumption.

The first unit of work is always G0 + G1, then the smallest G2 slice that a known
G0 result can calibrate.

## 5. Instantiation: 𝒫 = PSC, 𝒢 = S-adic Pisot

| Methodology slot | This repository |
|---|---|
| 𝒫 | `larsbx/pisot-substitution-conjecture-research` (PSC) |
| Shared library | `larsbx/finite-math-kernels`: `substitution_dynamics` (including `sadic`, the balanced pair algorithm, strong coincidence, discrepancy), `finite_linear_algebra`, `finite_polynomial`, `root_isolation` |
| `Ω` | Directive sequences `σ ∈ 𝒮^ℕ` over a finite set 𝒮 of unimodular substitutions, possibly restricted to a sofic directive shift (Brun, Arnoux–Rauzy, Cassaigne, Jacobi–Perron, Selmer, …) |
| `ι` | Periodic directive sequences ↦ substitutive systems, via composites `σ_[k,k+ℓ)` |
| Standing hypotheses (R4) | Primitivity, recognizability, algebraic irreducibility, C-balance, the Pisot condition. Negative controls: unbalanced Arnoux–Rauzy words (Cassaigne–Ferenczi–Zamboni) and non-Pisot algorithms (Poincaré) |
| G3 lever (gated, `docs/literature-gate-2026-10-09.md`) | BST23 Theorems 3.1/3.5: the Pisot condition plus one periodic point whose substitution has pure discrete spectrum gives a.e. pure discrete spectrum for the algorithm. The periodic-point input is a balanced-pair decision on a composite. BST19 Theorem 3.1 (tiling iff geometric coincidence) is the every-sequence counterpart |
| G4 first targets | **T1:** uniform C-balance and a bounded length ratio ⇒ a finite pool of overlap type triples along the shift orbit (lift of PSC PR #72). **T1′:** BST19 Theorem 3.1 ⇒ a finite type pool at selected PRICE return depths. All-depth transition finiteness remains open. **T2:** does "PDS ⇒ G1" lift to "PDS ⇒ the uniform graph is finite"? |
| G5 object | Uniform S-adic balanced-pair graph on (directive-automaton state, irreducible balanced pair); it restricts to the stationary BPA at periodic points |
| G2 exact predicates | Prefix primitivity, irreducibility and the Pisot property of `M_[0,n)`, C-balance, cone-contraction certificates. Lyapunov exponents are evidence only |
| G6 censuses | Periodic directive words up to length L per algorithm; uniform graphs on the algorithms' sofic shifts |

G0 is done in `docs/literature-gate-2026-10-09.md`: hypothesis table, status matrix, and the open cells the lever reaches (Selmer d = 4; Brun and Jacobi–Perron 5 ≤ d ≤ 10).

**Progress.**

- **G0:** done (`docs/literature-gate-2026-10-09.md`), with a §5 addendum.
  Selmer `d = 4` needs a substitutive realization before the BST23 lever
  applies.
- **G1:** done.
- **G2:** done.
  - `docs/sadic-kernel-g2-slice.md`: directive shifts, the cocycle, positive
    blocks, `Θ`, balance lower bounds.
  - `docs/sadic-kernel-g2-spectrum.md`: exact irreducibility and Pisot
    certificates, primitivity by Wielandt, periodic admissibility. The `ι`
    regression reproduces PSC's 4,554-substitution corpus.
  - C-balance can still only be refuted, never certified, by a finite run.
- **G3:** calibrated on Brun `d = 4` (`docs/sadic-g3-brun4-census.md`).
  BST23's periodic-point certificate is replicated, and all 6,386 primitive
  irreducible Pisot periodic points of period ≤ 8 pass the balanced pair
  algorithm.
- **G3 on open cells:** see `docs/sadic-g6-brun-higher-census.md`.
  - Theorem B places every primitive Brun composite, in any dimension, in
    the mirror Barge class. So every Pisot periodic Brun point has a tiling
    flow with pure discrete spectrum (Corollary B′).
  - Theorem C: for Brun with `d = 5, 6, 7`, the Pisot condition is the only
    missing input of BST23 Theorem 3.1. A periodic point that passes the
    balanced pair algorithm is pinned for each `d`.
  - Corollary B″: Sirvent–Solomyak 2002 Corollary 5.2 (gate §9) transfers
    B′ to the symbolic system for every irreducible Pisot composite.
    Theorem C′ extends Theorem C to every `5 ≤ d ≤ 10`, using one pinned
    primitive irreducible Pisot periodic point per dimension.
- **G4:**
  - Lemma S and Theorem T1 are proved under uniform balance and a bounded
    length ratio (`docs/t1-uniform-overlap-finiteness.md`).
  - T1′ bounds the swap-pair overlap types at selected PRICE return depths
    using BST19 Theorem 3.1's hypotheses only. Lemma P bounds their length
    ratios from PRICE's fixed positive suffix.
    The finite pool does not yet give a closed finite transition graph,
    and the all-depth extension is open.
  - Theorem W gives a conditional all-depth type pool from bounded-gap
    balanced positive-suffix anchors (`docs/all-depth-bounded-anchors.md`).
    Lemma M propagates balance across the bounded windows. Lemma G shows
    that bounding gaps in growing PRICE returns would force periodicity,
    so those returns cannot supply the desired nonperiodic extension that
    way. The additional anchor condition is not derived from BST19.
    Corollary A supplies a nonperiodic Arnoux–Rauzy calibration, using
    Thue–Morse-directed blocks 012 and 021 and BST19's uniform balance bound.
  - T2 is not started.
