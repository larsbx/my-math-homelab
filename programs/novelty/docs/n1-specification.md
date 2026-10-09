# N1 specification: conventions and certificate format v1

**Status:** candidate. Specification of `kernel/n1/` (checker) and
`experiments/n1/search.py` (search); soundness is tracked as pending records
in [the ledger index](ledger-index.md).

## 1. Convention `cayley-dickson/v1`

Base field ℚ (characteristic 0, so the characteristic-two exclusion holds
trivially). Parameters g₁, …, gₙ ∈ ℚ^×.

```text
A_0 = Q,   A_k = A_{k-1} ⊕ A_{k-1}   (parameter g_k)
(a, b)(c, d) = (ac + g_k · conj(d) b,  d a + b conj(c))
conj(a, b)   = (conj(a), −b)
```

Coordinates: an element of Aₙ is 2ⁿ rationals, the first half being its
A_{n−1} component; A_{n−1} ⊂ Aₙ as (x, 0). With n = 2, A₂ is the quaternion
algebra (g₁, g₂)_ℚ: i = e₁, j = e₂, i² = g₁, j² = g₂, ij = −ji = e₃. The tests
pin these relations, associativity at n = 2, alternativity at n = 3, failure
of alternativity at n = 4, and scalar norms x·conj(x) for n ≤ 3.

## 2. Certificates (`schemas/n1-certificate-v1.json`)

| verdict | witness | checker accepts iff | soundness |
|---|---|---|---|
| `zero_divisor` | `x`, `y` ∈ Aₙ | x ≠ 0, y ≠ 0, xy = 0 exactly | `ZeroDivisorCertificateSoundness` (elementary) |
| `division` | `place` ∈ {`inf`, prime} | n = 2 and (g₁, g₂)_place = −1 | `DivisionCertificateSoundness` ← `HilbertSymbolFormula`, `QuaternionSplitIffConic` |

Rationals are canonical strings `p` or `p/q` in lowest terms; `1 ≤ n ≤ 8`.
A refused certificate proves nothing in either direction.

Deliberately absent: division certificates for n = 3 (need the 3-fold
Pfister local–global statement pinned first) and for n ≥ 4. The verdict is
named `zero_divisor`, not `split`. For n ≤ 3, "has a zero divisor" and "split"
coincide only via a composition-algebra theorem that has not been imported yet.

## 3. Search

`experiments/n1/search.py` works in the first quaternion subalgebra only:
a ramified place (when n = 2), else the least-height integral solution of
z² = g₁x² + g₂y² gives q = z + xi + yj of norm 0 and the pair (q, conj q).
It is non-authoritative and may return `inconclusive`. Tests cross-check
the two routes: on a 100-pair grid, a ramified place and an isotropic vector
never coexist, and every quaternion pair in the grid is decided.

## 4. Next gates

1. Mathlib coverage audit (work package 1): Hilbert symbols, quaternion
   algebras, and Cayley–Dickson constructions in Lean 4/mathlib.
2. Human review of the three pending soundness records, then re-kind them
   (`imported_theorem` with `hypotheses_checked`, `repository_theorem` with
   `proof_reviewed`).
3. Extend division certificates to n = 3 after the Pfister-form statement is
   pinned; a zero-divisor search for n = 4 that does not route through a
   split quaternion subalgebra.
