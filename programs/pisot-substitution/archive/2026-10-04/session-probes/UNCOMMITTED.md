# Outputs pinned but never committed

Forty of this session's outputs (every `outputs/*.log` and `outputs/rerun_*.out`
named in `README.md`) were pinned when the archive was made but never committed:
the repository-wide `*.log` and `*.out` ignore rules for LaTeX by-products
dropped them. Their digests are kept in `SHA256SUMS.uncommitted`, so a recovered
copy can be checked and its line moved back to `SHA256SUMS`, which pins only
the files present. `.gitignore` now exempts `archive/` from those rules.
