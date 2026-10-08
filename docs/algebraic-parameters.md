# Algebraic parameters: Julia sets at irrational centres

Status: implemented and checked; changes no verdict of the Gaussian-rational
corpus.

## Why

The parameter corpus holds Gaussian-rational `c` only. Every hyperbolic centre
of period at least three is irrational: the rabbit, co-rabbit and airplane
centres are the three roots of `c^3 + 2c^2 + c + 1`, and Kokopelli's is a root
of the degree-6 period-4 Gleason factor `c^6 + 3c^5 + 3c^4 + 3c^3 + 2c^2 + 1`.
Their Julia sets are among the best-known in the field, and until now none of
them could be a corpus row.

## What a row is

`reference/algebraic_corpus.py` names each parameter by a **root handle**:
an integer polynomial `P` and a rational box `B`, here of half-width `2^-40`
on the dyadic grid `2^-41`. The box was found offline by exact dyadic Newton
steps and is declared, like every witness in the corpus.

| Check | How | Import |
| --- | --- | --- |
| every root of `P` is the centre of a component of exact period `n` | `P` divides `f_c^n(0)` and is coprime to `f_c^d(0)` for proper `d ∣ n`: integer algebra in the reference; in the kernel, exact monic division and one Bezout certificate `A P + B f_c^d(0) = N ≠ 0` per divisor, checked by multiplication | none |
| `B` holds exactly one root of `P` | the Krawczyk image of `B` lies strictly inside `B` (`vendor/python/root_isolation_py`, `vendor/mojo/root_isolation`) | `KrawczykMooreUniqueness` |
| distinct rows name distinct roots | boxes on one polynomial are strictly separated | none |
| declared conjugates are conjugate | same `P`, box equal to the conjugate box, angles negated | none |
| the classifier may count `IN` | the declared box is a trap of period `n` for every parameter in `B` | none |
| the box is the component at the listed angles | not computed | `ParameterRayLandingCorrespondence`, **not gated** |

All three roots of the cubic are rows, so its factor is fully accounted for.
The two non-real Kokopelli rows are two of the six roots of the period-4
factor. The others are the 1/4-, 3/4- and 1/2-satellite-of-1/2 centres and
the real primitive centre; they are not rows yet.

## The identification is not gated

The keys `rabbit`, `airplane`, `kokopelli` say which component each root
centres. That is the Douady-Hubbard correspondence between parameter rays and
component roots, and no literature gate of this repository has judged it.
`RationalRayLanding` (`docs/literature-gate-2026-09-20-landing.md`) is about
dynamical rays of one polynomial, and its findings 3 and 4 refuse
angle-to-root correspondence. The rows therefore name the import
`ParameterRayLandingCorrespondence` with status `NOT_GATED`, and the keys are
labels. Nothing verified depends on them: every root of an exact-period
Gleason factor is superattracting, so hyperbolic, whichever component it
centres. A literature gate for parameter rays is what would turn the labels
into identifications.

## What it opens

Because `reference/box_classifier.py` takes the parameter as a box, every
dynamical-plane certificate of the corpus applies over `B` unchanged, and a
verdict that holds for every `c` in `B` holds at the irrational centre. The
census (`docs/classifier-census.md`) now counts these Julia sets:

| key | OUT | IN | UNKNOWN |
| --- | --- | --- | --- |
| rabbit | 154 | 0 | 102 |
| co-rabbit | 154 | 0 | 102 |
| airplane | 172 | 0 | 84 |
| Kokopelli, and its conjugate | 160 | 0 | 96 |

At the census resolution no box is yet decided `IN`. The trap is verified, but
no grid box reaches it within eight iterations. Raising the horizon, or seeding
boxes along the superattracting cycle, is the obvious next measurement.

## What it does not establish

- **A box is not a point.** Every certificate holds for the whole box; none
  names the centre exactly, and the identification with a component is
  imported.
- **Local connectivity is imported.** It holds for these hyperbolic
  parameters through `DouadyHubbardHyperbolicLocallyConnected`, as for the
  rational centre rows; nothing here proves it.
- **The kernel decides every verified column.** Exact period (division and
  Bezout certificates), isolation, disjointness and traps are all checked by
  `kernel/algebraic_parameter.mojo`; the reference decides them again
  independently.
