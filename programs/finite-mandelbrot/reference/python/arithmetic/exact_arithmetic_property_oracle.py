#!/usr/bin/env python3
"""Independent oracle for the BigZ / Q / IQ property probe.

Specification: docs/rational-interval-arithmetic-spec.md (section 7, law tests).
Public boundary: docs/exact-arithmetic-public-boundary.md.

The Mojo probe ``kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo`` prints a transcript
of canonical byte encodings. This script regenerates the same operands from
the same xorshift64* stream, recomputes every result with Python ``int`` and
``fractions.Fraction``, encodes the expectation with the canonical
``Z(sign, byte_len, big_endian_magnitude)`` layout of
``docs/canonical-serialization.md``, and compares token by token. Nothing
printed by Mojo is parsed into a number: agreement is on bytes and codes.

Every run first checks the generators against their declared refinement
(``docs/generator-refinement-spec.md`` in ``larsbx/finite-math-kernels``,
whose ``oracle_refinement`` package is vendored here), because a differential
comparison is only as strong as the corpus it draws from.

Usage:
    exact_arithmetic_property_oracle.py              run ``mojo`` and compare
    exact_arithmetic_property_oracle.py TRANSCRIPT   compare a saved transcript
    exact_arithmetic_property_oracle.py --distribution   report phi_G only

Exit status 0 on agreement, 1 on any mismatch or on a corpus that departs from
its declaration, 2 when ``mojo`` is unavailable.
"""

from __future__ import annotations

import math
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from mojo_include import mojo_run  # noqa: E402

from oracle_refinement import Class, Refinement, audit_all  # noqa: E402

PROBE = ROOT / "kernel/mojo/arithmetic/exact_arithmetic_property_probe.mojo"

BASE = 10**9
MASK64 = (1 << 64) - 1
SEED = 11400714819323198485
Z_CASES, Q_CASES, I_CASES, MAX_LIMBS = 300, 200, 120, 6
HEADER = f"HEADER exact-arithmetic-property-probe 1 {SEED} {Z_CASES} {Q_CASES} {I_CASES}"


# --- generator (must match the Mojo probe call for call) -------------------


class Xorshift64Star:
    def __init__(self, seed: int) -> None:
        self.state = seed & MASK64

    def next(self) -> int:
        x = self.state
        x ^= x >> 12
        x ^= (x << 25) & MASK64
        x ^= x >> 27
        self.state = x
        return (x * 2685821657736338717) & MASK64


@dataclass
class Draws:
    """Every value each declared generator produced, nested calls included.

    A fraction draws two integers and an interval draws two fractions, so
    auditing only the operands a layer prints would judge `random_int` on a
    fraction of its own output. Passing a `Draws` changes nothing about the
    stream: the recorder is a parameter the transcript path never supplies."""

    integers: list[int] = field(default_factory=list)
    fractions: list[Fraction] = field(default_factory=list)
    intervals: list[tuple[Fraction, Fraction]] = field(default_factory=list)


def random_int(rng: Xorshift64Star, max_limbs: int = MAX_LIMBS, draws: Draws | None = None) -> int:
    if rng.next() % 4 == 0:
        value = rng.next() % 2001 - 1000
        if draws is not None:
            draws.integers.append(value)
        return value
    count = rng.next() % max_limbs + 1
    limbs = []
    for _ in range(count):
        pick = rng.next()
        limbs.append(BASE - 1 if pick % 5 == 0 else pick % BASE)
    value = sum(limb * BASE**i for i, limb in enumerate(limbs))
    if value != 0 and rng.next() % 2 == 1:
        value = -value
    if draws is not None:
        draws.integers.append(value)
    return value


def random_nonzero_int(rng: Xorshift64Star, draws: Draws | None = None) -> int:
    return random_int(rng, draws=draws) or 1


def random_fraction(rng: Xorshift64Star, draws: Draws | None = None) -> Fraction:
    numerator = random_int(rng, draws=draws)
    value = Fraction(numerator, random_nonzero_int(rng, draws=draws))
    if draws is not None:
        draws.fractions.append(value)
    return value


def random_interval(rng: Xorshift64Star, draws: Draws | None = None) -> tuple[Fraction, Fraction]:
    a, b = random_fraction(rng, draws=draws), random_fraction(rng, draws=draws)
    value = (min(a, b), max(a, b))
    if draws is not None:
        draws.intervals.append(value)
    return value


# --- phi_G: what these generators produce, and what they do not ---------------
#
# `larsbx/finite-math-kernels: docs/generator-refinement-spec.md`. The stream is
# deterministic, so these are exact statements about a fixed corpus. A class
# declared missed names the branch of the transcript grammar it leaves
# unexercised; declaring the gap is how it becomes a finding rather than a
# silence.

