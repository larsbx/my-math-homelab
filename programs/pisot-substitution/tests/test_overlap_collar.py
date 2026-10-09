from __future__ import annotations

import pytest

from psc_research.overlap_affine_pump import AffinePumpCertificate, first_zero_shift_free_affine_pump, occurrence_edges
from psc_research.overlap_collar import (
    Collar,
    build_collared_graph,
    collapsing_seed_pairs,
    collared_seeds,
    inflate_collar,
    is_proper_power,
    legal_collared_count,
    legal_factors,
    lift_affine_pump,
    patch_power_level,
    seed_collar,
    separation_radius,
    unresolved_collisions,
)
from psc_research.overlap_graph import OverlapGraph

SIGMA = {1: (2,), 2: (1, 3, 2), 3: (1, 1, 2)}  # determinant two


@pytest.fixture(scope="module")
def graph() -> OverlapGraph:
    return OverlapGraph(SIGMA)


def _patch_collar(sigma, a, b, path, radius):
    """The collar read directly off the inflated periodic patch ``sigma^n((ab)^Z)``."""
    word = (a, b) * (2 * radius + 3)
    pos = 2 * (radius + 1) + (path[0][0] != a)
    assert word[pos] == path[0][0]
    for (letter, child_index), (next_letter, _) in zip(path, path[1:] + [(None, None)]):
        assert word[pos] == letter
        if next_letter is None:
            break
        pos = sum(len(sigma[x]) for x in word[:pos]) + child_index
        word = tuple(x for y in word for x in sigma[y])
    return Collar(word[pos - radius:pos], word[pos + 1:pos + 1 + radius])


def test_collar_recursion_matches_the_inflated_periodic_patch() -> None:
    for a, b in ((1, 2), (2, 3), (1, 3)):
        for path in ([(a, 0), (SIGMA[a][0], 0)], [(b, 2 % len(SIGMA[b])), (SIGMA[b][2 % len(SIGMA[b])], 0), (1, 0)], [(a, 0)] * 1 + [(SIGMA[a][0], len(SIGMA[SIGMA[a][0]]) - 1)]):
            for radius in (0, 1, 3, 5):
                collar = seed_collar(path[0][0], b if path[0][0] == a else a, radius)
                for (letter, child_index), (next_letter, _) in zip(path, path[1:]):
                    collar = inflate_collar(SIGMA, collar, letter, child_index, radius)
                    assert next_letter == SIGMA[letter][child_index]
                assert collar == _patch_collar(SIGMA, a, b, path, radius), (a, b, path, radius)


def test_affine_state_alone_leaves_collisions_and_radius_one_resolves_them(graph: OverlapGraph) -> None:
    affine = build_collared_graph(graph, 0)
    assert len(affine.states) == len(graph.states) == 628
    assert len(unresolved_collisions(affine)) == 269
    collared = build_collared_graph(graph, 1)
    assert len(collared.states) == 1866
    assert max(len(collared.fibre(k)) for k in range(len(graph.states))) == 15
    assert unresolved_collisions(collared) == ()
    assert separation_radius(graph, 3) == 1
    assert {c.state_index for c in collared_seeds(graph, 1)} == {graph.index[s] for s in graph.seeds()}
    assert sum(len(occurrence_edges(graph, k)) for k in range(len(graph.states))) == len(affine.edges)


def test_golden_pump_lifts_to_an_eventually_constant_collar(graph: OverlapGraph) -> None:
    certificate = first_zero_shift_free_affine_pump(graph)
    assert certificate is not None and len(certificate.edges) == 6
    for radius, fibre_size in ((1, 11), (2, 12), (4, 16)):
        orbits = lift_affine_pump(graph, build_collared_graph(graph, radius), certificate)
        assert len(orbits) == fibre_size
        assert {o.period for o in orbits} == {1}
        assert {o.preperiod for o in orbits} == {0, 1}


def test_most_collared_tiles_are_legal_factors(graph: OverlapGraph) -> None:
    assert legal_factors(SIGMA, 2) == {(1,), (2,), (3,), (1, 3), (3, 2), (1, 1), (1, 2), (2, 1), (2, 2)}
    assert legal_collared_count(graph, build_collared_graph(graph, 1)) == 1854


