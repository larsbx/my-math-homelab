# Stop/go: closing Theorem K's excursions by a counter reading, then by monotone crossings — 2026-10-06

Targeted literature check (AGENTS.md review gate) for the next step on the
residue of Theorem K's family that
[`p1a-a1-prime-2026-10-05.md`](p1a-a1-prime-2026-10-05.md) §3i leaves: members
whose walks part at `t = 1` and do not meet again (single excursions).

## 1. The proposed claim and experiment

*Proposed first.* Read `w_1` and `w_2` in lockstep with the height
`h(t) = #y(w_1[:t]) − #y(w_2[:t − 1])` as a counter. The level-2 state of the
main witness family is `(w_1[t], w_2[t − 1], (1 − h(t))(e_z − e_y))`, so a
one-counter machine over the letter pairs would decide every member at once,
and its reachability question would be the finite certificate.

*What the experiment became* (§4): a closure lemma for monotone lattice paths,
read only at endpoints (Lemma X), plus a structure lemma for the longer word
(Lemmas Φ5 and Φ5′), measured by how much of each word a certificate must
reveal.

## 2. Prior art and terminology

| Source | What it gives | Transfers? |
| --- | --- | --- |
| C. Haase, S. Kreutzer, J. Ouaknine, J. Worrell, *Reachability in succinct and parametric one-counter automata*, CONCUR 2009, LNCS 5710, 369–383 | reachability for one-counter automata with binary updates is NP-complete; the parametric version asks for a parameter valuation | **no**: it needs one fixed automaton; here the machine depends on the member, and its closures compare the words at a *lag* `c (Delta + s)` that grows with the counter (§4), which no lockstep one-counter reading expresses |
| F. Klaedtke, H. Rueß, *Monadic second-order logics with cardinalities*, ICALP 2003 (Parikh automata) | automata with semilinear constraints on Parikh vectors; emptiness decidable | **only the warning**: "every member closes" is a ∀∃ statement over two words with Parikh-prefix equalities, the universality side, which is not decidable in general for such models |
| V. Berthé, J. Bourdon, T. Jolivet, A. Siegel, ETDS 36 (2016), [arXiv:1401.0704](https://arxiv.org/abs/1401.0704) | a finite certificate for an infinite family of Pisot products | the idea of a finite certificate transfers, as before (swap-family gate) |
| A. Livshits; V. Sirvent, B. Solomyak (balanced pair algorithm) | coincidence decided per substitution by balanced pairs | per member only; the repository's `coincidence_level` already decides per member |
| Discrete intermediate value theorem for lattice paths (folklore; used in Lemma Φ2) | a function changing by at most 1 per step that changes sign has a zero | **yes**: Lemma X is this argument applied to two monotone paths |

Terminology: a *common point* and the height `h` are as in the A1′ note §3g;
*excursion* means `h < 0` after `t = 1`.

## 3. Hypotheses that transfer, and those that do not

- **Transfers:** Pisot type and non-crossing, as in Lemmas Φ4–Φ5; monotone
  walks (every step is `e_y` or `e_z`), which is all Lemma X needs.
- **Does not transfer:** a fixed finite automaton (the one-counter results);
  any lockstep reading (closures are lagged).

## 4. Known negative controls, and what the measurements showed

- *Lockstep is not enough.* The shortest witnesses (Mojo census, residue at
  `|w_i| <= 9`) close at level 3 by `W_a(i) − W_b(k) = c delta`, with
  `i − k = c (Delta + s)`: a lagged comparison, not a lockstep one.
- *Touching is not crossing.* Crossings certified from endpoints alone cover
  86% of the many-run residue at length 9 from the main anchor; the rest
  meet only where the walks touch, which no endpoint data certifies unless a
  range ends inside the word, where a weak end inequality suffices (Lemma X).
- *A bounded prefix is not enough.* With Lemma X at run boundaries, the
  number of runs a certificate must reveal grows with the length (to 7 in a
  seeded sample at lengths 30–40) until the longer word's suffix is revealed
  by Lemma Φ5 (`s = +1`) or Lemma Φ5′ (`s = −1`), and for `s = −1` the
  lagged cut points are added. Then the kernel census (`reveal_census`)
  needs at most 2 runs through length 10 exhaustively and at most 4 in
  seeded samples at lengths 40–60 (A1′ note §3j).

## 5. Decision

**Redirect, then proceed narrowed.** The one-counter route stops: its
machinery does not apply to a member-dependent, lagged system. The route it
turned into — Lemma X at revealed boundaries and cut points, with the suffix
lemmas — proceeds. Its target is a finite cover of the run patterns. No
novelty is claimed for the intermediate value argument; it is the one behind
Lemma Φ2. What is new is the specialization: the certificate reads only
endpoints, so it can cross opaque tails. No claim is made beyond what the
exact cover establishes; the measured bounds are evidence, labelled with
their budgets.
