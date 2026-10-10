"""Oracle constants shared with kernel/tests/test_integer_vector.mojo.

The canonical kernel is `kernel/finite_linear_algebra/integer_vector.mojo` (vendored); this is the independent
cross-check. Both derive the same two checksums over the same 348 distinct
incidence matrices of the alphabet-3 PIP corpus, by different implementations in
different languages, so a divergence in either shows up as a number rather than
as a silence.

The two sides are not identical in contract, and that asymmetry is asserted
here too: Python's `int` is arbitrary precision, so the oracle returns an exact
answer where the 64-bit kernel raises. The kernel is exact or absent; the
oracle is the reference for what "exact" was.
"""

import pytest

from psc_research import bpa
from psc_research.fixed_vector import add, matvec, sub
from psc_research.pip_screen import pip_corpus

SEED = (1, 2, 3)
DISTINCT_INCIDENCES = 348
MATVEC_CHECKSUM = 4728
ADDSUB_CHECKSUM = 1576


def distinct_incidences():
    seen, out = set(), []
    for sigma in pip_corpus():
        n = bpa.alphabet_size(sigma)
        m = tuple(tuple(sigma[c + 1].count(r + 1) for c in range(n)) for r in range(n))
        if m in seen:
            continue
        seen.add(m)
        out.append(m)
    return out


def test_corpus_checksums_match_the_mojo_kernel():
    mats = distinct_incidences()
    assert len(mats) == DISTINCT_INCIDENCES
    assert sum(sum(matvec(m, SEED)) for m in mats) == MATVEC_CHECKSUM
    assert sum(sum(add(m[0], m[1])) + sum(sub(m[2], m[0])) for m in mats) == ADDSUB_CHECKSUM


def test_a_dimension_that_does_not_agree_is_refused():
    with pytest.raises(ValueError):
        add((1, 2, 3), (1, 2))
    with pytest.raises(ValueError):
        sub((1, 2), (1, 2, 3))
    with pytest.raises(ValueError):
        matvec(((1, 0, 0), (0, 1, 0), (0, 0, 1)), (1, 2))
    with pytest.raises(ValueError):
        matvec((), (1, 2, 3))


def test_the_oracle_is_arbitrary_precision_where_the_kernel_refuses():
    """The one documented difference between the two implementations.

    `kernel/tests/test_integer_vector.mojo` pins each of these as a refusal; here
    they have exact values. Neither side wraps, which is the property that
    matters: the kernel declines to answer rather than answering wrongly.
    """
    machine_max = 2**63 - 1
    assert add((machine_max, 0, 0), (1, 0, 0)) == (2**63, 0, 0)
    assert sub((-(2**63), 0, 0), (1, 0, 0)) == (-(2**63) - 1, 0, 0)
    half = machine_max // 2
    assert matvec(((half, half, half), (0, 0, 0), (0, 0, 0)), (1, 1, 1)) == (
        3 * half,
        0,
        0,
    )
