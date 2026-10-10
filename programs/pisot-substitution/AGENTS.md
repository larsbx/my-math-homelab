# Agent implementation policy

## Canonical language

**Mojo is the default and canonical implementation language for executable research code in this repository.**

New algorithms, finite-state constructions, exact arithmetic kernels, census drivers, proof-support instrumentation, and performance-sensitive research tooling should be implemented in `kernel/` first.

Python under `reference/psc_research/` is a secondary oracle/prototyping layer. It may be used to:

- cross-check a Mojo implementation with an independently written reference;
- generate small calibration fixtures or counterexamples;
- explore an idea before its contract is stable;
- preserve legacy regression coverage while a module is being ported.

A Python implementation is **not** the source of truth once a corresponding Mojo module exists. New theorem-support code should not merge as Python-only unless there is a documented blocker preventing a correct Mojo implementation.

TLA+ remains the proof-dependency/state-machine model layer and Lean remains the deductive finite-algebra layer. This Mojo-first rule does not replace either formal layer.

## Mojo-first optimization rule

Performance-sensitive code must be designed for Mojo rather than transliterated from Python. Prefer, in this order:

1. **Exploit fixed dimensions.** The standing alphabet-3 kernel should use fixed-size scalar or compact row-major arithmetic for 3-, 9-, and 27-coordinate objects where practical, rather than generic object-heavy containers in inner loops.
2. **Streaming exact algorithms.** Replace combinatorial tuple enumeration with running prefix accumulators when an exact recurrence exists. For example, scattered-subword `N2` and `N3` counts should be accumulated in one pass rather than with `O(n^2)` / `O(n^3)` index loops.
3. **Precompute substitution-local data.** Endpoint maps, image lengths, proper-prefix Parikh vectors, correction alphabets, and other data depending only on `sigma` should be computed once per substitution/census specimen and passed into hot loops.
4. **Reuse storage.** Reuse scratch vectors/buffers and size result storage from known bounds where the Mojo API makes this safe and clear. Avoid repeated temporary list/string construction in graph and census inner loops.
5. **Compact graph/state identities.** Prefer integer indices and compact exact keys after state interning. String serialization is for diagnostics/export, not the preferred long-term key representation for hot BPA lookup paths.
6. **Iterative graph kernels.** Keep SCC, reachability, and closure routines iterative and index-based to avoid recursion overhead and recursion-depth limits.
7. **Fuse passes when it preserves auditability.** For exact censuses, avoid recomputing inflation, factorization, endpoint maps, or Parikh data in independent passes when one verified pass can expose all required outputs.
8. **Fail closed.** Impossible invariant states must abort/raise rather than silently returning empty structures that could be misclassified as mathematical evidence.
9. **Exactness before speed.** Do not replace integer/rational predicates with floating approximations for PIP screening, equality, factorization, rank, or certificate decisions. Optimize the exact algorithm instead.
10. **Benchmark material optimizations.** When changing a hot kernel, add a deterministic correctness regression and, where practical, record the before/after algorithmic complexity or benchmark on a representative corpus slice.

## The census library

Every exhaustive census and catalogue in `kernel/` surveys the same object: the
4,554 primitive irreducible Pisot substitutions on `{0,1,2}` with images of
length at most three. That corpus, and the vocabulary for reporting on it, are
first-class modules rather than something each driver rebuilds:

| Module | Provides |
| --- | --- |
| `kernel/psc/corpus.mojo` | `Specimen`, the deterministic `image_words` order, `pip_corpus`, the shared state cap, the arithmetic regime of the incidence cubic |
| `kernel/psc/histogram.mojo` | bounded exact histogram over integer keys; a key outside its capacity raises |
| `kernel/psc/carrier.mojo` | the two edge facts that classify a recurrent noncoincident SCC (sink, strict carrier), per-state flags, boundary-synchronization lineage, replayable countermodels |
| `kernel/psc/symmetry.mojo` | relabelling and reversal normal forms for words, pairs and substitutions |
| `kernel/psc/defect_degree.mojo` | streaming `N4` and the first scattered-subword defect degree |
| `kernel/psc/degree2_sieve.mojo` | the parity and trace necessary conditions on the incidence cubic |
| `kernel/psc/degree3_taxonomy.mojo` | the degree-3 catalogue taxonomy and its summary lines |

