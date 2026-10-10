# Cross-pollination, round three: the rest of the estate

**Status:** comparative audit dated 2026-09-17, continuing `docs/cross-pollination-round-two-2026-09-16.md`. Round two read seven repositories; this one reads the twelve it never opened. It proves nothing, promotes no claim, and changes no ledger. Status labels follow section 0.2 of the round-one document. Project terms are governed by `claim_governance.toml` here and by `docs/terminology-registry.md` in the Mandelbrot program.

Round two closed with a non-claim: "`coop_substrate` was not read and is not assessed." That was the only repository it named as unread, and the estate turned out to hold eleven more the audit had never listed at all. This document records what is in them.

## 0. What was read

| Tag | Repository | Read | Role |
| --- | --- | --- | --- |
| `CS:` | `larsbx/coop_substrate` | full clone | Elixir signed-event ledger and capital-account substrate, plus the Harness-D evidence pipeline |
| `MT:` | `larsbx/meta_test` | full clone | specification for grading oracle suites as typed, content-addressed verification instruments |
| `NDC:` | `larsbx/native-deployment-control-plane` | README | Elixir deployment control plane on an append-only hash-chained ledger |
| `OW:` | `larsbx/openclaw-workspace` | tree and one document | agent workspace; holds the LLM-to-deterministic refactor roadmap |
| `SP:` | `larsbx/spruce` | README | Elixir/Ash agent platform, the scaffold `sprucegoose` grew from |
| `AI:` | `larsbx/agent-icm` | tree | agent operating layer: policies, workflows, tasks, hooks, skills |
| `IH:` | `larsbx/icm-hub` | tree and one document | numbered knowledge hub mirroring fourteen source areas |
| `BK:` | `larsbx/bizops-kb` | tree | Johnny-Decimal business knowledge base in Obsidian |
| `EB:` | `larsbx/eatsbot` | tree | application carrying the objective-review vocabulary |
| `HQ:`, `ARP:`, `PC:`, `AD:`, `WS:`, `OWG:` | `halaqa`, `agent-runtime-platform`, `pi-cli`, `accountabot_dashboard`, `web-scraper`, `openclaw-workspace-guest` | tree only | classified, not assessed |
| — | `larsbx/cross-pollinated`, `larsbx/finite-mandelbrot-research` | full clone | both empty; see section 4 |

Six repositories were **not read**: `truck-shop`, `redis-pilot`, `nextcloud-calendar`, `listmonk-deploy`, `infisical-deploy`, `vaultwarden-deploy`, and `openclaw-secrets`. They are deployment manifests for third-party services, a category `NDC:` supersedes with its own machinery, and a secrets store that should not be read at all. They are named here so that "not assessed" is a statement rather than a silence.

Markers: `[V]` verified here by reading; `[L]` a claim in the source that this audit did not check.

## 1. Five rulings the estate reaches independently, a sixth it reaches once, and no citation between any of them `[V]`

This is the finding. Six repositories, written for co-op finance, deployment, oracle grading, agent operations and two mathematics programs, arrive at an overlapping set of rules without referencing one another for any of it.

The overlap is not uniform, and the counts are the evidence, so they are stated rather than averaged. Repositories stating each ruling, as the subsections below cite them: **P1** four, **P2** four, **P3** seven, **P4** five, **P5** four, **P6** *one*. Only P1–P5 are convergences. P6 is a single repository's ruling that the others have not stated, recorded here because the estate needs it, not because it recurs — see its own subsection and section 6.

### P1. A derived fact is read or generated from its source, never re-derived

`OW: llm-to-deterministic-refactor-roadmap.md` states it as its governing principle: *"If the answer already exists as structured data somewhere in the system, read it. Do not infer it from rendered text, and do not ask a model to re-derive it."* It then names two defect types — regex parsing prose (Type A) and prose instructing a model to enumerate mechanically (Type B) — and fixes each by moving the fact to its structured channel.

