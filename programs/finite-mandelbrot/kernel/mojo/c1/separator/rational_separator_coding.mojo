# C1 rational separator coding scaffold.
#
# This module is intentionally finite and conservative. It records the
# canonical-coding obligations for rational-ray separators used in the C1
# catalogue-extensionality bridge. It does not prove MLC, fibre triviality, or
# generic boundary landing.

from dynamics.ray_address import RayAddr, same_ray_addr, ray_addr_before

fn is_normalized_ray_addr(addr: RayAddr) -> Bool:
    return addr.normalized()


struct CanonicalTwoRayCode:
    var left_num: Int
    var left_den: Int
    var right_num: Int
    var right_den: Int
    var landing_tag: String
    var theorem_tag: String
    var canonical: Bool
    var admissible: Bool

    fn __init__(
        inout self,
        left_num: Int,
        left_den: Int,
        right_num: Int,
        right_den: Int,
        landing_tag: String,
        theorem_tag: String,
        canonical: Bool,
        admissible: Bool,
    ):
        self.left_num = left_num
        self.left_den = left_den
        self.right_num = right_num
        self.right_den = right_den
        self.landing_tag = landing_tag
        self.theorem_tag = theorem_tag
        self.canonical = canonical
        self.admissible = admissible


fn landing_tag_admitted(tag: String) -> Bool:
    if tag == "RationalRayLanding":
        return True
    if tag == "ParabolicLanding":
        return True
    if tag == "HyperbolicBoundaryLanding":
        return True
    return False


fn landing_tag_rejected(tag: String) -> Bool:
    if tag == "GenericBoundaryLanding":
        return True
    if tag == "MLCBinding":
        return True
    if tag == "NumericalLandingGuess":
        return True
    return False


fn nonempty_theorem_tag(tag: String) -> Bool:
    return len(tag) > 0


fn canonical_two_ray_code(
    a: RayAddr,
    b: RayAddr,
    landing_tag: String,
    theorem_tag: String,
) -> CanonicalTwoRayCode:
    if not is_normalized_ray_addr(a):
        return CanonicalTwoRayCode(0, 1, 0, 1, landing_tag, theorem_tag, False, False)
    if not is_normalized_ray_addr(b):
        return CanonicalTwoRayCode(0, 1, 0, 1, landing_tag, theorem_tag, False, False)
    if same_ray_addr(a, b):
        return CanonicalTwoRayCode(a.num, a.den, b.num, b.den, landing_tag, theorem_tag, False, False)
    if landing_tag_rejected(landing_tag):
        return CanonicalTwoRayCode(0, 1, 0, 1, landing_tag, theorem_tag, False, False)
    if not landing_tag_admitted(landing_tag):
        return CanonicalTwoRayCode(0, 1, 0, 1, landing_tag, theorem_tag, False, False)
    if not nonempty_theorem_tag(theorem_tag):
        return CanonicalTwoRayCode(0, 1, 0, 1, landing_tag, theorem_tag, False, False)

    if ray_addr_before(b, a):
        return CanonicalTwoRayCode(b.num, b.den, a.num, a.den, landing_tag, theorem_tag, True, True)
    return CanonicalTwoRayCode(a.num, a.den, b.num, b.den, landing_tag, theorem_tag, True, True)


fn same_separator_identity(x: CanonicalTwoRayCode, y: CanonicalTwoRayCode) -> Bool:
    if not x.admissible or not y.admissible:
        return False
    return (
        x.left_num == y.left_num
        and x.left_den == y.left_den
        and x.right_num == y.right_num
        and x.right_den == y.right_den
        and x.landing_tag == y.landing_tag
        and x.theorem_tag == y.theorem_tag
    )


fn demo_swap_invariant_identity() -> Bool:
    let a = RayAddr(1, 3)
    let b = RayAddr(1, 2)
    let x = canonical_two_ray_code(a, b, "RationalRayLanding", "SchleicherRationalRayLanding")
    let y = canonical_two_ray_code(b, a, "RationalRayLanding", "SchleicherRationalRayLanding")
    return same_separator_identity(x, y)


fn demo_duplicate_rejected() -> Bool:
    let a = RayAddr(1, 3)
    let x = canonical_two_ray_code(a, a, "RationalRayLanding", "SchleicherRationalRayLanding")
    return not x.admissible


fn demo_generic_landing_rejected() -> Bool:
    let a = RayAddr(1, 3)
    let b = RayAddr(1, 2)
    let x = canonical_two_ray_code(a, b, "GenericBoundaryLanding", "UnprovedGenericLanding")
    return not x.admissible


fn demo_no_global_claim() -> Bool:
    # Coding a separator does not prove fibre triviality, MLC, or same-fibre
    # claims. Those remain separate theorem-level obligations.
    return True
