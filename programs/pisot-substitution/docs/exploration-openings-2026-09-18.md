# Openings: where the exploration has room, measured

**Status:** research-direction note dated 2026-09-18. It proves nothing,
promotes no claim, registers no ledger entry, and changes no status surface.
It records what was measured while asking which axes of this programme are
still open, and what each one would cost. Markers: `[V]` measured here by
executing the oracle layer of this repository, `[P]` a proposal with no
measurement behind it yet.

Every "first move" below is an experiment, not a plan of record. Nothing here
is asserted for any domain wider than the exact 4,554-member corpus declared
in `tools/corpus_refinement.py`.

## 0. Why this note exists

`docs/unimodular-route-gate-2026-09-17.md` declined one axis, the determinant,
after measuring that it separates the two live obstructions in opposite
directions. The same question can be asked of the other axes, and asking it
turned up four measurements worth recording and two proposals worth naming.
Two of the measurements are anomalies rather than openings: they say that a
statistic this repository reports is not the invariant its name suggests.

## 1. Seed choice is a free parameter that nothing currently measures `[P]`

Manuscript Theorem 5.38 needs **one** swap seed to have only productive
reachable overlaps. Every executable here builds the union over all three
unordered pairs: `psc.overlap_seed_patch` seeds from each pair `a < b`, and
`docs/p1-overlap-seed-growth-bridge-2026-09-17.md` §1 states its contract
"over all unordered seed pairs". The ledgers already record that all-seed
productivity is stronger than the theorem needs
(`docs/proof-ladder.md`, research discipline item 5).

So the gap between what is proved about and what is needed has never been
measured. The open questions are per-seed, and the union answers none of them:

- does the zero-shift-free recurrent structure depend on which pair seeds it;
- is there a substitution-independent rule choosing a seed whose graph has no
  zero-shift-free recurrent SCC;
- for the specimens whose union graph carries the deepest coincidence, is the
  depth attained at every seed or at one.

**First move.** A per-seed census: build the graph from one pair at a time and
tabulate, per specimen, the three per-seed answers against the union answer. The
seeding loop already ranges over pairs, so this is a restriction of an existing
driver rather than new machinery. A rule that picks a good seed would attack
the open premise directly; a measurement showing the three seeds always agree
would close the question and is worth as much.

## 2. The corpus determinant range is an artifact of the image-length cap `[V]`

Extending the screen to images of length at most four, on the same three
letters and with the same exact Sturm screening:

| domain | specimens | determinants that occur |
| --- | --- | --- |
| image length at most 3 (the declared corpus) | 4,554 | `-1, +1, +2` |
| image length at most 4 | 135,990 | `-2, -1, +1, +2, +3` |

The larger domain is 29.9 times the declared one, and its 135,990 members split
`-2: 11,040`, `-1: 19,368`, `+1: 32,196`, `+2: 53,586`, `+3: 19,800`, with
131,436 of them reaching the new length bound.

The consequence is about scope, not about strength. `|det M| = 3` and
`det M = -2` do not occur at image length three at all, so no finite-domain
certificate in `claim_governance.toml` has ever been evaluated on them, and
neither has any exact census. The firewall's standing warning against treating
a finite corpus as complete (`README.md`, generality firewall item 8) currently
has no measurement behind it in either direction: nothing says the statistics
saturate, and nothing says they grow.

**First move.** Run the seed-patch overlap census on the 30,840 specimens with
`|det M| = 3` or `det M = -2` — the regime that is new rather than merely
larger — and compare the depth, separation-radius and graph-size distributions
against the declared corpus. Growth there would give firewall item 8 its first
evidence; saturation would be the first quantitative reason to believe the
declared corpus is representative. A full run over all 135,990 is the same
experiment at roughly thirty times the cost and should follow, not lead.

## 3. The corpus is about twelvefold redundant, and two statistics are not invariants `[V]`

The symmetry group already implemented in `psc.symmetry` — relabelling by `S_3`
acting by conjugation, together with word reversal — acts on the corpus with

- **384 orbits** under relabelling and reversal, of sizes `12` (375 orbits) and
  `6` (9 orbits), mean orbit size 11.86;
- **759 orbits** under relabelling alone;
- `det M_sigma` constant on every orbit, as conjugation and reversal both
  preserve it.

Twelvefold redundancy is the budget that section 2 needs. But the audit that
would license deduplication turned up two things first, and they are the more
interesting half of this section. Restricting to the 2,628 unimodular
specimens, where each was classified by whether the extractor of
`psc.overlap_affine_pump` returns a zero-shift-free cycle and by the size of
its seed-patch overlap graph:

| grouping | classes | classes whose members disagree on pump presence | ... on graph size |
| --- | --- | --- | --- |
| relabelling only | 438 | 0 | **42** |
| relabelling and reversal | 220 | **5** | 21 |

- **Graph size is not a relabelling invariant.** The graph is seeded from all
  three unordered pairs, so relabelling should carry it to an isomorphic graph
  and leave `len(states)` alone; in 42 of 438 classes it does not. The natural
  suspect is the canonical orientation: the graph keeps one orientation per
  unordered pair, chosen by the numeric order of the letters, and manuscript
  Proposition 5.39 says the other orientation gives `(b, a, -t)`. Relabelling
  permutes which member of a pair is first and can therefore select the other
  orientation. If that is the cause, then the reported state counts — 1,118,850
  total and 2,640 largest — are properties of `(sigma, orientation convention)`
  and not of `sigma`. Productivity is unaffected, since Proposition 5.39 proves
  the orientation exchange preserves coincidences; the size and depth
  statistics are the ones at risk.
