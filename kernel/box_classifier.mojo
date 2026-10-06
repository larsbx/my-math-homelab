# box_classifier.mojo
#
# Specification: docs/rational-interval-arithmetic-spec.md.
# Certificates and their soundness: docs/three-valued-classifier.md.
#
# The three-valued classifier over boxes:
#
#     G(box) -> OUT | IN | UNKNOWN
#
# OUT is the vendored escape test (`quadratic_orbit.escape_criterion`)
# applied to a whole box, IN is a trap the orbit of the box falls into, and
# UNKNOWN is the residual, which is reported rather than shrunk. A trap is supplied and verified here, never searched
# for: an unverified trap is ignored, so a wrong witness costs an UNKNOWN and
# never an IN.
#
# This is the Mojo side of a differential pair; reference/box_classifier.py is the
# Python side.

from finite_exact.closed_interval import ComplexIQ, complex_box as box
from finite_exact.rat_q import Q
from quadratic_orbit.escape_criterion import escapes
from quadratic_orbit.orbit import quadratic_step

alias BOX_OUT = 0
alias BOX_IN = 1
alias BOX_UNKNOWN = 2


def is_trap(trap: ComplexIQ, c: ComplexIQ, period: Int) -> Bool:
    """Does `f_c^period` map the trap into itself?

    Inclusion is the whole certificate, and it is not strict. A box with this
    property is forward invariant under the iterate, so an orbit entering it
    stays in the union of its first `period` images, which is bounded. That
    argument never used strictness, and requiring it cost the parabolic case,
    whose petal touches the parabolic fixed point and so is invariant without
    being strictly invariant.
    """
    if period < 1 or not (trap.accepted() and c.accepted()):
        return False
    var image = trap.copy()
    for _ in range(period):
        image = quadratic_step(image, c)
    var inside = image.subset_of(trap)
    return inside.value and not inside.rejected


struct BoxOutcome(Copyable, Movable):
    """The verdict and the iterate index that produced it."""

    var kind: Int
    var steps: Int

    def __init__(out self, kind: Int, steps: Int):
        self.kind = kind
        self.steps = steps

    def decided(self) -> Bool:
        return self.kind != BOX_UNKNOWN


def classify(box: ComplexIQ, c: ComplexIQ, trap: ComplexIQ, has_trap: Bool, period: Int, horizon: Int) -> BoxOutcome:
    """Iterate the box until a certificate fires, or the horizon runs out."""
    if horizon < 1 or not (box.accepted() and c.accepted()):
        return BoxOutcome(BOX_UNKNOWN, -1)
    var trap_verified = has_trap and is_trap(trap, c, period)
    var image = box.copy()
    for n in range(horizon + 1):
        if escapes(image, c):
            return BoxOutcome(BOX_OUT, n)
        if trap_verified:
            var inside = image.subset_of(trap)
            if inside.value and not inside.rejected:
                return BoxOutcome(BOX_IN, n)
        image = quadratic_step(image, c)
        if not image.accepted():
            return BoxOutcome(BOX_UNKNOWN, n)
    return BoxOutcome(BOX_UNKNOWN, horizon)


def box_classifier_smoke() -> Bool:
    """The pinned traps, the three verdicts, and the refusal to trust a witness."""
    var c_zero = ComplexIQ.singleton(Q.zero(), Q.zero())
    var c_basilica = ComplexIQ.singleton(Q(-1, 1), Q.zero())
    var trap_zero = box(-1, 1, -1, 1, 4)
    var trap_basilica = box(-1, 1, -1, 1, 8)
    if not is_trap(trap_zero, c_zero, 1):
        return False
    if not is_trap(trap_basilica, c_basilica, 2):
        return False
    # A box the map leaves is not a trap, however little it leaves by.
    if is_trap(box(-1, 1, -1, 1, 1), c_zero, 1):
        return False
    # The parabolic petal at c = 1/4: invariant, and not strictly invariant.
    var c_cauliflower = ComplexIQ.singleton(Q(1, 4), Q.zero())
    var petal = box(1, 2, -1, 1, 4)
    if not is_trap(petal, c_cauliflower, 1):
        return False
    if quadratic_step(petal, c_cauliflower).strict_subset_of(petal).value:
        return False
    if is_trap(trap_zero, c_zero, 0):
        return False
    if classify(box(-1, 1, -1, 1, 8), c_zero, trap_zero, True, 1, 12).kind != BOX_IN:
        return False
    if classify(box(3, 4, 3, 4, 1), c_zero, trap_zero, True, 1, 12).kind != BOX_OUT:
        return False
    if classify(box(15, 17, 0, 1, 16), c_zero, trap_zero, True, 1, 12).kind != BOX_UNKNOWN:
        return False
    # An unverified trap is ignored rather than believed.
    var fake = box(-1, 1, -1, 1, 1)
    if classify(box(-1, 1, -1, 1, 16), c_zero, fake, True, 1, 12).kind == BOX_IN:
        return False
    return not classify(box(3, 4, 3, 4, 1), c_zero, trap_zero, True, 1, 0).decided()
