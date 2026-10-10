#!/usr/bin/env python3
"""Exact checks for the names atlas, `schemas/structure_names.toml`.

Every common name in the atlas is keyed to exact data, and every datum is
recomputed here over `Fraction`: exact types of rational angles under
doubling, internal addresses, limb angles by rotation number and by tuning,
parabolic parameters as repeated roots of `f_c^n(z) - z`, centres as factors of
the Gleason polynomial `f_c^n(0)` isolated by a Sturm count, and critical-orbit
types of Gaussian-rational parameters. No floating point.

The checks are statements about exact symbols. Tying an angle pair to a
component, or a component to a picture, is the landing theorem, imported and
not computed here. Usage: structure_names_reference.py
"""

from __future__ import annotations

import sys
import tomllib
from fractions import Fraction
from functools import reduce
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT))

from reference.python.c1 import kneading_reference as kr  # noqa: E402

TABLE = ROOT / "schemas/structure_names.toml"
NAME_STATUSES = ("field", "eponym", "folk")
KINDS = (
    "class",
    "hyperbolic-component",
    "cascade",
    "misiurewicz-parameter",
    "boundary-parameter",
    "region",
    "julia-set",
)
MAX_ROTATION_DENOMINATOR = 14
ACCUMULATION_DEPTH = 6

Poly = tuple[Fraction, ...]  # ascending coefficients, trimmed


# --- exact univariate polynomials over Q ------------------------------------

def poly(*coeffs) -> Poly:
    out = [Fraction(c) for c in coeffs]
    while out and out[-1] == 0:
        out.pop()
    return tuple(out)


def add(p: Poly, q: Poly) -> Poly:
    n = max(len(p), len(q))
    return poly(*((p[i] if i < len(p) else 0) + (q[i] if i < len(q) else 0) for i in range(n)))


def mul(p: Poly, q: Poly) -> Poly:
    out = [Fraction(0)] * (len(p) + len(q) - 1 if p and q else 0)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            out[i + j] += a * b
    return poly(*out)


def rem(p: Poly, d: Poly) -> Poly:
    r = list(p)
    while len(r) >= len(d):
        k, s = len(r) - len(d), r[-1] / d[-1]
        r = [r[i] - (s * d[i - k] if i >= k else 0) for i in range(len(r))]
        r = list(poly(*r))
    return tuple(r)


def gcd(p: Poly, q: Poly) -> Poly:
    while q:
        p, q = q, rem(p, q)
    return p


def deriv(p: Poly) -> Poly:
    return poly(*(i * a for i, a in enumerate(p) if i))


def evaluate(p: Poly, x: Fraction) -> Fraction:
    return reduce(lambda acc, a: acc * x + a, reversed(p), Fraction(0))


def iterate(seed: Poly, c: Poly, n: int) -> Poly:
    """`f^n(seed)` for `f(w) = w^2 + c`, both as polynomials in one variable."""
    return reduce(lambda w, _: add(mul(w, w), c), range(n), seed)


def proper_divisors(n: int) -> list[int]:
    return [d for d in range(1, n) if n % d == 0]


# --- the quadratic family ---------------------------------------------------

def periodic_poly(c: Fraction, n: int) -> Poly:
    """`f_c^n(z) - z` in `z` for rational `c`."""
    return add(iterate(poly(0, 1), poly(c), n), poly(0, -1))


def squarefree(p: Poly) -> bool:
    return len(gcd(p, deriv(p))) == 1


def parabolic_of_period(c: Fraction, n: int) -> bool:
    """Some cycle has `f^n`-multiplier one, and none has `f^d`-multiplier one for `d | n`, `d < n`."""
    return not squarefree(periodic_poly(c, n)) and all(squarefree(periodic_poly(c, d)) for d in proper_divisors(n))


def gleason(n: int) -> Poly:
    """`f_c^n(0)` as a polynomial in `c`."""
    return iterate(poly(0), poly(0, 1), n)


def exact_center_factor(coeffs: list[int], n: int) -> bool:
    """The polynomial divides `f_c^n(0)` and shares no root with `f_c^d(0)` for `d | n`, `d < n`."""
    p = poly(*coeffs)
    return len(p) > 1 and rem(gleason(n), p) == () and all(len(gcd(p, gleason(d))) == 1 for d in proper_divisors(n))


