"""Conformance between bootstrap identity lanes and committed period-four evidence."""

from itertools import product

from kernel.pv.identities import defect, hankel3, transport_residue
from kernel.pv_exact import (
    defect as kernel_defect,
    gcd_state,
    generate_e,
    hankel_minor,
    period4_aabb_runs,
    transport_congruence_holds,
)


def test_explicit_h3_matches_bareiss_including_singular_and_signed_inputs():
    for values in product((-2, 0, 3), repeat=5):
        assert hankel3(*values) == hankel_minor(values, 0, 3)
        assert defect(*values[:3]) == kernel_defect(*values[:3])


def test_transport_interfaces_agree_on_signed_integer_inputs():
    for a, b, c, d in product((-2, 1, 3), repeat=4):
        assert transport_residue(a, b, c, d) == 0
        assert transport_congruence_holds(a, b, c, d)


def test_committed_9_38_intervals_and_spike_boundaries():
    states = gcd_state(generate_e(9, 38, 120))
    runs = period4_aabb_runs(states, min_periods=2)
    assert [(r.start, r.end, r.full_periods, r.phase) for r in runs] == [
        (0, 10, 2, (1, 2, 2, 1)),
        (11, 35, 6, (1, 1, 2, 2)),
        (36, 60, 6, (1, 2, 2, 1)),
        (61, 85, 6, (2, 2, 1, 1)),
        (86, 99, 3, (2, 1, 1, 2)),
        (100, 110, 2, (1, 2, 2, 1)),
    ]
    assert [(i, x) for i, x in enumerate(states) if x not in (1, 2)] == [
        (10, 98), (35, 49), (60, 49), (85, 98),
        (99, 103), (110, 98), (112, 71),
    ]
    assert all(run.pattern == (1, 2) for run in runs)
