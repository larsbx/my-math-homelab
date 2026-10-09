from psc_research.examples import EXAMPLES
from psc_research.legal_ancestry_tower import (
    descent_margin,
    first_legal_ancestry_tower,
    substitution_max_image_length,
    tower_count_forces_existence,
    verify_legal_ancestry_tower,
)


TRIBONACCI_STATE = ((1, 2), (2, 1))
NON_PISOT_STRICT = {1: (2,), 2: (1, 2, 3), 3: (2,)}
STRICT_STATE = ((1, 2), (2, 1))


def test_conservative_descent_margin_recurrence():
    assert descent_margin(1, 0, 2) == 1
    assert descent_margin(1, 1, 2) == 4
    assert descent_margin(1, 2, 2) == 10
    assert descent_margin(1, 3, 2) == 22


def test_tribonacci_has_two_level_legal_ancestry_tower():
    sigma = EXAMPLES["tribonacci"]
    tower = first_legal_ancestry_tower(
        sigma,
        TRIBONACCI_STATE,
        depth=5,
        radius=1,
        descent_levels=2,
    )
    assert tower is not None
    assert tower.cut == 10
    assert tower.required_top_margin == 10
    assert tower.ancestry.steps[-1].top_source_cut == 5
    assert tower.ancestry.steps[-1].bottom_source_cut == 5
    assert tower.ancestry.steps[-2].top_source_cut == 2
    assert tower.ancestry.steps[-2].bottom_source_cut == 2


def test_explicit_tower_verifier_rejects_insufficiently_protected_cut():
    sigma = EXAMPLES["tribonacci"]
    try:
        verify_legal_ancestry_tower(
            sigma,
            TRIBONACCI_STATE,
            depth=5,
            cut=1,
            radius=1,
            descent_levels=2,
        )
    except ValueError as exc:
        assert "margin" in str(exc)
    else:
        raise AssertionError("unprotected top cut was accepted as a legal tower")


def test_strict_nonpisot_control_also_has_arbitrarily_deep_legal_tower_examples():
    tower = first_legal_ancestry_tower(
        NON_PISOT_STRICT,
        STRICT_STATE,
        depth=6,
        radius=1,
        descent_levels=2,
    )
    assert tower is not None
    assert tower.required_top_margin == 21
    assert tower.cut == 22


def test_counting_criterion_eventually_forces_a_strict_tower_top():
    # The strict non-Pisot component has uniform zero-return gap 2 and state
    # length 2.  At depth 9 its side length is 1024, so the conservative bad-
    # position count is finally beaten for radius 1 and two protected descents.
    assert substitution_max_image_length(NON_PISOT_STRICT) == 3
    assert tower_count_forces_existence(
        state=STRICT_STATE,
        total_length=1024,
        max_zero_return_gap=2,
        radius=1,
        descent_levels=2,
        max_image_length=3,
    )
