from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "kernel/mojo/certificates/c_minus_2/bigq_certificate_incidence.mojo"


def text() -> str:
    return SRC.read_text(encoding="utf-8")


def test_carrier_contains_explicit_finite_vertices_not_only_a_size():
    src = text()
    assert "struct FiniteVertexCarrier3(Copyable)" in src
    assert "var root_handle: FiniteVertex" in src
    assert "var ray_address_set: FiniteVertex" in src
    assert "var rational_box: FiniteVertex" in src
    assert "self.root_handle.valid()" in src
    assert "not self.root_handle.eq(self.ray_address_set)" in src


def test_point_vertex_is_incidence_only_and_has_finite_carrier():
    src = text()
    assert "struct PointVertex(Copyable)" in src
    assert "var carrier: FiniteVertexCarrier3" in src
    assert "self.carrier.valid() and self.incidence_only" in src
    assert 'FiniteVertex("RootHandle", "P_2_1@" + box_name)' in src
    assert 'FiniteVertex("RayAddressSet", "address_1_over_2")' in src
    assert 'FiniteVertex("RationalBox", box_name)' in src


def test_packaging_is_separate_from_certificate_emission():
    src = text()
    assert "def finite_incidence_packaged(self) -> Bool:" in src
    assert "def certificate_emitted(self) -> Bool:" in src
    assert "self.status.certificate_accepted()" in src
    assert "not packaged.certificate_emitted()" in src
    assert "not malformed.valid()" in src


def test_ambiguous_arithmetic_cannot_package_incidence():
    src = text()
    assert "var ambiguous = bigq_c_minus_2_certificate_incidence(0)" in src
    assert "not ambiguous.finite_incidence_packaged()" in src


def test_c1_and_residual_closure_remain_false():
    src = text()
    assert "def proves_c1(self) -> Bool:\n        return False" in src
    assert "def proves_residual_closure_no_missing_links(self) -> Bool:\n        return False" in src


def test_incidence_replay_is_compiler_wired(mojo_smoke):
    smoke = (ROOT / "kernel/mojo/smoke/smoke_tests.mojo").read_text(encoding="utf-8")
    boundary = (ROOT / "docs" / "mojo-toolchain-boundary.md").read_text(encoding="utf-8")
    assert "from certificates.c_minus_2.bigq_certificate_incidence import bigq_certificate_incidence_smoke" in smoke
    assert mojo_smoke.case_passed("bigq certificate incidence")
    assert "kernel/mojo/certificates/c_minus_2/bigq_certificate_incidence.mojo" in boundary
