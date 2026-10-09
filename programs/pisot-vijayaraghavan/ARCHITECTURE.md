# Repository architecture

This repository adopts the estate authority model used by
larsbx/langlands-lab and the exact-arithmetic discipline of
larsbx/finite-math-kernels.
ESTATE.toml is the machine-readable source of layout and authority.

The ordering rule is:

~~~text
claim authority -> mathematical concern -> implementation language
~~~

## Exact kernel — kernel/

Canonical executable identities use exact arithmetic only.
pv_exact.py supplies nearest-integer E-sequence generation, Bareiss/Hankel
determinants, gcd transitions, freshness checks, and canonical period-four
detectors. pv/identities.py retains the explicit H3, transport, gcd-product,
and scaling interfaces. Conformance tests check agreement between their
shared identities.
pv/hankel.py adds exact rational Hankel instrumentation, the strict size
calculation, and local recurrence candidates. Its finite outputs do not
certify the infinite-tail hypotheses of the manuscript theorem.
pv/reconstruction.py supplies exact finite telescoping and normalized
defect identities, retaining terminal terms for arbitrary trial parameters.
It neither estimates an infinite limit nor certifies a witness from a prefix.

## Claim state — proof/

proof/claims.toml is the sole authoritative claim ledger.
docs/dossier.md explains each claim and its boundary; its claim headings
must match the ledger one for one, including statuses.

## Evidence — tests/

Finite regressions support the exact implementation and enforce claim-status
consistency. They do not prove universal mathematics by enumeration.

## Experiments — experiments/

Non-authoritative frontier searches report caps, skipped half-integer ties,
maximal run intervals, and replayable exact data. The seed $(9,38)$ supplies
transient period-four evidence, not an eventual-tail theorem.

## Exposition and tooling

docs/ contains the dossier, roadmap, frontier, references, and audits.
The exponential-window, normalized-defect, and square-root notes supply
the written proofs. The square-summability route is an explicitly imported
dependency with a primary citation, separate from the proved corollary.
tools/ enforces repository consistency.
The CI policy job verifies the manifest against the pinned external estate
audit without vendoring or weakening it.

The first bounded-state target is the two-state no-two-step-return pattern
$(A,A,B,B,\ldots)$. Conditional three-state calculations remain deferred.
