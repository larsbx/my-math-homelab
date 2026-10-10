"""Regressions for the authoritative ledger/dossier consistency boundary."""

from copy import deepcopy
import subprocess
import sys
import tomllib

import pytest

from tools.check_claims import ALLOWED, ROOT, validate_claims


def record(status="CANDIDATE"):
    return {
        "claim": [{
            "id": "PV-EXAMPLE",
            "status": status,
            "statement": "An unproved example.",
            "does_not_establish": "A theorem.",
        }]
    }


def heading(status="CANDIDATE"):
    return f"### PV-EXAMPLE — {status}\n"


@pytest.mark.parametrize("status", sorted(ALLOWED))
def test_matching_dossier_status_is_accepted(status):
    assert validate_claims(record(status), heading(status)) == []


def test_live_ledger_promotion_without_dossier_update_fails():
    data = tomllib.loads((ROOT / "proof/claims.toml").read_text())
    dossier = (ROOT / "docs/dossier.md").read_text()
    assert validate_claims(data, dossier) == []
    promoted = deepcopy(data)
    claim = next(c for c in promoted["claim"] if c["id"] == "PV-PLUCKER-PATH")
    claim["status"] = "PROVED"
    assert (
        "PV-PLUCKER-PATH: status mismatch: ledger=PROVED, dossier=CANDIDATE"
        in validate_claims(promoted, dossier)
    )


def test_dossier_promotion_without_ledger_update_fails():
    errors = validate_claims(record(), heading("PROVED"))
    assert "PV-EXAMPLE: status mismatch: ledger=CANDIDATE, dossier=PROVED" in errors


def test_indented_markdown_claim_heading_is_checked():
    assert validate_claims(record(), "   " + heading()) == []
    errors = validate_claims(record(), "   " + heading("PROVED"))
    assert "PV-EXAMPLE: status mismatch: ledger=CANDIDATE, dossier=PROVED" in errors


@pytest.mark.parametrize("text", [
    "PV-EXAMPLE is mentioned in prose.",
    "| PV-EXAMPLE | CANDIDATE |",
    "~~~markdown\n### PV-EXAMPLE — CANDIDATE\n~~~\n",
    "\x60\x60\x60markdown\n### PV-EXAMPLE — CANDIDATE\n\x60\x60\x60\n",
    "<!--\n### PV-EXAMPLE — CANDIDATE\n-->\n",
])
def test_prose_tables_and_examples_cannot_supply_a_status(text):
    assert "PV-EXAMPLE: missing claim heading from docs/dossier.md" in (
        validate_claims(record(), text)
    )


@pytest.mark.parametrize("fence", ["~~~", "\x60\x60\x60", "\x60\x60\x60\x60"])
def test_fenced_alternative_status_does_not_override_real_heading(fence):
    dossier = heading() + f"\n{fence}markdown\n{heading('PROVED')}{fence}\n"
    assert validate_claims(record(), dossier) == []


def test_duplicate_dossier_heading_fails_even_if_statuses_match():
    assert "PV-EXAMPLE: duplicate dossier claim heading" in (
        validate_claims(record(), heading() + heading())
    )


def test_unknown_dossier_claim_fails():
    errors = validate_claims(
        record(), heading() + "### PV-UNRECORDED — PROVED\n"
    )
    assert "PV-UNRECORDED: dossier claim has no authoritative ledger record" in errors


@pytest.mark.parametrize("text", [
    "### PV-EXAMPLE: CANDIDATE\n",
    "## PV-EXAMPLE — CANDIDATE\n",
    "### PV-EXAMPLE — **CANDIDATE**\n",
])
def test_malformed_claim_heading_fails(text):
    assert any("malformed claim heading" in e for e in validate_claims(record(), text))


def test_unknown_status_fails():
    assert "PV-EXAMPLE: invalid dossier status 'CERTIFIED'" in (
        validate_claims(record(), heading("CERTIFIED"))
    )


@pytest.mark.parametrize("field", ["statement", "does_not_establish"])
def test_missing_claim_boundary_or_statement_fails(field):
    data = record()
    data["claim"][0][field] = " "
    assert f"PV-EXAMPLE: missing {field}" in validate_claims(data, heading())


def test_duplicate_ledger_claim_fails():
    data = record()
    data["claim"].append(deepcopy(data["claim"][0]))
    assert "duplicate ledger claim id: PV-EXAMPLE" in validate_claims(data, heading())


def test_cli_uses_repository_root_from_an_unrelated_directory(tmp_path):
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools/check_claims.py")],
        cwd=tmp_path, capture_output=True, text=True,
    )
    assert result.returncode == 0, result.stderr
    assert "ledger and dossier statuses match one for one" in result.stdout


def test_cli_returns_failure_for_ledger_dossier_mismatch(tmp_path):
    (tmp_path / "proof").mkdir()
    (tmp_path / "docs").mkdir()
    (tmp_path / "proof/claims.toml").write_text(
        '[[claim]]\nid = "PV-EXAMPLE"\nstatus = "PROVED"\n'
        'statement = "Example."\ndoes_not_establish = "A theorem."\n'
    )
    (tmp_path / "docs/dossier.md").write_text(heading())
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools/check_claims.py"), "--root", str(tmp_path)],
        cwd=tmp_path, capture_output=True, text=True,
    )
    assert result.returncode != 0
    assert "ledger=PROVED, dossier=CANDIDATE" in result.stderr
