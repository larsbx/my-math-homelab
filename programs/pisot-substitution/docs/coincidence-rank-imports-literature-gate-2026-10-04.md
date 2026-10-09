# Literature gate: the coincidence-rank imports behind Theorem S — 2026-10-04

**Status:** targeted literature stop/go note (`AGENTS.md`, review gate),
closing the import gap that the 2026-10-04 audit recorded under Theorem S of
`p1b-vertex-coincidence-box-2026-10-02.md` §5.1. It audits hypotheses only and
changes no ledger node or claim status.

## 1. The step under review

Theorem S (PDS ⇒ PPVC) needs: two tilings in one fibre of the maximal
equicontinuous factor that share no tile force coincidence rank at least 2,
and coincidence rank 1 is pure discrete spectrum. For PIP `sigma` the inputs
are Proposition F with Theorem R (same fibre) and Theorem B (no common vertex,
hence no common tile).

## 2. Primary texts read

**M. Barge, *Factors of Pisot tiling spaces and the Coincidence Rank
Conjecture*, arXiv:1301.7094** (the manuscript's `Barge2016`), §2,
definitions and Theorem 4 with its proof and footnote 1.

- Hypothesis: `Phi` is a **Pisot family** substitution. For a self-similar
  substitution (expansion a scalar `lambda`) this holds iff `lambda` is a
  Pisot number. No unimodularity, no irreducibility. Footnote 1: [BK] uses a
  narrower notion of Pisot family, and by [K] its results extend to this one.
- `cr(Phi) = min{#g^{-1}(z)}`; in [BKw] it is the largest number of tilings
  in one fibre, no two of which share a tile.
- Theorem 4(5): pure discrete spectrum ⟺ `g` a.e. one-to-one ⟺
  `cr(Phi) = 1`. Theorem 4(6): `g(T) = g(T')` ⟺ strong regional proximality.
  Theorem 4(2): each fibre contains `cr(Phi)` tilings pairwise disjoint under
  every `Phi^k`.

**M. Barge, *The Pisot conjecture for beta-substitutions*, arXiv:1505.04408**
(ETDS 2018; "Barge 2015" in the fibre gate), §1, items (1)–(3).

- Hypothesis: `theta` is an arbitrary **primitive, non-periodic substitution
  with Pisot inflation** `beta`. No unimodularity, no irreducibility.
- Item (2): pure discrete spectrum ⟺ `cr(theta) = 1`.
- Item (3): `pi_max(T) = pi_max(T')` ⟺ `T ∼srp T'`; and there are
  `T_1, …, T_r` with `T_i ∼srp T_j` and `T_i ∩ T_j = ∅` for `i != j` iff
  `r <= cr(theta)`. Here `T_i ∩ T_j = ∅` means no common tile, with no
  inflation quantifier.
- The author attributes (1)–(3) to [BKw, BBK, BK, B2]; this gate reads the
  published summary, not those proofs.

## 3. Transfer to the standing PIP regime

| Hypothesis | PIP `sigma` on three letters |
| --- | --- |
| primitive | yes |
| non-periodic | yes (irreducibility of the cubic excludes periodicity) |
| Pisot inflation (self-similar Pisot family) | yes, the Perron root is Pisot |
| unimodularity | not assumed by either source; the non-unit case is covered |
| meaning of "same fibre" | `pi_max = g`, the maximal equicontinuous factor map, as in Proposition F |

The step therefore reads, for every PIP `sigma`: `T_A`, `T_B` in one fibre and
sharing no tile give, by item (3) with `r = 2`, `cr >= 2`, hence no pure
discrete spectrum by item (2) or Theorem 4(5). The persistence under every
`Phi^k` added to Theorem S's proof is not needed for item (3) as stated, and
is harmless.

## 4. Negative controls and limits

- Barge–Gambaudo's geometric realization (in the fibre gate's table) is
  unimodular only and is not used here.
- Item (3) is a summary statement in an introduction; its proofs are in the
  cited papers, which this gate has not read. The hypotheses are taken from
  the summary's own standing assumption ("θ is an arbitrary (primitive,
  nonperiodic) substitution with Pisot inflation β").

## 5. Decision: proceed

The imports behind Theorem S hold with hypotheses that the standing PIP
regime meets, unimodular or not. Theorem S's remaining review dependencies
are the repository's own Theorem B, Proposition F and Theorem R.
