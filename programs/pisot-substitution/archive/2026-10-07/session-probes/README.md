# Session probes behind the adversarial audit — 2026-10-07

Provenance for [`docs/audit-adversarial-prop-v-theorem-e-2026-10-07.md`](../../../docs/audit-adversarial-prop-v-theorem-e-2026-10-07.md).
This is **not canonical code** (AGENTS.md). It is an independently written Python oracle that imports
nothing from the repository, and it is not a certificate: overlap tests use 60-digit
floats (mpmath). Needs `sympy`, `numpy` and `mpmath`. Run each script from this directory.

| file | what it does | output |
| --- | --- | --- |
| `common.py` | PIP screen; `coincidence_level`, a breadth-first strong-coincidence decider on the overlap graph that returns `None` only after exhausting the finite closure | — |
| `xcheck.py` | decider vs direct shared-tile scan, 300 random PIP specimens, all 3 pairs | `xcheck.out` |
| `enum_e.py L` | Theorem E's class enumerated from the definitions (images of length ≤ `L`): Proposition D normal form and `{x, c}` coincidence | `enum_e_L4.out`, `enum_e_L5.out` (≈4 min) |
| `tables.py` | symbolic `det M`, `f(1)`, `f(−1)` for all 16 endings | `tables.out` |
| `sweep_nf.py N` | named lemma positions, residue, decisions for `p, q, r ≤ N` | `sweep_nf_N30.out` |
| `propv.py R` | Proposition V radii, integral centre pairs for `r ≤ R`, shared vertices | `propv_R7.out` |
