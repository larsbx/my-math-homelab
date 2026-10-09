"""The evidence workflow re-certifies exactly the lines and wedges the driver pins.

`certified_lines()`, `certified_norm_lines()` and `certified_wedges()` in
kernel/symbolic_line_certificate.mojo are the single lists of certified
Theorem E lines, norm-mode lines (the wedges' boundary lines) and wedge cores;
.github/workflows/class-b-lines-evidence.yml must run each of them once, in
the driver's `CLASS AP BP AQ BQ AR BR`, `norm CLASS ...` and
`wedge CLASS P0 PA PB Q0 QA QB R0 RA RB` forms, and nothing else.
"""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DRIVER = ROOT / "kernel" / "symbolic_line_certificate.mojo"
WORKFLOW = ROOT / ".github" / "workflows" / "class-b-lines-evidence.yml"

ROW = re.compile(r"^\s*\[CLASS_([ABCD]),((?:\s*-?\d+,){10}\s*-?\d+)\],?\s*$", re.M)
WEDGE_ROW = re.compile(r"^\s*\[CLASS_([ABCD]),((?:\s*-?\d+,){11}\s*-?\d+)\],?\s*$", re.M)
LINE = re.compile(r"^\s*- \{ line: '([^']+)' \}\s*$", re.M)


def pinned(function, row, width, prefix=()):
    body = DRIVER.read_text(encoding="utf-8").split(f"def {function}()", 1)[1].split("\n\n\n", 1)[0]
    return [
        " ".join([*prefix, cls, *(x.strip() for x in ints.split(",")[:width])])
        for cls, ints in row.findall(body)
    ]


def pinned_lines():
    return (
        pinned("certified_lines", ROW, 6)
        + pinned("certified_norm_lines", ROW, 6, ("norm",))
        + pinned("certified_wedges", WEDGE_ROW, 9, ("wedge",))
    )


def workflow_lines():
    return LINE.findall(WORKFLOW.read_text(encoding="utf-8"))


def test_the_driver_pins_lines():
    assert len(pinned_lines()) >= 15


def test_the_workflow_runs_every_pinned_line_once():
    pins, runs = pinned_lines(), workflow_lines()
    assert len(runs) == len(set(runs))
    assert sorted(runs) == sorted(pins)


def test_shared_algebra_changes_trigger_the_symbolic_evidence_matrix():
    assert "      - 'kernel/psc/param_poly.mojo'" in WORKFLOW.read_text(encoding="utf-8")
