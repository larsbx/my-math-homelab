# H3 letter-graph attack: a transpose bug, caught and corrected (2026-06-13)

## Attempted route
The 06-10 queue item: classify when the letter graph V of a trapped component admits
"zero-correction cycles through the mixed-letter state" — i.e. find the trapped shape as a
closed anchor-free cycle in the state graph, attacked via the letter-pair graph and affine
offset fixed points.

## What happened (do-not-repeat)
Built `letter_graph.py`: letter-pair vertices (i,j), edges from position pairs carrying
correction c = pp[j][q] − pp[i][p], and solved the per-cycle affine offset map
δ ↦ (M_off)^L δ + S(γ) for fixed points, testing orbit genuineness + anchor-freeness.

**It reported 11,176–19,532 "trapped candidate" cycles across nearly all specimens** —
flatly contradicting the established result that Q∞ holds (1,083 sound certificates, no
trapped object). Two compounding errors:

1. **TRANSPOSE BUG (the decisive one).** The offset-propagation matrix is
   AT[c][a] = #c's in σ(a), which under `psc_core.incidence_matrix` (M[i,j] = #i's in σ(j))
   **equals M**, NOT M.T. `letter_graph.py` used `MT = M.T`. With the wrong matrix the
   forward orbits are garbage. Cross-checking the candidate (0,(2,−1,0),1) against qinf2's
   exact child map (AT=M) showed its cone reaches an ANCHOR in 5 states — no trapped object.
2. **WRONG OBJECT.** Even with the right matrix, the affine fixed point of a single routing
   counts periodic points of one branch, not the trapped object. The trapped object is a
   forward-closed anchor-free SET (all branches), which is exactly what qinf2 certifies. A
   genuine anchor-free cycle can coexist with an anchor in the cone via another branch.

## Resolution
`trapped_scc_search.py` (correct AT=M, forward-closed cone, backward reachability from
anchors): **0 failures across 50 PIP specimens** — every genuine Δ-state's cone reaches an
anchor, reproducing qinf2's certificates independently. No trapped letter-cycle exists.

## Net
No mathematical result; a corrected instrument and a logged bug. The transpose convention
(offset matrix = M, since incidence is M[i,j]=#i in σ(j)) is now explicit. The letter-graph /
affine-fixed-point framing is NOT a sound trapped-object detector and should not be reused;
the sound object is the forward-closed anchor-free cone (qinf2). Q∞ continues to hold across
the corpus with the corrected instrument.

## Lesson (consistent with project discipline)
A result contradicting an established, well-certified fact (Q∞ certificates) is a bug signal,
not a discovery. The discipline — cross-check against the trusted instrument on a single
witness before believing a surprising positive — localized it to one matrix transpose. Census
that disagrees with a prior solid certificate is the instrument's error until proven otherwise.

## Artifacts
`letter_graph.py` (BUGGY framing, retained with corrected matrix + warning), 
`trapped_scc_search.py` (correct, confirms 0 trapped), diagnostic scripts
`letter_graph_diagnose.py`, `letter_graph_resolve.py`, `letter_graph_crosscheck.py`,
`pin2.py`.
