# Superseded completion snapshots

The September 11 and September 14 completion ledgers are retained verbatim
for their historical observations and audit citations. They were moved out
of the live documentation on October 6, 2026. `SHA256SUMS` pins their bytes.

The source tree before this cleanup is
[`main@c2bd9a0`](https://github.com/larsbx/pisot-substitution-conjecture-research/tree/c2bd9a09555a91c6ebf65e3b477121c9dc5a554b).
Paths and status language inside the snapshots describe their historical
trees. They are not current status checks or proof sources.

Current status lives in the claim/source map, conjecture ledger, proof ladder
and research roadmap under `docs/`. `tools/make_ledger.py` binds its status
checks to those live surfaces; the latest dated snapshot remains
`docs/completion-ledger-2026-10-02.md`.

Verify from the repository root:

```sh
sha256sum -c archive/2026-10-06/status-snapshots/SHA256SUMS
```
