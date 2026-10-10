from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "docs" / "terminology-registry.md"
AUDIT = ROOT / "tools" / "audit_terminology.py"


def text(path):
    return path.read_text(encoding="utf-8")


def test_registry_exists_and_has_core_sections():
    body = text(REGISTRY)
    assert "## Established field terms" in body
    assert "## Project terms with declarations" in body
    assert "## Deprecated project terms" in body
    assert "## Novel bridge checklist" in body


def test_registry_declares_high_risk_project_terms():
    body = text(REGISTRY)
    for term in [
        "PointVertex",
        "rank-2 coordinate record",
        "finite rational-ray nest",
        "SeparatorCatalogueAdequacy",
        "persistent non-separation",
        "persistent wake ambiguity",
        "Mojo theorem kernel",
    ]:
        assert term in body


def test_each_project_term_declaration_has_genealogy_claim_leaks_and_use_discipline():
    body = text(REGISTRY)
    assert body.count("Terminology declaration:") >= 7
    assert body.count("Genealogy:") >= 7
    assert body.count("Bridge claim:") >= 7
    assert body.count("Known leaks:") >= 7
    assert body.count("Use discipline:") >= 7


def test_separator_adequacy_replaces_deprecated_catalogue_extensionality():
    body = text(REGISTRY)
    assert "catalogue extensionality`: deprecated" in body
    assert "Use `SeparatorCatalogueAdequacy`" in body
    assert "SeparatorCatalogueSoundness" in body
    assert "SeparatorCatalogueCompleteness" in body


def test_mojo_theorem_kernel_has_import_boundary_leaks():
    body = text(REGISTRY)
    assert "Mojo theorem kernel" in body
    assert "finite proof objects" in body
    assert "External analytic theorems enter only as explicit theorem tags" in body
    assert "cannot by itself prove analytic landing theorems" in body


def test_registry_distinguishes_theorem_condition_definition_and_analogy():
    body = text(REGISTRY)
    assert "theorem-backed" in body
    assert "conditional on named lemmas" in body
    assert "definition-only" in body
    assert "analogy/metaphor" in body


def test_rank2_circle_rule_is_in_registry_and_audit():
    registry = text(REGISTRY)
    audit = text(AUDIT)
    assert "At rank 2" in registry
    assert "circle" in registry
    assert "RANK2_BANNED_LOCI" in audit
    assert "unit circle" in audit


def test_audit_requires_registry():
    audit = text(AUDIT)
    assert "REGISTRY" in audit
    assert "REGISTRY_REQUIRED_TERMS" in audit
    assert "required terminology registry is missing" in audit
