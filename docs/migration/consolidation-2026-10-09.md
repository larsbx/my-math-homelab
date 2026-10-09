# Consolidation into my-math-homelab (2026-10-09)

Contract: estate-repository-v2 with multi-program-repository-v1, governance rev
`5ea47dec8086eab6a1dad6fd239688d20ea89891`. Locks: [`policy/source-locks.toml`](../../policy/source-locks.toml).

## Method

Each public source was imported with `tools/import_source.py`: an unsquashed
subtree merge (`merge -s ours` + `read-tree --prefix`) whose second parent is the
locked source head, so every original commit keeps its id and merge topology.
Programs then receive a `PROGRAM.toml` rendered from their lock, in its own commit.
No imported file was edited; nested `ESTATE.toml`, CI workflows, vendored copies
and claim registers are preserved as-is and not executed from the root.

This follows migration-sequence step 2 of the multi-program contract and the
`finite-dynamics` pilot (julia-oracle import), extended to the whole math estate.

## Decisions taken (proposed, pending owner adoption)

| Decision | Rationale |
| --- | --- |
| 14 programs, 2 shared components | research repositories are programs; `finite-math-kernels` and `math-vizops` are consumed by named programs |
| All sources public (owner decision, 2026-10-09) | closure-fiber, finite-julia and giant-fibers were first published metadata-only, then upgraded to full history imports once the owner stated every math repository is public |
| `finite-dynamics` superseded, not nested | a workspace inside a workspace would break the single `programs/` collection; its four programs are imported from the original sources and its pilot evidence stays at its source |
| `oracles` excluded | empty (title-only README); a root would be an empty silo |
| Root `acceptance_authority = false` | sources retain authority; this workspace's only owned check is import fidelity |
| `layout.status = "transitional"` | migration steps 3–6 remain pending (`ESTATE.toml` `[migration].next`) |
| Short program ids, pilot namespaces kept | FM, FJ, BFC, JO unchanged from `finite-dynamics`; new namespaces are unique |

## Not done here

- Reproducing each program's original gates from the root (Mojo/pixi, Lean, Julia, Python suites).
- Reconciling the vendored `finite-math-kernels` copies in FM, FJ, BFC, NL, PS, SAP and math-vizops with `shared/finite-math-kernels`.
- Transferring issues, releases and authority; archiving sources. No source is archived.

## Verification

`python3 kernel/workspace.py` checks every lock (ancestry, commit count, exact
tree, private boundary, manifest agreement); `tests/` holds a baseline and one
rejecting mutation per rule; CI runs both plus the pinned estate audit.
