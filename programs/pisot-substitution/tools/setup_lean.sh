#!/usr/bin/env bash
# Provision the checked-in Lean/Lake project without updating its pins.
set -euo pipefail
PSC_ROOT=$(cd "$(dirname "$0")/.." && pwd -P)
PSC_ELAN_BIN="${ELAN_HOME:-$HOME/.elan}/bin"
ELAN_VERSION=4.2.4

if ! "$PSC_ELAN_BIN/elan" --version 2>/dev/null | grep -q "^elan $ELAN_VERSION "; then
    case "$(uname -s)/$(uname -m)" in
        Linux/x86_64)
            target=x86_64-unknown-linux-gnu
            digest=42b94d4244e8353142c456ec0e4ca6528fd898a6c604d4059f494e706e431f63 ;;
        Linux/aarch64|Linux/arm64)
            target=aarch64-unknown-linux-gnu
            digest=05febd124d84ebf994b2e7479922a5650b1e950c17ae3bd1ddd776b65bb72bf9 ;;
        Darwin/x86_64)
            target=x86_64-apple-darwin
            digest=8a340b309d8ed2e96f930761fa223b3af57a38f5d253b53ac90293c9516f8cd4 ;;
        Darwin/arm64|Darwin/aarch64)
            target=aarch64-apple-darwin
            digest=7ad829861392c718dfebde3a83b5c8508df47be02af68894b094b0b3952616e5 ;;
        *) echo "Unsupported elan bootstrap platform; install elan $ELAN_VERSION." >&2; exit 2 ;;
    esac
    PSC_ELAN_TMP=$(mktemp -d)
    trap 'rm -rf "$PSC_ELAN_TMP"' EXIT
    curl --retry 5 --retry-all-errors --retry-delay 3 -fsSL \
        "https://github.com/leanprover/elan/releases/download/v$ELAN_VERSION/elan-$target.tar.gz" \
        -o "$PSC_ELAN_TMP/elan.tar.gz"
    python3 - "$PSC_ELAN_TMP/elan.tar.gz" "$digest" <<'PY'
import hashlib, pathlib, sys
if hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest() != sys.argv[2]:
    raise SystemExit("elan release digest mismatch")
PY
    tar -xzf "$PSC_ELAN_TMP/elan.tar.gz" -C "$PSC_ELAN_TMP"
    "$PSC_ELAN_TMP/elan-init" -y --no-modify-path --default-toolchain none
fi
"$PSC_ELAN_BIN/elan" --version | grep -q "^elan $ELAN_VERSION "
export PATH="$PSC_ELAN_BIN:$PATH"
python3 "$PSC_ROOT/tools/make_proof_bank.py" --pins-only
cd "$PSC_ROOT/proof/PscVerif"
PSC_PIN=$(cat lean-toolchain)
elan toolchain install "$PSC_PIN"
# Probe both applications: an installed but unusable toolchain is a failure.
for PSC_ENV_VAR in "${!LEAN_@}" "${!LAKE_@}" "${!MATHLIB_CACHE_@}"; do
    if [[ -n "$PSC_ENV_VAR" ]]; then unset "$PSC_ENV_VAR"; fi
done
export LAKE_CONFIG="" LAKE_CACHE_DIR="" LAKE_ARTIFACT_CACHE=false LAKE_RESTORE_ARTIFACTS=false
export MATHLIB_CACHE_GET_URL="https://cache.mathlib.org/mathlib4-master"
PSC_RELEASE=${PSC_PIN#leanprover/lean4:v}
PSC_LEAN_VERSION=$(elan run "$PSC_PIN" lean --version)
PSC_LAKE_VERSION=$(elan run "$PSC_PIN" lake --version)
if [[ "$PSC_LEAN_VERSION" != "Lean (version $PSC_RELEASE,"* ]] \
   || [[ "$PSC_LAKE_VERSION" != *"(Lean version $PSC_RELEASE)" ]]; then
    echo "Lean/Lake executable version does not match the pinned release $PSC_RELEASE" >&2
    exit 1
fi
printf '%s\n%s\n' "$PSC_LEAN_VERSION" "$PSC_LAKE_VERSION"

PSC_PIN_TMP=$(mktemp -d)
trap 'rm -rf "${PSC_ELAN_TMP:-}" "$PSC_PIN_TMP"' EXIT
for pin in lean-toolchain lakefile.toml lake-manifest.json; do
    cp "$pin" "$PSC_PIN_TMP/$pin"
done
# Lake clones exactly the manifest revisions; never run lake update here.
elan run "$PSC_PIN" lake --no-cache exe cache get
for pin in lean-toolchain lakefile.toml lake-manifest.json; do
    if ! cmp -s "$pin" "$PSC_PIN_TMP/$pin"; then
        echo "Lean provisioning changed $pin; refusing to credit the environment." >&2
        exit 1
    fi
done
python3 "$PSC_ROOT/tools/make_proof_bank.py" --pins-only --require-packages
