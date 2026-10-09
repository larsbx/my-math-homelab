from pathlib import Path
import re
import subprocess
import tomllib

from mojo_include import mojo_run


ROOT = Path(__file__).resolve().parents[1]


def test_toolchain_versions_and_tasks_are_pinned():
    manifest = tomllib.loads((ROOT / "pixi.toml").read_text(encoding="utf-8"))
    assert manifest["dependencies"]["mojo"] == "==1.0.0"
    assert manifest["pypi-dependencies"]["pytest"] == "==8.3.5"
    assert manifest["tasks"]["mojo-smoke"] == "mojo run -I kernel/mojo -I vendor/mojo kernel/mojo/smoke/smoke_tests.mojo"
    assert manifest["tasks"]["mojo-build"].startswith("mojo build -I kernel/mojo -I vendor/mojo kernel/mojo/smoke/smoke_tests.mojo")


MODULAR_PACKAGE = re.compile(
    r"conda\.modular\.com/max/[a-z0-9-]+/(?P<name>[a-z0-9-]+?)-(?P<version>\d[^-/]*)-[^-/]+\.conda"
)


def test_every_modular_package_in_the_lock_is_pinned_in_the_manifest():
    """A fresh solve may not move any MAX or Mojo package: each one the lock
    takes from the Modular channel is pinned by `==` to its locked version."""
    manifest = tomllib.loads((ROOT / "pixi.toml").read_text(encoding="utf-8"))
    locked = {
        m["name"]: m["version"]
        for m in MODULAR_PACKAGE.finditer((ROOT / "pixi.lock").read_text(encoding="utf-8"))
    }
    assert {"mojo", "mojo-compiler", "mojo-python"} <= set(locked)
    assert {name: manifest["dependencies"].get(name) for name in locked} == {
        name: f"=={version}" for name, version in locked.items()
    }


def test_ci_executes_both_mojo_compile_paths():
    workflow = (ROOT / ".github" / "workflows" / "no-trig-audit.yml").read_text(
        encoding="utf-8"
    )
    assert "pixi run mojo-build" in workflow
    assert "pixi run mojo-smoke" in workflow


def test_smoke_failure_exits_nonzero():
    result = subprocess.run(
        mojo_run("kernel/mojo/smoke/smoke_failure_probe.mojo"),
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode != 0
    assert "finite-regime Mandelbrot smoke tests: FAIL" in (
        result.stdout + result.stderr
    )


def test_compiler_checked_boundary_is_explicit():
    boundary = (ROOT / "docs" / "mojo-toolchain-boundary.md").read_text(
        encoding="utf-8"
    )
    for path in [
        "kernel/mojo/smoke/smoke_tests.mojo",
        "kernel/mojo/polynomial/poly_z.mojo",
        "kernel/mojo/certificates/cert_types.mojo",
        "vendor/mojo/finite_exact/rat_q.mojo",
        "vendor/mojo/finite_exact/integer_gcd.mojo",
        "kernel/mojo/dynamics/ray_address.mojo",
        "kernel/mojo/arithmetic/rational_trig.mojo",
        "kernel/mojo/theorem_kernel/alignment_audit_status.mojo",
        "kernel/mojo/theorem_kernel/mojo_optimization_contract.mojo",
        "vendor/mojo/finite_exact/closed_q.mojo",
        "kernel/mojo/polynomial/poly_interval_eval.mojo",
        "kernel/mojo/certificates/krawczyk_witness.mojo",
        "kernel/mojo/c1/proof/final_proof_block_ledger.mojo",
        "kernel/mojo/c1/residual/residual_closure_no_missing_links.mojo",
        "kernel/mojo/c1/theorem_tags/theorem_tag_assumption_payloads.mojo",
        "kernel/mojo/c1/theorem_tags/theorem_tag_import_ledger.mojo",
        "kernel/mojo/c1/proof/final_proof_object_skeleton.mojo",
        "kernel/mojo/arithmetic/cert_backend.mojo",
        "kernel/mojo/c1/theorem_tags/theorem_tag_payload_instances.mojo",
        "vendor/mojo/finite_exact/bigint_z.mojo",
        "kernel/mojo/arithmetic/bigint_adapter.mojo",
        "vendor/mojo/mojo_smoke/report.mojo",
        "kernel/mojo/dynamics/angle_tuning.mojo",
        "vendor/mojo/quadratic_orbit/collision.mojo",
        "vendor/mojo/quadratic_orbit/orbit.mojo",
        "vendor/mojo/rational_dynamics/rational.mojo",
        "vendor/mojo/rational_dynamics/doubling.mojo",
        "vendor/mojo/rational_dynamics/moebius.mojo",
        "vendor/mojo/rational_dynamics/multiplicative_order.mojo",
        "vendor/mojo/rational_dynamics/carmichael.mojo",
        "vendor/mojo/rational_dynamics/integers.mojo",
        "vendor/mojo/angle_doubling/angle.mojo",
    ]:
        assert path in boundary
    assert "Passing it does not imply that" in boundary
    assert "every `.mojo` file compiles" in boundary
