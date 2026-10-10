"""Exact regressions for the Penrose H_tail Phi increment cocycle."""

from std.testing import assert_equal, assert_true

from mojo_smoke.claims import require_contract
from psc.penrose_phi_tail import (
    PenrosePhiElt,
    cycle_gain,
    h_tail_branch_cycle,
    h_tail_period_gain,
    inflation_closure_generators,
    inflation_closure_index,
    inflation_closure_residue_vanishes,
    phi_mul,
    phi_state_potential_obstruction,
    residue_mod_11,
)


def test_both_tail_cycles_have_the_same_exact_gain() raises:
    var expected = PenrosePhiElt(4, -1)
    assert_equal(cycle_gain(h_tail_branch_cycle(0)), expected)
    assert_equal(cycle_gain(h_tail_branch_cycle(1)), expected)
    assert_equal(h_tail_period_gain(), expected)


def test_period_gain_has_exact_norm_eleven() raises:
    # N(4 - phi) = 4^2 + 4*(-1) - (-1)^2 = 11.
    assert_equal(h_tail_period_gain().norm(), 11)


def test_positive_growth_channel_is_not_a_state_potential() raises:
    # A genuine state potential telescopes to zero around a closed loop.
    # The source-grounded increment channel has gain 4-phi != 0, so the
    # accumulated exact-prefix height must live on a lift of H_tail.
    assert_true(phi_state_potential_obstruction())


def test_inflation_closure_has_index_eleven() raises:
    var g = h_tail_period_gain()
    var generators = inflation_closure_generators()
    assert_equal(len(generators), 2)
    assert_equal(generators[0], g)
    assert_equal(generators[1], phi_mul(g))
    assert_equal(generators[1], PenrosePhiElt(-1, 3))
    assert_equal(inflation_closure_index(), 11)
    assert_true(inflation_closure_residue_vanishes())
    assert_equal(residue_mod_11(PenrosePhiElt(1, 0)), 3)
    assert_equal(residue_mod_11(PenrosePhiElt(0, 1)), 1)


def main() raises:
    test_both_tail_cycles_have_the_same_exact_gain()
    print("[PASS] test_both_tail_cycles_have_the_same_exact_gain")
    test_period_gain_has_exact_norm_eleven()
    print("[PASS] test_period_gain_has_exact_norm_eleven")
    test_positive_growth_channel_is_not_a_state_potential()
    print("[PASS] test_positive_growth_channel_is_not_a_state_potential")
    test_inflation_closure_has_index_eleven()
    print("[PASS] test_inflation_closure_has_index_eleven")
    print("4 Penrose H_tail Phi-cocycle tests passed.")
    require_contract("penrose H_tail penrose_phi_increment channel")
