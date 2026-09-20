# Literature gate — the local-connectivity tags of the regime ledger

## Proposed step

`docs/J1_regime_ledger.md` carries one theorem tag per non-open row, and
`docs/J1_proof_definition.md` carries the bridge tag that connects fiber
triviality to local connectivity. Until now every one of them was declared and
none was checked, and the ledger said so.

This gate asks, for each tag: does a located source state what the repository
uses it for, on the hypotheses the row actually satisfies, and is the
attribution right?

## Decision

**Three row tags are accepted with qualifications, the bridge tag is accepted
in the direction the repository needs and split into two obligations, and one
statement in the prose is wrong and is corrected here.**

The correction is the reason this gate was worth running. The design analysis
and the README said local connectivity fails for "Cremer; non-Brjuno Siegel".
In the quadratic family **there is no such thing as a non-Brjuno Siegel
parameter**: by Brjuno-Yoccoz, an irrationally indifferent quadratic fixed
point is linearizable exactly when its rotation number is Brjuno, so a
non-Brjuno rotation number gives a Cremer point, not a Siegel disk. The second
failing class is a different one: a Siegel disk whose boundary contains no
critical point. Finding 5.

Nothing in the executable layer changes. Every verified column of the ledger
was computed by exact arithmetic and none of it rested on a tag.

## Findings

### 1. The bridge tag is two obligations, not one

`docs/J1_proof_definition.md` stated

```text
all fibers of K_c trivial  <=>  J_c locally connected     [theorem tag]
```

Schleicher's Proposition 2.9 gives one direction for any compact connected
full `K` in `C`: a point with a trivial fiber is a point at which `K` is openly
locally connected, and if **all** fibers are trivial then `K` is locally
connected, all external rays land, and the landing points depend continuously
on the angle.[^1] The converse does **not** hold at that generality -- the
paper is explicit that triviality of fibers is locally strictly stronger than
local connectivity, and a locally connected `K` may have non-accessible
points.[^1] [^2] Proposition 2.10 supplies the converse only under conditions
on a dense set of ray angles.

What rescues the biconditional here is that this repository is unicritical:
Proposition 3.6 states that if the filled Julia set of a **unicritical
polynomial** is locally connected then all its fibers are trivial.[^1] So for
`z^2 + c` the equivalence holds, at the level of `K_c`.

That leaves a step the tag was hiding. Schleicher's objects are the filled
Julia set `K_c`; the ledger and the prose speak of `J_c`. The transfer
"`K_c` locally connected iff `J_c` locally connected" for a polynomial with
connected Julia set is standard, but no source was located for it in this
gate. It is therefore split out as its own obligation and recorded as **NOT
GATED**, and `docs/J1_proof_definition.md` now names both.

Tags: `SchleicherFiberTrivialityLocalConnectivity` (ACCEPTED, unicritical
case), `FilledJuliaLocalConnectivityTransfer` (NOT GATED).

### 2. The geometrically finite tag says "periodic component", and the rows satisfy it

Tan Lei and Yin Yongcheng prove that each (eventually) periodic connected
component of the Julia set of a geometrically finite rational map is locally
connected.[^3] Two qualifications follow, and both are discharged by the rows
that use the tag.

- *Component, not set.* The theorem is about periodic components. For the five
  rows carrying this tag the critical orbit is bounded, so `J_c` is connected
  and is its own single component.
- *Geometrically finite must be checked per row.* A rational map is
  geometrically finite when every critical point **in the Julia set** has a
  finite forward orbit. For `dendrite` and `chebyshev` the critical point lies
  in `J_c` with a finite orbit, verified as `PREPERIODIC(l, k)` by the
  executable layer. For the three parabolic rows the critical point lies in the
  parabolic basin, which is a Fatou component, so the condition is vacuous.

Tag: `TanYinGeometricallyFiniteLocallyConnected` (ACCEPTED WITH
QUALIFICATION).

### 3. The hyperbolic tag is a body of classical work, and is not load-bearing here

