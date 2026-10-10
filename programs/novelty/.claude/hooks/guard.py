#!/usr/bin/env python3
"""Claude Code hooks enforcing AGENTS.md mechanically. One module, three events:

    guard.py pre-edit    PreToolUse  Edit|Write|NotebookEdit  deny edits to generated or vendored paths
    guard.py post-edit   PostToolUse Edit|Write               reseal + regenerate the ledger; check ESTATE pins
    guard.py pre-bash    PreToolUse  Bash                     gate `git commit` on the fast gates and the message rule

Reads the hook payload from stdin. Paths outside this repository are ignored.
"""
from __future__ import annotations

import json
import os
import re
import shlex
import subprocess
import sys
from fnmatch import fnmatch
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

# Generated or pinned paths: never hand-edited (AGENTS.md § Generated surfaces, § Vendored packages).
PROTECTED = (
    ("vendor/*", "vendored byte for byte from larsbx/finite-math-kernels: change it upstream, re-vendor, "
                 "re-pin with vendor/vendoring/check_vendored_sync.py pin NAME COMMIT, then tools/estate_pins.py --write"),
    ("data/*", "a census output: rerun the script named in its ledger `replay` (without --check), "
               "then update the record's digest and reseal"),
    ("tla/*", "generated from research/ledger.json: edit the ledger, then tools/seal_ledger.py and the generator"),
    ("docs/ledger-index.md", "generated from research/ledger.json: edit the ledger, then tools/seal_ledger.py and the generator"),
    ("paper/*/tables/*", "generated from data/: run the paper's make_tables.py"),
    ("tools/audit_estate_layout.py", "a vendored copy of the estate audit is forbidden (SPEC_estate §5); CI downloads it by pin"),
)
GENERATED_BLOCK = ("# BEGIN generated claims", "# END generated claims")
# Model identifiers never go into a commit (session policy); attribution trailers are fine.
MODEL_ID = re.compile(r"\bclaude-(?:opus|sonnet|haiku|fable)-\d[\w.-]*", re.IGNORECASE)


def relative(path: str | None) -> str | None:
    if not path:
        return None
    try:
        return Path(path).resolve().relative_to(ROOT).as_posix()
    except ValueError:
        return None


def deny(reason: str) -> int:
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny",
                                             "permissionDecisionReason": reason}}))
    return 0


def run(*cmd: str) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, env={**os.environ, "PYTHONPATH": "vendor"})


def touches_generated_block(tool: dict) -> bool:
    """Whether an edit of claim_governance.toml changes the generated [[claim]] block."""
    text = (ROOT / "claim_governance.toml").read_text(encoding="utf-8")
    start, end = text.find(GENERATED_BLOCK[0]), text.find(GENERATED_BLOCK[1])
    if "content" in tool:   # Write: compare the block before and after
        new = tool["content"]
        return new[new.find(GENERATED_BLOCK[0]):new.find(GENERATED_BLOCK[1])] != text[start:end]
    old = tool.get("old_string", "")
    at = text.find(old) if old else -1
    return at != -1 and at + len(old) > start and at < end


def pre_edit(payload: dict) -> int:
    tool = payload.get("tool_input", {})
    rel = relative(tool.get("file_path") or tool.get("notebook_path"))
    if rel is None:
        return 0
    for pattern, why in PROTECTED:
        if fnmatch(rel, pattern):
            return deny(f"{rel} is not hand-edited: {why}.")
    if rel == "claim_governance.toml" and touches_generated_block(tool):
        return deny("the [[claim]] block of claim_governance.toml is generated: edit research/ledger.json, "
                    "then tools/seal_ledger.py and the generator. The hand-written head above the markers is editable.")
    return 0


def post_edit(payload: dict) -> int:
    rel = relative(payload.get("tool_input", {}).get("file_path"))
    if rel == "research/ledger.json":
        steps = [("reseal", run(sys.executable, "tools/seal_ledger.py")),
                 ("regenerate", run(sys.executable, "-m", "proof_records.generate_ledgers", "research/ledger.json",
                                    "--claims", "claim_governance.toml"))]
        failed = [(name, r) for name, r in steps if r.returncode]
        if failed:
            name, r = failed[0]
            print(json.dumps({"decision": "block",
                              "reason": f"ledger {name} failed after editing research/ledger.json:\n{r.stdout}{r.stderr}"}))
        else:
            print(json.dumps({"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext":
                              "research/ledger.json was resealed and its surfaces regenerated "
                              "(docs/ledger-index.md, tla/, the claim block of claim_governance.toml)."}}))
    elif rel in ("vendored.toml", "ESTATE.toml"):
        r = run(sys.executable, "tools/estate_pins.py")
        if r.returncode:
            print(json.dumps({"decision": "block", "reason": r.stdout + r.stderr}))
    return 0


