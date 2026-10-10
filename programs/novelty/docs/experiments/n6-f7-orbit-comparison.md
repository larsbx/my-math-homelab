# Exact n=6 orbit comparison over F7

## Claim boundary

This page records an exact finite computation. It is neither a general theorem
nor a novelty claim. Its purpose is to turn the first Witt-stabilized
octonion--Soddy bridge into a reproducible witness that can fail under changed
fields, dimensions, seeds, or conventions.

## Model

- Packing dimension: `n=6`; curvature-vector dimension: `n+2=8`.
- Field: `F_7`.
- Normalized Descartes Gram matrix: `Q=I-(1/6)J=I+J`.
- Octonion norm Gram matrix: `I_8`, using the scalar Cayley--Dickson basis.
- Bridge: `Phi=I+J`, with `Phi^-1=I+3J`.
- Null seed in Descartes coordinates: `(1,2,0,0,0,0,0,0)`.
- State space: projective classes of nonzero null vectors.

Direct multiplication certifies

`Phi^T Q Phi = I_8` and `Phi Phi^-1 = I_8`.

For basis octonions `x,y`, the defect operator is

`D(x,y)=L_x L_y L_(xy)^-1`.

It is transported to Descartes coordinates as

`A(x,y)=Phi D(x,y) Phi^-1`.

The comparison family consists of the eight reduced higher-dimensional
Apollonian reflections

`b_i -> (2/(n-1)) sum_(j != i) b_j - b_i`.

Here `2/(n-1)=2/5=6` in `F_7`.

## Exact results

| Generator/action family | Distinct generators | Projective orbit size |
|---|---:|---:|
| Transported basis defects | 8 | 8 |
| Apollonian reflections | 8 | 168 |
| Combined family | 16 | 2240 |

The breadth-first searches exhaust their orbits; no search cap or random
sampling is used. Every generator is independently checked to satisfy
`A^T Q A=Q`, and the seed is checked to satisfy `v^T Q v=0`.

## Interpretation and next falsifiers

### Relative-framing counterexample

The defect subgroup alone is transported canonically up to orthogonal
conjugacy. Its comparison with a **fixed** Apollonian subgroup is not.
Let `u=(1,1,1,0,0,0,0,0)` in octonion norm coordinates and set
`h=I-2uu^T/(u^T u)`. Here `u^T u=3`, so the reflection is defined over F7.
Both `Phi` and `Phi*h` satisfy the same bridge Gram identity. Keep the
Descartes seed and Apollonian generators fixed and move only the defect
generators by `c=Phi*h*Phi^-1`. Exhaustive orbit computation gives:

| Bridge | Defect seed orbit | Combined seed orbit |
|---|---:|---:|
| `Phi` | 8 | 2240 |
| `Phi*h` | 8 | 137600 |

Thus the joint orbit statistic does not descend to the unframed isometry
class. Simultaneously conjugating **both** subgroups and the seed does
preserve it; changing the defect embedding alone need not.
The surviving construction is a framed pair of subgroups, considered up
to simultaneous conjugacy. A canonical unframed pairing requires an extra
selection rule or a proof that the allowed bridge changes normalize the
Apollonian subgroup. Neither has been supplied.

Reproduce the counterexample with
`from experiments.soddy.n6_f7_orbits import framing_audit; framing_audit()`.
This is an exact finite falsifier of bridge-independent joint orbit sizes,
not a theorem-level promotion or a packing/configuration realization.

The defect action is not orbit-equivalent to the Apollonian action in this
instance: the orbit sizes differ. The combined action is strictly larger than
either orbit on the selected seed. This keeps `NC-SG-01` alive but does not
establish that the enrichment is geometrically meaningful on the full ACC
configuration variety.

The next checks are:

1. repeat at admissible primes such as 13 and 19;
2. enumerate all projective null-cone seed classes rather than one seed;
3. repeat in stabilized dimensions 7 and 8;
4. compute subgroup orders and intersections, not only one orbit;
5. test preservation and stratification of the full ACC configuration data.

Reproduce with:

```console
python experiments/soddy/n6_f7_orbits.py
python -m unittest tests/test_n6_f7_orbits.py -v
```
