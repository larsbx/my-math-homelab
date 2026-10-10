import LanglandsOracles.ModL5
import LanglandsOracles.ModL7
import LanglandsOracles.ModL11
import LanglandsOracles.ModL13
import LanglandsOracles.ModL17
import LanglandsOracles.ModL19
import LanglandsOracles.ModL23
import LanglandsOracles.ModL29
import LanglandsOracles.ModL31

/-!
# ρ̄_ℓ for the 15 Cremona curves of prime level, ℓ = 5, 7, 11, 13, 17, 19, 23, 29, 31

One module per ℓ (`ModLℓ`), so that `lake` checks them in parallel: each holds the field facts, the check
that ζ generates 𝔽_ℓ^× (S generates GL₂ by the theorem `gl2_generated`), one declaration per certified
class pair (the kernel frees its cache between declarations), the per-curve arithmetic, and the headline
`modℓ_images_full`.  The ℓ ≥ 11 checks lift the default heartbeat limit.
-/
