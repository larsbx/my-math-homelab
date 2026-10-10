# Names atlas: the common names for structures of the Mandelbrot set

**Scope.** A dictionary, not a theorem. Every name people use for a piece of
the Mandelbrot set — from `hyperbolic component` to `seahorse-valley` — is
keyed here to exact data: rational external angles, internal addresses,
integer polynomials, rational parameters and rational isolating intervals.
No verdict in this repository moves, and no project term is introduced; every
defining word below is a field term (Route A of
`docs/terminology-governance.md`).

| Layer | File |
| --- | --- |
| the table, one entry per structure | `schemas/structure_names.toml` |
| the exact checks | `reference/python/atlas/structure_names_reference.py` |
| the tests (every field recomputed, plus doc ↔ table binding) | `tests/test_structure_names_atlas.py` |
| this prose | `docs/mandelbrot-structure-names-atlas.md` |

The defining family is `f_c(z) = z^2 + c` with critical point `0`
(`docs/mandelbrot-defining-family.md`).

## 0. Reading an entry

| Field | Meaning | Checked by |
| --- | --- | --- |
| `name_status` | `field` (standard in the literature), `eponym` (after a person), `folk` (popular; the source says whose) | enum |
| `root_angles` | the two parameter rays landing at the root, `θ₋ < θ₊`; one ray (angle `0`) for the main cardioid | exact type `(0, n)` under doubling; equal kneading sequences |
| `internal_address` | Lau–Schleicher internal address `1 → … → n` | recomputed from the kneading sequence of `θ₋` |
| `parent`, `rotation` | the component is the `p/q`-satellite of `parent` | angles recomputed: by rotation number on the main cardioid, by Douady tuning elsewhere |
| `root_parameter` | rational root `c` | `f_c^n(z) − z` has a repeated root and `f_c^d(z) − z` does not, for every `d ∣ n`, `d < n` |
| `center_polynomial` | integer factor of the Gleason polynomial `f_c^n(0)` | divides `f_c^n(0)`, coprime to `f_c^d(0)` for `d ∣ n`, `d < n` |
| `center_interval` | rational interval isolating the real centre | Sturm count equal to one |
| `angles`, `angle_type` | rays landing at a Misiurewicz parameter, exact type `(ℓ, k)` | recomputed |
| `parameter`, `critical_orbit_type` | Gaussian-rational `c = x + iy` as a rank-2 coordinate record, and the `(preperiod, period)` of its critical value | exact orbit over `Q` |
| `landing_cycle` | the ray cycle the angles fall into after `ℓ` doublings | forward images contained in it; it is closed under doubling |
| `limb` | the main-cardioid limb that contains the angles | angles strictly inside the `p/q`-wake |
| `accumulation` | limbs of `parent` whose rotation numbers tend to `rotation` along Farey sequences | root angles strictly monotone toward the target |
| `conjugate_of` | the entry is the complex conjugate of another | angles negated (`θ ↦ −θ` mod 1), period, address and centre polynomial equal, rotations mirrored, Gaussian parameter conjugated; for a Julia set, its parameter's conjugate |
| `tuning_of` | a region is the image of a main-cardioid region under tuning by a component | every tuned limb of the image has period `n q`, one kneading sequence on both rays, and internal address that of the component extended by `n q`, read off the kneading sequence |

Conventions. Angles are in `Q/Z`, written in `[0, 1)`. Munafo's `R2` names
(Mu-Ency) are given where the folk names come from there: `R2a` is the main
cardioid, `R2.p/qa` its `p/q`-bulb, `R2.C(p/q)` the cusp region at that bulb's
root.

## 1. Where things are

The combinatorial skeleton, by internal address. An arrow is "is a satellite
or descendant of"; the decimal values are floating-point orientation only and
are not certified locations.

