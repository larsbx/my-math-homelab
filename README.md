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

## Importing a source

```sh
# add a row to policy/source-locks.toml (commit, commits, files) and ESTATE.toml
python3 tools/import_source.py <id> https://github.com/<repository>.git
python3 kernel/workspace.py
```

Merge import PRs with a merge commit: squash or rebase would discard source ancestry.
