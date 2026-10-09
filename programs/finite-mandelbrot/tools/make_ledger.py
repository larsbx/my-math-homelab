#!/usr/bin/env python3
"""Build ledger.json from proof/c1/records.toml and regenerate every ledger surface.

Round-two item R2 of `docs/cross-pollination-round-two-2026-09-16.md`, the half
that was still owed here: this repository's ledgers were hand-maintained on
three surfaces at once -- the Mojo mirror `kernel/mojo/c1/proof/final_proof_block_ledger.mojo`,
the Markdown table of `docs/C1_final_proof_block_ledger.md`, and the `[[claim]]`
entries of `claim_governance.toml` -- and the claim-governance `consistency`
check could only report drift after it had happened. `proof/c1/records.toml` is
now the single source. Every surface is a function of it, so drift is impossible
rather than detected.

`vendor/python/proof_records` is vendored byte-for-byte from `larsbx/finite-math-kernels`
(`docs/ledger-generation-spec.md` and `docs/typed-relationship-graph-spec.md`
there) and renders the TLA+ ledger and its TLC models, the Markdown index, the
typed relationship graph, and the spliced `[[claim]]` block. The Mojo mirror and
the Markdown block table are this repository's own shapes, rendered here.

The blocks required for the final C1 proof object are exactly the dependencies
of the `C1` record: `required_for_final` is not a field anybody sets, it is the
edge `C1 -> block`. `block_ready_for_final` stays what it was -- a block is
ready only when it is checked and is neither scaffolded, nor an open frontier,
nor research-only -- so nothing here can promote a block by editing a surface.

Usage: make_ledger.py [--check]
"""

from __future__ import annotations

import json
import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from proof_records import generate_ledgers as gl  # noqa: E402
from proof_records.records import Edge, Kind, Record, identified  # noqa: E402

LEDGER = ROOT / "ledger.json"
POLICY = ROOT / "claim_governance.toml"
MOJO = ROOT / "kernel/mojo/c1/proof/final_proof_block_ledger.mojo"
BLOCK_DOC = ROOT / "docs" / "C1_final_proof_block_ledger.md"
SPEC_PATH = ROOT / "proof" / "c1" / "records.toml"


def load_spec() -> dict:
    data = tomllib.loads(SPEC_PATH.read_text(encoding="utf-8"))
    if data.get("version") != 1 or data.get("format") != "finite-mandelbrot-c1-records-v1":
        raise ValueError("unsupported C1 proof-record specification")
    rows = data.get("record", [])
    if not isinstance(rows, list) or not rows:
        raise ValueError("C1 proof-record specification has no records")
    names = [row.get("name") for row in rows]
    if any(not isinstance(name, str) or not name for name in names):
        raise ValueError("every C1 proof record needs a non-empty name")
    if len(names) != len(set(names)):
        raise ValueError("duplicate C1 proof-record name")
    known = set(names)
    for row in rows:
        try:
            Kind(row["kind"])
        except (KeyError, ValueError) as exc:
            raise ValueError(f"{row.get('name', '<unnamed>')}: unknown record kind") from exc
        for field in ("statement", "source_or_reason", "dependencies", "tags", "final_role", "next_action"):
            if field not in row:
                raise ValueError(f"{row['name']}: missing {field}")
        unknown = set(row["dependencies"]) - known
        if unknown:
            raise ValueError(f"{row['name']}: unknown dependencies: {sorted(unknown)}")
    for key in ("root_record", "priority_block", "next_block"):
        if data.get(key) not in known:
            raise ValueError(f"{key} must name a declared record")
    return data


SPEC = load_spec()
SCOPE = str(SPEC["scope"])
TABLE = {row["name"]: row for row in SPEC["record"]}
ROOT_RECORD = str(SPEC["root_record"])
PRIORITY_BLOCK = str(SPEC["priority_block"])
NEXT_BLOCK = str(SPEC["next_block"])
FORBIDDEN_FINAL_EXITS = dict(SPEC["forbidden_final_exits"])
STATUS_CLASSES = dict(SPEC["status_classes"])
STATUS_LABELS = dict(SPEC["status_labels"])

def surface(path: str, anchor: str, window_lines: int = 0, expect: str = "labelled") -> dict:
    return {"path": path, "anchor": anchor, "window_lines": window_lines, "expect": expect}


# Prose surfaces each claim keeps beyond the generated ones. The Mojo mirror and
# the block table are generated, so their anchors cannot drift from the table;
# they are still listed, because a surface nobody checks is a surface nobody
# notices going missing.
SURFACES = {
    name: [surface("docs/C1_final_proof_block_ledger.md", f"| `{name}` |"),
           surface("kernel/mojo/c1/proof/final_proof_block_ledger.mojo", f'ProofBlockStatus("{name}",')]
    for name in TABLE if name != ROOT_RECORD
}
SURFACES[ROOT_RECORD] = [
    surface(
        str(item["path"]),
        str(item["anchor"]),
        int(item.get("window_lines", 0)),
        str(item.get("expect", "labelled")),
    )
    for item in SPEC.get("root_surface", [])
]


