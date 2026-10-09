"""The oracle corpus is a declared object, and the declaration can fail.

Round-three item R9 for this repository. The finite-domain claims are asserted
for `pip_corpus()` and no other domain, so what that corpus contains is part of
every one of them; `tools/corpus_refinement.py` says what it contains and the
run refuses when it stops being true.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "reference"))

import corpus_refinement as cr  # noqa: E402
from psc_research.pip_screen import pip_corpus  # noqa: E402

CORPUS = pip_corpus()


def test_the_corpus_meets_its_declaration():
    assert cr.problems(CORPUS) == ()
    assert cr.main(["corpus_refinement.py", "--check"]) == 0


def test_the_size_the_finite_domain_claims_name_is_the_size_that_is_checked():
    """`claim_governance.toml` asserts its finite-domain claims for 4,554
    members. The number is not a remark in a document here."""
    assert len(CORPUS) == cr.SIZE == 4554
    shrunk = cr.problems(CORPUS[:-1])
    assert any("has 4553 members, and the finite-domain claims are asserted for 4554" in p for p in shrunk)


def test_a_member_outside_the_declared_shape_is_refused():
    """Swapped in rather than appended, so the size finding does not mask it."""
    intruder = {1: (1,), 2: (2,), 3: (1, 2, 3, 1)}       # an image past the length bound
    found = cr.problems([*CORPUS[:-1], intruder])
    assert any("outside its codomain" in p for p in found), found


def test_the_corpus_contains_no_constant_length_substitution():
    """Declared missed, and this is why: a constant image length L makes L a
    rational eigenvalue, so the irreducibility screen rejects every one. The
    domain is described as "lengths at most three" and the corner (3,3,3) is
    not in it."""
    assert not any(len({len(image) for image in sigma.values()}) == 1 for sigma in CORPUS)
    assert max(sum(len(i) for i in sigma.values()) for sigma in CORPUS) == cr.WIDEST == 8


def test_a_constant_length_member_would_make_the_declaration_stale():
    """The other direction: if the screen ever admitted one, the declaration
    fails rather than silently continuing to claim the gap."""
    constant = {1: (1, 2, 3), 2: (2, 3, 1), 3: (3, 1, 2)}
    assert cr.PIP.holds(constant)
    found = cr.problems([*CORPUS[:-1], constant])
    assert any("misses 'a constant image length'" in p for p in found)


def test_the_digest_says_which_corpus_and_not_only_what_it_is_like():
    """The finding this answers: a member swapped for a duplicate of another
    leaves the count, the shape and every named class intact, so a shape check
    alone lets a screening regression through in silence."""
    swapped = [*CORPUS[:-1], CORPUS[0]]
    assert len(swapped) == cr.SIZE
    assert cr.PIP.audit(swapped) == ()                      # shape and classes survive
    found = cr.problems(swapped)
    assert any("hashes to" in p for p in found), found
    assert any("repeats 1 member" in p for p in found), found


def test_a_reordering_is_a_different_corpus():
    """`pip_corpus` enumerates, so order is part of what the claims rest on."""
    reversed_corpus = list(reversed(CORPUS))
    assert cr.PIP.audit(reversed_corpus) == () and len(reversed_corpus) == cr.SIZE
    assert any("hashes to" in p for p in cr.problems(reversed_corpus))


def test_the_pinned_digest_is_the_digest_of_the_committed_corpus():
    assert cr.digest(CORPUS) == cr.DIGEST
    assert cr.preimage(CORPUS).count(b"\n") == cr.SIZE - 1
    assert cr.encode(CORPUS[0]) == "1:2 2:3 3:12"


def test_every_declared_gap_states_why_it_is_out_of_reach():
    for cls in cr.PIP.classes:
        if not cls.required:
            assert len(cls.reason) > 60, cls.name


def test_the_command_line_refuses_an_unknown_argument():
    with pytest.raises(SystemExit):
        cr.main(["corpus_refinement.py", "--everything"])
