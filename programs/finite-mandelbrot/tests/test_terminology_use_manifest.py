from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "docs" / "terminology-use-manifest.md"
LINTER = ROOT / "tools" / "audit_terminology.py"


def text(path):
    return path.read_text(encoding="utf-8")


def test_manifest_has_required_control_sections():
    body = text(MANIFEST)
    for section in [
        "## Registered project terms currently allowed",
        "## Terms requiring local declaration outside C1 files",
        "## Terms requiring theorem-tag status",
        "## High-risk bridge phrases",
        "## Circle/rank-2 ban",
    ]:
        assert section in body


def test_manifest_scopes_c1_terms_and_marks_legacy_term_deprecated():
    body = text(MANIFEST)
    for term in [
        "finite rational-ray nest",
        "persistent non-separation",
        "persistent wake ambiguity",
        "wake ambiguity",
        "SeparatorCatalogueAdequacy",
        "SeparatorCatalogueSoundness",
        "SeparatorCatalogueCompleteness",
        "side-assignment witness",
        "separator code",
    ]:
        assert term in body
    assert "catalogue extensionality` — use only when explicitly marked deprecated" in body
    assert "docs/C1_" in body
    assert "kernel/mojo/c1/" in body
    assert "tests/test_C1_" in body


def test_manifest_registers_mojo_theorem_kernel_boundary():
    body = text(MANIFEST)
    assert "Mojo theorem kernel" in body
    assert "finite proof-object theorem kernel" in body
    assert "external analytic theorems remain theorem-tag imports" in body


def test_linter_reads_manifest_and_scoped_terms():
    body = text(LINTER)
    assert "USE_MANIFEST" in body
    assert "C1_SCOPED_TERMS" in body
    assert "DEPRECATED_TERMS" in body
    assert "C1_SCOPED_PREFIXES" in body
    from audit_terminology import C1_SCOPED_TERMS, DEPRECATED_TERMS, POLICY, USE_MANIFEST as MANIFEST_PATH

    assert MANIFEST_PATH in {document.path for document in POLICY.documents}
    rule_terms = [set(getattr(rule, "terms", ())) for rule in POLICY.rules]
    assert set(C1_SCOPED_TERMS) in rule_terms
    assert set(DEPRECATED_TERMS) in rule_terms


def test_manifest_preserves_rank2_circle_ban():
    body = text(MANIFEST)
    assert "circle" in body
    assert "not valid rank-2 objects" in body
    assert "quadrance" in body
    assert "polynomial constraint" in body
