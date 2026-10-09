# Growth Bridge loop-gain oracle scaffold

## Role

This repository provides independent, non-authoritative differential checks for the post-PSC Growth Bridge programme.

It never proves the Growth Bridge theorem, accepts a PSC certificate, or changes theorem status.

## Input contract

Consume a deterministic fixture exported by the PSC repository containing:

- graph/component identifier;
- ordered vertices;
- occurrence-labelled directed edges;
- exact edge-gain coordinates in a declared arithmetic basis;
- optional canonical module presentation produced by Mojo.

No floating approximation is allowed in the equality path.

## Oracle questions

The first oracle should answer only finite algebra questions:

1. Is the supplied cycle basis valid?
2. What are the exact gains of those cycles?
3. What subgroup/module do those gains generate?
4. Does an independently chosen cycle basis generate the same subgroup/module?
5. Does the Julia presentation agree with the canonical Mojo presentation?

Return only the repository-standard verdicts:

- `agrees`
- `disagrees`
- `inconclusive`
- `oracle_error`

## Suggested implementation

Use Julia exact integers/rationals and standard integer normal-form routines where suitable. Keep the code independent of the Mojo algorithm so agreement is meaningful.

A later exploratory layer may inspect embeddings or characters, but that must remain separate from the exact finite-module oracle.

## Registry entry

The eventual oracle registry entry should declare:

- domain owner: `larsbx/pisot-substitution-conjecture-research`;
- authority: advisory;
- input schema version;
- canonical checker binding in PSC;
- fixture provenance;
- supported arithmetic coordinate types.

## Negative controls

- corrupt one edge gain and require `disagrees`;
- permute cycle basis while preserving its span and require `agrees`;
- delete an edge referenced by a cycle and require `oracle_error` or `inconclusive`;
- pass an unsupported arithmetic basis and fail closed.

This scaffold intentionally stops before any spectral or eigenvalue claim.
