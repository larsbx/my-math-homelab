# limb_streams.mojo
#
# Limb root angles by rotation number, and the Farey streams of limbs that make
# the atlas's valleys and the golden-mean convergents finite objects.
#
# The p/q-limb of the main cardioid has root rays theta_- < theta_+ on the
# unique period-q doubling cycle on which doubling acts as rotation by p/q.
# Here they are read off the rotation itself: the itinerary of j/q under
# x -> x + p/q against the arc [1 - p/q, 1) is the binary word of a cycle angle,
# and theta_-, theta_+ are the words of j = p - 1 and j = p. Elsewhere a limb is
# the tuning image of a main-cardioid limb by its parent's root rays.
#
# Everything is a statement about addresses. That the rays land at the root of
# a component is the imported landing theorem, as in angle_tuning.

from dynamics.angle_tuning import address, address_period, tuned_angle
from finite_exact.bigint_z import bigz_mul, bigz_sub
from rational_dynamics.rational import ReducedFraction, fraction_equal, fraction_from_i64, reduce_fraction, rejected_fraction

#: Largest q read off the rotation directly; 2^q - 1 must fit an Int64 word.
comptime LIMB_DENOMINATOR_LIMIT = 40


struct LimbRoots(Copyable, Movable):
    """The root angles theta_- < theta_+ of a limb, or a rejection."""

    var lo: ReducedFraction
    var hi: ReducedFraction

    def __init__(out self, var lo: ReducedFraction, var hi: ReducedFraction):
        self.lo = lo^
        self.hi = hi^

    def accepted(self) -> Bool:
        return self.lo.accepted() and self.hi.accepted()

    def width(self) -> ReducedFraction:
        """theta_+ - theta_-, exactly."""
        if not self.accepted():
            return rejected_fraction()
        return reduce_fraction(
            bigz_sub(bigz_mul(self.hi.num, self.lo.den), bigz_mul(self.lo.num, self.hi.den)),
            bigz_mul(self.lo.den, self.hi.den),
        )


def rejected_limb() -> LimbRoots:
    return LimbRoots(rejected_fraction(), rejected_fraction())


def _gcd(a: Int, b: Int) -> Int:
    var x = a
    var y = b
    while y != 0:
        var t = x % y
        x = y
        y = t
    return x


def rotation_word(start: Int, p: Int, q: Int) -> Int64:
    """The itinerary of start/q under rotation by p/q against [1 - p/q, 1), as a q-bit integer."""
    var word: Int64 = 0
    for i in range(q):
        word = word * 2 + (Int64(1) if (start + i * p) % q >= q - p else Int64(0))
    return word


def main_cardioid_limb(p: Int, q: Int) -> LimbRoots:
    """Root angles of the p/q-limb of the main cardioid, for reduced 0 < p/q < 1."""
    if q < 2 or q > LIMB_DENOMINATOR_LIMIT or p < 1 or p >= q or _gcd(p, q) != 1:
        return rejected_limb()
    var den = (Int64(1) << Int64(q)) - 1
    return LimbRoots(
        fraction_from_i64(rotation_word(p - 1, p, q), den),
        fraction_from_i64(rotation_word(p, p, q), den),
    )


def limb_of(lo_num: Int64, lo_den: Int64, hi_num: Int64, hi_den: Int64, p: Int, q: Int) -> LimbRoots:
    """Root angles of the p/q-limb of the component with root rays lo_num/lo_den < hi_num/hi_den: the
    main-cardioid limb tuned by that component. The main cardioid itself is passed as 0/1, 0/1."""
    if q < 2 or q > LIMB_DENOMINATOR_LIMIT or p < 1 or p >= q or _gcd(p, q) != 1:
        return rejected_limb()
    if lo_num == 0 and hi_num == 0:
        return main_cardioid_limb(p, q)
    var den = (Int64(1) << Int64(q)) - 1
    return LimbRoots(
        tuned_angle(lo_num, lo_den, hi_num, hi_den, rotation_word(p - 1, p, q), den),
        tuned_angle(lo_num, lo_den, hi_num, hi_den, rotation_word(p, p, q), den),
    )


