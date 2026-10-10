# Literature gate: finite balanced-pair automaton from overlap depth — 2026-10-02

**Status:** literature baseline and stop/go decision for Proposition 1 of
`docs/bpa-termination-by-overlap-depth-2026-10-02.md` (manuscript Proposition
5.46). **Decision: proceed with a narrowed novelty claim** (§6). The mechanism
is that of Sirvent–Solomyak (2002), Theorem 5.6; the repository contribution
is its transfer to the swap-seed closures of `B_sigma`, on the seed-patch
overlap graph that manuscript Theorem 4.22 makes finite unconditionally, with
an explicit length bound. Nothing here proves G1, G1b-2, overlap productivity
or the Pisot substitution conjecture.

## 1. Exact proposed claim

For a primitive irreducible Pisot `sigma` and a seed `s = (ab, ba)`: if every
vertex of the seed-patch overlap graph reachable from the seed overlaps of `s`
is productive, with largest first-coincidence depth `K`, then every state of
`B_sigma` reachable from `s` at depth `n >= K` has geometric length at most
`2 beta^K ell_max`, so the closure of `s` is finite. For every seed, this
gives G1.

## 2. Sources inspected

| Source | Statement used | Read |
| --- | --- | --- |
| V. F. Sirvent, B. Solomyak, *Pure discrete spectrum for one-dimensional substitution systems of Pisot type*, Canad. Math. Bull. 45 (2002) 697–710 | Theorem 5.6: for a prefix `W` of the fixed point `u`, (i′) bpa-`W` terminates ⇔ (ii′) the overlap algorithm for `x = x(W)` terminates with half-coincidences ⇔ (iii′) consecutive half-coincidences of `(T, T − beta^n x)` are boundedly apart, uniformly in `n`. Theorem 5.1: bpa-`W` terminating with coincidence ⇔ some overlap algorithm terminating with coincidences. | full text, §§3–5 |
| S. Akiyama, M. Barge, V. Berthé, J.-Y. Lee, A. Siegel, *On the Pisot substitution conjecture*, in Mathematics of Aperiodic Order (2015) | Theorem 5.3: for irreducible Pisot `phi`, pure discrete spectrum of `(X_phi, S)` ⇔ the balanced pair algorithm terminates with coincidence; one seed `(ij, ji)` suffices. Attributed to Sirvent–Solomyak, with extensions in Martensen and Barge–Štimac–Williams. | §5.3 |
| B. F. Martensen, *Generalized balanced pair algorithm*, Topology Proc. 28 (2004) 163–178 (arXiv math/0309194) | The standard algorithm need not terminate outside the irreducible, Perron-length setting; for a length vector such as `(1, 1, 2)` that is not the Perron one it does not terminate in his example. Cites Sirvent–Solomyak for "terminates ⇒ half-coincidences boundedly apart". | §§1, 3, 4 |
| M. Barge, S. Štimac, R. F. Williams, *Pure discrete spectrum in substitution tiling spaces*, DCDS 33 (2013) 579–597 | Periodic swap patches `(uv)^Z` vs. `(vu)^Z` need not be legal; dense eventual coincidence gives pure discrete spectrum. Already imported as manuscript Imported Theorem 5.37. | via the manuscript's import |

Hollander's two-letter termination theorem (with Solomyak) is cited by Martensen
and the survey; it was not read directly here and is not used.

## 3. Prior art and terminology

- **"Terminates"** in Sirvent–Solomyak and ABBLS means: finitely many
  irreducible balanced pairs occur (Sirvent–Solomyak, §3; ABBLS, §5.3). This
  is the repository's finiteness of a seed closure.
- **"Half-coincidence"** (Sirvent–Solomyak) is a point that is a tile boundary
  of both tilings: the repository's simultaneous boundary, or zero return
  (manuscript Lemma 5.30).
