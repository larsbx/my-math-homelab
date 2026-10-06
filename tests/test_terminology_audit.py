"""The terminology audit, against the usages it is there to catch.

`docs/terminology-registry.md` forbids calling the quadrance-1 locus a circle.
That rule was written down and unenforced, and the phrase reached
`docs/enclosure-width-lemma.md` and survived every gate. These cases pin both
directions: the breach is caught, and each of the four exemptions is honoured
so that correct prose is not blocked. The engine is the vendored
`lexical_audit`; these cases pin this repository's policy over it.
"""

from __future__ import annotations

import pytest

from audit_terminology import REGISTRY, REQUIRED_CLAUSE, ROOT, SELF, field_terms, main, policy, rejected_claims
from lexical_audit import audit


@pytest.fixture(scope="module")
def rules():
    return policy().rules


def findings(rules, text: str, name: str = "docs/note.md") -> list[str]:
    clause = rules[0]
    return [] if clause.scope.excluded(name) else [hit.match for hit in clause.hits(name, text)]


def rejection_findings(rules, text: str, name: str = "docs/note.md") -> list[str]:
    rejected = rules[1]
    return [] if rejected.scope.excluded(name) else [hit.term for hit in rejected.hits(name, text)]


def test_the_repository_passes():
    assert main() == 0


def test_the_registry_names_the_rule_and_its_enforcement():
    text = (ROOT / REGISTRY).read_text(encoding="utf-8")
    assert REQUIRED_CLAUSE in text
    assert SELF in text


@pytest.mark.parametrize("breach", [
    "A box straddling the unit circle at `c = 0`.",
    "Each point leaves the disc of radius `R`.",
    "The locus carries an arc of positive circumference.",
    "Read off the polar angle of the record.",
])
def test_a_breach_is_caught(rules, breach):
    assert findings(rules, breach)


def test_a_denial_is_not_a_breach(rules):
    assert not findings(rules, "It is not a circle at rank 2, and no arc, angle, or circumference is available from it.")


def test_a_denial_only_covers_what_follows_it(rules):
    """Both ways a looser rule let the escaped phrase through: a denial
    further along the sentence, and a denial after the term."""
    assert findings(rules, "Each leaves the disc of radius `R`, and by the criterion it never returns.")
    assert findings(rules, "For `lam` on the unit circle and not a root of unity.")


def test_a_registered_field_term_is_allowed(rules):
    assert not findings(rules, "The boundary of the Siegel disk contains no critical point here.")
    assert not findings(rules, "The ideal line contains the circular points `I` and `J`.")


def test_a_forbidding_heading_exempts_its_section(rules):
    assert not findings(rules, "## Forbidden usages\n\n- calling the locus a circle;\n")
    assert findings(rules, "## Usages\n\n- calling the locus a circle;\n")


def test_a_heading_is_prose_too(rules):
    assert findings(rules, "## The unit circle\n")


def test_an_explicit_marker_exempts_its_paragraph(rules):
    marked = "<!-- terminology-exempt: a classical device -->\nEvery circle passes through them.\n"
    assert not findings(rules, marked)
    assert findings(rules, marked + "\nEvery circle passes through them.\n"), (
        "the marker must exempt one paragraph, not the rest of the file"
    )


def test_a_literature_gate_may_quote_the_classical_statement(rules):
    quoted = "For `lam` on the unit circle and not a root of unity.\n"
    assert not findings(rules, quoted, name="docs/literature-gate-2026-09-19.md")
    assert findings(rules, quoted)


def test_comments_in_the_executable_core_are_scanned(rules):
    assert findings(rules, "# The unit circle is the boundary here.\n", name="tools/note.py")


def test_the_bare_word_angle_is_not_scanned(rules):
    """Route A language the programme needs: rational angles in `Q/Z`."""
    assert not findings(rules, "Angle combinatorics on `Q/Z` under `t -> 2t`.")


# --- rejected claims -------------------------------------------------------


def test_the_registry_names_at_least_one_rejected_claim():
    """The section exists because a claim was judged false, not because the
    format asked for it."""
    assert "CutCatalogueRayEquivalence" in rejected_claims((ROOT / REGISTRY).read_text(encoding="utf-8"))


def test_a_rejected_claim_cited_as_open_is_caught(rules):
    assert rejection_findings(rules, "This rests on CutCatalogueRayEquivalence, which is not yet gated.\n")


def test_a_rejected_claim_cited_as_rejected_passes(rules):
    assert not rejection_findings(rules, "CutCatalogueRayEquivalence is rejected; see the gate.\n")
    assert not rejection_findings(rules, "The gate rejects it. " + "x" * 200 + " CutCatalogueRayEquivalence\n")


def test_the_rejection_word_has_to_be_within_reach(rules):
    far = "It is rejected. " + "x" * 400 + " CutCatalogueRayEquivalence is the bridge.\n"
    assert rejection_findings(rules, far)


def test_the_gate_that_judged_it_may_state_it_plainly(rules):
    text = "the cut catalogue separates exactly what a ray-pair catalogue separates [CutCatalogueRayEquivalence]\n"
    assert not rejection_findings(rules, text, name="docs/literature-gate-2026-09-20-cut-equivalence.md")
    assert rejection_findings(rules, text)


def test_ford_circles_is_a_registered_field_term():
    assert "Ford circles" in field_terms((ROOT / REGISTRY).read_text(encoding="utf-8"))


@pytest.mark.parametrize("prose", [
    "The bulb radii follow the Ford circles law `q^-2`.",
    "See `larsbx/mandelbrot-bulbs-and-ford-circles-research`.",
])
def test_ford_circles_passes_in_prose_and_repository_slugs(rules, prose):
    assert not findings(rules, prose)


def test_a_registered_term_does_not_excuse_the_bare_word(rules):
    assert findings(rules, "The Ford circles meet a unit circle.")


# --- the planted tree --------------------------------------------------------


def test_a_planted_violation_fails_the_audit(tmp_path):
    """The policy over a copy of the registry and one planted note, end to end."""
    (tmp_path / "docs").mkdir()
    (tmp_path / REGISTRY).write_text((ROOT / REGISTRY).read_text(encoding="utf-8"), encoding="utf-8")
    (tmp_path / "docs" / "note.md").write_text(
        "The quadrance-1 locus is a circle.\n\nIt rests on CutCatalogueRayEquivalence.\n", encoding="utf-8")
    assert audit(tmp_path, policy(tmp_path)) == [
        "docs/note.md:1: 'circle' is not available at rank 2; register it, deny it, "
        "or mark the paragraph with <!-- terminology-exempt: reason -->",
        "docs/note.md: 'CutCatalogueRayEquivalence' is a rejected claim and must be cited as one; "
        "see the registry's rejected-claims section",
    ]
    (tmp_path / REGISTRY).write_text("# Terminology Registry\n", encoding="utf-8")
    assert audit(tmp_path, policy(tmp_path))[0] == f"{REGISTRY}: missing '## Established field terms'"
