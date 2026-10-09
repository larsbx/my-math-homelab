"""Pin all corrected PR #192 counts and the limits of the comparison.

The 9/19/39/42 overlap table has no executable quotient provenance. This
regression rebuilds the canonical graphs and guards their complete counts,
including the distinct seed versus finite-prefix OA initial conditions.
"""

from std.testing import assert_equal, assert_true
from mojo_smoke.claims import require_contract
from psc.representation_control import recompute_counts, specimen_keys


def test_all_four_canonical_rows() raises:
    var keys = specimen_keys()
    var det: List[Int] = [1, 2, 2, 2]
    var bpa: List[Int] = [6, 305, 327, 1168]
    var seed: List[Int] = [29, 1646, 1245, 1916]
    var oa: List[Int] = [29, 1646, 1246, 1914]
    var powers: List[Int] = [1, 2, 2, 1]
    var letters: List[Int] = [0, 0, 1, 0]
    var prefixes: List[Int] = [10609, 15546, 8996, 10791]
    var windows: List[Int] = [4, 3, 3, 4]
    var oa_minus_seed: List[Int] = [0, 1, 0, 0]
    var seed_minus_oa: List[Int] = [0, 1, 0, 2]
    assert_equal(len(keys), 4)
    for i in range(len(keys)):
        var row = recompute_counts(keys[i])
        assert_equal(row.determinant, det[i])
        assert_equal(row.bpa_types, bpa[i])
        assert_equal(row.comparison.seed_types, seed[i])
        assert_equal(row.comparison.oa_types, oa[i])
        assert_equal(row.comparison.power, powers[i])
        assert_equal(row.comparison.letter, letters[i])
        assert_equal(row.comparison.prefix_length, 1)
        assert_equal(row.prefix_length, prefixes[i])
        assert_equal(row.window, windows[i])
        assert_equal(row.comparison.oa_minus_seed, oa_minus_seed[i])
        assert_equal(row.comparison.seed_minus_oa, seed_minus_oa[i])
        assert_true(row.bpa_all_productive)
        assert_true(row.seed_all_productive)
        assert_true(row.comparison.oa_all_productive)
        # The alleged small-overlap explanation is reversed on EVERY row.
        assert_true(row.comparison.seed_types > row.bpa_types)
        print("[PASS] corrected canonical representation counts:", keys[i])


def test_caps_and_undersized_prefixes_do_not_return_rows() raises:
    var bpa_failed = False
    try:
        _ = recompute_counts("01/02/0", 1)
    except:
        bpa_failed = True
    assert_true(bpa_failed)
    # 6 BPA types fit but 29 overlap types do not.
    var overlap_failed = False
    try:
        _ = recompute_counts("01/02/0", 6)
    except:
        overlap_failed = True
    assert_true(overlap_failed)
    # The third specimen has 1245 seed types but 1246 OA types: this budget
    # reaches the OA cap independently of the already complete seed graph.
    var oa_failed = False
    try:
        _ = recompute_counts("21/22/102", 1245)
    except:
        oa_failed = True
    assert_true(oa_failed)
    var prefix_failed = False
    try:
        _ = recompute_counts("01/02/0", 20000, 1)
    except:
        prefix_failed = True
    assert_true(prefix_failed)


def main() raises:
    test_all_four_canonical_rows()
    test_caps_and_undersized_prefixes_do_not_return_rows()
    print("[PASS] representation comparison refuses capped or undersized inputs")
    require_contract("the four BPA/overlap comparison specimens have replayed canonical counts; finite-prefix OA and swap-seed graphs remain distinct and caps are inconclusive")
