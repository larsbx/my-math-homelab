#!/usr/bin/env python3
"""Build proof/tla/ledger.json from the record table below and regenerate every ledger surface.

The table is the single source of the proof-dependency ledger: one proof
record per named result (kind, statement, source, dependencies, tags), the
assumption sets the TLC models bind, the status labels the index prints, and
the aliases and prose surfaces each claim keeps in claim_governance.toml.
`tools/proof_records/generate_ledgers.py` (vendored from larsbx/finite-math-
kernels, docs/ledger-generation-spec.md there) renders proof/tla/Ledger.tla, one
TLC model per assumption set, docs/ledger-index.md, the typed relationship
graph docs/claim-relationship-graph.json, and the generated [[claim]] block of
claim_governance.toml. CI runs `--check`, so none of those surfaces can drift
from this table or be hand-edited.

Usage: make_ledger.py [--check]
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from proof_records import generate_ledgers as gl  # noqa: E402
from proof_records.records import Edge, Kind, Record, identified  # noqa: E402

LEDGER = ROOT / "proof" / "tla" / "ledger.json"
POLICY = ROOT / "claim_governance.toml"
SCOPE = "primitive irreducible Pisot substitutions in the standing regime"
MANUSCRIPT = "manuscripts/PSC_balanced_pair_state_2026-09-13.tex"
MAP = "docs/claim-status-and-source-map-2026-09-13.md"
LEDGER_DOC = "docs/conjecture-ledger.md"
LADDER = "docs/proof-ladder.md"
ROADMAP = "docs/research-roadmap-2026-09-21.md"
ZIPPER = "docs/p1b-strict-zipper-periodic-pair-2026-10-02.md"
FIBRE = "docs/p1b-periodic-pair-fibre-literature-gate-2026-10-02.md"
BOX = "docs/pds-certificate-from-the-box-automaton-2026-10-07.md"
LEFTMOST = "docs/p1b-leftmost-chain-periodic-pair-2026-10-05.md"
REVIEWED = "independently reviewed 2026-10-08 (docs/side-notes-ledger.md), human review pending"
BOX_LC_REVIEW = "docs/review-box-leftmost-ledger-2026-10-08.md"
BOX_LC_BASELINE = "cb9db58c9e25209c2a54ccd6955b509af88e8356"
BOX_LC_RECONCILED_BASELINE = "33a1b8b6cffc10c7f1e5be41a22325897a5072e4"
RECONCILIATION = "docs/proof-ledger-reconciliation-2026-10-08.md"
BOX_LC_REVIEWED = frozenset({
    "BoxCycleContainment", "BoxAutomatonCertificate", "PisotMeyerProperty",
    "OverlapCoincidenceCriterion", "BoxAutomatonPDSCertificate",
    "LeftmostChainCycleStructure", "LeftmostChainG1Certificate",
})

# name -> (kind, statement, source or reason, dependencies, tags)
# Dependencies are one-way proof sufficiency, never a converse implication
# (proof/tla/ProofArchitecture.tla). A proved node whose dependencies are open is a
# conditional theorem: its implication is proved, its premises are not.
T, I, P = Kind.REPOSITORY, Kind.IMPORTED, Kind.PENDING
TABLE: dict[str, tuple[Kind, str, str, tuple[str, ...], tuple[str, ...]]] = {
    # --- symbolic side, repository theorem-grade ------------------------------------
    "DefectTheorem": (T, "det M_sigma != 0 gives full incidence rank and letter injectivity, so the defect theorem applies to the image code",
                      f"{MANUSCRIPT}, standing algebraic setup", (), ()),
    "UniqueDecodability": (T, "the substitution images form a uniquely decodable code", f"{MANUSCRIPT}, Theorem 2.8", ("DefectTheorem",), ()),
    "UDForPowers": (T, "the images of every power sigma^r form a uniquely decodable code", f"{MANUSCRIPT}, power corollary of Theorem 2.8", ("UniqueDecodability",), ()),
    "LocalWitnessInjectivity": (T, "local witness injectivity on the symbolic side", f"{MANUSCRIPT}, symbolic side", (), ()),
    "MassBalanceK2Obstruction": (T, "the mass-balance obstruction for K2 on the symbolic side", f"{MANUSCRIPT}, symbolic side", (), ()),
    "AlgebraicEmbedding": (T, "the algebraic embedding of the symbolic side", f"{MANUSCRIPT}, symbolic side", ("UniqueDecodability",), ()),
    "WedgeBound": (T, "the wedge bound", f"{MANUSCRIPT}, symbolic side", ("AlgebraicEmbedding", "MassBalanceK2Obstruction"), ()),
    # --- seed spectral module ---------------------------------------------------------
    "PhiSemisimplicity": (T, "Phi_3 acts semisimply on the seed spectral module", "archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md, section 3 semisimplicity lemma; not formalized in Lean", (), ()),
    "ThetaIntertwining": (T, "Theta intertwines the seed spectral operators", "archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md, section 5 certified intertwining identity; kernel/verify.mojo check C7; not formalized in Lean", (), ()),
    "SeedCentralizer": (T, "the seed centralizer is as certified", "archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md, sections 5-7; proof/PscVerif/PscVerif/Centralizer.lean proves the centralizer contradiction only", ("ThetaIntertwining", "PhiSemisimplicity"), ()),
    "Target1": (T, "Target 1 of the seed spectral module", "archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md, section 7; proof/PscVerif/PscVerif/Centralizer.lean Psc.target1 proves the rational centralizer form only", ("SeedCentralizer",), ()),
    "DominantCubicCapture": (T, "dominant cubic capture for the explicitly certified seeds",
                             "archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md, sections 8-10 (historical restricted theorem)", ("Target1",), ()),
    "SpectralBlackBox": (T, "the seed-module spectral black box follows from Target 1 and dominant cubic capture",
                         "archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md, sections 8-10", ("Target1", "DominantCubicCapture"), ()),
    # --- v33 / v34 historical route ---------------------------------------------------
    "InterBlockCancellation": (T, "inter-block cancellation on the v33/v34 route", f"{MANUSCRIPT}, historical route", (), ()),
    "DominantK2Source": (T, "the dominant K2 source on the v33/v34 route", f"{MANUSCRIPT}, historical route", (), ()),
    "LoadBearingSCC": (T, "under G1 the load-bearing SCC of the v33/v34 route exists", f"{MANUSCRIPT}, historical route",
                       ("G1", "DominantK2Source", "InterBlockCancellation"), ()),
    # --- live graph / C3-C4 reductions ---------------------------------------------
    "SinkSCCReduction": (T, "under G1, nonproductivity reduces to a finite closed sink recurrent noncoincident SCC", "docs/sink-scc-reduction.md", ("G1",), ()),
    "C3Locality": (T, "higher newborn cuts are one-step block-local", "docs/c3-locality-reduction.md", (), ()),
    "EndpointCore": (T, "the endpoint-core normal form classifies the finitely many endpoint maps", "docs/c4-endpoint-core-program.md", (), ()),
    "GlobalEndpointSync": (T, "global endpoint synchronization eliminates endpoint types A and B", "docs/c4-barge-diamond-endpoint-eliminator.md", ("EndpointCore",), ()),
    "SignatureReduction": (T, "the endpoint-quotient signature reduction", "docs/c4-signature-reduction.md", ("EndpointCore",), ()),
    "ParikhIntertwiner": (T, "for a finite closed nonproductive SCC the Parikh intertwiner identity P N = M P holds", "docs/c4-parikh-intertwiner.md", (), ()),
    "OrientationMonodromy": (T, "the orientation cocycle and oriented double cover dichotomy", "docs/c4-orientation-monodromy.md", (), ()),
    "OrientationSpectrum": (T, "the orientation-even/odd spectral decomposition with its Perron comparison", "docs/c4-orientation-spectrum.md",
                            ("OrientationMonodromy", "ParikhIntertwiner"), ()),
    "DefectIntertwiner": (T, "the signed scattered-subword defect intertwiners in degrees two and three", "docs/c4-lowest-defect-intertwiner.md", ("OrientationMonodromy",), ()),
    "W3LowGrowth": (T, "the universal low-growth classification in W_3", "docs/c4-w3-low-growth-and-interface-correction.md", ("DefectIntertwiner", "PhiSemisimplicity"), ()),
    "Degree4Floor": (T, "the degree-4 first-defect reduction", "docs/c4-degree4-free-lie.md", ("DefectIntertwiner",), ()),
    "Mod3Sieve": (T, "the arbitrary-degree multidegree spectral sieve", "docs/c4-multidegree-spectral-sieve.md", ("DefectIntertwiner",), ()),
    "ParitySieve": (T, "the degree-2 parity sieve for a strict closed nonproductive SCC with nonzero K2", "docs/c4-degree2-parity-sieve.md", ("DefectIntertwiner",), ()),
    "MidArea": (T, "the degree-2 mid-area factorization identity", "docs/c4-degree2-midarea-factorization.md", (), ()),
    "MeanAreaLift": (T, "the three-state mean-area lifting obstruction", "docs/c4-degree2-meanarea-integrality.md", ("MidArea", "ParikhIntertwiner"), ()),
    "LatticeLift": (T, "the degree-2 integral lattice lifting certificate", "docs/c4-degree2-lattice-lift.md", ("MeanAreaLift",), ()),
    # --- Level-2 gate ------------------------------------------------------------------
    "G1b1BoundedDiscrepancy": (T, "all reachable swap-state prefix-difference walks are uniformly bounded",
                               "sources/issue-45/g1b1-bounded-discrepancy-reconstruction.md; manuscript Theorem 4.4; PR #69", (), ()),
    "G1b2RenewalFiniteness": (P, "only finitely many realizable irreducible balanced pairs occur inside the established discrepancy bound",
                              "open conjectural gate; manuscript Level-2 open problem; issue #44", ("G1b1BoundedDiscrepancy",), ()),
    "G1FromRenewal": (T, "G1b-1 and G1b-2 together give finite BPA", f"{MANUSCRIPT}, Proposition 4.11", ("G1b1BoundedDiscrepancy", "G1b2RenewalFiniteness"), ()),
    "G1": (T, "finite BPA (G1)", f"{MANUSCRIPT}, Propositions 4.11, 5.46 and 5.47 and open-problem list; {BOX}, consequence (c)",
           ("G1FromRenewal", "G1OverlapRoute", "G1HalfCoincidenceRoute", "G1FormalProductivityRoute"), ("status:open",)),
    # --- overlap route (finite graph, no G1) ----------------------------------------
    "SwapOverlapFiniteness": (T, "every swap seed has a finite exact overlap graph",
                              "docs/overlap-finiteness-and-coincidence-density-2026-09-13.md; manuscript Theorem 4.22; PR #72", ("G1b1BoundedDiscrepancy",), ()),
    "OverlapFullRank": (T, "a nonempty child-closed noncoincidence set has full rational intersection-vector rank", f"{MANUSCRIPT}, Corollary 5.34; PR #76", (), ()),
    "OverlapBadSCCNormalForm": (T, "failure of overlap productivity has a finite child-closed recurrent nonproductive SCC with PF(N_S) = beta, full-rank V_S, and spec(M) inside spec(N_S)",
                                f"{MANUSCRIPT}, Proposition 5.43; docs/p1-overlap-minimal-obstruction-2026-09-14.md, Proposition 2.1; PR #88",
                                ("SwapOverlapFiniteness", "OverlapFullRank"), ()),
    "OverlapBoundaryZipperDichotomy": (T, "a bad SCC contains an offset-zero non-eventually-coincident pair or every child factorization is a strict no-tie prefix-grid zipper",
                                       f"{MANUSCRIPT}, Proposition 5.44 and Lemma 5.45; docs/p1-overlap-minimal-obstruction-2026-09-14.md, Proposition 3.1; PR #88",
                                       ("OverlapBadSCCNormalForm", "AlignedOverlapsAreStrongCoincidence", "BoundaryCoincidenceCriterion"), ()),
    "OverlapProductivity": (P, "for every PIP substitution one swap seed on distinct tile types has only productive reachable overlaps",
                            "open conjectural gate, the current shortest-path gate; manuscript Open Problem 5.35; issue #84", (), ()),
    "AllSeedOverlapProductivity": (P, "for every PIP substitution every overlap reachable from every swap seed is productive",
                                   "open conjectural gate, stronger than the one-seed gate; manuscript Open Problem 5.35 (all-vertex form)", (), ()),
    "G1OverlapRoute": (T, "productivity of the seed-patch overlap graph from every swap seed gives finite BPA, by bounding every reachable state by 2 beta^D ell_max",
                       f"{MANUSCRIPT}, Proposition 5.46; docs/bpa-termination-by-overlap-depth-2026-10-02.md, Proposition 1; mechanism of Sirvent-Solomyak 2002, Theorem 5.6 (docs/bpa-overlap-depth-literature-gate-2026-10-02.md)", ("AllSeedOverlapProductivity", "SwapOverlapFiniteness"), ()),
    "AllSeedStrictZipperExclusion": (P, "for every PIP substitution no closed nonproductive strict-zipper set is reachable from any swap seed",
                                     "open conjectural gate; the all-seed form of the strict-zipper branch of Open Problem 5.35 (manuscript Proposition 5.44(iii)(b)); issue #139", (), ()),
    "G1HalfCoincidenceRoute": (T, "exclusion of reachable strict zippers from every swap seed gives finite BPA, every reachable state being at most 2 beta^K' ell_max long",
                               f"{MANUSCRIPT}, Proposition 5.47; docs/bpa-termination-by-overlap-depth-2026-10-02.md, Proposition 4 and Corollary 5; half-coincidence form of Sirvent-Solomyak 2002, Theorem 5.6", ("AllSeedStrictZipperExclusion", "SwapOverlapFiniteness"), ()),
    "CoincidenceDensityOne": (T, "seedwise overlap productivity gives coincidence density one and a dense eventual-coincidence good set",
                              f"{MANUSCRIPT}, Lemma 5.36; PR #77", ("OverlapProductivity", "SwapOverlapFiniteness"), ("status:proved",)),
    "AllStatesProductiveViaOverlaps": (T, "under seedwise overlap productivity every reachable balanced-pair state is productive",
                                       f"{MANUSCRIPT}, overlap route", ("OverlapProductivity", "SwapOverlapFiniteness"), ()),
    "DensityToPDSBridge": (I, "dense eventual coincidence gives pure discrete spectrum", "Barge, Stimac, and Williams; manuscript Imported Theorem 5.37; PR #77", (), ()),
    "PDSOverlapRoute": (T, "one-seed overlap productivity implies pure discrete spectrum, without G1 and without a seed-legality hypothesis",
                        f"{MANUSCRIPT}, Theorem 5.38", ("CoincidenceDensityOne", "DensityToPDSBridge"), ()),
    "AlignedOverlapsAreStrongCoincidence": (T, "offset-zero and right-aligned seed overlaps are productive exactly in the prefix/suffix strong-coincidence cases",
                                            f"{MANUSCRIPT}, Proposition 5.39; PR #82", (), ()),
    "BoundaryCoincidenceCriterion": (T, "an overlap reaches an offset-zero descendant exactly on an exact prefix-Parikh / common-left-endpoint hit",
                                     f"{MANUSCRIPT}, Proposition 5.40 and Corollary 5.41; PR #82", (), ()),
    # --- strongest Level-3 spectral route ----------------------------------------------
    "ConcentrationAuxB": (P, "no strict component with K2 = 0 exists (concentration / aux-B)", "open conjectural gate, not source-pending; manuscript open problem; issue #43",
                          ("G1", "SinkSCCReduction"), ()),
    "GaloisWedgePropagation": (T, "nonzero K2 gives full rational wedge span (degree-two carrier span)",
                               f"{MANUSCRIPT}, Proposition 5.20; docs/galois-aux-b-source-resolution-2026-09-13.md; PR #68", (), ()),
    "SpanRichProductivity": (P, "no strict component with K2 != 0 exists (general wedge productivity)",
                             "open conjectural gate, not source-pending; manuscript open problem; issue #85", ("ConcentrationAuxB", "GaloisWedgePropagation"), ()),
    "SpectralSCCProducer": (P, "the spectral route produces an SCC producer under G1", "open; the spectral SCC producer is not proved even conditionally",
                            ("G1", "SinkSCCReduction", "SpanRichProductivity"), ()),
    "PDSSpectralRoute": (T, "under G1 and a spectral SCC producer, pure discrete spectrum follows", f"{MANUSCRIPT}, spectral route", ("G1", "SpectralSCCProducer"), ()),
    # --- open C4 sufficiency route -----------------------------------------------------
    "C4": (P, "the C4 hypothesis of the boundary route", "open sufficiency premise of the C4 route", (), ()),
    "C3Local": (T, "C4 gives C3-local", "docs/c3-locality-reduction.md", ("C4", "C3Locality"), ()),
    "C2": (T, "C3-local gives C2", f"{MANUSCRIPT}, boundary route", ("C3Local",), ()),
    "SCCProducer": (T, "SCC Producer / C1 follows from G1, the sink-SCC reduction, and C2", f"{LEDGER_DOC}; manuscript unresolved statements",
                    ("G1", "SinkSCCReduction", "C2"), ("status:open",)),
    "PDS": (T, "pure discrete spectrum follows from G1 and SCC Producer", f"{MANUSCRIPT}, boundary route", ("G1", "SCCProducer"), ()),
    # --- literature / repository BPA bridge ---------------------------------------
    "StandardBPAEquivalence": (I, "the standard balanced-pair algorithm criterion for pure discrete spectrum", "docs/bpa-literature-bridge.md and the literature cited there", (), ()),
    "RepoSeedUnionBridge": (T, "the repository seed-union graph is the union of the literature seed graphs", "docs/bpa-literature-bridge.md", (), ()),
    "CoincidenceRankFibreTheorems": (I, "for a primitive non-periodic substitution with Pisot inflation: one fibre of the maximal equicontinuous factor iff strongly regionally proximal; pairwise strongly regionally proximal, tile-disjoint tilings number at most cr; pure discrete spectrum iff cr = 1",
                                     "docs/coincidence-rank-imports-literature-gate-2026-10-04.md (Barge arXiv:1301.7094 Thm 4(5),(6); Barge arXiv:1505.04408 Sec. 1 items (2)-(3))", (), ()),
    "ReturnModuleFullRank": (T, "the uncollared return module Lambda_ret of a primitive substitution whose frequency vector has Q-independent coordinates is all of Z^A; in particular Z^3 for every PIP substitution",
                             f"{FIBRE}, Theorem R; independently audited 2026-10-04 (docs/side-notes-ledger.md, section 7), human review pending", (), ()),
    "PeriodicPairOneFibre": (T, "two Phi^r-fixed legal tilings built from interior occurrences and sharing a centre have the same maximal-equicontinuous-factor image, so they lie in one fibre",
                             f"{FIBRE}, Proposition F, via Solomyak's eigenvalue criterion on the full-rank return module; "
                             "independently audited 2026-10-04 (docs/side-notes-ledger.md, section 7), human review pending",
                             ("ReturnModuleFullRank",), ()),
    "StrictZipperPeriodicPairForm": (T, "a strict zipper reachable from a swap seed exists iff two Phi^r-fixed legal tilings with a common centre have no common vertex, that is iff PeriodicPairVertexCoincidence fails",
                                     f"{ZIPPER}, Theorem B with Lemma C and Corollary B' (reformulation of issue #139); "
                                     "independently audited 2026-10-04 (docs/side-notes-ledger.md, section 7), human review pending",
                                     (), ()),
    # Three of the five repository inputs named in the proof are nodes above, so
    # the closure tracks more than the Barge import. Manuscript Proposition 5.47
    # is deliberately NOT a dependency: G1HalfCoincidenceRoute bundles the
    # half-coincidence bound with its open all-seed premise, and that premise is
    # exactly what PDS discharges here through StrictZipperPeriodicPairForm, so
    # requiring it would make an unconditional implication read as conditional
    # on an open gate (docs/audit-2026-10-04.md, D.4 resolution).
    "PDSImpliesRepoG1": (T, "pure discrete spectrum implies repository G1 (finite BPA from every swap seed)",
                         "docs/p1b-vertex-coincidence-box-2026-10-02.md, Theorem 5.1 (Theorem S) with manuscript Proposition 5.47; "
                         "independently audited 2026-10-04 (docs/side-notes-ledger.md, section 7), human review pending",
                         ("CoincidenceRankFibreTheorems", "PeriodicPairOneFibre", "StrictZipperPeriodicPairForm"), ()),
    "StrongCoincidenceFromPDS": (I, "pure discrete spectrum of an irreducible Pisot substitution gives simultaneous prefix strong coincidence of all letters",
                                 "Akiyama-Lee, European J. Combin. 39 (2014), Corollary 4.5; height-group step by Theorem R; docs/pds-strong-coincidence-literature-gate-2026-10-04.md", (), ()),
    "PDSImpliesSeedwiseTermination": (T, "pure discrete spectrum implies termination of the balanced-pair algorithm with coincidence from every seed (ab, ba), legal or not",
                                      f"{MANUSCRIPT}, Theorem thm:seedwise; docs/formal-productivity-reduction-2026-10-04.md, Proposition FP and Corollary FP''; "
                                      "manuscript Theorem 5.33(iii),(v); independently audited 2026-10-04, human review pending",
                                      ("PDSImpliesRepoG1", "StrongCoincidenceFromPDS"), ()),
    # --- box automaton: one finite automaton decides formal productivity --------------
    # Lemma Omega1 and Theorem Omega are per-specimen statements with no open
    # premise. The three consequences are the routes FP opens: two to PDS that
    # share no step after FP, and one to finite BPA. Routes (b) and (c) cite
    # Theorem 5.38 and Proposition 5.46 for their mechanism but do not depend on
    # PDSOverlapRoute or G1OverlapRoute, which bundle the weaker open seed gates
    # that FP discharges directly (the D.4 resolution, as for PDSImpliesRepoG1).
    "BoxCycleContainment": (T, "every potential overlap has finitely many descendants, and every potential overlap on a cycle of the overlap graph is a vertex of the box automaton",
                            f"{BOX}, Lemma Omega1 (Proposition V step 1; docs/formal-overlap-carriers-2026-10-04.md, section 2 item 5); "
                            f"step 1 audited in docs/audit-adversarial-prop-v-theorem-e-2026-10-07.md; {REVIEWED}", (), ()),
    "BoxAutomatonCertificate": (T, "a PIP substitution is formally productive iff every vertex of its box automaton reaches a coincidence",
                                f"{BOX}, Theorem Omega; {REVIEWED}", ("BoxCycleContainment",), ()),
    "FormalProductivity": (P, "for every PIP substitution every potential overlap is productive (FP)",
                           f"open conjectural gate; docs/formal-productivity-reduction-2026-10-04.md; {BOX}; implied by PDS through Corollary FP'' and Theorem S", (), ()),
    "PisotMeyerProperty": (I, "a repetitive primitive one-dimensional substitution tiling with Pisot inflation and FLC has Meyer control points and Meyer same-type return vectors",
                          f"Lee-Solomyak, arXiv:1002.0039, Definition 2.3 and Theorem 4.3; {BOX_LC_REVIEW}, section 1 (scalar expansion hypotheses and return-vector transfer checked)", (), ()),
    "OverlapCoincidenceCriterion": (I, "for a repetitive primitive FLC self-affine tiling with Meyer return vectors, coincidence reachability from every occurring overlap implies pure discrete spectrum of the tiling flow",
                                   f"Lee-Moody-Solomyak, arXiv:0910.4450, Theorem 4.7 and Lemmas 6.8-6.9; Akiyama-Lee, arXiv:1003.2898, Theorem 2.5; {BOX_LC_REVIEW}, section 1", (), ()),
    "BoxAutomatonPDSCertificate": (T, "for each fixed PIP substitution, if every vertex of its complete box automaton reaches a coincidence, its Perron-length suspension tiling flow has pure discrete spectrum",
                                  f"{BOX}, Theorem Omega consequence (a); {BOX_LC_REVIEW}, sections 1-2; tiling R-action sufficiency only",
                                  ("BoxAutomatonCertificate", "PisotMeyerProperty", "OverlapCoincidenceCriterion"), ()),
    "PDSFormalProductivityRoute": (T, "formal productivity implies pure discrete spectrum through the overlap-coincidence criterion, without unimodularity",
                                   f"{BOX}, consequence (a); {REVIEWED}", ("FormalProductivity", "BoxAutomatonPDSCertificate"), ()),
    "PDSFormalProductivitySeedRoute": (T, "formal productivity gives productivity of every overlap reachable from a swap seed, hence pure discrete spectrum by coincidence density one",
                                       f"{BOX}, consequence (b), with {MANUSCRIPT}, Lemma 5.36 and Theorem 5.38; {REVIEWED}",
                                       ("FormalProductivity", "SwapOverlapFiniteness", "DensityToPDSBridge"), ()),
    "G1FormalProductivityRoute": (T, "formal productivity gives finite BPA with termination with coincidence from every swap seed, every reachable state being at most 2 beta^D ell_max long",
                                  f"{BOX}, consequence (c), with docs/bpa-termination-by-overlap-depth-2026-10-02.md, Proposition 1; {REVIEWED}",
                                  ("FormalProductivity", "BoxCycleContainment"), ()),
    # --- leftmost chain: the structure of catch-up failure ---------------------------
    "LeftmostChainCycleStructure": (T, "every terminal cycle of the leftmost-child map on the complete box graph keeps one strict offset sign, with index zero on the later-starting side, and is a prefix-vs-interior occurrence pair sigma^r(i) = i U, sigma^r(j) = Q j V with (I - M^r) w_0 = ab(Q) after orienting the offset negatively; the prefix object is a right-infinite fixed ray and the interior object is a two-sided tiling compared on the right half-line, whose common centre is never a common vertex; the cycles come in mirror pairs",
                                    f"{LEFTMOST}, Lemma S, Proposition LC and Corollary LC4; 10,584 sign/shape checks, 10,128 integral replays and 456 uncomputed offsets on the standing corpus; {REVIEWED}", (), ()),
    "LeftmostChainG1Certificate": (T, "a PIP substitution whose box graph has no terminal leftmost cycle satisfies all-seed strict-zipper exclusion, hence finite BPA",
                                   f"{LEFTMOST}, Corollary LC5, with {MANUSCRIPT}, Proposition 5.47; {REVIEWED}", ("BoxCycleContainment",), ()),
    # --- retracted ------------------------------------------------------------------------
    "V5Thm51": (P, "v5 Theorem 5.1", "retired: the v5 Theorem 5.1 argument is withdrawn", (), (gl.WITHDRAWN_TAG,)),
}

STATUS_NOTES = {
    "G1": "the renewal, all-seed overlap, strict-zipper-exclusion and formal-productivity implications are proved alternative establishments of canonical G1; their open premises are not discharged, so G1 itself remains an open conjectural gate",
    "SCCProducer": "the implication from G1, the sink-SCC reduction, and C2 is proved; SCC Producer / C1 is an open theorem target",
    "CoincidenceDensityOne": "the equivalence of Lemma 5.36 is repository-proved; the ledger node is its conclusion, which needs overlap productivity",
}

ASSUMPTION_SETS = {
    "G1AndProducer": ["G1", "SCCProducer"],
    "G1Only": ["G1"],
    "G1AndC4": ["G1", "C4"],
    "RenewalGateAssumed": ["G1b1BoundedDiscrepancy", "G1b2RenewalFiniteness"],
    "SpectralGateAssumed": ["G1", "ConcentrationAuxB", "SpanRichProductivity", "SpectralSCCProducer"],
    # Imported theorems are established only by assumption (ImportedDef, never
    # ProvedDef), so the overlap gate names the Barge-Stimac-Williams import it
    # needs to reach PDSOverlapRoute.
    "OverlapGateAssumed": ["OverlapProductivity", "DensityToPDSBridge"],
    "AllSeedOverlapGateAssumed": ["AllSeedOverlapProductivity"],
    "AllSeedStrictZipperGateAssumed": ["AllSeedStrictZipperExclusion"],
    # FP alone reaches G1 and the seed route to PDS (through the imported
    # density bridge); the overlap-coincidence route needs its LMS import.
    "FormalProductivityGateAssumed": ["FormalProductivity", "PisotMeyerProperty", "OverlapCoincidenceCriterion", "DensityToPDSBridge"],
}

STATUS_LABELS = {"proved": "Repository-proved", "imported": "Imported theorem", "conditional": "Conditional theorem", "open": "Open conjectural gate",
                 "retired": "Retired claim", "finite-domain": "Finite-domain theorem"}

ALIASES = {
    "DefectTheorem": ["FullIncidenceRank", "full incidence rank"], "UniqueDecodability": ["unique decodability"],
    "G1b1BoundedDiscrepancy": ["G1b-1", "bounded discrepancy"], "G1b2RenewalFiniteness": ["G1b-2", "renewal finiteness"], "G1": ["finite BPA"],
    "SinkSCCReduction": ["sink-SCC reduction"], "GaloisWedgePropagation": ["degree-two carrier span"], "ConcentrationAuxB": ["aux-B", "general concentration"],
    "SpanRichProductivity": ["general wedge productivity"], "SwapOverlapFiniteness": ["seed-patch overlap graph finiteness", "seed-patch overlap finiteness"],
    "OverlapFullRank": ["full-rank child-closed overlap constraint"], "OverlapBadSCCNormalForm": ["closed irreducible bad-overlap normal form"],
    "OverlapBoundaryZipperDichotomy": ["strict zipper dichotomy"], "CoincidenceDensityOne": ["coincidence density one"],
    "DensityToPDSBridge": ["density-to-PDS bridge", "Barge–Štimac–Williams theorem"], "PDSOverlapRoute": ["Theorem 5.38"],
    "AlignedOverlapsAreStrongCoincidence": ["endpoint-aligned overlaps"], "BoundaryCoincidenceCriterion": ["boundary-hitting criterion"],
    "OverlapProductivity": ["seedwise overlap productivity", "overlap productivity", "Open Problem 5.35"], "SCCProducer": ["SCC Producer"],
    "AllSeedOverlapProductivity": ["all-seed overlap productivity"], "G1OverlapRoute": ["overlap-depth route to finite BPA"],
    "AllSeedStrictZipperExclusion": ["all-seed strict-zipper exclusion"], "G1HalfCoincidenceRoute": ["half-coincidence route to finite BPA"],
    "PDSImpliesRepoG1": ["Theorem S", "PDS implies G1"], "CoincidenceRankFibreTheorems": ["coincidence-rank fibre theorems"],
    "ReturnModuleFullRank": ["full-rank return module", "Theorem R"], "PeriodicPairOneFibre": ["periodic pairs in one fibre", "Proposition F"],
    "StrictZipperPeriodicPairForm": ["periodic-pair form of a strict zipper", "Theorem B"],
    "PDSImpliesSeedwiseTermination": ["seedwise bridge"], "StrongCoincidenceFromPDS": ["overlap coincidence to strong coincidence"],
    "BoxCycleContainment": ["Lemma Ω1"], "BoxAutomatonCertificate": ["Theorem Ω", "box-automaton certificate"],
    "FormalProductivity": ["formal productivity"], "OverlapCoincidenceCriterion": ["Lee–Moody–Solomyak overlap-coincidence criterion"],
    "PDSFormalProductivityRoute": ["consequence (a)"], "PDSFormalProductivitySeedRoute": ["consequence (b)"], "G1FormalProductivityRoute": ["consequence (c)"],
    "LeftmostChainCycleStructure": ["Proposition LC"], "LeftmostChainG1Certificate": ["Corollary LC5"],
    "PisotMeyerProperty": ["Pisot Meyer property"],
    "BoxAutomatonPDSCertificate": ["per-specimen box PDS certificate"],
}


def surface(path: str, anchor: str, window_lines: int = 0) -> dict:
    return {"path": path, "anchor": anchor, "window_lines": window_lines}


# Status checks bind live prose. Frozen completion snapshots belong in the
# archive and must not become a dependency of the current status ledger.
SURFACES = {  # prose surfaces on which each claim's status is spelled out (labelled by the consumer vocabulary)
    "DefectTheorem": [surface(MAP, "| Full incidence rank from"), surface(LEDGER_DOC, "### Full incidence rank and unique decodability", 2)],
    "UniqueDecodability": [surface(MAP, "| Unique decodability of substitution images and powers |"), surface("README.md", "**Unique decodability:**")],
    "G1b1BoundedDiscrepancy": [surface(MAP, "| G1b-1 bounded discrepancy |"), surface(LEDGER_DOC, "### G1b-1 bounded discrepancy", 2),
                               surface(LADDER, "=> bounded discrepancy"), surface("README.md", "=> bounded discrepancy")],
    "G1b2RenewalFiniteness": [surface(MAP, "| G1b-2 renewal finiteness |"), surface(LEDGER_DOC, "### G1b-2", 2),
                              surface(LADDER, "## G1b-2 — renewal finiteness", 2), surface(ROADMAP, "| **P2** | G1b-2 renewal finiteness |")],
    "G1": [surface(MAP, "| Finite BPA, G1 |"), surface(LEDGER_DOC, "## C. Parallel programme — G1 / renewal finiteness", 4)],
    "SinkSCCReduction": [surface(MAP, "| Sink-SCC reduction under G1 |")],
    "GaloisWedgePropagation": [surface(MAP, "| Degree-two carrier span / wedge dichotomy |")],
    "ConcentrationAuxB": [surface(MAP, "| Concentration / aux-B |"), surface(LEDGER_DOC, "### Concentration / aux-B", 2), surface(ROADMAP, "| **P3a** | Concentration, `K2=0` |")],
    "SpanRichProductivity": [surface(MAP, "| General wedge productivity |"), surface(LEDGER_DOC, "### Wedge productivity", 2), surface(ROADMAP, "| **P3b** | Wedge productivity, `K2!=0` |")],
    "SwapOverlapFiniteness": [surface(MAP, "| Seed-patch overlap graph finiteness |"), surface(LEDGER_DOC, "### Seed-patch overlap finiteness", 2),
                              surface(LADDER, "=> finite seed-patch overlap graph"), surface("README.md", "=> finite seed-patch overlap graph")],
    "OverlapFullRank": [surface(MAP, "| Full-rank child-closed overlap constraint |"), surface(LEDGER_DOC, "### Full-rank constraint on a bad set", 2)],
    "OverlapBadSCCNormalForm": [surface(MAP, "| Closed irreducible bad-overlap normal form |"), surface(LEDGER_DOC, "### Closed irreducible bad-overlap normal form", 2)],
    "OverlapBoundaryZipperDichotomy": [surface(MAP, "| Boundary obstruction / strict zipper dichotomy |")],
    "CoincidenceDensityOne": [surface(MAP, "| Coincidence density / dense-good-set equivalence |"), surface(LADDER, "=> coincidence density one / dense good set"),
                              surface("README.md", "=> coincidence density one / dense good set")],
    "DensityToPDSBridge": [surface(MAP, "| Density-to-PDS bridge |"), surface(LADDER, "=> pure discrete spectrum"), surface("README.md", "=> pure discrete spectrum")],
    "PDSOverlapRoute": [surface(MAP, "| One-seed overlap productivity implies PDS |")],
    "AlignedOverlapsAreStrongCoincidence": [surface(MAP, "| Endpoint-aligned overlaps = strong-coincidence boundary cases |")],
    "BoundaryCoincidenceCriterion": [surface(MAP, "| Boundary-hitting criterion |")],
    "OverlapProductivity": [surface(MAP, "| Seedwise overlap productivity / Open Problem 5.35 |"), surface(LEDGER_DOC, "### Overlap productivity / Open Problem 5.35", 2),
                            surface(LADDER, "=> one swap seed has only productive reachable overlaps"), surface("README.md", "=> one swap seed has only productive reachable overlaps"),
                            surface(ROADMAP, "| **P1** | Seedwise overlap productivity (#84) |")],
    "SCCProducer": [surface(MAP, "| SCC Producer / C1 |")],
    "AllSeedOverlapProductivity": [surface(MAP, "| All-seed overlap productivity |"), surface(LEDGER_DOC, "### All-seed overlap productivity", 2)],
    "G1OverlapRoute": [surface(MAP, "| All-seed overlap productivity implies finite BPA |"), surface(LEDGER_DOC, "### Overlap-depth route to finite BPA", 2),
                       surface("docs/proof-ladder.md", "## Overlap-depth route to G1", 2)],
    "AllSeedStrictZipperExclusion": [surface(MAP, "| All-seed strict-zipper exclusion |"), surface(LEDGER_DOC, "### All-seed strict-zipper exclusion", 2)],
    "G1HalfCoincidenceRoute": [surface(MAP, "| Strict-zipper exclusion implies finite BPA |"), surface(LEDGER_DOC, "### Half-coincidence route to finite BPA", 2),
                               surface("docs/proof-ladder.md", "## Half-coincidence route to G1", 2)],
    "PDSImpliesRepoG1": [surface(MAP, "| PDS implies G1 |"), surface(LEDGER_DOC, "### PDS implies G1", 2),
                         surface("docs/proof-ladder.md", "## PDS implies G1, so G1 is necessary", 2)],
    "PDSImpliesSeedwiseTermination": [surface(MAP, "| PDS implies seedwise termination |"), surface(LEDGER_DOC, "### PDS implies seedwise termination", 2),
                                      surface("docs/proof-ladder.md", "## PDS implies seedwise termination (former Open Problem 4.24)", 2)],
    "CoincidenceRankFibreTheorems": [surface(MAP, "| Coincidence-rank fibre theorems |")],
    "ReturnModuleFullRank": [surface(MAP, "| Full-rank return module |")],
    "PeriodicPairOneFibre": [surface(MAP, "| Periodic pairs lie in one fibre |")],
    "StrictZipperPeriodicPairForm": [surface(MAP, "| Periodic-pair form of a strict zipper |")],
    "StrongCoincidenceFromPDS": [surface(MAP, "| Strong coincidence from PDS |")],
    "BoxCycleContainment": [surface(MAP, "| Cycle vertices lie in the box automaton |")],
    "BoxAutomatonCertificate": [surface(MAP, "| Box-automaton certificate for formal productivity |")],
    "FormalProductivity": [surface(MAP, "| Formal productivity |")],
    "OverlapCoincidenceCriterion": [surface(MAP, "| Overlap-coincidence criterion |")],
    "PDSFormalProductivityRoute": [surface(MAP, "| Formal productivity implies PDS (overlap coincidence) |")],
    "PDSFormalProductivitySeedRoute": [surface(MAP, "| Formal productivity implies PDS (seed route) |")],
    "G1FormalProductivityRoute": [surface(MAP, "| Formal productivity implies finite BPA |")],
    "LeftmostChainCycleStructure": [surface(MAP, "| Leftmost-chain cycles are prefix-vs-interior pairs |")],
    "LeftmostChainG1Certificate": [surface(MAP, "| No terminal leftmost cycle implies finite BPA |")],
    "PisotMeyerProperty": [surface(MAP, "| Pisot Meyer property |")],
    "BoxAutomatonPDSCertificate": [surface(MAP, "| Box-automaton PDS certificate |")],
}


def records() -> dict[str, Record]:
    built: dict[str, Record] = {}

    def build(name: str) -> Record:
        if name in built:
            return built[name]
        kind, statement, source, deps, tags = TABLE[name]
        edges = tuple(Edge(build(d).id, build(d).statement, f"{name}/{d}") for d in deps)
        if kind is Kind.PENDING:
            evidence = (("reason", source),)
        elif kind is Kind.IMPORTED:
            evidence = (("hypotheses_checked", "true"), ("source", source))
        else:
            evidence = (("proof_reviewed", "true"), ("source", source))
        if name in BOX_LC_REVIEWED:
            evidence += (("review_source", BOX_LC_REVIEW),
                         ("additional_review_source", "docs/proof-bank-audit-2026-10-08.md"),
                         ("review_date", "2026-10-08"),
                         ("source_revision", BOX_LC_BASELINE),
                         ("reconciled_source_revision", BOX_LC_RECONCILED_BASELINE),
                         ("reconciliation_source", RECONCILIATION),
                         ("human_review_pending", "true"))
        if name == "G1":
            evidence += (("dependency_alternatives", json.dumps(
                [[build(r).id] for r in ("G1FromRenewal", "G1OverlapRoute", "G1HalfCoincidenceRoute", "G1FormalProductivityRoute")],
                separators=(",", ":"))),)
        if name in STATUS_NOTES:
            evidence += (("status_note", STATUS_NOTES[name]),)
        built[name] = identified(Record("", kind, statement, SCOPE, edges, evidence, frozenset(tags)))
        return built[name]

    return {name: build(name) for name in TABLE}


def record_json(record: Record) -> dict:
    return {"id": record.id, "kind": record.kind.value, "statement": record.statement, "scope": record.scope,
            "depends_on": [[e.record_id, e.expected_claim, e.use_site, e.scope_relation, e.required_outcome] for e in record.depends_on],
            "evidence": [list(kv) for kv in record.evidence], "tags": sorted(record.tags)}


def ledger() -> dict:
    return {
        "format": gl.FORMAT,
        "repository": "larsbx/pisot-substitution-conjecture-research",
        "module": "Ledger",
        "tla_dir": "proof/tla",
        "index_path": "docs/ledger-index.md",
        "graph_path": "docs/claim-relationship-graph.json",
        "assumption_sets": ASSUMPTION_SETS,
        "status_classes": {Kind.VERIFIED.value: "finite-domain"},
        "status_labels": STATUS_LABELS,
        "aliases": ALIASES,
        "surfaces": SURFACES,
        "records": {name: record_json(r) for name, r in records().items()},
    }


def main(argv: list[str]) -> int:
    check = "--check" in argv[1:]
    text = json.dumps(ledger(), indent=2, ensure_ascii=False) + "\n"
    if check:
        if not LEDGER.exists() or LEDGER.read_text(encoding="utf-8") != text:
            print(f"stale: {LEDGER} (run tools/make_ledger.py)")
            return 1
    else:
        LEDGER.write_text(text, encoding="utf-8")
    args = ["generate_ledgers", str(LEDGER), "--out", str(ROOT), "--claims", str(POLICY)] + (["--check"] if check else [])
    return gl.main(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
