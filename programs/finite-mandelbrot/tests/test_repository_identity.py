from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_canonical_repository_identity_is_unambiguous():
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    migration = (ROOT / "MIGRATION.md").read_text(encoding="utf-8")
    assert "finite-mandelbrot-research" in readme
    assert "former `larsbx/NLAP-JT` repository is historical" in readme
    assert "`larsbx/finite-mandelbrot-research`" in migration
    assert "finite-mandlebrot-research" not in migration


def test_post_cutover_work_belongs_only_in_canonical_repo():
    migration = (ROOT / "MIGRATION.md").read_text(encoding="utf-8")
    assert "New source changes, specifications, proofs, tests, CI changes, issues, and pull requests belong here." in migration