- **Bounded gaps ⇔ termination** is Sirvent–Solomyak Theorem 5.6
  (i′)⇔(iii′). Their proof of (ii′)⇒(iii′) is the depth argument: if the
  overlap algorithm terminates with half-coincidences, some `N` independent of
  the overlap works for all of them. Proposition 1 runs the same argument with
  coincidences, which give half-coincidences.

So the mechanism of Proposition 1 is standard, and the conclusion "overlap
coincidence ⇒ balanced-pair termination" is close to Sirvent–Solomyak
Theorem 5.1 and ABBLS Theorem 5.3.

## 4. Hypotheses that transfer and those that do not

| Point | Sirvent–Solomyak / ABBLS | Proposition 1 |
| --- | --- | --- |
| Seeds | bpa-`W` for a prefix `W` of the fixed point (legal words), or ABBLS's seeds of a fixed word | repository swap seeds `(ab, ba)`, possibly illegal; the transfer needs no legality, since the overlaps are those of the swap pair |
| Overlap set | the overlap algorithm's set, finite by the Pisot / Meyer structure | the seed-patch overlap graph, finite unconditionally by manuscript Theorem 4.22 (bounded discrepancy) |
| Hypothesis | termination of the overlap algorithm with half-coincidences, or pure discrete spectrum | productivity of every reachable overlap (coincidence descendants) |
| Bound | existence of a uniform bound | explicit `2 beta^K ell_max` |
| Irreducibility | used: tile lengths from the Perron eigenvector | used: `Q`-independence of `ell` turns balanced cuts into common boundaries |
| Unimodularity | not assumed (their first example is non-unimodular) | not assumed |

The route through ABBLS Theorem 5.3 would need two further steps that the
repository does not have: pure discrete spectrum (Theorem 5.38 gives it from
one-seed productivity), and then termination from **every** swap seed, the
open `PDSImpliesRepoG1` bridge (`docs/bpa-literature-bridge.md`). Proposition 1
avoids both by working seed by seed on the overlap graph directly.

## 5. Negative controls

- **Irreducibility is needed.** Martensen's non-terminating examples use
  reducible substitutions or a non-Perron length vector, where equal geometric
  length no longer forces equal Parikh vectors. Proposition 1 uses exactly
  that implication (manuscript Lemma 2.3, `Z`-independence of tile lengths), so it
  does not extend to those settings.
- **Productivity cannot be dropped.** A nonproductive reachable overlap gives a
  stretch whose inflations never contain a coincidence; nothing in the
  argument bounds the gaps there. Proposition 1 does not claim G1 without its
  hypothesis.
- **A budget is not a counterexample.** The cube-image specimen
  `0 -> 1, 1 -> 222, 2 -> 0222` exhausts direct builds at 400,000 letters,
  while Proposition 1 bounds its states by about `4.5e10` letters
  (Corollary 2 of the proof note).

## 6. Decision

**Proceed, narrowed.** Proposition 1 is recorded as a repository-proved
conditional theorem, attributed in mechanism to Sirvent–Solomyak Theorem 5.6.
Its novelty is restricted to:

1. the transfer to the repository's swap-seed closures, legal or not, which is
   what G1 is about;
2. the use of the unconditionally finite seed-patch overlap graph, so no
   pure-discrete-spectrum or realization step is needed;
3. the explicit bound `2 beta^K ell_max`, with its finite-domain corollaries.

A sharper statement is suggested by Theorem 5.6: finiteness should already
follow from every reachable overlap reaching a **half**-coincidence, a
condition weaker than productivity. It is proved as Proposition 4 of
`docs/bpa-termination-by-overlap-depth-2026-10-02.md`, by the same transfer
and with the same attribution: it is the half-coincidence form of Theorem
5.6, (ii′)⇒(i′), on the repository's swap-seed graph. Its Corollary 5
identifies the hypothesis with the exclusion of strict-zipper obstructions
(manuscript Proposition 5.44(iii)(b)). No further literature review is
needed for it: the sources and hypothesis boundaries above are the same.