def sturm_count(p: Poly, lo: Fraction, hi: Fraction) -> int:
    """Number of distinct real roots of `p` in `(lo, hi]`."""
    chain = [p, deriv(p)]
    while len(chain[-1]) > 1:
        chain.append(tuple(-a for a in rem(chain[-2], chain[-1])))
    chain = [q for q in chain if q]

    def variations(x: Fraction) -> int:
        signs = [s for s in (evaluate(q, x) for q in chain) if s != 0]
        return sum(1 for a, b in zip(signs, signs[1:]) if (a < 0) != (b < 0))

    return variations(lo) - variations(hi)


def critical_orbit_type(c: tuple[Fraction, Fraction], limit: int = 64) -> tuple[int, int] | None:
    """`(preperiod, period)` of the critical value `c` under `z -> z^2 + c` on Gaussian rationals,
    or None when the critical value is periodic or no repeat occurs within `limit` steps."""
    (x, y), seen = c, {}
    for k in range(limit):
        if (x, y) in seen:
            i = seen[(x, y)]
            return None if i == 0 else (i, k - i)
        seen[(x, y)] = k
        x, y = x * x - y * y + c[0], 2 * x * y + c[1]
    return None


# --- angles under doubling --------------------------------------------------

def angle(text: str) -> Fraction:
    return Fraction(text)


def doubling(theta: Fraction, n: int = 1) -> Fraction:
    return (theta * 2**n) % 1


#: The bound the Mojo catalogue holds addresses to.
MAX_ANGLE_DENOMINATOR = 1 << 20


def exact_type(theta: Fraction) -> tuple[int, int] | None:
    """`(preperiod, period)` of `theta` under doubling, read off the orbit's first
    repeat -- iteration, not the 2-adic valuation and multiplicative order the
    Mojo catalogue computes. None for an angle outside `[0, 1)` or with
    denominator past the bound: malformed data, never reduced into range."""
    if not 0 <= theta < 1 or theta.denominator > MAX_ANGLE_DENOMINATOR:
        return None
    seen: dict[Fraction, int] = {}
    point, step = theta, 0
    while point not in seen:
        seen[point] = step
        point, step = doubling(point), step + 1
    return seen[point], step - seen[point]


def internal_address(theta: Fraction) -> list[int]:
    if theta == 0:
        return [1]
    prefix = kr.kneading_prefix(theta)
    return kr.internal_address(prefix + [kr.continuation_last_letter(prefix)])


def rotation_angles(r: Fraction) -> tuple[Fraction, Fraction]:
    """Root angles of the `r`-limb of the main cardioid: the ends of the shortest gap of the unique
    period-`q` doubling cycle on which doubling moves each angle `p` places in cyclic order."""
    if r == 0:
        return (Fraction(0), Fraction(0))
    p, q = r.numerator, r.denominator
    assert 0 < r < 1 and q <= MAX_ROTATION_DENOMINATOR
    den = 2**q - 1
    cycles = {tuple(sorted(doubling(Fraction(k, den), i) for i in range(q))) for k in range(1, den)}
    rotating = [
        cyc for cyc in cycles
        if len(set(cyc)) == q and all(doubling(cyc[i]) == cyc[(i + p) % q] for i in range(q))
    ]
    assert len(rotating) == 1, r
    cyc = rotating[0]
    gaps = sorted(((cyc[(i + 1) % q] - cyc[i]) % 1, i) for i in range(q))
    assert gaps[0][0] < gaps[1][0], r
    i = gaps[0][1]
    return (cyc[i], cyc[(i + 1) % q])


def root_pair(entry: dict) -> tuple[Fraction, Fraction]:
    angles = [angle(a) for a in entry["root_angles"]]
    return (angles[0], angles[-1])


