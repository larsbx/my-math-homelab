import pytest

from psc_research import apply_substitution, coincidence_boundaries, decompose_pair, parikh


def test_parikh():
    assert parikh((1, 2, 1, 3), 3) == (2, 1, 1)


def test_apply_substitution():
    sigma = {1: (2, 1), 2: (3, 1), 3: (1,)}
    assert apply_substitution(sigma, (1, 2)) == (2, 1, 3, 1)


def test_flipped_tribonacci_decomposition_has_coincidence_sibling():
    sigma_u = (2, 1, 3, 1)
    sigma_v = (3, 1, 2, 1)
    assert coincidence_boundaries(sigma_u, sigma_v, 3) == [0, 3, 4]
    assert decompose_pair(sigma_u, sigma_v, 3) == [((2, 1, 3), (3, 1, 2)), ((1,), (1,))]


@pytest.mark.parametrize(
    ("u", "v"),
    [
        ((0,), (0,)),
        ((4,), (4,)),
        ((0,), (1,)),
        ((1,), (4,)),
    ],
)
def test_coincidence_boundaries_rejects_letters_outside_alphabet(u, v):
    with pytest.raises(ValueError, match=r"outside alphabet 1\.\.3"):
        coincidence_boundaries(u, v, 3)