def records() -> dict[str, Record]:
    built: dict[str, Record] = {}

    def build(name: str) -> Record:
        if name in built:
            return built[name]
        row = TABLE[name]
        kind = Kind(row["kind"])
        statement = str(row["statement"])
        source = str(row["source_or_reason"])
        deps = tuple(str(d) for d in row["dependencies"])
        tags = tuple(str(t) for t in row["tags"])
        edges = tuple(Edge(build(d).id, build(d).statement, f"{name}/{d}") for d in deps)
        evidence = (("reason", source),) if kind is Kind.PENDING else (("proof_reviewed", "true"), ("source", source))
        built[name] = identified(Record("", kind, statement, SCOPE, edges, evidence, frozenset(tags)))
        return built[name]

    return {name: build(name) for name in TABLE}


def record_json(record: Record) -> dict:
    return {"id": record.id, "kind": record.kind.value, "statement": record.statement, "scope": record.scope,
            "depends_on": [[e.record_id, e.expected_claim, e.use_site, e.scope_relation, e.required_outcome] for e in record.depends_on],
            "evidence": [list(kv) for kv in record.evidence], "tags": sorted(record.tags)}


def ledger() -> dict:
    return {
        "format": gl.FORMAT,
        "repository": str(SPEC["repository"]),
        "module": str(SPEC["module"]),
        "tla_dir": str(SPEC["tla_dir"]),
        "index_path": str(SPEC["index_path"]),
        "graph_path": str(SPEC["graph_path"]),
        "assumption_sets": {"RequiredBlocksAssumed": list(TABLE[ROOT_RECORD]["dependencies"])},
        "status_classes": STATUS_CLASSES,
        "status_labels": STATUS_LABELS,
        "aliases": {},
        "surfaces": SURFACES,
        "records": {name: record_json(r) for name, r in records().items()},
    }


# --- this repository's own surfaces ------------------------------------------------


def snake(name: str) -> str:
    """`ExitClosureForC1` -> `exit_closure_for_c1`, the Mojo accessor's name."""
    return "_".join(part.lower() for part in re.findall(r"[A-Z][a-z0-9]*|[A-Z]+(?![a-z])", name))


def blocks(analysis: gl.Analysis) -> list:
    """Every entry but the root, in table order: the blocks the mirror carries."""
    by_name = {e.name: e for e in analysis.entries}
    return [by_name[name] for name in TABLE if name != ROOT_RECORD]


def required() -> tuple[str, ...]:
    """The blocks the root record depends on: what `required_for_final` means."""
    return tuple(str(name) for name in TABLE[ROOT_RECORD]["dependencies"])


def render_mojo(analysis: gl.Analysis) -> str:
    """The Mojo mirror: one status per block, with the four status flags read
    off the record's class and `required_for_final` read off the root's edges."""
    needed = set(required())
    lines = [f"# {gl.GENERATED.format(source='ledger.json')}",
             "# Final proof block ledger for C1, from proof/c1/records.toml.",
             "#",
             "# This module records the status of required blocks for the final proof object.",
             "# It is intentionally conservative: a scaffolded or open-frontier block rejects",
             "# final acceptance.",
             "",
             "struct ProofBlockStatus(ImplicitlyCopyable):",
             "    var name: String",
             "    var proved_or_imported_checked: Bool",
             "    var scaffolded: Bool",
             "    var open_frontier: Bool",
             "    var research_only: Bool",
             "    var required_for_final: Bool",
             "",
             "    def __init__(out self, name: String, proved_or_imported_checked: Bool, scaffolded: Bool, open_frontier: Bool, research_only: Bool, required_for_final: Bool):",
             "        self.name = name",
             "        self.proved_or_imported_checked = proved_or_imported_checked",
             "        self.scaffolded = scaffolded",
             "        self.open_frontier = open_frontier",
             "        self.research_only = research_only",
             "        self.required_for_final = required_for_final",
             "",
             "",
             "struct FinalEvidencePolicy(ImplicitlyCopyable):"]
    lines += [f"    var {field}: Bool" for field in FORBIDDEN_FINAL_EXITS]
    lines += ["",
              "    def __init__(out self, " + ", ".join(f"{field}: Bool" for field in FORBIDDEN_FINAL_EXITS) + "):"]
    lines += [f"        self.{field} = {field}" for field in FORBIDDEN_FINAL_EXITS]
    for entry in blocks(analysis):
        flags = [_flag(entry.status, cls) for cls in ("proved-or-imported-checked", "scaffolded", "open-frontier", "research-only")]
        flags.append("True" if entry.name in needed else "False")
        lines += ["", "", f"def {snake(entry.name)}_status() -> ProofBlockStatus:",
                  f'    return ProofBlockStatus("{entry.name}", ' + ", ".join(flags) + ")"]
    lines += ["", "", "def block_ready_for_final(block: ProofBlockStatus) -> Bool:",
              "    if not block.required_for_final:",
              "        return True",
              "    return block.proved_or_imported_checked and not block.scaffolded and not block.open_frontier and not block.research_only",
              "", "", "def final_ledger_ready_for_c1() -> Bool:",
              "    return ("]
    conjuncts = [f"        block_ready_for_final({snake(name)}_status())" for name in required()]
    lines.append(" and\n".join(conjuncts))
    lines += ["    )",
              "", "", "def current_priority_block() -> String:",
              f"    return {snake(PRIORITY_BLOCK)}_status().name",
              "", "", "def next_immediate_block() -> String:",
              f"    return {snake(NEXT_BLOCK)}_status().name",
              "", "", "def import_ledger_created() -> Bool:",
              "    return theorem_tag_import_ledger_status().proved_or_imported_checked",
              "", "", "def assumption_payload_schema_created() -> Bool:",
              "    return theorem_tag_assumption_payloads_status().proved_or_imported_checked",
              "", "", "def canonical_final_evidence_policy() -> FinalEvidencePolicy:",
              "    return FinalEvidencePolicy(" + ", ".join("False" for _ in FORBIDDEN_FINAL_EXITS) + ")",
              "", "", "def final_evidence_policy_valid(policy: FinalEvidencePolicy) -> Bool:",
              "    return not ("]
    lines.append(" or\n".join(f"        policy.{field}" for field in FORBIDDEN_FINAL_EXITS))
    lines.append("    )")
    for field, accessor in FORBIDDEN_FINAL_EXITS.items():
        lines += ["", "", f"def {accessor}(policy: FinalEvidencePolicy) -> Bool:", f"    return policy.{field}"]
    return "\n".join(lines) + "\n"


