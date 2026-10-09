"""Conformance of the residual directive carrier with docs/C1_residual_directive_carrier.md.

The Python reference in reference/python/c1/kneading_reference.py pins the same instances as
the Mojo smoke target; exact angle tuning is the independent oracle.
"""

from __future__ import annotations

import sys
import tomllib
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.c1 import kneading_reference as kr  # noqa: E402

DOC = ROOT / "docs" / "C1_residual_directive_carrier.md"
SRC = ROOT / "kernel/mojo/c1/residual/residual_directive_carrier.mojo"
F = Fraction


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def periodic_angles(max_period: int):
    for p in range(2, max_period + 1):
        d = 2**p - 1
        for n in range(1, d):
            theta = F(n, d)
            if kr.period(theta) == p:
                yield theta


# --- documentation and governance ----------------------------------------------


def test_carrier_term_is_declared_with_genealogy_and_leaks():
    body = text(DOC)
    assert body.splitlines()[2].startswith("Status:")
    assert "Terminology declaration: residual directive carrier" in body
    for field in ("Genealogy:", "Bridge claim:", "Known leaks:", "Use discipline:"):
        assert field in body
    assert "definition-only" in body
    assert "TuningKneadingSubstitution" in body and "TuningKneadingSubstitution" in text(ROOT / "kernel/mojo/c1/theorem_tags/theorem_tag_import_ledger.mojo")


def test_non_claims_return_false_in_mojo():
    src = text(SRC)
    for name in ("carrier_agreement_proves_same_fiber", "directive_prefix_decides_residual_membership", "dgp_parity_twist_is_general"):
        block = src[src.index(f"def {name}() -> Bool:"):]
        assert "return False" in block.split("\n\n")[0]
    assert "TuningPattern.dgp" not in src.replace("`TuningPattern.dgp`", "")
    assert "from substitution_dynamics.internal_address import internal_address" in src
    assert "from substitution_dynamics.tuning import TuningPattern, continuation_twist, kneading_prefix" in src


def test_regime_correspondence_binds_the_carrier_symbols():
    spec = tomllib.loads(text(ROOT / "schemas/regime_correspondences.toml"))
    entry = next(c for c in spec["correspondence"] if c["id"] == "angle-kneading-prefix")
    assert entry["class"] == "symbolic_encoding" and "fibre triviality" in entry["does_not_inherit"]
    for symbol in entry["symbols"]:
        path, name = symbol.split("::")
        assert path == "kernel/mojo/c1/residual/residual_directive_carrier.mojo" and f"def {name}(" in text(SRC)
    assert text(SRC).count("# Regime correspondence: angle-kneading-prefix") == len(entry["symbols"])


def test_vendored_substitution_kernels_are_pinned():
    manifest = tomllib.loads(text(ROOT / "vendored.toml"))
    packages = {p["name"]: p for p in manifest["package"]}
    assert set(packages["substitution_dynamics"]["files"]) == {
        "substitution_dynamics/substitution.mojo", "substitution_dynamics/tuning.mojo", "substitution_dynamics/sadic.mojo", "substitution_dynamics/coincidence.mojo",
        "substitution_dynamics/internal_address.mojo"}
    assert len({packages[n]["commit"] for n in ("finite_exact", "claim_governance", "substitution_dynamics")}) == 1


# --- the reference model --------------------------------------------------------


def test_kneading_prefixes_of_named_centres():
    assert kr.kneading_prefix(F(1, 3)) == [1]
    assert kr.kneading_prefix(F(3, 7)) == [1, 0]
    assert kr.kneading_prefix(F(1, 7)) == [1, 1] == kr.kneading_prefix(F(2, 7)) == kr.kneading_prefix(F(5, 7))
    assert kr.kneading_prefix(F(7, 15)) == [1, 0, 0] and kr.kneading_prefix(F(2, 5)) == [1, 0, 1]
    for bad in (F(0), F(1, 2), F(3, 4), F(7, 5), F(1)):
        assert kr.kneading_prefix(bad) is None


