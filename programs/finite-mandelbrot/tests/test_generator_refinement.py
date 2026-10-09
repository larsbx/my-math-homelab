"""The corpora this repository's oracles draw from, declared and checked.

Round-three item R9: `larsbx/meta_test` requires a generator to declare a
codomain refinement, and the facility is vendored from
`larsbx/finite-math-kernels` (`vendor/python/oracle_refinement`, specified in its
`docs/generator-refinement-spec.md`).

Every test here is a negative control as well as a check: each one names the
corpus that would have passed while saying nothing.
"""

from __future__ import annotations

import re
import sys
from itertools import combinations
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from reference.python.arithmetic import exact_arithmetic_property_oracle as probe  # noqa: E402
from oracle_refinement import Class, Refinement, audit_all  # noqa: E402


# --- the exact-arithmetic property probe -------------------------------------------


def test_the_probe_corpus_meets_its_declaration():
    assert probe.distribution_problems() == ()


def test_the_probe_is_judged_on_every_call_not_only_the_printed_operands():
    """A fraction draws two integers and an interval draws two fractions."""
    draws = probe.drawn()
    assert len(draws.integers) == 2 * probe.Z_CASES + 2 * len(draws.fractions)
    assert len(draws.fractions) == 2 * probe.Q_CASES + 2 * len(draws.intervals)
    assert len(draws.intervals) == 2 * probe.I_CASES


def test_the_probe_stream_still_misses_zero_the_unit_and_the_point_interval():
    """The declared gaps, pinned. Closing one must be deliberate: this fails
    first, and then the declaration is revised rather than quietly kept."""
    draws = probe.drawn()
    assert not any(v == 0 for v in draws.integers)
    assert not any(abs(v) == 1 for v in draws.integers)
    assert not any(f == 0 or f.denominator == 1 for f in draws.fractions)
    assert not any(lo == hi for lo, hi in draws.intervals)
    assert any(abs(v) >= 1 << 63 for v in draws.integers)


def test_every_declared_gap_names_what_it_leaves_unexercised():
    for refinement in probe.REFINEMENTS:
        for cls in refinement.classes:
            if not cls.required:
                assert len(cls.reason) > 40, (refinement.name, cls.name)


# --- the carrier-density sweep ------------------------------------------------------
#
# `larsbx/finite-math-kernels: docs/generator-refinement-spec.md`. The Mojo
# smoke case `sweep_profiles_accepted` claims both profile identities hold "for
# every prefix of every small catalogue", over the corpus `sweep_picks` in
# kernel/mojo/c1/carrier/carrier_density_profile.mojo. It used to draw the first
# nine pairs of `combinations(range(12), 2)`, every one of which starts at
# `0/12`: a pencil of rays through one point is not a catalogue. The corpus
# reaches several left endpoints and both extremes of arc width, and the
# declaration below refuses it if it stops doing either.

CARRIER = ROOT / "kernel/mojo/c1/carrier/carrier_density_profile.mojo"
TWELFTH = 12


def sweep() -> list[tuple[tuple[int, int], tuple[int, int]]]:
    """The separators of `sweep_picks`, read from the Mojo source that runs them."""
    src = CARRIER.read_text(encoding="utf-8")
    body = src[src.index("def sweep_picks()"):]
    body = body[body.index("return [") + len("return ["):]
    body = body[:body.index("]")]
    picks = [tuple(map(int, pair.split(", "))) for pair in re.findall(r"\((\d+, \d+)\)", body)]
    return [((a, TWELFTH), (b, TWELFTH)) for a, b in picks]


def _numerators(separator) -> tuple[int, int]:
    (a, _), (b, _) = separator
    return a, b


def _gap(separator) -> int:
    a, b = _numerators(separator)
    return abs(b - a)


def _crosses(first, second) -> bool:
    """The arcs interleave: one endpoint of each lies inside the other."""
    a, b = sorted(_numerators(first))
    c, d = sorted(_numerators(second))
    return a < c < b < d or c < a < d < b


def _nests(first, second) -> bool:
    a, b = sorted(_numerators(first))
    c, d = sorted(_numerators(second))
    return (a < c and d < b) or (c < a and b < d)


SWEEP = Refinement(
    "carrier sweep separator",
    f"a two-ray separator with distinct endpoints on the {TWELFTH}ths",
    lambda s: (all(d == TWELFTH for _, d in s) and all(0 <= n < TWELFTH for n in _numerators(s))
               and _gap(s) > 0),
    (
        Class("a left endpoint other than 0", lambda s: _numerators(s)[0] != 0),
        Class("adjacent rays", lambda s: _gap(s) == 1),
        Class("antipodal rays", lambda s: _gap(s) == TWELFTH // 2),
        Class("endpoints off the twelfths", lambda s: any(d != TWELFTH for _, d in s),
              reason=f"the sweep is deliberately one denominator wide: every arc is a multiple "
                     f"of 1/{TWELFTH}, so the identities are checked on a lattice rather than on "
                     f"the classical wakes, which the pinned smoke profiles cover instead"),
    ),
)

SWEEP_PAIR = Refinement(
    "carrier sweep pair",
    "two separators of the sweep, as a refinement step measures them",
    lambda pair: all(SWEEP.holds(s) for s in pair) and len(pair) == 2,
    (
        Class("crossing", lambda pair: _crosses(*pair)),
        Class("nested", lambda pair: _nests(*pair)),
        Class("disjoint", lambda pair: not _crosses(*pair) and not _nests(*pair)),
    ),
)


def test_the_sweep_corpus_meets_its_declaration():
    base = sweep()
    assert len(base) == 9
    assert audit_all(((SWEEP, base), (SWEEP_PAIR, list(combinations(base, 2))))) == ()


def test_the_sweep_reaches_more_than_one_left_endpoint_and_both_arc_extremes():
    base = sweep()
    assert len({_numerators(s)[0] for s in base}) > 1
    widths = {_gap(s) for s in base}
    assert 1 in widths and TWELFTH // 2 in widths


def test_the_corpus_the_sweep_used_to_draw_is_refused_by_name():
    """The historical control. `combinations(range(12), 2)[:9]` is nine
    separators that all start at `0/12`: a pencil of rays through one point,
    swept as though it were a catalogue, with no crossing or nested pair in it."""
    pencil = [((k, 12), (j, 12)) for k, j in combinations(range(12), 2)][:9]
    problems = audit_all(((SWEEP, pencil), (SWEEP_PAIR, list(combinations(pencil, 2)))))
    assert len(problems) == 3
    assert "a left endpoint other than 0" in problems[0]
    assert "'crossing'" in problems[1] and "'nested'" in problems[2]


def test_the_sweep_pairs_reach_every_relative_position():
    pairs = list(combinations(sweep(), 2))
    assert any(_crosses(a, b) for a, b in pairs)
    assert any(_nests(a, b) for a, b in pairs)
    assert any(not _crosses(a, b) and not _nests(a, b) for a, b in pairs)


def test_the_sweep_declares_the_denominator_it_does_not_leave():
    """The gap is stated rather than implied: one denominator wide, with the
    classical wakes covered by the pinned smoke profiles instead."""
    missed = [c for c in SWEEP.classes if not c.required]
    assert [c.name for c in missed] == ["endpoints off the twelfths"]
    assert "pinned" in missed[0].reason
