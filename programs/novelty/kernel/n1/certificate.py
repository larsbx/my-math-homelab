"""Independent checker for N1 certificates (schemas/n1-certificate-v1.json).

The checker trusts nothing the search reports. It accepts a certificate only
when its finite content verifies by exact arithmetic:

* ``zero_divisor`` — nonzero x, y ∈ A_n with xy = 0, multiplied out under
  ``cayley-dickson/v1``. Sound without imported theorems: an algebra with a
  zero divisor is not a division algebra.
* ``division`` — n = 2 only, and a place v with (a_1, a_2)_v = -1. Sound
  modulo the imported records `HilbertSymbolFormula` and
  `QuaternionSplitIffConic` (research/ledger.json).

Anything else is refused with a reason; refusal never means the opposite
verdict holds.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from fractions import Fraction

from n1 import cayley_dickson as cd
from n1.hilbert import hilbert

SCHEMA = "novelty-lab/n1-certificate/v1"
CONVENTION = "cayley-dickson/v1"
RATIONAL = re.compile(r"^-?(0|[1-9][0-9]*)(/[1-9][0-9]*)?$")
KEYS = {"schema", "field", "convention", "parameters", "verdict", "witness"}


@dataclass(frozen=True)
class Verdict:
    accepted: bool
    reason: str


def rational(text: object) -> Fraction:
    """A rational written canonically as ``p`` or ``p/q`` in lowest terms."""
    if not isinstance(text, str) or not RATIONAL.match(text):
        raise ValueError(f"not a canonical rational: {text!r}")
    value = Fraction(text)
    if str(value) != text:
        raise ValueError(f"not in lowest terms: {text!r}")
    return value


def element(xs: object, n: int) -> cd.Element:
    if not isinstance(xs, list) or len(xs) != 1 << n:
        raise ValueError(f"element must list 2^{n} rationals")
    return tuple(map(rational, xs))


def _zero_divisor(params: cd.Params, witness: dict) -> Verdict:
    n = len(params)
    x, y = element(witness.get("x"), n), element(witness.get("y"), n)
    if not any(x) or not any(y):
        return Verdict(False, "witness factors must be nonzero")
    if any(cd.mul(x, y, params)):
        return Verdict(False, "witness product is not zero")
    return Verdict(True, f"xy = 0 in A_{n}")


def _division(params: cd.Params, witness: dict) -> Verdict:
    if len(params) != 2:
        return Verdict(False, "division certificates are defined for n = 2 only")
    place = witness.get("place")
    if not isinstance(place, str):
        return Verdict(False, "division witness must name a place")
    if hilbert(*params, place) != -1:
        return Verdict(False, f"Hilbert symbol at {place} is +1")
    return Verdict(True, f"(a_1, a_2)_{place} = -1")


CHECKS = {"zero_divisor": ({"x", "y"}, _zero_divisor), "division": ({"place"}, _division)}


def check(cert: object) -> Verdict:
    """Accept or refuse a parsed certificate; never raises on malformed input."""
    try:
        if not isinstance(cert, dict) or set(cert) != KEYS:
            return Verdict(False, f"certificate must have exactly the keys {sorted(KEYS)}")
        if (cert["schema"], cert["field"], cert["convention"]) != (SCHEMA, "Q", CONVENTION):
            return Verdict(False, "unsupported schema, field, or convention")
        params = cert["parameters"]
        if not isinstance(params, list) or not 1 <= len(params) <= 8:
            return Verdict(False, "parameters must list 1..8 rationals")
        params = tuple(map(rational, params))
        if 0 in params:
            return Verdict(False, "parameters must be nonzero")
        keys, check_verdict = CHECKS.get(cert["verdict"], (None, None))
        if keys is None or not isinstance(cert["witness"], dict) or set(cert["witness"]) != keys:
            return Verdict(False, "unknown verdict or malformed witness")
        return check_verdict(params, cert["witness"])
    except (ValueError, TypeError) as exc:
        return Verdict(False, str(exc))