struct FareyTerm(Copyable, Movable):
    """One limb of a stream: the side it approaches from and its rotation number."""

    var below: Bool
    var num: Int
    var den: Int

    def __init__(out self, below: Bool, num: Int, den: Int):
        self.below = below
        self.num = num
        self.den = den


def farey_stream(a: Int, b: Int, depth: Int, max_den: Int) -> List[FareyTerm]:
    """Rotation numbers tending to a/b along its Farey parents, (n a + a')/(n b + b') for n = 1..depth,
    below then above, keeping denominators up to max_den. The parent below exists when a/b > 0 and the
    parent above when a/b < 1; each is the neighbour of smallest denominator."""
    var out = List[FareyTerm]()
    for side in range(2):
        var below = side == 0
        if (below and a == 0) or (not below and a == b):
            continue
        var pn = -1
        var pd = -1
        for d in range(1, b + 1):
            for n in range(d + 1):
                var det = a * d - n * b if below else n * b - a * d
                if det == 1 and pd < 0 and (d < b or not below):
                    pn = n
                    pd = d
        if pd < 0:
            continue
        for k in range(1, depth + 1):
            if k * b + pd <= max_den:
                out.append(FareyTerm(below, k * a + pn, k * b + pd))
    return out^


# --- smoke --------------------------------------------------------------------------


def _limb_is(limb: LimbRoots, lo_n: Int64, lo_d: Int64, hi_n: Int64, hi_d: Int64) -> Bool:
    return fraction_equal(limb.lo, address(lo_n, lo_d)) and fraction_equal(limb.hi, address(hi_n, hi_d))


def limb_streams_smoke() -> Bool:
    # Main-cardioid limbs: 1/2, 1/3, 2/3, 1/4, 2/5, 3/8.
    if not _limb_is(main_cardioid_limb(1, 2), 1, 3, 2, 3):
        return False
    if not _limb_is(main_cardioid_limb(1, 3), 1, 7, 2, 7) or not _limb_is(main_cardioid_limb(2, 3), 5, 7, 6, 7):
        return False
    if not _limb_is(main_cardioid_limb(1, 4), 1, 15, 2, 15) or not _limb_is(main_cardioid_limb(2, 5), 9, 31, 10, 31):
        return False
    if not _limb_is(main_cardioid_limb(3, 8), 73, 255, 74, 255):
        return False
    # Refusals: unreduced, out of range, past the word limit.
    if main_cardioid_limb(2, 4).accepted() or main_cardioid_limb(3, 3).accepted() or main_cardioid_limb(1, 41).accepted():
        return False
    # The main cardioid passes through; the 1/2-bulb tunes: its 1/2-limb is 2/5, 3/5, its 1/3-limb 22/63, 25/63.
    if not _limb_is(limb_of(0, 1, 0, 1, 1, 3), 1, 7, 2, 7):
        return False
    if not _limb_is(limb_of(1, 3, 2, 3, 1, 2), 2, 5, 3, 5) or not _limb_is(limb_of(1, 3, 2, 3, 1, 3), 22, 63, 25, 63):
        return False
    # Every main-cardioid wake has width 1/(2^q - 1), and both rays have period q.
    for q in range(2, 15):
        for p in range(1, q):
            if _gcd(p, q) != 1:
                continue
            var limb = main_cardioid_limb(p, q)
            if not fraction_equal(limb.width(), address(1, (Int64(1) << Int64(q)) - 1)):
                return False
            if address_period(limb.lo) != q or address_period(limb.hi) != q:
                return False
    # Farey streams: 1/2 from below is 1/3, 2/5, 3/7; from above 2/3, 3/5, 4/7. 0 has only the side above.
    var half = farey_stream(1, 2, 3, 14)
    if len(half) != 6 or not (half[0].below and half[0].num == 1 and half[0].den == 3):
        return False
    if not (half[2].num == 3 and half[2].den == 7 and not half[3].below and half[3].num == 2 and half[3].den == 3):
        return False
    var cusp = farey_stream(0, 1, 3, 14)
    if len(cusp) != 3 or cusp[0].below or cusp[0].num != 1 or cusp[0].den != 2 or cusp[2].den != 4:
        return False
    return True
