#!/bin/bash
# PostToolUse: an edit to vendored.toml re-derives the ESTATE.toml [[dep]] pins
# (tools/vendoring/check_vendored_sync.py estate). A vendored tree that no longer matches its
# pins blocks with the drift report instead of pinning a drifted tree.
set -euo pipefail
REPO=$(cd "$(dirname "$0")/../.." && pwd -P)
path=$(python3 -c 'import json, sys; print(json.load(sys.stdin).get("tool_input", {}).get("file_path", ""))')
[ "$(realpath -m "$path")" = "$REPO/vendored.toml" ] || exit 0
python3 "$REPO/tools/vendoring/check_vendored_sync.py" estate >&2 || exit 2
