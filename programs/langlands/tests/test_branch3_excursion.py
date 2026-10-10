"""Third act: excursion relations on finite data, GL_2 pseudocharacters, mod-ell excursion evaluations."""
import pytest

from langlands.excursion import (
    S3_TRACE_MOD_2, ExcursionData, charpoly_has_root_pm1, frobenius_class_in_S3, gl2, gl2_group,
    mod_ell_excursion_check, procesi_identity_holds, trace,
)
from langlands.newforms import CREMONA_PRIME_LEVEL, newforms_of_level
from langlands.gf import GF

E37 = newforms_of_level(37)[0]


@pytest.mark.parametrize("ell", [2, 3])
def test_procesi_identity_on_GL2(ell):
    assert len(gl2(ell)) == (ell**2 - 1) * (ell**2 - ell)
    assert procesi_identity_holds(ell)


def test_excursion_relations_for_a_finite_hom():
    """ρ: GL_2(F_2) → GL_2(F_3) via the permutation representation? Simpler: ρ = inclusion of the
    diagonal-torus-normaliser... Use ρ = id on GL_2(F_2) and the Hecke functions f(x) = tr(x_0 x_1^{-1})."""
    G = gl2_group(2)
    D = ExcursionData(G, G, lambda x: x)
    f = lambda x: trace(G.mul(x[0], G.inv(x[1])), 2)  # noqa: E731
    assert D.is_lr_invariant(f, 2)
    assert D.relations_hold(f, 2)
    g = lambda x: trace(G.mul(x[0], G.inv(x[1])), 2) * trace(G.mul(x[1], G.inv(x[0])), 2)  # noqa: E731
    assert D.is_lr_invariant(g, 2) and D.relations_hold(g, 2)


def good_reductions(f, primes):
    return [f.reduction(p) for p in primes if p not in (2, 3, f.conductor)]


PRIMES = [p for p in range(5, 400) if all(p % d for d in range(2, int(p**0.5) + 1))]


def test_mod2_frobenius_class_from_cubic_factorisation_gives_ap_mod_2():
    """Frob_p in Gal(Q(E[2])/Q) = S_3 = GL_2(F_2), read from the factorisation of x³ + ax + b mod p;
    its trace (as a 2×2 matrix over F_2) is a_p mod 2, for every good p < 400 and every Cremona curve."""
    for f in CREMONA_PRIME_LEVEL:
        for E in good_reductions(f, PRIMES):
            assert S3_TRACE_MOD_2[frobenius_class_in_S3(E)] == E.trace_of_frobenius % 2, (f.label, E.F.p)


def test_mod3_excursion_of_37a1_and_all_cremona_curves():
    """ψ_3 has an F_p-root ⇔ ρ̄_3(Frob_p) has eigenvalue ±1 ⇔ x² − a_p x + p has a root ±1 mod 3."""
    for f in CREMONA_PRIME_LEVEL:
        for E in good_reductions(f, PRIMES):
            galois, automorphic = mod_ell_excursion_check(E, 3)
            assert galois == automorphic, (f.label, E.F.p)


def test_the_37a1_instance_certified_in_lean_matches_python():
    primes = [5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 43, 47, 53, 59, 61]
    assert [E37.reduction(p).trace_of_frobenius for p in primes] == [-2, -1, -5, -2, 0, 0, 2, 6, -4, -9, 2, -9, 1, 8, -8]
    for p in primes:
        galois, automorphic = mod_ell_excursion_check(E37.reduction(p), 3)
        assert galois == automorphic == charpoly_has_root_pm1(E37.reduction(p).trace_of_frobenius, p, 3)
