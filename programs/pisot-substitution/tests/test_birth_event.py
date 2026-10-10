from psc_research.birth_event import (
    event_by_key,
    newborn_occurrences,
    oriented_derived_word,
    strict_birth_event_catalog,
    strict_catalog_is_endpoint_nonsynchronizing,
)
from psc_research.derived_factorization import strict_derived_substitution


SIGMA = {1: (2,), 2: (1, 2, 3), 3: (2,)}
A = ((1, 2), (2, 1))
B = ((2, 3), (3, 2))
COMP = (A, B)


def test_strict_component_has_finite_complete_birth_event_catalog():
    catalog = strict_birth_event_catalog(SIGMA, COMP)
    assert tuple(event.key for event in catalog) == ((A, 1), (B, 1))
    assert all(event.physical_cut == 2 for event in catalog)
    assert all(not event.source_aligned_on_both_sides for event in catalog)
    assert all(event.endpoint_nonsynchronizing for event in catalog)
    assert strict_catalog_is_endpoint_nonsynchronizing(SIGMA, COMP)


def test_birth_events_retain_canonical_orientation_and_endpoint_data():
    by_key = event_by_key(strict_birth_event_catalog(SIGMA, COMP))
    a = by_key[(A, 1)]
    b = by_key[(B, 1)]

    assert (a.left_child, a.left_orientation_sign) == (A, -1)
    assert (a.right_child, a.right_orientation_sign) == (B, 1)
    assert a.left_endpoint_pair == (1, 2)
    assert a.right_endpoint_pair == (2, 3)

    assert (b.left_child, b.left_orientation_sign) == (A, 1)
    assert (b.right_child, b.right_orientation_sign) == (B, -1)
    assert b.left_endpoint_pair == (2, 1)
    assert b.right_endpoint_pair == (3, 2)


def test_oriented_derived_word_carries_parent_signs_across_depths():
    tau = strict_derived_substitution(SIGMA, COMP)
    assert oriented_derived_word(SIGMA, tau, A, 1) == ((A, -1), (B, 1))
    assert oriented_derived_word(SIGMA, tau, A, 2) == (
        (A, 1),
        (B, -1),
        (A, 1),
        (B, -1),
    )


def test_deep_birth_occurrence_transforms_physical_data_when_parent_is_reversed():
    tau = strict_derived_substitution(SIGMA, COMP)
    catalog = strict_birth_event_catalog(SIGMA, COMP)
    occurrences = newborn_occurrences(SIGMA, tau, A, depth=2, catalog=catalog)

    first = occurrences[0]
    assert first.source_state == A
    assert first.parent_orientation == -1
    assert first.event.left_endpoint_pair == (2, 1)
    assert first.event.right_endpoint_pair == (3, 2)
    assert first.event.source_difference == tuple(-x for x in event_by_key(catalog)[(A, 1)].source_difference)
    assert first.event.correction == tuple(-x for x in event_by_key(catalog)[(A, 1)].correction)
    assert first.event.left_orientation_sign == 1
    assert first.event.right_orientation_sign == -1


def test_every_deep_newborn_boundary_is_an_oriented_occurrence_of_one_step_type():
    tau = strict_derived_substitution(SIGMA, COMP)
    catalog = strict_birth_event_catalog(SIGMA, COMP)
    occurrences = newborn_occurrences(SIGMA, tau, A, depth=3, catalog=catalog)
    assert tuple(item.derived_boundary_index for item in occurrences) == (1, 3, 5, 7)
    assert tuple((item.event.key, item.parent_orientation) for item in occurrences) == (
        ((A, 1), 1),
        ((B, 1), -1),
        ((A, 1), 1),
        ((B, 1), -1),
    )


def test_missing_birth_event_type_is_rejected():
    tau = strict_derived_substitution(SIGMA, COMP)
    catalog = strict_birth_event_catalog(SIGMA, COMP)
    try:
        newborn_occurrences(SIGMA, tau, A, depth=2, catalog=catalog[:1])
    except ValueError as exc:
        assert "missing" in str(exc)
    else:
        raise AssertionError("incomplete birth-event catalog was accepted")
