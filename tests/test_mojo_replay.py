"""The Mojo kernel and the Python reference oracle must decide the same thing.

Two checks live here. The first needs no toolchain: the numeric codes the two
implementations exchange are declared in both, and a divergence would let a
transcript be compared under two different encodings. The second runs the
Mojo driver and compares its transcript line for line, and is skipped where no
Mojo toolchain is installed -- the container that writes this repository has
none, so CI is where that check first runs.
"""

import re
import shutil
import subprocess
from pathlib import Path

import pytest

from julia_reference import (
    MULTIPLIER_CODE,
    MULTIPLIER_CODE_NONE,
    OrbitVerdict,
    classify_multiplier,
    critical_orbit,
    multiplier,
)
from parameter_corpus import CORPUS

ROOT = Path(__file__).resolve().parents[1]
KERNEL = ROOT / "kernel" / "julia_orbit.mojo"
TRANSCRIPT_DRIVER = ROOT / "kernel" / "corpus_transcript.mojo"

#: The Mojo replay's step budget, declared by the generated corpus.
MOJO_HORIZON = int(re.search(r"alias MOJO_HORIZON = (\d+)", (ROOT / "kernel" / "parameter_corpus.mojo").read_text()).group(1))

#: Large enough that the Mojo horizon, not the bit budget, is what runs out.
REPLAY_BIT_BUDGET = 1 << 30

ORBIT_NAMES = {
    OrbitVerdict.ESCAPES: "ESCAPES",
    OrbitVerdict.PREPERIODIC: "PREPERIODIC",
    OrbitVerdict.CAPPED: "CAPPED",
}


def mojo_aliases() -> dict[str, int]:
    text = KERNEL.read_text(encoding="utf-8")
    return {name: int(value) for name, value in re.findall(r"alias ((?:MULT|ORBIT)_\w+) = (-?\d+)", text)}


def test_multiplier_codes_agree():
    aliases = mojo_aliases()
    for cls, code in MULTIPLIER_CODE.items():
        assert aliases[f"MULT_{cls.value}"] == code
    assert aliases["MULT_NONE"] == MULTIPLIER_CODE_NONE


def test_orbit_codes_agree():
    aliases = mojo_aliases()
    assert aliases["ORBIT_ESCAPES"] == 0
    assert aliases["ORBIT_PREPERIODIC"] == 1
    assert aliases["ORBIT_CAPPED"] == 2


def reference_transcript() -> list[str]:
    lines = []
    for row in CORPUS:
        orbit = critical_orbit(row.c, horizon=MOJO_HORIZON, bit_budget=REPLAY_BIT_BUDGET)
        first, second = -1, -1
        if orbit.verdict is OrbitVerdict.ESCAPES:
            first = orbit.escape_index
        elif orbit.verdict is OrbitVerdict.PREPERIODIC:
            first, second = orbit.preperiod, orbit.period
        code = (
            MULTIPLIER_CODE_NONE
            if row.cycle is None
            else MULTIPLIER_CODE[classify_multiplier(multiplier(row.cycle))]
        )
        lines.append(f"{row.key}\t{ORBIT_NAMES[orbit.verdict]}\t{first}\t{second}\t{code}")
    return lines


def test_reference_transcript_is_well_formed():
    lines = reference_transcript()
    assert len(lines) == len(CORPUS)
    assert all(len(line.split("\t")) == 5 for line in lines)


@pytest.mark.skipif(shutil.which("mojo") is None, reason="mojo binary not on PATH")
def test_mojo_transcript_matches_the_reference():
    result = subprocess.run(
        ["mojo", "run", "-I", str(ROOT / "vendor" / "mojo"), str(TRANSCRIPT_DRIVER)], capture_output=True, text=True, cwd=ROOT, check=False
    )
    assert result.returncode == 0, result.stdout + result.stderr
    actual = [line for line in result.stdout.splitlines() if line.strip()]
    assert actual == reference_transcript()
