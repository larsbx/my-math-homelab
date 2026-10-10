# Legacy NLAP provenance

The repository historically named `larsbx/NLAP-JT` is being migrated. Its name is not a stable domain identifier for new oracle registrations.

Salvageable exact-arithmetic, canonical-serialization, and certificate-replay material may be ported only when:

1. the source commit and original path are recorded;
2. the mathematical contract is restated independently of the legacy repository name;
3. the target claim and boundary identifiers exist in the successor or shared kernel repository;
4. golden vectors are checked against the authoritative implementation;
5. legacy proof or acceptance status is not inferred from successful oracle replay.

The first oracle therefore binds to `larsbx/finite-math-kernels`, claim `bigz-canonical-bytes`, boundary `shared-finite-kernel`. This preserves useful content without freezing the migrating NLAP name into the new registry.
