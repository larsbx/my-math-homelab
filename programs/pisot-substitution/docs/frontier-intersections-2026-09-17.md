# Where this program's machinery transfers: nine frontier intersections

**Status:** research-direction note dated 2026-09-17, continuing the outward half of
`docs/cross-pollination-round-two-2026-09-16.md`. Round two compared this program with the user's
other repositories; this one looks outward, at fields of mathematics whose open problems the same
machinery could touch. It proves nothing, promotes no claim, changes no ledger, and states no new
result about the Pisot substitution conjecture or about C1. Markers follow the round-two convention:
`[V]` verified here by reading or executing code in these repositories, `[L]` a literature statement
that must be pinned before any ledger uses it. Repository tags: `PSC:` this repository, `NLAP:`
`larsbx/finite-mandlebrot-research`, `FMK:` `larsbx/finite-math-kernels`.

Every "first move" below is a concrete experiment, not a plan of record.

## 0. What is actually portable

Three engines. Everything else in either program is domain content that does not travel.

### 0.1 The separation calculus `[V]`

A *separation system* is a tuple

    S = (X, T, Σ, sep)

with `X` a finite set, `T : X → X` a map, `Σ` a finite set of *declared* separators carrying an
admissibility tag, and `sep : P₂(X) → Bool` deciding when a separator puts two points on opposite
*open* sides. Write `P` for the least fixpoint

    P₀ = { p ∈ P₂(X) : sep(p) }
    P_{n+1} = P_n ∪ { p : T(p) ∈ P_n }        P = ⋃ₙ P_n

the *productive* pairs, and `N = P₂(X) \ P` the *nonproductive* ones: the pairs no iterate of `T`
ever separates. `T` is a function, so the pair graph has out-degree at most one and every component
of `N` falls into one cycle or terminates at a merging pair (`T` identifies its two points). The
cyclic sinks split by whether the cycle meets a separator endpoint — *boundary* obstruction, the
object may lie on the separation line itself — or never does — *interior*, the prefix is too coarse.

Two instantiations exist and are executed in CI:

| Instance | `X` | `T` | `Σ` |
| --- | --- | --- | --- |
| `PSC: kernel/psc/overlap_seed_patch.mojo`, `overlap_recurrence.mojo` | seed-patch overlap states | one inflation step | coincidence and collar data |
| `NLAP: src/C1_misiurewicz_prefix_graph.mojo` | `Z/den` | doubling | two-ray separators with a landing tag |

The abstraction claim is falsifiable and worth falsifying: *if* the signature above is genuine, one
implementation parameterised over `(X, T, Σ, sep)` reproduces both pinned outputs — `PSC:` the
overlap censuses, `NLAP:` type (1, 3) over denominator 14 giving 12 vertices, 37 undecided, 20
nonproductive, 2 merging, 2 boundary cycles, 0 interior. If it cannot, the resemblance is
superficial and this note's first section is wrong.

### 0.2 The certificate calculus `[V]`

Exclusion (`NLAP: src/interval_orbit.mojo`, `checked_interval_exclusion.mojo`) plus localisation
(`krawczyk_witness.mojo`) over exact dyadic rationals (`FMK: finite_exact`), with three outcomes
kept distinct: accepted, refused for want of resolution, and rejected. A refusal is never read as a
negative — the property that most published computer-assisted arguments leave implicit.

### 0.3 Claim governance `[V]`

`claim_governance.toml` here, the theorem-tag import ledger in `NLAP:`, and `FMK: proof_records`:
machine-checked separation of derived, imported and conjectured, with promotion rules and a risky-
phrase linter over prose.

## 1. Automata theory: distinguishability and separating words

