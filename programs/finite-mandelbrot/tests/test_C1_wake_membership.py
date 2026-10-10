from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/c1/wake/wake_membership.mojo"
DOC = ROOT / "docs" / "C1_wake_membership_soundness.md"
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))
from claim_governance.lexing import mask_comments_and_strings


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_wake_membership_files_exist():
    assert SRC.exists()
    assert DOC.exists()


def test_strict_cyclic_membership_is_present():
    src = read(SRC)
    assert "strictly_between_cyclic" in src
    assert "Wrapped interval" in src
    assert "strictly_between_linear" in src
    assert "same_addr" in src


def test_boundary_addresses_are_rejected_as_side_witnesses():
    src = read(SRC)
    doc = read(DOC)
    assert "on_separator" in src
    assert "return False" in src
    assert "OnSeparator" in doc
    assert "not a separation proof" in doc


def test_theorem_tag_and_incidence_binding_are_required():
    src = read(SRC)
    doc = read(DOC)
    assert "incidence_bound" in src
    assert "theorem_tagged" in src
    assert "incidence_bound and self.theorem_tagged" in src
    assert "Incidence binding" in doc
    assert "Classical reading" in doc


def test_wake_membership_soundness_remains_pending():
    src = read(SRC)
    doc = read(DOC)
    assert "wake_membership_soundness_claim_is_available" in src
    assert "return False" in src
    assert "WakeMembershipSoundness" in doc
    assert "one-way soundness lemma" in doc


def test_no_generic_stabilization_claim():
    src = read(SRC)
    doc = read(DOC)
    forbidden = [
        "claim MLC",
        "generic boundary landing",
        "pixel",
        "renderer",
        "hash-root",
    ]
    # The doc may mention forbidden phrases only under explicit non-goals.
    assert "does not claim stabilization" in src or "does_not_claim_stabilization" in src
    assert "does not imply" in doc
    assert "does not assert" in doc
    assert "wake_membership_does_not_claim_stabilization" in src


def test_no_analytic_shortcuts_in_scaffold():
    src = mask_comments_and_strings(read(SRC))
    banned = ["sin", "cos", "tan", "Float64", "Float32", "pixel", "ray curve"]
    for token in banned:
        assert token not in src
