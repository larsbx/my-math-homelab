# Agent policy

Follow [`docs/METHODOLOGY.md`](docs/METHODOLOGY.md): phases G0–G7 and rules
R1–R7. In short:

- **Mojo is canonical.** New executable mathematics lands in `kernel/sadic/`
  with a regression test `kernel/tests/test_*.mojo` that declares the claim or
  contract it guards (`mojo_smoke.claims`). The exact Python oracle in
  `reference/sadic_reference/` is written independently and pinned by
  `tests/`. Extend `kernel/vectors.mojo` and `tools/cross_check.py` together.
- **Test first.** Write the oracle test and the Mojo test before the kernel.
- **Exact or labelled.** No floating point in `kernel/` or the oracle
  (`claim_governance.toml` numerics rules). Overflow raises; a capped or failed
  run is inconclusive.
- **Statuses move together.** A status change goes to `CLAIMS.md` and
  `claim_governance.toml` in one commit. A literature statement is imported
  only after `docs/literature-gate-*.md` marks it *verified*.
- **No local patches to vendored packages.**

Checks before pushing:

```bash
python3 tools/vendoring/check_vendored_sync.py
PYTHONPATH=tools python3 -m claim_governance.cli --root .
PYTHONPATH=reference python3 -m pytest -q tests
(cd kernel && pixi run test && pixi run vectors > build/vectors.txt) && python3 tools/cross_check.py kernel/build/vectors.txt
PYTHONPATH=tools python3 -m claim_governance.cli --root . --check coverage
```
