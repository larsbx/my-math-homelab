# Certificate predicate migration inventory

Status: executable-boundary inventory during BigZ-backed c=-2 replay.

This inventory separates finite computations, imported classical results, and
the global C1 obligation. A green bounded-width computation is not a
proof-grade certificate and cannot discharge an imported theorem or C1.

| Predicate | Current executable source | State | Acceptance consequence |
| --- | --- | --- | --- |
| Squarefree `P_{2,1}` evaluation and strict localization | `kernel/mojo/certificates/krawczyk_witness.mojo` | replayed on unbounded BigZ rational intervals; rejection distinct from non-contraction | accepts the finite arithmetic replay only; proof-grade acceptance is explicitly false |
| Same-box forbidden collisions | `kernel/mojo/dynamics/interval_orbit.mojo` | replayed 5/5 on the same parameterized BigZ box constructor as localization; rejection distinct from ambiguity | accepts the finite exact-type arithmetic replay only |
| Rational ray-address orbit for `1/2` | `kernel/mojo/dynamics/bigq_ray_address.mojo` | replayed with normalized BigZ-backed `Q`, including a representation whose inputs exceed `Int64`; malformed and out-of-range values reject | accepts finite symbolic address data only |
| Rational parameter-ray landing replay | `kernel/mojo/certificates/c_minus_2/bigq_landing_target_adapter.mojo` | composes same-exponent BigZ localization, exact-type exclusion, and symbolic address replay; correspondence citation remains metadata | finite replay only; retained as a non-acceptance-bearing cross-check |
| Proof-grade rational landing target association | `kernel/mojo/certificates/c_minus_2/proof_grade_landing_target_association.mojo` | exact BigZ/Q ray orbit, exact BigZ replay of `R_{2,1}=C^3(C+2)`, lower-type exclusion of `C=0`, exact type `(2,1)` at `C=-2`, and canonical checked theorem import | proof-grade target association accepted for the `c=-2`, address-`1/2` payload |
| Legacy BigQ theorem payload replay | `kernel/mojo/certificates/c_minus_2/bigq_theorem_tag_payload_instances.mojo` | finite source scope matched with classification attachment deliberately absent | remains non-final; superseded for the acceptance-bearing rational landing path by the proof-grade association module |
| Known trivial-fiber class import | `kernel/mojo/certificates/c_minus_2/bigq_theorem_tag_payload_instances.mojo` | BigZ/Q Misiurewicz instance data matched; classification proof attachment explicitly absent | final import remains false |
| Finite-certificate composition | `kernel/mojo/certificates/c_minus_2/bigq_finite_certificate_gate.mojo` | BigZ/Q finite inputs compose at standard and beyond-`Int64` widths; ambiguity and invalid widths reject | theorem tags and complete certificate acceptance remain false |
| Incidence packaging | `kernel/mojo/certificates/c_minus_2/bigq_certificate_incidence.mojo` | compiler-wired carrier stores three explicit finite vertices and validates their roles and distinctness | finite incidence may package; certificate emission remains false |
| Rational parameter-ray landing import | `kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo` | source metadata checked independently; source scope consumes the BigZ/Q landing replay (`bigq_landing_target_adapter.mojo`); final path consumes `ProofGradeLandingTargetAssociation` | final import admissible for the `c=-2`, address-`1/2` instance |
| Known trivial-fiber class import | `kernel/mojo/certificates/c_minus_2/proof_grade_misiurewicz_trivial_fiber_classification.mojo`, `kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo` | checked source record and payload bound to the proof-grade `c=-2`, exact type-`(2,1)` target; wrong target/type/source/payload-kind reject | class-specific import accepted; generic MLC, all-fiber triviality, residual closure, and C1 remain false |
| Incidence packaging | legacy `kernel/mojo/certificates/certificate_incidence.mojo` | size-only carrier, not in the compiler-wired acceptance path | retained for comparison; superseded by explicit BigZ-path carrier |
| Integer backend | `src/bigint_z.mojo` | dynamic limbs with exact ring/order/division/gcd and canonical integer serialization | rational and core intervals migrated; remaining consumers still block proof-grade acceptance |
| `ResidualClosureNoMissingLinks` | `kernel/mojo/c1/residual/residual_closure_no_missing_links.mojo` | open | blocks C1 independently of finite certificates |

## Next obligations

1. Implement `CanonicalFiniteCertificateIncidenceReplay`: define canonical
   serialization for the explicit finite incidence carrier and verify
   deterministic replay across processes.
2. Keep complete certificate acceptance fail-closed until canonical incidence
   replay is acceptance-bearing.
3. Keep the C1 residual-closure proof track separate; no finite example,
   accepted landing import, or successful certificate instance implies the
   missing global closure statement.

The checked Int64 rows this inventory used to carry (`checked_krawczyk_witness.mojo`, `checked_interval_exclusion.mojo`, `certificate_arithmetic_migration_gate.mojo`, the `1/2` orbit in `checked_ray_address.mojo`, `checked_landing_target_adapter.mojo`, `checked_finite_certificate_gate.mojo`) are retired; the BigZ/Q rows above replay each of them exactly wherever the Int64 path did not reject for overflow.
