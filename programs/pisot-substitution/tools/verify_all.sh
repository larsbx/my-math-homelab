#!/usr/bin/env bash
# Run every verification layer. Each layer is skipped, with a notice, if its
# toolchain is absent -- so a partial environment reports honestly rather than
# passing vacuously.
set -uo pipefail
cd "$(dirname "$0")/.."
ROOT=$(pwd)
status=0
ran=0
skipped=0

section() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }
ok()      { printf '  \033[32mPASS\033[0m  %s\n' "$1"; ran=$((ran+1)); }
bad()     { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; status=1; ran=$((ran+1)); }
skip()    { printf '  \033[33mSKIP\033[0m  %s (%s)\n' "$1" "$2"; skipped=$((skipped+1)); }

section "Source provenance"
PROV_TMP=$(mktemp -d)
git -C "$PROV_TMP" init -q
if sha256sum -c sources/issue-45/SHA256SUMS \
   && git -C "$PROV_TMP" apply \
        "$ROOT/sources/issue-45/0001-Seed-P1-A-concentration-program.patch" \
        "$ROOT/sources/issue-45/0002-Audit-v34-against-the-concentration-gate.patch" \
   && cmp -s sources/issue-45/p1a-concentration-aux-b-program.md \
        "$PROV_TMP/docs/p1a-concentration-aux-b-program.md" \
   && cmp -s sources/issue-45/p1a-v34-concentration-audit.md \
        "$PROV_TMP/docs/p1a-v34-concentration-audit.md"; then
    ok "Issue #45 snapshots match preserved source commits"
else
    bad "Issue #45 source provenance"
fi
if sha256sum -c sources/minimal-bad-scc/SHA256SUMS; then
    ok "minimal-bad-SCC historical proposal snapshot is intact"
else
    bad "minimal-bad-SCC proposal source provenance"
fi
if python3 tools/vendoring/check_vendored_sync.py; then
    ok "vendored Mojo packages match the commits pinned in vendored.toml"
else
    bad "vendored package drift (vendored.toml)"
fi
if python3 tools/make_ledger.py --check >/dev/null; then
    ok "generated ledger surfaces are current (tools/make_ledger.py --check)"
else
    bad "generated ledger surfaces are stale (run: python3 tools/make_ledger.py)"
fi
if python3 tools/make_math_catalogue.py --check >/dev/null; then
    ok "generated mathematical-object catalogue is current"
else
    bad "mathematical-object catalogue drift (run: python3 tools/make_math_catalogue.py)"
fi
if python3 tools/make_proof_bank.py --check; then
    ok "complete proof-bank inventory and Lean pins are current"
else
    bad "proof-bank drift or incomplete Lean import coverage"
fi
if python3 tools/polyglot_envelope/render.py --check >/dev/null; then
    ok "the polyglot envelope is the rendering of its vendored template"
else
    bad "polyglot envelope drift (run: python3 tools/polyglot_envelope/render.py)"
fi
if python3 tools/check_manuscript_source.py; then
    ok "manuscript sources are intact LaTeX and PDF"
else
    bad "manuscript source integrity"
fi
if python3 tools/check_markdown_source.py; then
    ok "theorem/research Markdown contains no unexpected C0 controls"
else
    bad "theorem/research Markdown source integrity"
fi
if python3 tools/check_hit_witness_evidence.py; then
    ok "committed finite-box hit-witness exports match their digests and stable labels"
else
    bad "hit-witness export provenance"
fi
if PYTHONPATH=tools python3 -m claim_governance.cli --root . >/dev/null; then
    ok "status surfaces agree with the claim ledger (claim_governance.toml)"
else
    bad "claim governance audit (run: PYTHONPATH=tools python3 -m claim_governance.cli --root .)"
fi
if [[ ${1:-} == provenance ]]; then
    exit "$status"
fi

section "Mojo canonical exact implementation"
if command -v pixi >/dev/null 2>&1; then
    cd "$ROOT/kernel"
    if pixi run test; then
        ok "canonical Mojo regression tests"
    else
        bad "canonical Mojo regression tests"
    fi
    cd "$ROOT"
    # The suite has now written kernel/build/claim-receipts.tsv, so the coverage
    # check above re-runs with the run behind it: a claim whose only test body
    # was never reached is uncovered, not credited.
    if PYTHONPATH=tools python3 -m claim_governance.cli --root . --check coverage >/dev/null; then
        ok "every ledger claim the policy requires guarded has a passing test (receipts)"
    else
        bad "test-claim coverage against the run receipts (PYTHONPATH=tools python3 -m claim_governance.cli --root . --check coverage)"
    fi
    cd "$ROOT/kernel"
    if pixi run verify; then
        ok "certificate checks (verify.mojo)"
    else
        bad "certificate checks (verify.mojo)"
    fi

    census_out=$(pixi run mojo run -I . census.mojo 2>&1)
    if grep -Eq 'PIP specimens \(images of length <= 3\):[[:space:]]+4554' <<<"$census_out" \
       && grep -Eq 'B_sigma construction terminated:[[:space:]]+4554.*capped:[[:space:]]+0' <<<"$census_out" \
       && grep -Eq 'productive:[[:space:]]+4554.*non-productive:[[:space:]]+0' <<<"$census_out"; then
        ok "alphabet-3 census (4554 PIP; 0 capped; 0 nonproductive)"
    else
        bad "alphabet-3 census regression"
        tail -20 <<<"$census_out"
    fi
    cd "$ROOT"
else
    skip "Mojo layer" "pixi not installed; curl -fsSL https://pixi.sh/install.sh | bash"
fi

section "Python secondary reference/oracle"
if command -v pytest >/dev/null 2>&1; then
    pytest_out=$(pytest -q 2>&1)
    if [ $? -eq 0 ]; then
        ok "pytest oracle regressions"
    else
        bad "pytest oracle regressions"
        tail -20 <<<"$pytest_out"
    fi
else
    skip "pytest oracle" "not installed; pip install -e .[dev]"
fi

section "TLA+ models"
JAR="${TLA_TOOLS:-$ROOT/proof/tla/tla2tools.jar}"
if command -v java >/dev/null 2>&1 && [ -f "$JAR" ]; then
    if TLA_TOOLS="$JAR" ./proof/tla/check.sh; then ok "all models"; else bad "some model"; fi
else
    skip "TLA+ layer" "need java and tla2tools.jar (set TLA_TOOLS, or download into proof/tla/)"
fi

section "Lean 4 proofs"
if command -v lake >/dev/null 2>&1; then
    if ./tools/check_lean.sh; then
        ok "lake build + complete compiled-declaration axiom audit"
    else
        bad "Lean proof bank (build, inventory or axiom audit)"
    fi
else
    skip "Lean layer" "lake not on PATH; run ./tools/setup_lean.sh and add ~/.elan/bin to PATH"
fi

printf '\n%d checks run, %d skipped. ' "$ran" "$skipped"
if [ $status -eq 0 ]; then printf 'All run checks passed.\n'; else printf 'FAILURES above.\n'; fi
exit $status
