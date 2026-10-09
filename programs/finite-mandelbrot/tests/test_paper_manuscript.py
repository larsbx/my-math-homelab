from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAPER = ROOT / "paper" / "finite_certificates_for_mandelbrot_fibers.tex"
BIB = ROOT / "paper" / "finite_certificates_for_mandelbrot_fibers.bib"


def body(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_manuscript_exists_and_has_standard_structure():
    text = body(PAPER)
    assert "\\begin{abstract}" in text
    assert "\\section{Introduction}" in text
    assert "\\section{Background from complex dynamics}" in text
    assert "\\section{Conclusion}" in text
    assert "\\bibliography{finite_certificates_for_mandelbrot_fibers}" in text


def test_manuscript_uses_field_legible_problem_statement():
    text = body(PAPER)
    assert "finite separation formulation of fiber triviality" in text
    assert "conditional proof criterion" in text
    assert "not a proof of Mandelbrot local connectivity" in text
    assert "persistent non-separation" in text
    assert "fiber triviality" in text


def test_manuscript_has_no_project_internal_terminology():
    text = body(PAPER)
    forbidden = [
        "C1",
        "Mojo",
        "theorem kernel",
        "separator-catalogue",
        "carrier",
        "ResidualClosureNoMissingLinks",
        "ExitClosureForC1",
        "PRIORITY_ZERO",
        "finite-mandlebrot-research",
        "catalogue extensionality",
    ]
    for term in forbidden:
        assert term not in text


def test_manuscript_exposes_analytic_import_boundary_without_internal_names():
    text = body(PAPER)
    assert "imported theorems from complex dynamics" in text
    assert "known theorem" in text
    assert "assumptions" in text
    assert "rational parameter-ray landing" in text or "Rational parameter rays" in text
    assert "fiber" in text


def test_bibliography_contains_core_literature():
    text = body(BIB)
    for key in [
        "SchleicherFibersLC",
        "SchleicherRationalParameterRays",
        "MilnorOrbitPortraits",
        "DouadyHubbardEtude",
        "HertlingMandelbrotComputable",
        "BravermanYampolskyJuliaComputability",
    ]:
        assert key in text
