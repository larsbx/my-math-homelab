"""The exact-arithmetic audit, on this repository and on repositories built to fail.

An audit that has only ever seen a passing tree is a claim, not a check. Each
case below builds a small tree that violates one rule and asserts the audit
names it.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

import audit_exact_arithmetic as audit

ROOT = Path(__file__).resolve().parents[1]

SPEC_SECTIONS = "\n".join(
    [
        "## 0. The problem being solved",
        "## 5. Conformance criteria",
        "## 6. Consumers and binding tables",
        "| `larsbx/finite-julia-set-research` | `docs/exact-arithmetic-binding.md` | `src/finite_exact/` |",
        "## 7. Hook: how a consumer enforces the specification",
    ]
)

CONSUMER = 'from finite_exact.rat_q import Q\n\ndef f() -> Q:\n    return Q(1, 2)\n'
HEADER = "# Specification: docs/rational-interval-arithmetic-spec.md.\n"


@pytest.fixture
def tree(tmp_path, monkeypatch):
    """A minimal consumer: one bound, citing, exact module."""
    (tmp_path / "docs").mkdir()
    (tmp_path / "src").mkdir()
    (tmp_path / "tools").mkdir()
    (tmp_path / "docs" / "rational-interval-arithmetic-spec.md").write_text(SPEC_SECTIONS, encoding="utf-8")
    (tmp_path / "docs" / "exact-arithmetic-binding.md").write_text(
        "| Spec item | Module | Class | Notes |\n| --- | --- | --- | --- |\n"
        "| 1–2 kernel | `src/kernel.mojo` | DEMO | the one module |\n",
        encoding="utf-8",
    )
    (tmp_path / "tools" / "exact_arithmetic_allowlist.md").write_text("Empty by design.\n", encoding="utf-8")
    (tmp_path / "src" / "kernel.mojo").write_text(HEADER + CONSUMER, encoding="utf-8")
    monkeypatch.setattr(audit, "ROOT", tmp_path)
    monkeypatch.setattr(audit, "SPEC", tmp_path / "docs" / "rational-interval-arithmetic-spec.md")
    monkeypatch.setattr(audit, "BINDING", tmp_path / "docs" / "exact-arithmetic-binding.md")
    monkeypatch.setattr(audit, "ALLOWLIST", tmp_path / "tools" / "exact_arithmetic_allowlist.md")
    monkeypatch.setattr(audit, "SCAN_ROOTS", (tmp_path / "src",))
    return tmp_path


def test_this_repository_passes_its_own_audit():
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "audit_exact_arithmetic.py")],
        capture_output=True, text=True, cwd=ROOT, check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_a_faithful_tree_passes(tree):
    assert audit.audit() == []


def test_a_tree_without_a_manifest_exempts_nothing(tree):
    """No `vendored.toml` means nothing is vendored, so C7 applies to all."""
    assert audit.vendored_exempt() == ()


def test_a_vendored_module_is_exempt_from_the_citation(tree):
    """A vendored file carries upstream's header, so C7 is upstream's.

    The exemption is read from the manifest rather than written into the
    audit, so adding a package is one step and not two.
    """
    (tree / "vendored.toml").write_text(
        '[[package]]\nname = "borrowed"\nrepository = "elsewhere"\n'
        'commit = "' + "0" * 40 + '"\nroot = "src"\n\n[package.files]\n',
        encoding="utf-8",
    )
    (tree / "src" / "borrowed").mkdir()
    (tree / "src" / "borrowed" / "lifted.mojo").write_text(CONSUMER, encoding="utf-8")
    (tree / "docs" / "exact-arithmetic-binding.md").write_text(
        "| Spec item | Module | Class | Notes |\n| --- | --- | --- | --- |\n"
        "| 1–2 kernel | `src/kernel.mojo` | DEMO | the one module |\n"
        "| 1–2 borrowed | `src/borrowed/lifted.mojo` | CONFORMS | vendored |\n",
        encoding="utf-8",
    )
    assert audit.vendored_exempt() == ("src/borrowed/",)
    assert audit.audit() == []


def test_an_unvendored_module_still_owes_the_citation(tree):
    """The same file outside a vendored package is named by C7."""
    (tree / "src" / "lifted.mojo").write_text(CONSUMER, encoding="utf-8")
    (tree / "docs" / "exact-arithmetic-binding.md").write_text(
        "| Spec item | Module | Class | Notes |\n| --- | --- | --- | --- |\n"
        "| 1–2 kernel | `src/kernel.mojo` | DEMO | the one module |\n"
        "| 1–2 lifted | `src/lifted.mojo` | DEMO | not vendored |\n",
        encoding="utf-8",
    )
    assert audit.audit() == [
        "src/lifted.mojo does not cite docs/rational-interval-arithmetic-spec.md (C7)"
    ]


def test_an_unbound_arithmetic_consumer_is_named(tree):
    (tree / "src" / "stray.mojo").write_text(HEADER + CONSUMER, encoding="utf-8")
    assert audit.audit() == ["arithmetic consumer lacks binding row: src/stray.mojo"]


def test_a_bound_module_that_does_not_cite_the_spec_is_named(tree):
    (tree / "src" / "kernel.mojo").write_text(CONSUMER, encoding="utf-8")
    assert any("does not cite" in error for error in audit.audit())


def test_a_bound_module_that_does_not_exist_is_named(tree):
    (tree / "src" / "kernel.mojo").unlink()
    assert any("missing file" in error for error in audit.audit())


def test_a_float_type_in_kernel_scope_is_named(tree):
    (tree / "src" / "kernel.mojo").write_text(HEADER + CONSUMER + "\nvar x: Float64 = 0\n", encoding="utf-8")
    assert any("floating point in kernel scope" in error for error in audit.audit())


def test_a_decimal_literal_in_kernel_scope_is_named(tree):
    (tree / "src" / "kernel.mojo").write_text(HEADER + CONSUMER + "\nvar x = 0.5\n", encoding="utf-8")
    assert any("floating point in kernel scope" in error for error in audit.audit())


def test_a_decimal_in_a_comment_is_not_a_violation(tree):
    (tree / "src" / "kernel.mojo").write_text(HEADER + "# the bound is 0.25 here\n" + CONSUMER, encoding="utf-8")
    assert audit.audit() == []


def test_a_quarantine_without_an_allowlist_entry_is_named(tree):
    (tree / "docs" / "exact-arithmetic-binding.md").write_text(
        "| Spec item | Module | Class | Notes |\n| --- | --- | --- | --- |\n"
        "| 1–2 kernel | `src/kernel.mojo` | QUARANTINED | float substrate |\n",
        encoding="utf-8",
    )
    assert any("QUARANTINED but not allowlisted" in error for error in audit.audit())


def test_an_allowlist_entry_without_a_quarantine_is_named(tree):
    (tree / "tools" / "exact_arithmetic_allowlist.md").write_text("- `src/kernel.mojo`\n", encoding="utf-8")
    assert any("allowlisted but not a QUARANTINED" in error for error in audit.audit())


def test_a_spec_that_does_not_name_this_consumer_is_named(tree):
    spec = tree / "docs" / "rational-interval-arithmetic-spec.md"
    spec.write_text(spec.read_text().replace("larsbx/finite-julia-set-research", "larsbx/somewhere-else"), encoding="utf-8")
    assert audit.audit() == ["docs/rational-interval-arithmetic-spec.md does not name this repository as a consumer"]


def test_the_live_allowlist_is_empty():
    """Prose in the allowlist names paths; none of them is a grant."""
    assert audit.allowlisted() == set()
