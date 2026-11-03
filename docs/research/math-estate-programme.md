# Mathematics estate: recurring automated research contract

**Scope:** Every currently active mathematics source in `policy/source-locks.toml`
— **14 programmes and 2 shared research components**. Superseded
`finite-dynamics` and the empty `oracles` repo are *not* active programmes.

**Authoritative registry:** `policy/math-research-portfolio.toml`  
**Read-only coordinator:** `tools/math_research_portfolio.py`  
**Scheduling:** `.github/workflows/math-estate-research.yml`  
**Existing specialist:** `policy/research-schedules.toml` and
`.github/workflows/akn-math-research.yml` for AKN.

## Contract (for every mathematics repository)

A research programme is a scientific process, not merely a CI job:

```
stated hypothesis / exact definition / imported assumptions
    -> current source SHA and evidence inventory
    -> reproducible experiment and explicitly bounded search
    -> independent verification by a distinct mathematical implementation
    -> counterexample or disagreement preservation
    -> new theorem obligation / next reproducible calculation
    -> reviewed claim-governance change, if justified
```

**The rollout is deliberately staged.** Every source is registered and
subject to the same recurring provenance, CI/issue/PR review, evidence
retention, scientific frontier, and claim-governance rules. The AKN track
has an existing exact enumeration + independent-verifier executor.
A second narrowly scoped adapter now covers the **Arithmetic Bicycle**
source's six registered finite fixture families: one computation
enumerates modular potentials and cut-cycle intersections; an independent
checker enumerates edge vectors and tests image membership using exact
gcds of maximal lattice minors. The latest source fixture is fetched
at the inspected immutable SHA, with Git blob and SHA-256 checks.
Its original realization-invariance conjecture remains **refuted**.

The other **11 tracks** are not falsely marked as possessing an
independent mathematical experiment: their research-specific
experiments, independent checkers, and autonomous hypothesis-selection
policies must be separately reviewed and registered before execution.
The scheduler makes that onboarding obligation visible in every report.
Even AKN does not prove a universal theorem by running a finite job.

## GitHub schedule (UTC)

| Trigger | Scope | Activity |
| --- | --- | --- |
| Daily `43 4 * * *` | Every active repo | Inspect current default-branch SHA, source exact-file evidence, PRs, issues and CI; preserve a per-programme immutable-revision record. |
| Tuesday `47 5 * * 2` | Every active repo, four shards | Conduct source-bound evidence/falsification triage and issue-specific mathematical next-step planning; explicitly flag missing independent proof adapters. |
| Monday `17 4 * * 1` | AKN specialist | Execute exact complete 135-plane AKN chamber candidate and independent 2D-section replay, then checked bounded singular probes. |
| Daily `7 4 * * *` | AKN specialist | Record exact source PR/issue/check status. |
| PR updates | Homelab registry and scheduler files | Offline conformance, strict registration, mutation/regression tests. |
| Manual dispatch | Daily, weekly, validate | Re-run the registered source evidence cycle at current source revisions. |

GitHub's scheduled trigger is activated only after the workflow file
is merged to homelab `main`, and start times may be delayed by the
Actions scheduler.

The general weekly portfolio never duplicates AKN's expensive
mathematical experiment: it records that its independent executor is
`scheduled_by_akn_specialist`. The two shared components are monitored
as *infrastructure/independent-oracle* lanes, not as separate theorem
authorities.

## Programme-specific mathematical frontier

