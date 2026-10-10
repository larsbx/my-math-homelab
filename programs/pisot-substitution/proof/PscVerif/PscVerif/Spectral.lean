/-
# What this development proves, and what it does not

## Proved here, with no additional axioms

* `Psc.N_mul_N`, `Psc.N_mul_N₂` -- the degree-2 and degree-3 shuffle identities
  on words, including the coincidence corrections that the naive shuffle product
  omits.
* `Psc.BalancedPair.K₃_shuffle_zero` -- §3's "certified fact 3": on a balanced
  pair with `K₂ = 0`, the degree-3 invariant satisfies the shuffle relations, so
  `K₃(s) ∈ W₃`.
* `Psc.seed_K₂_zero`, `Psc.seed_length`, `Psc.seed_K₃_mem_W₃` -- §4's seed list is
  what it claims to be.
* `Psc.theta_seed` -- §6's table is *derived*: `Θ` applied to each seed's own `K₃`
  gives the tabulated `A_k`.
* `Psc.trace_A`, `Psc.trace_sq_A`, `Psc.det_A_ne_zero`, `Psc.A_ne_zero` --
  §6 properties 1, 2, 3, 7.
* `Psc.Aq_mulVec_ones`, `Psc.Aq_eigenspace` -- §6 property 6, both halves: the
  universal eigenvector, and that its eigenspace is exactly that line.
* `Psc.no_commuting_of_no_eigenvalue` -- the centralizer contradiction, over an
  arbitrary field.
* `Psc.target1` -- **PIP-Locus Target 1** in contradiction form: no matrix
  without a rational eigenvalue commutes with a seed matrix.
* `Psc.no_equal_row_sums` -- §7's concrete corollary.
* `Psc.trace_sq_cyclicPlus`, `Psc.trace_sq_cyclicMinus`,
  `Psc.Aq_not_conj_cyclicPlus`, `Psc.Aq_not_conj_cyclicMinus` -- §9's trace
  obstruction and the Dominant Cubic Capture step that rests on it.

## Deliberately not proved here

* The `Θ`-intertwining identity `Θ(M^{⊗3} x) M = det(M) M Θ(x)` as a polynomial
  identity in `ℤ[m_ij]`.  It is verified exactly, on the whole PIP corpus with
  entries in `0..2` and on all six seeds, by the Mojo kernel (check `C7`).
* Semisimplicity of `Φ₃`, the Galois-transitivity arguments of §8 and §9, and the
  passage from "nonzero projection onto the dominant factor" to a spectral-radius
  bound.  These need the splitting field of `χ_M` and are not formalised.
* Hypothesis **G1** (finiteness of `B_σ`) and the **SCC Producer** conjecture.
  These are state-machine statements, specified and model-checked in scope in the
  TLA+ layer (`proof/tla/BPA.tla`), and they remain open in general.  The
  proof-architecture ledger `proof/tla/ProofArchitecture.tla` records exactly which
  claims depend on them.
* Everything in §12's "what this certificate does NOT prove" list.

## Axiom audit

The `#print axioms` commands below must report only Lean's three standard
axioms (`propext`, `Classical.choice`, `Quot.sound`).  Any `sorryAx` here would
mean a gap.
-/
import PscVerif.TraceLemma

namespace Psc

#print axioms BalancedPair.K₃_shuffle_zero
#print axioms seed_K₃_mem_W₃
#print axioms theta_seed
#print axioms trace_sq_A
#print axioms Aq_eigenspace
#print axioms target1
#print axioms no_equal_row_sums
#print axioms Aq_not_conj_cyclicPlus
#print axioms Aq_not_conj_cyclicMinus

end Psc
