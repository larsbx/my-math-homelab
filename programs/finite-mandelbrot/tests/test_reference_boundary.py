"""Estate reference-plane boundary."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

MAPPINGS = {
    "tools/poly_reference.py": "reference/python/polynomial/poly_reference.py",
    "tools/interval_exclusion_reference.py": "reference/python/interval/interval_exclusion_reference.py",
    "tools/misiurewicz_catalogue_reference.py": "reference/python/c1/misiurewicz_catalogue_reference.py",
    "tools/misiurewicz_prefix_graph_reference.py": "reference/python/c1/misiurewicz_prefix_graph_reference.py",
    "tools/kneading_reference.py": "reference/python/c1/kneading_reference.py",
    "tools/exact_arithmetic_property_oracle.py": "reference/python/arithmetic/exact_arithmetic_property_oracle.py",
}


def test_reference_implementations_live_in_the_reference_plane():
    for shim, canonical in MAPPINGS.items():
        canonical_path = ROOT / canonical
        assert canonical_path.is_file(), canonical
        assert len(canonical_path.read_text(encoding="utf-8").splitlines()) > 40


def test_tools_entrypoints_are_only_compatibility_shims():
    for shim, canonical in MAPPINGS.items():
        body = (ROOT / shim).read_text(encoding="utf-8")
        assert canonical in body
        assert "Compatibility shim" in body
        assert len(body.splitlines()) < 30, shim


def test_ci_uses_reference_plane_not_compatibility_shims():
    workflow = (ROOT / ".github" / "workflows" / "no-trig-audit.yml").read_text(encoding="utf-8")
    assert "reference/python/polynomial/poly_reference.py" in workflow
    assert "reference/python/interval/interval_exclusion_reference.py" in workflow
    assert "tools/poly_reference.py" not in workflow
    assert "tools/interval_exclusion_reference.py" not in workflow
