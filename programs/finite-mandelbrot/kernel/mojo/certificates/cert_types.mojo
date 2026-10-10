# cert_types.mojo
#
# Witness-facing data structures for the finite-regime Mandelbrot certificate
# calculus. These types make the proof boundary explicit:
#
#   - squarefree localization is algebraic and finite;
#   - exact type is pointwise exclusion on the same box;
#   - landing/fiber conclusions are theorem tags, not internal proofs.

struct Dyadic:
    var mantissa: Int
    var shift: Int

    def __init__(out self, mantissa: Int, shift: Int):
        # value = mantissa / 2^shift
        self.mantissa = mantissa
        self.shift = shift


struct ComplexDyadic:
    var re: Dyadic
    var im: Dyadic

    def __init__(out self, re: Dyadic, im: Dyadic):
        self.re = re
        self.im = im


struct ComplexBox:
    var re_lo: Dyadic
    var re_hi: Dyadic
    var im_lo: Dyadic
    var im_hi: Dyadic

    def __init__(out self, re_lo: Dyadic, re_hi: Dyadic, im_lo: Dyadic, im_hi: Dyadic):
        self.re_lo = re_lo
        self.re_hi = re_hi
        self.im_lo = im_lo
        self.im_hi = im_hi


struct PairIJ:
    var i: Int
    var j: Int

    def __init__(out self, i: Int, j: Int):
        self.i = i
        self.j = j


struct SquarefreeWitness:
    # Represents P = R / gcd(R, R').
    # Full implementation must include Euclidean quotients and remainder-zero checks.
    var degree_R: Int
    var degree_gcd: Int
    var degree_P: Int

    def __init__(out self, degree_R: Int, degree_gcd: Int, degree_P: Int):
        self.degree_R = degree_R
        self.degree_gcd = degree_gcd
        self.degree_P = degree_P


struct KrawczykWitness:
    # Represents K(beta) subset interior(beta) for the localization polynomial.
    # The current fields are metadata; exact interval enclosures will replace them.
    var center: ComplexDyadic
    var approximate_inverse: ComplexDyadic
    var inclusion_checked: Bool

    def __init__(out self, center: ComplexDyadic, approximate_inverse: ComplexDyadic, inclusion_checked: Bool):
        self.center = center
        self.approximate_inverse = approximate_inverse
        self.inclusion_checked = inclusion_checked


struct JointBoxWitness:
    # Load-bearing condition after squarefree localization:
    #   same beta must support both Krawczyk inclusion and all forbidden exclusions.
    var krawczyk_ok: Bool
    var forbidden_exclusions_ok: Bool
    var same_box: Bool

    def __init__(out self, krawczyk_ok: Bool, forbidden_exclusions_ok: Bool, same_box: Bool):
        self.krawczyk_ok = krawczyk_ok
        self.forbidden_exclusions_ok = forbidden_exclusions_ok
        self.same_box = same_box

    def accepts(self) -> Bool:
        return self.krawczyk_ok and self.forbidden_exclusions_ok and self.same_box


struct TheoremTags:
    var rational_ray_landing: Bool
    var misiurewicz_fiber_triviality: Bool

    def __init__(out self, rational_ray_landing: Bool, misiurewicz_fiber_triviality: Bool):
        self.rational_ray_landing = rational_ray_landing
        self.misiurewicz_fiber_triviality = misiurewicz_fiber_triviality

    def accepts(self) -> Bool:
        return self.rational_ray_landing and self.misiurewicz_fiber_triviality


struct MisCertHeader:
    var ell: Int
    var period_k: Int
    var horizon_H: Int
    var ray_address_preperiod_lambda: Int
    var ray_period_n: Int

    def __init__(out self, ell: Int, period_k: Int, horizon_H: Int, ray_period_n: Int):
        self.ell = ell
        self.period_k = period_k
        self.horizon_H = horizon_H
        self.ray_address_preperiod_lambda = ell - 1
        self.ray_period_n = ray_period_n

    def header_ok(self) -> Bool:
        if self.ell < 1:
            return False
        if self.period_k < 1:
            return False
        if self.horizon_H < self.ell + self.period_k:
            return False
        if self.ray_address_preperiod_lambda != self.ell - 1:
            return False
        if self.ray_period_n % self.period_k != 0:
            return False
        return True
