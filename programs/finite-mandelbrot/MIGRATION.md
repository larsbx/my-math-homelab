# Repository migration provenance

This repository is the dedicated and canonical home for the finite-regime Mandelbrot research program.

## Source pin and history import

The migration is pinned to `larsbx/NLAP-JT` source commit `d00c64d4ec703564a2d8ceb606279d2025f2352a`.

The imported source history has `.github/workflows/` removed from the imported commit graph solely because the GitHub Actions token used for the history join had `contents: write` but not GitHub's separate workflow-write permission. Workflow-only empty commits were pruned by that rewrite. No research source, tests, paper, specification, or governance content was omitted. The canonical workflow was restored afterward through GitHub's authorized contents API.

## Cutover completion

The migration PR was merged to `main` on September 16, 2026 as merge commit `8d9a1bea240416bb26090a19cff59faaa4dbd7bb`.

The merged `main` branch then passed the canonical `finite-regime-core-audit`, including Mojo build and smoke execution, vendored digest checks, the exact-arithmetic property oracle, no-trig and no-points audits, the full 426-test Python suite, terminology and claim governance, manuscript-language checks, backend and exact-arithmetic audits, polynomial reference identities, and interval-exclusion reference checks.

The former migration branch `migration/nlap-jt-foundation` was fast-forwarded to the merge commit after cutover so it no longer represents a divergent repository state.

The original `larsbx/NLAP-JT` repository was marked historical and its legacy CI workflow was disabled after cutover. It is retained only for historical links and pre-migration history. New source changes, specifications, proofs, tests, CI changes, issues, and pull requests belong here.

## Repository identity and invariant preservation

Consumer-owned current-tree repository identity is migrated to `larsbx/finite-mandelbrot-research`. Mathematical claims and proof status were not changed by the repository move. In particular, the exact rational/interval arithmetic boundary, no-transcendental-trigonometry policy, no-circle/rank-2 rule, no-ideal-point rule, Mojo-first theorem-kernel policy, theorem-tag imports, and C1 open-frontier status remain binding.

Vendored code under `vendor/mojo/finite_exact/` and `vendor/python/claim_governance/` was intentionally kept byte-for-byte unchanged so that the SHA-256 pins in `vendored.toml` remain valid. A vendored upstream comment may therefore retain the former consumer name until the upstream `finite-math-kernels` package is revised and re-pinned.
