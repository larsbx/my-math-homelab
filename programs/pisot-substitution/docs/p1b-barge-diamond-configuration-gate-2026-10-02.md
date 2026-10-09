# Literature gate: the Barge–Diamond configuration argument against strict zippers — 2026-10-02

**Status:** stop/go literature gate, the step named in §6 of
`p1b-periodic-pair-fibre-literature-gate-2026-10-02.md` and §7 of
`p1b-strict-zipper-periodic-pair-2026-10-02.md`. **Decision: stop.** The
configuration argument does not force a common vertex. Its maximality step
works in the vertex setting. What it produces there is a pair of tiles that
start at one point, and such a pair already shares a vertex. §4 records the
exact point of failure, and §5 the one valid vertex-form statement, which is
a necessary condition and is not promoted. Nothing here excludes a strict
zipper or proves PeriodicPairVertexCoincidence, AllSeedStrictZipperExclusion
or G1.

## 1. Question

Corollary B′ of the periodic-pair note reduces the strict-zipper branch
(issue #139, and with it G1 via manuscript Proposition 5.47) to
PeriodicPairVertexCoincidence. That statement says two `Phi^r`-fixed legal
tilings `T_A`, `T_B` with a common centre and integral centre offset share a
vertex. By Proposition F and Theorem R of the fibre gate, `T_A` and `T_B` lie
in one fibre of the maximal equicontinuous factor, for every PIP `sigma`.
The question is whether the configuration argument of Barge–Diamond (2002),
which Barge (2018) runs on `Psi`-fixed tilings in one fibre, can force that
common vertex.

## 2. Sources, read in full

| Source | Read |
| --- | --- |
| M. Barge, B. Diamond, *Coincidence for substitutions of Pisot type*, Bull. SMF 130 (2002), 619–626, [doi:10.24033/bsmf.2433](https://doi.org/10.24033/bsmf.2433) | all 8 pages |
| M. Barge, *The Pisot conjecture for beta-substitutions*, ETDS 38 (2018), 2009–2034, [arXiv:1505.04408](https://arxiv.org/abs/1505.04408) | §4 (Properties 1–3, Lemma 2 and its proof, Lemmas 7, 12, 13) |

## 3. The argument as it stands

**Barge–Diamond, Theorem 1.** For Pisot `phi` on `d` letters, *some* pair of
distinct letters is strongly coincident. This is one pair, not every pair.

- *Setting.* Strands are the broken lines in `Z^d` of words. `F_phi` is the
  Arnoux–Ito–Sano inflation of segments. By Lemma 2 every strand is
  eventually inside a fixed neighbourhood `N_B(E^u)` of the expanding line. A
  *configuration* is a set of segments crossed by one translate of the
  stable hyperplane at interior points.
- *Lemma 4.* There is a maximum size `M` of configurations that are not
  eventually coincident, bounded by the number of segments in `N_B(E^u)`
  that meet one stable slice.
- *Proof of Theorem 1.* Take a maximal non-eventually-coincident `C` and its
  iterates `C^(k)`. List the union vertices `P_0 < … < P_m` and the slice
  configurations `C_i` between them. At `P_i` some strands end, and the same
  number issue (`S_{i+1}`). Two cases:
  1. **Maximality.** Some alternative set `S′` of segments issuing at `P_i`
     keeps `C′_{i+1}` non-eventually-coincident. Then `C_{i+1} ∪ S′` is too
     large to be non-eventually-coincident, so some `s ∈ S_{i+1}`,
     `s′ ∈ S′` are eventually coincident. Both start at `P_i`, so
     `s = I_j + v`, `s′ = I_r + v` with `j ≠ r`, and the pair `(j, r)` is
     strongly coincident. **This is the theorem's conclusion.**
  2. **Determinism.** Otherwise `C_i` determines `C_{i+1}` up to
     translation. There are finitely many slice configurations up to
     translation, so `C_{i+p(l−i)} = C_i + p v` with `v ∈ Z^d \ {0}`
     bounded. Then `p v ∈ N_{2B}(E^u)` for arbitrarily large `p`, so
     `E^u ∩ Z^d ≠ {0}`, a contradiction.

**Barge 2018, Lemma 2.** Take `r = cr` pairwise tile-disjoint,
strongly regionally proximal, `Psi`-fixed tilings `S_1, …, S_r` (they exist
by Barge–Kellendonk), with slice configurations `C_j`. By non-periodicity
there are `k, l, w` with `C_k = C_l + w` but `C_{k+1} ≠ C_{l+1} + w`.
Maximality of `r` makes two tiles that begin at the same point `M_l`
strongly asymptotic on a dense set (Case 1). The closing step is
**Property 2** of beta-substitutions (if `ab` and `ac` are legal and `b ≠ c`,
then `b = 1` or `c = 1`), together with Property 1 in Case 2. Both are
monotonicity properties of the beta-transformation's language.

## 4. Transfer to vertex form, and where it fails

Define a configuration to be **eventually vertex-sharing** (EVS) when two of
its strands have, at some iterate, a common vertex strictly inside the
configuration's extent. A two-element configuration that is not EVS is a
vertex of `Z` (no offset-zero descendant), up to the boundary convention.
Let `M_v` be the maximum size of a non-EVS configuration. It is finite by
the same strip count as Lemma 4. `M_v >= 2` iff some overlap has no
offset-zero descendant.

Run the Barge–Diamond proof with a maximal non-EVS `C`.

- **What transfers.** In the iterates the strands are pairwise
  vertex-disjoint, so exactly one strand ends and one issues at each union
  vertex `P_i` (`l_i = 1`). The **determinism** case transfers verbatim. If
  every alternative segment `s′` at `P_i` makes `C′_{i+1}` EVS, then `C_i`
  determines `C_{i+1}`, and the lattice-point contradiction follows. In
  Barge 2018 the same fact removes Case 2: `#C′_l = 2` needs two strands
  ending at one point.
- **What fails.** In the **maximality** case some alternative `s′` keeps
  `C′_{i+1}` non-EVS. Maximality then makes `C_{i+1} ∪ {s′}` EVS. The only
  pair that can be EVS is `{s, s′}`, since every other pair lies in a non-EVS
  configuration. But `s` and `s′` *both start at `P_i`*: they form the
  left-aligned overlap `(j, r, 0)`. In the coincidence setting that pair is
  the theorem. In the vertex setting it shares the vertex `P_i` from the
  start. Maximality yields only that `(j, r, 0)` has a further common vertex
  inside its region at some depth. That is a property of an *aligned* pair,
  and aligned pairs are exactly what manuscript Proposition 5.47 says do not
  obstruct finiteness. No contradiction with the strict zipper `C` follows.
  The other strands are vertex-disjoint from both `s` and `s′`, and
  vertex-disjointness is not transitive.
- **Barge 2018 in vertex form.** Use `r_v` pairwise vertex-disjoint, srp,
  `Psi`-fixed tilings. Case 1 gives two tiles `a ≠ b` beginning at `M_l` such
  that every descendant of `(a, b, 0)` in its region has an offset-zero
  descendant: `(a, b, 0)` has no strict-zipper descendant. Barge closes this
  with Property 2. For an arbitrary PIP `sigma` there is no analogue of
  Property 2: nothing constrains the two distinct successors of a
  right-special context. The existence of a `Psi`-periodic maximal
  vertex-disjoint family, which Barge–Kellendonk supply for tile-disjoint
  families with `r = cr`, is also not established.

## 5. The one vertex-form statement that holds

*Lemma BD-v (necessary condition, not promoted).* If `M_v >= 2`, let `C` be
a maximal non-EVS configuration. Then for all large `k` some union vertex
`P_i` of `C^(k)` admits an alternative segment `s′` with `C′_{i+1}` non-EVS.
For every such `s′`, the aligned overlap formed by `s′` and the actual
segment `s` issuing at `P_i` has a common vertex strictly inside its region
at some depth.

*Proof.* §4: the determinism case is contradictory, and in the maximality
case the EVS pair must be `{s, s′}`. `square`

This is the kind of necessary-condition layer that `docs/audit-2026-09-20.md`
§F.3 says not to add to the zipper branch without a completeness or
uniformity statement. It is
recorded here only to locate the failure.

## 6. Decision

**Stop** the configuration route as a closing argument for #139. Add it to
the stop list of the fibre gate (§6 there). It may be reopened only with a
substitute for Property 2. That would be a statement forcing the alternative
continuation `s′` at a branch vertex to share a vertex with a strand of `C`
other than `s`, or forcing the actual continuation `s` to be EVS with the
rest of `C`. No such statement is known for general PIP substitutions.

What remains open is PeriodicPairVertexCoincidence, now unconditionally the
vertex analogue of coincidence rank one along periodic fibres
(Proposition F with Theorem R).
