# Tuning substitutions and column coincidence: targeted literature stop/go check

**Status:** stop/go note under the review gate of `AGENTS.md`, dated 2026-09-16. It records the decision on how the three kernels that the finite-math-kernels pin of PR #102 adds to `kernel/substitution_dynamics/` (`tuning.mojo`, `sadic.mojo`, `coincidence.mojo`) may be used in this repository. It proves nothing, promotes no claim, and changes no ledger entry; `OverlapProductivity` and the Pisot substitution conjecture remain open.

## Proposed claim or experiment

The round-two cross-pollination audit (item R1, `docs/cross-pollination-round-two-2026-09-16.md` on the branch that carries it) asked the monorepo for a tuning constructor and a constant-length coincidence test, and named this repository's binding as: constant-length column coincidence as the alphabet-generic special case beside the balanced-pair and overlap coincidence kernels, and Dekking's theorem as an imported theorem where a constant-length specimen is used as a calibration.

The exact executable content of the pinned kernels is finite combinatorics only:

- `tau_{A', eps}(s) = A' . (s xor eps)` on `{0, 1}`, the star product, and the identity `tau_{A * B} = tau_A o tau_B`;
- finite directive prefixes of substitutions over one alphabet and their composite;
- for a constant-length substitution over at most 60 letters, the least `k` such that some column of `sigma^k` is constant, by exhaustive breadth-first search over subsets of the alphabet.

## Prior art and field terminology

1. Dekking, *The spectrum of dynamical systems arising from substitutions of constant length*, Z. Wahrscheinlichkeitstheorie verw. Gebiete 41 (1978). Terminology: constant length `q`, height `h(sigma)`, pure base, coincidence (a column of some power of `sigma` constant across the alphabet). The theorem: a primitive aperiodic substitution of constant length has pure discrete spectrum if and only if its pure base admits a coincidence.
2. Kamae, *A topological invariant of substitution minimal sets*, J. Math. Soc. Japan 24 (1972), and Martin, *Substitution minimal flows*, Amer. J. Math. 93 (1971): the constant-length setting in which coincidence was first isolated.
3. Queffélec, *Substitution Dynamical Systems: Spectral Analysis*, Lecture Notes in Mathematics 1294, chapters on constant-length substitutions and on the Thue–Morse spectrum: the survey form of items 1 and 2 with the continuous spectral component of Thue–Morse.
4. Douady and Hubbard, *Étude dynamique des polynômes complexes* (tuning); Derrida, Gervois, and Pomeau, the star product of unimodal kneading sequences; Milnor, *Periodic orbits, external rays and the Mandelbrot set*. These give the kneading form of tuning that the tuning kernel encodes with the parity (DGP) twist. They are consumer citations of the NLAP-JT program, recorded in its theorem-tag ledger, not of this repository.
5. Barge and Kwapisz, *Geometric theory of unimodular Pisot substitutions*, Amer. J. Math. 128 (2006), and Host's coincidence condition as surveyed by Akiyama, Barge, Berthé, Lee, and Siegel: the non-constant-length coincidence vocabulary this repository already uses (balanced pairs, overlap coincidence, coincidence rank).

## Hypotheses that transfer and hypotheses that do not

Transfer:

- The word "coincidence" is used in the same sense in items 1 and 5: two orbits of letters agree at a common position after inflation. The constant-length column test is the case where inflation preserves positions exactly, so it is the alphabet-generic special case named by the audit, and it is a correct calibration for the vocabulary of `docs/overlap-finiteness-and-coincidence-density-2026-09-13.md`.
- Exhaustiveness: the subset search is complete, so `found == False` is a finite negative fact about every power of `sigma`, not a capped run.

Do not transfer:

- A constant-length-`q` substitution on `n >= 2` letters has incidence matrix with Perron–Frobenius eigenvalue `q`, an integer, so `x - q` divides its characteristic polynomial. No such substitution is an irreducible Pisot substitution. The PIP regime of this repository therefore contains no constant-length specimen, and nothing computed by `coincidence.mojo` bears on `OverlapProductivity`, G1, C3, C4, or the conjecture. The kernel is calibration, never evidence.
- Dekking's theorem needs primitivity, aperiodicity, and the height: when `h(sigma) > 1` the coincidence condition is to be evaluated on the pure base, which the package does not compute (its specification, section 3.3). Until a height kernel exists upstream, a `found` witness is not the hypothesis of Dekking's theorem, and the theorem may not be imported on the strength of it.
- Tuning acts on kneading sequences of real quadratic maps; nothing in this repository is a kneading sequence. The tuning and directive-prefix kernels have no PSC consumer and are pinned only because the package is vendored byte-for-byte.
- The module docstrings cite `docs/tuning-substitutions-spec.md` and `tools/tuning_reference.py`, which are paths of the monorepo, not of this repository. The vendoring protocol forbids editing them here; the specification is read upstream at the pinned commit.

## Known negative controls and counterexamples

- Thue–Morse (`0 -> 01`, `1 -> 10`): no column of any power is constant, and its spectrum has a continuous component (Queffélec, item 3). Pinned by `kernel/tests/test_tuning_kernels.mojo` as `found == False`, depth `-1`.
- Period doubling (`0 -> 11`, `1 -> 10`), the DGP tuning of the period-two centre: coincidence at depth one in column zero; every tuning substitution has this property because both images share their prefix, so a depth-one witness on a tuning substitution carries no information beyond the definition.
- The three-letter substitution `0 -> 01`, `1 -> 20`, `2 -> 21`: least depth two, columns `(0, 1)`, checking that the search does not stop at the first level.
- A non-constant-length substitution (Fibonacci) is rejected by `column_coincidence`; a mixed-alphabet directive prefix is rejected by `compose` and `directive_composite`. Upstream also rejects it in `apply_directive` from the commit after the one pinned here; the pin will follow once that commit is on the monorepo's main branch, and the regression will then add that case.

## Decision

Proceed with a narrowed target.

- The three modules are pinned and compiled by `pixi run test` through `kernel/tests/test_tuning_kernels.mojo`, which exercises the composition identity, DGP closure, the kneading prefix, and least-depth coincidence with the negative controls above.
- Column coincidence may be cited in this repository only as the constant-length calibration of the coincidence vocabulary, outside the PIP regime. It is not a gate input and no ledger entry, status surface, or manuscript may cite it as evidence.
- Dekking's theorem is not imported. Importing it requires the height kernel upstream and a claim-ledger entry of class `imported` with the primitivity, aperiodicity, and height hypotheses checked on the specimen.
- The tuning and directive-prefix kernels stay unbound here; their consumer is NLAP-JT.
