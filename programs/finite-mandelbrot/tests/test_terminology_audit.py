"""The terminology governance audit, on planted violations.

`tools/audit_terminology.py` is this repository's policy over the vendored
`lexical_audit` engine. Each case plants one violation in a small tree that
otherwise carries this repository's registry, use manifest and rank-2 files,
and asserts the audit names it; the clean copy passes, so every finding below
is the planted one.
"""

from __future__ import annotations

import shutil
from pathlib import Path

import pytest

from audit_terminology import POLICY, RANK2_DOCUMENT, RANK2_OPERATOR, REGISTRY, USE_MANIFEST
from lexical_audit import audit

ROOT = Path(__file__).resolve().parents[1]
GOVERNING = (REGISTRY, USE_MANIFEST, RANK2_DOCUMENT, RANK2_OPERATOR)


@pytest.fixture
def tree(tmp_path: Path) -> Path:
    for rel in GOVERNING:
        (tmp_path / rel).parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / rel, tmp_path / rel)
    return tmp_path


def plant(tree: Path, rel: str, text: str) -> list[str]:
    (tree / rel).parent.mkdir(parents=True, exist_ok=True)
    (tree / rel).write_text(text, encoding="utf-8")
    return audit(tree, POLICY)


def test_the_repository_passes():
    assert audit(ROOT, POLICY) == []


def test_the_governing_copy_passes(tree):
    assert audit(tree, POLICY) == []


def test_a_risky_phrase_needs_negation_or_a_declaration(tree):
    risky = "docs/note.md: risky phrase 'isomorphic to' requires terminology declaration with genealogy and leaks"
    assert plant(tree, "docs/note.md", "The nest is isomorphic to the tree.\n") == [risky]
    assert plant(tree, "docs/note.md", "The nest is not isomorphic to the tree.\n") == []
    plant(tree, "docs/note.md", "The nest is isomorphic to the tree.\n")
    assert plant(tree, "kernel/mojo/x.mojo", "# The nest is isomorphic to the tree.\n") == [
        risky, risky.replace("docs/note.md", "kernel/mojo/x.mojo")], "comments are governed prose"
    (tree / "kernel/mojo/x.mojo").unlink()
    declared = ("Terminology declaration: nest\nGenealogy: g\nBridge claim: b\nKnown leaks: k\nUse discipline: u\n"
                "The nest is isomorphic to the tree.\n")
    assert plant(tree, "docs/note.md", declared) == []


def test_an_incomplete_declaration_is_named(tree):
    assert plant(tree, "docs/note.md", "Terminology declaration: nest\nGenealogy: g\n") == [
        "docs/note.md: terminology declaration missing fields: Bridge claim:, Known leaks:, Use discipline:"
    ]


def test_a_deprecated_term_needs_migration_context(tree):
    assert plant(tree, "docs/note.md", "We prove catalogue extensionality here.\n") == [
        "docs/note.md: deprecated term 'catalogue extensionality' requires migration/deprecation context; "
        "use SeparatorCatalogueAdequacy/Soundness/Completeness"
    ]
    assert plant(tree, "docs/note.md", "The legacy name catalogue extensionality is retired.\n") == []
    assert plant(tree, "docs/C1_catalogue_extensionality.md", "catalogue extensionality\n") == []


def test_a_c1_scoped_term_outside_c1_needs_a_pointer(tree):
    finding = "docs/note.md: C1-scoped term 'separator code' requires local declaration or registry pointer outside C1 files"
    assert plant(tree, "docs/note.md", "A separator code decides it.\n") == [finding]
    assert plant(tree, "docs/note.md", "A separator code decides it (docs/terminology-registry.md).\n") == []
    assert plant(tree, "docs/C1_note.md", "A separator code decides it.\n") == []
    assert plant(tree, "kernel/mojo/c1/x.mojo", "# A separator code decides it.\n") == []


def test_every_occurrence_of_a_scoped_term_is_read(tree):
    text = "There is no separator code here." + " " * 300 + "\nA separator code decides it.\n"
    assert plant(tree, "docs/note.md", text) == [
        "docs/note.md: C1-scoped term 'separator code' requires local declaration or registry pointer outside C1 files"
    ]


def test_the_rank2_operator_names_no_locus(tree):
    operator = (tree / RANK2_OPERATOR).read_text(encoding="utf-8")
    assert plant(tree, RANK2_OPERATOR, operator + "# not a unit circle\n") == [
        f"{RANK2_OPERATOR}: rank-2 locus phrase 'unit circle' is not allowed"
    ]


def test_the_rank2_substrate_may_name_a_locus_only_to_deny_it(tree):
    substrate = (tree / RANK2_DOCUMENT).read_text(encoding="utf-8")
    assert plant(tree, RANK2_DOCUMENT, substrate + "\n" + "x" * 300 + " The circle primitive.\n") == [
        f"{RANK2_DOCUMENT}: rank-2 locus phrase 'circle primitive' is not allowed"
    ]


def test_the_governing_documents_are_required(tree):
    (tree / USE_MANIFEST).unlink()
    assert audit(tree, POLICY) == [f"{USE_MANIFEST}: required terminology use manifest is missing"]
    registry = (tree / REGISTRY).read_text(encoding="utf-8")
    (tree / REGISTRY).write_text(registry.replace("## Deprecated project terms", "## Old terms"), encoding="utf-8")
    assert audit(tree, POLICY) == [
        f"{REGISTRY}: missing deprecated project terms section",
        f"{USE_MANIFEST}: required terminology use manifest is missing",
    ]


def test_the_manifest_must_mark_the_legacy_term_deprecated(tree):
    manifest = (tree / USE_MANIFEST).read_text(encoding="utf-8")
    (tree / USE_MANIFEST).write_text(manifest.replace("deprecated", "retired").replace("Deprecated", "Retired"), encoding="utf-8")
    assert audit(tree, POLICY) == [f"{USE_MANIFEST}: legacy catalogue extensionality must be marked deprecated"]
