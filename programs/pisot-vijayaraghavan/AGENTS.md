# Agent policy — PV problem research

This repository studies the classical PV problem through exact integer
dynamics, Hankel determinants, gcd normalizations, and controlled experiments.
It is a research estate, not a theorem announcement.

**Canonical arithmetic:** Python integers and fractions.Fraction.
**Research rule:** computations are evidence, never theorem promotion.

## Read first

- README.md
- ESTATE.toml
- ARCHITECTURE.md
- proof/claims.toml
- docs/dossier.md
- docs/roadmap.md
- docs/audit/2026-10-05-thread-audit.md

## Gate

Before describing a change as finished, run:

~~~bash
python -m pytest
python tools/check_claims.py
~~~

The CI policy job must also pass the pinned estate layout audit.
For experiment changes, run the relevant experiment with committed parameters
and report the exact command and cap.

## Claim statuses

proof/claims.toml is authoritative. Each dossier claim uses exactly one
heading of the form "### PV-CLAIM-ID — STATUS", matching the ledger status.

- **PROVED** — proof written and surviving the current audit;
- **COMPUTED** — exact finite computation only;
- **IMPORTED** — external theorem used without proof here;
- **CANDIDATE** — proof candidate with a named obligation remaining;
- **HEURISTIC** — model or asymptotic prediction;
- **OPEN** — unresolved target;
- **WITHDRAWN** — an invalid argument retained as an explicit non-claim.

Earlier bootstrap IDs are mapped in the dossier. Their DERIVED and PROVISIONAL
labels do not form a second status ledger.

## Standing prohibitions

- Never describe PV as solved or promote bounded computation.
- No floating point in kernel/ or proof-relevant tests.
- Do not infer recurrence from one moving vanishing Hankel minor.
- Do not reuse a WITHDRAWN argument, including the invalid limsup-splitting
  proof of Hankel-profile concavity.
- Do not assume no-two-step-return requires three gcd states: two states admit
  $(A,A,B,B,\ldots)$.
- Do not describe the transport congruence as independent leverage past the
  square-root threshold.
- Keep periodic three-state calculations explicitly conditional.
- Do not claim large fresh-prime mass from local freshness alone.

Every PR must state what it does not establish. The current bounded-state
frontier is docs/frontier-period4.md.
