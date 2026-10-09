# Finite proof-record specification

Status: proposed reusable infrastructure contract. This document defines records
for finite computations, imported theorems, bounded experiments, open
dependencies, and dependency closure. It proves no mathematical statement,
accepts no finite-mandlebrot-research certificate, and does not discharge C1 or
`ResidualClosureNoMissingLinks`.

The intended future package name is `finite_proof_records`. The first
implementation must compile and execute in CI before any consumer treats it as
authoritative.

## 1. Separation of responsibilities

The package records and validates provenance and dependency structure. It does
not decide whether a domain theorem is true.

The library owns:

- canonical record kinds and lifecycle states;
- stable identifiers and deterministic field ordering;
- dependency edges and closure validation;
- validation of required provenance fields;
- the distinction between invalid, incomplete, bounded, and accepted records;
- consumer-supplied policy decisions represented as explicit results.

Consumers own:

- mathematical predicates and proof rules;
- the list of admissible external theorem families;
- domain-specific forbidden claims;
- certificate acceptance;
- hash-suite selection and commitment construction;
- whether a validated record is sufficient for a theorem or release decision.

In particular, the finite-mandlebrot-research restrictions on circle primitives and global
MLC-strength claims remain finite-mandlebrot-research policy. PSC's G1, concentration, renewal,
realization, and productivity boundaries remain PSC policy.

## 2. Record kinds

Every record has exactly one kind.

| Kind | Meaning | May close a dependency? |
| --- | --- | --- |
| `finite_computation` | Deterministic finite computation with replay metadata | Yes, only for the exact finite proposition named |
| `formal_derivation` | Locally checked rule applications with explicit premises | Yes, within the declared rule system |
| `imported_theorem` | External theorem with source, statement, hypotheses, and a checked use-site match | Yes, only after consumer policy accepts the import |
| `bounded_experiment` | Result over an explicitly enumerated finite domain | No general dependency; only its bounded proposition |
| `open_dependency` | Named proposition not proved or accepted | No |
| `countermodel` | Replayable witness refuting a named statement | Closes only the refuted statement negatively |
| `rejected_record` | Malformed, inconsistent, or policy-rejected input | No |

A bounded experiment must never be relabelled as a formal derivation or
imported theorem merely because its enumerated domain is large.

## 3. Common envelope

Every non-rejected record carries:

- `schema_id`: stable schema name;
- `schema_version`: positive integer;
- `record_id`: canonical identifier derived from the record-ID preimage defined in section 8;
- `kind`: one value from section 2;
- `claim_id`: stable consumer-owned claim identifier;
- `claim_text`: human-readable statement;
- `scope`: exact domain on which the claim is asserted;
- `dependencies`: ordered list of identity-bearing `DependencyEdge` records;
- `producer`: implementation and version that created the record;
- `payload_encoding`: canonical encoding identifier;
- `evidence`: ordered references needed for replay or source inspection.

Unknown schema versions, unknown record kinds, duplicate dependency
identifiers, noncanonical ordering, missing required fields, and identifier
mismatches reject the record.

Each `DependencyEdge` carries:

- `dependency_record_id`: the referenced record;
- `expected_claim_id`: the exact premise or proposition expected from it;
- `use_site_id`: the consumer-owned position at which that premise is used;
- `required_scope_relation`: the declared relation required between dependency
  scope and consumer scope;
- `required_outcome`: the validation outcome required by this use.

All five fields are identity-bearing. The validator must compare the referenced
record's claim, scope, and validation result with the edge instead of accepting
a structurally valid but unrelated record.

Display text, timestamps, filesystem paths, repository URLs, and diagnostic
rendering are not identity-bearing unless a schema explicitly declares them
so.

## 4. Kind-specific payloads

### 4.1 Finite computation

Required fields:

- executable identity and immutable source revision;
- input encoding and exact input digest;
- deterministic configuration;
- completeness boundary;
- resource-cap status;
- output encoding and exact output digest;
- replay result.

A capped, interrupted, skipped, or unavailable execution is incomplete. It is
never a passing computation and never a counterexample.

### 4.2 Formal derivation

Required fields:

- rule-system identifier and version;
- ordered rule applications;
- explicit premise identifiers;
- checked conclusion;
- checker identity and immutable source revision.

The checker must recompute dependency closure. A Boolean supplied by the
producer saying that all rules were checked is not sufficient.

### 4.3 Imported theorem

Required fields:

- source identifier and bibliographic locator;
- theorem statement or stable statement identifier;
- source hypotheses;
- consumer claim being supported;
- use-site domain facts;
- an explicit hypothesis-match result;
- preserved conclusion;
- non-inherited conclusions and leak boundary;
- consumer policy decision.

Source existence, hypothesis matching, and consumer admissibility are distinct
checks. A known source with unmatched hypotheses remains incomplete.

### 4.4 Bounded experiment

Required fields:

- finite domain definition;
- enumeration method;
- completeness statement for that finite domain;
- caps and skipped cases;
- exact summary and retained witnesses.

