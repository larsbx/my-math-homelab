# The valleys and the golden-mean parameter as finite objects

**Scope.** Six atlas valleys and the golden-mean Siegel parameter had names
but no finite key a computation could hold: a valley has no boundary, and the
Siegel parameter is irrational. Each is now the limit of an exact sequence of
limbs that the kernel prints and the tests check. Co-rabbit, Kokopelli and
the Siegel disk meet the code through their parameters. No verdict moves.

| Layer | File |
| --- | --- |
| limb angles by rotation number, Farey sequences | `kernel/mojo/dynamics/limb_streams.mojo` (smoke case "limb streams by rotation number") |
| the printed sequences | `kernel/mojo/entrypoints/structure_streams.mojo`, `pixi run structure-streams` |
| atlas relations `conjugate_of`, `tuning_of` | `schemas/structure_names.toml`, checked in `reference/python/atlas/structure_names_reference.py` |
| tests | `tests/test_structure_streams.py`, `tests/test_structure_names_atlas.py` |

## 1. A valley is the limit of a sequence of limbs

For a component `X` and a rotation number `r = a/b` with Farey parents
`a′/b′ < r < a″/b″`, the limbs of `X` at

```text
r_n⁻ = (n a + a′)/(n b + b′) ↑ r,     r_n⁺ = (n a + a″)/(n b + b″) ↓ r,     n = 1, 2, …
```

have exact root angles, and the atlas reference checks that they move
strictly monotonically toward the root angles of the `r`-limb. The sequence
is what fills the valley.

| Valley | `X` | `r` | First terms |
| --- | --- | --- | --- |
| `elephant-valley` | main cardioid | `0` (the cusp `1/4`) | `1/2, 1/3, 1/4, …` |
| `seahorse-valley` | main cardioid | `1/2` (the root `−3/4`) | `1/3, 2/5, 3/7, … ↑` and `2/3, 3/5, 4/7, … ↓` |
| `triple-spiral-valley` | main cardioid | `1/3` | `1/4, 2/7, … ↑` and `2/5, 3/8, … ↓` |
| `quad-spiral-valley` | main cardioid | `1/4` | `1/5, 2/9, … ↑` and `2/7, 3/11, … ↓` |
| `double-spiral-valley` | 1/2-bulb | `0` | the elephant sequence, tuned |
| `scepter-valley` | 1/2-bulb | `1/2` (the root `−5/4`) | the seahorse sequence, tuned |

The kernel and the atlas reference compute limb angles differently, and the
tests require them to agree term by term:

- **The kernel** reads them off the rotation itself. The itinerary of `j/q`
  under `x ↦ x + p/q` against `[1 − p/q, 1)` is a binary word of the cycle,
  and `θ₋`, `θ₊` are the words of `j = p − 1` and `j = p`.
- **The atlas reference** searches the doubling cycles of period `q`.
- **The tests** additionally check the defining property directly: one
  period-`q` cycle, doubling acting as rotation by `p/q`, `θ₋ θ₊` its
  shortest gap.

## 2. Exact facts the sequences carry

Each is checked by the tests on every term printed or on every `q ≤ 14`.

1. **Wake width on the main cardioid.** `θ₊ − θ₋ = 1/(2^q − 1)`.
2. **Two digits.** The root words of a `p/q`-limb are `w01` and `w10`: they
   differ only in their last two binary digits.
3. **Tuned width.** Tuning by the 1/2-bulb's rays `(1/3, 2/3)` replaces the
   digits `0, 1` by the blocks `01, 10`, so a word is read in base four with
   digits `1, 2`. Fact 2 then gives width `3/(4^q − 1)` for every limb in
   Scepter and Double Spiral Valley: `3/(2^q + 1)` times the width of the
   main-cardioid limb it is the image of.
4. **Tuning images.** Every tuned term has period `2q`, one kneading sequence
   on both rays, and internal address `1 → 2 → 2q`, read off the kneading
   sequence independently of how the angles were tuned.
5. **Conjugation.** `θ ↦ −θ` sends the 1/3-bulb to the 2/3-bulb, `c = i` to
   `c = −i`, and the rabbit to the co-rabbit; period, internal address and
   centre polynomial agree, and rotations are mirrored.

## 3. The golden-mean parameter as a sequence

The limbs at the convergents `F_n/F_{n+1}` (`1/2, 2/3, 3/5, 5/8, 8/13, 13/21,
21/34`) are printed with exact root angles up to `q = 34`. Consecutive
convergents are Farey neighbours, computed from the determinant, and the
terms with `q ≤ 14` agree with the cycle search. The bulbs repository
certifies the centres of the first five.

The parameter itself is the limit, and stays outside the finite core. The
golden mean has bounded type (every partial quotient is `1`); that bounded
type gives a Siegel disk, and that the Julia set is then locally connected,
are imported theorems (Siegel 1942; Petersen 1996).

## 4. What this opens

- **Limb size along a valley.** The bulbs repository's second-order law,
  `ρ = 1 − q²ε + q³(ι_{p/q} − ½)ε² + O(ε³)`, is a statement about each term
  here. Elephant and Seahorse Valley differ in their target: the parabolic
  index at the cusp is `0` and at the 1/2 root `1/8` (exact vectors in three
  repositories). How `ι` approaches those values along each sequence is a
  finite, tabulable question.
- **Does tuning preserve size ratios?** Fact 3 is exact for wakes. Whether
  the certified bulb sizes in Scepter Valley stand in a comparable ratio to
  those in Seahorse Valley is open, and the bulbs repository's
  certificates are where to measure it.
- **The co-rabbit and Kokopelli in the dynamical plane.** Both sit at
  irrational centres. Making them corpus rows in `finite-julia-set-research`
  needs a parameter given as a root handle (polynomial and certified box)
  rather than a rational; that is the next step and changes that corpus's
  schema.

## 5. What the sequences do not carry

- **A sequence is not a region.** The limbs fill a valley; the valley's
  extent is not defined, and the sequence certifies no boundary.
- **A prefix is not the limit.** Six Farey steps, or `q ≤ 34`, say nothing
  about the limit parameter or about terms beyond the bound.
- **A tuning image is combinatorial.** Tuning by a satellite sends the cusp
  of the main cardioid to a root that is not a cusp; the limb sequences
  correspond while the pictures differ.
- **Angles are not positions.** That the rays of a term land at a limb's root
  is the imported landing theorem, here as everywhere in the atlas.
