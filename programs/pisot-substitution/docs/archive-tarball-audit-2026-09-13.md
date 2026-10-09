# Audit of PSC_PROJECT_UPLOAD_2026_09_08.tar.gz

**Audit date:** 2026-09-13  
**Archive SHA-256:** `6fe1831a7701d054b7d726f1810e28f137e3edf162eed2fb56afe7fdfc6aadd4`  
**Disposition:** historical input already represented in
`archive/2026-09-08/`; no source-status promotion.

## Safe inspection

The compressed archive contains 66 members. Before extraction it was checked
for absolute paths, parent-directory traversal, symbolic links, hard links,
and device entries. None were present. The Python instruments were inventoried
but not executed.

The archive contains:

- the read-first remediation note and September project audit;
- patched v34 certificate notes;
- June 2026 review and adjudication notes;
- Python research instruments and JSONL census data;
- `PSC_PROOF_v15.tex/.pdf`;
- `Geometric_Mass_Balance_Two_Anchor_v9.tex/.pdf`.

It contains no `PSC_PROOF_v16` or later manuscript.

## Identity checks

The two load-bearing text files with checksums already recorded by the
repository provenance audit match exactly:

| File | SHA-256 |
| --- | --- |
| `manuscripts/PSC_PROOF_v15.tex` | `0b28c23aa8f4d006e6de3823b1c953626dad20ce58c77afa76717bd91abee6df` |
| `certificates_patched/PROOF_CERTIFICATE.md` | `c318edd7b55aacddf4a3f980eea22b183b7161249dbc0ff42d74ef93faf13b3e` |

The repository archive has 63 files and additionally preserves provenance and
rendered read-first material. The tarball supplies no new proof source absent
from the archived corpus.

## Mathematical effect

The tarball confirms the existing source decisions:

1. `PSC_PROOF_v15` is the last recovered historical manuscript.
2. The degree-three proof certificate establishes dominant capture only for
   six explicit length-seven `K2=0` seed defects.
3. It does not prove that a strict recurrent carrier contains or inherits one
   of those seeds.
4. The v34 load-bearing SCC theorem requires G1, finite balanced-pair closure.
5. No material in the tarball proves G1b-2, G1, concentration, general wedge
   productivity, the realization bridge, SCC Producer, or PSC.

Later independent reconstructions on `main` remain authoritative for G1b-1
and degree-two carrier-span propagation.

## Residual contradictions in patched v34 summaries

The patched files correct their headline status but retain contradictory
closing material.

### V34_CLOSURE.md

The title, trajectory, theorem statement, and proof spine correctly require
finite `B_sigma` as hypothesis G1. Later, however, the same file states:

- “No new hypotheses, no finite-closure conjecture”;
- finite `B_sigma` is “Proved (PSC_PROOF_v5 Thm 5.1)”;
- the Load-Bearing SCC Theorem is “Unconditional.”

Those later statements are false under the file's own retraction of the v5
predecessor-contraction argument.

### DOMINANT_K2_SOURCE_V34.md

The headline, theorem, status table, and final conclusion correctly describe
the chain as conditional on G1. Two intervening headings nevertheless say that
all external facts or hypotheses are discharged, and the caveat list again
describes v5 Theorem 5.1 as supplying finite closure.

The correct reading is controlled by the explicit status table and final
conditional conclusion: the dominant-source lemma is proved, while principal
SCC capture, full SCC transfer, and the load-bearing SCC theorem require G1.

### PROOF_CERTIFICATE.md, Section 15

The certificate's main degree-three theorem is correctly restricted to the six
explicit length-seven seeds, and its opening warning correctly denies the
SCC-level conclusion. Its appended v34 status section nevertheless says that
the degree-two route “discharges all hypotheses through the v5 finiteness
theorem” and calls that route canonical, even though the same appended material
identifies finite closure as G1 and the archive elsewhere withdraws v5
Theorem 5.1.

This appended v34 language is not part of the valid six-seed certificate and
does not discharge G1. The correct separation is:

- Sections 8–10 and the seed-level Spectral Black Box in Section 14:
  restricted six-seed degree-three theorem;
- Section 11: quarantined—the unsigned SCC transfer
  `L_C N_C = Phi_3 L_C` is false for normalized reversed children; use the
  corrected signed first-defect relation documented in
  `docs/verification-architecture.md` and
  `docs/c4-w3-low-growth-and-interface-correction.md`;
- v34 dominant-source lemma: proved;
- v34 recurrent-SCC capture and load-bearing conclusion: conditional on G1;
- no carrier-level concentration or productivity conclusion.

## Citation rule

These files remain immutable historical evidence. Do not repair them in place.

- Cite `PROOF_CERTIFICATE.md` only for the six-seed degree-three theorem in §§8–10/14; do not cite §11's unsigned SCC transfer, and disregard the appended unconditional v34 summary.
- Cite the dominant-source lemma separately from the G1-conditional SCC
  transfer.
- Never quote the unconditional rows of `V34_CLOSURE.md` as current status.
- Use `sources/issue-45/p1a-v34-concentration-audit.md` and
  `docs/claim-status-and-source-map-2026-09-13.md` for the live
  interpretation.
- If the original tarball is retained externally, identify it by the archive
  SHA-256 above.
