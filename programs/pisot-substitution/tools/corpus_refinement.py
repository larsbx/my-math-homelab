#!/usr/bin/env python3
"""The input distribution of this repository's oracle layer, declared.

Round-three item R9: `larsbx/meta_test` requires a generator to declare a
codomain refinement, `phi_G`, as an object a run can refuse rather than an
accident of how the test was written. The facility is
`tools/oracle_refinement`, vendored from `larsbx/finite-math-kernels` and
specified in its `docs/generator-refinement-spec.md`.

This repository's differential oracles -- `oracles/python/overlap_depth_census_oracle.py`
and the census scripts beside it -- do not sample. They run over
`psc_research.pip_screen.pip_corpus()`, every PIP substitution on three letters
with image lengths at most three. That is the strongest distribution there is,
and declaring it is not therefore pointless: the finite-domain claims in
`claim_governance.toml` are asserted *for that domain and no other*, so what the
domain contains is part of every one of them. A sentence in a document saying
"the exact 4,554-member short-image corpus" is a number; this is the number, the
shape behind it, and a run that refuses when either moves.

The declaration says what the corpus is *like*. `DIGEST` says *which* corpus it
is, because the two are different guarantees: swap one member for a duplicate
of another and the count, the shape and every named class survive untouched
while the finite domain has quietly changed. The size and the classes catch a
screen that admits or rejects the wrong kind of substitution; the digest catches
a screen that admits or rejects the wrong ones.

Writing the declaration found something the name hides. The domain is described
as "image lengths at most three", and the corpus contains **no constant-length
substitution at all**: not one of `(1,1,1)`, `(2,2,2)` or `(3,3,3)`. A constant
image length `L` makes every column sum of the incidence matrix `L`, so `L` is a
rational eigenvalue and the characteristic polynomial is reducible; the
irreducibility screen rejects all 19,683 candidates of shape `(3,3,3)` before
the Pisot test is ever reached. That is why the widest total image length in the
corpus is eight rather than nine. A reader taking "lengths at most three" at
face value would assume the corner is in there. It is declared missed here, with
the reason, so the next reader does not have to rediscover it.

Usage:
    corpus_refinement.py            report phi_G
    corpus_refinement.py --check    exit 1 if the corpus departs from it
"""

from __future__ import annotations

import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "reference"))

from oracle_refinement import Class, Refinement  # noqa: E402
from psc_research.pip_screen import pip_corpus  # noqa: E402

LETTERS = (1, 2, 3)
MAX_IMAGE = 3
SIZE = 4554
WIDEST = 8
#: SHA-256 of `preimage()`: the ordered corpus, member by member, canonically
#: encoded. The size and the declared classes say what the corpus is like; this
#: says which corpus it is. Swapping one member for a duplicate of another
#: leaves the count and every class intact and changes the domain, so a shape
#: check alone would let a screening regression through in silence.
DIGEST = "ba36a99940d08b8c5f3b077aa382c543eb572604b6c0081eab872b5f7fd46308"


def _images(sigma: dict) -> tuple[tuple[int, ...], ...]:
    return tuple(tuple(sigma[letter]) for letter in LETTERS)


def _lengths(sigma: dict) -> tuple[int, ...]:
    return tuple(len(image) for image in _images(sigma))


PIP = Refinement(
    "pip_corpus",
    f"a substitution on {{{', '.join(map(str, LETTERS))}}} with every image of length 1 to {MAX_IMAGE}",
    lambda s: (isinstance(s, dict) and tuple(sorted(s)) == LETTERS
               and all(1 <= len(i) <= MAX_IMAGE and set(i) <= set(LETTERS) for i in _images(s))),
    (
        Class("an image of length one", lambda s: 1 in _lengths(s)),
        Class("an image at the length bound", lambda s: MAX_IMAGE in _lengths(s)),
        Class("three distinct image lengths", lambda s: len(set(_lengths(s))) == len(LETTERS)),
        Class("the widest total image length", lambda s: sum(_lengths(s)) == WIDEST),
        Class("a letter that occurs once in the whole image", lambda s: any(
            sum(image.count(letter) for image in _images(s)) == 1 for letter in LETTERS)),
        Class("a constant image length", lambda s: len(set(_lengths(s))) == 1,
              reason=f"a constant length L makes every column sum of the incidence matrix L, so L "
                     f"is a rational eigenvalue and the characteristic polynomial is reducible; "
                     f"the irreducibility screen rejects every candidate of shape (3,3,3) -- all "
                     f"19683 of them -- and likewise (1,1,1) and (2,2,2), which is why the widest "
                     f"total image length here is {WIDEST} and not {len(LETTERS) * MAX_IMAGE}"),
        Class("a letter absent from every image", lambda s: any(
            all(letter not in image for image in _images(s)) for letter in LETTERS),
              reason="a primitive matrix has a positive power with no zero entry, so no letter "
                     "can be missing from the images of a primitive substitution; the screen "
                     "rejects it before the corpus, and the claims never meet one"),
    ),
)


def encode(sigma: dict) -> str:
    """One member as canonical text: the images in letter order, nothing else."""
    return " ".join(f"{letter}:{''.join(map(str, sigma[letter]))}" for letter in LETTERS)


def preimage(corpus: list[dict]) -> bytes:
    """The ordered corpus as bytes, one member per line. Order is part of the
    identity: `pip_corpus` enumerates, so a reordering is a different program."""
    return "\n".join(encode(sigma) for sigma in corpus).encode("utf-8")


def digest(corpus: list[dict]) -> str:
    return hashlib.sha256(preimage(corpus)).hexdigest()


def problems(corpus: list[dict] | None = None) -> tuple[str, ...]:
    """Every way the corpus departs from the declaration: its identity first,
    then its size, then the shape and the classes."""
    corpus = pip_corpus() if corpus is None else corpus
    found = list(PIP.audit(corpus))
    duplicates = len(corpus) - len({encode(sigma) for sigma in corpus})
    if duplicates:
        found.insert(0, f"pip_corpus repeats {duplicates} member(s); an enumeration that "
                        f"repeats itself is smaller than it counts")
    if len(corpus) != SIZE:
        found.insert(0, f"pip_corpus has {len(corpus)} members, and the finite-domain claims "
                        f"are asserted for {SIZE}")
    found_digest = digest(corpus)
    if DIGEST and found_digest != DIGEST:
        found.insert(0, f"pip_corpus hashes to {found_digest}, and the finite-domain claims "
                        f"are asserted for {DIGEST}")
    return tuple(found)


def main(argv: list[str]) -> int:
    if argv[1:] not in ([], ["--check"]):
        raise SystemExit(__doc__)
    found = problems()
    if found:
        print("The oracle corpus no longer matches its declared refinement:\n")
        print("\n".join(f"  {p}" for p in found))
        return 1
    corpus = pip_corpus()
    print(f"OK: pip_corpus has {len(corpus)} members, each {PIP.codomain}.")
    print(f"    sha256 {digest(corpus)}")
    print(f"    reaches {', '.join(PIP.reached())}")
    for cls in PIP.classes:
        if not cls.required:
            print(f"    misses {cls.name}: {cls.reason}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
