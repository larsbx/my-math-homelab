from psc_research.derived_dynamics import (
    cyclic_class_labels,
    cyclic_power_restrictions,
    graph_period,
    is_strongly_connected,
    iterate_derived_generic,
    primitive_by_graph,
)


def test_period_two_substitution_splits_into_primitive_square_classes():
    tau = {"A": ("B",), "B": ("A", "A")}
    assert is_strongly_connected(tau)
    assert graph_period(tau) == 2
    assert cyclic_class_labels(tau) == {"A": 0, "B": 1}
    assert not primitive_by_graph(tau)
    restrictions = cyclic_power_restrictions(tau)
    assert restrictions == (
        {"A": ("A", "A")},
        {"B": ("B", "B")},
    )
    assert all(primitive_by_graph(restriction) for restriction in restrictions)


def test_period_three_cycle_has_three_primitive_power_classes():
    tau = {"A": ("B",), "B": ("C",), "C": ("A", "A")}
    assert graph_period(tau) == 3
    assert cyclic_class_labels(tau) == {"A": 0, "B": 1, "C": 2}
    assert cyclic_power_restrictions(tau) == (
        {"A": ("A", "A")},
        {"B": ("B", "B")},
        {"C": ("C", "C")},
    )


def test_nonpisot_strict_calibration_is_primitive_but_can_still_be_periodic():
    # This is the derived substitution of the repository's primitive non-Pisot
    # strict component.  Its fixed word is periodic ABAB..., demonstrating that
    # graph primitivity alone does not provide Mossé's aperiodicity hypothesis.
    tau = {"A": ("A", "B"), "B": ("A", "B")}
    assert primitive_by_graph(tau)
    assert graph_period(tau) == 1
    assert iterate_derived_generic(tau, "A", 3) == tuple("ABABABAB")


def test_tribonacci_shape_is_primitive_at_graph_level():
    tau = {"A": ("A", "B"), "B": ("A", "C"), "C": ("A",)}
    assert is_strongly_connected(tau)
    assert graph_period(tau) == 1
    assert primitive_by_graph(tau)


def test_graph_period_rejects_non_strongly_connected_input():
    tau = {"A": ("A",), "B": ("A",)}
    assert not is_strongly_connected(tau)
    try:
        graph_period(tau)
    except ValueError as exc:
        assert "strongly connected" in str(exc)
    else:
        raise AssertionError("non-strongly-connected graph was assigned a period")
