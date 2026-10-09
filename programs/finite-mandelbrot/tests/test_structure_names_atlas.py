"""The names atlas, checked entry by entry against exact oracles.

`schemas/structure_names.toml` keys every common name for a structure of the
Mandelbrot set to exact data: rational external angles, internal addresses,
integer polynomials, rational parameters and rational isolating intervals.
`docs/mandelbrot-structure-names-atlas.md` is the prose it binds to. Every
exact field is recomputed here; a name whose data is wrong fails, and so does a
name the prose and the table do not share.
"""

from __future__ import annotations

import re
import subprocess
import sys
from fractions import Fraction
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.atlas import structure_names_reference as sn  # noqa: E402

DOC = ROOT / "docs" / "mandelbrot-structure-names-atlas.md"
ENTRIES = sn.load()
BY_ID = {e["id"]: e for e in ENTRIES}


@pytest.mark.parametrize("entry", ENTRIES, ids=[e["id"] for e in ENTRIES])
def test_entry_exact_data_checks(entry: dict) -> None:
    assert sn.check_entry(entry, BY_ID) == []


def test_ids_and_names_are_unique() -> None:
    names = [n.lower() for e in ENTRIES for n in e["names"]]
    assert len(BY_ID) == len(ENTRIES)
    assert len(set(names)) == len(names)


def test_every_entry_has_status_and_source() -> None:
    for e in ENTRIES:
        assert e["name_status"] in sn.NAME_STATUSES, e["id"]
        assert e["kind"] in sn.KINDS, e["id"]
        assert e.get("source"), e["id"]


def test_doc_and_table_bind_in_both_directions() -> None:
    cited = set(re.findall(r"`([a-z0-9][a-z0-9./-]*)`", DOC.read_text(encoding="utf-8")))
    assert set(BY_ID) <= cited, sorted(set(BY_ID) - cited)
    anchored = set(re.findall(r"<a id=\"([a-z0-9./-]+)\"></a>", DOC.read_text(encoding="utf-8")))
    assert anchored == set(BY_ID), sorted(anchored ^ set(BY_ID))


# The oracles are independent of the table; pin them on textbook instances.

def test_limb_angles_of_main_cardioid() -> None:
    F = Fraction
    assert sn.rotation_angles(F(1, 2)) == (F(1, 3), F(2, 3))
    assert sn.rotation_angles(F(1, 3)) == (F(1, 7), F(2, 7))
    assert sn.rotation_angles(F(2, 3)) == (F(5, 7), F(6, 7))
    assert sn.rotation_angles(F(2, 5)) == (F(9, 31), F(10, 31))


def test_parabolic_and_center_oracles() -> None:
    F = Fraction
    assert sn.parabolic_of_period(F(1, 4), 1)
    assert sn.parabolic_of_period(F(-3, 4), 2)
    assert sn.parabolic_of_period(F(-5, 4), 4)
    assert sn.parabolic_of_period(F(-7, 4), 3)
    assert not sn.parabolic_of_period(F(-1), 2)
    assert not sn.parabolic_of_period(F(-3, 4), 4)  # parabolic, but of period 2
    assert sn.exact_center_factor([1, 1, 2, 1], 3)  # 1 + c + 2c^2 + c^3
    assert not sn.exact_center_factor([1, 1], 3)  # c + 1: period 2


def test_critical_orbit_type_on_gaussian_rationals() -> None:
    F = Fraction
    assert sn.critical_orbit_type((F(-2), F(0))) == (1, 1)
    assert sn.critical_orbit_type((F(0), F(1))) == (1, 2)
    assert sn.critical_orbit_type((F(-1), F(0))) is None  # periodic, not preperiodic


@pytest.mark.parametrize(
    "field, wrong",
    [
        ("root_angles", ["1/7", "3/7"]),
        ("period", 5),
        ("internal_address", [1, 2]),
        ("root_parameter", "-1/4"),
    ],
)
def test_checks_reject_corrupted_data(field: str, wrong: object) -> None:
    corrupted = {**BY_ID["bulb-1/3"], field: wrong}
    assert sn.check_entry(corrupted, BY_ID) != []


def test_exact_type_refuses_angles_outside_the_circle_and_past_the_bound() -> None:
    """An angle outside [0, 1) or with denominator past 2^20 is malformed data,
    reported by the checks rather than reduced into a valid-looking type."""
    for theta in (Fraction(1), Fraction(-1, 3), Fraction(4, 3), Fraction(1, (1 << 20) + 1)):
        assert sn.exact_type(theta) is None, theta
    assert sn.exact_type(Fraction(1, 1 << 20)) == (20, 1)
    assert sn.exact_type(Fraction(1, 6)) == (1, 2)


def test_reference_main_passes() -> None:
    result = subprocess.run(
        [sys.executable, "reference/python/atlas/structure_names_reference.py"],
        cwd=ROOT, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_doc_passes_terminology_audit() -> None:
    result = subprocess.run(
        [sys.executable, "tools/audit_terminology.py"], cwd=ROOT, capture_output=True, text=True, check=False,
    )
    assert result.returncode == 0, result.stdout


# Relations between entries: complex conjugation and tuning images.

def test_declared_relations_are_present() -> None:
    assert BY_ID["bulb-2/3"]["conjugate_of"] == "bulb-1/3"
    assert BY_ID["c-minus-i"]["conjugate_of"] == "c-i"
    assert BY_ID["co-rabbit"]["conjugate_of"] == "douady-rabbit"
    assert BY_ID["scepter-valley"]["tuning_of"] == {"image_of": "seahorse-valley", "by": "bulb-1/2"}
    assert BY_ID["double-spiral-valley"]["tuning_of"] == {"image_of": "elephant-valley", "by": "bulb-1/2"}


def test_conjugation_maps_angles_to_their_negatives() -> None:
    F = Fraction
    assert sn.conjugate_angles([F(1, 7), F(2, 7)]) == [F(5, 7), F(6, 7)]
    assert sn.conjugate_angles([F(0)]) == [F(0)]


@pytest.mark.parametrize(
    "entry_id, wrong",
    [("bulb-2/3", "bulb-1/4"), ("c-minus-i", "tip"), ("co-rabbit", "basilica"), ("bulb-2/3", "no-such-entry")],
)
def test_wrong_conjugate_is_refused(entry_id: str, wrong: str) -> None:
    assert sn.check_entry({**BY_ID[entry_id], "conjugate_of": wrong}, BY_ID) != []


def test_a_component_is_not_its_own_conjugate_unless_real() -> None:
    assert sn.check_entry({**BY_ID["bulb-1/3"], "conjugate_of": "bulb-1/3"}, BY_ID) != []


def test_tuning_image_terms_are_satellites_of_the_tuning_component() -> None:
    """Each tuned term of the image has period n q, one kneading sequence on both
    rays, and internal address that of the tuning component extended by n q --
    read off the kneading sequence, independent of how the angles were tuned."""
    terms = sn.tuning_image_terms(BY_ID["seahorse-valley"], BY_ID["bulb-1/2"], BY_ID)
    assert terms and all(t["address"] == [1, 2, 2 * t["rotation"].denominator] for t in terms)


@pytest.mark.parametrize(
    "wrong",
    [{"image_of": "seahorse-valley", "by": "bulb-1/3"}, {"image_of": "triple-spiral-valley", "by": "bulb-1/2"},
     {"image_of": "no-such-valley", "by": "bulb-1/2"}],
)
def test_wrong_tuning_image_is_refused(wrong: dict) -> None:
    assert sn.check_entry({**BY_ID["scepter-valley"], "tuning_of": wrong}, BY_ID) != []