def limb_angles(parent: dict, r: Fraction) -> tuple[Fraction, Fraction]:
    """Root angles of the `r`-limb of `parent`: by rotation number on the main cardioid, by tuning elsewhere."""
    if parent["period"] == 1:
        return rotation_angles(r)
    lo, hi = root_pair(parent)
    if r == 0:
        return (lo, lo)
    return tuple(kr.tune_angle(lo, hi, t) for t in rotation_angles(r))


def farey_neighbours(r: Fraction) -> tuple[Fraction | None, Fraction | None]:
    """The Farey parents of `r` inside `[0, 1]`, below and above; None on the side `r` bounds."""
    p, q = r.numerator, r.denominator
    below = next((Fraction(a, b) for b in range(1, q) for a in range(b + 1) if p * b - a * q == 1), None)
    above = next((Fraction(a, b) for b in range(1, q + 1) for a in range(b + 1) if a * q - p * b == 1), None)
    return (below if r > 0 else None, above if r < 1 else None)


def farey_stream(r: Fraction) -> list[tuple[str, Fraction]]:
    """Rotation numbers tending to `r` along its Farey parents, `(side, s)` with side "below" or "above",
    to ACCUMULATION_DEPTH terms within MAX_ROTATION_DENOMINATOR."""
    below, above = farey_neighbours(r)
    return [
        (side, Fraction(n * r.numerator + nb.numerator, n * r.denominator + nb.denominator))
        for side, nb in (("below", below), ("above", above)) if nb is not None
        for n in range(1, ACCUMULATION_DEPTH + 1)
        if n * r.denominator + nb.denominator <= MAX_ROTATION_DENOMINATOR
    ]


def accumulation_errors(parent: dict, r: Fraction) -> list[str]:
    """The limbs of `parent` whose rotation numbers tend to `r` along Farey sequences have root
    angles that move strictly monotonically toward the root angles of the `r`-limb."""
    target = limb_angles(parent, r)
    errors = []
    for side, pick, bound_ok, step_ok in (
        ("below", 0, lambda a: a < target[0], lambda a, b: a < b),
        ("above", 1, lambda a: a > target[1], lambda a, b: a > b),
    ):
        ends = [limb_angles(parent, s)[pick] for d, s in farey_stream(r) if d == side]
        if not all(bound_ok(a) for a in ends) or not all(step_ok(a, b) for a, b in zip(ends, ends[1:])):
            errors.append(f"limbs accumulating on {r} from {side} are not monotone toward it")
    return errors


# --- relations between entries ----------------------------------------------

def conjugate_angles(angles) -> list[Fraction]:
    """Complex conjugation acts on external angles as theta -> -theta modulo one."""
    return sorted((1 - Fraction(a)) % 1 for a in angles)


def _same_if_both(e: dict, f: dict, key: str) -> bool:
    return key not in e or key not in f or e[key] == f[key]


def _mirrored_if_both(e: dict, f: dict, key: str) -> bool:
    return key not in e or key not in f or (1 - Fraction(e[key])) % 1 == Fraction(f[key])


def conjugate_errors(e: dict, f: dict, by_id: dict) -> list[str]:
    """`f` is the complex conjugate of `e`: angles negated, the real data equal, rotations mirrored;
    a named Julia set is the conjugate of another when their parameters are. An entry is its own
    conjugate only when its angles are symmetric (a real structure)."""
    if e["kind"] != f["kind"]:
        return [f"conjugate of a {f['kind']} cannot be a {e['kind']}"]
    if e["kind"] == "julia-set":
        if e["at"] != f["at"]:
            return ["conjugate Julia sets sit at different places of their components"]
        return conjugate_errors(by_id[e["parameter_of"]], by_id[f["parameter_of"]], by_id)
    field = {"hyperbolic-component": "root_angles", "misiurewicz-parameter": "angles"}.get(e["kind"])
    if field is None:
        return [f"conjugation is not checked for a {e['kind']}"]
    errors = [] if conjugate_angles(e[field]) == sorted(angle(a) for a in f[field]) else [f"{field} are not negated"]
    errors += [f"{k} differs" for k in ("period", "internal_address", "center_polynomial", "angle_type", "parent")
               if not _same_if_both(e, f, k)]
    errors += [f"{k} is not mirrored" for k in ("rotation", "limb") if not _mirrored_if_both(e, f, k)]
    if "parameter" in e and "parameter" in f:
        (x, y), (u, v) = (tuple(Fraction(t) for t in e["parameter"]), tuple(Fraction(t) for t in f["parameter"]))
        errors += [] if (x, -y) == (u, v) else ["parameter is not conjugated"]
    return errors


