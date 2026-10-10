"""Conformance of the obstruction extractor with docs/C1_misiurewicz_prefix_graph.md."""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.c1 import misiurewicz_catalogue_reference as mc  # noqa: E402
from reference.python.c1 import misiurewicz_prefix_graph_reference as pg  # noqa: E402

DOC = ROOT / "docs" / "C1_misiurewicz_prefix_graph.md"
SRC = ROOT / "kernel/mojo/c1/wake/misiurewicz_prefix_graph.mojo"

DEN13 = 14  # the denominator of exact type (1, 3)


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


TAG = pg.RATIONAL_RAY_LANDING


def seps(*pairs: tuple[int, int]) -> list[tuple[int, int, int]]:
    """Separators with an accepted landing tag, which the caller declares."""
    return [(low, high, TAG) for low, high in pairs]


PERIOD_THREE = pg.period_pair_prefix(3, 14)   # the rays 1/7, 2/7, 4/7


# --- documentation and governance ----------------------------------------------


def test_term_is_declared_with_genealogy_and_leaks():
    body = text(DOC)
    assert body.splitlines()[2].startswith("Status:")
    assert "Terminology declaration: prefix obstruction" in body
    for field in ("Genealogy:", "Bridge claim:", "Known leaks:", "Use discipline:"):
        assert field in body
    assert "Definition-only" in body
    assert "prefix obstruction" in text(ROOT / "docs" / "terminology-registry.md")


def test_non_claims_return_false_in_mojo():
    src = text(SRC)
    for name in ("obstruction_free_proves_fibre_triviality",
                 "extractor_decides_persistent_nonseparation",
                 "bounded_refusal_is_evidence_of_no_obstruction"):
        block = src[src.index(f"def {name}() -> Bool:"):]
        assert "return False" in block.split("\n\n")[0]
    assert not re.search(r"\bFloat(?:16|32|64|Literal)?\b", src)
    assert not re.search(r"(?<![\w.])\d+\.\d", src)


def test_regime_correspondence_binds_the_extractor_symbols():
    spec = tomllib.loads(text(ROOT / "schemas/regime_correspondences.toml"))
    entry = next(c for c in spec["correspondence"] if c["id"] == "misiurewicz-prefix-obstruction")
    for absent in ("fibre triviality", "persistent non-separation", "parameter location"):
        assert absent in entry["does_not_inherit"]
    for symbol in entry["symbols"]:
        path, name = symbol.split("::")
        assert path == "kernel/mojo/c1/wake/misiurewicz_prefix_graph.mojo" and f"def {name}(" in text(SRC)
    tag = "# Regime correspondence: misiurewicz-prefix-obstruction"
    assert text(SRC).count(tag) == len(entry["symbols"])


def test_the_two_implementations_share_one_bound():
    assert f"comptime MAX_PREFIX_GRAPH_DENOMINATOR = {pg.MAX_PREFIX_GRAPH_DENOMINATOR}" in text(SRC)


# --- the graph ------------------------------------------------------------------


def test_forward_closure_is_closed_under_doubling_and_contains_the_seed():
    for preperiod in range(1, 6):
        for period in range(1, 6):
            den = mc.catalogue_denominator(preperiod, period)
            if den < 0 or den > pg.MAX_PREFIX_GRAPH_DENOMINATOR:
                continue
            seed = mc.catalogue(preperiod, period)
            closure = pg.forward_closure(seed, den)
            assert set(seed) <= set(closure)
            assert {(2 * x) % den for x in closure} <= set(closure)
            assert closure == sorted(set(closure))


def test_a_ray_of_a_separator_is_on_it_and_never_on_a_side():
    # docs/C1_wake_membership_soundness.md, the strict interval condition, and
    # docs/C1_side_assignment_witnesses.md: only Left and Right prove separation.
    for den in (4, 6, 14, 24):
        for low in range(den):
            for high in range(den):
                if low == high:
                    continue
                sep = (low, high, TAG)
                assert pg.side(low, sep, den) == pg.ON_SEPARATOR
                assert pg.side(high, sep, den) == pg.ON_SEPARATOR
                assert not pg.separated(low, high, [sep], den)


def test_exchanging_a_separators_rays_names_the_complementary_side():
    for point in range(DEN13):
        first, second = pg.side(point, (3, 9, TAG), DEN13), pg.side(point, (9, 3, TAG), DEN13)
        if point in (3, 9):
            assert first == second == pg.ON_SEPARATOR
        else:
            assert first != second


