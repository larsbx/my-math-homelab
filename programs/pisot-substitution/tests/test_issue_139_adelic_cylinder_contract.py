import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / "schemas" / "p1b-adelic-prefix-difference-cylinder.json"
NOTE = ROOT / "docs" / "p1b-adelic-prefix-difference-cylinder-2026-09-21.md"


def load_contract():
    return json.loads(CONTRACT.read_text(encoding="utf-8"))


def test_cylinder_is_specified_but_hitting_remains_open():
    data = load_contract()
    assert data["issue"] == 139
    assert data["status"] == "specified_not_proved"
    residual = data["residual_lemma"]
    assert residual["name"] == "AffinePeriodicOrbitCylinderRecurrence"
    assert residual["status"] == "open"
    assert residual["must_be_uniform_in_component"] is True
    assert residual["must_preserve_occurrence_compatibility"] is True


def test_nonunit_carrier_keeps_finite_places():
    carrier = load_contract()["carrier"]
    assert carrier["finite_places_required_when_nonunit"] is True
    assert "all finite places dividing (beta)" in carrier["internal_places"]
    assert carrier["intertwiner_required"] == "lambda(M*z) = beta*lambda(z)"


def test_acceptance_stays_exact_and_occurrence_labelled():
    target = load_contract()["level_target"]
    assert target["formula"] == (
        "C_m(i,j) = beta^(-m) * Phi'_sigma(lambda(D_m(i,j)))"
    )
    assert target["acceptance_equivalence"] == (
        "Phi'_sigma(lambda(w)) in C_m(i,j) iff M^m*w in D_m(i,j)"
    )
    assert "exact integer equality" in target["authoritative_acceptance"]
    assert "occurrence-labelled" in target["authoritative_acceptance"]


def test_affine_orbit_keeps_forcing_digits():
    orbit = load_contract()["affine_orbit"]
    assert orbit["recurrence"] == "w_(t+1) = M*w_t + d_t"
    assert orbit["replayed_offset"] == "w_t = M^t*w_0 + q_t"
    assert orbit["periodicity"] == "w_r = w_0"
    assert orbit["forbidden_homogeneous_substitute"] == (
        "M^t*w_0 without accumulated forcing"
    )
    forbidden = load_contract()["forbidden_acceptance"]
    assert any("homogeneous powers" in item for item in forbidden)


def test_weak_geometric_surrogates_cannot_accept():
    forbidden = set(load_contract()["forbidden_acceptance"])
    assert "Archimedean projection equality in the non-unit case" in forbidden
    assert "membership in the closure of the cumulative target" in forbidden
    assert "positive measure or almost-everywhere coverage" in forbidden
    assert "floating or truncated local-coordinate equality" in forbidden


def test_note_has_no_forbidden_control_characters():
    note = NOTE.read_text(encoding="utf-8")
    forbidden = [
        char
        for char in note
        if ord(char) < 32 and char != "\n"
    ]
    assert forbidden == []
    for marker in [
        r"\beta",
        r"\lambda",
        r"\Phi'_\sigma",
        r"\mathcal C_m",
        r"\varnothing",
    ]:
        assert marker in note


def test_note_keeps_claim_boundary_and_affine_correction_explicit():
    note = NOTE.read_text(encoding="utf-8")
    for marker in [
        "**Status:** exact specification for issue #139.",
        "### AdelicPeriodicOffsetHitting",
        "### Affine periodic-orbit cylinder recurrence (open)",
        "it does **not** say",
        r"w_{t+1}=Mw_t+d_t",
        r"w_t=M^t w_0+q_t",
        "certificate acceptance remains integer/algebraic and fail-closed",
    ]:
        assert marker in note
