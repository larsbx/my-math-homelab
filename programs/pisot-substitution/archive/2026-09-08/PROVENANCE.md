# Provenance — 2026-09-08 remediation bundle

Verbatim contents of `PSC_PROJECT_UPLOAD_2026_09_08.tar.gz`, preserved here so the
research state survives outside a session container. Nothing in this directory has
been edited.

Read in this order:

1. `README_READ_FIRST_2026_09_08.md` — supersedes `SESSION_2026_06_10_SUMMARY.md`.
2. `notes_2026_06/SESSION_2026_06_13_LEDGER.md`
3. `PROJECT_AUDIT_2026_09_08.md`

## Canonical documents

| Document | Status |
|---|---|
| `manuscripts/PSC_PROOF_v15.tex` / `.pdf` | Canonical. Six external review rounds. |
| `manuscripts/Geometric_Mass_Balance_Two_Anchor_v9.tex` / `.pdf` | Companion (cohomological line). |
| `certificates_patched/*` | The corrected certificates: "unconditional" → "conditional on finite `B_σ` (G1)". |

PSC_PROOF_v14 and earlier are superseded **with a known error** — they state
finiteness of `B_σ` as a proved theorem via the withdrawn predecessor contraction.
Do not cite them.

## Instrument corrections that must be used

- `instruments/legal_swaps.py` — G2/structural BPA runs must seed from
  legality-filtered swaps; all-swap seeding over-counts recurrent SCCs in ~2% of
  specimens. Termination is seed-invariant.
- `instruments/exact_lengths.py` — exact ℚ(β) genuineness; the float census was
  verified sound (0 mismatches).
- The offset-propagation matrix is **M** (`M[i,j]` = number of `i` in `σ(j)`), not
  `Mᵀ` — see `instruments/trapped_scc_search.py`.

## Relationship to the verification layer

`docs/verification-architecture.md` records which claims in these documents are
re-derived by the Mojo kernel, model-checked in TLA+, or proved in Lean 4, and
which are neither. It also lists three discrepancies found while doing so.
