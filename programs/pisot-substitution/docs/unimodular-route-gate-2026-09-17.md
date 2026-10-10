# Route gate — restricting the programme to `|det M| = 1`

**Status:** one repository-proved restricted lemma plus an exact finite
determinant split of the corpus. This note does not prove overlap
productivity, the periodic-patch context bridge, strong coincidence, or the
Pisot substitution conjecture, and it does not change the standing regime.

## Proposed step

Drop firewall item 4 of `README.md` — "unimodularity `|det M| = 1`" — and run
the programme on the unimodular branch only, where the internal representation
is Euclidean and the geometric theory of Barge–Kwapisz is available.

This gate asks the question the firewall items are there to force: what does
the restriction buy on the **open premise**, what does it cost, and is the
thing it buys the thing that is currently blocking the route?

## Decision

**Do not restrict. Stratify by `det M` instead.**

The restriction buys exactly one of the two live obstructions, and it is not
the one in front of the route. The measurements are in findings 2–4 and the
one thing it does buy is upgraded to a theorem in finding 1, which is worth
recording on its own and does not need the restriction to be adopted.

## Findings

### 1. Unimodularity forbids a collapsing seed patch, and that is a theorem

### Lemma 1 (no unimodular patch collapse). **Status: repository-proved.**

Let `sigma` be a substitution on the alphabet `A` with incidence matrix
`M = M_sigma` and `|det M| = 1`. Then for distinct letters `a != b` and every
`n >= 1`, the word `sigma^n(ab)` is not a proper power.

**Proof.** Suppose `sigma^n(ab) = u^k` with `k >= 2`. Taking Parikh vectors and
writing `P` for the Parikh map,

```text
M^n (e_a + e_b) = P(sigma^n(ab)) = k * P(u).
```

`M^n` lies in `GL_A(Z)` because `|det M^n| = 1`, so

```text
e_a + e_b = k * M^(-n) P(u)  in  k Z^A.
```

But `a != b` gives `e_a + e_b != 0` with every coordinate in `{0, 1}`, so some
coordinate equals `1` and `k` divides `1`, contradicting `k >= 2`. ∎

The lemma uses neither primitivity, nor irreducibility, nor the Pisot
property: it is the divisibility content of unimodularity alone. It holds at
every level, so it is stronger than any level-capped census statement.

By `docs/p1-overlap-collar-2026-09-16.md` §3.3, a collapsing seed patch is
exactly what makes a seed-patch occurrence's ancestry unresolvable by bounded
context on this corpus. Lemma 1 therefore says that the §3.2 golden
countermodel — `0 -> 102, 1 -> 2, 2 -> 020`, whose level-one patch for the
pair `{1,2}` is `(20)^Z` — is a non-unit phenomenon by necessity and not by
accident. That substitution has `det M = 2`.

What Lemma 1 does **not** give is the converse implication. That no seed patch
collapses does not prove that a finite separation radius exists; the
equivalence in §3.3 is a corpus equivalence at the tested levels, not a
theorem, and this note does not upgrade it.

### 2. The corpus determinant split

### Computational Proposition 2 (determinant split of the corpus). **Status: finite-domain theorem.**

On the exact 4,554-member alphabet-3 short-image PIP corpus, with the
arithmetic regime of `psc.corpus.arithmetic_regime` and the collapse predicate
of `psc.overlap_collar.collapsing_seed_pair_count` at level `6`:

| `det M` | specimens | overlap vertices | collapsing seed patch | zero-shift-free affine pump |
| --- | --- | --- | --- | --- |
| `+1` | 1,980 | 122,656 | 0 | 1,950 |
| `-1` | 648 | 27,164 | 0 | 648 |
| `+2` | 1,926 | 969,030 | 120 | 1,926 |
| total | 4,554 | 1,118,850 | 120 | 4,524 |

Only `|det M| in {1, 2}` occurs at image length at most three on three
letters, so the non-unit branch of this corpus is exactly the
determinant-two branch. The unimodular branch is 2,628 specimens, 57.7% of
the corpus and 13.4% of its overlap vertices.

The pump column reproduces the count of `docs/p1-overlap-collar-2026-09-16.md`
§3.3 (4,524 specimens with a zero-shift-free recurrent cycle) and attributes
it by determinant, which that note did not do.

*Provenance of these numbers.* Two implementations agree on them. The
independent Python oracle (`psc_research.pip_screen`,
`psc_research.overlap_collar`, `psc_research.overlap_affine_pump`) produced the
table; the canonical regime split of `kernel/swap_overlap_census.mojo` reproduced
it line for line in CI:

```text
regime |det M| > 1: specimens: 1926 overlap states: 969030 collapsing patches: 120 zero-shift-free pumps: 1926
regime |det M| = 1: specimens: 2628 overlap states: 149820 collapsing patches: 0 zero-shift-free pumps: 2598
unimodular collapsing seed patches (must be 0): 0
```

Those three lines are pinned by the `swap-overlap-census` job, and
`kernel/tests/test_unimodular_route.mojo` guards the same split in the
regression suite, so a drift in either direction fails the build rather than
changing a number in this table.

### 3. The collapse obstruction is entirely non-unit; the pump obstruction is not

The two live obstructions split in opposite ways.

- **Collapse.** All 120 collapsing specimens have `det M = 2`; no unimodular
  specimen collapses at levels `1..8`. This is finding 1 as a computation,
  and finding 1 is the reason it is not a coincidence of the corpus.
- **Pump.** A zero-shift-free affine cycle is extracted from 2,598 of the
  2,628 unimodular specimens, 98.9%, with minimum cycle length `1` in every
  determinant class. The restriction does not touch it.

