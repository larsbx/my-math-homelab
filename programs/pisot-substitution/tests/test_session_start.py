"""Provisioning contracts, plus a real locked-Mojo integration check in CI.

Network/installer boundaries and Lean helpers are faked in these cases. The
lean-proofs CI job checks the real pinned build and complete axiom audit. Set
PSC_SESSION_START_REAL_PIXI to a pinned pixi binary to require real installation,
activation, compilation and execution (the mojo-kernel CI job does this).
PSC_SESSION_START_HOOK can select a historical hook for negative calibration.
"""

import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import textwrap

import pytest

ROOT = Path(__file__).resolve().parents[1]
HOOK = Path(os.environ.get("PSC_SESSION_START_HOOK", ROOT / ".claude/hooks/session-start.sh"))
PIN = "0.81.0"
STD_PROBE = '''from std.collections import List

def main():
    var values: List[Int] = [17, 25]
    print("session-start std ok", values[0] + values[1])
'''


def script(path, body):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(f"#!{sys.executable}\n" + textwrap.dedent(body))
    path.chmod(0o755)


def sandbox(tmp_path, *, installed=None, failure="", real_pixi=None):
    # Check the hook's metacharacter quoting independently of pixi's known
    # dollar-expansion bug. Real pixi still exercises spaces and single quotes.
    name = "repo with spaces and 'quotes'" if real_pixi else "repo with $literal and 'quotes'"
    repo = tmp_path / "parent workspace" / name
    hook = repo / ".claude/hooks/session-start.sh"
    hook.parent.mkdir(parents=True)
    shutil.copyfile(HOOK, hook)
    mojo = repo / "kernel"
    mojo.mkdir()
    for name in ("pixi.toml", "pixi.lock"):
        shutil.copyfile(ROOT / "kernel" / name, mojo / name)
    home = tmp_path / "home with spaces"
    home.mkdir()
    env_file = tmp_path / "session.env"
    env_file.touch()
    log = tmp_path / "calls.jsonl"
    bins = tmp_path / "provision-bin"
    bins.mkdir()
    prefix = mojo / ".pixi/envs/default"
    activation = {
        "MODULAR_HOME": str(prefix), "CONDA_PREFIX": str(prefix),
        "MOJO_STDLIB_PATH": str(prefix / "lib/mojo"),
        "PSC_ACTIVATION_QUOTING": "spaces $literal and 'quotes'",
        "PATH": "/must-not-freeze-this-path",
        "PIXI_IN_SHELL": "1", "PIXI_PROMPT": "(psc-mojo)",
    }
    if failure == "activation-prefix":
        activation["CONDA_PREFIX"] = str(tmp_path / "wrong-prefix")
    prelude = f'''
import json, os, pathlib, subprocess, sys
repo = pathlib.Path({str(repo)!r})
log = pathlib.Path({str(log)!r})
def record(tool):
    with log.open("a") as f:
        f.write(json.dumps([tool, str(pathlib.Path.cwd()), sys.argv[1:]]) + "\\n")
'''
    lean_bin = home / ".elan/bin"
    for tool in ("lean", "lake"):
        script(lean_bin / tool, prelude + f'''
record({tool!r})
assert sys.argv[1:] == ["--version"]
print("mock {tool}")
''')
    script(repo / "tools/setup_lean.sh", prelude + f'''
record("lean-setup")
assert pathlib.Path.cwd() == repo
if {failure!r} == "lean-setup":
    sys.exit(25)
''')
    script(repo / "tools/check_lean.sh", prelude + f'''
record("lean-check")
assert pathlib.Path.cwd() == repo
for tool in ("lean", "lake"):
    assert pathlib.Path(__import__("shutil").which(tool)).parent == pathlib.Path({str(lean_bin)!r})
if {failure!r} == "lean-check":
    sys.exit(26)
''')
    script(bins / "python3", prelude + f'''
if sys.argv[1:3] == ["-m", "pip"]:
    record("pip")
    assert pathlib.Path.cwd() == repo
    assert sys.argv[1:] == ["-m", "pip", "install", "-q", "-e", ".[dev]"]
else:
    os.execv({sys.executable!r}, [{sys.executable!r}, *sys.argv[1:]])
''')
    # The installer is delivered through the same curl | bash boundary as live
    # provisioning; assert its inputs independently of the hook's source text.
    pixi_source = tmp_path / "pinned-pixi"
    installer = f'''set -eu
test "$PIXI_VERSION" = v{PIN}
test "$PIXI_NO_PATH_UPDATE" = 1
mkdir -p "$HOME/.pixi/bin"
cp {shlex.quote(str(pixi_source))} "$HOME/.pixi/bin/pixi"
'''
    script(bins / "curl", prelude + f'''
record("installer")
assert sys.argv[-1] == "https://pixi.sh/install.sh"
print({installer!r})
''')
    if real_pixi:
        shutil.copyfile(real_pixi, pixi_source)
        pixi_source.chmod(0o755)
    else:
        script(pixi_source, prelude + f'''
record("pixi")
args = sys.argv[1:]
if args == ["--version"]:
    print("pixi {'0.80.0' if failure == 'installer-version' else PIN}")
else:
    assert pathlib.Path.cwd() == repo / "kernel"
    assert args in (["install", "--locked"], ["shell-hook", "--locked", "--json"])
    if args[0] == {failure!r}:
        sys.exit(23)
    if args[0] == "shell-hook":
        print(json.dumps({{"environment_variables": {activation!r}}}))
''')
        script(prefix / "bin/mojo", prelude + f'''
record("mojo")
for name, value in {activation!r}.items():
    if name not in {{"PATH", "PIXI_IN_SHELL", "PIXI_PROMPT"}}:
        assert os.environ.get(name) == value, name
if sys.argv[1:] == ["--version"]:
    print("mock Mojo")
else:
    assert sys.argv[1] == "run"
    assert pathlib.Path(sys.argv[2]).is_file()
    if {failure!r} == "probe":
        sys.exit(24)
    print("session-start std ok 42" if "std.collections" in pathlib.Path(sys.argv[2]).read_text() else "mojo ok")
''')
    if installed == PIN:
        target = home / ".pixi/bin/pixi"
        target.parent.mkdir(parents=True)
        shutil.copyfile(pixi_source, target)
        target.chmod(0o755)
    elif installed:
        script(home / ".pixi/bin/pixi", f'print("pixi {installed}")\n')
    env = {
        "HOME": str(home), "PATH": f"{bins}:/usr/bin:/bin",
        "CLAUDE_CODE_REMOTE": "true", "CLAUDE_PROJECT_DIR": str(repo.parent),
        "CLAUDE_ENV_FILE": str(env_file),
        # Share the existing download cache in the real integration case.
        "PIXI_CACHE_DIR": os.environ.get("PIXI_CACHE_DIR", str(Path.home() / ".cache/rattler/cache")),
    }
    return repo, hook, env_file, log, env