A census driver is then a survey: it walks `pip_corpus()` and folds per-specimen
facts into histograms and counters. A new census should be written that way. Do
not re-enumerate the image words, re-screen the corpus, re-derive sink or strict
-carrier membership by scanning component edges, or hand-roll a histogram line.

The same rule governs scripts. An executable computation belongs in `kernel/` with
a driver and a regression test, not in `tools/`. What lives under `tools/`
is the provenance and governance tooling; the Python census oracles that
cross-check a Mojo census in an independently written language live under
`oracles/python/`, sanctioned by the oracle policy above. A Python script that is the *only*
implementation of a computation is a defect to be ported, and the ported script
is then deleted rather than kept as a second source of truth.

Exploratory searches are welcome but must be reproducible and must label
themselves: a seeded generator (`kernel/psc/prng.mojo`) or a stated stride, an
explicit resource budget, and output that distinguishes an exhausted budget from
a mathematical verdict (`kernel/psc/bounded_bpa.mojo`). Randomness may never enter
a certificate, a census, or proof-support code.

## Vendored packages

Seven logical Mojo packages under `kernel/`, the five Python packages under
`tools/`, and `proof/tla/ProofArchitecture.tla` are vendored byte-for-byte from the single
`larsbx/finite-math-kernels` monorepo and pinned to one commit by SHA-256
digest in `vendored.toml`;
`tools/vendoring/check_vendored_sync.py`, itself vendored, enforces the pins
in CI and in `tools/verify_all.sh` and derives the `finite-math-kernels` pin
of `ESTATE.toml`. Do not patch a vendored file, add a file beside one,
or reintroduce a local copy of what a package provides: change the package
upstream, re-vendor, and re-pin (`tools/vendoring/check_vendored_sync.py pin NAME
COMMIT`).

