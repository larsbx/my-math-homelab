"""Golden separation, genuine obstruction, and resource negative controls."""
from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract
from psc.overlap_seed_patch import build_seed_overlap_tables, build_seed_overlap_graph_from_tables
from psc.separation_sweep import classify_separation, orbit_key
from psc.symmetry import parse_substitution_key, reversed_substitution, conjugated_substitution


def main() raises:
    var sigma = parse_substitution_key("1/021/001")
    var tables = build_seed_overlap_tables(sigma)
    var graph = build_seed_overlap_graph_from_tables(tables, 20000)
    assert_equal(classify_separation(tables, graph), 1)
    var refused = False
    try:
        _ = classify_separation(tables, graph, 0)
    except:
        refused = True
    assert_true(refused)
    refused = False
    try:
        _ = classify_separation(tables, graph, 12, 1)
    except:
        refused = True
    assert_true(refused)
    var obstructed = parse_substitution_key("102/2/020")
    var ot = build_seed_overlap_tables(obstructed)
    var og = build_seed_overlap_graph_from_tables(ot, 20000)
    assert_equal(classify_separation(ot, og), -1)
    var exceptional = parse_substitution_key("1/2/022102")
    var et = build_seed_overlap_tables(exceptional)
    var eg = build_seed_overlap_graph_from_tables(et, 20000)
    assert_equal(classify_separation(et, eg), 9)
    assert_equal(orbit_key(exceptional), orbit_key(reversed_substitution(exceptional)))
    var perm: List[Int] = [2, 0, 1]
    assert_equal(orbit_key(exceptional), orbit_key(conjugated_substitution(exceptional, perm)))
    require_contract("bounded total-length separation survey distinguishes exact radii, proper-power witnesses, and refused budgets")
