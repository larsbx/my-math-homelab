# Mojo toolchain boundary

Status: compiling initial slice; repository-wide port incomplete.

The repository pins Mojo 1.0.0 and pytest 8.3.5 through `pixi.toml` and
`pixi.lock`. Every package the lock takes from the Modular channel (`mojo`,
`mojo-compiler`, `mojo-python`, `mblack`) is pinned by `==` in the manifest,
and `tests/test_mojo_toolchain.py` checks the two agree. CI performs both a JIT smoke run and an ahead-of-time build.

The compiler-checked dependency closure currently consists of:

- `kernel/mojo/smoke/smoke_tests.mojo`;
- `kernel/mojo/polynomial/poly_z.mojo`;
- `kernel/mojo/certificates/cert_types.mojo`;
- `vendor/mojo/finite_exact/rat_q.mojo`;
- `vendor/mojo/finite_exact/integer_gcd.mojo`;
- `kernel/mojo/dynamics/ray_address.mojo`;
- `kernel/mojo/arithmetic/rational_trig.mojo`;
- `kernel/mojo/theorem_kernel/alignment_audit_status.mojo`;
- `kernel/mojo/theorem_kernel/mojo_optimization_contract.mojo`;
- `vendor/mojo/finite_exact/closed_q.mojo`;
- `kernel/mojo/polynomial/poly_interval_eval.mojo`;
- `kernel/mojo/certificates/krawczyk_witness.mojo`.
- `kernel/mojo/c1/proof/final_proof_block_ledger.mojo`.
- `kernel/mojo/c1/residual/residual_closure_no_missing_links.mojo`.
- `kernel/mojo/c1/theorem_tags/theorem_tag_assumption_payloads.mojo`.
- `kernel/mojo/c1/theorem_tags/theorem_tag_import_ledger.mojo`.
- `kernel/mojo/c1/proof/final_proof_object_skeleton.mojo`.
- `kernel/mojo/arithmetic/cert_backend.mojo`.
- `kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo`.
- `vendor/mojo/finite_exact/bigint_z.mojo`.
- `kernel/mojo/arithmetic/bigint_adapter.mojo`.
- `vendor/mojo/mojo_smoke/report.mojo`.
- `kernel/mojo/dynamics/angle_tuning.mojo`.
- `kernel/mojo/dynamics/bigq_ray_address.mojo`.
- `kernel/mojo/certificates/c_minus_2/bigq_landing_target_adapter.mojo`.
- `kernel/mojo/certificates/c_minus_2/bigq_theorem_tag_payload_instances.mojo`.
- `kernel/mojo/certificates/c_minus_2/bigq_finite_certificate_gate.mojo`.
- `kernel/mojo/certificates/c_minus_2/bigq_certificate_incidence.mojo`.
- `vendor/mojo/substitution_dynamics/substitution.mojo`.
- `vendor/mojo/substitution_dynamics/tuning.mojo`.
- `vendor/mojo/substitution_dynamics/internal_address.mojo`.
- `kernel/mojo/c1/residual/residual_directive_carrier.mojo`.
- `kernel/mojo/c1/separator/separated_density.mojo`.
- `kernel/mojo/certificates/misiurewicz_catalogue.mojo`.
- `kernel/mojo/c1/wake/misiurewicz_prefix_graph.mojo`.
- `kernel/mojo/certificates/c_minus_2/proof_grade_landing_target_association.mojo`.
- `kernel/mojo/certificates/c_minus_2/proof_grade_misiurewicz_trivial_fiber_classification.mojo`.
- `vendor/mojo/quadratic_orbit/collision.mojo`.
- `vendor/mojo/quadratic_orbit/orbit.mojo`.
- `vendor/mojo/rational_dynamics/rational.mojo`.
- `vendor/mojo/rational_dynamics/doubling.mojo`.
- `vendor/mojo/rational_dynamics/moebius.mojo`.
- `vendor/mojo/rational_dynamics/multiplicative_order.mojo`.
- `vendor/mojo/rational_dynamics/carmichael.mojo`.
- `vendor/mojo/rational_dynamics/integers.mojo`.
- `vendor/mojo/angle_doubling/angle.mojo`.

