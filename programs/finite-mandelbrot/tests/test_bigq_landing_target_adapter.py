from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def test_bigq_ray_address_is_normalized_fail_closed_and_unbounded():
    src = (ROOT / "kernel/mojo/dynamics/bigq_ray_address.mojo").read_text(encoding="utf-8")
    assert "from finite_exact.rat_q import Q, q_from_bigz" in src
    # The address, its doubling, and its equality are the vendored
    # rational_dynamics package; this module keeps the [0, 1) contract.
    assert "from rational_dynamics.rational import (" in src
    assert "var value: ReducedFraction" in src
    assert "var doubled = double_mod_one(address.value)" in src
    assert "fraction_equal(a.value, b.value)" in src
    assert "def double_mod_one(value: ReducedFraction) -> ReducedFraction:" in (
        ROOT / "vendor/mojo/rational_dynamics/rational.mojo"
    ).read_text(encoding="utf-8")
    assert "value.num.sign < 0 or not value.lt(Q.one())" in src
    assert "var beyond_i64 = bigz_add(bigz_from_i64(9223372036854775807)" in src
    assert "bigz_mul(beyond_i64, bigz_from_i64(2))" in src
    assert "malformed.rejected and out_of_range.rejected" in src


def test_bigq_landing_association_composes_same_exponent_replays():
    src = (ROOT / "kernel/mojo/certificates/c_minus_2/bigq_landing_target_adapter.mojo").read_text(encoding="utf-8")
    assert "verify_bigq_p21_krawczyk_c_minus_2(half_width_den_power)" in src
    assert "bigq_p21_exact_type_exclusions(half_width_den_power)" in src
    assert "self.exclusions.half_width_den_power == self.half_width_den_power" in src
    assert "self.rays.preperiod + self.correspondence.critical_orbit_preperiod_offset == self.ell" in src
    assert "var narrow = verify_bigq_c_minus_2_landing_target_association(80)" in src


def test_correspondence_metadata_cannot_accept_theorem_or_certificate():
    src = (ROOT / "kernel/mojo/certificates/c_minus_2/bigq_landing_target_adapter.mojo").read_text(encoding="utf-8")
    assert "A citation key is metadata, never executable evidence of its theorem." in src
    assert "def theorem_import_accepted(self) -> Bool:\n        #" in src
    assert "def certificate_accepted(self) -> Bool:\n        return False" in src
    assert "not association.theorem_import_accepted()" in src
    assert "not association.certificate_accepted()" in src


def test_bigq_landing_replay_is_compiler_wired_and_policy_clean(mojo_smoke):
    smoke = (ROOT / "kernel/mojo/smoke/smoke_tests.mojo").read_text(encoding="utf-8")
    boundary = (ROOT / "docs" / "mojo-toolchain-boundary.md").read_text(encoding="utf-8")
    assert "from dynamics.bigq_ray_address import bigq_ray_address_replay_smoke" in smoke
    assert "from certificates.c_minus_2.bigq_landing_target_adapter import bigq_landing_target_replay_smoke" in smoke
    assert mojo_smoke.case_passed("bigq landing target replay")
    assert "kernel/mojo/dynamics/bigq_ray_address.mojo" in boundary
    assert "kernel/mojo/certificates/c_minus_2/bigq_landing_target_adapter.mojo" in boundary


def test_global_open_obligations_remain_explicitly_unproved():
    ledger = (ROOT / "kernel/mojo/c1/proof/final_proof_block_ledger.mojo").read_text(encoding="utf-8")
    residual = (ROOT / "kernel/mojo/c1/residual/residual_closure_no_missing_links.mojo").read_text(encoding="utf-8")
    assert 'ProofBlockStatus("ResidualClosureNoMissingLinks", False, False, True, False, True)' in ledger
    assert "def residual_closure_no_missing_links_accepts" in residual
    assert "def proves_c1_by_itself() -> Bool:\n    return False" in residual