That is exactly round-two item R2, which this estate's mathematics side delivered two days later in ignorance of it: one record table, every status surface a function of it. The Mandelbrot program's first generation run found a proof block that gated final acceptance and appeared on no status surface, which is a Type A defect in the roadmap's taxonomy. `CS:` reaches the same place from a third direction: every projection is a pure fold over the log, so a surface cannot disagree with the events.

### P2. A check that cannot fail is not a check

Four statements, four repositories, no shared wording:

| Where | How it is put |
| --- | --- |
| `OW:` roadmap, "Anti-vacuity" | "Every phase carries a regression that fails against current code. A phase whose test passes before the change has not proven anything and is not done." |
| `NDC:` README, restore drill | "The negative control is required evidence; an equality check that never fails is a broken instrument." |
| `NDC:` README, routing check | a deliberately mismatched upstream is run "confirming the check is a working instrument rather than a constant pass" |
| `MT:` INV-4 `[L]` | "vacuity is uncompilable where provable" — provably vacuous oracles fail to compile, discharged by SMT at DSL compile time. Specified, not running: see below |

Round two recorded the same lesson as a correction rather than a rule: R5's first negative control was tautological because the separators were built from the addresses they were meant to separate. The Mandelbrot program has since built a real one.

`MT:` is the only place in the estate where the rule is **specified as a mechanism** rather than left to be remembered. It is not mechanized anywhere: `MT:` is a normative specification whose implementation is not authorized and whose S0 is blocked, so its compile-time refusal is a design nobody can run today. `NDC:` and the Mandelbrot program enforce the rule by carrying an actual rejecting case; `MT:` is the only one that would make a vacuous oracle unbuildable, if it existed. Section 5 states this non-claim, and the row above is marked accordingly.

### P3. Inconclusive is a third outcome, never a pass and never a failure

| Where | Name |
| --- | --- |
| `PSC:`, `NLAP:` | a capped run is inconclusive, never a counterexample (UW-2) |
| `FMK: proof_records` | `incomplete`, `bounded` — bounded evidence never closes a general claim |
| `SG:` | `UNEXECUTED`, neither PASS nor FAIL |
| `MT:` A.5 | "Solver `:unknown` MUST be treated as unliftable — never as pass or fail" |
| `OW:` Phase 3 | "Unclassifiable → `ambiguous`, never silently dropped" |
| `CS:` 00 Art. I.2, 09 §1 | "pending a ruling, contested instruments are gated `N` (not-yet)" |

Six vocabularies for one idea. Round two's A1 noted three of them and proposed mapping them onto each other; the map `FMK: proof_records/vocabularies.py` now holds covers two.

`CS:` earns its row on `N`, not on failing closed. Its `undeclared ⇒ fails closed` and `unclassified ⇒ block` rules refuse to proceed, which is a decision to deny rather than a third outcome carried forward, and they belong under P5 and P6 where they are cited. `N` is the genuine third state: contested, awaiting a ruling, and not readable as either answer in the meantime.

### P4. A derived or machine-produced artifact never authorizes

`CS:` is the sharpest: `MachineExtractionRecorded` is *"a proposal carrying the raw-artifact hash, never authoritative; promotion = human `FindingExtracted`; demotion = `CorrectionRecorded`."* `MT: INV-3` says of its own judge suite: *"measured always, trusted never."* `SG:` separates four authority planes so that a projection never authorizes. `FMK: proof_records` refuses to let a bounded experiment close a general claim. `NDC:` binds every call to one resource and one declared action and refuses anything else.

### P5. Make the illegal state unrepresentable, not merely rejected

`CS:`: *"`BuildStarted(D)` without `gate(D)` unrepresentable"*; an unversioned instrument edit is impossible because the version is content-addressed. `SP:`: *"there is no path to `:acting` that bypasses `:thinking`, even if the GenServer crashes mid-turn."* `NLAP:` enforces its membership lifecycle at the append gate rather than in a checker downstream. `MT: INV-3` makes the shown/judge partition verifier-enforced at compile time.

The research repositories are one rung below this. They reject bad states at the boundary and say so loudly, which is weaker than not being able to build one.

