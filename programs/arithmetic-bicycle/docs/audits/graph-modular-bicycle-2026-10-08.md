# Graph modular-bicycle proof audit — 2026-10-08

Claim: `ABC-GRAPH-MODULAR-BICYCLE`.

Base: `369e75e8388422ab1a77c9a917d02c3fa6c42b83` (merged bootstrap).
Proof record: `proof/graph-modular-bicycle.md`.
Audit result: the graph claim meets its repository proof and independent
evidence gates. This audit accompanies the contribution; no separate
reviewer signoff is recorded.

## Mathematical obligations

| Obligation | Evidence in the integral proof |
| --- | --- |
| Exact finite critical-group convention | Degree-zero divisors modulo the full Laplacian image; free cokernel part excluded |
| Arbitrary modulus | Connected-path equality of potentials over Z/n, with no field division |
| Integral target | Cycle condition makes Ly divisible by n; its quotient has degree zero |
| Target annihilated by n | n[Ly/n] = [Ly] = 0 |
| Lift and potential independence | Any two gradient representatives differ by a constant plus n times an integral vector |
| Injectivity | Ly/n = Lz implies y-nz is an integral constant potential |
| Surjectivity | n[d] = 0 supplies an integral solution Ly = nd |
| Inverse representative independence | Changing d by Lz changes a solution potential by nz; other solutions differ by constants |
| Both inverse identities | Same potential reused in the two displayed formulas |
| Reduction compatibility | m=kn: Phi_n(reduce b) = k Phi_m(b) |
| Inflation compatibility | Multiply the potential by k: Phi_m(kb) = Phi_n(b) |
| Composition and graph naturality | Explicit divisibility compositions, signed edge permutations, and vertex permutations |

The constant-kernel step is integral and therefore cannot be replaced by
an unqualified assertion about the modular kernel of L. That modular
kernel is usually larger; it is precisely the source of nonzero bicycles.

## Independent executable evidence

The 17 conformance tests pass. They include:

- ten explicit small multigraphs at 53 moduli, including primes, prime
  powers, and mixed composites;
- Smith factors at every root, computed from all-minor gcds by a separate
  Bareiss implementation;
- independently enumerated critical-group classes, with both inverse
  identities checked on every n-torsion class;
- all 44 connected labeled simple graphs through four vertices at
  moduli 2, 3, 4, and 6, totaling 176 additional finite cases;
- representative changes, linearity, root independence, graph
  isomorphisms, and modulus-map composition;
- explicit invalid representative constructions and domain rejection.

The source-pinned receipt replays 53 cases and 70 proper divisibility
pairs. For each case it checks the entire bicycle set, Smith-predicted
order distribution, distinct mapped classes, and the inverse on an
independently enumerated quotient. Its proof/source hashes bind the
evidence to the checked-in contribution.

The oracle does not import the candidate implementation. Its Laplacian
construction, bicycle enumeration, determinant method, and class
coordinates are separate algorithms. The implementations share the
explicit input graph and elementary exact integer arithmetic.

## Negative controls

- C4 modulo 4 has a bicycle represented by the gradient of (0,1,2,3).
  The correct divisor is (-1,0,0,1), of critical-group order 4. Applying B
  to the residue vector (1,1,1,1) gives zero and incorrectly loses this class.
- A cycle without a cut witness and a cut without the cycle condition
  are both rejected.
- The two-edge parallel graph has nonzero bicycles at moduli 2 and 4,
  but reduction from 4 to 2 is zero. Unscaled inclusion is not a bicycle
  map in the other direction.
- The parallel graph and C4 agree in mod-2 bicycle rank but differ in
  mod-4 size and element orders.

These controls exercise integral torsion and representative errors that
prime-field dimension equality would not detect.

## Promotion boundary

Promote only `ABC-GRAPH-MODULAR-BICYCLE` to `proved`, with this audit,
the integral proof, and independent conformance locators. The regular
claim stays `working`. `ABC-MAIN` and `ABC-REALIZATION-INVARIANCE`
stay `open`. Python retains candidate status without acceptance authority.
Finite enumeration is supporting evidence, not the arbitrary-n proof.

## Replay

```sh
python conformance/check_claims.py
python -m unittest discover -s conformance -p 'test_*.py' -v
python conformance/replay_graph_modular_bicycle.py --check
git diff --check
```