```text
main cardioid  1                       cusp c = 1/4 (Elephant Valley)
├── 1/2-bulb  1→2                      root c = −3/4 (Seahorse / Double Spiral Valley)
│   ├── 1/2-bulb of 1/2-bulb  1→2→4    root c = −5/4 (Scepter Valley)
│   │   └── … period-doubling cascade → Feigenbaum point ≈ −1.4011552
│   └── (1/2-limb, beyond the cascade) main antenna
│       ├── period-3 window 1→2→3      root c = −7/4, centre ≈ −1.75488
│       └── tip c = −2
├── 1/3-bulb  1→3                      centre ≈ −0.12256 + 0.74486i (Triple Spiral Valley)
│   └── (1/3-limb) principal Misiurewicz ≈ −0.1011 + 0.9563i, c = i, Kokopelli 1→3→4
├── 2/3-bulb  1→3                      complex conjugate of the 1/3-bulb
├── 1/4-bulb  1→4                      centre ≈ 0.28227 + 0.53006i (Quad Spiral Valley)
└── golden-mean Siegel parameter on the boundary ≈ −0.39054 − 0.58679i
```

## 2. Names for kinds of structure

These name classes, not instances; they have no exact key of their own.

| Id | Names | Status | Definition (field sense) | Source |
| --- | --- | --- | --- | --- |
| <a id="hyperbolic-component"></a>`hyperbolic-component` | hyperbolic component; mu-atom, atom | field | connected component of the parameters with an attracting cycle; its period is constant on it | Douady–Hubbard; Munafo |
| <a id="satellite-component"></a>`satellite-component` | satellite component; bulb | field | component whose root is on the boundary of a component of lower period (a `p/q`-bifurcation) | Milnor 2000 |
| <a id="primitive-component"></a>`primitive-component` | primitive component; cardioid | field | component whose root is not on another component; it is the root of a baby Mandelbrot set and has a cusp | Milnor 2000 |
| <a id="root"></a>`root` | root, root parameter, parabolic parameter | field | the parameter on a component's boundary where the multiplier is `1`; two parameter rays land there (one for the main cardioid) | Douady–Hubbard; Milnor 2000 |
| <a id="cusp"></a>`cusp` | cusp | field | the root of a primitive component | Milnor 2000 |
| <a id="center"></a>`center` | center, centre, nucleus, superattracting parameter | field | the parameter where the critical point is periodic; a root of the Gleason polynomial `f_c^n(0)` | Douady–Hubbard; Munafo |
| <a id="limb"></a>`limb` | limb, `p/q`-limb | field | the part of `M` attached at the `p/q` root of a component, including that satellite | Douady–Hubbard; Milnor 2000 |
| <a id="wake"></a>`wake` | wake, `p/q`-wake | field | the open parameter region between the two root rays of a component; the limb is `M` inside it | Milnor 2000; Schleicher 2004 |
| <a id="parameter-ray"></a>`parameter-ray` | parameter ray, external ray | field | a field line of the Riemann map of the complement of `M`; rational rays land (theorem tag) | Douady–Hubbard |
| <a id="equipotential"></a>`equipotential` | equipotential, level curve of the Green function, escape-time band | field | a level set of the Green function; escape-time bands are the regions between them | Douady–Hubbard 1982; Peitgen–Richter |
| <a id="misiurewicz-parameter"></a>`misiurewicz-parameter` | Misiurewicz parameter, Misiurewicz point | eponym | the critical orbit is strictly preperiodic; rays of angles with even denominator land there | Misiurewicz 1981; Douady–Hubbard |
| <a id="branch-point"></a>`branch-point` | branch point, junction | field | a parameter at which `M` minus it has at least three components; in the combinatorial model these are Misiurewicz parameters | Douady–Hubbard; Schleicher 2004 |
| <a id="filament"></a>`filament` | filament, antenna, hair, spoke | folk | a thin arc-like part of `M` between branch points and tips; "spokes" are those issuing from a principal Misiurewicz parameter | Peitgen–Richter; Munafo |
| <a id="main-antenna"></a>`main-antenna` | main antenna, spike, needle | folk | the part of the real slice of `M` from the Feigenbaum point to the tip `c = −2` | Munafo; Peitgen–Richter |
| <a id="baby-mandelbrot-set"></a>`baby-mandelbrot-set` | baby Mandelbrot set, small copy, minibrot, midget, island, Mandelbrot island | field | the image of `M` under a Douady–Hubbard tuning map, rooted at a primitive component (satellite copies also exist). Islands look disconnected in pictures; `M` is connected | Douady–Hubbard 1985; Munafo |
| <a id="julia-island"></a>`julia-island` | Julia island, embedded Julia set | folk | near a Misiurewicz parameter `M` looks like the Julia set there (Tan Lei's asymptotic similarity); decorations of that shape around a baby copy | Tan Lei 1990; Munafo |
| <a id="valley"></a>`valley` | valley | folk | the region of `M` near a cusp or root, between two touching components; see §6 | Peitgen–Richter; Munafo |
| <a id="feigenbaum-point"></a>`feigenbaum-point` | Feigenbaum point, Myrberg–Feigenbaum point, Feigenbaum parameter | eponym | the accumulation of the period-doubling cascade, `≈ −1.4011552`; the landing parameter of the limit of the cascade's angles (the Thue–Morse angle); infinitely renormalizable | Myrberg; Feigenbaum 1978 |

## 3. Hyperbolic components with names

| Id | Names | Status | Period | Root angles | Internal address | Root `c` | Centre | Source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| <a id="main-cardioid"></a>`main-cardioid` | main cardioid, period-1 component | field | 1 | `0` | 1 | `1/4` | `c = 0` | Douady–Hubbard |
| <a id="bulb-1/2"></a>`bulb-1/2` | period-2 bulb, 1/2-bulb | field | 2 | `1/3, 2/3` | 1→2 | `−3/4` | `c = −1` | Douady–Hubbard; `R2.1/2a` |
| <a id="bulb-1/3"></a>`bulb-1/3` | 1/3-bulb, rabbit bulb | field | 3 | `1/7, 2/7` | 1→3 | irrational | root of `c³+2c²+c+1`, upper half-plane | Douady–Hubbard |
| <a id="bulb-2/3"></a>`bulb-2/3` | 2/3-bulb, co-rabbit bulb | field | 3 | `5/7, 6/7` | 1→3 | irrational | root of `c³+2c²+c+1`, lower half-plane | Douady–Hubbard |
| <a id="bulb-1/4"></a>`bulb-1/4` | 1/4-bulb | field | 4 | `1/15, 2/15` | 1→4 | irrational | root of `c⁶+3c⁵+3c⁴+3c³+2c²+1` | Douady–Hubbard |
| <a id="bulb-1/2.1/2"></a>`bulb-1/2.1/2` | period-4 bulb of the period-2 bulb, 1/2-bulb of the 1/2-bulb | field | 4 | `2/5, 3/5` | 1→2→4 | `−5/4` | real root of `c⁶+3c⁵+3c⁴+3c³+2c²+1` in `(−1.3108, −1.3106]` | Douady–Hubbard; `R2.1/2.1/2a` |
| <a id="airplane-component"></a>`airplane-component` | period-3 window, airplane component, largest real island | field | 3 | `3/7, 4/7` | 1→2→3 | `−7/4` | real root of `c³+2c²+c+1` in `(−1.7549, −1.7548]` | Myrberg; Douady–Hubbard |
| <a id="kokopelli-component"></a>`kokopelli-component` | Kokopelli component | folk | 4 | `1/5, 4/15` | 1→3→4 | irrational | root of `c⁶+3c⁵+3c⁴+3c³+2c²+1` | name attribution unverified |

The airplane component is primitive: its root `−7/4` is a cusp, and the
baby Mandelbrot set it roots is the one the folk name "largest real island"
refers to (`baby-mandelbrot-set`).

## 4. The period-doubling cascade

<a id="feigenbaum-cascade"></a>`feigenbaum-cascade` — period-doubling
cascade, Feigenbaum cascade (eponym; Myrberg, Feigenbaum). The components of
periods `2, 4, 8, 16, …` on the real axis, each the `1/2`-satellite of the
previous. Their root angles are the iterated Douady tuning of `(1/3, 2/3)` by
itself:

| Period | Root angles | Root `c` |
| --- | --- | --- |
| 2 | `1/3, 2/3` | `−3/4` |
| 4 | `2/5, 3/5` | `−5/4` |
| 8 | `7/17, 10/17` | irrational |
| 16 | `106/257, 151/257` | irrational |

The limit of these angles is the Thue–Morse angle, and it lands at the
`feigenbaum-point`.

## 5. Misiurewicz parameters with names

| Id | Names | Status | Angles | Angle type `(ℓ, k)` | `c` | Critical-orbit type | Falls into | Limb | Source |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| <a id="tip"></a>`tip` | tip, antenna tip, `c = −2` | field | `1/2` | (1, 1) | `−2` | (1, 1) | `{0}` (β fixed point) | 1/2 | Douady–Hubbard |
| <a id="c-i"></a>`c-i` | `c = i` | field | `1/6` | (1, 2) | `i` | (1, 2) | `{1/3, 2/3}` | 1/3 | Douady–Hubbard; Carleson–Gamelin |
| <a id="c-minus-i"></a>`c-minus-i` | `c = −i` | field | `5/6` | (1, 2) | `−i` | (1, 2) | `{1/3, 2/3}` | 2/3 | Douady–Hubbard |
| <a id="principal-misiurewicz-1/3"></a>`principal-misiurewicz-1/3` | principal Misiurewicz point of the 1/3-limb, `M_{3,1}` | field | `9/56, 11/56, 15/56` | (3, 3) | `≈ −0.1011 + 0.9563i` | (3, 1) | `{1/7, 2/7, 4/7}` (α fixed point) | 1/3 | Douady–Hubbard; Schleicher 2004 |

The angle type and the critical-orbit type differ at the principal
Misiurewicz parameter: three rays of period 3 land at the α fixed point, which
has period 1. The angle type describes rays, not orbit values.

## 6. Folk regions: the valleys

A valley is not a set with boundary; it is a name for where one looks. The
exact key is the family of limbs that fills it: limbs whose rotation numbers
tend to a target along the Farey parents, with root angles moving strictly
monotonically toward the target root (checked to six Farey steps).

| Id | Names | Between | Limbs accumulating | Munafo | Source |
| --- | --- | --- | --- | --- | --- |
| <a id="elephant-valley"></a>`elephant-valley` | Elephant Valley | `main-cardioid` at its cusp `c = 1/4` | main-cardioid limbs `1/(n+1) → 0` | `R2.C(0)` | Peitgen–Richter; Munafo |
| <a id="seahorse-valley"></a>`seahorse-valley` | Seahorse Valley | `main-cardioid` and `bulb-1/2` at `c = −3/4`, main-cardioid side | main-cardioid limbs `n/(2n+1) → 1/2 ← (n+1)/(2n+1)` | `R2.C(1/2)` | Peitgen–Richter (Scientific American 1985); Munafo |
| <a id="double-spiral-valley"></a>`double-spiral-valley` | Double Spiral Valley | the same seam, 1/2-bulb side | 1/2-bulb limbs `1/(n+1) → 0` | `R2.1/2a` side of `R2.C(1/2)` | Munafo |
| <a id="triple-spiral-valley"></a>`triple-spiral-valley` | Triple Spiral Valley | `main-cardioid` and `bulb-1/3` (mirror: `bulb-2/3`) | main-cardioid limbs → `1/3` | `R2.C(1/3)` | Munafo 1997 |
| <a id="quad-spiral-valley"></a>`quad-spiral-valley` | Quad Spiral Valley | `main-cardioid` and `bulb-1/4` (mirror: 3/4-bulb) | main-cardioid limbs → `1/4` | `R2.C(1/4)` | Munafo 1997 |
| <a id="scepter-valley"></a>`scepter-valley` | Scepter Valley, Seahorse Valley West | `bulb-1/2` and `bulb-1/2.1/2` at `c = −5/4` | 1/2-bulb limbs → `1/2` | `R2.1/2.C(1/2)` | Munafo |

Two valleys are tuning images of others, checked as `tuning_of`: Scepter
Valley is Seahorse Valley tuned by the 1/2-bulb's rays `(1/3, 2/3)`, and
Double Spiral Valley is Elephant Valley tuned the same way. The image is
combinatorial: tuning by a satellite component sends the cusp of the main
cardioid to a root that is not a cusp, so the limb sequences correspond while
the pictures differ.

Each valley's limb sequence is printed exactly by `pixi run
structure-streams` and studied in `docs/structure-streams.md`.

The motifs that give valleys their names — seahorses, peacock eyes,
elephants, spirals — are features of pictures at particular zooms. They have
no exact key and are not entries.

## 7. Julia sets named after their parameter

Several famous names belong to Julia sets `K_c`, and are carried over to the
parameter or component.

| Id | Names | Status | Parameter | Source |
| --- | --- | --- | --- | --- |
| <a id="cauliflower"></a>`cauliflower` | cauliflower | folk | root of `main-cardioid`, `c = 1/4` | Douady 1994; Milnor 2006 |
| <a id="basilica"></a>`basilica` | basilica | folk | centre of `bulb-1/2`, `c = −1` | Douady–Hubbard; Grigorchuk–Żuk 2002 |
| <a id="san-marco"></a>`san-marco` | San Marco fractal, San Marco dragon | folk | root of `bulb-1/2`, `c = −3/4` | Mandelbrot 1982 |
| <a id="douady-rabbit"></a>`douady-rabbit` | Douady rabbit, rabbit | eponym | centre of `bulb-1/3` | Douady–Hubbard |
| <a id="co-rabbit"></a>`co-rabbit` | co-rabbit, anti-rabbit | folk | centre of `bulb-2/3` | Douady–Hubbard; Bartholdi–Nekrashevych 2006 |
| <a id="airplane"></a>`airplane` | airplane | folk | centre of `airplane-component` | Douady–Hubbard |
| <a id="kokopelli"></a>`kokopelli` | Kokopelli | folk | centre of `kokopelli-component` | name attribution unverified |
| <a id="dendrite"></a>`dendrite` | dendrite | field | `c-i`; the word is also the class name for every Misiurewicz Julia set | Douady–Hubbard; Carleson–Gamelin |
| <a id="chebyshev-segment"></a>`chebyshev-segment` | segment Julia set, Chebyshev Julia set | eponym | `tip`: `K_{−2} = [−2, 2]`, `f_{−2}` conjugate to the Chebyshev polynomial `T_2` | Carleson–Gamelin |
| <a id="siegel-disk"></a>`siegel-disk` | golden-mean Siegel disk | eponym | `golden-mean-siegel` | Siegel 1942; Petersen 1996 |

<a id="golden-mean-siegel"></a>`golden-mean-siegel` — golden-mean Siegel
parameter (eponym). The main-cardioid boundary parameter of internal angle
`(√5 − 1)/2`, a classical referent with no finite key of its own. Its finite
shadow is the chain of limbs it is the limit of, with rotation numbers the
continued-fraction convergents `1/1, 1/2, 2/3, 3/5, 5/8, 8/13, …`, each
consecutive pair Farey neighbours (checked). `pixi run structure-streams`
prints these limbs exactly up to `q = 34`.

The co-rabbit is the complex conjugate of the rabbit (`conjugate_of`), as the
2/3-bulb is of the 1/3-bulb and `c = −i` of `c = i`.

## 8. What a name does not carry

- **A name is not a location.** Every angle pair here is exact, but "the
  parameter rays at `1/7` and `2/7` land at the root of the `1/3`-bulb" is the
  imported landing theorem, not a computation. The decimals are orientation
  only; the isolating intervals are the exact localizations.
- **One polynomial, several names.** `c³ + 2c² + c + 1` has three roots: the
  rabbit, co-rabbit and airplane centres. The polynomial does not pick one;
  the angles do, and the interval does on the real axis.
- **Folk regions have no boundary.** A valley names a neighbourhood of a
  cusp or root. The accumulation check certifies the ordering of the limbs
  there, not an extent.
- **Julia-set names are about the dynamical plane.** "Rabbit" names `K_c`
  for one `c`; "rabbit bulb" is borrowed.
- **Attribution is best effort.** Where the origin of a folk name could not be
  confirmed, the source says so rather than guessing.

Where the estate's code and data hold an atlas datum, from kernel smoke
cases to certificate files in sibling repositories, is recorded and checked
in `docs/structure-crosswalk.md`.

## 9. Adding a name

Add an entry to `schemas/structure_names.toml` with a `source`, add its row and
anchor here, and run:

```bash
python3 reference/python/atlas/structure_names_reference.py
python -m pytest tests/test_structure_names_atlas.py
```

The test fails if a name appears twice, if an id is in the table but not
anchored here (or anchored here but not in the table), or if any exact field
disagrees with its recomputation.