def test_separation_needs_two_open_opposite_sides():
    prefix = seps((1, 2), (5, 6))
    for a in range(DEN13):
        for b in range(DEN13):
            opposite = any(
                pg.side(a, s, DEN13) != pg.ON_SEPARATOR
                and pg.side(b, s, DEN13) != pg.ON_SEPARATOR
                and pg.side(a, s, DEN13) != pg.side(b, s, DEN13)
                for s in prefix
            )
            assert pg.separated(a, b, prefix, DEN13) is opposite


def test_an_untagged_or_unknown_landing_tag_is_refused():
    # docs/C1_admissible_separator_codes.md forbids a generic landing tag.
    assert pg.accepted_landing_tag(pg.RATIONAL_RAY_LANDING)
    assert pg.accepted_landing_tag(pg.PARABOLIC_LANDING)
    assert pg.accepted_landing_tag(pg.HYPERBOLIC_BOUNDARY_LANDING)
    for tag in (0, -1, 4, 99):
        assert not pg.accepted_landing_tag(tag)
        assert pg.extract(mc.catalogue(1, 3), [(2, 3, tag)], DEN13).rejected


def test_no_function_builds_a_prefix_out_of_addresses_alone():
    # The co-landing evidence admissibility requires cannot come from addresses,
    # so nothing here generates it; a prefix is declared or there is none.
    assert not hasattr(pg, "catalogue_separators")
    src = text(SRC)
    assert "def catalogue_separator_lows(" not in src
    assert "def catalogue_separator_highs(" not in src


def test_a_period_prefix_never_contains_the_points_it_separates():
    # Periodic rays against strictly preperiodic addresses.
    for preperiod in range(1, 5):
        for period in range(1, 5):
            den = mc.catalogue_denominator(preperiod, period)
            if den < 0 or den > pg.MAX_PREFIX_GRAPH_DENOMINATOR:
                continue
            prefix = pg.period_pair_prefix(period, den)
            if not prefix:
                continue
            assert not (pg.endpoints(prefix) & set(mc.catalogue(preperiod, period)))