- **Pump presence is relabelling-invariant but not reversal-invariant** (0
  mixed, then 5 mixed once reversal joins the group). This one is expected
  rather than alarming: the extractor deletes offset-zero states while
  deliberately retaining right-aligned ones, an asymmetry
  `kernel/swap_overlap_census.mojo` documents at its call site. It still means
  "has a zero-shift-free cycle" is a property of a substitution together with a
  left/right convention.

**First move.** Audit which census statistics are invariant under which part of
the group, and record the answer beside each statistic. Deduplication to 384
representatives is worth roughly a twelvefold budget and should wait for that
audit, because a statistic that varies within an orbit cannot be computed on a
representative.

## 4. Absence of a zero-shift-free cycle is finer than the Galois spectrum `[V]`

Of the 2,628 unimodular specimens, 30 carry no zero-shift-free affine cycle at
all. They occupy only four of the twelve characteristic polynomials that occur
on that branch, and every one of the four has constant term `-1` and
non-positive middle coefficient:

| characteristic polynomial | with a cycle | without |
| --- | --- | --- |
| `x^3 - x^2 - x - 1` | 120 | 12 |
| `x^3 - 2x^2 - 1` | 336 | 6 |
| `x^3 - 2x^2 - x - 1` | 246 | 6 |
| `x^3 - 2x^2 - 2x - 1` | 264 | 6 |

Both directions matter. Lying in these four cubics is necessary for a specimen
to be cycle-free, and the remaining eight unimodular cubics never produce one,
so the spectrum constrains the phenomenon. But no row is pure: 120 specimens
with the first polynomial do carry a cycle. Whatever decides the absence is
therefore a combinatorial invariant strictly finer than the Galois spectrum
of `M_sigma`, and the full-rank and inherited-spectrum constraints of PR #76 and
PR #88 cannot be what is deciding it.

**First move.** Take the 30 as a family and look for the invariant that
separates them from the 120 sharing their spectrum. Anything found there
speaks to the strict-zipper branch of the PR #88 dichotomy, which is where the
zero-shift-free structure is the obstruction.

## 5. Already taken, and named here so it is not proposed twice

The gap between the contracting lower bound on the hitting level and the
observed hitting depth (`README.md`; Proposition 5.42) is the subject of
`docs/uniform-coincidence-level-bound-2026-09-18.md`, which states a uniform
target and proves negative controls for two naive uniformizations. Nothing in
this note adds to it, and a proposal to "sharpen Proposition 5.42" should be
read as a proposal to continue that note.

## 6. The two-letter case as a falsification test of the route `[P]`

The unimodular irreducible Pisot conjecture on two letters is settled in the
literature. This repository's route — bounded discrepancy, finite seed-patch
overlap graph, seedwise productivity, coincidence density, the imported density
bridge — should therefore be able to reach that case on its own terms. Whether
it can has not been tried.

The value is diagnostic and runs both ways: a route that reaches the settled
case gains a check no corpus can give, and a route that cannot reach it is
missing something the classical argument has, which is worth learning before
more effort goes into three letters.

The cost is bounded rather than open-ended. The vendored
`substitution_dynamics` package is alphabet-generic; what is fixed to three
letters is the `psc` binding — `ALPHABET = 3` in `psc.words` and the `Mat3`
linear algebra — in 13 of the 50 modules under `kernel/psc/`.

## 7. Depth of the deductive layer `[P]`

`proof/PscVerif/` machine-checks finite algebra from the spectral module. The
reduction itself — bounded discrepancy to finite overlap graph to coincidence
density to the imported bridge — is audited prose and a TLA+ dependency ledger,
which record that the hypotheses were checked by a reader rather than by a
proof assistant. Formalizing the reduction, and not the open premise, would
move that chain from audited to machine-checked and would force every
hypothesis into the open where the firewall could see it.

## Replaying the measurements

Sections 2 to 4 were produced from the Python oracle layer on the corpus
declared by `tools/corpus_refinement.py`, using `psc_research.pip_screen`
(`pip_corpus`, `mat`, `charpoly`), `psc_research.overlap_graph.OverlapGraph`
and `psc_research.overlap_affine_pump.first_zero_shift_free_affine_pump`. The
symmetry action is conjugation by each permutation of `{1,2,3}` composed with
word reversal, and the orbit counts are counts of canonical representatives.
Section 2 re-runs `pip_screen`'s screen over the 120 candidate images of length
at most four in place of the 39 of length at most three.

No canonical Mojo driver computes any of this yet. These are oracle
measurements offered as a reason to build one, not as a cross-checked result,
and none of them is a ledger claim.

## What this note does not license

1. No claim that any statistic of the declared corpus extends to images of
   length four, to another alphabet size, or to the determinants that domain
   adds. Section 2 measures what the domain contains, not what holds on it.
2. No deduplication of any census to orbit representatives before the
   invariance audit of section 3, which found two statistics that move inside
   an orbit.
3. No conclusion that the reported overlap-graph sizes are wrong. Section 3
   records that they vary within a relabelling class and names the likely
   cause; which convention they follow is what the audit has to establish.
4. No progress on Open Problem 5.35. Section 1 proposes measuring a degree of
   freedom the theorem already allows; section 4 proposes looking for an
   invariant. Neither is an argument.
5. No status change anywhere. The claim ledger, the conjecture ledger, the
   proof ladder and the generality firewall are untouched by this note.