def test_a_collision_surviving_every_radius_comes_from_a_collapsing_patch() -> None:
    sigma = {1: (2, 1, 3), 2: (3,), 3: (1, 3, 1)}  # sigma(2)sigma(3) = 3 131 = (31)^2
    g = OverlapGraph(sigma)
    assert len(g.states) == 126
    assert separation_radius(g, 8) is None
    survivors = unresolved_collisions(build_collared_graph(g, 8))
    assert len(survivors) == 3
    witness = build_collared_graph(g, 8).states[survivors[0].child]
    assert g.states[witness.state_index][:2] == (3, 1)
    assert witness.top.left == (3, 1) * 4 and witness.bottom.right == (3, 1) * 4  # the periodic word (31)^Z on both tiles
    assert survivors[0].labels == ((2, 0, 3, 0), (3, 1, 3, 2))  # the 3 of sigma(2) and the middle 3 of sigma(3)
    assert is_proper_power((3, 1, 3, 1)) and not is_proper_power((3, 1, 3)) and not is_proper_power((3,))
    assert patch_power_level(sigma, 2, 3, 6) == 1 and patch_power_level(sigma, 1, 3, 6) is None
    assert collapsing_seed_pairs(g, 6) == ((2, 3, 1),)
    assert collapsing_seed_pairs(OverlapGraph(SIGMA), 6) == ()  # the golden graph: separation radius 1, no collapse
    with pytest.raises(RuntimeError):
        patch_power_level(sigma, 1, 2, 0)
    with pytest.raises(RuntimeError):
        patch_power_level(sigma, 2, 2, 6)  # (a, a) is not a swap seed, and sigma(a)sigma(a) is always a power


def test_fail_closed(graph: OverlapGraph) -> None:
    with pytest.raises(RuntimeError):
        seed_collar(1, 2, -1)
    with pytest.raises(RuntimeError):
        inflate_collar(SIGMA, seed_collar(1, 2, 1), 1, 1, 1)
    with pytest.raises(RuntimeError):
        inflate_collar(SIGMA, seed_collar(1, 2, 1), 1, 0, -1)  # a negative radius must not yield an empty collar
    with pytest.raises(RuntimeError):
        inflate_collar(SIGMA, Collar((1,), (1,)), 1, 0, 2)  # radius-1 neighbours with length-one images cannot supply radius 2
    certificate = first_zero_shift_free_affine_pump(graph)
    from dataclasses import replace
    corrupted = AffinePumpCertificate(certificate.state_indices[:1] + (-1,) * (len(certificate.edges) - 1), certificate.edges)
    stale = AffinePumpCertificate(certificate.state_indices, (replace(certificate.edges[0], top_child_index=certificate.edges[0].top_child_index + 1),) + certificate.edges[1:])
    assert any(certificate.edges[2].forcing)  # the third edge advances the bottom child, so its forcing term is nonzero
    forged = AffinePumpCertificate(certificate.state_indices, certificate.edges[:2] + (replace(certificate.edges[2], forcing=graph.F.zero),) + certificate.edges[3:])
    for malformed in (AffinePumpCertificate((certificate.state_indices[0],), ()), AffinePumpCertificate((), ()),
                      AffinePumpCertificate(certificate.state_indices, certificate.edges[:-1]), corrupted, stale, forged):
        with pytest.raises(RuntimeError):  # an edge sequence that does not match the states is not a pump
            lift_affine_pump(graph, build_collared_graph(graph, 1), malformed)
    with pytest.raises(RuntimeError):
        legal_factors(SIGMA, 0)
    with pytest.raises(RuntimeError):
        collared_seeds(capped_graph(), 1)
    with pytest.raises(RuntimeError):  # a certificate from another graph has no starting fibre here
        lift_affine_pump(graph, build_collared_graph(graph, 1), first_zero_shift_free_affine_pump(OverlapGraph({1: (2, 1, 3), 2: (3,), 3: (1, 3, 1)})))
    with pytest.raises(RuntimeError):
        build_collared_graph(graph, 1, max_states=100)
    with pytest.raises(RuntimeError):
        separation_radius(graph, -1)  # an empty search must not read as a surviving collision
    with pytest.raises(RuntimeError):
        build_collared_graph(capped_graph(), 1)


def capped_graph() -> OverlapGraph:
    capped = OverlapGraph(SIGMA)
    capped.capped = True
    return capped
