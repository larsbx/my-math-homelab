# P1 overlap productivity — radius-`m` periodic-patch collars

**Status:** repository-proved collar recursion lemma plus exact finite
calibration. This note does not prove the periodic-patch context bridge, a
recognizability radius for the periodic patches, overlap productivity, or the
Pisot substitution conjecture.

Primary target: issue #84 / manuscript Open Problem 5.35. Dependencies: the
ordered occurrence dictionary of PR #89, the affine pump certificate of
`p1-overlap-affine-pump-2026-09-15.md`, and the one-step checkpoint of
`p1-overlap-context-equality-2026-09-15.md`. This is the depth-`k` collar
that the latter two notes leave open, in its radius form.

## 1. The object

Fix distinct letters `a != b`. The two periodic patches of the swap seed are
the bi-infinite words `(ab)^Z` and `(ba)^Z`, tiled by the Perron tile lengths
with the top patch's `a` and the bottom patch's `b` both starting at `0`; the
seed overlaps are the overlapping tile pairs of the two patches, and an
occurrence path of length `n` from a seed (a sequence of actual ordered child
occurrences, PR #89) is an actual pair of tiles, one in `sigma^n((ab)^Z)` and
one in `sigma^n((ba)^Z)`.

The **radius-`m` collar** of such an occurrence is the quadruple

```text
(L_top, R_top, L_bot, R_bot),
```

the `m` letters immediately to the left and to the right of the top tile in
`sigma^n((ab)^Z)` and of the bottom tile in `sigma^n((ba)^Z)`. A collared
state is an overlap state `(i,j,w)` of the seed-patch graph together with a
collar; the collared occurrence graph at radius `m` has the collared states
reachable from the collared seeds as vertices and the actual child
occurrences as edges, each edge carrying its one-step ancestry label (the
parent letters and the two child indices).

The two periodic patches are the same bi-infinite word up to a shift, so the
collar of a seed tile depends only on its letter: it is the alternating word
in `{a,b}` on both sides, starting with the partner letter.

### Lemma 1 (collar recursion). **Status: repository-proved.**

Let an occurrence have parent tiles `x` (top) and `y` (bottom) with radius-`m`
collar `(L, R, L', R')`, and let the child occurrence use the `r`-th letter of
`sigma(x)` and the `s`-th letter of `sigma(y)`. Then its radius-`m` collar is

```text
( last_m( sigma(L) sigma(x)[:r] ),  first_m( sigma(x)[r+1:] sigma(R) ),
  last_m( sigma(L') sigma(y)[:s] ), first_m( sigma(y)[s+1:] sigma(R') ) ).
```

Consequently the collared occurrence graph at radius `m` is finite, its
projection to the seed-patch overlap graph is a surjective graph morphism
sending collared edges onto actual occurrence edges, and the radius-`m` collar
of an occurrence is the truncation of its radius-`(m+1)` collar.

**Proof.** The level-`(n+1)` patch is the letterwise image of the level-`n`
patch, and the child tile is the `r`-th letter of the image of its parent.
The `m` letters to its left are therefore the last `m` letters of the image of
the parent's left context followed by the first `r` letters of `sigma(x)`;
since every image has at least one letter, the image of the `m` letters `L`
already has at least `m` letters, so nothing to the left of `L` contributes.
The right side and the bottom tile are the same. Finiteness follows because
the seed-patch graph is finite (manuscript Theorem 4.22) and there are
finitely many words of length `m`; the morphism and truncation statements are
read off the formula. ∎

The recursion is checked exactly, in Mojo and in Python, against the collar
read directly off the inflated periodic patch for several ancestry paths.

### Lemma 2 (collars along a periodic occurrence path). **Status: repository-proved.**

Let an occurrence path repeat a cycle of `r` occurrence labels forever (for
instance an affine pump certificate), and write `C_k` for the radius-`m`
collar at level `kr`. Then `C_(k+1) = g(C_k)` for a map `g` on the finite set
of collars that depends only on `m`, `sigma` and the cycle's labels. Hence
`(C_k)` is eventually periodic.

**Proof.** Iterating Lemma 1 along the `r` labels of the cycle expresses
`C_(k+1)` as a function of `C_k` and the fixed labels; the parent letters
along the cycle are fixed by the labels, so the function is the same at every
traversal. ∎

The period need not be `1`: if the top tile is the first child of its
`r`-fold ancestor at every traversal, its left neighbour at level `(k+1)r` is
the last letter of `sigma^r` applied to its left neighbour at level `kr`, and
the last-letter map of `sigma^r` may have a cycle of length greater than one.
The census below meets such pumps.

## 2. Three finite diagnostics

- **Unresolved collision.** A collared state reached by two occurrences with
  different one-step ancestry labels. The collar at that radius does not
  determine the parent occurrence (and hence, the affine recurrence being
  invertible over `Q`, not the parent state either).
- **Separation radius.** The least `m` at which no unresolved collision
  exists. By the truncation clause of Lemma 1, a collision at radius `m+1` is
  a collision at radius `m`, so resolution is monotone in `m` and the least
  such `m` is well defined. The search is capped; a specimen with a collision
  at the cap is a survivor, counted and printed, never resolved by assumption.
- **Lift of an affine pump.** Given an occurrence-labelled cycle, replay it
  from every collared state over its first state and report the preperiod and
  the period of the collar sequence of Lemma 2, in traversals of the cycle.
  Period `1` means that after the preperiod every traversal returns to the
  same collared state: the pumped occurrences sit in one symbolic context of
  radius `m`.
- **Legality.** Whether the collared tile, the `2m+1` letters centred at the
  tile, is a factor of the language of `sigma`, decided by the exact
  fixed-point closure of the length-bounded factor set.
- **Patch collapse.** The least `n >= 1` at which `sigma^n(ab)` is a proper
  power `u^k`, `k >= 2`, for a seed pair `{a,b}`. Then the level-`n` patch
  `(sigma^n(ab))^Z = u^Z` has a period shorter than the image of the seed
  period, so it admits two parsings into images of the level-`(n-1)` patch,
  shifted by `|u|`: two ancestries with the same bi-infinite context, which
  no collar radius separates. This is the classical failure of unique
  desubstitution on periodic words, and it is inherent to the periodic-patch
  construction, not to the collar.

Canonical implementation and regression:

```text
kernel/psc/overlap_collar.mojo
kernel/tests/test_overlap_collar.mojo
```

Independent oracle:

```text
reference/psc_research/overlap_collar.py
tests/test_overlap_collar.py
```

The corpus census `kernel/swap_overlap_census.mojo` now reports the separation
radius of every specimen (capped at `6`), whether some seed pair's patch
collapses by level `6`, the two cross-terms (a survivor without a collapse,
a collapse without a survivor), and the lift of the first zero-shift-free
affine pump at radius `4`.

## 3. Exact results

### 3.1 The determinant-two regression

For `0 -> 1, 1 -> 0 2 1, 2 -> 0 0 1` (628 overlap states):

| radius `m` | collared states | largest fibre | unresolved collisions | legal collared states |
| --- | --- | --- | --- | --- |
| 0 | 628 | 1 | 269 | 628 |
| 1 | 1866 | 15 | 0 | 1854 |
| 2 | 2861 | 18 | 0 | 2837 |
| 4 | 4991 | 39 | 0 | 4950 |
| 8 | 9185 | 69 | 0 | 9110 |

- The affine state alone leaves 269 of 628 states with ambiguous one-step
  ancestry; one letter of context on each side of each tile resolves every
  occurrence. The separation radius is `1`.
- The 12 collared states of radius `1` whose context is not a factor of the
  language are exactly the 9 seeds (whose collars are the alternating words
  of the periodic patch, such as `1 0 1`) and 3 states at level one; from
  level two on, every radius-`1` collar is legal.
- The six-edge zero-shift-free affine pump lifts to collared cycles at radii
  `1`, `2` and `4` (fibres of `11`, `12` and `16` collared states): every
  collared state over the cycle's first state returns to itself after at most
  one traversal, and one collared state is fixed outright. At radius `4` the
  fixed collar is `1 0 2 1 | 0 0 1 0` around the top tile and
  `2 1 0 2 | 1 1 0 2` around the bottom tile (letters as in the
  substitution above; the bar marks the tile). The
  one-step mismatch of the previous note is therefore transient along this
  pump: the two occurrences reaching the same affine state with different
  contexts are one traversal apart, not two persistent contexts.

### 3.2 A collision that no radius separates

For `1 -> 2 1 3, 2 -> 3, 3 -> 1 3 1` (126 overlap states; one-based letters)
three collared states remain unresolved at every radius up to `12`. The
witness is the state `(3, 1)` with the periodic word `(31)^Z` on both sides
of both tiles, reached with the labels `(2, 0, 3, 0)` and `(3, 1, 3, 2)`: the
top `3` is the image of a `2` in one ancestry and the middle letter of
`sigma(3) = 131` in the other. The source is the seed pair `{2, 3}`, whose
level-one patch is `sigma(2) sigma(3) = 3 131 = (31)^2`: `patch_power_level`
reports level `1` for that pair and none for the other two. This
substitution is a golden countermodel to the overstrong statement that a
finite collar radius always resolves the ancestry of a seed-patch occurrence.

### 3.3 The exact 4,554-member corpus

On the exact short-image ternary PIP corpus (`kernel/swap_overlap_census.mojo`,
cap `6` on the separation radius, lifts at radius `4`):

| separation radius | 1 | 2 | 3 | 4 | 5 | 6 | survivor at 6 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| specimens | 618 | 2664 | 912 | 216 | 12 | 12 | 120 |

- 4434 specimens resolve every occurrence's one-step ancestry at radius at
  most `6`; the median radius is `2`.
- The 120 survivors at radius `6` are exactly the 120 specimens with a seed
  pair whose patch collapses to a proper power by level `6`: no survivor
  without a collapse, no collapse without a survivor. All 120 are
  non-unimodular, and `docs/unimodular-route-gate-2026-09-17.md` Lemma 1
  proves that they must be: a unimodular incidence matrix forbids a collapsing
  patch at every level. The collapsing case of this dichotomy is therefore a
  non-unit phenomenon, which does not make the surviving collision easier to
  resolve on the branch where it occurs. On this corpus the
  finite obstruction to resolving ancestry by context is entirely the
  periodicity of the patches, and a separation radius exists precisely when
  no iterated seed patch is a proper power at the tested levels.
- This equivalence is a finite statement at the stated caps. On the
  24,486-member total-length class
  (`docs/lost-depth-indexed-formulation-2026-10-01.md` §§6, 9) it fails at the
  survey's radius cap `6`: one symmetry orbit of 12 specimens keeps a
  collision there without a collapsing patch. Its representative
  `0 -> 1, 1 -> 2, 2 -> 022102` has separation radius `9` and no collapsing
  patch through level `14` (regressions in `kernel/tests/test_overlap_collar.mojo`
  and `kernel/tests/test_separation_sweep.mojo`). The deterministic sweep
  `kernel/separation_radius_total_length_sweep.mojo` decides all 24,486
  specimens at radius cap `12`: the 12 members of that orbit are exactly the
  specimens of radius above `6` (all radius `9`), and the 852 that never
  separate are exactly those with a collapsing patch by level `6`. At that
  cap the equivalence holds on the whole class.
- Of the 4524 specimens with a zero-shift-free recurrent cycle, the first
  affine pump lifts at radius `4` to a collar that is eventually constant in
  3820 specimens and eventually periodic with period `2` or `3` in 704; the
  preperiod is at most `4` traversals and the period at most `3`. Lemma 2's
  period is realized: the corpus contains pumps whose symbolic context
  cycles, as the last-letter map of `sigma^r` cycles.

## 4. Meaning and limitation

*Meaning.* The collar is the exact finite object that the literature gate
asked for before any recognizability or splicing argument: a paired
prefix-suffix address with a finite symbolic neighbourhood in the iterated
periodic patches, computed by an exact recursion rather than read off a
subshift. The separation radius makes the phrase "the context determines the
cut" a decidable statement about one substitution's finite seed-patch
hierarchy, and the lift makes "equal affine states with equal contexts along a
pump" an exact eventually periodic object. On the golden pump the contexts
are eventually equal at every tested radius: bounded-radius context equality
cannot by itself exclude zero-shift-free recurrence, because this pump lives
in a productive graph. Whatever excludes a closed nonproductive strict-zipper
component must therefore use more than the equality of bounded contexts, for
instance child closure and nonproductivity together with the exact cycle
identity and a dictionary from legal collared occurrences to the
realized-overlap graph of the tiling.

*Meaning of the collapse dichotomy.* The corpus equivalence between
surviving collisions and collapsing patches says what the periodic-patch
context bridge can and cannot ask for: outside the collapsing case the
hierarchy resolves every occurrence's ancestry from bounded context, an
exact analogue of recognizability on the patches themselves; in the
collapsing case two ancestries are translates by a period of the patch and
produce the same overlaps, which is why the seed-patch graph is a graph of
overlap types and why the density bridge of Barge–Štimac–Williams counts
occurrences per period rather than parsing them.

*Limitation.* A separation radius is a property of one substitution's finite
graph; the corpus distribution is finite evidence and neither bounds the
radius for other substitutions nor identifies it with a recognizability
constant of Mossé or Durand–Leroy, which are theorems about the aperiodic
subshift, not about the periodic patches. Legality of a collar is necessary
for reading an occurrence as a tiling overlap and is not claimed sufficient.
Period `1` of a lift at a finite radius does not license deleting or
repeating the loop in any argument about the tiling; it records that the
seed-patch hierarchy realizes the pump in one bounded context, which it does
by construction. No cap, corpus or radius bound is self-certifying.

## 5. Literature status

This slice is the second executable prescribed by
`p1-overlap-affine-pump-literature-gate-2026-09-15.md` (steps 1 and 3 of its
revised program) and stays inside that stop/go decision; no new search was
made. The collar is the prefix-suffix address language of Canterini–Siegel
with a finite symbolic neighbourhood; the separation radius is the
periodic-patch analogue of the recognizability radius whose computability
for the subshift is Durand–Leroy's theorem, and is not that constant. The
next steps of the program, the seed-relative growth bridge and the non-unit
representation, are untouched.
