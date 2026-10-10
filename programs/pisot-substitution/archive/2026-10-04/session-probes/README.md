# Session probes behind the vertex-coincidence note — 2026-10-03/04

Every scratch probe run while working on
`docs/p1b-vertex-coincidence-box-2026-10-02.md` §§3–5.6 (PRs #197–#204 and
the PR that adds this archive), with its saved output. The probes were
written as throwaway scratch and are kept here unchanged, except that
absolute scratch paths were made relative. They are **provenance, not
canonical code** (AGENTS.md):

- the Python probes are floating-point or prototype oracles, not
  certificates;
- the Mojo probes are exact, but are superseded by the committed drivers
  named below;
- every claim in the note cites the committed Mojo driver where one exists.

`outputs/rerun_<name>.out` is a fresh re-run of every probe on 2026-10-04
(`probes/rerun.sh`). The other files in `outputs/` are the logs saved during
the session. `evidence.zip` holds the bulky outputs (the length-4 census
chunk logs, the targeted-search chunk logs, `law.json` and the 135,990
`K_V` records). `SHA256SUMS` binds every file.

## Replay

```sh
cd archive/2026-10-04/session-probes
sha256sum -c SHA256SUMS
unzip -o evidence.zip          # restores bulk/ (needed by uhan.py, law_stats.py)
cd probes && PIXI=pixi ./rerun.sh            # all probes; or ./rerun.sh NAME ...
python3 law_stats.py; python3 len4_rest.py   # written for this archive
```

The Python probes need only the standard library. `lib.py` is their shared
helper (float PIP screen, characteristic polynomial, roots). The Mojo probes
run against `kernel/` through `pixi run --manifest-path` (2026-10-06:
`rerun.sh`'s `MOJO_DIR` was repointed from the retired `mojo/` to `kernel/`,
the current include root; no probe source changed).

## Index

