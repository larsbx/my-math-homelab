#!/usr/bin/env bash
# Run every repository gate and report each as PASS, FAIL or SKIP.
#
#   scripts/verify_all.sh            all groups
#   scripts/verify_all.sh python     one group: python | lean | tla
#   scripts/verify_all.sh fast       the seconds-long subset of python (the commit hook runs it)
#
# Exit status: 0 when every selected gate ran and passed; 1 when any gate failed;
# 3 when none failed but some were skipped (a skipped gate is not a passed gate).
# CI runs the groups it has toolchains for and must see 0.
set -uo pipefail
cd "$(dirname "$0")/.."

groups=("${@:-python lean tla}")
groups=(${groups[*]})
failed=0 skipped=0

gate() {   # gate NAME COMMAND...
    local name=$1; shift
    if out=$("$@" 2>&1); then
        printf 'PASS  %s\n' "$name"
    else
        printf 'FAIL  %s\n%s\n' "$name" "$out" | sed '2,$s/^/      /'
        failed=$((failed + 1))
    fi
}

skip() {   # skip NAME REASON
    printf 'SKIP  %s (%s)\n' "$1" "$2"
    skipped=$((skipped + 1))
}

fast_gates() {
    gate "programme registries" python scripts/check_registry.py
    gate "vendored packages match their pins" python vendor/vendoring/check_vendored_sync.py
    gate "ESTATE.toml vendoring pins" python tools/estate_pins.py
    gate "ledger surfaces are generated" env PYTHONPATH=vendor \
        python -m proof_records.generate_ledgers research/ledger.json --claims claim_governance.toml --check
    gate "claim governance (incl. test coverage)" env PYTHONPATH=vendor python -m claim_governance.cli
}

python_gates() {
    gate "F3 structure tensor provenance" python scripts/check_f3_table.py
    fast_gates
    gate "unit and regression tests" python -m unittest discover -s tests
    for census in experiments/n2/*.py; do
        grep -q -- '--check' "$census" && gate "census $(basename "$census" .py) is current" python "$census" --check
        grep -q -- '--replay' "$census" && gate "census $(basename "$census" .py) certificates replay" python "$census" --replay
    done
    gate "paper tables are generated" python paper/associator-defects/make_tables.py --check
}

lean_gates() {
    if ! command -v lake >/dev/null; then
        skip "Lean oracle" "lake not on PATH; the lean-oracle workflow runs it"
        return
    fi
    gate "Lean oracle builds and self-checks" sh -c 'lake build && lake exe oracle-selfcheck'
    gate "oracle mutation suite" python scripts/lean_mutation_suite.py --check
    gate "Lean F3 export matches the Python table" sh -c \
        'lake exe export-f3 > /tmp/novelty-f3.json && python scripts/check_f3_table.py --lean-export /tmp/novelty-f3.json'
}

tla_gates() {
    if [ -z "${TLA2TOOLS:-}" ] || ! command -v java >/dev/null; then
        skip "TLC ledger models" "set TLA2TOOLS to tla2tools.jar and install java"
        return
    fi
    # TLC resolves EXTENDS from the spec's directory and TLA-Library (absolute), so it runs
    # inside tla/ with the vendored ProofArchitecture on the library path.
    local jar lib meta
    jar=$(realpath "$TLA2TOOLS"); lib=$(realpath vendor/proof_records); meta=$(mktemp -d)
    for cfg in tla/MCNoveltyLedger*.cfg; do
        local model; model=$(basename "$cfg" .cfg)
        gate "TLC $model holds" sh -c 'cd tla && java -XX:+UseParallelGC -DTLA-Library="$1" -cp "$2" tlc2.TLC \
            -metadir "$3/$4" "$4" | grep -q "No error has been found"' sh "$lib" "$jar" "$meta" "$model"
    done
    rm -rf "$meta"
}

for g in "${groups[@]}"; do
    case $g in
        python) python_gates ;;
        fast) fast_gates ;;
        lean) lean_gates ;;
        tla) tla_gates ;;
        *) echo "unknown gate group: $g" >&2; exit 2 ;;
    esac
done

[ "${groups[*]}" = fast ] ||
    echo "estate layout audit: runs in the policy job of .github/workflows/verify.yml (see ARCHITECTURE.md)"
if [ $failed -gt 0 ]; then echo "FAILED: $failed gate(s)"; exit 1; fi
if [ $skipped -gt 0 ]; then echo "INCOMPLETE: $skipped gate(s) skipped, none failed"; exit 3; fi
echo "ALL GATES PASSED"
