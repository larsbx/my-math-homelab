# Canonical finite rational-ray address value type.
# It does not represent a measured angle. Doubling is not defined here: the
# doubling map on addresses is the vendored `rational_dynamics.double_mod_one`
# (exact, BigZ-backed), used through `dynamics/bigq_ray_address.mojo`.

from finite_exact.integer_gcd import gcd_int


struct RayAddr(ImplicitlyCopyable):
    var num: Int
    var den: Int

    def __init__(out self, num: Int, den: Int):
        self.num = num
        self.den = den

    def shape_valid(self) -> Bool:
        return self.den > 0 and self.num >= 0 and self.num < self.den

    def valid(self) -> Bool:
        return self.shape_valid()

    def normalized(self) -> Bool:
        if not self.shape_valid():
            return False
        try:
            return gcd_int(self.num, self.den) == 1
        except:
            return False


def same_ray_addr(a: RayAddr, b: RayAddr) -> Bool:
    return a.num == b.num and a.den == b.den


def ray_addr_before(a: RayAddr, b: RayAddr) -> Bool:
    if a.den < b.den:
        return True
    if a.den > b.den:
        return False
    return a.num < b.num
