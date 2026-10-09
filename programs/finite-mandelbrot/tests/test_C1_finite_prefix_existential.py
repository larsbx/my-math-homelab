from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/c1/bridge/finite_prefix_existential.mojo"
DOC = ROOT / "docs" / "C1_finite_prefix_to_existential_separation.md"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_prefix_existential_scaffold_exists():
    src = read(SRC)
    assert "struct PrefixSeparatorRecord" in src
    assert "struct PrefixSideWitness" in src
    assert "struct ExistentialSeparationWitness" in src
    assert "fn prefix_to_existential_separation" in src


def test_existential_requires_prefix_occurrence_and_admissibility():
    src = read(SRC)
    assert "separator_is_admissible" in src
    assert "occurs_in_prefix" in src
    assert "self.prefix_level >= 0" in src
    assert "self.separator_is_admissible and self.occurs_in_prefix" in src
    assert "demo_missing_prefix_rejects" in src


def test_existential_requires_same_separator_distinct_objects_and_opposite_sides():
    src = read(SRC)
    assert "same_separator" in src
    assert "distinct_objects" in src
    assert "opposite_open_sides" in src
    assert "a.side_label != b.side_label" in src
    assert "demo_same_side_rejects_existential" in src


def test_on_separator_cannot_introduce_existential_separation():
    src = read(SRC)
    assert "OnSeparator" in src
    assert "demo_on_separator_rejects_existential" in src
    assert "self.side_label == \"Left\" or self.side_label == \"Right\"" in src


def test_local_existential_does_not_claim_global_results():
    src = read(SRC)
    assert "claims_catalogue_completeness" in src
    assert "claims_global_same_fiber" in src
    assert "claims_mlc" in src
    assert "generic_same_fiber_not_claimed" in src
    assert "not w.claims_global_same_fiber and not w.claims_mlc" in src


def test_doc_keeps_scope_local():
    doc = read(DOC)
    assert "does not prove" in doc
    assert "absence of separation in prefix `k` implies same fiber" in doc
    assert "MLC" in doc
    assert "finite accepted prefix witness => existential finite separation" in doc
    assert "classical separation => eventually enumerated finite separator code" in doc
