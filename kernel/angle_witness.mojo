# angle_witness.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
# Statements and what is imported: docs/angle-types-and-landing.md.
#
# This repository's use of the vendored angle package: the doubling orbits of
# the angles Phase 3 names, and the counting identity that ties the angle side
# to the point side of section 2.
#
# This is the Mojo side of a differential pair; reference/angle.py is the Python
# side.

from angle_doubling.angle import Angle, angle_smoke, has_type, orbit_term, period, preperiod, type_count


def angle_witness_smoke() -> Bool:
    """The package's own laws, then the counting identity of section 2."""
    if not angle_smoke():
        return False
    # The angles of the corpus parameters' types. 1/3 and 2/3 are the
    # period-two angles; 1/6 and 5/6 are their preperiod-one preimages.
    var third = Angle.of(1, 3)
    var sixth = Angle.of(1, 6)
    if not (has_type(third, 0, 2) and has_type(sixth, 1, 2)):
        return False
    if has_type(sixth, 0, 2):
        return False
    if not orbit_term(sixth, 1).eq(third):
        return False
    # Section 2: `2^l (2^k - 1) + 2^l = 2^(l+k)`. At `c = 0` the second term
    # is the multiplicity of the critical point, so the angle count is
    # exactly the number of the remaining roots.
    for l in range(0, 5):
        for k in range(1, 5):
            var counted = type_count(l, k)
            if counted < 0:
                return False
            if counted + (Int64(1) << Int64(l)) != (Int64(1) << Int64(l + k)):
                return False
    # A dyadic angle is preperiodic to the fixed angle zero, which is where
    # the critical point's own rays go.
    var dyadic = Angle.of(3, 8)
    if not (preperiod(dyadic) == 3 and period(dyadic) == 1):
        return False
    return orbit_term(dyadic, 3).is_zero()