### P6. Fail-closed has a direction, and only one repository says so

`NDC:` alone states it: *"For deploy gates, failing closed means refusing to proceed. For a destructive operation, failing closed means refusing to **delete**. Uncertainty is never resolved in favour of deletion."* Everywhere else in the estate, including both mathematics programs, "fail closed" is used as though it had one meaning. It has two, and they point opposite ways.

## 2. What each repository holds that the research programs do not

### C1. `MT:` grades the oracle, which is the layer both programs are missing `[V]`

`MT:` studies *the oracle suite, not the implementation under test*, and asks "does this suite constrain anything, and how much?" Three instruments: typed non-vacuity (uncompilable vacuous oracles), empirical discrimination (kill-rate over a labelled population of fault-seeded implementations), adversarial gating (held-out mutation operators as feasibility constraints).

Its oracle taxonomy is the research programs' testing practice, named:

| `MT:` family | Instance here |
| --- | --- |
| known-answer | the pinned constants of every Mojo smoke target |
| property | `FMK: tools/property_oracle.py`, the exact-arithmetic probe |
| metamorphic | `PSC:` relabelling and reversal normal forms |
| reference (differential) | every `tools/*_reference.py` in `NLAP:`, the Python oracle layer of `PSC:` |
| model-based | the TLA+ layer, which `MT:` would derive rather than author |

The sharpest transfer is `MT:`'s requirement that a generator declare a **codomain refinement `φ_G`** — the input distribution is a declared, checked object rather than an accident of how the test was written. Round two recorded, in its own words, the failure that requirement exists to prevent: the M-adic carrier's soundness defect survived differential testing because "every coordinate it generated lay in `[-9, 9]`, where the wrap is unreachable", and the audit generalized it to "a differential test is only as strong as its input distribution". `MT:` is the mechanism for the moral the audit drew. `[L]` on `MT:`'s own claims: the specification is normative and unimplemented, and says so — S0 is blocked and implementation is not authorized.

### C2. `CS:` is a fourth content-addressed evidence ledger, and the only one with two implementations of its codec `[V]`

Round two's A1 compared three: `SG:`'s `ContentID`, `FMK:`'s length-prefixed records, `CC:`'s manifest. `CS:` is a fourth, and its opportunity-1 problem is already solved inside it: `CoopEventCanonicalV1` is a frozen strict-CBOR profile **implemented twice** — a Rust NIF for production and a pure-Elixir reference for test — and locked with committed byte-level vectors that both must reproduce. A1 proposed cross-testing `SG:`'s canonical encoding against `FMK:`'s golden vectors; `CS:` shows what the finished form looks like, and adds a boot gate: the application refuses to start if it cannot reproduce its known-answer vectors.

