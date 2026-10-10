from kernel.pv.identities import (
    defect,
    dodgson_h3_sides,
    gcd_product_divides_defect,
    transport_residue,
    two_step_return_shape,
)


def test_dodgson_h3_identity_on_small_integer_box():
    for a0 in range(1, 6):
        for a1 in range(1, 6):
            for a2 in range(1, 6):
                for a3 in range(1, 6):
                    for a4 in range(1, 6):
                        left, right = dodgson_h3_sides(a0, a1, a2, a3, a4)
                        assert left == right


def test_transport_congruence_on_small_integer_box():
    for a0 in range(1, 9):
        for a1 in range(1, 9):
            for a2 in range(1, 9):
                for a3 in range(1, 9):
                    assert transport_residue(a0, a1, a2, a3) == 0


def test_consecutive_gcd_product_divides_defect():
    for a0 in range(1, 20):
        for a1 in range(1, 20):
            for a2 in range(1, 20):
                assert gcd_product_divides_defect(a0, a1, a2)


def test_two_step_return_scaling_shape():
    for g in range(1, 6):
        for u, v, w in ((1, 2, 3), (2, 3, 5), (3, 5, 8)):
            U, V, W, E = two_step_return_shape(g * u, g * v, g * w, g)
            assert (U, V, W) == (u, v, w)
            assert E == defect(u, v, w)