VALUE_OPTS = {"-m": "message", "--message": "message", "-F": "file", "--file": "file", "-t": "template",
              "--template": "template", "-C": "commit", "-c": "commit", "--reuse-message": "commit",
              "--reedit-message": "commit", "--fixup": "commit", "--squash": "commit"}


def commit_invocations(command: str):
    """(cwd override, argv after `commit`) for each `git [-C dir] commit ...` in a shell command."""
    lexer = shlex.shlex(command, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    try:
        tokens = list(lexer)
    except ValueError:   # unbalanced quotes: let the shell reject it
        return
    for i, token in enumerate(tokens):
        if token != "git":
            continue
        j, cwd = i + 1, None
        while j < len(tokens) and tokens[j].startswith("-"):
            if tokens[j] == "-C" and j + 1 < len(tokens):
                cwd, j = tokens[j + 1], j + 2
            else:
                j += 1
        if j < len(tokens) and tokens[j] == "commit":
            args = []
            for t in tokens[j + 1:]:
                if set(t) <= set("();<>|&"):
                    break
                args.append(t)
            yield cwd, args


def commit_messages(args: list[str], cwd: Path) -> tuple[list[str], bool]:
    """(message texts the commit will use, whether the message comes from an editor)."""
    texts, sourced, amend = [], False, "--amend" in args

    def take(kind: str, value: str) -> None:
        nonlocal sourced
        sourced = sourced or kind != "template"   # a template still opens the editor
        if kind == "message":
            texts.append(value)
        elif kind in ("file", "template") and value != "-":   # `-F -` reads stdin: a heredoc in the command text
            path = (cwd / value).expanduser()
            texts.append(path.read_text(encoding="utf-8", errors="replace") if path.is_file() else "")
        elif kind == "commit":
            texts.append(subprocess.run(["git", "log", "-1", "--format=%B", value], cwd=cwd,
                                        capture_output=True, text=True).stdout)
    it = iter(range(len(args)))
    for k in it:
        arg = args[k]
        name, eq, inline = arg.partition("=")
        if arg.startswith("--") and name in VALUE_OPTS:
            value = inline if eq else (args[k + 1] if k + 1 < len(args) else "")
            if not eq:
                next(it, None)
            take(VALUE_OPTS[name], value)
        elif arg.startswith("-") and not arg.startswith("--"):
            for pos, flag in enumerate(arg[1:], start=1):
                if f"-{flag}" in VALUE_OPTS:
                    value = arg[pos + 1:] or (args[k + 1] if k + 1 < len(args) else "")
                    if not arg[pos + 1:]:
                        next(it, None)
                    take(VALUE_OPTS[f"-{flag}"], value)
                    break
    if amend and not sourced:
        texts.append(subprocess.run(["git", "log", "-1", "--format=%B"], cwd=cwd, capture_output=True, text=True).stdout)
        sourced = "--no-edit" in args
    return texts, not sourced


def pre_bash(payload: dict) -> int:
    command = payload.get("tool_input", {}).get("command", "")
    invocations = list(commit_invocations(command))
    if not invocations:
        return 0
    if os.environ.get("CLAUDE_CODE_REMOTE") == "true":
        status = ROOT / ".claude" / "provision-status"
        state = status.read_text(encoding="utf-8").strip() if status.is_file() else "missing"
        if state != "ok":
            return deny(f"session provisioning did not succeed ({state}); the gates cannot all run here. "
                        "Rerun .claude/hooks/session-start.sh and fix what it reports before committing.")
    base = Path(payload.get("cwd") or ROOT)
    texts = [command]   # inline -m values and heredoc bodies (`-F -`) are in the command text
    for cwd, args in invocations:
        found, editor = commit_messages(args, (base / cwd) if cwd else base)
        if editor:
            return deny("commit with -m, -F or -C so the message can be checked; an editor-composed message "
                        "cannot be inspected before it is recorded.")
        texts += found
    if (hit := next((m for t in texts if (m := MODEL_ID.search(t))), None)):
        return deny(f"the commit message names a model identifier ({hit.group(0)}); keep model identifiers out of commits.")
    r = subprocess.run(["scripts/verify_all.sh", "fast"], cwd=ROOT, capture_output=True, text=True)
    if r.returncode:
        return deny("fast gates failed; fix them before committing (scripts/verify_all.sh fast):\n" + r.stdout)
    return 0


if __name__ == "__main__":
    event = sys.argv[1] if len(sys.argv) > 1 else ""
    handlers = {"pre-edit": pre_edit, "post-edit": post_edit, "pre-bash": pre_bash}
    if event not in handlers:
        print(f"usage: guard.py {{{'|'.join(handlers)}}}", file=sys.stderr)
        raise SystemExit(1)   # non-blocking error: a misconfigured hook must not wedge the session
    raise SystemExit(handlers[event](json.load(sys.stdin)))
