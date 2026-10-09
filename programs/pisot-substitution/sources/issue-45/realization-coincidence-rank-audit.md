# Realization / coincidence-rank equivalence — audit of the unreconstructed gaps

**Status:** audit only. Nothing here is proved. The reported v16/later
equivalence stays a conjectural bridge (Section 5.10 of
`manuscripts/PSC_balanced_pair_state_2026-09-13.tex`) and must stay outside
`ProvedDef`.

## 1. The reported statement

The 2026-09-11 ledger records, under a finiteness hypothesis,

```text
cr(sigma) > 1   <=>   B_sigma contains a recurrent producer-free component
                       that is globally realized.
```

Here `cr(sigma)` is the coincidence rank of Barge–Kellendonk (the number of
tilings in a generic fibre of the maximal equicontinuous factor that are
pairwise never coincident), and "producer-free" means nonproductive.

## 2. What a proof would need

**Forward direction** (`cr(sigma) > 1` gives a globally realized nonproductive
recurrent component). Take two tilings in one fibre that never coincide, with
underlying sequences `x`, `y`. A proof would need, in order:

- (a) a *balanced window*: positions `[i, j)` in `x` and `[i', j')` in `y`
  with equal Parikh vectors, geometrically aligned so that the window is a
  balanced pair whose zero returns are simultaneous tile boundaries;
- (b) *non-coincidence transfers to the reduction*: that the reduction of that
  window, and of its inflations, contains no coincidence block, which requires
  relating the coincidence status of `x, y` to that of the pairs the
  inflations describe (inflating a window of `x, y` describes a window of
  `sigma(x), sigma(y)`, a different pair of fibre-mates);
- (c) *recurrence*: under G1, infinitely many such windows at increasing
  levels force the descent relation on nonproductive pairs into a recurrent
  component;
- (d) *reachability*: that the states so produced are vertices of `B_sigma`,
  i.e. reachable from a swap seed `(ab, ba)`.

None of (a)–(d) has a proof on `main`. (a) is the content of Conjecture 4.21
(relative density of simultaneous boundaries); (d) is the seed-family question
(Open Problem 4.24 and Section 4.8 of the manuscript); (b) and (c) have not
been written down anywhere in reachable history.

**Backward direction** (a globally realized nonproductive recurrent component
gives `cr(sigma) > 1`). Suppose some pair of tilings in one fibre has, at
every level, a window whose reduction lies in the component. Inside such a
window the two sequences never share a letter at a position of equal prefix
Parikh content (that would be a coincidence block), so the window is
coincidence-free. This gives "never coincide" only if the windows are
*cofinal*: every position of the pair lies in some window at some level (for
instance nested exhaustive windows, or windows of relatively dense
occurrence covering the whole line). Windows confined to one persistent
noncoincident region say nothing about coincident tiles elsewhere. So even
with the strongest available definition the backward direction needs cofinal
coverage as an explicit hypothesis; with the weaker definition in the ledger
(a formal cycle surviving legal collars of every finite radius) it is open
outright, since no theorem converts collar survival into a pair of tilings.

## 3. The gaps

| gap | content | status |
| --- | --- | --- |
| (G0) definition | "globally realized" has no definition on `main` that is independent of the conclusion; the working definitions in the ledger (formal cycle surviving legal collars of every radius) and in the certificate framework (pair of fibre-mates with confined reductions) are not shown equivalent | undefined |
| (G1) reachability | realized nonproductive pairs are not shown to be reachable from swap seeds | open (= seed-family question) |
| (G2) window existence and density | fibre-mates are not shown to admit balanced windows, let alone relatively dense ones | open (= Conjecture 4.21) |
| (G3) cofinal coverage | the windows realizing a component must cover every position of the pair for coincidence-freeness of windows to give coincidence-freeness of the tilings; no definition on `main` includes this | undefined |
| (G4) collar completeness | no theorem bounds the collar radius at which every unrealizable formal cycle must die; the finite collar experiments are therefore not a decision procedure | open (ledger item P4) |
| (G5) transfer of non-coincidence | requirement (b): that non-coincidence of two fibre-mates forces the reductions of a balanced window, and of its inflations (windows of *other* fibre-mates), to avoid coincidence blocks; not written down anywhere in reachable history | open |
| (G6) recurrence | requirement (c): that infinitely many coincidence-free windows at increasing levels force the descent relation on nonproductive pairs into a recurrent component, under G1; not written down anywhere in reachable history | open |

With (G0)–(G6) open, the reported equivalence is not a theorem, not a
reduction, and not source-pending in any useful sense: there is no missing
file whose recovery would close (G1)–(G6), since each is an independently
recorded open problem of the program (G0 and G3 are definitional requirements, not
theorems to recover; G5 and G6 have never been stated in reachable history,
so there is nothing to recover).

## 4. Recommendation

- Record the equivalence as **Conjectural bridge**, as the manuscript already
  does, and stop tagging it "source-pending".
- Keep the realization firewall: a formal recurrent cycle of `B_sigma` is not
  a pair of tilings; finite collar death is not a completeness theorem.
- The only theorem-grade content in this area is the seed-union proposition
  (Proposition 4.23) and the literature equivalence for a single seed cited in
  Section 4.8 of the manuscript, which is exactly why Open Problem 4.24 is the
  precise obstruction.
