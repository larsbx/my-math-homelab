# preperiodic_witness.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
# Statements and what is imported: docs/preperiodic-certificates.md.
#
# This repository's preperiodic witnesses, replayed against the vendored
# kernel. The certificates themselves are `quadratic_orbit/preperiodic.mojo`;
# nothing is reimplemented here. What is here is the corpus: the boxes of
# `reference/parameter_corpus.py`, the types they are claimed at, and the checks
# that each one isolates a root of exactly that type.
#
# This is the Mojo side of a differential pair; reference/preperiodic.py is the
# Python side.

from finite_exact.closed_interval import ComplexIQ, complex_box as box
from finite_exact.rat_q import Q
from quadratic_orbit.preperiodic import excludes_preperiodic_point, isolates_preperiodic_point


def has_exact_type(z: ComplexIQ, c: ComplexIQ, preperiod: Int, period: Int) -> Bool:
    """Isolated at this type, and every strictly smaller type excluded.

    A root of `R_{l,k}` is also a root of `R_{l',k'}` whenever `l' >= l` and
    `k` divides `k'`, so isolation alone names an upper bound on the type. The
    exclusions are what make it exact.
    """
    if not isolates_preperiodic_point(z, c, preperiod, period):
        return False
    for l in range(preperiod + 1):
        for k in range(1, period + 1):
            if l == preperiod and k == period:
                continue
            if period % k != 0:
                continue
            var excluded = excludes_preperiodic_point(z, c, l, k)
            if not (excluded.value and not excluded.rejected):
                return False
    return True


def preperiodic_witness_smoke() -> Bool:
    """Every witness of `reference/parameter_corpus.py`, at its declared type."""
    var c_zero = ComplexIQ.singleton(Q.zero(), Q.zero())
    var c_basilica = ComplexIQ.singleton(Q(-1, 1), Q.zero())
    var c_dendrite = ComplexIQ.singleton(Q.zero(), Q(1, 1))
    # c = 0: the fixed point 1, and -1 which lands on it.
    if not has_exact_type(box(7, 9, -1, 1, 8), c_zero, 0, 1):
        return False
    if not has_exact_type(box(-17, -15, -1, 1, 16), c_zero, 1, 1):
        return False
    # c = -1: the critical point on the 2-cycle, and the irrational fixed point.
    if not has_exact_type(box(-1, 1, -1, 1, 16), c_basilica, 0, 2):
        return False
    if not has_exact_type(box(25, 27, -1, 1, 16), c_basilica, 0, 1):
        return False
    # c = i: the 2-cycle the critical orbit falls into.
    if not has_exact_type(box(-1, 1, -17, -15, 16), c_dendrite, 0, 2):
        return False
    if not has_exact_type(box(-33, -31, 31, 33, 32), c_dendrite, 0, 2):
        return False
    # The critical point is a root of `R_{l,k}` whenever it is preperiodic,
    # and for `l >= 1` it is never an isolable one: the chain rule puts the
    # factor `2 f^0(0) = 0` in both products, so `R'(0) = 0`. At `c = i` the
    # critical point has type (2, 2) and the certificate declines it.
    return not isolates_preperiodic_point(box(-1, 1, -1, 1, 16), c_dendrite, 2, 2)