def run_hook(hook, env, cwd):
    return subprocess.run(["/bin/bash", str(hook)], env=env, cwd=cwd, text=True,
                          capture_output=True, timeout=600)


def bare_probe(repo, env_file):
    probe = repo.parent / "std-probe.mojo"
    probe.write_text(STD_PROBE)
    # No inherited compiler variables, pixi, or PATH entries from the hook.
    return subprocess.run([
        "/bin/bash", "--noprofile", "--norc", "-c",
        'set -eu; source "$1"; test -z "${PIXI_IN_SHELL:-}"; '
        'test -z "${PIXI_PROMPT:-}"; test "${PATH##*:}" = /caller-tail; '
        'lean --version; lake --version; mojo run "$2"',
        "probe", str(env_file), str(probe),
    ], env={"HOME": str(repo.parent), "PATH": "/usr/bin:/bin:/caller-tail"},
        cwd=repo.parent, text=True, capture_output=True, timeout=120)


@pytest.mark.parametrize("installed", [None, "0.80.0", PIN])
@pytest.mark.parametrize("project_dir", ["parent", None])
def test_hook_provisions_locked_activation_from_its_own_repository(tmp_path, installed, project_dir):
    repo, hook, env_file, log, env = sandbox(tmp_path, installed=installed)
    if project_dir is None:
        del env["CLAUDE_PROJECT_DIR"]
    lock = (repo / "kernel/pixi.lock").read_bytes()
    for _ in range(2):
        result = run_hook(hook, env, repo.parent)
        assert result.returncode == 0, result.stdout + result.stderr
        assert "mojo ok" in result.stdout
        result = bare_probe(repo, env_file)
        assert result.returncode == 0, result.stdout + result.stderr
        assert "session-start std ok 42" in result.stdout
    calls = [json.loads(line) for line in log.read_text().splitlines()]
    assert sum(call[0] == "installer" for call in calls) == (installed != PIN)
    assert sum(call[0] == "pixi" and call[2] == ["install", "--locked"] for call in calls) == 2
    assert sum(call[0] == "pixi" and call[2] == ["shell-hook", "--locked", "--json"] for call in calls) == 2
    assert sum(call[0] == "lean-setup" for call in calls) == 2
    assert sum(call[0] == "lean-check" for call in calls) == 2
    assert sum(call[0] == "lean" for call in calls) == 2
    assert sum(call[0] == "lake" for call in calls) == 2
    assert (repo / "kernel/pixi.lock").read_bytes() == lock
    # The hook removes each temporary compilation probe on exit.
    for tool, _, args in calls:
        if tool == "mojo" and args[0] == "run" and "std-probe" not in args[1]:
            assert not Path(args[1]).exists()


