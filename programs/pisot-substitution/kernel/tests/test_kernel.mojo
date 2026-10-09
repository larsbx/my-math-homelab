"""Regression tests for the exact kernel.

Run with `pixi run test`.
"""

from std.testing import assert_equal, assert_true, assert_false

from psc.bpa import build, recurrent_noncoincident_sccs, sccs, coincidence_boundaries, inherited_boundary_positions, newborn_boundary_positions, inherited_sync_positions, newborn_sync_positions
from psc.certificate import run_all, q_target1, pip_corpus
from mojo_smoke.claims import require_claim
from psc.endpoint_core import endpoint_type
from finite_linear_algebra.mat3 import Mat3, identity3, has_rational_root
from psc.pisot import is_pip, is_primitive, is_irreducible_cubic, is_pisot_charpoly
from finite_linear_algebra.qlinalg import nullspace, rank, in_span
from finite_exact.rat_q import Q
from psc.exact import q_is_zero, q_vec
from psc.seeds import length7_seeds, certificate_seed_matrices
from finite_linear_algebra.tensor3 import shuffle_matrix, shuffle_image, theta, idx3, zeros27, is_zero27, tensor_cube_apply, levi_civita
from psc.w3 import w3_basis, certificate_w3_basis, in_w3, spans_same_space
from psc.words import Pair, parikh, is_zero, is_balanced, k1, k2, k3


def test_rational_normalisation() raises:
    assert_true(Q(2, 4).eq(Q(1, 2)))
    assert_true(Q(1, -2).eq(Q(-1, 2)))
    assert_true(q_is_zero(Q(0, 7)))
    assert_true(Q(1, 3).add(Q(1, 6)).eq(Q(1, 2)))
    assert_true(Q(2, 3).mul(Q(3, 2)).eq(Q(1, 1)))
    assert_true(Q(1, 0).rejected)
    assert_true(Q(1, 2).div(Q.zero()).rejected)


def test_exact_nullspace() raises:
    var m = List[List[Q]]()
    var r0: List[Int] = [1, 2, 3]
    var r1: List[Int] = [2, 4, 6]
    m.append(q_vec(r0))
    m.append(q_vec(r1))
    assert_equal(rank(m), 1)
    assert_equal(len(nullspace(m, 3)), 2)


def test_levi_civita() raises:
    assert_equal(levi_civita(0, 1, 2), 1)
    assert_equal(levi_civita(0, 2, 1), -1)
    assert_equal(levi_civita(1, 1, 2), 0)


def test_w3_is_eight_dimensional() raises:
    assert_equal(len(w3_basis()), 8)


def test_certificate_basis_spans_w3() raises:
    assert_true(spans_same_space(certificate_w3_basis(), w3_basis()))


def test_w3_invariant_basis_on_tribonacci() raises:
    var e: List[Int] = [1, 1, 1, 1, 0, 0, 0, 1, 0]
    var m = Mat3(e)
    var basis = certificate_w3_basis()
    assert_equal(len(basis), 8)
    for k in range(len(basis)):
        assert_true(in_w3(tensor_cube_apply(m, basis[k])))


def test_seeds_are_k2_zero_of_length_seven() raises:
    var seeds = length7_seeds()
    assert_equal(len(seeds), 6)
    for k in range(len(seeds)):
        assert_equal(seeds[k].length(), 7)
        assert_true(is_balanced(seeds[k]))
        assert_true(is_zero(k1(seeds[k])))
        assert_true(is_zero(k2(seeds[k])))
        assert_true(in_w3(k3(seeds[k])))


def test_seed_matrices_match_certificate() raises:
    var seeds = length7_seeds()
    var certA = certificate_seed_matrices()
    for k in range(len(seeds)):
        assert_true(theta(k3(seeds[k])) == Mat3(certA[k]))


def test_seed_matrix_invariants() raises:
    var seeds = length7_seeds()
    var ones: List[Int] = [1, 1, 1]
    for k in range(len(seeds)):
        var a = theta(k3(seeds[k]))
        assert_false(a.is_zero())
        assert_equal(a.trace(), 0)
        assert_equal((a * a).trace(), 6)
        assert_true(a.det() != 0)
        var img = a.apply(ones)
        assert_equal(img[0], img[1])
        assert_equal(img[1], img[2])
        assert_true(img[0] == 2 or img[0] == -2)


def test_adjugate_identity() raises:
    var e: List[Int] = [1, 1, 1, 1, 0, 0, 0, 1, 0]
    var m = Mat3(e)
    assert_true(m * m.adjugate() == identity3().scale(m.det()))


def test_tribonacci_is_pip() raises:
    var e: List[Int] = [1, 1, 1, 1, 0, 0, 0, 1, 0]
    var m = Mat3(e)
    assert_true(is_primitive(m))
    assert_true(is_irreducible_cubic(m.charpoly()))
    assert_true(is_pisot_charpoly(m.charpoly()))
    assert_true(is_pip(m))


def test_permutation_matrix_is_not_pip() raises:
    var e: List[Int] = [0, 1, 0, 0, 0, 1, 1, 0, 0]
    assert_false(is_pip(Mat3(e)))


def test_equal_row_sums_forces_rational_eigenvalue() raises:
    # (1,1,1)^T is an eigenvector, so the characteristic cubic is reducible.
    var e: List[Int] = [1, 1, 0, 0, 1, 1, 1, 0, 1]
    assert_true(has_rational_root(Mat3(e).charpoly()))
    assert_false(is_pip(Mat3(e)))


