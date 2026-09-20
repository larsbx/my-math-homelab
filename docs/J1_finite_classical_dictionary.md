# J1 finite-to-classical dictionary

Status: proof-focus document. It fixes which finite object stands for which
classical referent, and which side of the boundary each one lives on.

## Dictionary

| Finite-regime object | Classical referent | Internal status |
| --- | --- | --- |
| `GQ` / `ComplexIQ` singleton | a Gaussian-rational parameter or point | rank-2 coordinate record, not an analytic complex number |
| `quadrance` | squared modulus | exact rational scalar; no modulus and no square root exist here |
| `escape_bound_quadrance` | the escape radius `max(2, \|c\|)`, squared | exact rational bound |
| `critical_orbit` verdict `ESCAPES` | the critical orbit tends to infinity | finite certificate: the quadrance grows by a rational ratio `r > 1` at every later step (`docs/escape-criterion.md`), which is derived here, not imported |
| `critical_orbit` verdict `PREPERIODIC` | the parameter is postcritically finite | finite certificate with exact preperiod and period |
| `critical_orbit` verdict `CAPPED` | nothing | exhausted budget; not a classification |
| cycle witness | a periodic orbit of `f_c` | finite data, checked by exact identity |
| `multiplier` | `(f_c^k)'` along the cycle | exact Gaussian rational |
| `MULT_PARABOLIC` | rationally indifferent cycle | decided by the multiplier dichotomy |
| `MULT_IRRATIONALLY_INDIFFERENT` | irrationally indifferent cycle | decided; the Siegel/Cremer split is **not** |
| `Separated_k^c` | separation by landed dynamical rays at rational angles | finite combinatorial separator (Phase 3) |
| `SameFiberLevel_k^c` | not separated through catalogue level `k` | finite non-separation predicate (Phase 3) |
| `LocallyConnected(K_c)` | local connectivity of the filled Julia set | what the imported fiber theory is stated about |
| `LocallyConnected(J_c)` | local connectivity of the Julia set | external theorem tag, never proved here; reached from `K_c` by an ungated transfer |
| `BrjunoCondition` | Brjuno condition on the rotation number | external, and not a finite test |

## Allowed finite claims

1. a parameter is Gaussian-rational and encoded canonically;
2. a cycle witness is an exact cycle of `f_c` with distinct elements;
3. a multiplier is computed exactly and classified into one of the five
   classes;
4. a quadrance-1 multiplier is or is not one of the four roots of unity of
   `Q(i)`;
5. a critical orbit escapes at a named index with a rational growth ratio, or
   is preperiodic with a named preperiod and period, or exhausted a named
   budget;
6. two implementations agree on all of the above.

## Forbidden finite claims

1. a Julia set is locally connected;
2. an irrationally indifferent parameter is Siegel, or is Cremer;
3. a capped orbit is bounded, or is unbounded;
4. an orbit with no escape certificate is bounded;
5. a multiplier of quadrance exactly 1 is attracting, or is repelling;
6. a coordinate record is an analytic complex number;
7. the quadrance-1 locus of `J_0` is a circle, or carries an arc, an angle, or
   a circumference;
8. a regime is discharged because one of its parameters checked out.

## The bridge shape

```text
J1-A. The finite catalogue relation at c is extensionally fiber separation for K_c.
J1-B. A finite nest at c stabilizes exactly when the corresponding fiber is trivial.
J1-C. All fibers of K_c are trivial if and only if J_c is locally connected.   [tag]
```

`J1-C` is imported. `J1-A` and `J1-B` are the work, and they are stated and
discharged per regime, not globally.
