from pathlib import Path
import subprocess
import sys
from fractions import Fraction

ROOT = Path(__file__).resolve().parents[1]


def test_interval_exclusion_reference_passes():
    result = subprocess.run(
        [sys.executable, str(ROOT / "reference" / "python" / "interval" / "interval_exclusion_reference.py")],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert "c=-2: 5/5" in result.stdout
    assert "M_4,1: 18/18" in result.stdout


def test_interval_oracle_uses_fraction_not_float():
    text = (ROOT / "reference" / "python" / "interval" / "interval_exclusion_reference.py").read_text()
    assert "from fractions import Fraction" in text
    assert "float(" not in text
    assert "math." not in text


def test_same_box_language_present():
    text = (ROOT / "reference" / "python" / "interval" / "interval_exclusion_reference.py").read_text()
    assert "same-box" in text
    assert "forbidden collision" in text


def test_interval_oracle_uses_the_vendored_sharp_square():
    # The interval classes are the vendored closed_interval twin of closed_q;
    # its complex square uses the sharp coordinate square (spec section 2.5).
    sys.path.insert(0, str(ROOT / "reference" / "python" / "interval"))
    import interval_exclusion_reference as ie
    from closed_interval import ComplexIQ

    text = (ROOT / "reference" / "python" / "interval" / "interval_exclusion_reference.py").read_text()
    assert "from closed_interval import" in text
    assert "class " not in text
    box = ie.c_minus_2_box()
    assert isinstance(box, ComplexIQ)
    # Y = [-1/16, 1/16] straddles zero, so Y^2 = [0, 1/256], not [-1/256, 1/256].
    assert box.square().re.hi == box.re.lo * box.re.lo


def test_downstream_api_of_the_oracle_is_kept():
    # math-vizops loads this file from a sibling checkout and reads these.
    sys.path.insert(0, str(ROOT / "reference" / "python" / "interval"))
    import interval_exclusion_reference as ie

    box = ie.dyadic_box(-2 * 2**6, 0, 6, 4)
    assert (box.re.lo, box.re.hi, box.im.lo, box.im.hi) == (-2 - Fraction(1, 16), -2 + Fraction(1, 16), Fraction(-1, 16), Fraction(1, 16))
    assert ie.excluded_count(ie.c_minus_2_box(), 2, 1, 3) == (5, 5, [])
    assert ie.excluded_count(ie.c_minus_2_box(), 2, 1, 4) == (5, 7, [(0, 4), (1, 4)])
