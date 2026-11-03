# AKN exact-atlas autonomous research — my-math-homelab

**Recorded:** November 1, 2026  
**Home:** `larsbx/my-math-homelab`  
**Programme:** `tiling-theory` (`TT`)  
**Source authority:** `larsbx/tiling-theory-research`; retained, NOT transferred  
**Registry:** `policy/research-schedules.toml`  
**Scheduler:** `.github/workflows/akn-math-research.yml`  
**Coordinator:** `tools/research_schedule.py`

## Research aim and current hypotheses

The source's stacked PR #23 (on #22) studies the exact
`Z[tau]` arrangement of 135 candidate hyperplanes, 15 normal
directions and nine levels per direction. The preliminary full generic
computation reports 21,840 open chambers, exactly 24 orbits of
complete incident-cell stars under the full icosahedral group `I_h`,
and **six stabilizer-subgroup conjugacy types**. These are separate
invariants: the 24 orbits are *not* 24 subgroup conjugacy classes.

Original source records:

- `https://github.com/larsbx/tiling-theory-research/pull/22` —
  exact 576-center radius-two generic feasibility census (286 / 287 / 3),
  awaiting its own exact-head acceptance.
- `https://github.com/larsbx/tiling-theory-research/pull/23` —
  generic open-chamber enumerator, independent 2D arrangement region-count
  checker, complete witness packet, stabilizer-subgroup conjugacy
  classification and exact singular-plane pilot. **Draft pending review.**
- `https://github.com/larsbx/tiling-theory-research/issues/24` —
  exhaustive singular-stratum proof obligation.

These figures are **preliminary finite evidence, not an accepted
universal theorem**. Arbitrary matching rules, aperiodicity, radius
minimality, other periodic lifts and all singular boundary selection
conventions are outside this certificate.

## Executing the research programme

`my-math-homelab` owns orchestration, periodic investigation and
evidence indexing; the source project still owns its claims, proofs,
releases and source-code changes. The historically imported
`programs/tiling-theory/` tree is **immutable under its source lock**
in this PR. Do not copy new scripts into that tree or modify its
`PROGRAM.toml`; refreshing imports requires the established
history-preserving importer and a separate reviewed PR.

| Trigger | UTC schedule | Action |
| --- | --- | --- |
| Daily source monitor | `07 04 * * *` | Read PR #22/#23 exact GitHub heads, source issue #24, and available exact-head Actions runs; retain JSON status/evidence. |
| Weekly full mathematical research | `17 04 * * 1` (Monday) | Fetch PR #23 **exact** head SHA, reproduce full 135-plane chamber candidate and independent proof replay, classify 24 star orbits and six stabilizer conjugacy types, then run the source-owned exhaustive singular checker when available. Historical source revisions retain the 105-probe replay. |
| Pull request | On changes to registry, coordinator, tests or workflow | Validate schedule and authority invariants; record live source status. Do not run expensive full experiment automatically on every workspace PR. |
| Manual dispatch | `status` or `full` | Replay the same procedure on demand with source provenance retained. |

While PR #23 remains open, its head is inspected through GitHub's API
and fetched via `refs/pull/23/head`. After it is merged, the
coordinator instead inspects and fetches `refs/heads/main` from the
source repository. **In both cases, the fetched SHA must match the
inspected exact revision.** A race, unexpectedly forked PR, or
closed-unmerged research branch fails closed. The exact SHA and source
ref are written to `research-cycle.json`; the registration SHA is
historical provenance, not a stale frozen execution target.

The complete singular protocol verifies the source revision and the two
evidence digests before reporting singular coverage. It preserves the source
driver's cell-pattern counterexamples and keeps boundary-convention
realizability separate from geometric stratum completeness.

Artifact output includes the source revision, exact witness packet,
independent replay, forced/closed-possible singular cell experiments,
contradictions, stderr and traceback on failures. Artifacts are
configured for 90-day retention. No identity/credentials are passed
to the source research subprocess.

The weekly job is not considered accepted merely because it starts,
because its GitHub Actions status is `queued`, or because a previous
revision passed. A successful candidate requires the exact-head
independent checker and expected mathematical invariants to pass.
Source PR reviews and governed mathematical claim registration are
separate acceptance gates.

## Current research next steps

1. Confirm PR #22 and PR #23 exact-head hosted verification and
   reconcile outstanding review threads without silently resolving them.
2. Obtain complete and independently checked 21,840 generic witnesses
   at the exact source revision; preserve the original preliminary
   manifest and any divergent reproducible counterexample.
3. Investigate the 105 exact internal-plane probes and distinguish
   forced, possible (closed-window) and excluded cells.
4. Pursue issue #24: enumerate **every nonempty relative-open
   singular stratum** (2D faces, 1D intersections, and 0D vertices),
   produce exact witnesses, and independently verify complete
   stratification under explicit boundary membership conventions.
5. Expand research planning to additional periodic constructions,
   radius-two obstruction classes, and potential counterexamples,
   without promoting a bounded search to a universal proof.

## Local reproductions

```sh
python3 -m unittest discover -s tests -p test_research_scheduler.py -v
python3 tools/research_schedule.py --mode status --out /tmp/akn-status
python3 tools/research_schedule.py --mode full \
  --out /tmp/akn-full \
  --checkout /tmp/akn-source-pr23
```

GitHub scheduled workflows execute **only when the workflow file
is present on the repository default branch**. Before this scheduling
PR is merged, the daily and weekly crons are recorded but not active.
The scheduler is independent of ChatGPT automations and does not
need an open conversation.

## Governance contract

A mathematical research cycle follows:

`hypothesis → exact experiment → independent verifier →
counterexample/failure retention → new finite obligation → governed review`.

A green workflow is evidence about its declared finite predicate, not
automatic authority to assert a perfect matching-rule or aperiodicity
theorem. Automatic commits, issue resolution, merges and mathematical
claim promotions are intentionally disabled.
