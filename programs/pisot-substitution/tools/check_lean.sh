#!/usr/bin/env bash
# Never credit locally cached dependency artifacts, even with matching metadata.
set -euo pipefail
PSC_ROOT=$(cd "$(dirname "$0")/.." && pwd -P)
PSC_VERIFY_TMP=$(mktemp -d)
PSC_AUDIT_LOG="$PSC_VERIFY_TMP/audit.log"
trap 'rm -rf "$PSC_VERIFY_TMP"' EXIT
python3 "$PSC_ROOT/tools/make_proof_bank.py" --check \
    --prepare-audit-workspace "$PSC_VERIFY_TMP/proof/PscVerif"
# Bootstrap the pinned cache tool from clean sources. Its downloaded artifacts
# come from the fixed upstream source-hash namespace into a new empty cache;
# neither local .olean/.hash/.trace nor local Lake configuration is copied.
for PSC_ENV_VAR in "${!LEAN_@}" "${!LAKE_@}" "${!MATHLIB_CACHE_@}"; do
    if [[ -n "$PSC_ENV_VAR" ]]; then unset "$PSC_ENV_VAR"; fi
done
# Disable Lake's system configuration and artifact store as well as barrels.
export LAKE_CONFIG="" LAKE_CACHE_DIR="" LAKE_ARTIFACT_CACHE=false LAKE_RESTORE_ARTIFACTS=false
export MATHLIB_CACHE_DIR="$PSC_VERIFY_TMP/download-cache"
export MATHLIB_CACHE_GET_URL="https://cache.mathlib.org/mathlib4-master"
cd "$PSC_VERIFY_TMP/proof/PscVerif"
PSC_TOOLCHAIN=$(cat lean-toolchain)
PSC_RELEASE=${PSC_TOOLCHAIN#leanprover/lean4:v}
run_pinned_lake() { elan run "$PSC_TOOLCHAIN" lake "$@"; }
PSC_LEAN_VERSION=$(elan run "$PSC_TOOLCHAIN" lean --version)
PSC_LAKE_VERSION=$(run_pinned_lake --version)
if [[ "$PSC_LEAN_VERSION" != "Lean (version $PSC_RELEASE,"* ]] \
   || [[ "$PSC_LAKE_VERSION" != *"(Lean version $PSC_RELEASE)" ]]; then
    echo "Lean/Lake executable version does not match the pinned release $PSC_RELEASE" >&2
    exit 1
fi
printf '%s\n%s\n' "$PSC_LEAN_VERSION" "$PSC_LAKE_VERSION"
check_fresh_pins() {
    python3 - "$PSC_ROOT" "$PSC_VERIFY_TMP" <<'PY'
import pathlib, sys
sys.path.insert(0, str(pathlib.Path(sys.argv[1]) / "tools"))
from make_proof_bank import check_pins
check_pins(pathlib.Path(sys.argv[2]), require_packages=True)
PY
}
# Load the manifest and clone dependencies before compiling the cache tool.
run_pinned_lake --no-cache env true
check_fresh_pins
run_pinned_lake --no-cache exe cache get
run_pinned_lake --no-cache build PscVerif
check_fresh_pins
run_pinned_lake --no-cache env lean ProofBankAudit.lean | tee "$PSC_AUDIT_LOG"
python3 "$PSC_ROOT/tools/make_proof_bank.py" --check --audit-log "$PSC_AUDIT_LOG"
