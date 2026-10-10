# v0.1.0 release checklist

A public Git repository is already usable through `Pkg.add(url = ...)`. A tagged or General Registry release requires every applicable gate below.

## Package integrity

- [ ] `julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.test()'` passes on Julia 1.11.
- [ ] A clean depot reproduces the same test result.
- [ ] `Project.toml` UUID and version match the intended release.
- [ ] The committed registry entry passes closed-field validation.
- [ ] The canonical and corrupted BigInt fixtures produce `agrees` and `disagrees`, respectively.

## Cross-language evidence

- [ ] The authoritative Mojo checker emits the committed canonical bytes.
- [ ] The compared Mojo source commit is recorded.
- [ ] The oracle run records Julia version, source commit, input digest, and output digest.
- [ ] No result is labelled `accepted`, `proved`, or `authorized`.

## Governance

- [ ] Woodpecker records the canonical CI result.
- [ ] The reviewed GitHub state is reconciled onto canonical Forgejo without overwriting Forgejo-only work.
- [ ] The canonical Forgejo commit is recorded in the release evidence.
- [ ] Repository licensing is chosen explicitly by the owner; do not infer a license from public visibility.

## Publication

- [ ] Tag `v0.1.0` only from the reconciled canonical commit.
- [ ] Update installation documentation to prefer the tag after it exists.
- [ ] Publish to Julia General only after the license and all package-integrity gates are resolved.
- [ ] Record registration or rejection output without treating registration as mathematical validation.