INTEGER = Refinement(
    "random_int",
    f"an integer of at most {MAX_LIMBS} base-{BASE} limbs, either sign",
    lambda v: isinstance(v, int) and abs(v) < BASE**MAX_LIMBS,
    (
        Class("negative", lambda v: v < 0),
        Class("small", lambda v: abs(v) <= 1000),
        Class("beyond 64 bits", lambda v: abs(v) >= 1 << 63),
        Class("a maximal limb", lambda v: (BASE - 1) in limbs_of(v)),
        Class("zero", lambda v: v == 0,
              reason="the small branch draws one of 2001 values and the limb branch sums "
                     "non-zero-biased limbs, so this stream never lands on it; the `Z` "
                     "division-by-zero branch of the grammar is therefore unexercised"),
        Class("a unit", lambda v: abs(v) == 1,
              reason="same window, and this stream misses it; the sign and gcd edges at "
                     "plus or minus one are covered only by the known-answer suites"),
    ),
)

FRACTION = Refinement(
    "random_fraction",
    f"a rational whose parts are each an integer of at most {MAX_LIMBS} base-{BASE} limbs",
    lambda v: (isinstance(v, Fraction) and v.denominator > 0
               and abs(v.numerator) < BASE**MAX_LIMBS and v.denominator < BASE**MAX_LIMBS),
    (
        Class("negative", lambda v: v < 0),
        Class("proper", lambda v: abs(v) < 1),
        Class("zero", lambda v: v == 0,
              reason="its numerator is random_int, which this stream never draws at zero; "
                     "the `Q` division-by-zero branch is therefore unexercised"),
        Class("integer-valued", lambda v: v.denominator == 1,
              reason="both parts are drawn independently from a wide range, so this stream "
                     "never cancels to one; canonicalisation to denominator one is covered "
                     "only by the known-answer suites"),
    ),
)

INTERVAL = Refinement(
    "random_interval",
    "a closed interval whose endpoints are two draws of random_fraction, lo <= hi",
    lambda v: (isinstance(v, tuple) and len(v) == 2 and v[0] <= v[1]
               and all(FRACTION.holds(end) for end in v)),
    (
        Class("straddling zero", lambda v: v[0] < 0 < v[1]),
        Class("strictly positive", lambda v: v[0] > 0),
        Class("strictly negative", lambda v: v[1] < 0),
        Class("degenerate", lambda v: v[0] == v[1],
              reason="both endpoints are independent rationals over a wide range, so this "
                     "stream never draws them equal; the point-interval reciprocal and sign "
                     "paths are therefore unexercised"),
    ),
)

REFINEMENTS = (INTEGER, FRACTION, INTERVAL)


def limbs_of(value: int) -> list[int]:
    """The base-BASE limbs of a magnitude, least significant first."""
    magnitude, limbs = abs(value), []
    while magnitude:
        magnitude, limb = divmod(magnitude, BASE)
        limbs.append(limb)
    return limbs or [0]


def drawn() -> Draws:
    """Every value the transcript's stream produces, nested draws included."""
    rng, draws = Xorshift64Star(SEED), Draws()
    for _ in range(Z_CASES):
        random_int(rng, draws=draws), random_int(rng, draws=draws)
    for _ in range(Q_CASES):
        random_fraction(rng, draws=draws), random_fraction(rng, draws=draws)
    for _ in range(I_CASES):
        random_interval(rng, draws=draws), random_interval(rng, draws=draws)
    return draws


def distribution_problems() -> tuple[str, ...]:
    """Every way the realized corpus departs from the declarations above."""
    draws = drawn()
    return audit_all(zip(REFINEMENTS, (draws.integers, draws.fractions, draws.intervals)))


# --- canonical encodings -----------------------------------------------------


