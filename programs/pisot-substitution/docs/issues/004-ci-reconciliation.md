# Issue 004: restore or reconcile estate CI

## Problem

The repository was discovered to be a pre-existing PSC research estate, not a fresh empty repository. The historical `.github/workflows/ci.yml` contained full estate checks including provenance, Python governance, Mojo kernels, and exact census jobs.

## Risk

A lightweight boundary-sync workflow is useful, but it must not replace the estate CI.

## Acceptance

- Current `.github/workflows/ci.yml` is compared against commit `e0bff9eb1a12cca1ee885918148156b9d4fbc0a1`.
- Any unintentionally removed estate gates are restored.
- `.github/workflows/boundary-sync.yml` remains as an additive focused check.
- A note is added to `README.md` or `docs/automation-protocol.md` explaining the two-tier CI strategy.
