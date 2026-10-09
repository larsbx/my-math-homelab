from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RANK2_DOC = ROOT / "docs" / "rank2-coordinate-substrate.md"
RANK2_SRC = ROOT / "kernel/mojo/arithmetic/rank2_operator.mojo"


def text(path):
    return path.read_text(encoding="utf-8")


def test_rank2_doc_says_circle_is_not_primitive():
    body = text(RANK2_DOC)
    assert "circle" in body
    assert "not primitive rank-2 objects" in body
    assert "must not reify that condition as a circle at rank 2" in body
    assert "higher incidence/constraint layer" in body


def test_rank2_doc_allows_quadrance_not_circle():
    body = text(RANK2_DOC)
    assert "Q(x, y) = x^2 + y^2" in body
    assert "Q(x, y) = r" in body
    assert "The finite core may use the scalar polynomial" in body


def test_rank2_source_does_not_use_circle_locus_language():
    body = text(RANK2_SRC).lower()
    forbidden = [
        "circle",
        "unit circle",
        "disk",
        "circumference",
        "arc",
        "locus",
    ]
    for token in forbidden:
        assert token not in body
