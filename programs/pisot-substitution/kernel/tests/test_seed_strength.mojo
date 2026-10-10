"""Exact regressions for the seed-strength note
(docs/p1-seed-strength-2026-10-08.md): the anatomy of one swap seed, the
closure of the census domains under reversal that turns the prefix
strong-coincidence census into a two-sided one, and the measured
seed-dependence of the recurrent part."""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract
from psc.corpus import Specimen, pip_corpus, pip_corpus_total_length
from psc.overlap_obstruction import recurrent_sccs
from psc.overlap_seed_patch import (
    OverlapState,
    SeedOverlapTables,
    build_overlap_graph_from_seeds,
    build_seed_overlap_tables,
    cached_sign,
    interior_overlap_cached,
)
from psc.perron_field3 import CubicElt, cubic_sub_checked
from psc.symmetry import reversed_substitution


def pair_seed_states(
    tables: SeedOverlapTables, a: Int, b: Int, mut cache: Dict[CubicElt, Int]
) raises -> List[OverlapState]:
    """The genuine overlaps inside the first period of `(ab)^Z` against `(ba)^Z`."""
    var top_types: List[Int] = [a, b]
    var bottom_types: List[Int] = [b, a]
    var top_starts: List[CubicElt] = [CubicElt(), tables.lengths.at(a)]
    var bottom_starts: List[CubicElt] = [CubicElt(), tables.lengths.at(b)]
    var out = List[OverlapState]()
    for i in range(2):
        for j in range(2):
            var s = OverlapState(top_types[i], bottom_types[j], cubic_sub_checked(bottom_starts[j], top_starts[i]))
            if interior_overlap_cached(tables, cache, s):
                out.append(s)
    return out^


def test_a_swap_seed_has_exactly_three_overlaps() raises:
    """Proposition SA: with ell_b < ell_a the seed (ab, ba) has exactly the
    aligned pair (a, b, 0), the self-overlap (a, a, ell_b) and the
    right-aligned pair (b, a, ell_b - ell_a); symmetrically when ell_a < ell_b.
    Checked on every pair of every standing specimen."""
    var corpus = pip_corpus()
    var checked = 0
    for s in range(len(corpus)):
        var tables = build_seed_overlap_tables(corpus[s].sigma)
        var cache = Dict[CubicElt, Int]()
        for a in range(3):
            for b in range(a + 1, 3):
                var states = pair_seed_states(tables, a, b, cache)
                assert_equal(len(states), 3)
                var la = tables.lengths.at(a)
                var lb = tables.lengths.at(b)
                var a_longer = cached_sign(tables, cache, cubic_sub_checked(la, lb)) > 0
                var long = a if a_longer else b
                var want: List[OverlapState] = [
                    OverlapState(a, b, CubicElt()),
                    OverlapState(long, long, lb if a_longer else cubic_sub_checked(CubicElt(), la)),
                    OverlapState(b, a, cubic_sub_checked(lb, la)),
                ]
                for w in range(3):
                    var found = False
                    for k in range(3):
                        if states[k] == want[w]:
                            found = True
                    assert_true(found)
                checked += 1
    assert_equal(checked, 3 * 4554)


def label_set(corpus: List[Specimen]) -> Dict[String, Bool]:
    var out = Dict[String, Bool]()
    for s in range(len(corpus)):
        out[String(corpus[s].sigma[0]) + String(corpus[s].sigma[1]) + String(corpus[s].sigma[2])] = True
    return out^


def assert_closed_under_reversal(corpus: List[Specimen], size: Int) raises:
    assert_equal(len(corpus), size)
    var members = label_set(corpus)
    for s in range(len(corpus)):
        var r = reversed_substitution(corpus[s].sigma)
        assert_true((String(r[0]) + String(r[1]) + String(r[2])) in members)


def test_the_census_domains_are_closed_under_reversal() raises:
    """Reversing every image maps each census domain onto itself, so a prefix
    strong-coincidence census without failure on the domain is also a suffix
    one: every pair of every member is eventually coincident from both ends."""
    assert_closed_under_reversal(pip_corpus(), 4554)
    assert_closed_under_reversal(pip_corpus_total_length(8), 24486)


def recurrent_keys(tables: SeedOverlapTables, a: Int, b: Int) raises -> Dict[String, Bool]:
    var cache = Dict[CubicElt, Int]()
    var g = build_overlap_graph_from_seeds(tables, pair_seed_states(tables, a, b, cache), cache, 200000)
    assert_equal(g.capped, False)
    var out = Dict[String, Bool]()
    var comps = recurrent_sccs(g)
    for c in range(len(comps)):
        for k in range(len(comps[c])):
            out[String(g.states[comps[c][k]])] = True
    return out^


def same(x: Dict[String, Bool], y: Dict[String, Bool]) -> Bool:
    if len(x) != len(y):
        return False
    for k in x.keys():
        if k not in y:
            return False
    return True


def test_the_recurrent_part_depends_on_the_seed() raises:
    """The truth of one-seed productivity does not depend on the seed
    (Theorem SC of the note), but the object does: on 444 of the 4,554
    standing specimens the three seeds reach different recurrent parts, and
    no seed's recurrent part is ever empty."""
    var corpus = pip_corpus()
    var differ = 0
    for s in range(len(corpus)):
        var tables = build_seed_overlap_tables(corpus[s].sigma)
        var r01 = recurrent_keys(tables, 0, 1)
        var r02 = recurrent_keys(tables, 0, 2)
        var r12 = recurrent_keys(tables, 1, 2)
        assert_true(len(r01) > 0 and len(r02) > 0 and len(r12) > 0)
        if not (same(r01, r02) and same(r01, r12)):
            differ += 1
    assert_equal(differ, 444)


def main() raises:
    test_a_swap_seed_has_exactly_three_overlaps()
    print("[PASS] test_a_swap_seed_has_exactly_three_overlaps")
    test_the_census_domains_are_closed_under_reversal()
    print("[PASS] test_the_census_domains_are_closed_under_reversal")
    test_the_recurrent_part_depends_on_the_seed()
    print("[PASS] test_the_recurrent_part_depends_on_the_seed")
    require_contract("seed strength: every swap seed (ab, ba) has exactly three overlaps, (a, b, 0), the longer letter's self-overlap and the right-aligned (b, a); the standing and total-length-8 domains are closed under reversal; the three seeds reach different recurrent parts on 444 of 4,554 standing specimens, none empty")
