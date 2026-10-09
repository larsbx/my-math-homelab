#!/bin/bash
# Provision a Claude Code on the web container for the repository gates:
# Python oracles and pytest (as CI does), and the Mojo toolchain exactly as
# pinned by kernel/pixi.lock, plus the pinned Lean/Lake proof project.
set -euo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0
# The hook may be registered from a parent workspace, so locate the repo from
# the script rather than trusting CLAUDE_PROJECT_DIR.
REPO=$(cd "$(dirname "$0")/../.." && pwd -P)
cd "$REPO"

python3 -m pip install -q -e '.[dev]'

"$REPO/tools/setup_lean.sh"
PSC_LEAN_BIN="${ELAN_HOME:-$HOME/.elan}/bin"

# Pinned pixi; reinstalled when the binary is missing or at another version.
PIXI_VERSION=0.81.0
PIXI_BIN="$HOME/.pixi/bin"
"$PIXI_BIN/pixi" --version 2>/dev/null | grep -qx "pixi $PIXI_VERSION" ||
    curl --retry 5 --retry-all-errors --retry-delay 3 -fsSL https://pixi.sh/install.sh |
        PIXI_VERSION="v$PIXI_VERSION" PIXI_NO_PATH_UPDATE=1 bash
# Refuse a failed/mismatched installer result before provisioning the lock.
"$PIXI_BIN/pixi" --version | grep -qx "pixi $PIXI_VERSION"

# --locked: install exactly kernel/pixi.lock; fail rather than re-solve the pin.
(cd kernel && "$PIXI_BIN/pixi" install --locked)
MOJO_BIN="$REPO/kernel/.pixi/envs/default/bin"

# Activate the environment for the whole session: a bare `mojo` needs the
# activation variables (MODULAR_HOME, CONDA_PREFIX, ...) to locate `std`.
# PATH is composed below rather than frozen at hook time; the interactive-shell
# markers are dropped so `pixi run` still works from the session.
(cd kernel && "$PIXI_BIN/pixi" shell-hook --locked --json) | python3 -c '
import json, os, shlex, sys
env = json.load(sys.stdin)["environment_variables"]
# pixi 0.81.0 can expand dollar expressions in a prefix during activation.
# Refuse that mismatch before publishing an unusable session environment.
if os.path.realpath(env.get("CONDA_PREFIX", "")) != os.path.realpath(sys.argv[1]):
    raise SystemExit("pixi activation prefix differs from the locked repository environment")
skip = {"PATH", "PIXI_IN_SHELL", "PIXI_PROMPT"}
for k, v in sorted(env.items()):
    if k not in skip:
        print(f"export {k}={shlex.quote(v)}")' "$REPO/kernel/.pixi/envs/default" >> "$CLAUDE_ENV_FILE"

# The pip-installed pytest (with pypdf) must shadow any preinstalled tool copy.
printf 'export PATH=%q:"$PATH"\n' "$(python3 -c 'import sysconfig; print(sysconfig.get_path("scripts"))'):$MOJO_BIN:$PIXI_BIN:$PSC_LEAN_BIN" >> "$CLAUDE_ENV_FILE"

# Fail the hook, not the first gate, if the toolchain cannot compile.
PROBE=$(mktemp --suffix=.mojo)
trap 'rm -f "$PROBE"' EXIT
echo 'def main(): print("mojo ok")' > "$PROBE"
(source "$CLAUDE_ENV_FILE" && mojo --version && mojo run "$PROBE")
(source "$CLAUDE_ENV_FILE" && "$REPO/tools/check_lean.sh")
