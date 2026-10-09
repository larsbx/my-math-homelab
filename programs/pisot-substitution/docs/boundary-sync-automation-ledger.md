# Boundary synchronization automation ledger

**Status:** record of the initial boundary-sync automation. Current priorities
and dependencies are in `docs/proof-ladder.md`; implementation policy is in
`AGENTS.md`.

## Added surface

- `docs/boundary-synchronization.md` documents the Boundary Synchronization Lemma, the synchronizing-end criterion, and the nonsynchronizing trap normal form.
- `reference/psc_research/` contains lightweight Python BPA and boundary-sync utilities.
- `kernel/boundary_sync_sweep.mojo` provides the canonical seeded sweep driver;
  the initial Python script was removed when this computation was ported.
- `tools/audit_manuscript.py` guards against known stale manuscript claims.
- `.github/workflows/boundary-sync.yml` runs the focused lightweight checks.

## Regression targets

The lightweight tests cover:

- balanced-pair decomposition basics;
- Tribonacci and flipped-Tribonacci boundary synchronization;
- Smith-style partial synchronization, where neither endpoint map is globally synchronizing but the Boundary Synchronization Lemma still applies;
- audit rejection of known stale statements.

## Current caveat

Boundary synchronization provides a normal form for the finite-BPA/SCC route.
It does not discharge seedwise overlap productivity on the shortest PDS route;
use the live proof ladder for the active open premises.
