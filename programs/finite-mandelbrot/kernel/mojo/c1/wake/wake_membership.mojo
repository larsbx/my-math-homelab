# C1 wake membership scaffold.
#
# This module is proof-facing scaffolding for WakeMembershipSoundness.
# It uses only finite rational address data and side labels. It does not
# compute analytic geometry, landing curves, pixels, or generic boundary facts.

struct WakeRayAddr:
    var num: Int
    var den: Int

    fn __init__(inout self, num: Int, den: Int):
        self.num = num
        self.den = den

    fn shape_valid(self) -> Bool:
        return self.den > 0 and self.num >= 0 and self.num < self.den


fn same_addr(a: WakeRayAddr, b: WakeRayAddr) -> Bool:
    # Cross-multiply. Normalization is handled by the witness contract/tests.
    return a.num * b.den == b.num * a.den


fn residue_on_common_den(x: WakeRayAddr, common_den: Int) -> Int:
    return x.num * (common_den // x.den)


fn common_den_pair(a: WakeRayAddr, b: WakeRayAddr) -> Int:
    # Scaffold: product denominator is always valid as a common denominator.
    # Later proof-grade version can replace this with lcm.
    return a.den * b.den


fn common_den_triple(a: WakeRayAddr, b: WakeRayAddr, c: WakeRayAddr) -> Int:
    return a.den * b.den * c.den


fn strictly_between_linear(left: Int, probe: Int, right: Int) -> Bool:
    return left < probe and probe < right


fn strictly_between_cyclic(a: WakeRayAddr, probe: WakeRayAddr, b: WakeRayAddr) -> Bool:
    # Checks whether probe lies strictly in the positively oriented cyclic
    # interval from a to b on Q/Z. Boundary equality is rejected elsewhere.
    if not a.shape_valid() or not probe.shape_valid() or not b.shape_valid():
        return False
    if same_addr(a, probe) or same_addr(b, probe):
        return False

    let d = common_den_triple(a, probe, b)
    let aa = residue_on_common_den(a, d)
    let pp = residue_on_common_den(probe, d)
    let bb = residue_on_common_den(b, d)

    if aa < bb:
        return strictly_between_linear(aa, pp, bb)

    # Wrapped interval: (a, 1) union (0, b).
    return pp > aa or pp < bb


struct WakeSeparatorLite:
    var left: WakeRayAddr
    var right: WakeRayAddr
    var admissible: Bool

    fn __init__(inout self, left: WakeRayAddr, right: WakeRayAddr, admissible: Bool):
        self.left = left
        self.right = right
        self.admissible = admissible

    fn valid(self) -> Bool:
        return self.admissible and self.left.shape_valid() and self.right.shape_valid() and not same_addr(self.left, self.right)


struct WakeMembershipWitness:
    var object_id: String
    var separator: WakeSeparatorLite
    var probe: WakeRayAddr
    var incidence_bound: Bool
    var theorem_tagged: Bool

    fn __init__(
        inout self,
        object_id: String,
        separator: WakeSeparatorLite,
        probe: WakeRayAddr,
        incidence_bound: Bool,
        theorem_tagged: Bool,
    ):
        self.object_id = object_id
        self.separator = separator
        self.probe = probe
        self.incidence_bound = incidence_bound
        self.theorem_tagged = theorem_tagged

    fn on_separator(self) -> Bool:
        return same_addr(self.probe, self.separator.left) or same_addr(self.probe, self.separator.right)

    fn accepted_left_side(self) -> Bool:
        if not self.separator.valid() or self.on_separator():
            return False
        return self.incidence_bound and self.theorem_tagged and strictly_between_cyclic(self.separator.left, self.probe, self.separator.right)

    fn accepted_right_side(self) -> Bool:
        if not self.separator.valid() or self.on_separator():
            return False
        return self.incidence_bound and self.theorem_tagged and strictly_between_cyclic(self.separator.right, self.probe, self.separator.left)

    fn accepted_some_side(self) -> Bool:
        return self.accepted_left_side() or self.accepted_right_side()


fn wake_membership_soundness_claim_is_available() -> Bool:
    # This remains false until the paper proof binds finite cyclic wake evidence
    # to the classical side relation through theorem tags.
    return False


fn wake_membership_does_not_claim_stabilization() -> Bool:
    return True