def test_target1_on_tribonacci() raises:
    var e: List[Int] = [1, 1, 1, 1, 0, 0, 0, 1, 0]
    var m = Mat3(e)
    var seeds = length7_seeds()
    for k in range(len(seeds)):
        assert_false(is_zero27(q_target1(m, k3(seeds[k]))))


def test_bpa_tribonacci() raises:
    var trib: List[List[Int]] = [[0, 1], [0, 2], [0]]
    var a = build(trib)
    assert_false(a.capped)
    assert_equal(a.size(), 6)
    assert_equal(len(sccs(a)), 3)
    assert_equal(len(recurrent_noncoincident_sccs(a)), 1)


def test_coincidence_boundaries() raises:
    var u: List[Int] = [0, 1, 1, 0]
    var v: List[Int] = [1, 0, 0, 1]
    var b = coincidence_boundaries(u, v)
    assert_equal(b[0], 0)
    assert_equal(b[len(b) - 1], 4)


def test_smith_newborn_boundary_lineage() raises:
    # Python Smith {1:(2,),2:(1,3),3:(1,3,1,2)} in zero-based Mojo letters.
    var smith: List[List[Int]] = [[1], [0, 2], [0, 2, 0, 1]]
    var u: List[Int] = [0, 2, 1]
    var v: List[Int] = [1, 0, 2]
    var p = Pair(u, v)

    var inherited = inherited_boundary_positions(smith, p.u, p.v)
    assert_equal(len(inherited), 2)
    assert_equal(inherited[0], 0)
    assert_equal(inherited[1], 7)

    var newborn = newborn_boundary_positions(smith, p)
    assert_equal(len(newborn), 2)
    assert_equal(newborn[0], 3)
    assert_equal(newborn[1], 4)

    var inherited_sync = inherited_sync_positions(smith, p)
    assert_equal(len(inherited_sync), 0)

    var newborn_sync = newborn_sync_positions(smith, p)
    assert_equal(len(newborn_sync), 2)
    assert_equal(newborn_sync[0], 3)
    assert_equal(newborn_sync[1], 4)


def test_endpoint_map_types() raises:
    var a: List[Int] = [0, 0, 0]
    var b: List[Int] = [0, 0, 1]
    var c: List[Int] = [0, 0, 2]
    var d: List[Int] = [0, 1, 2]
    var e: List[Int] = [0, 2, 1]
    var f: List[Int] = [1, 0, 0]
    var g: List[Int] = [1, 2, 0]
    assert_equal(endpoint_type(a), 0)
    assert_equal(endpoint_type(b), 1)
    assert_equal(endpoint_type(c), 2)
    assert_equal(endpoint_type(d), 3)
    assert_equal(endpoint_type(e), 4)
    assert_equal(endpoint_type(f), 5)
    assert_equal(endpoint_type(g), 6)


def test_full_certificate_passes() raises:
    var checks = run_all(2)
    assert_equal(len(checks), 10)
    for i in range(len(checks)):
        assert_true(checks[i].passed, checks[i].name)


def main() raises:
    var n = 0
    test_rational_normalisation()
    n += 1
    print("[PASS]", "test_rational_normalisation")
    test_exact_nullspace()
    n += 1
    print("[PASS]", "test_exact_nullspace")
    test_levi_civita()
    n += 1
    print("[PASS]", "test_levi_civita")
    test_w3_is_eight_dimensional()
    n += 1
    print("[PASS]", "test_w3_is_eight_dimensional")
    test_certificate_basis_spans_w3()
    n += 1
    print("[PASS]", "test_certificate_basis_spans_w3")
    test_w3_invariant_basis_on_tribonacci()
    n += 1
    print("[PASS]", "test_w3_invariant_basis_on_tribonacci")
    test_seeds_are_k2_zero_of_length_seven()
    n += 1
    print("[PASS]", "test_seeds_are_k2_zero_of_length_seven")
    test_seed_matrices_match_certificate()
    n += 1
    print("[PASS]", "test_seed_matrices_match_certificate")
    test_seed_matrix_invariants()
    n += 1
    print("[PASS]", "test_seed_matrix_invariants")
    test_adjugate_identity()
    n += 1
    print("[PASS]", "test_adjugate_identity")
    test_tribonacci_is_pip()
    n += 1
    print("[PASS]", "test_tribonacci_is_pip")
    test_permutation_matrix_is_not_pip()
    n += 1
    print("[PASS]", "test_permutation_matrix_is_not_pip")
    test_equal_row_sums_forces_rational_eigenvalue()
    n += 1
    print("[PASS]", "test_equal_row_sums_forces_rational_eigenvalue")
    test_target1_on_tribonacci()
    n += 1
    print("[PASS]", "test_target1_on_tribonacci")
    test_bpa_tribonacci()
    n += 1
    print("[PASS]", "test_bpa_tribonacci")
    test_coincidence_boundaries()
    n += 1
    print("[PASS]", "test_coincidence_boundaries")
    test_smith_newborn_boundary_lineage()
    n += 1
    print("[PASS]", "test_smith_newborn_boundary_lineage")
    test_endpoint_map_types()
    n += 1
    print("[PASS]", "test_endpoint_map_types")
    test_full_certificate_passes()
    n += 1
    print("[PASS]", "test_full_certificate_passes")
    print(n, "kernel tests passed.")
    require_claim("Target1")
    require_claim("W3LowGrowth")