def tuning_image_terms(image: dict, by: dict, by_id: dict) -> list[dict]:
    """The terms of a main-cardioid accumulation stream tuned by the component `by`: rotation, the two
    tuned root angles, their period, and the internal address read off the kneading sequence."""
    r = Fraction(image["accumulation"]["rotation"])
    lo, hi = root_pair(by)
    terms = []
    for _, s in farey_stream(r):
        tuned = tuple(kr.tune_angle(lo, hi, t) for t in rotation_angles(s))
        terms.append({"rotation": s, "angles": tuned, "periods": [kr.period(t) for t in tuned],
                      "kneading_agrees": kr.kneading_prefix(tuned[0]) == kr.kneading_prefix(tuned[1]),
                      "address": internal_address(tuned[0])})
    return terms


def tuning_of_errors(e: dict, by_id: dict) -> list[str]:
    """A region declared the image of another under tuning by a component: the image accumulates on the
    main cardioid, this region accumulates on the component at the same rotation, and every tuned term is
    a satellite of the component (period n q, one kneading sequence, address extended by n q)."""
    rel = e["tuning_of"]
    image, by = by_id.get(rel["image_of"]), by_id.get(rel["by"])
    if image is None or by is None or image["kind"] != "region" or by["kind"] != "hyperbolic-component":
        return ["tuning_of names no region and component"]
    if image["accumulation"]["parent"] != "main-cardioid":
        return ["a tuning image is taken of a main-cardioid accumulation"]
    if e["accumulation"] != {"parent": rel["by"], "rotation": image["accumulation"]["rotation"]}:
        return ["accumulation is not the image's, moved onto the tuning component"]
    n = by["period"]
    return [
        f"tuned term {t['rotation']} is not a satellite of {rel['by']}"
        for t in tuning_image_terms(image, by, by_id)
        if t["periods"] != [n * t["rotation"].denominator] * 2 or not t["kneading_agrees"]
        or t["address"] != by["internal_address"] + [n * t["rotation"].denominator]
        or t["angles"] != limb_angles(by, t["rotation"])
    ]


def relation_errors(e: dict, by_id: dict) -> list[str]:
    errors = []
    if "conjugate_of" in e:
        f = by_id.get(e["conjugate_of"])
        errors += ["unknown conjugate_of"] if f is None else conjugate_errors(e, f, by_id)
    if "tuning_of" in e:
        errors += tuning_of_errors(e, by_id)
    return errors


# --- entries ----------------------------------------------------------------

def check_hyperbolic(e: dict, by_id: dict) -> list[str]:
    n, angles = e["period"], [angle(a) for a in e["root_angles"]]
    errors = []
    if len(angles) != (1 if n == 1 else 2) or angles != sorted(set(angles)):
        errors.append("root_angles must be one angle at period 1 and a strictly increasing pair otherwise")
    errors += [f"root angle {a} is not of exact type (0, {n})" for a in angles if exact_type(a) != (0, n)]
    if errors:
        return errors
    if len(angles) == 2 and kr.kneading_prefix(angles[0]) != kr.kneading_prefix(angles[1]):
        errors.append("root angles have different kneading sequences")
    if internal_address(angles[0]) != e["internal_address"]:
        errors.append(f"internal address is {internal_address(angles[0])}")
    if "parent" in e:
        parent = by_id.get(e["parent"])
        if parent is None:
            return errors + ["unknown parent"]
        if tuple(angles) != limb_angles(parent, Fraction(e["rotation"])):
            errors.append(f"root angles differ from the {e['rotation']}-limb of {e['parent']}")
    if "root_parameter" in e and not parabolic_of_period(Fraction(e["root_parameter"]), n):
        errors.append("root_parameter is not parabolic of this period")
    if "center_polynomial" in e:
        if not exact_center_factor(e["center_polynomial"], n):
            errors.append("center_polynomial is not a factor of exact period of the Gleason polynomial")
        elif "center_interval" in e:
            lo, hi = (Fraction(x) for x in e["center_interval"])
            if not lo < hi or sturm_count(poly(*e["center_polynomial"]), lo, hi) != 1:
                errors.append("center_interval does not isolate one real root")
    return errors


