# C1 proof state

This directory is the canonical declarative source for the repository's C1
claim/proof state.

`records.toml` owns:

- record statements and kinds;
- scaffolded/open status reasons;
- dependency edges;
- the final C1 root dependency set;
- current priority and next blocks;
- final-role and next-action text;
- final-evidence exclusions;
- status labels used by generated surfaces.

`tools/make_ledger.py` owns mechanism only: it validates this data, computes
identity-bearing proof records, writes `ledger.json`, and regenerates the Mojo,
Markdown, claim-governance, TLA+, and relationship-graph projections.

Changing a path or renderer must not change a record's mathematical status.
Changing `records.toml` is therefore a research-state change and should be
reviewed as such.

The current repository identity value in the ledger is preserved by this
migration so the generated surfaces remain equivalent to their pre-migration
state. Repository-identity cleanup is a separate migration concern.
