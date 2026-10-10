# Procesi proof memory measurement — 2026-10-06

COMPUTED: replacing the exhaustive mod-3 Procesi proof materially reduces the
`Pseudocharacter` process peak. The mathematical statements and executable
predicates are unchanged.

| Measurement | Before | After |
|---|---:|---:|
| `Pseudocharacter` maximum process RSS | 10,930,900 KiB (10.42 GiB) | 553,464 KiB (0.53 GiB) |
| `Pseudocharacter` build wall time | 67.11 s | 0.74 s |
| Largest process in the clean build | 10.42 GiB (`Pseudocharacter`) | 3.99 GiB (`BrandtCertificates`) |
| Serialized clean build wall time | 718.81 s | 652.01 s |

The module peak fell 94.9%; the clean build's largest-process peak fell
61.7%. These are single-run process peaks, not aggregate concurrent memory.

## Protocol and provenance

[CI run 37433371677](https://github.com/larsbx/langlands-lab/actions/runs/37433371677)
built baseline `7630927a8378b57a0fc0e7306d4402af44105103` and candidate
`4c168b639bcc6e98c1172ea3d15fcb281638b4fd` sequentially on the same runner
(4 logical processors, AMD EPYC 9V74 80-Core Processor, 16,373,452 KiB RAM), using
Lean 4.34.1, commit `5045d0056413266e57c625dcd7c365b10e377c52`.
Each checkout began with `lake clean`; all 46 local modules were then built in
import order, followed by the default `lake build` target and `Audit.lean`.
Linux `wait4` recorded each build's largest child-process RSS. Every build exited
successfully. Only `Pseudocharacter` differed among the 46 proof-source hashes.

The reproduction command, run once per checkout on the same machine, is:

```sh
python3 tools/benchmark_lean_memory.py --root CHECKOUT --output NEW_OUTPUT_DIRECTORY
```

The script is supplied from the candidate when measuring the baseline. It
preserves source hashes, module logs, raw integer timings/RSS, and audit output.
[Exact measurements](procesi-memory-2026-10-06.json) retain the per-module data and
artifact digest. The temporary CI experiment workflow was removed after the run.
These serialized timings do not measure Lake's default parallel wall time and
are separate from PR #23's measurements on another machine.

## Proof and audit boundaries

`procesi_GL2_F3 : Mat2.procesiHolds 3 = true` now uses
`M2.procesi (isCSR_fin 3)` and `List.all_eq_true`. A kernel-decided conversion on
3⁶ scalar tuples bridges the subtraction-free identity to the signed expression;
it no longer evaluates 48³ matrix triples. `procesi_GL2_F2` still independently
checks all 6³ triples, and Python still checks both groups exhaustively.

All 20 declaration signatures in `Pseudocharacter.lean` are unchanged.
`Audit.lean` and its 64 entries are byte-identical; both audits have exactly the
existing global axiom set `propext`, `Quot.sound`. The sole audit-output change is
`procesi_GL2_F3`: formerly axiom-free, it now inherits `propext`, `Quot.sound` from
the generic theorem. No `Classical.choice`, `sorryAx`, or `ofReduceBool` occurs.
The pseudocharacter and parameter claims, the remaining imported converse,
the canonical Python kernel, and the generated certificate data are unchanged.

CI run [37433371543](https://github.com/larsbx/langlands-lab/actions/runs/37433371543)
passed the pinned estate audit, all 647 Python tests, and all three Lean-gate tests
(build, 64-entry axiom audit, exported-data freshness) on the measured candidate.