def check_cascade(e: dict, by_id: dict) -> list[str]:
    lo, hi = root_pair(by_id[e["generator"]])
    levels = [tuple(angle(a) for a in pair) for pair in e["levels"]]
    expected = reduce(lambda acc, _: acc + [tuple(kr.tune_angle(lo, hi, t) for t in acc[-1])], levels[1:], [(lo, hi)])
    return [] if levels == expected else [f"levels differ from iterated tuning by {e['generator']}"]


def check_misiurewicz(e: dict, by_id: dict) -> list[str]:
    angles, (l, k) = [angle(a) for a in e["angles"]], e["angle_type"]
    errors = [f"angle {a} is not of exact type ({l}, {k})" for a in angles if exact_type(a) != (l, k)]
    if l < 1:
        errors.append("a Misiurewicz angle is strictly preperiodic")
    if "parameter" in e:
        c = tuple(Fraction(x) for x in e["parameter"])
        if critical_orbit_type(c) != tuple(e["critical_orbit_type"]):
            errors.append(f"critical orbit type is {critical_orbit_type(c)}")
    if "landing_cycle" in e:
        cycle = {angle(a) for a in e["landing_cycle"]}
        if not {doubling(a, l) for a in angles} <= cycle or {doubling(a) for a in cycle} != cycle:
            errors.append("angles do not map into the landing cycle")
    if "limb" in e:
        lo, hi = rotation_angles(Fraction(e["limb"]))
        errors += [f"angle {a} is outside the {e['limb']}-wake" for a in angles if not lo < a < hi]
    return errors


def check_boundary(e: dict, by_id: dict) -> list[str]:
    cs = [Fraction(x) for x in e["convergents"]]
    ok = all(abs(a.numerator * b.denominator - b.numerator * a.denominator) == 1 for a, b in zip(cs, cs[1:]))
    return [] if ok and e["parent"] in by_id else ["convergents are not consecutive Farey neighbours"]


def check_region(e: dict, by_id: dict) -> list[str]:
    if not all(i in by_id for i in e["between"]):
        return ["unknown component in between"]
    acc = e["accumulation"]
    parent, r = by_id[acc["parent"]], Fraction(acc["rotation"])
    return accumulation_errors(parent, r)


JULIA_TARGETS = {
    "center": ("hyperbolic-component",),
    "root": ("hyperbolic-component",),
    "parameter": ("misiurewicz-parameter", "boundary-parameter"),
}


def check_julia(e: dict, by_id: dict) -> list[str]:
    target = by_id.get(e["parameter_of"])
    if target is None:
        return ["unknown parameter_of"]
    return [] if target["kind"] in JULIA_TARGETS.get(e["at"], ()) else [f"at = {e['at']} does not fit a {target['kind']}"]


CHECKS = {
    "class": lambda e, by_id: [],
    "hyperbolic-component": check_hyperbolic,
    "cascade": check_cascade,
    "misiurewicz-parameter": check_misiurewicz,
    "boundary-parameter": check_boundary,
    "region": check_region,
    "julia-set": check_julia,
}


def check_entry(entry: dict, by_id: dict) -> list[str]:
    if not entry.get("names"):
        return ["no names"]
    return [f"{entry['id']}: {m}" for m in CHECKS[entry["kind"]](entry, by_id) + relation_errors(entry, by_id)]


def load(path: Path = TABLE) -> list[dict]:
    return tomllib.loads(path.read_text(encoding="utf-8"))["entry"]


def main() -> int:
    entries = load()
    by_id = {e["id"]: e for e in entries}
    errors = [m for e in entries for m in check_entry(e, by_id)]
    for m in errors:
        print(f"FAIL {m}")
    if not errors:
        print(f"OK: {len(entries)} named structures agree with their exact data.")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
