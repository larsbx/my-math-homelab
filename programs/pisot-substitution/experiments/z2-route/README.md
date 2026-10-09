# Unbounded `Z_2` route: exploratory drivers

**Status:** exploratory scratch, kept for reproducibility. Nothing here is
cited by a proof or a census, and these drivers have no regression tests.
The canonical code is `kernel/odd_letter_family_certificate.mojo`.
Side-notes ledger, 2026-10-07 ("the z_floor cover run") and the q-lift
entries after it record what they measured.

| File | What it runs |
| --- | --- |
| `onepat.mojo` | `cover_pattern_guided` on one run pattern, in z_floor mode, verbose: `onepat s delta floor budget l1 open1 l2 open2` (`l1`, `l2` like `zy`, `-` for empty, `open` 0/1) |
| `zruns.mojo` | every fully revealed pattern with `w_1` (or `u`) of at most `r1` runs and `w_2` of at most `r2`, every run length symbolic: `zruns s delta floor r1 r2 budget [qlift]` (`qlift` 1 runs the cover over the product coordinates `q_j = n_j e`); `... budget count` prints the number of patterns; `... budget at i` covers pattern `i` alone, plain z_floor first and the q-lift only if the plain cover leaves a region open, ending with `VERDICT plain`, `qlift` or `open`; `... budget at i plain` or `... at i qlift` runs that one stage alone (`VERDICT open` when it leaves a region open) |
| `sweep.sh` | `sweep.sh BIN s delta floor r1 r2 budget plain_secs qlift_secs`: for every pattern runs `BIN ... at i plain` under `timeout plain_secs` and, if that leaves a region open or times out, `BIN ... at i qlift` under `timeout qlift_secs`, so a pattern whose plain cover times out still gets the q-lift; one line per pattern (`closed-by-plain`, `closed-by-qlift`, `open`, `timeout`, with each stage's regions, open count and seconds, or `killed`), then a summary |
| `boxtime.mojo` | one member `w_1 = z^a y^b`, `w_2 = y^(b+2+e) z^(a+1)` of the `s = −1` leaf `zy \| yz`, timed under the box automaton (`boxtime a b e box`) or `coincidence_level` (`boxtime a b e lvl`); figures in `docs/audit-finite-regime-advice-2026-10-08.md` |

Build from `kernel/`:

```sh
pixi run mojo build -I . ../experiments/z2-route/zruns.mojo -o /tmp/zruns
../experiments/z2-route/sweep.sh /tmp/zruns -1 -2 4 4 4 5000 300 600
```
