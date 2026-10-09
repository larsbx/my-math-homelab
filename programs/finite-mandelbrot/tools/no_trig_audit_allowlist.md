# No-Trig Audit Allowlist

The lexical audit is intentionally conservative. This file records the intended exceptions.

Allowed explanatory policy locations:

- `docs/rational-trigonometry-policy.md`

Allowed implementation locations:

- none

Core source files should avoid analytic circular-function spellings even in comments where practical, because the audit is designed to be simple enough for CI and coding agents to trust.