A second compile target, `kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo`, imports
`bigint_z`, `rat_q`, and `interval_q` and is executed by `pixi run property`,
which pipes its transcript into `reference/python/arithmetic/exact_arithmetic_property_oracle.py`.

This slice checks the preserved polynomial identities, certificate-header
constraints, the same-box joint-witness gate, imported-theorem-tag acceptance,
normalized rational arithmetic, rational ordering, interval multiplication,
coordinate-record quadrance, normalized rational spread, symbolic ray-address
doubling through the vendored `rational_dynamics`, and interval Horner evaluation of the squarefree
localization polynomial, and the exact interval Krawczyk contraction for
`P_{2,1}` at the dyadic box centered on -2. It also checks the C1 final-ledger
readiness and final-evidence policy from explicit data, including an unsafe
negative control, and checks typed accepted and rejected residual exit kinds.
It also checks typed theorem assumption-payload families, conclusions, and
strength classes, including out-of-range, generic-MLC, and bounded-search
rejection paths.
The import ledger separately checks typed conclusion, strength, and status
vocabularies while retaining its scaffolded, non-final records.
The final proof-object skeleton checks its acceptance policy from explicit data,
including unsafe-policy and missing-link negative controls; this does not make
the current partial ledger ready for C1.
Repository alignment policy is checked from explicit data with an unsafe
theorem-import negative control.
Optimization policy is likewise checked from explicit data, including a
negative control that attempts to mark a debug path proof-grade.
The checked Int64 transition layer rejects boundary overflows, invalid
denominators, and the known Q_8 coefficient-growth case. It is not a bigint
backend and is not wired into `Q`, so proof-grade acceptance remains disabled.
The checked Int64 rational stack that used to follow it (checked `Q`, interval
`Q` and complex interval layers, the checked `P_{2,1}` Krawczyk and exact-type
exclusion paths, the checked-width localization gate, and the checked c=-2
landing adapter and finite-certificate gate) is retired. The BigZ replays below
are the certificates of record: on every half-width the checked stack accepted
they reproduce its boxes, Krawczyk images and verdicts exactly, and they answer
where it rejected for overflow.
The checked ray-address primitives remain for the kneading and tuning kernels
that import them; they reject malformed or overflowing fixed-width inputs. The
`1/2 -> 0 -> 0` orbit for c=-2 is the BigZ replay's. Source-specific
theorem-tag instances match that replay to the Schleicher landing and
Misiurewicz-fiber source families, and take final import admissibility from the
proof-grade landing association and trivial-fiber classification.
The completed `BigZ` integer backend uses dynamic base-`10^9` limbs and executes exact
signed construction, ring operations, order, quotient/remainder, rejected
non-divisions, and Euclidean gcd beyond `Int64` magnitude. Phase three adds a
canonical sign/8-byte-length/minimal-big-endian-magnitude encoding. Its complete
integer capability record permits rational migration, but no certificate path
uses it yet; bounded `Q` and downstream consumers still reject proof acceptance.
Quotient/remainder uses schoolbook long division, checked in-process against the
retained shift-and-subtract reference; `Q` scales by denominator cofactors and
cross-cancels before multiplying. Both are exercised by the smoke target and by
the randomized property probe.
The BigZ landing-target replay composes the same exponent across localization
and exact-type exclusion with a normalized symbolic `1/2 -> 0 -> 0` address
orbit whose supplied numerator and denominator exceed `Int64`. It explicitly
rejects theorem-import and certificate acceptance; the correspondence citation
is metadata only.
The BigZ theorem-payload and finite-certificate layers now replay finite source
scope and compose the c=-2 inputs. Their classification-proof flags remain
false, so theorem imports, complete certificate acceptance, C1, and
`ResidualClosureNoMissingLinks` all remain unaccepted.
The BigZ incidence layer packages the finite root-handle, symbolic-address-set,
and rational-box vertices as three explicit carrier members. It validates their
roles and distinctness, while keeping certificate emission false because the
theorem imports remain unaccepted.
Passing it does not imply that
every `.mojo` file compiles, that the Int64 coefficient backend is proof-grade,
or that any open C1 theorem obligation has been discharged.

Remaining modules retain legacy syntax until they enter an explicitly listed,
dependency-closed compile target. The compile frontier must expand by adding
real imports and executable assertions, not by treating source-text inspection
as type checking.
