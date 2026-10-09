from pathlib import Path
import tomllib

ROOT = Path(__file__).resolve().parents[1]
# The machine-integer gcd lives upstream in finite_exact and is vendored here.
CANONICAL = ROOT / "vendor/mojo/finite_exact/integer_gcd.mojo"
RETIRED_LOCAL_COPY = ROOT / "kernel/mojo/arithmetic/integer_gcd.mojo"


def test_gcd_implementations_are_centralized():
    canonical = CANONICAL.read_text(encoding="utf-8")
    assert "def gcd_int(" in canonical
    assert "def gcd_i64(" in canonical
    assert "def gcd_i64_or_one(" in canonical

    retired_definitions = {
        "vendor/mojo/finite_exact/rat_q.mojo": ["def gcd_i64(", "fn gcd_i64("],
        "kernel/mojo/arithmetic/big_int_boundary.mojo": ["def gcd_i64(", "fn gcd_i64("],
        "kernel/mojo/certificates/certificate_sets.mojo": ["def gcd_int(", "fn gcd_int("],
        "kernel/mojo/c1/separator/rational_separator_coding.mojo": ["def gcd_i(", "fn gcd_i("],
    }
    for relative, forbidden_definitions in retired_definitions.items():
        text = (ROOT / relative).read_text(encoding="utf-8")
        for definition in forbidden_definitions:
            assert definition not in text


def test_zero_case_policy_is_explicit_for_rational_normalization():
    rational = (ROOT / "vendor/mojo/finite_exact/rat_q.mojo").read_text(encoding="utf-8")
    assert "if nn.is_zero():" in rational
    assert "var common = bigz_gcd(nn, dd)" in rational
    assert "bigz_div_exact(nn, common)" in rational
    assert "bigz_div_exact(dd, common)" in rational


def test_the_gcd_is_the_pinned_vendored_module_and_no_local_copy_remains():
    manifest = tomllib.loads((ROOT / "vendored.toml").read_text(encoding="utf-8"))
    finite_exact = next(p for p in manifest["package"] if p["name"] == "finite_exact")
    assert "finite_exact/integer_gcd.mojo" in finite_exact["files"]
    assert not RETIRED_LOCAL_COPY.exists()
    importers = [path for path in (ROOT / "kernel").rglob("*.mojo")
                 if "from finite_exact.integer_gcd import" in path.read_text(encoding="utf-8")]
    assert importers
    for path in (ROOT / "kernel").rglob("*.mojo"):
        assert "arithmetic.integer_gcd" not in path.read_text(encoding="utf-8"), path
