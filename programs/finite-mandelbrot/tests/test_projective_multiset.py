from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "kernel/mojo/dynamics/projective_multiset.mojo"
SPEC = ROOT / "docs" / "projective-multiset.md"
DEFINITION = ROOT / "docs" / "mandelbrot-defining-family.md"
BRIDGE = ROOT / "docs" / "multiset-bridge-program.md"
BRIDGE_SOURCE = ROOT / "kernel/mojo/dynamics/critical_relation_bridge.mojo"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_projective_morphism_and_infinity_multiplicity_are_explicit():
    spec = read(SPEC)
    source = read(SOURCE)
    assert "F_c [X:Z] = [X^2 + c Z^2 : Z^2]" in spec
    assert "(F_c^n)^* [infinity] = 2^n [infinity]" in spec
    assert "def infinity_pullback_multiplicity" in source
    assert "return 1 << iterates" in source


def test_affine_landing_is_separated_from_algebraic_escape():
    spec = read(SPEC)
    source = read(SOURCE)
    assert "an affine orbit" in spec
    assert "never lands on the infinity divisor" in spec
    assert "def affine_orbit_lands_at_infinity" in source
    assert "return False" in source


def test_multiset_coefficient_has_declared_semantics_and_grading():
    spec = read(SPEC)
    source = read(SOURCE)
    assert "critical-basin multiplicity" in spec
    assert "graded by the exact critical-orbit signature" in spec
    assert "struct ParameterCycle" in source
    assert "var multiplicity: Int" in source
    assert "var tail: Int" in source
    assert "var period: Int" in source


def test_claim_firewall_is_explicit():
    spec = " ".join(read(SPEC).split())
    assert "does not identify a finite-field shadow with the classical Mandelbrot set" in spec
    assert "local connectivity, fibre triviality, or landing of external rays" in spec
    assert "Supporting general prime powers" in spec


def test_actual_defining_family_is_typed_and_authoritative():
    definition = read(DEFINITION)
    assert "f_c(z) = z^2 + c" in definition
    assert "Phi(c,z) = (c, z^2 + c)" in definition
    assert "s(c) = (c,0)" in definition
    assert "Q_n(c) = f_c^n(0)" in definition
    assert "M = {c in C : the sequence (Q_n(c))_{n >= 0} is bounded}" in definition
    assert "x_n^2 + y_n^2 > 4" in definition
    assert "Projectivization alone does not turn boundedness" in definition
    assert "retained as a candidate" in definition


def test_readme_routes_to_the_authoritative_definition():
    readme = read(ROOT / "README.md")
    assert "docs/mandelbrot-defining-family.md" in readme
    assert "not alternative definitions of the Mandelbrot set" in readme
    assert "docs/multiset-bridge-program.md" in readme


def test_multiset_bridge_is_a_staged_theorem_program_not_an_exclusion():
    definition = " ".join(read(DEFINITION).split())
    bridge = " ".join(read(BRIDGE).split())
    assert "Such conversions are theorem targets, not prohibited constructions" in definition
    assert "A_{ell,k}(C) = Q_{ell+k}(C) - Q_ell(C)" in bridge
    assert "Good-reduction and lifting certificate" in bridge
    assert "critical-basin cardinality over `F_p`" in bridge
    assert "remains in the toolbox" in bridge
    assert "It is not yet an imported theorem" in bridge


def test_simple_residue_root_bridge_is_executable_and_bounded():
    bridge = read(BRIDGE)
    source = read(BRIDGE_SOURCE)
    assert "simple-residue-root subcertificate" in bridge
    assert "struct SimpleResidueRootCertificate" in source
    assert "def bounded_prime" in source
    assert "def reduction_commutes_through" in source
    assert "def exact_minimal_collision_pattern" in source
    assert "def verify_simple_residue_root" in source
    assert "does not construct an infinite Hensel lift" in source


def test_first_hensel_step_is_replayed_without_claiming_full_lift():
    source = read(BRIDGE_SOURCE)
    bridge = read(BRIDGE)
    assert "struct HenselStepCertificate" in source
    assert "hensel_step(relation_mod_p2, base.residue, prime)" in source
    assert "def verify_hensel_step" in source
    assert "correction_digit" in source
    assert "lifted_relation_holds" in source
    assert "not an infinite p-adic lift" in source
    assert "one replayable Hensel step" in bridge
    assert "not an asserted infinite" in bridge


def test_bounded_linear_factor_provenance_closes_the_rational_subcase():
    source = read(BRIDGE_SOURCE)
    bridge = read(BRIDGE)
    assert "struct LinearFactorProvenance" in source
    assert "def synthetic_divide_monic_linear" in source
    assert "def verify_linear_factor_provenance" in source
    assert "recomposition_exact" in source
    assert "matches_lift_mod_p2" in source
    assert "does not factor a" in source
    assert "bounded factor provenance" in bridge
    assert "not a general factorization" in bridge
