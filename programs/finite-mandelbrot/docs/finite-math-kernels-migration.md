# Shared finite-math kernel migration

Status: implemented consumer migration; no theorem-status change.

finite-mandlebrot-research vendors `finite_exact/` from `larsbx/finite-math-kernels` at the full
commit recorded in `vendored.toml`. The checker is itself vendored from the
same upstream (`vendor/python/vendoring/check_vendored_sync.py`, `pixi run
vendored`): it verifies every vendored file by SHA-256 in CI, rejects an
unpinned source file inside a vendored package directory, and checks that the
`finite-math-kernels` `[[dep]]` pin in `ESTATE.toml` is the digest derived from
`vendored.toml`. After copying a package from upstream, `check_vendored_sync.py
pin NAME COMMIT` re-pins its digests and re-derives that pin (a new package is
first added to `vendored.toml` with its name, repository, root, and an empty
`[package.files]` table); `check_vendored_sync.py estate` re-derives the pin
alone. Arithmetic consumers import the
package-qualified modules under `vendor/mojo/finite_exact/`; the former root-level
implementations were removed. The machine-integer gcd (`integer_gcd`) and the
base-ten renderer (`exact_decimal`), first written in this repository under
`kernel/mojo/arithmetic/`, now live upstream in `finite_exact` and are imported
from there; the local copies were removed.

The same pin also vendors the monorepo's `substitution_dynamics` tuning,
directive-prefix, and column-coincidence modules under
`vendor/mojo/substitution_dynamics/`, consumed by `kernel/mojo/c1/residual/residual_directive_carrier.mojo`
(`docs/C1_residual_directive_carrier.md`); the balanced-pair and automaton
modules are not vendored. `continuation_last_letter` in that file is a thin
adapter over the vendored closed form `continuation_twist`
(`vendor/mojo/substitution_dynamics/tuning.mojo`; letter `0` exactly when the
twist is on): its brute-force body, which built both continuations and kept the
one whose internal address contains the period, was removed. The two agreed on
every 0/1 word of length at most 22 (8,388,607 words, the empty word refused by
both), on every accepted kneading prefix of `num/(2^p - 1)` for `p <= 20`
(2,097,110), and on 780,000 random words of length 23 to 61 and 59,663 random
accepted addresses of period 21 to 62. The adapter keeps the local signature
and refuses the empty prefix, as before. It also refuses any letter outside
`{0, 1}`: the brute force answered about half such words and refused the rest,
where upstream refuses none; no caller passes one, since every prefix comes
from `checked_kneading_prefix`. `internal_address`, its `_rho`, and
`checked_kneading_prefix` stay local: upstream ships no internal address and no
angle-to-kneading reading. The Python mirror
`reference/python/c1/kneading_reference.py` keeps the brute-force search as the
independent oracle; it is not a copy of upstream's `continuation_twist` (its
`rho` and `internal_address` are what upstream's
`tests/substitution_dynamics/test_tuning_reference.py` uses as its brute-force
check).

The smoke suite's named reporter is the vendored `mojo_smoke` package
(`vendor/mojo/mojo_smoke/report.mojo`); it replaced
`kernel/mojo/smoke/smoke_report.mojo`, which differed from it only in its
header comment.

The interval critical orbit's shared pieces are the vendored `quadratic_orbit`
package (`vendor/mojo/quadratic_orbit/`). `kernel/mojo/dynamics/interval_orbit.mojo`
imports the collision partition (`intended_pair`, `forbidden_count`) from
`quadratic_orbit/collision.mojo` and the orbit step (`zero_box`,
`quadratic_step` under the local name `next_orbit_value`), `collision_interval`
and `complex_excludes_zero` from `quadratic_orbit/orbit.mojo`; its local copies,
and the unused local `intended_count`, were removed. The two partitions agree
on every input the consumer passes: both intend nothing when `ell < 1` or
`period < 1` (so a purely periodic type, `ell = 0`, is rejected by
`OrbitEvalConfig.valid()` before partitioning and partitions to nothing if
reached anyway), and upstream additionally refuses negative indices, which no
caller passes. `excludes_zero`, the two-valued reading of
`complex_excludes_zero`, stays local. The legacy-syntax
`kernel/mojo/certificates/collision_sets.mojo` (and the other uncompiled
`fn`-era files) keeps its own partition: it is outside the compiled closure,
and its `is_intended_tail_pair` intends tail pairs at `ell = 0`, which the
upstream partition does not.

The BigZ ray address of `kernel/mojo/dynamics/bigq_ray_address.mojo` is the
vendored `rational_dynamics` `ReducedFraction`, and its doubling and equality
are `double_mod_one` and `fraction_equal`
(`vendor/mojo/rational_dynamics/rational.mojo`). `make_bigq_ray_addr` remains a
thin adapter that keeps the local contract: the input is normalized as a `Q`
first, so a negative denominator flips the sign as before, and an address
outside `[0, 1)` is refused, where upstream `reduce_fraction` would accept any
nonnegative fraction. The Int64 checked addresses of
`kernel/mojo/dynamics/checked_ray_address.mojo` and the checked Int64 backend
they ran on are retired: the kneading and tuning kernels that imported them now
use the vendored `rational_dynamics` doubling over BigZ.

