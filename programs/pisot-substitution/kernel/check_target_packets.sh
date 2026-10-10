#!/usr/bin/env bash
# Replay archived Mojo outputs and verify the driver boundary. No math here.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
mojo build -I . target_aware_bpa.mojo -o build/target-aware-bpa
driver=build/target-aware-bpa
fixtures=../evidence/target-aware-bpa-2026-10-02
for fixture in real-secondary non-pisot-strict gf-actual; do
    case "$fixture" in
        real-secondary) key=1/02/202 ;;
        non-pisot-strict) key=1/012/1 ;;
        gf-actual) key=1/2/021 ;;
    esac
    "$driver" --sigma "$key" --dump > "build/target-$fixture.jsonl"
    cmp "$fixtures/$fixture.jsonl" "build/target-$fixture.jsonl"
done
"$driver" --replay 396,820 --cycle > build/target-cycle-replay.jsonl
grep -Eq '"record":"requested_replay"' build/target-cycle-replay.jsonl
"$driver" --potential linear --weights 1 0 -1 --strict > build/target-linear.jsonl
for budget in state length packet edge; do
    if "$driver" "--$budget-cap" 1 > "build/target-$budget-cap.log" 2>&1; then
        echo "ERROR: exhausted $budget cap succeeded" >&2
        exit 1
    fi
    if grep -Eq '"record":"header"|"record":"summary"' "build/target-$budget-cap.log"; then
        echo "ERROR: exhausted $budget cap emitted a complete verdict" >&2
        exit 1
    fi
done
if "$driver" --sigma x/1/2 > build/target-invalid.log 2>&1; then
    echo "ERROR: malformed substitution succeeded" >&2
    exit 1
fi
if "$driver" --replay 0,1 --cycle > build/target-invalid-replay.log 2>&1; then
    echo "ERROR: invalid cycle replay succeeded" >&2
    exit 1
fi
echo "PASS target-aware JSONL reproduction, cycle replay, potentials, and fail-closed CLI caps"
