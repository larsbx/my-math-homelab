#!/bin/bash
# Provision a Claude Code on the web container for the repository gates
# (scripts/verify_all.sh): Python >= 3.11 for the Python group, and the Lean
# toolchain pinned by lean-toolchain, with `lake` on PATH, for the lean group.
# The TLC group stays a reported SKIP unless TLA2TOOLS is set.
set -euo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0
# The hook may be registered from a parent workspace, so locate the repository
# from the script rather than trusting CLAUDE_PROJECT_DIR.
REPO=$(cd "$(dirname "$0")/../.." && pwd -P)
cd "$REPO"

# A SessionStart hook cannot block the session, so its outcome is recorded instead:
# guard.py refuses commits in web sessions until this file reads "ok".
STATUS="$REPO/.claude/provision-status"
echo "failed: provisioning did not finish (see the SessionStart hook output)" > "$STATUS"
trap '[ $? -eq 0 ] && echo ok > "$STATUS"' EXIT

# The Python gates use only the standard library, but need tomllib (3.11).
python3 -c 'import sys; sys.exit(sys.version_info < (3, 11))' ||
    { echo "python3 >= 3.11 is required by the gates" >&2; exit 1; }

# elan, then exactly the toolchain lean-toolchain names; refuse a different one.
TOOLCHAIN=$(cat lean-toolchain)
ELAN_BIN="$HOME/.elan/bin"
[ -x "$ELAN_BIN/elan" ] ||
    curl --retry 5 --retry-all-errors --retry-delay 3 -fsSL \
        https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh |
        sh -s -- -y --no-modify-path --default-toolchain none
"$ELAN_BIN/elan" toolchain install "$TOOLCHAIN"
printf 'export PATH=%q:"$PATH"\n' "$ELAN_BIN" >> "$CLAUDE_ENV_FILE"

# Fail the hook, not the first gate, if the toolchain cannot build the oracle.
(export PATH="$ELAN_BIN:$PATH" && lake --version | grep -q "${TOOLCHAIN##*:v}" && lake build)