def test_a_pair_merges_exactly_when_its_points_differ_by_half():
    for a in range(DEN13):
        for b in range(a + 1, DEN13):
            merges = pg.successor((a, b), DEN13) is None
            assert merges == ((b - a) % DEN13 == DEN13 // 2)


# --- the extractor --------------------------------------------------------------


def test_the_nonproductive_set_is_forward_closed():
    # The lemma the pipeline rests on, checked rather than assumed: a
    # nonproductive pair never has a productive successor.
    for prefix in (seps(), seps((2, 3)), seps((1, 2)), seps((1, 2), (2, 3), (5, 6))):
        vertices = pg.forward_closure(mc.catalogue(1, 3), DEN13)
        bad = pg.nonproductive(vertices, prefix, DEN13)
        for pair in bad:
            after = pg.successor(pair, DEN13)
            assert after is None or after in bad, (prefix, pair)


def test_a_merging_pair_is_nonproductive_not_productive():
    # Two addresses with a common image are exactly the ones doubling can never
    # tell apart, so they are an obstruction rather than a discharge.
    vertices = pg.forward_closure(mc.catalogue(2, 1), 4)
    bad = pg.nonproductive(vertices, [], 4)
    merging = [p for p in bad if pg.successor(p, 4) is None]
    assert merging and all(p in bad for p in merging)


def test_nonproductive_is_monotone_under_refining_the_prefix():
    vertices = pg.forward_closure(mc.catalogue(1, 3), DEN13)
    coarse = pg.nonproductive(vertices, seps((1, 2)), DEN13)
    finer = pg.nonproductive(vertices, seps((1, 2), (2, 3)), DEN13)
    assert finer <= coarse


def test_sink_cycles_are_cycles_and_partition_no_pair_twice():
    vertices = pg.forward_closure(mc.catalogue(1, 3), DEN13)
    bad = pg.nonproductive(vertices, seps((1, 2)), DEN13)
    cycles = pg.sink_cycles(bad, DEN13)
    seen: set[tuple[int, int]] = set()
    for cycle in cycles:
        assert set(cycle) <= bad
        for index, pair in enumerate(cycle):
            assert pg.successor(pair, DEN13) == cycle[(index + 1) % len(cycle)]
        assert not (set(cycle) & seen)
        seen |= set(cycle)


def test_the_pinned_declared_prefix_instance():
    # The rays 1/7, 2/7, 4/7 as a tagged period-three prefix, on the catalogue of
    # exact type (1, 3). The prefix is periodic and the catalogue strictly
    # preperiodic, so this asks a real question rather than restating a
    # construction: the prefix does not decide the class.
    found = pg.extract_catalogue(1, 3, PERIOD_THREE)
    assert (found.vertices, found.undecided, found.nonproductive) == (12, 37, 20)
    assert (found.merging, len(found.boundary), len(found.interior)) == (2, 2, 0)
    assert not found.obstruction_free


def test_the_dichotomy_is_a_property_of_the_prefix_not_of_the_cycle():
    interior = pg.extract(mc.catalogue(1, 3), seps((1, 2), (2, 3), (3, 4)), DEN13)
    boundary = pg.extract(mc.catalogue(1, 3), seps((1, 2), (2, 3), (5, 6)), DEN13)
    shared = ((6, 10), (6, 12), (10, 12))          # the orbit 3/7 -> 6/7 -> 5/7
    assert interior.nonproductive == boundary.nonproductive
    assert shared in interior.interior and shared not in interior.boundary
    assert shared in boundary.boundary and shared not in boundary.interior


def test_a_separator_whose_open_arc_is_empty_decides_nothing():
    # Adjacent rays leave no point strictly inside, and a point on a ray is not
    # a side, so such a separator cannot discharge any pair. This is why a prefix
    # of consecutive closure points was worthless as well as inadmissible.
    bare = pg.extract(mc.catalogue(1, 3), [], DEN13)
    adjacent = pg.extract(mc.catalogue(1, 3), seps((1, 2)), DEN13)
    assert adjacent.undecided == bare.undecided
    assert adjacent.nonproductive == bare.nonproductive


def test_a_nonproductive_set_can_be_entirely_transient():
    # Six nonproductive pairs, two merging, and no cycle at all: the reason the
    # obstruction-free test is the whole set rather than its sinks.
    bare = pg.extract(mc.catalogue(2, 1), [], 4)
    assert (bare.nonproductive, bare.merging, len(bare.cycles)) == (6, 2, 0)
    assert not bare.obstruction_free


def test_the_nonproductive_set_has_sinks_of_two_kinds():
    # A merging pair has no outgoing edge, so its component is a singleton
    # nothing leaves: a terminal sink, not a transient vertex. Terminal sinks
    # and cyclic sinks are disjoint, and `merging` counts the terminal ones.
    for preperiod, period, prefix in ((2, 1, []), (1, 3, []), (2, 2, []),
                                      (1, 3, PERIOD_THREE)):
        den = mc.catalogue_denominator(preperiod, period)
        vertices = pg.forward_closure(mc.catalogue(preperiod, period), den)
        bad = pg.nonproductive(vertices, prefix, den)
        terminal = {p for p in bad if pg.successor(p, den) is None}
        on_cycle = {p for c in pg.sink_cycles(bad, den) for p in c}
        assert not (terminal & on_cycle)
        found = pg.extract(mc.catalogue(preperiod, period), prefix, den)
        assert found.terminal_sinks == len(terminal)
        assert found.sink_components == len(found.cycles) + len(terminal)


def test_multiple_sinks_are_all_retained():
    # The case the overlap route's Python oracle covers and its Mojo suite does
    # not: several disjoint cycles must each be reported.
    vertices = pg.forward_closure(mc.catalogue(1, 3), DEN13)
    bad = pg.nonproductive(vertices, seps((1, 2)), DEN13)
    assert len(pg.sink_cycles(bad, DEN13)) == 5
    found = pg.extract(mc.catalogue(1, 3), seps((1, 2)), DEN13)
    assert len(found.boundary) == 4 and len(found.interior) == 1


# --- declared prefixes and fail-closed behaviour ---------------------------------


def test_the_reference_regression_replays():
    assert pg.main() == 0


def test_declared_period_prefixes_give_answers_not_restatements():
    # No claim that any type is obstruction free. What is checked is that a
    # declared prefix of periodic rays is accepted and returns a verdict whose
    # content is not fixed by the construction: some types it leaves undecided.
    undecided_somewhere = False
    for preperiod in range(1, 5):
        for period in range(1, 5):
            den = mc.catalogue_denominator(preperiod, period)
            if den < 0 or den > pg.MAX_PREFIX_GRAPH_DENOMINATOR:
                continue
            prefix = pg.period_pair_prefix(period, den)
            if not prefix:
                continue
            found = pg.extract_catalogue(preperiod, period, prefix)
            assert found.accepted
            if found.nonproductive:
                undecided_somewhere = True
    assert undecided_somewhere, "a prefix that always decides would be a construction artefact"


def test_the_smoke_target_pins_the_same_instances():
    src = text(SRC)
    for fragment in ("if found.vertices != 12 or found.undecided != 37 or found.nonproductive != 20:",
                     "if found.merging != 2 or found.boundary != 2 or found.interior != 0:",
                     "var expected: List[Int] = [1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13]",
                     "var orbit_expected: List[Int] = [2, 4, 8]",
                     "if separated(low, high, one_low, one_high, den):",
                     "if bare.cycles() != 0 or bare.terminal_sinks() != 2 or bare.sink_components() != 2:"):
        assert fragment in src
    assert "misiurewicz_prefix_graph_smoke" in text(ROOT / "kernel/mojo/smoke/smoke_tests.mojo")


def test_a_refusal_is_never_an_empty_obstruction_set():
    refused = pg.rejected_extraction()
    assert refused.rejected and not refused.accepted
    assert not refused.obstruction_free      # UW-2: a bounded failure is not evidence
    assert refused.nonproductive == 0        # and it carries no counts either way


def test_malformed_and_out_of_range_inputs_are_refused():
    cat = mc.catalogue(1, 3)
    assert pg.extract(cat, seps((3, 3)), DEN13).rejected          # a separator needs two rays
    assert pg.extract(cat, seps((1, DEN13)), DEN13).rejected      # ray out of range
    assert pg.extract(cat, seps((-1, 2)), DEN13).rejected
    assert pg.extract(cat, [], 0).rejected                        # no denominator
    assert pg.extract([99], [], DEN13).rejected                   # seed out of range
    assert pg.extract([], [], DEN13).rejected                     # empty seed
    assert pg.extract(cat, [], pg.MAX_PREFIX_GRAPH_DENOMINATOR + 1).rejected
    assert pg.extract_catalogue(4, 5, []).rejected                # denominator 496


def test_counts_past_the_bound_are_refusals_not_passes():
    bounded = [(l, k) for l in range(1, 9) for k in range(1, 9)
               if mc.catalogue_denominator(l, k) >= 0 and pg.extract_catalogue(l, k, []).rejected]
    assert len(bounded) == 35
    assert all(mc.catalogue_denominator(l, k) > pg.MAX_PREFIX_GRAPH_DENOMINATOR for l, k in bounded)


# --- the negative control (round-two item R5) -------------------------------------

CONTROL_SEED = [9]                 # the period-three orbit 3/7 -> 6/7 -> 5/7 over 21
RABBIT_WAKE = seps((3, 6))         # 1/7 and 2/7, co-landing at the period-three root
BASILICA_WAKE = seps((7, 14))      # 1/3 and 2/3, co-landing at the period-two root
CONTROL_DEN = 21


def test_the_control_orbit_is_the_period_three_one_and_holds_no_ray_of_the_prefix():
    assert pg.forward_closure(CONTROL_SEED, CONTROL_DEN) == [9, 15, 18]
    assert not pg.endpoints(RABBIT_WAKE + BASILICA_WAKE) & {9, 15, 18}


def test_a_prefix_that_separates_no_point_of_the_orbit_is_one_interior_obstruction():
    """Decided by hand: every point is strictly outside the arc from 3 to 6, so
    no iterate separates any pair; doubling carries the orbit onto itself, so
    the three pairs form one cycle; and no point is a ray, so the cycle meets no
    boundary and the dichotomy must call it interior."""
    assert [pg.side(p, RABBIT_WAKE[0], CONTROL_DEN) for p in (9, 15, 18)] == [pg.LEFT] * 3
    found = pg.extract(CONTROL_SEED, RABBIT_WAKE, CONTROL_DEN)
    assert (found.vertices, found.undecided, found.nonproductive) == (3, 3, 3)
    assert (found.merging, len(found.boundary), len(found.interior)) == (0, 0, 1)
    assert not found.obstruction_free


def test_one_more_declared_co_landing_makes_the_same_orbit_clean():
    """The other direction: the arc from 7 to 14 holds 9 and neither 15 nor 18,
    so the orbit is split and the pair left undecided is separated one doubling
    later. An extractor that always reported an obstruction fails here."""
    found = pg.extract(CONTROL_SEED, RABBIT_WAKE + BASILICA_WAKE, CONTROL_DEN)
    assert found.obstruction_free and found.nonproductive == 0
    assert found.undecided == 1 and found.vertices == 3


def test_the_control_exercises_the_interior_branch_the_pinned_report_does_not():
    pinned = pg.extract_catalogue(1, 3, PERIOD_THREE)
    assert len(pinned.interior) == 0
    assert len(pg.extract(CONTROL_SEED, RABBIT_WAKE, CONTROL_DEN).interior) == 1


def test_the_mojo_smoke_pins_the_control_and_the_note_records_it():
    src = text(SRC)
    for fragment in ("var control_seed: List[Int] = [9]", "coarse.interior != 1",
                     "refined.accepted() and refined.obstruction_free()"):
        assert fragment in src
    body = text(DOC)
    assert "## The negative control" in body
    assert "control on **this extractor**, not on the class" in body


def test_the_non_claims_hold_in_the_reference_too():
    assert not pg.obstruction_free_proves_fibre_triviality()
    assert not pg.extractor_decides_persistent_nonseparation()