The catalogue denominator `2^l (2^k - 1)` of
`kernel/mojo/certificates/misiurewicz_catalogue.mojo` is the vendored
`angle_doubling` `type_count` (`vendor/mojo/angle_doubling/angle.mojo`): the
addresses with `2^(l+k) t = 2^l t` are exactly the multiples of that
denominator's reciprocal, and the local index and denominator bounds still
apply first. Three local readings stay, because upstream's differ:
`exact_type` reads every period up to its denominator bound `2^20`, while
upstream `period` refuses past 64 (the smoke's brute-force check reaches
`1/107`, of period 106); `angle_period` in `kernel/mojo/dynamics/angle_tuning.mojo`
reads periods of denominators up to `2^62 - 1`, while upstream `Angle` refuses
denominators past `2^30`; and `catalogue_count` counts the addresses of
*exact* type `(l, k)` by Moebius inversion, which `type_count`, counting every
address with `2^(l+k) t = 2^l t`, is not.

The lexical audits (`tools/audit_no_trig.py`, `tools/audit_no_points.py`,
`tools/audit_exact_arithmetic.py`) and the source-reading tests mask comments
and strings with the vendored `claim_governance.lexing.mask_comments_and_strings`;
the local `tools/source_tokens.py` was removed. The two maskers produced
byte-identical output on every `.py`, `.mojo`, `.md`, `.toml` and `.tex` file
in the repository when the swap was made. They differ only where the local
copy mis-lexed: upstream keeps a backslash-continued single-quoted string open
and does not close a triple-quoted string at an escaped quote.

`tools/audit_exact_arithmetic.py` is a policy over the vendored
`exact_arithmetic_audit` engine (`vendor/python/exact_arithmetic_audit/`),
unified upstream from this repository's audit and finite-julia-set-research's.
The policy reproduces the former audit (the section 6.2 binding table, the
fourteen required headings, any class admitted, the four vendored facades
exempt from the citation check), and gains the engine's stricter checks: a
`DType.float*` dtype is a C1 hit, only list items of
`tools/exact_arithmetic_allowlist.md` grant a quarantine, and the
specification must name this repository (as `larsbx/finite-mandlebrot-research`,
its spelling there). None of these reports anything on this tree. Arithmetic
consumers are still the modules that import `rat_q`, `rational`, `closed_q` or
`closed_interval`: reading any `finite_exact` import would also demand rows
for seven modules that use only `integer_gcd`, `bigint_z` or `exact_decimal`
(`kernel/mojo/arithmetic/big_int_boundary.mojo`,
`kernel/mojo/certificates/c_minus_2/bigq_landing_target_adapter.mojo`,
`kernel/mojo/certificates/certificate_sets.mojo`,
`kernel/mojo/certificates/misiurewicz_catalogue.mojo`,
`kernel/mojo/dynamics/ray_address.mojo`,
`kernel/mojo/entrypoints/atlas_dataset.mojo`,
`vendor/mojo/rational_dynamics/rational.mojo`), none of which consumes the
`Q` or `IQ` layer the binding table governs.

`tools/audit_terminology.py` is a policy over the vendored `lexical_audit`
engine (`vendor/python/lexical_audit/`), unified upstream from this
repository's terminology audit, finite-julia-set-research's and the bulbs
repository's no-limits audit. Its constants are unchanged; the registry and
the use manifest are governing documents whose requirements are the former
checks, and the risky-phrase, deprecated-term, C1-scoped-term and rank-2
locus checks are context rules (a marker within 140 characters of the
occurrence's start). One check is stricter: every occurrence of a C1-scoped
term or a rank-2 locus phrase is read, where the former audit read only the
first, so a negated first mention no longer hides a later one. A finding is
named once, and the report lists findings in rule order rather than file
order. On this tree it reports nothing, as the former audit did;
`tests/test_terminology_audit.py` plants one violation per rule.

The interval exclusion oracle
`reference/python/interval/interval_exclusion_reference.py` computes over the
vendored `closed_interval` package (`vendor/python/closed_interval/`), the
Python twin of `closed_q`; its local `I` and `CI` classes were removed. Their
complex square was the expanded product `mul(self)`, looser than the sharp
square of the vendored Mojo `closed_q` whenever a coordinate interval contains
`0`. No recorded result moved: the pinned verdicts (`c = -2`, horizon 3: 5/5;
`M_{4,1}`, horizon 6: 18/18), the `c = -2` box at horizon 4 (5/7, failing
`(0, 4)` and `(1, 4)`), and every box math-vizops's atlas chooses and decides
from the current `pixi run atlas-dataset` output are identical under both
squares. `excluded_count`, `dyadic_box`, `c_minus_2_box` and `m41_box` keep
their signatures, and a box still exposes `re.lo`, `re.hi`, `im.lo` and
`im.hi`. A reversed interval is now a rejected value that poisons every
operation, as in `closed_q`, rather than a `ValueError`; a rejected
difference box excludes nothing.

This changes ownership, not mathematical semantics:

- `BigZ` and `Q` remain exact, unbounded, and fail closed;
- interval predicates remain conservative and distinct from exact acceptance;
- certificate acceptance remains a consumer responsibility;
- C1 and every source-pending theorem dependency remain unresolved unless a
  separate proof record says otherwise.

The old standalone library repositories may be archived only after the PSC
consumer migration is merged and repository-wide reference checks show no
live pin to them.