def encode_z(value: int) -> str:
    sign = 0 if value == 0 else (1 if value > 0 else 2)
    magnitude = abs(value).to_bytes((abs(value).bit_length() + 7) // 8, "big")
    return ".".join(str(b) for b in bytes([sign]) + len(magnitude).to_bytes(8, "big") + magnitude)


def encode_q(value: Fraction) -> str:
    return encode_z(value.numerator) + "." + encode_z(value.denominator)


def code(flag: bool) -> str:
    return "1" if flag else "0"


def trunc_divmod(a: int, b: int) -> tuple[int, int]:
    """Truncating quotient with remainder carrying the dividend's sign."""
    q = abs(a) // abs(b)
    if (a < 0) != (b < 0):
        q = -q
    return q, a - q * b


def interval_tokens(lo: Fraction, hi: Fraction) -> list[str]:
    return [encode_q(lo), encode_q(hi)]


def interval_mul(x: tuple[Fraction, Fraction], y: tuple[Fraction, Fraction]) -> tuple[Fraction, Fraction]:
    products = [x[0] * y[0], x[0] * y[1], x[1] * y[0], x[1] * y[1]]
    return (min(products), max(products))


# --- expected transcript -----------------------------------------------------


def expected_lines() -> list[str]:
    rng = Xorshift64Star(SEED)
    lines = [HEADER]
    for index in range(Z_CASES):
        a, b = random_int(rng), random_int(rng)
        gcd = math.gcd(a, b)
        if b == 0:
            quotient = ["rejected", "rejected"]
        else:
            q, r = trunc_divmod(a, b)
            quotient = [encode_z(q), encode_z(r)]
        lines.append(" ".join([
            "Z", str(index), encode_z(a), encode_z(b), encode_z(a + b), encode_z(a - b), encode_z(a * b),
            code(a < b), code(a == b), encode_z(gcd), *quotient, "1",
        ]))
    for index in range(Q_CASES):
        a, b = random_fraction(rng), random_fraction(rng)
        lines.append(" ".join([
            "Q", str(index), encode_q(a), encode_q(b), encode_q(a + b), encode_q(a - b), encode_q(a * b),
            "rejected" if b == 0 else encode_q(a / b), code(a < b), code(a <= b), code(a == b), "1",
        ]))
    for index in range(I_CASES):
        x, y = random_interval(rng), random_interval(rng)
        total = (x[0] + y[0], x[1] + y[1])
        difference = (x[0] - y[1], x[1] - y[0])
        product = interval_mul(x, y)
        sign = 1 if x[0] > 0 else (-1 if x[1] < 0 else 0)
        reciprocal = ["rejected", "rejected"] if sign == 0 else interval_tokens(1 / x[1], 1 / x[0])
        lines.append(" ".join([
            "I", str(index), *interval_tokens(*x), *interval_tokens(*y), *interval_tokens(*total),
            *interval_tokens(*difference), *interval_tokens(*product), str(sign), *reciprocal, "1",
        ]))
    lines.append("END")
    return lines


def compare(actual: list[str]) -> list[str]:
    expected = expected_lines()
    errors: list[str] = []
    if len(actual) != len(expected):
        errors.append(f"transcript has {len(actual)} lines, expected {len(expected)}")
    for lineno, (want, got) in enumerate(zip(expected, actual), start=1):
        if want == got:
            continue
        want_tokens, got_tokens = want.split(" "), got.split(" ")
        first = next((i for i, (w, g) in enumerate(zip(want_tokens, got_tokens)) if w != g), min(len(want_tokens), len(got_tokens)))
        errors.append(f"line {lineno} token {first}: expected {want_tokens[first] if first < len(want_tokens) else '<none>'!r}, got {got_tokens[first] if first < len(got_tokens) else '<none>'!r}")
        if len(errors) >= 20:
            errors.append("... further mismatches suppressed")
            break
    return errors


def run_probe() -> list[str] | None:
    mojo = shutil.which("mojo")
    if mojo is None:
        return None
    result = subprocess.run(mojo_run(str(PROBE.relative_to(ROOT)), mojo), cwd=ROOT, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"mojo probe failed with status {result.returncode}:\n{result.stderr}")
    return [line for line in result.stdout.splitlines() if line.strip()]


def report_distribution() -> int:
    """The declarations of `REFINEMENTS` against the corpus this stream draws."""
    problems = distribution_problems()
    if problems:
        print("The generators no longer match their declared refinement:\n")
        print("\n".join(f"  {p}" for p in problems))
        return 1
    for refinement in REFINEMENTS:
        print(f"{refinement.name}: reaches {', '.join(refinement.reached())}")
        for cls in refinement.classes:
            if not cls.required:
                print(f"  misses {cls.name}: {cls.reason}")
    return 0


def main(argv: list[str]) -> int:
    if argv[1:] == ["--distribution"]:
        return report_distribution()
    # A differential run is only as strong as the corpus it draws, so the
    # declaration is checked before the comparison it qualifies.
    problems = distribution_problems()
    if problems:
        print("The generators no longer match their declared refinement:\n")
        print("\n".join(f"  {p}" for p in problems))
        print("\nSee docs/generator-refinement-spec.md in larsbx/finite-math-kernels.")
        return 1
    if len(argv) > 1:
        actual = [line for line in Path(argv[1]).read_text(encoding="utf-8").splitlines() if line.strip()]
    else:
        actual = run_probe()
        if actual is None:
            print("mojo is not on PATH; run inside `pixi run` or pass a saved transcript.")
            return 2
    errors = compare(actual)
    if errors:
        print("Exact-arithmetic property probe disagrees with the Python oracle:\n")
        print("\n".join(errors))
        return 1
    print(f"OK: property probe agrees with the oracle on {Z_CASES} integer, {Q_CASES} rational, and {I_CASES} interval cases.")
    missed = [f"{r.name}/{c.name}" for r in REFINEMENTS for c in r.classes if not c.required]
    print(f"OK: the corpus meets its declared refinement; classes it is declared to miss: {', '.join(missed)}.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
