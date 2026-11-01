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
The arithmetic-bicycle track now has a pinned independent finite replay,
using the [experiment contract](independent-experiment-contract.md).
The other **14 tracks lack a configured independent experiment**: their
research-specific experiments, independent checkers and execution policies must be separately reviewed and registered before execution.
The scheduler makes that onboarding obligation visible in every report.
Even AKN does not prove a universal theorem by running a finite job.

## GitHub schedule (UTC)

| Trigger | Scope | Activity |
| --- | --- | --- |
| Daily `43 4 * * *` | Every active repo | Inspect current default-branch SHA, source exact-file evidence, PRs, issues and CI; preserve a per-programme immutable-revision record. |
| Tuesday `47 5 * * 2` | Every active repo, four shards | Conduct source-bound evidence/falsification triage and issue-specific mathematical next-step planning; execute the reviewed arithmetic-bicycle adapter once in shard 0; flag remaining adapter gaps. |
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
| arithmetic-bicycle | Preserve the rank-two refutation, test the proved surjective domain, and investigate extra nonsurjective lattice data. | Pinned independent finite adapter; hosted acceptance pending |
| bulb-ford | Reproduce finite exact P0/P2/P6 bulb/Ford evidence without using analytical limits as finite proof. | Needs reviewed adapter |
| closure-fiber | Investigate exact identity fibers and literature dependence in algebraic-group closure. | Needs reviewed adapter |
| finite-julia | Certificate-carrying dynamical-plane finite tests and consumer compatibility. | Needs reviewed adapter |
| finite-mandelbrot | Exact critical-orbit certificates; keep MLC as open. | Needs reviewed adapter |
| giant-fibers | Finite-field Descartes fiber-count tests versus the proposed heavy-fiber formula. | Needs reviewed adapter |
| julia-oracle | Differential oracle reproducibility, cross-consumer disagreement, no claim authority. | Needs reviewed adapter |
| langlands | Reproduce small exact Hecke/Galois calibration claims without conflating imported results. | Needs reviewed adapter |
| novelty | Independently audit Lean/evidence/literature boundaries for novelty candidates. | Needs reviewed adapter |
| pisot-substitution | Reconcile precise open PSC boundary lemmas, tests and claim integration on current heads. | Needs reviewed adapter |
| pisot-vijayaraghavan | Bounded exact auxiliary calculations, with the classical PV problem still open. | Needs reviewed adapter |
| s-adic-pisot | Independently verify theorem-scope assumptions and finite Selmer/Brun censuses. | Needs reviewed adapter |
| tiling-theory | 21,840 generic AKN chambers, 24 star orbits, six stabilizer conjugacy types, 105 singular probes. | Specialized exact executor; hosted acceptance still required |
| vizing-domination | Exact graph-census representatives and provenance of the missing larger catalogue. | Needs reviewed adapter |
| finite-math-kernels | Cross-consumer exact kernel/canonical-record compatibility. | Shared-component adapter needed |
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

This proves file/revision provenance, **not the truth of mathematics
written in those files**. A CI failure or pending run is flagged.
A stale imported tree is registered as provenance drift, never modified
automatically. Missing files, malformed registration, unavailable APIs
and unexpected source revisions fail closed and retain errors.

Evidence is published as machine-readable per-programme JSON plus
`portfolio-index.json`, using four disjoint weekly shards to limit
resource use. Artifacts are retained for 90 days under the GitHub
Actions policy.

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
opt-in research execution path. Arithmetic-bicycle is the first local
adapter candidate under review under `policy/math-experiments.toml`; it executes no source
scripts. Additional opt-in runners should be
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
triage*. AKN retains its specialist. Arithmetic-bicycle now has a bounded
independent finite replay integrated into its existing weekly shard, pending PR review
and hosted acceptance. The other 14 adapters remain an explicit backlog.
See [independent-experiment-contract.md](independent-experiment-contract.md)
for the reusable implementation and acceptance pattern.