Two further pieces the research side lacks: **as-of reads** (`gate` is "as-of reproducible"; `PSC:`'s ledger has no notion of what it said last week) and **in-log rule versioning applied forward-only**, which is what a proof-record ledger would need before it could restate its own history.

### C3. `NDC:` runs a reproducible-build gate that is a proof record in production `[V]`

`NativeDeployment.BuildManifest` requires every build input to be declared — exact source commit, immutable builder image digest, ordered commands, environment values, content-addressed input paths — encodes them canonically, and derives a SHA-256 identity. Repeating a build with different output fails closed as `:non_reproducible_build`.

That is `FMK:`'s `verified_finite_computation` record, whose required evidence is exactly `replay` and `digest`, built for deployments instead of censuses. `PSC:`'s census records name a replay command and a digest; `NDC:` enforces that re-running it reproduces the artifact. The research side asserts replayability; `NDC:` checks it.

`NDC:` also supplies P6 above, and one structural idea neither mathematics program has: `assert_reclaimable/4` refuses to judge a preview in isolation because per-project minimum retention *"is a property of the whole set"*. That is the same shape as the separated-pair density correction, where flattening the endpoints into one cut set counted atoms that are not separated from each other as though they were — a class property misread as an element property. Two repositories, two domains, one error, both caught.

### C4. `OW:` has written the estate's methodology down, and the research repositories have not read it `[V]`

Besides P1 and P2, the roadmap draws a boundary the research programs draw informally: it lists what must *not* be mechanized — "Audit / observer / decider judgement roles", approval that "stays deferred and read-only" — and says converting them to rules "would be the same category error in the opposite direction". `PSC: AGENTS.md` makes the same split between exploratory search and certificate, without ever saying why the split exists.

### C5. `EB:` shows the objective-review vocabulary already has a non-research consumer `[V]`

`EB:` carries `OBJECTIVE_REVIEW_REPORT.md`, `UNIVERSAL_CRITIQUE.md`, `UNIVERSAL_ACTION_PLAN.md` and `STANDARDS.md`. Round-two item R6 delivered the Research Hygiene Manifesto into `ORM:` with `claim_governance` as its reference implementation; `EB:` is evidence that the review vocabulary travels to ordinary applications, which is the readership R6's manifesto was written for.

### C6. Two documentation taxonomies, no bridge `[V]`

`BK:` uses Johnny-Decimal (`00-09 System-management area`, `10-19 …`), `IH:` uses a numbered hub (`01-openclaw` … `14-copyparty`), and `MT:` files its documents under `docs/65-roadmaps/` and `docs/66-workflows/`, citing a "canonical Systemwide SOP taxonomy". The research repositories use a flat `docs/` with long dated filenames. Neither convention is better; the point is that `MT:`'s roadmap and `PSC:`'s ledger index are the same kind of object filed two different ways, so nothing can walk both.

## 3. Ranked next contributions

| Rank | Contribution | Repositories | Kind | First file |
| --- | --- | --- | --- | --- |
| R9 | Declare the input distribution of every differential oracle, per `MT:`'s `φ_G`, starting with the two that hid a soundness defect | FMK, PSC, NLAP | tooling, mathematics | `FMK: tools/property_oracle.py`; `NLAP: tools/*_reference.py` |
| R10 | Cross-test `CS: CoopEventCanonicalV1` against `FMK: fixtures/vectors.json`, and adopt its boot-gated known-answer self-test | FMK, CS | infrastructure | `FMK: tests/proof_records/test_vectors.py` |
| R11 | Mechanize the property-to-test tables: `CS: HARNESS.md` P1–P8 and `NDC:`'s acceptance list are prose; the `coverage` check of R8 already does this for a claim ledger | CS, NDC, FMK | tooling | `FMK: audit/claim_governance/checks/coverage.py` |
| R12 | Write P1–P6 once, as operational rulings beside the Research Hygiene Manifesto, each citing the repositories that state it | ORM, all | documentation | `ORM:` manifesto directory |
| R13 | Give fail-closed a direction in both mathematics programs' vocabularies, per `NDC:` | PSC, NLAP | documentation | `PSC: AGENTS.md`; `NLAP: docs/` |
| R14 | Resolve the two empty repositories of section 4 | — | governance | — |
| R15 | Import `CS:`'s as-of reads and forward-only in-log rule versioning into the proof-record model, so a ledger can restate its own history | FMK | infrastructure | `FMK: docs/proof-records-specification.md` |

R9 is first because it is the only item that answers a defect the estate has already suffered rather than one it might. R10 is second because the encoding convergence was round two's cheapest item and `CS:` has since finished the hard half of it.

### 3.1 Running delivery record

| Item | State | Where |
| --- | --- | --- |
| R9 | **delivered for every oracle that generates its inputs; five `NLAP:` reference oracles that enumerate fixed catalogues still declare nothing.** `oracle_refinement` is a vendorable package (it began in `FMK: tools/`, where no consumer could reach it, which is a rule remembered rather than mechanized). It declares a generator's codomain and, per named class, whether the corpus reaches it or misses it with a reason; both directions are checked, so a declaration cannot rot. Declared: `FMK:` property probe and M-adic corpus, `NLAP:` property probe and carrier-density sweep, `PSC: pip_corpus`. Two findings fell out of writing them -- the `NLAP:` sweep claimed to run over "every prefix of every small catalogue" and drew nine separators that all start at `0/12`, with no crossing or nested pair among them; and `PSC: pip_corpus` contains **no constant-length substitution at all**, so the domain called "image lengths at most three" never attains `(3,3,3)` and its widest total image length is eight, not nine | `FMK: f2a8ef1`; `NLAP: a130730`; `PSC: 63bc522`; `FMK: docs/generator-refinement-spec.md` |
| R13 | **delivered, and an adoption in both programmes rather than a convergence.** `PSC: AGENTS.md` and `NLAP: README.md` each sort that repository's own gates into the two columns -- a reached cap, an undecided certificate, an inadmissible separator, a rejected exact value and a stale generated surface refuse to proceed; a doubtful retirement, a doubtful demotion of a proof block, and a doubtful replacement of an archived certificate or pinned transcript refuse to destroy -- and each states the tie-break for a new gate as the irreversible column. Both say in their own text that they take the distinction from `NDC:`, and `larsbx/cross-pollinated` records the `PSC:` instance with `adopted = true` and its source, so P6 still counts as reached once | `PSC: e052ca3`; `NLAP: a130730`; `cross-pollinated: 64eb0fe` |
| R12 | delivered, section 6 | `cross-pollinated` |
| R14 | delivered by the estate's owner rather than by this programme, on 2026-09-17. The formerly empty `larsbx/finite-mandelbrot-research` is now `...-empty-archive`, the live Mandelbrot program holds the correctly spelled name, and the transposed name redirects to it. `larsbx/cross-pollinated` was filled by R12. Outstanding, and not urgent because the redirect resolves: the estate still spells the old name internally -- `FMK: tools/check_references.py`, `cross-pollinated`'s estate list, and the Mandelbrot repository's own `claim_governance.toml`, `pixi.toml` and terminology pattern | -- |
| R10 | **partly delivered: the boot gate, not the cross-test.** `FMK:` had two independent implementations of its codec and committed byte-level vectors both must reproduce; what it lacked was `CS:`'s third part, the gate. `proof_records` now runs a known-answer self-test at import and raises rather than returning a wrong identity -- FIPS 180-4 for SHA-256 first, so a broken primitive is named as one, then the committed preimage, identifier and digest of a record pinned by rule. The constants are generated from the same reference ledger as the fixture and committed, so they are a diff somebody accepts rather than constants the code agrees with by construction, and a corruption hook makes the gate fail on demand. The gap it closes is concrete: `proof_records` is vendored into two repositories that compute identities in CI and never run its suite, and both pinned the commit before the gate until it was re-vendored into each -- `PSC: vendored.toml` and the Mandelbrot repository's now pin `FMK: 8af9d7a`, and importing `proof_records` in either runs the four checks. Built upstream is not the same as reached downstream, and the record above said so for as long as it was true. Neither re-vendor moved an identity: the 20 generated surfaces here and the 10 there regenerate byte-identical, so the codec that produced the committed ledgers is the codec that still produces them. Outstanding: cross-testing `CS: CoopEventCanonicalV1` against `FMK: fixtures/vectors.json` -- the two codecs encode different data, so there are no shared bytes, and a useful cross-test is a shared property suite, which is a design question rather than a task | `FMK: 8af9d7a`; `PSC: 95e8101`; `NLAP: c0ac0ac` |
| R11, R15 | not started | -- |

R13 and R14 leave the queue. R9 and R10 leave the ranked list but not the work: the five `NLAP:` reference oracles that enumerate pinned catalogues -- kneading, the Misiurewicz catalogue and prefix graph, the polynomial identities, the interval exclusions -- still draw undeclared corpora, and the carrier-density sweep is the reason to expect that to matter, since it was an enumeration too and it was a pencil of rays through one point. R11 is now the head, with R9's and R10's remainders beside it.

## 4. Two empty repositories, one of them a name collision `[V]`

- `larsbx/finite-mandelbrot-research` was created on 2026-09-17 and contains one file: a README holding its own title. The live program is `larsbx/finite-mandlebrot-research`, spelled with the transposition, and carries the whole Mandelbrot repository. Anyone or anything resolving the correctly spelled name reaches the empty one. `FMK: README.md` and both cross-pollination audits cite the misspelled name as canonical, so the live name is the one with the typo in it. *(Resolved 2026-09-17 by the estate's owner, in the direction this audit did not propose: the empty repository was renamed `larsbx/finite-mandelbrot-research-empty-archive` and the live program took the correctly spelled name. The transposed name now redirects to it, so every citation in this estate still resolves, and none of them is canonical any more. See section 3.1, R14.)*
- `larsbx/cross-pollinated` is likewise a single README holding its title. Nothing in either audit refers to it. *(Resolved after this audit was written: R12 was delivered there. See section 6.)*

Neither is a mathematical matter. Both are recorded because a reader who searches the estate by name will find them first. Both are now resolved, and the record above is left as written with the resolutions noted, because what the audit found is not changed by its having been fixed.

## 5. Non-claims

- Nothing here bears on `OverlapProductivity`, `ResidualClosureNoMissingLinks`, `C1`, or any conjecture status.
- Section 1 is a claim about wording and structure in documents, not about the correctness of any repository's code. Where a repository states a property of itself, this audit records the statement and marks it `[L]` if it did not check it.
- `MT:`'s three instruments are a specification, not a running system: its own README says implementation is not authorized and S0 is blocked. Nothing here treats its guarantees as available.
- The six repositories listed as not read in section 0 are not assessed, and their absence from section 1 is not evidence that they lack the rulings.
- `coop_substrate`'s charter constants are flagged in its own source as placeholders awaiting declaration; no number taken from it is a real value, and none is used here.

## 6. Delivered: R12, as a package rather than a document `[V]`

R12 ranked "write P1–P6 once, as operational rulings, each citing the
repositories that state it". It is delivered in `larsbx/cross-pollinated`,
which was one of the two empty repositories of section 4, as data rather than
as prose in `ORM:`'s manifesto directory. Two departures from the ranked item,
both stated rather than hidden:

- **Location.** `ORM:` was not read by this audit and is not in this session's
  scope, so putting the rulings there was not available. `cross-pollinated` was
  empty and named for exactly this, which resolves half of section 4 as a side
  effect.
- **Form.** `rulings.toml` and `vocabularies.toml` are machine-readable, and
  `python -m crosspollinated` refuses malformed data: a ruling with no
  instance, an instance with no path, a term outside the declared classes, a
  repository cited but absent from the estate, or the `inconclusive` class
  removed. A document could not refuse any of these.

What it deliberately does **not** contain is a checker. The mechanisms these
rulings describe live where they were built — `FMK: proof_records`,
`FMK: audit/claim_governance`, `CS:`'s append gate, the verifier `MT:`
specifies — and restating one in a package that no repository's CI runs would
give it an authority it has not earned, which is what P4 forbids. What it adds
instead is `CONFORMANCE.md`: for each ruling, the test a repository must be
able to show, and the near-miss that does not count. Those tests are
generalizations of instruments already built in this estate, not new
requirements.

Every `instance` there is a citation, not a verification: it records that a
repository states the ruling at that path, never that it obeys it. One entry —
`sprucegoose: UNEXECUTED` — is carried from round two and was not read directly;
its entry says so.

P6 was stated once when this section was written. It no longer is: R13 has
since given `PSC: AGENTS.md` the distinction, and section 3.1 records it. The
package does not count that as a second convergence, because `PSC:` adopted the
ruling rather than reaching it: the instance carries `adopted = true` with its
source, `Ruling.independent` counts only repositories that reached the ruling,
and the report says "stated more than once but reached once". Closing the
estate's gap and converging on a ruling are different facts.

R13 is finished. `NLAP: README.md` now carries the same table, and it too says
it adopted the distinction rather than reaching it, so the count does not move.
