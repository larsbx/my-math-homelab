"""This repository's estate manifest, ESTATE.toml (estate-repository-v2).

CI validates the manifest with the audit from a pinned checkout of
larsbx/estate-governance; these tests pin the facts that are this
repository's own: identity, estate position, edges and authority.
"""

import re
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ESTATE = tomllib.loads((ROOT / "ESTATE.toml").read_text(encoding="utf-8"))
DEPS = {d["id"]: d for d in ESTATE["dep"]}


def test_estate_manifest_names_canonical_repository():
    assert ESTATE["template"] == "estate-repository-v2"
    assert (ESTATE["repo"]["id"], ESTATE["repo"]["slug"]) == ("finite-mandelbrot-research", "larsbx/finite-mandelbrot-research")
    assert ESTATE["principles"]["ordering"] == ["authority", "domain", "language"]


def test_estate_position_is_a_proposed_research_candidate():
    assert (ESTATE["repo"]["class"], ESTATE["repo"]["layer"], ESTATE["repo"]["band"]) == ("research", 3, "EXPLORE")
    assert (ESTATE["repo"]["stage"], ESTATE["origin"]["decided_by"]) == ("candidate", "proposed")


def test_governance_is_a_pinned_dependency_not_a_vendored_copy():
    governance = DEPS["estate-governance"]
    assert re.fullmatch(r"[0-9a-f]{40}", governance["rev"])
    assert re.fullmatch(r"sha256:[0-9a-f]{64}", governance["pin"])
    assert not (ROOT / "tools" / "audit_estate_layout.py").exists()


def test_vendored_kernels_are_a_declared_dependency():
    assert re.fullmatch(r"sha256:[0-9a-f]{64}", DEPS["finite-math-kernels"]["pin"])


def test_only_mojo_has_acceptance_authority():
    accepted = [x["name"] for x in ESTATE["language"] if x["acceptance_authority"]]
    assert accepted == ["Mojo"]


def test_template_forbids_empty_silos_and_mass_move():
    assert ESTATE["principles"]["empty_silos"] == "forbidden"
    assert ESTATE["migration"]["mass_move"] is False
