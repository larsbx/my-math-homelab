"""The structure streams: valleys and the golden-mean convergents as finite objects.

A valley of the atlas has no boundary, but the limbs that fill it do: the
`p/q`-limbs whose rotation numbers tend to a target along its Farey parents.
`kernel/mojo/entrypoints/structure_streams.mojo` prints each valley's stream,
and the golden-mean convergent limbs, with exact root angles. This test runs it
and checks every term against the Python atlas oracles, which find limb angles
by a different method (searching the doubling cycles rather than reading the
rotation itinerary), and binds the emitted valleys to the atlas both ways.
"""

from __future__ import annotations

import json
import subprocess
import sys
from fractions import Fraction
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "tools"))
from mojo_include import mojo_run  # noqa: E402

from reference.python.atlas import structure_names_reference as sn  # noqa: E402

SRC = "kernel/mojo/entrypoints/structure_streams.mojo"
ATLAS = {e["id"]: e for e in sn.load()}
REGIONS = {i: e for i, e in ATLAS.items() if e["kind"] == "region"}


def frac(pair: list[int]) -> Fraction:
    return Fraction(pair[0], pair[1])


@pytest.fixture(scope="module")
def streams() -> dict:
    result = subprocess.run(mojo_run(SRC), cwd=ROOT, capture_output=True, text=True, check=False)
    assert result.returncode == 0, result.stdout + result.stderr
    return json.loads(result.stdout, parse_float=lambda s: pytest.fail(f"float {s} in the streams"))


def test_sections(streams: dict) -> None:
    assert set(streams) == {"valleys", "convergents"}


def test_every_atlas_valley_is_emitted_and_nothing_else(streams: dict) -> None:
    assert {v["id"] for v in streams["valleys"]} == set(REGIONS)


@pytest.mark.parametrize("valley_id", sorted(REGIONS))
def test_valley_stream_matches_the_atlas_and_the_oracle(streams: dict, valley_id: str) -> None:
    valley = next(v for v in streams["valleys"] if v["id"] == valley_id)
    acc = REGIONS[valley_id]["accumulation"]
    parent, r = ATLAS[acc["parent"]], Fraction(acc["rotation"])
    assert valley["parent"] == acc["parent"] and frac(valley["rotation"]) == r
    expected = sn.farey_stream(r)
    assert [(t["side"], frac(t["limb"])) for t in valley["terms"]] == expected
    for t in valley["terms"]:
        lo, hi = sn.limb_angles(parent, frac(t["limb"]))
        assert (frac(t["lo"]), frac(t["hi"])) == (lo, hi)
        if parent["period"] == 1:
            assert rotation_pair_errors(lo, hi, frac(t["limb"])) == []
        assert frac(t["width"]) == hi - lo
        assert t["period"] == parent["period"] * frac(t["limb"]).denominator
    assert sn.accumulation_errors(parent, r) == []


def test_tuning_images_are_the_tuned_streams(streams: dict) -> None:
    by_id = {v["id"]: v for v in streams["valleys"]}
    for vid, e in REGIONS.items():
        if "tuning_of" not in e:
            continue
        by = ATLAS[e["tuning_of"]["by"]]
        lo, hi = sn.root_pair(by)
        image = by_id[e["tuning_of"]["image_of"]]["terms"]
        tuned = [(sn.kr.tune_angle(lo, hi, frac(t["lo"])), sn.kr.tune_angle(lo, hi, frac(t["hi"]))) for t in image]
        assert [(frac(t["lo"]), frac(t["hi"])) for t in by_id[vid]["terms"]] == tuned


def test_main_cardioid_wakes_have_width_one_over_two_to_the_q_minus_one(streams: dict) -> None:
    for v in streams["valleys"]:
        if v["parent"] == "main-cardioid":
            for t in v["terms"]:
                assert frac(t["width"]) == Fraction(1, 2 ** frac(t["limb"]).denominator - 1)


def rotation_pair_errors(lo: Fraction, hi: Fraction, r: Fraction) -> list[str]:
    """The defining property, checked directly at any q: `lo < hi` lie on one period-q doubling cycle
    on which doubling moves every angle p places in cyclic order, and bound its shortest gap."""
    p, q = r.numerator, r.denominator
    cycle = sorted({sn.doubling(lo, i) for i in range(q)})
    if len(cycle) != q or sn.doubling(lo, q) != lo or hi not in cycle:
        return ["not one period-q cycle"]
    if any(sn.doubling(cycle[i]) != cycle[(i + p) % q] for i in range(q)):
        return ["doubling is not rotation by p/q on the cycle"]
    gaps = sorted(((cycle[(i + 1) % q] - cycle[i]) % 1, cycle[i]) for i in range(q))
    return [] if gaps[0][1] == lo and gaps[0][0] == hi - lo and gaps[0][0] < gaps[1][0] else ["not the shortest gap"]


def test_golden_mean_convergents(streams: dict) -> None:
    (stream,) = streams["convergents"]
    assert stream["id"] == "golden-mean-siegel"
    rotations = [frac(t["limb"]) for t in stream["terms"]]
    atlas = [Fraction(c) for c in ATLAS["golden-mean-siegel"]["convergents"] if 0 < Fraction(c) < 1]
    assert rotations[: len(atlas)] == atlas and len(rotations) > len(atlas)
    for t in stream["terms"]:
        r, pair = frac(t["limb"]), (frac(t["lo"]), frac(t["hi"]))
        assert rotation_pair_errors(*pair, r) == []
        if r.denominator <= sn.MAX_ROTATION_DENOMINATOR:
            assert pair == sn.rotation_angles(r)
        assert t["farey_adjacent_to_previous"] == (t is not stream["terms"][0])
    fib = [1, 1]
    while len(fib) < len(rotations) + 3:
        fib.append(fib[-1] + fib[-2])
    assert rotations == [Fraction(fib[i], fib[i + 1]) for i in range(1, len(rotations) + 1)]


def word(theta: Fraction, q: int) -> str:
    return format(theta.numerator * ((2**q - 1) // theta.denominator), f"0{q}b")


def test_root_words_of_a_limb_differ_only_in_their_last_two_digits() -> None:
    """theta_- = w01 and theta_+ = w10 as q-digit periodic words, for every reduced p/q, q <= 14."""
    for q in range(2, 15):
        for p in range(1, q):
            if Fraction(p, q).denominator == q:
                lo, hi = (word(t, q) for t in sn.rotation_angles(Fraction(p, q)))
                assert lo[:-2] == hi[:-2] and (lo[-2:], hi[-2:]) == ("01", "10"), (p, q)


def test_limbs_tuned_by_the_half_bulb_have_wake_width_three_over_four_to_the_q_minus_one(streams: dict) -> None:
    """Tuning by (1/3, 2/3) reads the words in base four with digits 1, 2, so the last-two-digit
    difference 01 -> 10 becomes 3 / (4^q - 1): the wakes in Scepter and Double Spiral Valley are
    3 / (2^q + 1) times the widths of the main-cardioid limbs they are images of."""
    for v in streams["valleys"]:
        if v["parent"] == "bulb-1/2":
            for t in v["terms"]:
                q = frac(t["limb"]).denominator
                assert frac(t["width"]) == Fraction(3, 4**q - 1)
