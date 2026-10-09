#!/usr/bin/env bash
# Run every TLA+ model and assert its expected outcome.
#
# Usage: TLA_TOOLS=/path/to/tla2tools.jar ./check.sh
set -uo pipefail
cd "$(dirname "$0")"
JAR="${TLA_TOOLS:-tla2tools.jar}"
if [ ! -f "$JAR" ]; then
    echo "tla2tools.jar not found. Set TLA_TOOLS or download it:"
    echo "  curl -L -o tla2tools.jar https://github.com/tlaplus/tlaplus/releases/latest/download/tla2tools.jar"
    exit 2
fi

# model : expected
# HOLD means no invariant violation. Otherwise the named invariant must be
# violated, so TLC's counterexample trace demonstrates the positive derivation
# (BPA models only; the generated ledger models are all HOLD).
MODELS=(
    "MCTribonacci:HOLD"
    "MCFlippedTribonacci:HOLD"
    "MCSmith:HOLD"
    "MCNonProductive:Productive"
    # Generated proof-dependency models (tools/make_ledger.py): every one must
    # hold. Each asserts <Name>NotEstablished for the results its assumptions
    # leave unreachable and the liveness property that its Reachable set is
    # eventually established, so the positive derivations (PDSOverlapRoute
    # under OverlapProductivity and the imported density bridge, G1OverlapRoute
    # and canonical G1 under AllSeedOverlapProductivity, PDS under G1 and SCC Producer,
    # LoadBearingSCC under G1, SpectralBlackBox unconditionally) are read off
    # the Reachable sets rather than off expected violations.
    "MCLedgerOpen:HOLD"
    "MCLedgerImports:HOLD"
    "MCLedgerG1AndProducer:HOLD"
    "MCLedgerG1Only:HOLD"
    "MCLedgerG1AndC4:HOLD"
    "MCLedgerRenewalGateAssumed:HOLD"
    "MCLedgerSpectralGateAssumed:HOLD"
    "MCLedgerOverlapGateAssumed:HOLD"
    "MCLedgerAllSeedOverlapGateAssumed:HOLD"
    "MCLedgerAllSeedStrictZipperGateAssumed:HOLD"
    "MCLedgerFormalProductivityGateAssumed:HOLD"
)

fail=0
for entry in "${MODELS[@]}"; do
    model="${entry%%:*}"
    expect="${entry##*:}"
    rm -rf states
    out=$(timeout 600 java -XX:+UseParallelGC -cp "$JAR" tlc2.TLC "$model" 2>&1)
    if [ "$expect" = "HOLD" ]; then
        if grep -q "No error has been found" <<<"$out"; then
            echo "[PASS] $model  all invariants hold"
        else
            echo "[FAIL] $model  expected no violation"; echo "$out" | tail -5; fail=1
        fi
    else
        if grep -q "Invariant $expect is violated" <<<"$out"; then
            echo "[PASS] $model  $expect violated as expected"
        else
            echo "[FAIL] $model  expected $expect to be violated"; echo "$out" | tail -5; fail=1
        fi
    fi
done
rm -rf states
exit $fail
