"""Every vendored package matches the commit pinned in vendored.toml."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from vendoring import check_vendored_sync as sync  # noqa: E402

PACKAGES = {
    "proof_architecture": ("larsbx/finite-math-kernels", "proof/tla"),
    "finite_exact": ("larsbx/finite-math-kernels", "kernel"),
    "substitution_dynamics": ("larsbx/finite-math-kernels", "kernel"),
    "finite_linear_algebra": ("larsbx/finite-math-kernels", "kernel"),
    "claim_governance": ("larsbx/finite-math-kernels", "tools"),
    "proof_records": ("larsbx/finite-math-kernels", "tools"),
    "oracle_refinement": ("larsbx/finite-math-kernels", "tools"),
    "parallel_fold": ("larsbx/finite-math-kernels", "kernel"),
    "finite_graph": ("larsbx/finite-math-kernels", "kernel"),
    "finite_automata": ("larsbx/finite-math-kernels", "kernel"),
    "mojo_smoke": ("larsbx/finite-math-kernels", "kernel"),
    "vendoring": ("larsbx/finite-math-kernels", "tools"),
    "polyglot_envelope": ("larsbx/finite-math-kernels", "tools"),
}


def test_vendored_packages_match_their_pins():
    assert sync.check() == []
    packages = {p["name"]: p for p in sync.load()}
    assert {n: (p["repository"], p["root"]) for n, p in packages.items()} == PACKAGES
    assert len({pkg["commit"] for pkg in packages.values()}) == 1, "every package is pinned to one upstream commit"
    for name, pkg in packages.items():
        assert pkg["repository"] == "larsbx/finite-math-kernels"
        if name == "proof_architecture":
            assert set(pkg["files"]) == {"ProofArchitecture.tla"}
        else:
            assert all(rel.startswith(name + "/") for rel in pkg["files"])
    # The inventory is written out so that a re-vendor which quietly adds or drops a file is a
    # test to update rather than a change nobody sees. self_test.py and known_answers.py arrived
    # with the import-time known-answer gate. Upstream keeps the package under kernel/proof_records
    # beside its Mojo sources and ProofArchitecture.tla; only the Python modules are taken here,
    # every one of them, and the TLA+ module is pinned separately as proof_architecture.
    assert set(packages["proof_records"]["files"]) == {"proof_records/__init__.py", "proof_records/records.py", "proof_records/generate_ledgers.py",
                                                       "proof_records/graph.py", "proof_records/self_test.py", "proof_records/known_answers.py",
                                                       "proof_records/vocabularies.py"}
    assert set(packages["oracle_refinement"]["files"]) == {"oracle_refinement/__init__.py"}
    assert set(packages["parallel_fold"]["files"]) == {
        "parallel_fold/__init__.mojo",
        "parallel_fold/map_fold.mojo",
    }
    assert set(packages["finite_graph"]["files"]) == {
        "finite_graph/__init__.mojo",
        "finite_graph/scc.mojo",
        "finite_graph/signing.mojo",
        "finite_graph/union_find.mojo",
    }
    # moore_minimisation.mojo and subset_construction.mojo arrived when upstream split named
    # algorithms into their own modules; dfa.mojo re-exports them.
    assert set(packages["finite_automata"]["files"]) == {"finite_automata/__init__.mojo", "finite_automata/dfa.mojo",
                                                         "finite_automata/moore_minimisation.mojo",
                                                         "finite_automata/subset_construction.mojo"}
    assert set(packages["mojo_smoke"]["files"]) == {"mojo_smoke/__init__.mojo", "mojo_smoke/claims.mojo", "mojo_smoke/report.mojo"}
    assert set(packages["vendoring"]["files"]) == {"vendoring/__init__.py", "vendoring/check_vendored_sync.py"}


def test_local_patch_is_detected(tmp_path, monkeypatch):
    for pkg in sync.load():
        for rel in pkg["files"]:
            target = tmp_path / pkg["root"] / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes((ROOT / pkg["root"] / rel).read_bytes())
    manifest = tmp_path / "vendored.toml"
    manifest.write_text((ROOT / "vendored.toml").read_text(encoding="utf-8"), encoding="utf-8")
    assert sync.check(tmp_path, manifest) == []
    target = tmp_path / "kernel" / "finite_exact" / "rat_q.mojo"
    target.write_text(target.read_text(encoding="utf-8") + "\n# local patch\n", encoding="utf-8")
    (tmp_path / "kernel" / "finite_exact" / "extra.mojo").write_text("", encoding="utf-8")
    (tmp_path / "tools" / "claim_governance" / "local_rule.py").write_text("", encoding="utf-8")
    errors = sync.check(tmp_path, manifest)
    assert any("rat_q.mojo differs" in e for e in errors)
    assert any("finite_exact/extra.mojo is not pinned" in e for e in errors)
    assert any("claim_governance/local_rule.py is not pinned" in e for e in errors)


def test_no_second_arithmetic_or_kernel_lives_beside_the_packages():
    psc = ROOT / "kernel" / "psc"
    # The second group moved upstream at finite-math-kernels da41c27 and is vendored from there.
    for retired in ["rational.mojo", "rational_interval.mojo", "mat3.mojo", "qlinalg.mojo", "tensor3.mojo",
                    "checked_int.mojo", "integer_matrix.mojo", "integer_vector.mojo", "automata.mojo", "signing.mojo",
                    "claim_tests.mojo"]:
        assert not (psc / retired).exists(), retired
    for path in psc.glob("*.mojo"):
        body = path.read_text(encoding="utf-8")
        assert "struct Rat" not in body and "struct Mat3" not in body, path.name


def _copy_vendored_tree(tmp_path):
    for pkg in sync.load():
        for rel in pkg["files"]:
            target = tmp_path / pkg["root"] / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes((ROOT / pkg["root"] / rel).read_bytes())
    for name in ("vendored.toml", "ESTATE.toml"):
        (tmp_path / name).write_bytes((ROOT / name).read_bytes())
    return tmp_path / "vendored.toml"


def test_estate_pin_is_the_vendored_digest():
    # ESTATE.toml's [[dep]] pin for each vendoring source is derived from vendored.toml as the
    # pinned estate audit derives it; CI's policy job runs that audit against the same pin.
    assert set(sync.estate_pins()) == {"finite-math-kernels"}
    assert sync.estate_drift() == []


def test_estate_pin_drift_is_detected_and_rederived(tmp_path):
    manifest = _copy_vendored_tree(tmp_path)
    estate = tmp_path / "ESTATE.toml"
    good = estate.read_text(encoding="utf-8")
    estate.write_text(good.replace(sync.estate_pins()["finite-math-kernels"], "sha256:" + "0" * 64), encoding="utf-8")
    assert any("finite-math-kernels" in e for e in sync.check(tmp_path, manifest))
    assert sync.write_estate_pins(tmp_path, manifest) == []
    assert estate.read_text(encoding="utf-8") == good
    assert sync.check(tmp_path, manifest) == []


def test_pin_rederives_the_estate_pin(tmp_path):
    manifest = _copy_vendored_tree(tmp_path)
    target = tmp_path / "kernel" / "finite_exact" / "rat_q.mojo"
    target.write_text(target.read_text(encoding="utf-8") + "\n# re-vendored\n", encoding="utf-8")
    pkg = next(p for p in sync.load(manifest) if p["name"] == "finite_exact")
    assert sync.pin("finite_exact", pkg["commit"], tmp_path, manifest) == []
    assert sync.check(tmp_path, manifest) == []
    assert sync.estate_pins(tmp_path, manifest) != sync.estate_pins()


def test_missing_estate_dep_fails_closed(tmp_path):
    manifest = _copy_vendored_tree(tmp_path)
    estate = tmp_path / "ESTATE.toml"
    estate.write_text(estate.read_text(encoding="utf-8").replace('id = "finite-math-kernels"', 'id = "renamed"'), encoding="utf-8")
    assert any("no [[dep]]" in e for e in sync.write_estate_pins(tmp_path, manifest))
    assert any("no [[dep]]" in e for e in sync.check(tmp_path, manifest))