def _flag(status: str, cls: str) -> str:
    return "True" if status == cls else "False"


BLOCK_TABLE_BEGIN = "<!-- BEGIN generated block table (tools/make_ledger.py); do not edit between the markers -->"
BLOCK_TABLE_END = "<!-- END generated block table -->"


def render_block_table(analysis: gl.Analysis) -> str:
    """The `Required blocks` table of the Markdown ledger: every block the root
    record depends on, with the status label the index and the mirror agree on."""
    needed = set(required())
    labels = analysis.ledger.status_labels
    rows = [BLOCK_TABLE_BEGIN, f"<!-- {gl.GENERATED.format(source='ledger.json')} -->", ""]

    def table(names) -> list[str]:
        out = ["| Block | Current status | Final role | Current next action |", "|---|---:|---|---|"]
        for name in names:
            entry = by_name[name]
            out.append(f"| `{name}` | `{labels.get(entry.status, entry.status)}` | {TABLE[name]['final_role']} | {TABLE[name]['next_action']} |")
        return out

    by_name = {e.name: e for e in analysis.entries}
    ordered = [e.name for e in blocks(analysis)]
    rows += table([name for name in ordered if name in needed])
    rows += ["", "The final object does not require these, so a status of theirs never blocks",
             "acceptance; the ledger carries them because they are what the required",
             "theorem-tag blocks are built on.", ""]
    rows += table([name for name in ordered if name not in needed])
    rows += ["", BLOCK_TABLE_END]
    return "\n".join(rows) + "\n"


def splice(existing: str, fragment: str, begin: str, end: str) -> str:
    start = existing.find(begin)
    stop = existing.find(end, start) if start >= 0 else -1
    if start < 0 or stop < 0:
        raise SystemExit(f"markers {begin!r} .. {end!r} not found in the document")
    return existing[:start] + fragment.rstrip("\n") + existing[stop + len(end):]


def main(argv: list[str]) -> int:
    check = "--check" in argv[1:]
    text = json.dumps(ledger(), indent=2, ensure_ascii=False) + "\n"
    stale = []
    if not LEDGER.exists() or LEDGER.read_text(encoding="utf-8") != text:
        stale.append(LEDGER)
        if not check:
            LEDGER.write_text(text, encoding="utf-8")
    if check and stale:
        print(f"stale: {LEDGER} (run tools/make_ledger.py)")
        return 1

    try:
        analysis = gl.analyse(gl.load_ledger(LEDGER))
    except (gl.LedgerError, OSError, ValueError, KeyError, TypeError) as exc:
        print(str(exc))
        return 2
    own = {MOJO: render_mojo(analysis),
           BLOCK_DOC: splice(BLOCK_DOC.read_text(encoding="utf-8"), render_block_table(analysis), BLOCK_TABLE_BEGIN, BLOCK_TABLE_END)}
    drifted = [p for p, body in own.items() if not p.exists() or p.read_text(encoding="utf-8") != body]
    if check:
        if drifted:
            print("generated surfaces are stale:\n  " + "\n  ".join(str(p) for p in drifted))
            return 1
    else:
        for path, body in own.items():
            path.write_text(body, encoding="utf-8")
        print(f"wrote {len(own)} repository surfaces ({len(drifted)} changed)")

    args = ["generate_ledgers", str(LEDGER), "--out", str(ROOT), "--claims", str(POLICY)] + (["--check"] if check else [])
    return gl.main(args)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
