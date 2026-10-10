# Exact-arithmetic allowlist

Modules permitted to contain floating-point types or decimal literals in the
kernel scope. Every entry must be a `QUARANTINED` row of
`docs/exact-arithmetic-binding.md`, and every `QUARANTINED` row must be listed
here; `tools/audit_exact_arithmetic.py` fails on either mismatch.

**The list is empty.** This repository has never had a floating-point
substrate. An entry appearing here is a regression to explain, not a
convenience.
