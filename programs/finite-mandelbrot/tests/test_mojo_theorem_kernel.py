from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POLICY = ROOT / "docs" / "mojo_first_execution_policy.md"
REGISTRY = ROOT / "docs" / "terminology-registry.md"
KERNEL = ROOT / "kernel/mojo/theorem_kernel/mojo_theorem_kernel.mojo"


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_mojo_theorem_kernel_is_declared_and_governed():
    body = text(POLICY) + "\n" + text(REGISTRY) + "\n" + text(KERNEL)
    assert "Mojo theorem kernel" in body
    assert "finite proof-object theorem kernel" in body
    assert "ProofObject" in body
    assert "RuleApplication" in body
    assert "CheckedTheoremStatus" in body


def test_theorem_tags_are_import_boundary_not_internal_proofs():
    body = text(POLICY) + "\n" + text(KERNEL)
    assert "TheoremTagImport" in body
    assert "internal_proof_claimed" in body
    assert "if tag.internal_proof_claimed" in body
    assert "return False" in body
    assert "theorem_tags_are_axiom_import_boundary() -> Bool" in body


def test_kernel_rejects_mlc_and_rank2_circle_claims():
    body = text(KERNEL)
    assert "claims_global_mlc" in body
    assert "uses_rank2_circle" in body
    assert "global MLC-strength claim is open frontier" in body
    assert "rank-2 circle primitive rejected" in body
    assert "rank2_circle_primitive_available_in_kernel() -> Bool" in body


def test_kernel_accepts_finite_rule_checked_statement_only():
    body = text(KERNEL)
    assert "demo_finite_separator_theorem" in body
    assert "FinitePrefixToExistentialSeparation" in body
    assert "all_rules_checked" in body
    assert "unchecked local rule" in body
    assert "check_proof_object" in body


def test_policy_mentions_deterministic_proof_replay():
    body = text(POLICY)
    assert "deterministic proof replay" in body
    assert "no ambient mutable global theorem state" in body