| probe | what it computes | result (re-run) | where it is used | superseded by |
|---|---|---|---|---|
| `lib.py` | shared float helpers: incidence, primitivity, char. poly, roots, float PIP screen | — | all Python probes | `psc.corpus`, `psc.pisot` |
| `r_all.py` / `r_irr.py` / `r_prim.py` / `r_prim4.py` | return-lattice index from the abelianised simple cycles of the 2-letter factor graph, over image words of length ≤ L (argument; re-run at L = 3) for PIP / primitive irreducible / primitive nonsingular substitutions; `r_prim4.py` is byte-identical to `r_prim.py` | PIP 4554, bad 0; primitive irreducible 11730, bad 0; primitive nonsingular 24996, index > 1: 0 (both copies) | Theorem R gate (`p1b-periodic-pair-fibre-literature-gate`) | `mojo/return_lattice_census.mojo` |
| `r_search.py` | searches image triples (words ≤ 5) driving a 2-state automaton {O, I} between prescribed states, PIP only | 0 found | exploratory, Theorem R work; no claim | — |
| `box.py`, `box2.py` | float box graph of Proposition V from approximate eigenvectors (box2 adds the recurrent part and deepest first-hit depth) | (failing vertices, recurrent, deepest depth): Tribonacci (0, 14, 3); cube (0, 1166, 17); golden pump (0, 716, 15) | §3 cross-check | `psc.vertex_coincidence` |
| `box_corpus.py` | box2 over the whole standing corpus, largest box | 4554 specimens, 0 with a vertex lacking an offset-zero descendant; largest closed float box graph 118,527 states at `11/20/002` (its own bounds and start set; the exact box graph's largest is 249,385 states at label `6 11 13`) | §3 cross-check | `mojo/vertex_coincidence_census.mojo` |
| `box_rec.py` | abandoned stub (returns None) | — | none | — |
| `oracle_total.py` | box2 over the standing corpus: failures, recurrent total, max recurrent, max depth | 4554, 0 bad, 1,174,788 recurrent, max 2,676, deepest 17 | §4 standing row cross-check | `mojo/vertex_coincidence_census.mojo` |
| `radii.py` | float box radii and box volume over the corpus | worst box ≈ 1.43·10^6 points at `12/221/00`, total ≈ 1.07·10^8 | sizing for Proposition V | `psc.vertex_coincidence.box_radii` |
| `vc_try.mojo` | first exact smoke test of `decide_vertex_coincidence` | golden pump: holds, radii 29, 17, 18, 61,337 states, 716 recurrent, depth 15 | §3 | `tests/test_vertex_coincidence.mojo` |
| `mine.py` | descent potentials on three named specimens: one-step descent failures under the l2 and max contracting sizes, worst k-step descent | Tribonacci 0/0, k 1; cube 234/234, k 5; golden pump 140/140, k 5 | §5.2 (one-step and k-step descent ruled out) | — |
| `mine2.py` | left/right endpoint chains on the same three: vertices whose chain hits at the left end, right end, either, neither | Tribonacci 14/14/14, 0; cube 654/652/1053, 107; golden pump 2/6/8, 706 | §5.2 (endpoint mechanism ruled out) | `psc.one_tile` (exact catch-up analysis) |
| `mine3.py` | stride-7 sample (651 specimens): `K_V` against the size-shrinkage prediction `L` | `K_V/L` ∈ [0.32, 2.56], `K_V − L` ∈ [−33.75, 5.00]; `22/001/10`: L 49.75, K_V 16 | §5.6 | — |
| `climb.py` | stride-7 sample: same-letter maximiser, climb length, residual depth | maximiser same-letter in 111 of 651; residual histogram as in output; deepest `210/0/110` K_V 17, climb 1 | §5.6a | — |
| `plastic.py` | depth anatomy of `0 -> 1, 1 -> 2, 2 -> 01` | `(0,0,(±1,±1,∓1))` t = ±β⁻² depth 14; `(1,1,…)` t = ±β⁻¹ depth 13; `(2,2,(±1,0,0))` t = ±1 depth 12 | §5.6a | — |
| `outlier.py` | unimodular complex specimens with deepest depth ≥ 12 | 1980 candidates; the 12 `K_V = 14` specimens (74 recurrent each), char. poly x³ − x − 1 | §5.4 outlier class | `mojo/vertex_excess_census.mojo` |
| `law.py` | per-specimen (K_V, mu, abs det, beta) over the standing corpus → `bulk/law.json` | 4554 rows | §5.5 | `mojo/vertex_depth_law.mojo` (exact law checks) |
| `law_stats.py` | (written for this archive) §5.5 statistics from `law.json` | K_V·log(1/mu) ∈ [0.441, 3.164]; correlation 0.923; mu = 0.9387 for every K_V ≥ 15; mu ≤ 0.802 for K_V ≤ 3 | §5.5 | — |
| `uhan.py` | envelope constants from the 135,990 length-4 `K_V` records (`bulk/uh4`) | K_V·log(1/mu) ∈ [0.441, 4.042]; 1506 above 3.2, 336 above 3.5; correlation 0.944; per-offset maxima as in output | §5.5a; the withdrawn per-offset estimates | `mojo/vertex_depth_law.mojo` |
| `len4_rest.py` | (written for this archive) length-4 PIP specimens outside the standing corpus and the total-length ≤ 8 class | 135,990 PIP; 4554 standing; 14,670 with total length ≤ 8; neither 121,320 | §4 domain table | — |
| `targeted.sh` | wrapper that ran `vertex_coincidence_targeted.mojo 5 39 40 40` after the length-4 census | saved log: 40,680 candidates, stride 40 → 1017 decided, 993 hold, 24 capped, 0 fail, deepest K_V 39 at `17/135/239` | §5.5b | `mojo/vertex_coincidence_targeted.mojo` |
| `birth.py`, `birth2.py`, `birth3.py` | stride-7 sample: first hits classified as catch-up or simultaneous birth along one minimal witness path; catch-up delay by abs det | 651 specimens, 149,412 recurrent, 61,854 first hits simultaneous; delay histogram as in output | withdrawn one-witness analysis behind §5.6b (PR #198 review) | `psc.one_tile` |
| `onetile.py`, `onetile_s.py` | float prototype of Q1 (leftmost chains, CU) on the stride-7 sample | 651 specimens, 149,412 recurrent, 78,406 in CU, 135,266 reach CU; Q1 fails on 53 | §5.6b prototype | `psc.one_tile`, `mojo/one_tile_census.mojo` |
| `probe.mojo` | Q1 on three mirrored specimens | 1/012/010 mirror 694/0/0; 1/12/022 mirror 14/0/14; Tribonacci mirror 8/8/8 | §5.6b mirror analysis | `two_sided`, `tests/test_one_tile.mojo` |
| `feat.py` | loader for the Python analyses below (corpus words, Q1 failures) | — | — | — |
| `a1.py` | first/last-letter structure of the Q1 failures | see output | §5.6b exploration | `odd_letter_sets` (Proposition C) |
| `a2.py` | Q1 failures by abs det and real/complex spectrum | 648/1980/1926; partial 48/54/48; total 0/0/210 | §5.6c | `mojo/one_tile_anatomy.mojo` |
| `a3.py` | proper prefix in `M Z^3` against Q1 failure | catch-up-free ⇔ total failure: 210/210, 150 partial not free, 4194 pass | Lemma P | `catch_up_free`, `mojo/one_tile_census.mojo` |
| `a4.py` | the smallest partial failures with their spectral class | see output | §5.6b | `mojo/one_tile_anatomy.mojo` |
| `col.py` | odd-letter image shapes against catch-up-freeness | catch-up-free ⇔ unique shape: 210; |O| = 2 in 192, |O| = 1 in 18 | Proposition C | `odd_letter_sets` |
| `lv.py` | exact level against M-adic valuation, depth 5 | agrees exactly on the 210 catch-up-free specimens, nowhere else | Proposition P′ | `level_is_valuation` |
| `closure_probe.mojo` | closure sizes of the Q1-failing vertices outside the catch-up-free class | 348 vertices: closure 1 in 276, 2 in 72, each its own SCC | §5.6b, §5.6c | `mojo/one_tile_anatomy.mojo` |
| `diag_probe.mojo` | diagonal against off-diagonal hit reachability | 1,080,828 / 1,153,308 of 1,154,040; catch-up-free: 180 all diagonal, 30 not | §5.6c | `mojo/one_tile_anatomy.mojo` |
| `direct_probe.mojo` | recurrent one-step catch-ups on non-catch-up-free specimens | 4170 of 4344, 29,712 vertices; 174 without | §5.6c | `mojo/one_tile_anatomy.mojo` |

## Session logs in `outputs/`

| file | what |
|---|---|
| `vc_census.log`, `vc_hist.log` | standing-corpus PPVC census and its `K_V` histogram (as pinned in CI) |
| `vc_total.log` | total-length ≤ 8 census: 24,486 hold, deepest 25 |
| `excess.log` | box-graph excess census (§5.4) |
| `law_all.log` | exact depth-law check on the 135,990 length-4 records: 3.2 law 1506 violations, 4 law 72, `7 + 1/log(1/mu)` none |
| `targeted.log` | targeted slow-contraction search (§5.5b) |
| `box_corpus.log`, `oracle_total.log` | float oracle runs (re-run above) |
| `onetile_census.log`, `one_tile_two_sided.txt`, `one_tile_p.txt`, `one_tile_pp.txt`, `one_tile_short.txt`, `one_tile_c.txt` | successive one-tile census runs as the driver grew (Q1; two-sided; Lemma P; P′; short periodic; Proposition C) |
| `one_tile_anatomy.txt` | the anatomy driver's full output, including all 174 labels |
| `corpus_words.txt`, `fails.txt`, `partial_labels.txt` | corpus image words by label, per-specimen two-sided Q1 failures, labels of the 150 partial failures (inputs of the Python analyses) |
| `rec_small.txt`, `rec_t.txt` | `K_V` records of a 300-specimen slice and of the targeted search's deepest specimen |
| `gate_test.txt`, `gate_test2.txt`, `tla.txt` | full Mojo suite and TLA runs from the session's gate checks |

`literature-quotes.md` quotes verbatim, with section and page, every passage
of the three papers read for the literature gates that the notes rely on:
Baker–Barge–Kwapisz 2006, Barge 2015 (arXiv:1505.04408) and Barge–Diamond
2002.

## References

`fetch_references.sh` downloads the three papers into `refs-local/`, which
is gitignored, and checks each against the SHA-256 of the copy read in the
session:

| paper | source | SHA-256 |
|---|---|---|
| Baker–Barge–Kwapisz, Ann. Inst. Fourier 56 (2006) 2213–2248 | numdam.org, doi:10.5802/aif.2238 | `1a3683a0e7eaef3e11a0492857da5ee7471b710aca00cf6fc3083910b23f8ce8` |
| Barge, arXiv:1505.04408v2 (2015) | arxiv.org | `4edde4708c136439f11b0ffe2747ce9c758246790fd47564ee6fe97536d1b0b8` |
| Barge–Diamond, Bull. SMF 130 (2002) 619–626 | numdam.org, doi:10.24033/bsmf.2433 | `c7f0f79628217c13cda86f374751e125017253d3d69755103e1c637942d333ab` |

The first two hashes equal those of the copies read on 2026-10-03/04. The
Barge–Diamond hash is of the copy fetched on 2026-10-04 to build this list,
because the session copy was overwritten by that fetch.

The repository is public, so the papers themselves are not committed. The
AIF article reads: "© Association des Annales de l'institut Fourier, 2006,
tous droits réservés … Toute reproduction en tout ou partie cet article …
pour tout usage autre que l'utilisation à fin strictement personnelle du
copiste est constitutive d'une infraction pénale". The arXiv paper carries
arXiv's non-exclusive distribution licence (arxiv.org/licenses/nonexclusive-distrib/1.0),
which licenses arXiv only. The Bull. SMF article is on Numdam under its
terms of use. The archive therefore pins each exact copy by hash and quotes
the passages used, and the script restores the copies for local use.

Not archived: compiled Mojo binaries (`vcc`, `vct`, `vdl`, `vex`), helper
scripts that only edited repository files, and local drafts of documents
since merged.