The only determinant sensitivity of the pump runs the other way: the 30
specimens with no zero-shift-free cycle at all are all unimodular, 1.1% of
that branch. Nothing follows from 30 specimens.

### 4. The open premise is determinant-blind

This is the finding that decides the gate, and it comes from the repository's
own manuscript rather than from a measurement.

Manuscript Proposition 5.39 (`docs/overlap-finiteness-and-coincidence-density-2026-09-13.md`
§9.1) proves that Open Problem 5.35 for the swap seed implies the two-sided
strong coincidence condition of Arnoux–Ito, and records that this condition is
open for `d >= 3`. No determinant hypothesis enters that implication, and the
literature's open case is the unimodular one. Restricting to `|det M| = 1`
therefore leaves the primary gate standing on a problem that has been open in
the unimodular setting since Arnoux–Ito, on a corpus where `d = 3` always.

Nothing on the proved part of the shortest route is bought either. UD, G1b-1
bounded discrepancy, the finite seed-patch overlap graph, Lemma 5.36 and the
audited Barge–Štimac–Williams import are all proved without unimodularity, so
the restriction adds no usable premise there; it only weakens the conclusion
of the theorem the route is aiming at.

### 5. What the restriction would genuinely buy, and when

Two things, both real and both late.

- **A Euclidean internal representation.** The finite-place factors of Siegel
  and of Minervino–Thuswaldner are absent at `|det M| = 1`, so the
  representation space is `R^(d-1)` and the geometric theory of Barge–Kwapisz
  becomes citable in the restricted statement. Step 5 of the affine-pump
  programme (`docs/p1-overlap-affine-pump-2026-09-15.md` §4) could then be
  discharged by citation instead of construction, and the `M`-adic ball
  carrier of `larsbx/finite-math-kernels` would be unnecessary inside the
  restricted domain.
- **Lemma 1**, which removes the collapse branch of the context bridge.

The programme is blocked at **step 4**, the seed-relative growth and splicing
bridge, which findings 3 and 4 show to be determinant-blind. Unimodularity is
a simplification of a step the route has not reached.

### 6. What the restriction does not repair

Firewall item 6 survives it. For an irreducible cubic Pisot `beta`, unit or
not, `pi_s(Z^A)` is a rank-3 subgroup of a two-dimensional contracting space
and is dense, not discrete. "Unimodular, therefore a stable lattice" is false,
and a proof that wants a discrete stable object still has to earn it.

## What this gate licenses, and what it does not

1. **Licensed:** Lemma 1 as a repository-proved restricted lemma, and
   Computational Proposition 2 as a finite-domain determinant split, with the
   regime split folded into the existing `kernel/swap_overlap_census.mojo`
   survey rather than a second driver.
2. **Licensed:** reading `det M` as a first-class coordinate of the corpus in
   any future obstruction census, so that "is this obstruction non-unit?" is a
   measured question rather than an assumption.
3. **Not licensed:** dropping or weakening firewall item 4 or item 5. The
   standing regime is unchanged, and a unit-only conclusion stays marked
   restricted.
4. **Not licensed:** any claim that the unimodular branch is closer to a
   productivity theorem. Finding 3 measures the opposite for the pump, and
   finding 4 states why the gate itself does not move.
5. **Not licensed:** treating Lemma 1 as progress on Open Problem 5.35. It
   bears on the context bridge's collapse branch only, and only on one branch
   of the regime.
6. **Not licensed:** any separation, tiling, or unique-representation property
   in the Euclidean internal space of the restricted domain. Finding 5 names
   the theory as citable; citing it is a step this gate does not take.

## If a restricted sub-theorem is wanted anyway

The productive axis is structural rather than determinantal. The unimodular
class is not a route, it is a smaller instance of the same open problem: for
`d = 2` the unimodular irreducible Pisot case is already a theorem in the
literature, and for `d >= 3` it is exactly the open case. A restriction that
buys a theorem has to restrict the combinatorics (β-substitutions,
Arnoux–Rauzy families), not the determinant. This note does not audit those
families; naming them is a pointer, not an import.

## Sources

Repository surfaces are the primary sources for findings 2–4:
`docs/p1-overlap-collar-2026-09-16.md` §3.2–3.3,
`docs/overlap-finiteness-and-coincidence-density-2026-09-13.md` §9.1,
`docs/p1-overlap-affine-pump-2026-09-15.md` §4, and
`docs/padic-representation-literature-gate-2026-09-16.md` findings 1 and 3.

The external references below are bibliographic and are not verified
snapshots; no PDF was imported for this gate, so nothing here is an audited
import and no hypothesis of these works has been checked against the standing
regime.

[^1]: Pierre Arnoux and Shunji Ito, "Pisot substitutions and Rauzy fractals," *Bulletin of the Belgian Mathematical Society Simon Stevin* 8 (2001), 181–207.
[^2]: Marcy Barge and Jarosław Kwapisz, "Geometric theory of unimodular Pisot substitutions," *American Journal of Mathematics* 128 (2006), 1219–1282.
[^3]: Anne Siegel, "Représentation des systèmes dynamiques substitutifs non unimodulaires," *Ergodic Theory and Dynamical Systems* 23 (2003), 1247–1273.
[^4]: Milton Minervino and Jörg Thuswaldner, "The geometry of non-unit Pisot substitutions," *Annales de l'Institut Fourier* 64 (2014), 1373–1417.
[^5]: Shigeki Akiyama, Marcy Barge, Valérie Berthé, Jeong-Yup Lee and Anne Siegel, "On the Pisot substitution conjecture," in *Mathematics of Aperiodic Order*, Progress in Mathematics 309, Birkhäuser, 2015, 33–72.
