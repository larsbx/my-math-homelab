from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = ROOT / "docs" / "SPEC_finite_fiber_stabilization.md"
BLOCKS = ROOT / "docs" / "top-conjecture-blocks.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_top_conjecture_is_c1_and_mlc_bridge():
    spec = read(SPEC)
    assert "C1: Global finite nest stabilization iff MLC" in spec
    assert "all Mandelbrot fibers are trivial" in spec
    assert "Schleicher" in spec


def test_generic_frontier_remains_open():
    spec = read(SPEC)
    assert "Generic boundary carriers do not receive unconditional singleton certificates." in spec
    assert "exactly the MLC-level obstruction" in spec
    assert "generic co-landing is unconditionally finitely certified" in spec
    assert "Invalid claims" in spec


def test_blocks_register_defers_secondary_work():
    blocks = read(BLOCKS)
    assert "implementation work is paused unless it supports C1 directly" in blocks
    assert "full bigint backend" in blocks
    assert "hash-root finalization" in blocks
    assert "finite-field shadow experiments" in blocks
    assert "renderer/pixel work" in blocks


def test_allowed_work_is_fiber_stabilization_only():
    blocks = read(BLOCKS)
    assert "finite nest schema" in blocks
    assert "separation-line schema" in blocks
    assert "ray-address combinatorics" in blocks
    assert "theorem-tag dependency records" in blocks
