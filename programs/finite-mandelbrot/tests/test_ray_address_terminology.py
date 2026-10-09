from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def test_executable_certificate_fields_use_symbolic_address_language():
    cert = read("kernel/mojo/certificates/cert_types.mojo")
    joint = read("kernel/mojo/certificates/joint_certificate.mojo")
    validator = read("kernel/mojo/certificates/validator_plan.mojo")
    assert "ray_address_preperiod_lambda" in cert
    assert "angle_preperiod_lambda" not in cert
    assert "ray_address_kneading_match" in joint
    assert "angle_kneading_match" not in joint
    assert "fn ray_address_preperiod" in validator
    assert "fn angle_preperiod" not in validator


def test_stable_theta_witness_ids_remain_compatible():
    incidence = read("kernel/mojo/certificates/certificate_incidence.mojo")
    certificate = read("kernel/mojo/certificates/misiurewicz_certificate.mojo")
    for witness_id in ["theta_1_2", "theta_9_11_15_over_56"]:
        assert witness_id in incidence
        assert witness_id in certificate


def test_address_diagnostics_do_not_claim_measurement():
    sets = read("kernel/mojo/certificates/certificate_sets.mojo")
    assert '"ray address 1/2"' in sets
    assert '"angle 1/2"' not in sets
    assert "addresses are rational" in sets