| Package | Upstream | Provides | PSC-side layer |
| --- | --- | --- | --- |
| `kernel/finite_exact/` | `larsbx/finite-math-kernels` | unbounded `BigZ`, normalized `Q`, canonical bytes, closed rational intervals and rank-2 boxes, checked machine-integer arithmetic; rejection is sticky | `kernel/psc/exact.mojo`: rejected consumer states raise/abort; Horner helpers, midpoint, diagnostic rendering |
| `kernel/substitution_dynamics/` | `larsbx/finite-math-kernels` | words, substitutions, balanced pairs, automaton, discrepancy, tuning patterns, directive prefixes, column coincidence, relabelling/reversal normal forms, endpoint self-map classes, and the named modules `balanced_pair_algorithm` (bounded), `barge_class`, `dumont_thomas`, `strong_coincidence` (generic over a difference bound) and `return_lattice`, over an explicit alphabet | `kernel/psc/words.mojo`, `psc/bpa.mojo`, `psc/swap_discrepancy.mojo`, `psc/symmetry.mojo`, `psc/endpoint_core.mojo` (keeps the C4 A..G names), `psc/barge_class.mojo`, `psc/bounded_bpa.mojo`, `psc/dumont_thomas.mojo`, `psc/return_lattice.mojo` remain thin alphabet-3 / image-list views; `psc/coincidence_formula.mojo` keeps the Perron-field reserve (`PerronReserve`) the package automaton is generic over, and `psc/coincidence_elimination.mojo`, `psc/coincidence_level_bound.mojo` bind it |
| `kernel/finite_linear_algebra/` | `larsbx/finite-math-kernels` | `Mat3`, generic RREF/rank/nullspace over `Q`, rank-three tensors, `W_3`, integer lifts, the M-adic ball carrier, checked integer vectors, the primitivity test of a non-negative integer matrix, and exact polynomials over `Q` (`qpoly`: division, gcd, Cauchy root bound, Sturm chain, sign variations) | `kernel/psc/w3.mojo` keeps the printed certificate basis; `psc/exact.mojo` re-exports lifts; `psc/pisot.mojo`, `psc/pisot_screen.mojo` and `psc/real_root_sign.mojo` build on `qpoly` and keep the unrolled Horner, the length-preserving remainder, the Sturm chain of `p` itself and the Tarski query |
| `kernel/parallel_fold/` | `larsbx/finite-math-kernels` | deterministic MAX-backed map/fold over an index range; index-order fold preserves sequential results for associative combines | `kernel/psc/parallel_census.mojo` keeps PSC evidence semantics, failure replay, and corpus-specific result records |
| `kernel/finite_graph/` | `larsbx/finite-math-kernels` | iterative Tarjan SCCs and the cycle test on an adjacency list, a disjoint-set forest, and the F2 Perron-compatibility signing test | `kernel/psc/overlap_obstruction.mojo` keeps the capped-graph refusal around `scc`; `psc/finite_cokernel_address.mojo` and `psc/loop_quotient_census.mojo` use `union_find`; `psc/hub_cocycle.mojo` reads `signing` |
| `kernel/finite_automata/` | `larsbx/finite-math-kernels` | deterministic finite automata over an integer alphabet: products, complement, projection (subset construction), minimisation, language equality, witnesses, accepted-word counts, and a bounded automaton that can refuse | `substitution_dynamics.dumont_thomas` and `.strong_coincidence` build their automata on it; `psc/numeration_addition.mojo`, `psc/numeration_conversion.mojo` and the coincidence views use it directly |
| `kernel/mojo_smoke/` | `larsbx/finite-math-kernels` | `require_claim` / `require_contract`, the receipt lines a test prints when its declaration is reached | `kernel/run_tests.sh` collects the receipts; `claim_governance.toml` `[coverage]` reads them |
| `tools/claim_governance/` | `larsbx/finite-math-kernels` (`audit/`) | the status-surface, terminology, promotion, numerics, and test-coverage audit | `claim_governance.toml` is the policy; its `[coverage]` table binds `kernel/tests/` to the ledger |
| `proof/tla/ProofArchitecture.tla` | `larsbx/finite-math-kernels` | generic alternative-dependency state machine, pinned as `proof_architecture`; copy with the matching ledger generator |
| `tools/proof_records/` | `larsbx/finite-math-kernels` | proof records (kinds, identity, dependency closure) and the ledger generator | `tools/make_ledger.py` holds the record table; `proof/tla/ledger.json`, `proof/tla/Ledger.tla`, the `proof/tla/MCLedger*` models, `docs/ledger-index.md`, `docs/claim-relationship-graph.json`, and the generated `[[claim]]` block of `claim_governance.toml` are its outputs, never hand-edited |
| `tools/oracle_refinement/` | `larsbx/finite-math-kernels` | a generator's declared input distribution, `φ_G`: the codomain every draw must satisfy, and per named class whether the corpus reaches it or misses it with a stated reason, both directions checked | `tools/corpus_refinement.py` declares `psc_research.pip_screen.pip_corpus()`, the domain every finite-domain claim is asserted for, and pins its digest |
| `tools/vendoring/` | `larsbx/finite-math-kernels` | `check_vendored_sync.py`: per-file digest check of every package, refusal of an unpinned source file inside a package directory, and derivation of the `ESTATE.toml` vendoring pin | `vendored.toml` is the manifest; CI, `tools/verify_all.sh` and the estate-pin hook run it |
| `tools/polyglot_envelope/` | `larsbx/finite-math-kernels` | the polyglot boundary envelope schema and conformance vectors as one template, and `render.py`, which substitutes this repository's facts | `polyglot.manifest.toml` declares the repository and `boundary_id`; `.polyglot/boundary-envelope-v1.schema.json` and `.polyglot/conformance-v1.json` are its outputs, never hand-edited; CI and `tools/verify_all.sh` run `--check` |

Integer, rational, and rational-interval arithmetic is therefore **not**
implemented in this repository. Do not add a second rational type or a
hard-coded three-letter kernel beside the packages. The PSC binding rows of
the arithmetic specification are in `docs/exact-arithmetic-binding.md`.

## Porting order for the live C4 program

The current C4 recognizability/factorization work is being migrated to this policy. The preferred order is:

1. shared word/prefix and BPA primitives in `kernel/psc/`;
2. multi-level prefix ancestry and legal-context/tower primitives;
3. derived substitution/address and orientation-aware birth events;
4. relative hierarchy-offset state/transducer;
5. exact corpus instrumentation using those Mojo modules.

Python copies may remain as independent reference oracles during migration, but new results should cite the Mojo implementation as canonical.

## Review gate

### Targeted literature stop/go check