| Programme | Exact question / near-term research obligation | Independent experiment status |
| --- | --- | --- |
| arithmetic-bicycle | Exact 6-fixture code-hull and lattice-index cross-check at prime, prime-power and composite moduli; preserve **refuted** invariance. | Independent finite-fixture adapter implemented; hosted acceptance pending |
| bulb-ford | Reproduce finite exact P0/P2/P6 bulb/Ford evidence without using analytical limits as finite proof. | Needs reviewed adapter |
| closure-fiber | Investigate exact identity fibers and literature dependence in algebraic-group closure. | Needs reviewed adapter |
| finite-julia | Certificate-carrying dynamical-plane finite tests and consumer compatibility. | Needs reviewed adapter |
| finite-mandelbrot | 11 exact finite-field critical-relation and simple-root controls, independently replayed by dual-number iteration and coefficient recurrence. MLC remains open. | Exact field adapter implemented; hosted acceptance pending |
| giant-fibers | Finite-field Descartes fiber-count tests versus the proposed heavy-fiber formula. | Needs reviewed adapter |
| julia-oracle | Differential oracle reproducibility, cross-consumer disagreement, no claim authority. | Needs reviewed adapter |
| langlands | Reproduce small exact Hecke/Galois calibration claims without conflating imported results. | Needs reviewed adapter |
| novelty | Independently audit Lean/evidence/literature boundaries for novelty candidates. | Needs reviewed adapter |
| pisot-substitution | Reconcile precise open PSC boundary lemmas, tests and claim integration on current heads. | Needs reviewed adapter |
| pisot-vijayaraghavan | Bounded exact auxiliary calculations, with the classical PV problem still open. | Needs reviewed adapter |
| s-adic-pisot | Independently verify theorem-scope assumptions and finite Selmer/Brun censuses. | Needs reviewed adapter |
| tiling-theory | 21,840 generic AKN chambers, 24 star orbits, six stabilizer conjugacy types, 105 singular probes. | Specialized exact executor; hosted acceptance still required |
| vizing-domination | Exact historical 16-to-3 graph6 isomorphism and 16 domination-number-four witnesses; 491 census remains unavailable. | Independent finite historical adapter implemented; hosted acceptance pending |
| finite-math-kernels | Independently reconstruct exact cyclotomic polynomials for q≤8 and check all 22 primitive-power residue identities; separately audit germ coefficients. | Cyclotomic finite adapter implemented; hosted acceptance pending |
| math-vizops | Source-owned proof/evidence attachment and scene reproducibility; no theorem acceptance. | Shared-component adapter needed |

The up-to-date, machine-readable individual research obligations are
in the versioned portfolio registry, not dependent on the narrative
table above. All `research_evidence_path` entries were checked to
exist in their respective source repositories when registered.
Every new active source lock must obtain a matching research track;
conformance rejects an unregistered addition or stale/mismatched source.

## Exact-revision evidence checks

For each current source `default_branch` the coordinator records the
current Git SHA, compares it to the homelab imported source lock, and
fetches at that **immutable SHA** the original `README.md`,
`ESTATE.toml`, and a programme-specific research/claim surface.

For each file, the coordinator **recomputes the Git blob SHA-1 from
the retrieved bytes and independently stores their SHA-256**, rejecting
a mismatch. Current open PRs, issue titles and exact-head GitHub
Actions runs are captured with their precise source commit IDs.

For public sources, this proves file/revision provenance, **not the
truth of mathematics written in those files**. Private sources are
isolated, not probed or presented as successfully inspected. A CI failure or pending run is flagged.
A stale imported tree is registered as provenance drift, never modified
automatically. Missing files, malformed registration, unavailable APIs
and unexpected source revisions fail closed and retain errors.

Evidence is published as machine-readable per-programme JSON plus
`portfolio-index.json`, using four disjoint weekly shards to limit
resource use. Artifacts are retained for 90 days under the GitHub
Actions policy.

## Private-source isolation and first scheduled-run repair

