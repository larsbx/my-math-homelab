from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_ray_address_value_types_are_centralized():
    canonical = (ROOT / "kernel/mojo/dynamics/ray_address.mojo").read_text(encoding="utf-8")
    assert "struct RayAddr(" in canonical
    # Doubling is the vendored rational_dynamics map, not a local Int copy.
    assert "struct RayAddr64(" not in canonical
    assert "def doubled(" not in canonical
    for relative in [
        "kernel/mojo/c1/separator/separation_grammar.mojo",
        "kernel/mojo/c1/separator/separator_codes.mojo",
        "kernel/mojo/c1/separator/rational_separator_coding.mojo",
        "kernel/mojo/arithmetic/rational_trig.mojo",
    ]:
        text = (ROOT / relative).read_text(encoding="utf-8")
        assert "struct RayAddrFinite" not in text
        assert "struct RayAddrCode" not in text
        assert "struct RayAddr:" not in text


def test_ray_address_metadata_record_remains_distinct():
    metadata = (ROOT / "kernel/mojo/certificates/misiurewicz_certificate.mojo").read_text(encoding="utf-8")
    assert "struct RayAddressDatum" in metadata
    assert "var preperiod: Int" in metadata
    assert "var ray_period: Int" in metadata
