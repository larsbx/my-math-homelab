from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "docs" / "finite-proof-records-spec.md"


def text() -> str:
    return SPEC.read_text(encoding="utf-8")


def test_spec_declares_non_theorem_boundary():
    body = text()
    assert "It proves no mathematical statement" in body
    assert "accepts no finite-mandlebrot-research certificate" in body
    assert "does not discharge C1" in body
    assert "ResidualClosureNoMissingLinks" in body


def test_record_kinds_cover_evidence_and_open_states():
    body = text()
    for kind in [
        "finite_computation",
        "formal_derivation",
        "imported_theorem",
        "bounded_experiment",
        "open_dependency",
        "countermodel",
        "rejected_record",
    ]:
        assert f"`{kind}`" in body


def test_validation_is_not_boolean():
    body = text()
    for state in ["accepted", "bounded", "incomplete", "open", "refuted", "rejected"]:
        assert f"`{state}`" in body
    assert "These states are not Booleans" in body


def test_fail_closed_dependency_rules_are_explicit():
    body = text()
    for requirement in [
        "reject missing dependency identifiers",
        "reject cycles",
        "propagate `rejected`, `incomplete`, and `open`",
        "depends only on a bounded experiment",
        "exact set of missing or unacceptable links",
    ]:
        assert requirement in body


def test_domain_policy_stays_outside_portable_kernel():
    body = text()
    assert "finite-mandlebrot-research policy" in body
    assert "PSC policy" in body
    assert "consumer-policy result carriers" in body
    assert "ships no default that silently permits imported theorems" in body
    assert "finite-mandlebrot-research theorem names and prohibited primitive lists" in body
    assert "PSC conjecture names" in body


def test_canonical_encoding_does_not_choose_hash_or_accept_certificate():
    body = text()
    assert "Canonical encoding and hashing are separate" in body
    assert "consumers select a hash suite" in body
    assert "diagnostic renderer is never an encoding oracle" in body
    assert "certificate acceptance" in body


def test_first_implementation_must_be_compiled_and_negative_tested():
    body = text()
    assert "compiled Mojo CI closure" in body
    for case in [
        "tamper",
        "missing-dependency",
        "cyclic-dependency",
        "capped-computation",
        "unmatched-hypothesis",
        "bounded-to-general",
    ]:
        assert case in body


def test_dependency_edges_bind_expected_claim_scope_and_use():
    body = text()
    for field in [
        "dependency_record_id",
        "expected_claim_id",
        "use_site_id",
        "required_scope_relation",
        "required_outcome",
    ]:
        assert f"`{field}`" in body
    assert "structurally valid but unrelated record" in body


def test_record_identifier_has_non_circular_preimage():
    body = text()
    assert "record-ID preimage" in body
    assert "except `record_id` itself" in body
    assert "verify the identifier without circularity" in " ".join(body.split())


def test_incomplete_records_remain_addressable():
    body = text()
    assert "even when validation yields `incomplete`, `open`, or" in body
    assert "must remain addressable" in body
    assert "malformed construction" in body
    assert "rejected only by consumer policy retains its identity" in body
