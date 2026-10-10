from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POLICY = ROOT / "docs" / "terminology-governance.md"
LINTER = ROOT / "tools" / "audit_terminology.py"


def text(path):
    return path.read_text(encoding="utf-8")


def test_policy_requires_genealogy_and_leaks_for_novel_terms():
    body = text(POLICY)
    assert "Terminology declaration:" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_policy_distinguishes_theorem_isomorphism_analogy_and_definition():
    body = text(POLICY)
    assert "theorem-backed isomorphism" in body
    assert "conditional bridge theorem" in body
    assert "definition used for this project only" in body
    assert "metaphor or analogy" in body


def test_linter_scans_for_risky_bridge_language():
    body = text(LINTER)
    for phrase in [
        "obvious isomorphism",
        "canonical analogy",
        "essentially the same",
        "isomorphic to",
        "proof by analogy",
    ]:
        assert phrase in body


def test_linter_enforces_complete_declaration_fields():
    body = text(LINTER)
    assert "REQUIRED_DECLARATION_FIELDS" in body
    assert "Terminology declaration:" in body
    assert "Genealogy:" in body
    assert "Bridge claim:" in body
    assert "Known leaks:" in body
    assert "Use discipline:" in body


def test_rank2_circle_rule_is_part_of_terminology_governance():
    body = text(POLICY)
    assert "A circle is undefined at rank 2" in body
    linter = text(LINTER)
    assert "RANK2_BANNED_LOCI" in linter
    assert "unit circle" in linter
    assert "circle primitive" in linter
