# Q-A condition (1): exact reduction and why it is irreducible (2026-06-13)

## Result
Condition (1) of homological-Pisotness of Σ_C — that every nonzero root of
q = χ_{N_C}/χ_{M_σ} is a root of unity — reduces, on the b₁=0 (loop-free base) stratum
where condition (3) is already proved (thm:inherit), to a single integer identity plus a
roots-of-unity clause:

    r = (C_comp − 1) − b₁,   and the C_comp−1 nonzero q-roots are all equal to 1,

where r = #{nonzero roots of q, with multiplicity} and C_comp = #components(G₀^ER(Σ_C)).
On the b₁=0 stratum this is r = C_comp − 1 with all those roots = 1.

## Derivation (from the BBJS exact sequence, exact)
dim Ȟ¹(Ω_{Σ_C}) = dim lim N_C^⊤ − (C_comp − 1) + b₁, and dim lim N_C^⊤ = k + r (the β-block
of degree k plus the r nonzero roots of q). Homological Pisot is dim Ȟ¹ = k, giving
r = (C_comp−1) − b₁. This is cor:QAresidue made precise.

## Validation on known homological-Pisot reducible substitutions
The two BBJS cr=3 triple covers (Examples 1, 2), which ARE homological Pisot with C_comp=3,
b₁=0:
- Example 1 (d=1): χ = x³(x−9)(x−1)²; q = x³(x−1)²; r = 2 = (3−1)−0; both nonzero roots = 1. ✓
- Example 2 (d=2): χ = x²(x−1)²(x²−12x−9); q = x²(x−1)²; r = 2 = (3−1)−0; both roots = 1. ✓
(Self-correction logged: first pass used minpoly x²−12x+9; the correct minpoly of 6+3√5 is
x²−12x−9, fixed; divisibility then exact.)
The identity and condition (1) hold precisely on the known examples.

## Why the residual is IRREDUCIBLE (the key finding)
The lower bound r ≥ C_comp−1 in roots of unity is PROVED (cor:rootofunity, H̃⁰ injection).
The residual is the UPPER bound r ≤ C_comp−1. This is NOT derivable from b₁=0:
- On the producing corpus, the nonzero spectrum of N_C is essentially FULL: r₀/|C| has
  **median 1.000** across 152 recurrent SCCs (min 0.600), and only **7.9%** have r₀ ≤ 2.
  Generic N_C have no nilpotent part.
- So r ≤ C_comp−1 is a strong, highly non-generic constraint. For connected G₀^ER
  (C_comp=1) it forces r = 0 — N_C entirely nilpotent off the β-block — which essentially
  nothing satisfies.

Therefore condition (1) is genuine, independent content: it is the homological-Pisot
hypothesis itself (the spectrum of N_C collapsing to {β-conjugates} ∪ {roots of unity} ∪
{0}), NOT a consequence of the loop-free base. There is no shortcut from b₁=0 to condition
(1); cor:rootofunity gives the lower half (≥ C_comp−1 roots of unity) for free, and the
upper half is irreducibly the rigidity hypothesis.

## Consequence for the program (honest placement)
- thm:inherit closes condition (3) unconditionally on the b₁=0 stratum.
- cor:rootofunity gives the lower half of condition (1)+(2) (≥ C_comp−1 roots of unity).
- The remaining content of Q-A is the single upper bound r ≤ C_comp−1, equivalent to "no
  extra nonzero N_C-spectrum beyond β-conjugates and the forced roots of unity." This is
  the homological-Pisot rigidity, provably non-generic, with no census purchase (the
  premise is the trapped object) and no derivation from the loop-free structure.
- This does not advance the open core but PINS its exact location: Q-A is not three
  conditions but, on the b₁=0 stratum, ONE inequality r ≤ C_comp−1, and that inequality is
  the irreducible homological-Pisot content. The no-coarse-quotient meta-theorem governs:
  the spectral collapse is a positional/rigidity fact no count-level argument reaches.

## Sharp sub-target identified (for any future attack)
On the b₁=0 stratum, Q-A (hence the cohomological route prop:qa-crc) holds for a trapped Σ_C
IFF its transition complex satisfies r ≤ C_comp−1, equivalently (connected case) IFF the
trapped component is spectrally minimal: q(x) = x^{|C|−k}, all extra N_C-spectrum nilpotent.
Whether the trapped (cut-disjoint, anchor-free, ρ(N_C)=β) constraints FORCE this collapse
is the precise open question — now isolated as a single spectral-minimality statement rather
than a vague "rigidity."

## Artifacts
cond1_identity_check.py (BBJS-example validation), cond1_upper_probe.py (genericity probe).
