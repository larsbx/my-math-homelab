import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MATRIX_PATH = ROOT / "schemas" / "p1b-strict-zipper-transfer-matrix.json"
NOTE_PATH = ROOT / "docs" / "p1b-strict-zipper-literature-gate-2026-09-21.md"


def load_matrix():
    return json.loads(MATRIX_PATH.read_text(encoding="utf-8"))


def test_issue_139_residual_obligation_stays_open_and_nonunit():
    data = load_matrix()
    assert data["issue"] == 139
    assert data["standing_regime"]["unimodular_required"] is False
    assert data["standing_regime"]["determinant_absolute_value_may_exceed_one"] is True

    obligation = data["residual_obligation"]
    assert obligation["name"] == "AdelicPeriodicOffsetHitting"
    assert obligation["status"] == "open"
    assert obligation["requires_finite_place_factor_when_nonunit"] is True
    assert obligation["proved_by_sources"] is False
    assert obligation["implies_pds"] is False


def test_unit_and_unimodular_sources_are_never_marked_as_full_transfers():
    data = load_matrix()
    restricted = [
        source
        for source in data["sources"]
        if source["unit_only"] or source["unimodular_only"]
    ]
    assert {source["key"] for source in restricted} == {
        "ItoRao2006",
        "BargeKwapisz2006",
    }
    assert all(source["transfer_status"] == "partial" for source in restricted)


def test_general_nonunit_sources_do_not_claim_the_missing_hit():
    data = load_matrix()
    mt = next(
        source
        for source in data["sources"]
        if source["key"] == "MinervinoThuswaldner2014"
    )
    assert mt["transfer_status"] == "ambient_space"
    assert "pointwise periodic-offset hit" in mt["does_not_transfer"]

    al = next(
        source
        for source in data["sources"]
        if source["key"] == "AkiyamaLee2011"
    )
    assert al["transfer_status"] == "diagnostic"
    assert "forcing a specified periodic offset to hit" in al["does_not_transfer"]


def test_barge_results_remain_class_specific_positive_controls():
    data = load_matrix()
    barge = [
        source for source in data["sources"] if source["key"].startswith("Barge20")
    ]
    assert {source["key"] for source in barge} == {"Barge2016", "Barge2018"}
    assert all(source["class_specific"] for source in barge)
    assert all(source["transfer_status"] == "positive_control" for source in barge)


def test_note_contains_explicit_firewall_and_stop_go_sections():
    note = NOTE_PATH.read_text(encoding="utf-8")
    required = [
        "## 1. Exact question and hypothesis firewall",
        "## 7. Exact residual theorem obligation",
        "### Adelic periodic-offset hitting theorem (open)",
        "## 8. Stop/go decision",
        "No theorem-facing Mojo instrumentation is authorized",
    ]
    for marker in required:
        assert marker in note
