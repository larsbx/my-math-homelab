# Structure crosswalk: where the estate's code meets the atlas

**Scope.** A map, not a theorem. The names atlas
(`docs/mandelbrot-structure-names-atlas.md`) keys each named structure of the
Mandelbrot set to exact data. This crosswalk records where code and committed
data in this repository and its siblings hold that data: a root angle pair in
a kernel smoke case, a centre in a certificate file, a catalogue that contains
a Misiurewicz angle, a corpus row at a named Julia parameter. No verdict moves.

| Layer | File |
| --- | --- |
| the table, one `[[occurrence]]` per place | `schemas/structure_crosswalk.toml` |
| the checks | `reference/python/atlas/structure_crosswalk_reference.py` |
| the generated surface for consumers | `docs/structure_crosswalk.json` (`pixi run crosswalk`) |
| the tests | `tests/test_structure_crosswalk.py` |

## 1. What an occurrence says

An occurrence names a repository, a file, a literal `anchor` in it (or, for
committed JSON, a `json_row` locator: an array of the top-level object and the
fields its row must match), the atlas ids it meets, a `relation`, and the
`datum` it shares, written in the atlas's own fields.

| Relation | Meaning | Datum |
| --- | --- | --- |
| `same-datum` | holds the atlas datum as a fixture or constant | required |
| `computes` | computes the atlas datum from other data | required |
| `contains` | a set, catalogue or emitted section with the datum among its members | required |
| `certifies` | issues a finite certificate (box, interval) for the structure | optional |
| `attaches` | carries an invariant the atlas does not (an index, a kneading word) | optional |
| `names` | names the structure without its datum | none |

A named Julia set answers for its parameter: the corpus row `basilica` is
checked against the centre of `bulb-1/2`.

## 2. What is checked

- **Datum against atlas.** Every datum field is an atlas field, compared
  exactly: rationals as `Fraction` (so `6/15` is `2/5`), angle lists as subsets
  of the atlas list, cascade levels level by level, a Gaussian parameter
  componentwise. A `center` is checked as a root of the entry's centre
  polynomial inside its isolating interval.
- **Anchor against file.** The anchor occurs verbatim, or the JSON row
  exists. For this repository always; for a sibling repository when its
  checkout sits beside this one, or under `$CROSSWALK_SOURCES`. Without a
  checkout those tests skip and `structure_crosswalk_reference.py` lists what
  it could not check.
- **Vocabulary.** Relations, planes and exactness classes are the declared
  ones; ids are unique and never collide with atlas ids.
- **Surface.** `docs/structure_crosswalk.json` is regenerated and compared in
  CI, and carries no float.

All 89 occurrences pass against the `main` branch of every repository named.

## 3. The surface for vizops

`docs/structure_crosswalk.json` has format `structure crosswalk 1`. It
declares its own vocabulary, as `larsbx/math-vizops` requires of anything it
draws:

- `classes`: one per atlas kind (`atlas/hyperbolic-component`, …) and one per
  plane (`kernel`, `reference`, `oracle`, `data`, `test`, `doc`, `view`, …);
- `relations`: the six occurrence relations above and eight atlas relations
  read off the atlas's own fields (`satellite-of`, `generated-by`,
  `julia-set-of`, `region-at`, `in-limb-of`, `boundary-of`, `conjugate-of`,
  `tuning-image-of`);
- `nodes`: every atlas entry with its exact `key`, and every occurrence with
  its repository, path, locator, exactness and, for the emitter, the
  `atlas-dataset` section it `emits`;
- `edges`: occurrence → atlas id, and atlas → atlas.

A consumer draws this graph, or uses it to label what it already draws,
without deriving anything: the atlas edges are generated here, and every
identification is one this repository checks.

## 4. Coverage

Every one of the 30 named structures that is not a class name meets the code;
`tests/test_structure_crosswalk.py` requires it.

| Atlas id | Where |
| --- | --- |
| `tip` | catalogue (1,1), Krawczyk and exclusion boxes, `R_{2,1}`, incidence package, kernels' orbit test, bulbs' certify test, vizops view |
| `bulb-1/2`, `bulb-1/3`, `bulb-1/4`, `bulb-2/3` | emitter tunings and kneading, reference components, prefix-graph controls, `limb_streams`, bulbs centre boxes and wakes, cyclotomic and parabolic-index vectors, the Julia corpus |
| `bulb-1/2.1/2`, `airplane-component`, `kokopelli-component` | emitter, reference, kernels' tuning patterns, the bulbs antipode box at `c = −5/4`, Julia kneading at `−7/4` |
| `principal-misiurewicz-1/3` | `M_{4,1}` throughout: Theta, separator, orbits, exclusion boxes, catalogue (3,3) |
| `main-cardioid`, `c-i`, `c-minus-i`, `feigenbaum-cascade` | catalogues, corpus rows, index fixtures, tuning cascades |
| the ten Julia-set names | corpus rows, carrier addresses, density levels, certificate rows of their parameters |
| the six valleys, `golden-mean-siegel` | `pixi run structure-streams` (`docs/structure-streams.md`), and the bulbs certificates of the convergent limbs |

## 5. What the survey found that is not yet mapped

- **A vizops naming defect.** The atlas page's `NAMED_ROOT_RAY` keys
  `(2, 5)` and `(3, 5)` never match the emitter's unreduced `(6, 15)` and
  `(9, 15)`, so `bulb-1/2.1/2` is drawn unnamed (occurrence
  `vizops-named-root-rays`). This surface carries the names; the page can read
  them instead of its own table.
- **A convention difference.** This repository counts a critical-orbit type
  from `Q_0 = 0`, so its `(ell, k)` has `ell` one more than the atlas's
  `critical_orbit_type` preperiod (`c = −2` is `(2, 1)` here, `[1, 1]` in the
  atlas). The crosswalk compares atlas fields only.
- **Atlas candidates pinned elsewhere.**
  - The root of `bulb-1/4` is `c = 1/4 + i/2` exactly (Julia corpus
    `parabolic_i`, jet order 5). The atlas's parabolic check is over `Q` only.
  - The 3/4-bulb (root `1/4 − i/2`) and the primitive period-4 component
    (`7/15, 8/15`, centre near `−1.9408`) are named in the emitter and in vizops.
  - The type-(2,1) angles `1/4, 3/4` and their cubic `C³ + 2C² + 2C + 2`.
  - `critical_orbit_type = [3, 1]` for `principal-misiurewicz-1/3`.
- **The rest of the ten.** The valleys and the golden-mean parameter became
  finite objects as limb sequences, and the co-rabbit a conjugate; see
  `docs/structure-streams.md`.

## 6. Adding an occurrence

Add an `[[occurrence]]` to `schemas/structure_crosswalk.toml`, then:

```bash
CROSSWALK_SOURCES=<dir with sibling checkouts> python3 reference/python/atlas/structure_crosswalk_reference.py
python3 tools/make_structure_crosswalk.py
python -m pytest tests/test_structure_crosswalk.py
```
