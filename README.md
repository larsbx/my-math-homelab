# my-math-homelab

Consolidated workspace for the larsbx mathematics research estate, organised by
the [estate-governance](https://github.com/larsbx/estate-governance) multi-program
contract: durable research programs under `programs/<id>/`, shared components
under `shared/<id>/`, each imported with its full original history and locked to
a source commit. Source repositories remain authoritative until each program's
authority is transferred.

See [ARCHITECTURE.md](ARCHITECTURE.md), [ESTATE.toml](ESTATE.toml) and the
[migration record](docs/migration/consolidation-2026-10-09.md).

## Checks

```sh
python3 kernel/workspace.py        # imports match their locks
python3 -m pytest tests            # verifier conformance
```

## Importing or refreshing a source

```sh
# add or update the row in policy/source-locks.toml (commit, commits, files);
# new sources also need an ESTATE.toml entry
python3 tools/import_source.py <id> https://github.com/<repository>.git
python3 kernel/workspace.py
```

Merge import PRs with a merge commit: squash or rebase would discard source ancestry.

## Retiring the source repositories

After the consolidation PR is merged, from a clean `main` checkout with
`gh auth refresh -s delete_repo`:

```sh
tools/retire_sources.sh                    # dry run
tools/retire_sources.sh --apply            # tag unmerged branches as archive/<id>/<branch>, transfer issues
tools/retire_sources.sh --apply --delete   # ...then delete each source
```

A source is skipped if its `main` moved since its lock (refresh it first) or it
has open PRs. Deletion is permanent; branches and issues survive only through
the first two steps.

## Automated mathematics research schedule

The `tiling-theory` programme's AKN generic-chamber atlas and singular-
strata investigation is registered in
[`policy/research-schedules.toml`](policy/research-schedules.toml) and
documented in
[`docs/research/akn-automated-research.md`](docs/research/akn-automated-research.md).

After the scheduled workflow lands on `main`,
[`AKN autonomous mathematical research`](.github/workflows/akn-math-research.yml)
records source PR and exact-head CI status every day at **04:07 UTC**,
and runs the exact chamber experiment plus independent replay **Mondays
at 04:17 UTC**. The full run also conducts bounded 105-plane singular
probes; exhaustive singular strata remain an explicit research
obligation.

The coordinator executes the verified PR head while source PR #23 is
open, then selects the inspected default-branch SHA after merge.
It retains fail-closed evidence and never promotes a mathematical
claim or edits a historically imported source tree. The source project
remains authoritative for proofs and theorem status.
