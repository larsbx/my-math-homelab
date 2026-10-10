from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/arithmetic/coord_record_eval.mojo"
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings


def text() -> str:
    return SRC.read_text(encoding="utf-8")


def test_coord_record_eval_exists():
    src = text()
    assert "struct CoordEvalStatus" in src
    assert "fn eval_p41_coord_record" in src
    assert "fn eval_p41_derivative_coord_record" in src
    assert "fn m41_coord_eval_status_pending_backend" in src


def test_not_point_evaluation_language():
    src = mask_comments_and_strings(text()).lower()
    assert "point evaluation" not in src
    assert "coordrecord" in src or "coord_record" in src
    assert "coordrecord" in src or "coord_record" in src


def test_p41_coefficients_and_derivative_coefficients_preserved():
    src = text()
    assert "0, 8, 20, 40, 68, 94, 114, 116, 94, 60, 28, 8, 1" in src
    assert "8, 40, 120, 272, 470, 684, 812, 752, 540, 280, 88, 12, 0" in src


def test_m41_remains_pending_until_bigint_backend():
    src = text()
    assert "certificate_ready_backend" in src
    assert "True, True, True, False" in src
    assert "current Q uses Int64" in src


def test_no_runtime_shortcuts():
    src = mask_comments_and_strings(text()).lower()
    forbidden = ["float64", "math.", "cmath", "numpy", "atan(", "radian", "degree"]
    for token in forbidden:
        assert token not in src
