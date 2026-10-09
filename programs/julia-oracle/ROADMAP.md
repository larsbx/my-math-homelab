# Python-to-Julia oracle migration

Status: implementation roadmap. Julia remains non-authoritative throughout.

## Invariants

1. Mojo remains the executable acceptance boundary where it is authoritative today.
2. Domain repositories own question identifiers, canonical vectors, fixtures, and promotion decisions.
3. Julia emits only `agrees`, `disagrees`, `inconclusive`, or `oracle_error`.
4. A disagreement fails the differential gate and creates an investigation obligation.
5. Mathematical proof, certificate acceptance, effect authorization, and persisted operational state remain outside this repository.
6. Every migration runs Python and Julia in parallel before Python retirement.
7. Retirement requires a domain-owned review demonstrating equal or stronger corpus coverage and an independently structured Julia implementation.

## Waves

| Wave | Source | Julia target | Completion gate |
|---|---|---|---|
| 1 | `finite-math-kernels/tools/property_oracle.py` | `ExactArithmeticOracle` | 300 Z and 200 Q transcript rows agree byte-for-byte; negative transcript rejected |
| 2 | duplicated exact-arithmetic oracles in NLAP-JT and finite-mandelbrot-research | consume Wave 1 | domain vector ownership and pinned lab revision |
| 3 | `finite-math-kernels/tools/madic_oracle.py` | exact lattice/coset oracle | adversarial overflow and singular-matrix vectors preserved |
| 4 | PSC census oracles | substitution/census modules | all 4,554 PIP corpus summaries and counter-calibrations match |
| 5 | finite-julia-set reference layer | orbit, interval, kneading, Markov modules | transcript equivalence plus independent-algorithm review |
| 6 | remaining mathematical Python oracles | registry-selected modules | domain-by-domain retirement review |

## Wave 1 implementation

The first implementation uses Julia `BigInt` and `Rational{BigInt}`, independently regenerates the xorshift64* corpus, and compares only canonical byte tokens and boolean codes. It does not parse Mojo values back into numbers.

The domain repository must invoke the Julia CLI against the same saved Mojo transcript used by the Python oracle. During parallel validation both commands are required. Python may be retired only by a later, explicit domain PR.

## Non-target Python

Python remains allowed for repository orchestration, documentation generation, lexical policy checks, and a deliberately independent third conformance path. Such files are not mathematical-oracle migration debt unless the registry classifies them as an oracle.