The record must name both the proposition established on the finite domain and
the stronger propositions it does not establish.

### 4.5 Open dependency

Required fields:

- exact missing proposition;
- downstream claims blocked by it;
- known partial results;
- accepted resolution classes.

An open dependency cannot be converted to accepted by dependency closure.

### 4.6 Countermodel

Required fields:

- exact statement refuted;
- canonical witness;
- replay procedure;
- successful replay result;
- scope showing that the witness satisfies the refuted statement's
  hypotheses.

A witness outside the hypotheses rejects rather than refutes.

## 5. Validation states

Validation returns exactly one state:

| State | Meaning |
| --- | --- |
| `accepted` | Structurally valid, complete for its declared scope, and accepted by consumer policy |
| `bounded` | Valid result whose authority is limited to its declared finite domain |
| `incomplete` | Well-formed but missing evidence, replay, hypothesis match, or dependency |
| `open` | Explicit unresolved dependency |
| `refuted` | Valid countermodel refutes the named statement within scope |
| `rejected` | Malformed, inconsistent, unknown-version, or policy-rejected record |

These states are not Booleans. Consumers must not collapse `bounded`,
`incomplete`, `open`, or `rejected` into false mathematical claims.

Every rejection has a stable reason code. Diagnostic prose is supplementary.

## 6. Dependency closure

Records form a finite directed acyclic graph for one validation invocation.
The validator must:

1. reject missing dependency identifiers;
2. reject cycles;
3. validate every dependency under the same schema and policy context;
4. verify each dependency's claim, scope, and outcome against its identity-bearing `DependencyEdge`;
5. propagate `rejected`, `incomplete`, and `open` without converting them
   into negative mathematical evidence;
6. reject an accepted general claim that depends only on a bounded experiment;
7. return the exact set of missing or unacceptable links.

Dependency order is identity-bearing and deterministic. If a consumer treats a
dependency collection as mathematically unordered, it must canonicalize by
record identifier before encoding.

## 7. Consumer policy interface

Domain policy is supplied as data or a typed callback whose result is recorded.
The portable interface distinguishes:

- `allow`;
- `deny(reason_code)`;
- `requires_more_evidence(missing_ids)`;
- `open_frontier(claim_id)`.

Policy must not mutate the record being checked. Policy identity and version
are part of the validation result.

The library ships no default that silently permits imported theorems or turns a
finite computation into certificate acceptance.

## 8. Canonical encoding

The encoding is versioned and domain-separated. Each field is encoded by a
declared scalar or aggregate codec; variable-length values are length-prefixed;
maps are prohibited unless their canonical key order is specified.

Canonical encoding and hashing are separate:

- the record-ID preimage is the canonical encoding of every identity-bearing
  envelope, dependency-edge, and payload field except `record_id` itself;
- `record_id` is the consumer-selected digest identifier of that preimage;
- the authoritative record encoding contains the preimage fields followed by
  `record_id`, allowing a validator to recompute the preimage and verify the
  identifier without circularity;
- the package may emit the preimage and authoritative record bytes and verify
  `record_id`;
- consumers select a hash suite and commitment protocol;
- changing a schema, codec, field order, or identity-bearing field changes the
  record identifier;
- a diagnostic renderer is never an encoding oracle.

A structurally well-formed record has canonical bytes and a verifiable
`record_id` even when validation yields `incomplete`, `open`, or
`bounded`; those states must remain addressable so dependency closure can
report and propagate the exact unacceptable link. A malformed construction
that cannot produce the common envelope is not a record, has no authoritative
encoding, and validates as `rejected`. A structurally well-formed record
rejected only by consumer policy retains its identity and records the policy
result separately.

## 9. Initial implementation boundary

The first Mojo implementation includes:

- record-kind and validation-state closed types;
- common envelope validation;
- identity-bearing dependency-edge and DAG validation;
- imported-theorem hypothesis-match records;
- bounded-experiment scope records;
- countermodel records;
- consumer-policy result carriers;
- deterministic encoding test vectors;
- positive, tamper, missing-dependency, cyclic-dependency, capped-computation,
  unmatched-hypothesis, and bounded-to-general negative tests.

It excludes:

- finite-mandlebrot-research theorem names and prohibited primitive lists;
- PSC conjecture names;
- cryptographic hash selection;
- certificate acceptance;
- network retrieval;
- trust in producer-supplied aggregate Booleans;
- proof-assistant verification.

## 10. Adoption gate

Extraction into its own repository is allowed only after:

1. the implementation is in the compiled Mojo CI closure;
2. record-ID preimage and authoritative encoding have deterministic golden vectors;
3. dependency cycles and missing links fail closed;
4. bounded evidence cannot satisfy a general claim;
5. imported theorem use requires a checked hypothesis match;
6. finite-mandlebrot-research and PSC each supply a distinct policy adapter in consumer code;
7. neither consumer changes any mathematical claim status during migration.

Until then, `kernel/mojo/theorem_kernel/mojo_theorem_kernel.mojo` remains a scaffold and must not be
described as an authoritative proof checker.
