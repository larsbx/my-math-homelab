# Literature Notes

This file tracks theorem boundaries for the finite-regime Mandelbrot research program.

## Schleicher — rational parameter rays

Use for the theorem tag:

```text
RationalRayLanding
```

Role in this project:

- rational parameter rays land;
- ray combinatorics relate to critical-orbit dynamics;
- ray period and orbit/kneading period must be distinguished.

Design consequence:

The finite verifier checks rational-angle combinatorics and exact Misiurewicz type. The theorem tag discharges the analytic conclusion that the corresponding rays land at the isolated parameter.

## Schleicher — fibers and local connectivity

Use for the theorem tag:

```text
MisiurewiczFiberTriviality
```

Role in this project:

- fibers are defined by separation using rational rays / separation lines;
- Misiurewicz fibers are trivial;
- hyperbolic-component boundary fibers are trivial;
- local connectivity of the Mandelbrot set is equivalent to triviality of all fibers in Schleicher's framework.

Design consequence:

Separation-completeness is not an extra premise. It is built into the fiber definition. The open frontier is singleton stabilization/triviality of fibers at generic boundary points.

## Douady-Hubbard tradition

Use as classical background for:

- parameter rays;
- landing of rational rays;
- orbit portraits;
- Misiurewicz and parabolic boundary structure;
- Mandelbrot local connectivity formulation.

## Tuning and kneading sequences

Use as classical background for the residual directive carrier
(`docs/C1_residual_directive_carrier.md`):

- Douady and Hubbard, *Étude dynamique des polynômes complexes*: tuning and polynomial-like renormalization;
- Bruin and Schleicher, symbolic dynamics of quadratic polynomials: 0/1 kneading sequences of angles, the `rho` function, internal addresses, and the periodic continuations `A(nu)`;
- Derrida, Gervois, and Pomeau: the star product of real unimodal kneading sequences (the parity twist, real case only);
- Milnor, *Periodic orbits, external rays and the Mandelbrot set*: orbit portraits and root angles.

Role in this project: sources for the scaffolded theorem tag `TuningKneadingSubstitution` behind the residual directive carrier, a project term registered in `docs/terminology-registry.md`. None of them is a statement about parameter-plane shrinking or fibre triviality.

## Harmonic measure on the boundary of `M`

Use as classical background for the theorem tag
`HarmonicMeasureAlmostEveryFibreTrivial` and for the finite density of
`docs/C1_separated_pair_density.md`:

- Graczyk and Świątek, *Harmonic measure and expansion on the boundary of the Mandelbrot set*;
- Smirnov, *Symbolic dynamics and Collet-Eckmann conditions*.

Role in this project: they are reported to give triviality of the fibre for
harmonic-measure-almost every boundary parameter. That is a measure-theoretic
statement with a null exceptional set, and the residual class of
`docs/C1_residual_directive_carrier.md` lies inside that exceptional set. The
statements must be pinned exactly before any final import; nothing here decides
a named pair.

## Interval / Krawczyk methods

Use for finite localization witnesses.

Role in this project:

- certify existence and uniqueness of a root in a dyadic complex box;
- provide finite rational proof objects;
- avoid floating-point trust.

Design consequence:

Krawczyk localizes the algebraic parameter only. It does not prove ray landing or fiber triviality.

## Fixed-point and integer rendering tradition

Historical relevance:

- early fractal renderers used integer/fixed-point arithmetic;
- these show that Mandelbrot-like images can be generated without floating-point arithmetic.

Design difference:

This project is not just integer rendering. It is proof-carrying finite certification.

## Finite-field arithmetic dynamics

Relevant but secondary.

Every affine finite-field orbit is eventually periodic and, for a polynomial
morphism, never lands on the infinity divisor. Projective infinity nevertheless
has exact algebraic dynamics: for `z |-> z^2 + c` it is fixed and totally
ramified, with pullback multiplicity `2^n` after `n` iterates. Intersection
multiplicity at infinity and valuative pole-order growth are also algebraic
notions, but they are distinct from classical analytic escape of an affine
complex orbit. Finite-field Mandelbrot analogues therefore remain arithmetic
shadows, not replacements for the classical escape-defined set. See
`docs/projective-multiset.md`.

Possible use:

- study reductions of critical-orbit polynomials;
- analyze orbit statistics;
- use modular checks for exploratory algebra.
