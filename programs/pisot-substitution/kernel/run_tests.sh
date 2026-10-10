#!/usr/bin/env bash
# Run every Mojo regression test under tests/, and record what each one guards.
#
# One loop over tests/test_*.mojo, so a new test file is picked up by adding
# the file -- there is no chain of names to keep in step, and a forgotten entry
# cannot silently drop coverage. Every test runs even after a failure, so one
# run reports every broken contract, and the exit status is nonzero if any
# failed.
#
# Each test declares the ledger claim or the contract it guards
# (mojo_smoke/claims.mojo, vendored) and prints a receipt line when the declaration is
# reached. The receipts of the tests that *passed* are collected here into
# $CLAIM_RECEIPTS (default build/claim-receipts.tsv, repository-relative
# paths), which the `coverage` check of claim_governance.toml reads: a
# declaration no run reached guards nothing. The file is rewritten from empty
# on every run, so a stale receipt cannot survive a red suite.
set -uo pipefail
cd "$(dirname "$0")"

RECEIPTS=${CLAIM_RECEIPTS:-build/claim-receipts.tsv}
mkdir -p "$(dirname "$RECEIPTS")"
printf '# finite proof-test receipts 1\n' > "$RECEIPTS"
LOG=$(mktemp)
trap 'rm -f "$LOG"' EXIT

status=0
ran=0
failed=()
for test in tests/test_*.mojo; do
    ran=$((ran + 1))
    mojo run -I . -I tests "$test" 2>&1 | tee "$LOG"
    if (( ${PIPESTATUS[0]} == 0 )); then
        awk -v path="kernel/$test" '
            /^claim-receipt: /    { printf "%s\tclaim\t%s\n",    path, substr($0, 16) }
            /^contract-receipt: / { printf "%s\tcontract\t%s\n", path, substr($0, 19) }' "$LOG" >> "$RECEIPTS"
    else
        status=1
        failed+=("$test")
    fi
done

printf '\n%d Mojo test files run; receipts in %s.\n' "$ran" "$RECEIPTS"
if (( status == 0 )); then
    printf 'All passed.\n'
else
    printf 'FAILED: %s\n' "${failed[*]}"
fi
exit "$status"
