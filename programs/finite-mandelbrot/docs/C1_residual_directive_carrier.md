# C1 residual directive carrier

Status: definition-level carrier for the residual class; no theorem-status change.

This note binds round-two item R1 of `docs/cross-pollination-round-two-2026-09-16.md` (N1) into the C1 program. After the class-specific theorem tags of `docs/C1_theorem_tag_import_ledger.md`, persistent non-separation between distinct parameters can only occur inside the infinitely renormalizable class. That class has a finite-combinatorial description: an infinite directive sequence of tuning substitutions, one per renormalization level. The carrier defined here is a finite prefix of that sequence, computed exactly from periodic rational ray addresses by `kernel/mojo/c1/residual/residual_directive_carrier.mojo`, with the substitution kernel vendored from `larsbx/finite-math-kernels` (`vendor/mojo/substitution_dynamics/`, pinned in `vendored.toml`).

## Terminology declaration: residual directive carrier

Genealogy: The term combines the C1 vocabulary of carriers (`docs/C1_unresolved_wake_to_carrier_obstruction.md`) with the S-adic vocabulary of substitution dynamics, where a directive sequence is a sequence of substitutions whose composites generate a subshift. The tuning-as-substitution reading of renormalization is the Douady–Hubbard tuning operator written on kneading sequences.

Bridge claim: definition-only project term. A residual directive carrier is a finite list of levels, each an exact periodic rational ray address with the tuning pattern it determines. It carries no analytic object. The claim that the pattern's substitution is Douady–Hubbard tuning acting on kneading sequences is the scaffolded theorem tag `TuningKneadingSubstitution`, not a property of the carrier.

Known leaks: A carrier describes the dynamical-plane combinatorics of a renormalization level; it says nothing about parameter-plane shrinking of the nested tuned copies, which needs a priori bounds. Two carriers agreeing to every finite depth is the persistent non-separation frontier restated, not resolved. A level is an address, and the two root addresses of one component compare as different levels; companion identification is not implemented. The twist rule below is exact combinatorics checked on finitely many instances against angle tuning; its identification with tuning for every centre rests on the cited source.

Use discipline: Use only in C1 frontier documents and C1 source files, or with a pointer to this declaration. Never write that a carrier proves same-fibre membership, decides residual membership, or bounds renormalization.

## Objects

```text
level(theta) := (num, den, pattern(theta))          theta = num/den periodic under doubling
pattern(theta) := (kneading_prefix(theta), twist)   the vendored TuningPattern form
carrier := [level_1, ..., level_n]                  refinement appends a level
```

### Kneading prefix of an address

For a periodic address `theta` of period `p`, the 0/1 kneading sequence is the itinerary of `2^k theta` (modulo one, `k = 0, 1, ...`) with respect to the two half-open arcs cut by `theta/2` and `(theta+1)/2`: letter `1` for the open arc containing `theta`, letter `0` for the other, and `*` at the first boundary hit, which is position `p - 1`. `checked_kneading_prefix(num, den)` computes the letters before `*` with checked `Int64` cross-multiplication and rejects addresses outside `(0, 1)`, addresses with an even reduced denominator, overflow, and periods beyond `62`. This is the kneading sequence of Bruin and Schleicher's symbolic dynamics of quadratic polynomials, evaluated on the address itself.

### Twist: the continuation rule

The pattern's substitution is `s -> prefix . (s xor twist)`. The twist is chosen so that the image of `1` is `A(nu)`, the periodic continuation of `nu = prefix *` whose internal address `1 -> rho(1) -> rho(rho(1)) -> ...` contains the period `p`, where `rho(m) = min { k > m : nu_k != nu_{k-m} }`. `continuation_last_letter` returns its last letter through the vendored closed form `continuation_twist` (`1 - nu_(n-S)` with `S` the last internal-address entry below `n`; upstream `docs/tuning-substitutions-spec.md` section 1.3), and rejects an empty prefix and any letter outside `{0, 1}`. On 0/1 prefixes exactly one continuation qualifies, so nothing else is rejected; the internal address is the vendored `internal_address` (upstream checks it against a brute-force search over the periodic extension), the smoke target replays the characterization against it for every prefix of length at most 10, and `reference/python/c1/kneading_reference.py` keeps the brute-force search as the independent oracle.

The parity twist shipped by the vendored kernel as `TuningPattern.dgp` (Derrida–Gervois–Pomeau) agrees with this rule on real centres and disagrees on the rabbit (`1/7`, prefix `11`, where `A(11*) = 110`); the carrier therefore never uses `dgp`, and `dgp_parity_twist_is_general()` returns `False`.

### Kneading prefix of a carrier

`ResidualDirectiveCarrier.kneading_word()` is the vendored `kneading_prefix` of the levels' patterns: the prefix of the star product `A_1 * ... * A_n`, of length `p_1 ... p_n - 1`, which every image of the composite substitution begins with. `agrees_to_depth(other, k)` compares the first `k` addresses; `refined(level)` returns a new carrier; `checked_period()` is the product of the levels' periods with `Int64` overflow reported, never wrapped, and `kneading_word()` refuses to expand a carrier whose period overflows or exceeds `2^20` letters.

## Exact checks

The Mojo smoke target and `tests/test_C1_residual_directive_carrier.py` (through `reference/python/c1/kneading_reference.py`) pin the same instances. For each, the carrier's kneading prefix equals the kneading prefix of the address obtained by exact angle tuning (binary-block substitution by the component's two root angles):

| Levels (addresses) | Tuned address | Kneading prefix |
| --- | --- | --- |
| `1/3, 1/3` | `2/5` | `101` |
| `1/3, 1/3, 1/3` | `7/17` | `1011101` |
| `7/15, 1/3` | `8/17` | `1000100` |
| `1/7, 1/3` | `10/63` | `11011` |
| `1/7, 3/7` | `82/511` | `11011111` |

The Python test extends this to every periodic angle of period at most 10 as the base of a tuning by each of the five components of the reference (doubling, rabbit, airplane, primitive and satellite period 4) and checks that the continuation rule is well defined for every periodic angle of period at most 12. These are bounded experiments in the sense of `docs/finite-proof-records-spec.md`; they support the scaffolded tag and prove nothing about the residual class.

## Non-claims

`carrier_agreement_proves_same_fiber()`, `directive_prefix_decides_residual_membership()`, and `dgp_parity_twist_is_general()` return `False`. No carrier computation certifies persistent non-separation, fibre triviality, a priori bounds, or C1. Carrier refinement is one more renormalization level; whether refinement must eventually separate two distinct parameters is the open frontier recorded in `docs/C1_final_proof_block_ledger.md`.

## Next step

Companion identification (the second root address of a level's component) and a `density` field per level, the parameter-space twin of PSC's coincidence density (round-two item N2), so that carriers compare up to component rather than up to address.
