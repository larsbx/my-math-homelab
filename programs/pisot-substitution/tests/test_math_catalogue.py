from pathlib import Path
import tomllib

from psc_research import overlap_graph


ROOT = Path(__file__).resolve().parents[1]


def _catalogue():
    return tomllib.loads(
        (ROOT / "docs/catalogues/mathematical_objects.toml").read_text(encoding="utf-8")
    )


def test_overlap_graph_is_registered_as_oracle_for_canonical_mojo_kernel():
    entries = {item["id"]: item for item in _catalogue()["object"]}
    item = entries[overlap_graph.CATALOGUE_OBJECT_ID]
    assert overlap_graph.IMPLEMENTATION_ROLE == "independent-oracle"
    assert item["canonical"] == overlap_graph.CANONICAL_IMPLEMENTATION
    assert item["oracle"] == "reference/psc_research/overlap_graph.py"


def test_catalogue_paths_exist():
    for item in _catalogue()["object"]:
        assert (ROOT / item["canonical"]).is_file(), item["canonical"]
        assert (ROOT / item["oracle"]).is_file(), item["oracle"]