For hyperbolic parameters local connectivity of the Julia set was settled in
the work of Fatou, Douady and Hubbard, and is reported that way rather than as
one numbered theorem.[^4] No single citable statement was located, so the tag
is accepted as an attribution to that body of work, with its theorem number
unverified.

It also carries less weight than it appears to. Both rows using it, `c0` and
`basilica`, have `PREPERIODIC(l=0, k)` critical orbits: they are
postcritically finite, and so are covered by finding 2 as well. The tag is kept
because it is the natural citation for a hyperbolic parameter, not because the
rows depend on it alone.

Tag: `DouadyHubbardHyperbolicLocallyConnected` (ACCEPTED WITH QUALIFICATION).

### 4. The escaping row's tag is right; its stated reason was not

That a polynomial all of whose critical points escape has a Cantor Julia set,
with the dynamics conjugate to the one-sided shift, is classical.[^5] The
`escaping` row's tag is accepted on that basis, again without a verified
theorem number.

The row's local-connectivity column reads `NOT_APPLICABLE_DISCONNECTED`, and
the reason recorded in the corpus note was loose. The correct reason is not
that a Cantor set fails to be locally connected but that **the fiber theory
this repository imports is stated for compact connected full sets**, and `K_c`
is disconnected here, so the question the other rows answer is not posed at
this parameter.

Tag: `FatouJuliaEscapingCantorSet` (ACCEPTED WITH QUALIFICATION).

### 5. "Non-Brjuno Siegel" does not exist in the quadratic family

Brjuno and Russmann proved that an irrationally indifferent fixed point with a
Brjuno rotation number is linearizable, and Yoccoz proved the condition sharp
for quadratic polynomials: for `lam` on the unit circle and not a root of
unity, the origin is a Siegel point of `lam z + z^2` exactly when `lam`
satisfies the Brjuno condition.[^6] A non-Brjuno rotation number therefore
produces a **Cremer** point, and the class the prose named is empty.

The two classes where local connectivity genuinely fails are:

- a polynomial with a Cremer cycle -- its Julia set is not locally connected,
  by a theorem of Douady and Sullivan;[^7]
- a polynomial with a periodic Siegel disk whose boundary contains **no**
  critical point -- its Julia set is not locally connected, by the same
  Douady-Sullivan criterion, and such quadratics exist: Herman showed the
  critical point lies on the boundary for every Diophantine rotation number,
  but there are Brjuno numbers for which it does not.[^8]

This sharpens the `niven` row rather than changing its status. At
`c = (37 + 16i)/100` the multiplier is `(3 + 4i)/5` and the row is `UNDECIDED`
for two reasons now, not one: whether `arg(lam) / 2pi` is Brjuno is not known,
and *even if it is*, local connectivity would still turn on whether the
critical point lies on the boundary of the resulting Siegel disk.

New tags, recorded for the phase that needs them and not used by any row yet:
`DouadySullivanCremerNotLocallyConnected`, `BrjunoYoccozQuadraticLinearization`
(both ACCEPTED WITH QUALIFICATION, theorem numbers unverified).

## Verdicts

| Tag | Used by | Verdict |
| --- | --- | --- |
| `DouadyHubbardHyperbolicLocallyConnected` | `c0`, `basilica` | ACCEPTED WITH QUALIFICATION (finding 3) |
| `TanYinGeometricallyFiniteLocallyConnected` | `dendrite`, `chebyshev`, `cauliflower`, `parabolic_minus_one`, `parabolic_i` | ACCEPTED WITH QUALIFICATION (finding 2) |
| `FatouJuliaEscapingCantorSet` | `escaping` | ACCEPTED WITH QUALIFICATION (finding 4) |
| `SchleicherFiberTrivialityLocalConnectivity` | `docs/J1_proof_definition.md` | ACCEPTED, unicritical case (finding 1) |
| `FilledJuliaLocalConnectivityTransfer` | `docs/J1_proof_definition.md` | **NOT GATED** (finding 1) |
| `DouadySullivanCremerNotLocallyConnected` | no row yet | ACCEPTED WITH QUALIFICATION (finding 5) |
| `BrjunoYoccozQuadraticLinearization` | no row yet | ACCEPTED WITH QUALIFICATION (finding 5) |

