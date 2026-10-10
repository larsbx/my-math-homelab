from psc_research.lie4 import (
    character_dimension,
    degree4_witt_dimension,
    lie4_schur_character,
    lie4_witt_character,
    low_growth_families,
    orbit,
    orbit_families,
    schur_211_character,
    schur_31_character,
)


def test_witt_and_schur_decompositions_agree_exactly():
    assert lie4_witt_character() == lie4_schur_character()


def test_degree_four_dimensions_are_15_plus_3_equals_18():
    assert character_dimension(schur_31_character()) == 15
    assert character_dimension(schur_211_character()) == 3
    assert character_dimension(lie4_witt_character()) == 18
    assert degree4_witt_dimension(3) == 18


def test_s31_weight_multiplicities_have_three_orbit_shapes():
    s31 = schur_31_character()
    for weight in orbit((3, 1, 0)):
        assert s31[weight] == 1
    for weight in orbit((2, 2, 0)):
        assert s31[weight] == 1
    for weight in orbit((2, 1, 1)):
        assert s31[weight] == 2
    assert len(s31) == 12


def test_lie4_orbit_family_dimensions_sum_to_eighteen():
    families = orbit_families()
    assert [(f.name, f.orbit_size, f.multiplicity_in_lie4, f.dimension) for f in families] == [
        ("A_310", 6, 1, 6),
        ("B_220", 3, 1, 3),
        ("C_211", 3, 3, 9),
    ]
    assert sum(f.dimension for f in families) == 18


def test_low_growth_degree4_families_require_unimodularity():
    assert low_growth_families(2, False) == ()
    assert low_growth_families(3, True) == ()
    assert low_growth_families(1, False) == ("C_211",)
    assert low_growth_families(1, True) == ("C_211", "B_220")