Before implementing a new theorem-facing diagnostic, testing a proposed
universal invariant, or promoting a proof lemma, perform a small targeted
literature review first. Its purpose is to avoid spending computation or proof
effort on a known construction, a known counterexample, or a route whose
hypotheses do not match the standing PIP regime.

Keep the check proportional: normally inspect three to six primary sources
covering (1) the closest known construction, (2) the strongest relevant
theorem, and (3) known hypothesis/counterexample boundaries. Record a short
stop/go note in `docs/` containing:

- the exact proposed claim or experiment;
- prior art and the terminology used in the field;
- hypotheses that transfer and those that do not;
- known negative controls or counterexamples;
- the resulting decision: stop, redirect, or proceed with a narrowed target.

Only after that decision should new theorem-facing tests or proof code be
written. Pure regression repairs for an already reviewed contract do not need
a new review. If the review shows that a proposed identity is standard, cite
it and restrict novelty claims to the actual new specialization, certificate,
or theorem.

For new executable mathematical machinery, a PR should normally contain or depend on:

- a canonical Mojo implementation;
- Mojo regression coverage for the theorem/invariant contract;
- explicit counter-calibrations for known overstrong variants;
- Python oracle coverage only when it adds independent value;
- no claim beyond what the exact executable or formal proof actually establishes.

## Record side findings

Every session records its side findings in `docs/side-notes-ledger.md` in the
same commit as the work that produced them: a refuted or retired mechanism, a
route redirected at a stop/go decision, specimens already settled by the
literature, a withdrawn or unreproducible figure, a finite observation worth
not recomputing, a tooling pitfall. One dated line, with a locator for the
evidence. Before starting a new mechanism, census or literature route, read
the ledger first; an entry there is the reason not to spend the cycles again.
The ledger is append-only: correct an entry with a dated correction beneath
it.

## Every test names what it guards

A file under `kernel/tests/` ends its `main` with a declaration from the
vendored `kernel/mojo_smoke/claims.mojo`: `require_claim("<Name>")` for each ledger claim
in `claim_governance.toml` whose certificate rests on the contract the test
pins, or `require_contract("<what it pins>")` when no ledger claim is the
target, as for a vendored kernel. The `coverage` check of the vendored
`claim_governance` package reports a test that declares neither, a name that
is in no ledger claim or alias, and a finite-domain or evidence claim that no
test guards -- those two classes because their whole warrant is an exact
finite computation, where a repository-proved claim also has a manuscript,
a Lean proof, or an archived certificate behind it.

The declaration is placed after the assertions it stands behind, because
`kernel/run_tests.sh` collects the receipts of the tests that *passed* and the
check credits nothing a run did not reach. A declaration is a link, not
evidence: what the contract is, the assertions decide; that the claim follows
from it, its own proof or certificate decides.

## Fail closed, and which way closed points

"Fail closed" is used throughout this repository as though it had one meaning.
It has two, and they point opposite ways. `larsbx/native-deployment-control-plane`
is the only repository in this estate that says so, and it is right:

> For deploy gates, failing closed means refusing to proceed. For a destructive
> operation, failing closed means refusing to delete. Uncertainty is never
> resolved in favour of deletion.

Applied here, by effect rather than by name:

| Operation | Closed means | Because |
| --- | --- | --- |
| A catalogue or census cap is reached | refuse to conclude | an exhausted budget is not a mathematical verdict, and a capped run reports as capped |
| A certificate check cannot decide | refuse to promote | the claim keeps the status its evidence earns, never the one the run hoped for |
| A generated surface disagrees with its table | refuse the run (`--check`) | the surface is a function of the table, so disagreement is drift and not a new fact |
| A claim is to be retired | refuse to retire | withdrawal is a statement about the claim's history; an uncertain one stays live and stays wrong in public rather than vanishing |
| An archived certificate or manuscript source is to be replaced | refuse to overwrite | the archive is the record a reader replays; a doubtful replacement destroys the thing the doubt was about |

The first three refuse to *proceed*. The last two refuse to *destroy*, and a
rule that only knew the word would have had them delete. When a new gate is
added, state which column it is in; when it is not obvious, it is the second,
because that is the direction that cannot be undone.

This does not license retiring a claim quietly when the evidence is clear.
Retirement is a deliberate, attributable act with its own status in
`claim_governance.toml`; what fails closed is the *uncertain* case, not the
decided one.
