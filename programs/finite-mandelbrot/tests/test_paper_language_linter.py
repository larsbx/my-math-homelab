from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LINTER = ROOT / "tools" / "audit_paper_language.py"
SKILL = ROOT / "docs" / "linter_skill_paper_language.md"
PAPER = ROOT / "paper" / "finite_certificates_for_mandelbrot_fibers.tex"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_linter_exists_and_scans_paper_tex_files():
    body = text(LINTER)
    assert "PAPER_ROOT" in body
    assert "glob(\"*.tex\")" in body
    assert "audit_file" in body
    assert "Paper language audit" in body


def test_linter_bans_project_internal_terms_from_manuscripts():
    body = text(LINTER)
    for term in [
        "C1",
        "finite-mandlebrot-research",
        "Mojo",
        "theorem kernel",
        "separator-catalogue",
        "catalogue extensionality",
        "carrier",
        "ResidualClosureNoMissingLinks",
        "ExitClosureForC1",
        "PRIORITY_ZERO",
        "OPEN_FRONTIER",
    ]:
        assert term in body
    assert "BANNED_TERMS" in body


def test_linter_recommends_field_facing_replacements():
    body = text(LINTER) + "\n" + text(SKILL)
    for phrase in [
        "finite rational-ray separation certificates",
        "adequacy of finite rational-ray separation certificates",
        "finite proof checker",
        "finite record",
        "open problem",
    ]:
        assert phrase in body


def test_linter_requires_standard_mathematical_context():
    body = text(LINTER)
    for phrase in [
        "Mandelbrot set",
        "quadratic family",
        "rational parameter rays",
        "fiber",
        "finite certificate",
        "Mandelbrot local connectivity",
    ]:
        assert phrase in body
    assert "FIELD_REQUIRED_TERMS" in body


def test_linter_requires_core_literature_citations():
    body = text(LINTER)
    for key in [
        "DouadyHubbardEtude",
        "SchleicherRationalParameterRays",
        "SchleicherFibersLC",
        "MilnorOrbitPortraits",
    ]:
        assert key in body
    assert "FIELD_REQUIRED_REFERENCES" in body


def test_skill_scope_is_paper_only():
    body = text(SKILL)
    assert "paper/*.tex" in body
    assert "Internal documents, source files, tests, and CI scripts" in body


def test_current_manuscript_has_no_banned_terms_named_by_policy():
    manuscript = text(PAPER)
    for banned in [
        "finite-mandlebrot-research",
        "Mojo",
        "theorem kernel",
        "separator-catalogue",
        "catalogue extensionality",
        "ResidualClosureNoMissingLinks",
        "ExitClosureForC1",
        "PRIORITY_ZERO",
        "OPEN_FRONTIER",
    ]:
        assert banned not in manuscript
