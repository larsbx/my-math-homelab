# Contributing

Read ESTATE.toml, ARCHITECTURE.md, proof/claims.toml, and docs/dossier.md.

Run:

    python -m pytest
    python tools/check_claims.py

A bounded test is not a theorem. A congruence shadow is not independent
leverage without independent input. Reduction to an open special case is
progress, not a solution. Failed proof steps are WITHDRAWN.

Every PR must fill in What this does not establish.

For experiment changes, also run the committed replay command and report its
parameters and cap. The seed (9,38) is finite transient evidence only.

The ledger is authoritative. Each dossier claim must use exactly one heading
of the form "### PV-CLAIM-ID — STATUS" matching proof/claims.toml; an ID
mentioned in prose, a table, or an example is not a claim-status record.

CI must also pass the hash-pinned estate layout audit. Adjust the declared
layout when adding an authority plane; do not weaken the external audit.