**Transfer out.** `N` above is the complement of a partition-refinement fixpoint. Running Moore's
algorithm backwards from the separated pairs is exactly what `extract` does `[V]`. The question
"how large a separator prefix distinguishes these two points" is the separating-words problem
(Goralčík–Koubek; Robson's `O(n^{2/5})` state bound; Demaine, Eisenstat, Shallit, Wilson) `[L]`.

**Return.** That literature measures the *cost* of a separator. Both programs currently count
separated pairs and never the size of the prefix that separates them, so no statement here is
quantitative in the parameter that field has spent forty years bounding.

**First move.** Report prefix size beside `undecided` and `nonproductive` in both extractors, and
state `PSC: kernel/psc/... ` coincidence density and `NLAP: src/C1_separated_density.mojo` as functions
of it. The flattened-density control already in the density module is the right negative example.

**Difficulty.** Low. The data exists; only the reporting dimension is missing.

## 2. Decision procedures for automatic and substitutive sequences

**Transfer out.** Coincidence conditions, defect degrees and balanced-pair recurrence are first-order
statements about substitutive sequences. Walnut decides such statements for automatic sequences, and
the decidability extends to Ostrowski-type numeration systems attached to quadratic and some Pisot
parameters (Shallit; Hieronymi, Ma, Oei, Schaeffer, Thompson, Shallit) `[L]`.

**Return.** A decision procedure replaces a finite sweep with a theorem about an infinite family. The
4,554-specimen corpus here is finite evidence by construction `[V]`; a decidable fragment would be a
different kind of object entirely.

**First move.** Express the degree-3 coincidence condition for one substitution family in Walnut's
logic and compare its verdict with `PSC: kernel/degree3_catalog.mojo` on the same family. The test is
agreement with the verdicts that census already reports; disagreement is a bug in the encoding, not a
result.

**Started `[V]`.** The engine and the presentation exist: `PSC: kernel/finite_automata/dfa.mojo` (total
deterministic automata with product, complement, subset-construction projection, emptiness with a
shortest witness, Moore minimisation) and `PSC: kernel/psc/dumont_thomas.mojo` (the Dumont-Thomas
numeration of a fixed point as an automaton). `PSC: kernel/automatic_route_census.mojo` checks three
identities per specimen against computations sharing no step: 228 specimens, 68,400 letter
positions, zero mismatches. The formula, the addition automaton and the encoding test are not done,
and `docs/automatic-sequence-route-literature-gate-2026-09-17.md` states exactly what remains and
what would have to be imported.

**Difficulty.** Medium, and the highest-payoff item in this note.

## 3. Shift radix systems and beta-numeration

**Transfer out.** `PSC: kernel/psc/overlap_contracting.mojo` keys a contracting bound on the pair
(characteristic cubic, digit set) — 1,617 distinct pairs over the corpus `[V]`. That pair is the data
of a shift radix system, and the bound is an effective statement about its contraction. SRS
finiteness and periodicity in the cubic region are open (Akiyama, Borbély, Brunotte, Pethő,
Thuswaldner) `[L]`, and the same parameters govern the finiteness property (F) of beta-expansions
`[L]`.

**Return.** That programme computes root isolation numerically; the exact Sturm and Perron layer here
(`PSC: kernel/psc/real_root_sign.mojo`, `perron_field3.mojo`) certifies it.

**First move.** Publish the 1,617 keys as SRS parameters with their certified bounds, and check the
subset where SRS finiteness is known against what the contracting bound gives.

**Difficulty.** Low. The keys are already computed and cached.

## 4. Aperiodic order and diffraction

**Transfer out.** Pure discrete spectrum for a Pisot substitution tiling is equivalent to the tiling
being a regular model set, hence to pure Bragg diffraction (Lee, Moody, Solomyak; Baake, Grimm) `[L]`.
The contracting bound is an effective window statement, and effective constants are what that
literature usually lacks.

**Return.** Meyer-set and almost-periodicity criteria are alternative finite witnesses this program
does not currently extract.

**First move.** State the contracting bound as a window-regularity constant for one worked specimen
and compare it with the qualitative statement in the literature.

**Difficulty.** Medium; the translation of the constant is the work.

## 5. Computer-assisted proof in dynamics

**Transfer out.** Section 0.3. Validated-numerics proofs — Tucker on Lorenz, CAPD, KAM tori,
renormalisation — are published as a paper plus a code artefact, with the derived/imported boundary
carried in prose `[L]`. The theorem-tag ledger and the refusal-versus-negative discipline are exactly
the missing layer, and they are independent of either conjecture here.

**Return.** Decades of craft in interval-arithmetic proof design, and a community that would review
the governance layer adversarially.

**First move.** A standalone methodological note: the tag vocabulary, the three-outcome discipline,
and the two audits that enforce them, written for readers who have never seen either conjecture.

**Started `[V]`.** `FMK: docs/provenance-for-computer-assisted-proof.md`: the three distinctions
prose blurs, the three outcomes, the five record kinds, the five policy checks, and four adoption
steps, with two real incidents as calibration.

**Difficulty.** Low, and the machinery already exists.

## 6. Complex dynamics: puzzles, laminations, local connectivity

**Transfer out.** The separator prefixes of `NLAP:` are puzzle-piece separations in combinatorial
form, and the decided measure is a Lebesgue-measure proxy for what puzzle depth achieves `[V]`.

**Return.** Thurston's quadratic minor lamination supplies co-landing data as a *theorem* rather than
as a declared tag `[L]`; adopting it would discharge the admissibility hypothesis on a large class of
prefixes instead of assuming it per instance. Yoccoz puzzle geometry also suggests principled
separator families, where the current prefixes are periodic orbits chosen for being disjoint from the
catalogue.

**First move.** Derive one prefix from lamination data instead of declaring it, and rerun the
extractor on type (1, 3); the counts either reproduce or the derivation is wrong.

**Difficulty.** High, and the most valuable of the high-difficulty items.

## 7. Arithmetic dynamics and height theory

**Transfer out.** Misiurewicz parameters are algebraic, and an exclusion certificate is an explicit
dyadic box in which no forbidden collision occurs `[V]` — effective separation data attached to a
Galois-stable object (box, polynomial, collision set).

**Return.** Unlikely-intersection and equidistribution results in arithmetic dynamics (Baker–DeMarco,
Favre–Gauthier) are usually ineffective `[L]`; a calculus that outputs explicit boxes is the shape of
input that could make an instance effective.

**First move.** Convert one exclusion box into an explicit lower bound on the distance between two
algebraic parameters of bounded type, and compare with the height bound the literature gives.

**Difficulty.** High; the translation from box to height is the mathematics.

## 8. Formal verification

**Transfer out.** `FMK: proof_records`, exact Sturm sequences, and interval arithmetic are
transportable; Lean's mathlib has all three thinly `[L]`.

**Return.** A checked certificate becomes a theorem about a specific box, in a system with no trusted
Mojo runtime in its kernel.

**First move.** Export one exclusion box and one Sturm witness as Lean terms. Not the conjectures —
the certificates.

**Difficulty.** Medium.

## 9. Combinatorics on words: piecewise testability

**Transfer out.** `PSC: kernel/psc/defect_degree.mojo` computes the level at which two words become
inequivalent for scattered subwords `[V]`. That level is Simon's congruence, and the same invariant
governs `k`-piecewise testable separability of languages, an active topic (Place, Zeitoun) `[L]`.

**Return.** Separation problems for language classes are the same question asked of a different `T`;
the vocabulary differs, the object does not.

**First move.** State `first_defect_degree` as a Simon-congruence level and check the degree-2 and
degree-3 sieves against the standard characterisation on the corpus.

**Difficulty.** Low.

## 10. Ranking

| Intersection | Effort | Payoff | Character of the payoff |
| --- | --- | --- | --- |
| §2 decision procedures | medium | very high | converts finite evidence into a theorem about a family |
| §6 laminations for separators | high | very high | discharges the admissibility hypothesis rather than assuming it |
| §5 CAP provenance | low | high | methodological, publishable now, independent of both conjectures |
| §3 shift radix systems | low | high | certified constants for an open programme |
| §8 Lean certificate export | medium | high | removes a trusted runtime from the chain |
| §7 heights | high | high | effective input to an ineffective literature |
| §1 separating words | low | medium | the missing quantitative dimension |
| §9 piecewise testability | low | medium | vocabulary alignment, immediate |
| §4 diffraction constants | medium | medium | constants where the literature is qualitative |

## 11. Non-claims

This note proves nothing. No intersection above is a result, and none changes the status of
`OverlapProductivity`, of the Pisot substitution conjecture, or of C1. Every `[L]` statement is a
literature claim that must be pinned in the ordinary way before any ledger cites it. The abstraction
of section 0.1 is a conjecture about this repository's own code, and section 0.1 says how to refute
it.