def test_period_limit_is_sixty_two_in_reference_and_mojo():
    assert pow(2, 63, 92737) == 1 and kr.period(F(1, 92737)) is None
    assert kr.period(F(1, 2**62 - 1)) == 62
    src = text(SRC)
    assert "comptime MAX_CARRIER_PERIOD = 62" in src and "for k in range(MAX_CARRIER_PERIOD):" in src
    assert "checked_kneading_prefix(1, 92737).accepted()" in src and "checked_mul(p, self.levels[i].pattern.period())" in src
    assert "comptime MAX_KNEADING_WORD = 1048576" in src and "period > MAX_KNEADING_WORD" in src


def test_addresses_are_the_vendored_reduced_fractions():
    """The carrier and angle tuning read addresses as the vendored
    rational_dynamics `ReducedFraction`, exact over BigZ; neither imports the
    retired checked Int64 backend or the checked ray-address primitives."""
    tuning = text(ROOT / "kernel/mojo/dynamics/angle_tuning.mojo")
    for path_text in (text(SRC), tuning):
        assert "checked_int64_backend" not in path_text and "checked_ray_address" not in path_text
    assert "double_mod_one" in text(SRC) and "double_mod_one" in tuning and "fraction_equal" in tuning


def test_every_periodic_angle_has_a_kneading_prefix_of_length_period_minus_one():
    for theta in periodic_angles(10):
        assert len(kr.kneading_prefix(theta)) == kr.period(theta) - 1


def test_continuation_rule_is_well_defined_for_every_periodic_angle_up_to_period_12():
    for theta in periodic_angles(12):
        assert kr.tuning_pattern(theta) is not None, theta


def test_mojo_continuation_letter_and_internal_address_are_the_vendored_kernels():
    """The letter is the vendored closed form, whose boundary (a non-empty 0/1
    prefix) is the one the letter fails closed on; the internal address is the
    vendored one, with no local `rho`. The smoke still replays the closed form
    against the internal address for every prefix of length at most 10."""
    src = text(SRC)
    body = src[src.index("def continuation_last_letter("):src.index("struct DirectiveLevel(")]
    assert "continuation_twist(prefix)" in body and "_internal_address_contains" not in body
    assert "def _rho(" not in src and "def internal_address(" not in src
    assert "TuningPattern.continuation(kneading.prefix)" in src
    named = text(ROOT / "vendor/mojo/substitution_dynamics/internal_address.mojo")
    assert "def internal_address(nu: List[Int]) raises -> List[Int]:" in named and "Lau and Schleicher" in named
    smoke = src[src.index("def residual_directive_carrier_smoke("):]
    assert "for length in range(1, 11):" in smoke and "_internal_address_contains(other, length + 1)" in smoke


def test_twists_of_named_centres():
    assert kr.tuning_pattern(F(1, 3)) == ([1], True)
    assert kr.tuning_pattern(F(3, 7)) == ([1, 0], True)
    assert kr.tuning_pattern(F(1, 7)) == ([1, 1], True)
    assert kr.tuning_pattern(F(7, 15)) == ([1, 0, 0], True)
    assert kr.tuning_pattern(F(2, 5)) == ([1, 0, 1], False)


def test_pinned_instances_agree_with_exact_angle_tuning():
    assert kr.main() == 0
    assert kr.carrier_kneading_prefix([kr.tuning_pattern(F(1, 3))] * 3) == [1, 0, 1, 1, 1, 0, 1]


def test_substitution_form_of_tuning_agrees_with_angle_tuning_on_every_base_up_to_period_10():
    for name, (minus, plus) in kr.COMPONENTS.items():
        pattern = kr.tuning_pattern(minus)
        assert kr.tuning_pattern(plus) == pattern, name
        for base in periodic_angles(10):
            tuned = kr.tune_angle(minus, plus, base)
            assert kr.kneading_prefix(tuned) == kr.substitute(pattern, kr.kneading_prefix(base)) + pattern[0], (name, base)


def test_parity_twist_holds_on_real_centres_and_fails_on_the_rabbit():
    parity = lambda prefix: sum(prefix) % 2 == 1
    for real in (F(1, 3), F(3, 7), F(7, 15), F(2, 5), F(7, 17), F(8, 17)):
        prefix, twist = kr.tuning_pattern(real)
        assert twist == parity(prefix), real
    prefix, twist = kr.tuning_pattern(F(1, 7))
    assert twist and not parity(prefix)