**Amendment, 2026-09-20, second.** `docs/enclosure-width-lemma.md` proves two
completeness theorems for the classifier without importing anything. Its
corollary, that a hyperbolic parameter's trap basin is the whole interior of
`K_c`, does import: the tag is `FatouHyperbolicInteriorIsTheBasin` and this
gate has **not** judged it, so the corollary is conditional and the theorems
are not. The tag joins `FilledJuliaLocalConnectivityTransfer`'s original
position: named, used, ungated.

**Amendment, 2026-09-20, third.** `docs/literature-gate-2026-09-20-basins.md` judges it, and
accepts it for the quadratic family together with a second tag,
`FatouParabolicInteriorIsTheBasin`, that the parabolic trap of
`docs/three-valued-classifier.md` section 5 raised. Both are imports; neither
is proved here.

**Amendment, 2026-09-20.** This gate judged the tags the ledger carries. It did
not judge the escape *criterion* -- the step from "a quadrance passed a bound"
to "the orbit is unbounded" -- because no tag named it and nothing in the
repository derived it. That gap is closed in `docs/escape-criterion.md`, by
derivation rather than by import, so the criterion is not a tag and does not
belong in the table below. Finding 4's tag is about the Cantor structure of
the resulting Julia set, which is a different statement and remains imported.

**Amendment, same day.** `FilledJuliaLocalConnectivityTransfer` was gated
after this table was written; see `docs/literature-gate-2026-09-19-transfer.md`,
which discharges it for `c` with connected `K_c`. The row above records what
*this* gate returned and is left as it stood.

"Accepted with qualification" means: a source was located, it states what the
repository uses the tag for, and the qualification named in the finding is part
of the tag's meaning from here on. It does not mean a theorem number was
checked against a printed page; where that was not done, the finding says so.

## What this gate did not do

It did not verify any theorem number against a printed text, obtain any of the
cited papers in full beyond the sections quoted, or check a proof. It did not
make any row's verified column depend on a tag, and no such dependency exists:
the cycles, multipliers, and critical-orbit verdicts are computed.

[^1]: D. Schleicher, *On Fibers and Local Connectivity of Compact Sets in C*, arXiv:math/9902154. Propositions 2.9, 2.10, 3.6; `K` compact, connected, and full throughout (Definition 2.1). https://arxiv.org/abs/math/9902154
[^2]: D. Schleicher, *On Fibers and Local Connectivity of Mandelbrot and Multibrot Sets*, arXiv:math/9902155. https://arxiv.org/abs/math/9902155
[^3]: Tan Lei and Yin Yongcheng, *Local connectivity of the Julia set for geometrically finite rational maps*, Science in China Series A 39 (1996), no. 1, 39-47.
[^4]: J. H. Hubbard, *Local connectivity of Julia sets and bifurcation loci: three theorems of J.-C. Yoccoz*, in Topological Methods in Modern Mathematics. https://pi.math.cornell.edu/~hubbard/Yoccoz.pdf
[^5]: J. Milnor, *Dynamics in One Complex Variable*, on the Fatou-Julia dichotomy for polynomials: all critical points escaping gives a Cantor Julia set carrying the one-sided shift.
[^6]: On the sharpness of the Brjuno condition in the quadratic family: the origin is a Siegel point of `lam z + z^2` iff `lam` is Brjuno. See the Scholarpedia article on quadratic Siegel disks and the Marmi-Moussa-Yoccoz literature. http://www.scholarpedia.org/article/Siegel_disks/Quadratic_Siegel_disks
[^7]: A. Douady and D. Sullivan: a polynomial with a Cremer cycle has a Julia set that is not locally connected, as cited in the Cremer-polynomial literature. https://arxiv.org/abs/math/9502235
[^8]: On Siegel disks without a critical point on the boundary and the resulting failure of local connectivity, and on Herman's result for Diophantine rotation numbers: *On (non-)local-connectivity of some Julia sets*, arXiv:1203.2741. https://arxiv.org/pdf/1203.2741