@pytest.mark.parametrize("failure", ["lean-setup", "install", "shell-hook", "probe", "installer-version", "activation-prefix", "lean-check"])
def test_hook_refuses_provisioning_or_compilation_failure(tmp_path, failure):
    repo, hook, env_file, log, env = sandbox(tmp_path, installed=PIN, failure=failure)
    result = run_hook(hook, env, repo.parent)
    assert result.returncode != 0, result.stdout + result.stderr
    calls = [json.loads(line) for line in log.read_text().splitlines()]
    if failure == "lean-setup":
        assert result.returncode == 25
        assert env_file.read_bytes() == b""
        assert not any(call[0] in {"installer", "pixi", "lean-check"} for call in calls)
    elif failure == "lean-check":
        assert result.returncode == 26
        assert any(call[0] == "lean-check" for call in calls)
    else:
        # Ensure a missing fixture cannot make an earlier failure pass vacuously.
        assert any(call[0] == "pixi" for call in calls)
        assert not any(call[0] == "lean-check" for call in calls)
    if failure == "activation-prefix":
        assert "activation prefix differs" in result.stderr
        assert env_file.read_bytes() == b""
    for tool, _, args in calls:
        if tool == "mojo" and args[0] == "run":
            assert not Path(args[1]).exists()


def test_local_session_does_not_provision(tmp_path):
    repo, hook, env_file, log, env = sandbox(tmp_path)
    env["CLAUDE_CODE_REMOTE"] = "false"
    result = run_hook(hook, env, repo.parent)
    assert result.returncode == 0, result.stdout + result.stderr
    assert not log.exists()
    assert env_file.read_bytes() == b""


@pytest.mark.skipif(not os.environ.get("PSC_SESSION_START_REAL_PIXI"), reason="real pixi integration is required by mojo-kernel CI")
def test_real_locked_mojo_runs_from_emitted_environment(tmp_path):
    real_pixi = Path(os.environ["PSC_SESSION_START_REAL_PIXI"]).resolve()
    version = subprocess.check_output([str(real_pixi), "--version"], text=True).strip()
    assert version == f"pixi {PIN}"
    repo, hook, env_file, _, env = sandbox(tmp_path, installed=PIN, real_pixi=real_pixi)
    lock = (repo / "kernel/pixi.lock").read_bytes()
    result = run_hook(hook, env, repo.parent)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "mojo ok" in result.stdout
    result = bare_probe(repo, env_file)
    assert result.returncode == 0, result.stdout + result.stderr
    assert "session-start std ok 42" in result.stdout
    assert (repo / "kernel/pixi.lock").read_bytes() == lock
