from math import gcd

import pytest

from kernel.pv_exact import (
    defect,
    desnanot_jacobi_holds,
    gcd_state,
    generate_e,
    large_prime_freshness_holds,
    period4_aabb_runs,
    period4_aabb_tail,
    transition_data,
    transport_congruence_holds,
)


SEEDS = [(3, 5), (4, 7), (7, 11), (10, 17)]


@pytest.mark.parametrize("seed", SEEDS)
def test_generated_sequences_satisfy_transport_identity(seed):
    values = generate_e(*seed, 24)
    for n in range(len(values) - 3):
        assert transport_congruence_holds(*values[n : n + 4])


@pytest.mark.parametrize("seed", SEEDS)
def test_desnanot_jacobi_on_generated_sequences(seed):
    values = generate_e(*seed, 24)
    for k in (2, 3):
        max_start = len(values) - (2 * (k + 1) - 1)
        for n in range(max_start + 1):
            assert desnanot_jacobi_holds(values, n, k)


@pytest.mark.parametrize("seed", SEEDS)
def test_bounded_gcd_factorization_identities(seed):
    values = generate_e(*seed, 24)
    for n in range(len(values) - 2):
        a, b, c = values[n : n + 3]
        data = transition_data(a, b, c)
        assert data.g_n == gcd(a, b)
        assert data.g_next == gcd(b, c)
        assert data.g_next == data.b_n * data.d_n
        assert data.g_n % data.d_n == 0
        assert data.h_n % data.b_n == 0
        assert data.c_n == data.g_n * data.g_next * data.primitive_det


@pytest.mark.parametrize("seed", SEEDS)
def test_local_freshness_when_G_bounds_adjacent_gcds(seed):
    values = generate_e(*seed, 24)
    states = gcd_state(values)
    G = max(states)
    for n in range(len(values) - 2):
        assert large_prime_freshness_holds(values, n, G)


def test_period4_detector_accepts_all_rotations():
    for states in (
        [2, 2, 5, 5] * 4,
        [2, 5, 5, 2] * 4,
        [5, 5, 2, 2] * 4,
        [5, 2, 2, 5] * 4,
    ):
        assert period4_aabb_tail(states, repeats=3) == (2, 5)


def test_period4_detector_rejects_two_step_return_pattern():
    assert period4_aabb_tail([2, 5, 2, 5] * 4, repeats=3) is None


def test_h2_is_the_quadratic_defect():
    from kernel.pv_exact import hankel_minor

    values = generate_e(4, 7, 12)
    for n in range(len(values) - 2):
        assert hankel_minor(values, n, 2) == defect(
            values[n], values[n + 1], values[n + 2]
        )


def test_period4_run_finder_reports_maximal_runs():
    states = [9, 1, 1, 2, 2, 1, 1, 2, 2, 7]
    runs = period4_aabb_runs(states, min_periods=2)
    assert len(runs) == 1
    run = runs[0]
    assert run.start == 1
    assert run.end == 9
    assert run.full_periods == 2
    assert run.pattern == (1, 2)


def test_seed_9_38_has_six_period_transient_blocks():
    values = generate_e(9, 38, 120)
    runs = period4_aabb_runs(gcd_state(values), min_periods=3)
    assert max(run.full_periods for run in runs) == 6
