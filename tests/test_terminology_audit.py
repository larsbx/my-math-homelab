"""The terminology audit, against the usages it is there to catch.

`docs/terminology-registry.md` forbids calling the quadrance-1 locus a circle.
That rule was written down and unenforced, and the phrase reached
`docs/enclosure-width-lemma.md` and survived every gate. These cases pin both
directions: the breach is caught, and each of the four exemptions is honoured
so that correct prose is not blocked.
"""

from __future__ import annotations

import pytest

from audit_terminology import (
    REGISTRY,
    REQUIRED_CLAUSE,
    SELF,
    audit_file,
    audit_rejected,
    field_terms,
    main,
    rejected_claims,
)


@pytest.fixture(scope="module")
def terms() -> list[str]:
    return field_terms()


def findings(tmp_path, text: str, terms: list[str], name: str = "note.md") -> list[str]:
    path = tmp_path / name
    path.write_text(text, encoding="utf-8")
    errors: list[str] = []
    audit_file(path, terms, errors)
    return errors


def test_the_repository_passes():
    assert main() == 0


def test_the_registry_names_the_rule_and_its_enforcement():
    text = REGISTRY.read_text(encoding="utf-8")
    assert REQUIRED_CLAUSE in text
    assert SELF in text


@pytest.mark.parametrize("breach", [
    "A box straddling the unit circle at `c = 0`.",
    "Each point leaves the disc of radius `R`.",
    "The locus carries an arc of positive circumference.",
    "Read off the polar angle of the record.",
])
def test_a_breach_is_caught(tmp_path, terms, breach):
    assert findings(tmp_path, breach, terms)


def test_a_denial_is_not_a_breach(tmp_path, terms):
    assert not findings(tmp_path, "It is not a circle at rank 2, and no arc, angle, or circumference is available from it.", terms)


def test_a_denial_only_covers_what_follows_it(tmp_path, terms):
    """Both ways a looser rule let the escaped phrase through: a denial
    further along the sentence, and a denial after the term."""
    assert findings(tmp_path, "Each leaves the disc of radius `R`, and by the criterion it never returns.", terms)
    assert findings(tmp_path, "For `lam` on the unit circle and not a root of unity.", terms)


def test_a_registered_field_term_is_allowed(tmp_path, terms):
    assert not findings(tmp_path, "The boundary of the Siegel disk contains no critical point here.", terms)
    assert not findings(tmp_path, "The ideal line contains the circular points `I` and `J`.", terms)


def test_a_forbidding_heading_exempts_its_section(tmp_path, terms):
    assert not findings(tmp_path, "## Forbidden usages\n\n- calling the locus a circle;\n", terms)
    assert findings(tmp_path, "## Usages\n\n- calling the locus a circle;\n", terms)


def test_an_explicit_marker_exempts_its_paragraph(tmp_path, terms):
    marked = "<!-- terminology-exempt: a classical device -->\nEvery circle passes through them.\n"
    assert not findings(tmp_path, marked, terms)
    assert findings(tmp_path, marked + "\nEvery circle passes through them.\n", terms), (
        "the marker must exempt one paragraph, not the rest of the file"
    )


def test_a_literature_gate_may_quote_the_classical_statement(tmp_path, terms):
    quoted = "For `lam` on the unit circle and not a root of unity.\n"
    assert not findings(tmp_path, quoted, terms, name="literature-gate-2026-09-19.md")
    assert findings(tmp_path, quoted, terms)


def test_comments_in_the_executable_core_are_scanned(tmp_path, terms):
    assert findings(tmp_path, "# The unit circle is the boundary here.\n", terms, name="note.py")


def test_the_bare_word_angle_is_not_scanned(tmp_path, terms):
    """Route A language the programme needs: rational angles in `Q/Z`."""
    assert not findings(tmp_path, "Angle combinatorics on `Q/Z` under `t -> 2t`.", terms)


# --- rejected claims -------------------------------------------------------


@pytest.fixture(scope="module")
def claims() -> list[str]:
    return rejected_claims()


def test_the_registry_names_at_least_one_rejected_claim(claims):
    """The section exists because a claim was judged false, not because the
    format asked for it."""
    assert "CutCatalogueRayEquivalence" in claims


def rejection_findings(tmp_path, text: str, claims: list[str], name: str = "note.md") -> list[str]:
    path = tmp_path / name
    path.write_text(text, encoding="utf-8")
    errors: list[str] = []
    audit_rejected(path, claims, errors)
    return errors


def test_a_rejected_claim_cited_as_open_is_caught(tmp_path, claims):
    assert rejection_findings(tmp_path, "This rests on CutCatalogueRayEquivalence, which is not yet gated.\n", claims)


def test_a_rejected_claim_cited_as_rejected_passes(tmp_path, claims):
    assert not rejection_findings(tmp_path, "CutCatalogueRayEquivalence is rejected; see the gate.\n", claims)
    assert not rejection_findings(tmp_path, "The gate rejects it. " + "x" * 200 + " CutCatalogueRayEquivalence\n", claims)


def test_the_rejection_word_has_to_be_within_reach(tmp_path, claims):
    far = "It is rejected. " + "x" * 400 + " CutCatalogueRayEquivalence is the bridge.\n"
    assert rejection_findings(tmp_path, far, claims)


def test_the_gate_that_judged_it_may_state_it_plainly(tmp_path, claims):
    text = "the cut catalogue separates exactly what a ray-pair catalogue separates [CutCatalogueRayEquivalence]\n"
    assert not rejection_findings(tmp_path, text, claims, name="literature-gate-2026-09-20-cut-equivalence.md")
    assert rejection_findings(tmp_path, text, claims)


def test_ford_circles_is_a_registered_field_term(terms):
    assert "Ford circles" in terms


@pytest.mark.parametrize("prose", [
    "The bulb radii follow the Ford circles law `q^-2`.",
    "See `larsbx/mandelbrot-bulbs-and-ford-circles-research`.",
])
def test_ford_circles_passes_in_prose_and_repository_slugs(tmp_path, terms, prose):
    assert not findings(tmp_path, prose, terms)


def test_a_registered_term_does_not_excuse_the_bare_word(tmp_path, terms):
    assert findings(tmp_path, "The Ford circles meet a unit circle.", terms)
