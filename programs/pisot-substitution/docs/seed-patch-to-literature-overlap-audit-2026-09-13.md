# Seed-patch to literature-overlap bridge: closure audit

**Status (2026-09-13; superseded for sufficiency on 2026-09-14):** the local balanced-pair/overlap dictionary is
repository-proved. The global coverage transfer below is no longer needed for the G1-free route to PDS: Barge–Štimac–Williams Theorem 3.1 applies directly to the periodic swap patch (manuscript Imported Theorem 5.37, Theorem 5.38; `docs/overlap-finiteness-and-coincidence-density-2026-09-13.md`, Section 8). The transfer remains of independent interest only. This audit
closes the former multi-item realization research thread by separating the
proved local interface from that single unproved implication. It does not
prove overlap productivity, G1b-2, G1, pure discrete spectrum, or PSC.

## 1. Objects that must not be identified

The repository seed-patch graph `O_sigma` starts with the finite aligned
patch pair

```text
ab
ba
```

for each unordered letter pair and closes those overlaps under inflation.

Sirvent--Solomyak's overlap algorithm `oa-x` instead fixes a translation
`x in Z[beta] cap R_+` and uses every overlap arising between the infinite
tilings `T` and `T-beta^n x`, for all `n >= 0`. Its graph is denoted
`G_O(T,x)`. Their Theorem 4.1(b) says that if this complete graph terminates
with coincidences for some such `x`, then the tiling flow has pure discrete
spectrum. In their terminology "terminates with coincidences" means that
every graph vertex has a path to an overlap-coincidence; finiteness of the
graph is automatic in their Pisot setting.

For a prefix `W` of a substitution fixed point they take
`x(W)` to be its geometric length. A standing substitution need not itself
have a one-sided fixed point: its first-letter map may have a nontrivial
cycle. Choose a letter on such a cycle and a multiple `q` of the cycle length;
then `sigma^q` is prolongable on that letter and has a one-sided fixed point
`u`. Passing to `sigma^q` does not change the substitution tiling hull or its
translation spectrum. It also does not change overlap productivity: a
coincidence reached after `k` one-step inflations persists, so further
inflation reaches a coincidence at a multiple of `q`, while every
`sigma^q` path is already a `sigma` path.

For this powered presentation, Sirvent--Solomyak Section 5 identifies the
balanced-pair algorithm for the infinite pair `(u, shift^{|W|}u)` with
`oa-x(W)`. This is not the same initial object as a finite swapped patch.
Legality of `ab` alone does not identify the two.

Primary source:

- V. F. Sirvent and B. Solomyak, "Pure Discrete Spectrum for
  One-dimensional Substitution Systems of Pisot Type," *Canadian
  Mathematical Bulletin* 45 (2002), 697--710,
  DOI [10.4153/CMB-2002-062-3](https://doi.org/10.4153/CMB-2002-062-3):
  overlap graph and criterion in Section 4, especially Theorem 4.1;
  balanced-pair/overlap relation in Section 5, especially Theorems 5.1 and
  5.6.

Akiyama--Lee gives a broader self-affine/Meyer overlap-coincidence criterion,
but it does not by itself turn the repository's smaller initial family into
the complete graph:

- S. Akiyama and J.-Y. Lee, "Algorithm for determining pure pointedness of
  self-affine tilings," *Advances in Mathematics* 226 (2011), 2855--2883,
  [arXiv:1003.2898](https://arxiv.org/abs/1003.2898).

## 2. What is now proved locally

The following formerly proposed bridge items are discharged by
`docs/overlap-finiteness-and-coincidence-density-2026-09-13.md`.

| Local obligation | Repository result |
| --- | --- |
| A realized reduced balanced pair gives an ordered overlap chain | Lemma 1.1 together with the construction preceding Lemma 3.1 |
| Inflation of the pair agrees with refinement of the chain | child formula and Lemma 1.1 |
| Parikh zero returns are exactly simultaneous boundaries | Lemma 3.1 |
| Letter coincidences are exactly common full tiles | Lemma 3.2 |
| Seed-patch overlap types form a finite graph | Theorem 2.1 |
| Productivity is equivalent to positive common fraction; all seed overlaps productive iff seed coincidence density is one | Theorem 4.1 |

These statements require no claim that every formal balanced-pair state is
globally realized. They concern states and overlaps that actually occur in
the inflated finite swapped patches.

## 3. The exact remaining bridge

The weakest sufficient statement is the following.

**Seed-to-OA productivity transfer.** For every standing PIP substitution,
choose a prolongable power `tau = sigma^q` as above. There exist a legal
swapped seed `(ab,ba)` for `tau` and a prefix `W` of the resulting fixed point
such that

```text
every tau-overlap reachable from (ab,ba) is productive
    =>
every vertex of G_O(T,x(W)) is productive.
```

Equality or surjectivity of the two vertex sets is stronger than necessary.
A map may use collars or occurrence context, provided it commutes with
inflation and sends a complete-graph nonproductive class to a seed-patch
nonproductive class.

If this transfer is proved, the G1-free route is rigorous:

```text
general seed-patch overlap productivity
=> productivity of every vertex of G_O(T,x(W))
=> oa-x(W) terminates with coincidences
=> PDS.
```

The last arrow is Sirvent--Solomyak Theorem 4.1(b). No balanced-pair
finiteness hypothesis occurs in this chain.

## 4. Why coincidence density alone does not yet close it

The repository's density `delta((ab,ba))` measures common-tile length in
successive inflations of one finite swapped patch. When it is one, every
overlap in that seed-patch graph is productive.

Sirvent--Solomyak's proof uses the complete translated tilings and all
classes in `G_O(T,x)`; the key density is global along those tilings.
A density-one statement on one growing finite patch cannot be substituted
without proving that omitted realized overlap classes either:

1. occur inside controlled translates of the seed-patch hierarchy, or
2. inherit coincidence reachability from classes that do.

Boundary errors of sublinear length are harmless for density, but an omitted
nonproductive overlap class can recur with positive frequency by primitivity.
Therefore a bare exhaustion-by-length argument is insufficient unless it
also controls occurrence context.

## 5. Proof and countermodel interfaces

A proof should provide an explicit context radius or recognizability datum
and establish:

1. every complete-graph class has a collared occurrence;
2. after a uniformly bounded number of desubstitutions, that occurrence is
   represented in an inflated swapped patch;
3. the representation preserves child reachability to coincidence.

A failed transfer should be retained as a replayable exact countermodel:

- substitution images and exact characteristic polynomial;
- prefix `W` and translation `x(W)`;
- exact overlap type plus enough collar to certify its occurrence;
- a closed nonproductive SCC of `G_O(T,x(W))`;
- evidence that no represented seed-patch vertex maps to that SCC.

Any executable search must fail closed on state or collar caps. A clean
bounded search remains finite evidence unless an independent uniform collar
bound is proved.

## 6. Separation from G1

Uniformly bounded distance between consecutive half-coincidences in
`(T,T-beta^n x(W))` is equivalent to balanced-pair termination in
Sirvent--Solomyak Theorem 5.6. That is the G1b-2 direction.

The productivity transfer above asks only that every complete overlap class
eventually reach a full coincidence. It does not bound distances between
simultaneous boundaries and therefore would not prove G1 or G1b-2. Conversely,
G1b-2 is not needed if the productivity transfer and general seed-patch
overlap productivity are proved.

## 7. Closed research conclusion

The realization thread has no remaining local dictionary sublemmas.
The global seed-to-OA productivity transfer of Section 3 remains unproved,
but since 2026-09-14 it is not needed for sufficiency: the G1-free spectral
bridge is supplied by Barge–Štimac–Williams Theorem 3.1 applied to the
periodic swap patch (manuscript Lemma 5.36, Imported Theorem 5.37, Theorem
5.38), and the former density-bridge open problem is retired. Overlap
productivity (Open Problem 5.35) remains open and the exact
4,554-substitution overlap census remains finite evidence.