The first estate-wide scheduled daily run on **2026-11-02**
([workflow 41447971436](https://github.com/larsbx/my-math-homelab/actions/runs/41447971436))
failed on three HTTP 404 responses. Inspection of the actual source
repository permissions established that `closure-fiber`, `finite-julia`,
and `giant-fibers` are currently **private**, although the October 9
import locks still declare them public. A homelab-scoped GitHub Actions
`GITHUB_TOKEN` is not authorized to read those private repositories.

**Do not solve this by passing a broad private token into a publicly
accessible workflow artifact.** The homelab is a public repository.
Private revision IDs, source issue/PR titles, file content and file
hashes must not be written to its public evidence artifacts.

These three sources are explicitly marked
`source_access_policy = "private_isolated"` and the portfolio now
refuses to contact them from the public homelab coordinator.
The public daily/weekly index records only the already-registered
source name and a coarse `private_source_isolated` / 
`requires_private_source_runner` status, with
`source_contents_retrieved=false`, no exact head and no source CI
details. All other source records still fail closed if an unexpected
private repository is discovered.

**Research execution for those three must move into source-owned private
workflows**, with source-scoped credentials and private artifacts.
Any aggregate published to the public homelab needs a separately
reviewed information-release contract. Until that exists, no private
exact-head research result is claimed verified by the homelab.

The import source-lock visibility mismatch is separately recorded for
governance review. This change does not rewrite locked imported source
histories, grant a token broader access, or turn a successful public
portfolio run into proof that the private research jobs executed.

## Research automation versus monitoring

The portfolio coordinator provides an *operational research substrate*.
It can identify a changed hypothesis/PR, CI regression, incomplete
provenance or pending proof obligation, but it does **not** construct
new independent mathematical proof algorithms in an unconfigured
repository. An individual programme is upgraded to a full autonomous
research cycle only after it has:

1. A source-owned exact research charter identifying mathematical
   hypotheses, hypotheses imported from literature, and decidable
   finite subclaims.
2. A deterministic source revision and explicit finite-resource cap
   with honest `inconclusive` semantics.
3. A reproducible experiment and an **independent** checker using
   meaningfully different mathematics or implementation.
4. Counterexample and disagreement fixtures, negative controls and
   a machine-readable `next_research_obligation`.
5. Source-head CI and governed claim status gates; *no automatic
   universal theorem assertion*.

This is not a licence for the homelab to execute unreviewed source
scripts with its GitHub credentials. The AKN specialist is a separate
opt-in research execution path. Additional opt-in runners should be
isolated, resource-limited and explicitly reviewed.

## Commands

```sh
python3 tools/math_research_portfolio.py --mode validate
python3 -m unittest discover -s tests -p 'test_math_research_portfolio.py' -v
python3 tools/math_research_portfolio.py --mode daily --out /tmp/math-daily
python3 tools/math_research_portfolio.py --mode weekly --shard 0 --out /tmp/math-shard-0
```

The coordinator changes **no** imported `programs/*` or `shared/*`
file, source lock, source PR or claim ledger. Mathematical claim
acceptance stays with each source repo until a separately documented
per-programme authority transfer.

## Programme admission / removal

`policy/source-locks.toml` is the authoritative active programme
inventory. To add a source, first follow the estate's history-preserving
import and authority rules. Register exactly one matching portfolio
track with source repository, research question, accepted evidence
surface and original authority. Remove a track only if the source is
explicitly retired or transferred under the estate contract.

**Current completion boundary:** All 16 current active math sources
are registered and scheduled for *research governance and evidence
triage* once this workflow merges. Full generic-chamber independent exact research remains AKN-specialized;
the Arithmetic Bicycle six-specimen finite module replay is newly implemented.
The other 13 individual adapters are an explicit backlog, not silently
counted as accomplished.

## Independent Vizing historical graph-corpus adapter

`tools/math_adapters/vizing_domination.py` now provides a second
**source-SHA-pinned, independently checked finite programme adapter**.
It fetches the 16 historical graph6 records and the declared A/A-class/B
partition from the source's exact revision, verifying their Git blob
SHA-1 and independent SHA-256 provenance.

Unlike the source's canonical degree-IR labeling, the adapter performs
exhaustive adjacency-preserving isomorphism search with degree and
neighborhood-degree pruning. Every claimed equivalence comes with a
literal bijection checked against all ordered vertex pairs; class
representatives are also exhaustively tested for non-isomorphism.
A separate exact subset-enumeration calculation establishes
`gamma(G)=4` for each of the 16 historical ten-vertex graphs.

The finite result is **16 records in exactly three isomorphism classes
of sizes 1, 14 and 1**. The authoritative reported **491-entry**
census remains unavailable. Neither these 16 specimens nor the
completed small-graph domination numbers settle Vizing's general
domination conjecture. A missing source entry, invalid graph6 padding,
misassigned class, fake source promotion or non-isomorphic graph in
a class fails closed; no source oracle is executed.

This is a second source-specific finite adapter. The homelab now has
**three mathematically specialized lanes** (AKN, arithmetic-bicycle
and Vizing), leaving **13 registered source tracks** needing reviewed
independent experiment adapters.

## Independent finite-Mandelbrot critical-relation adapter

The source's `kernel/mojo/dynamics/critical_type_census.mojo` contains
**11 finite-field Golden test vectors** with `(c,ell,k,p)`, including
positive simple-root witnesses and negative collision controls.
The new `tools/math_adapters/finite_mandelbrot.py` reads only this
**source-Git-blob-verified text at an immutable source SHA** and then
recomputes the values by two independently implemented exact methods:

1. Formal dual-number recurrence for `Q_{n+1}=Q_n²+C`, tracking
   `Q_n(c)`, `Q'_n(c)`, and every pairwise critical-orbit collision
   modulo the declared prime `p`.
2. Exact polynomial coefficient convolution and Horner evaluation
   in `F_p[C]` to independently check `Q_{ell+k}-Q_ell`, its
   derivative, and all collision-pair exclusions.

All controls have horizons `ell+k ≤12`, primes `p<2³²`, explicit
rational-free finite-field operations, and negative tests for false
prime moduli, missing vectors, incorrect simple-root flags and
unbounded horizons. The fixture's eleven exact finite field flags
were independently cross-checked against the dual-number procedure.

**Scope:** These are eleven finite candidate certificates, not a
classification of the Mandelbrot set, a theorem about MLC, or a
replacement for the source's source-governed proof/acceptance process.
Their next obligation is exact integer-coefficient and squarefree
independent replay beyond the current native Int bound.

## Independent finite-math-kernels cyclotomic adapter

The new `tools/math_adapters/finite_math_kernels.py` is a source-locked
standard-library exact polynomial-arithmetic replay for the current
`conformance/cyclotomic_germ_v1.json` fixture.

It independently reconstructs each `Phi_q(X)` for `1 ≤ q ≤ 8` by
integer polynomial multiplication and exact monic division of `X^q-1`
by prior cyclotomic factors. It also checks all **22 coprime pairs
`(q,p)`** by exact reduction `Phi_q(X^p) ≡ 0 mod Phi_q(X)`, with
complete pair coverage and negative tests for altered coefficients,
incomplete vectors, nonprimitive powers and bad dimensions.

The source's rational **parabolic germ coefficients and byte encoding
are not independently derived by this first adapter**. Those are a
separate research obligation. A passing finite polynomial fixture
does not prove a theorem about all cyclotomic orders, analytic
parabolic dynamics or a consumer's canonical Mojo implementation.

## CI and mathematical-frontier priority

A source CI failure, pending run, cancelled check or unavailable
required-check coverage remains the **primary next research obligation**
even after a programme's finite mathematical fixture passes. The
scientific follow-up is retained separately as
`mathematical_next_research_obligation`. This corrects the review
finding on PR #12, where successful AB or Vizing replay could overwrite
the source's pending CI triage in the portfolio summary.

## Independent Arithmetic Bicycle finite adapter (next rollout)

The adapter `tools/math_adapters/arithmetic_bicycle.py` is a
source-SHA-bound **independent finite negative-control verifier**.
For the six cases in
`conformance/fixtures/realization-dependence-v1.json` it computes
`im(A^T mod n) intersect ker(A mod n)` by enumerating potentials,
and separately enumerates the **edge vectors** `x` subject to
`Ax=0 mod n` while checking `x in im(A^T mod n)` by integer
lattice-index equality:
`[Z^m : (A^T Z^r + n Z^m)] =
 [Z^m : (A^T Z^r + n Z^m + Z x)]`.

Both procedures use exact integer arithmetic and cover the registered
prime, prime-power and mixed-composite moduli, including 26. They compare
the **actual finite sets**, not only their orders. The strict finite
scope includes the rank-two realization-invariance counterexample at
5 and 10, and an equal-order control at 25. It also records group
annihilator profiles and exact fixture hashes.

A source fixture change, inconsistent expected order, altered matrix
or algorithm disagreement fails the weekly shard. Its artifacts retain
the counterexample; this **does not reinstate** the refuted conjecture
or prove its prospective surjective restriction. The next candidate
obligation concerns the source's surjective essential domain with
`m(E)=1`, independently of this refuted general domain.
