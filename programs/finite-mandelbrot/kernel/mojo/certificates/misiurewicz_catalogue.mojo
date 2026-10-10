# Exact-type catalogue of Misiurewicz ray addresses (round-one item B6).
# This file is terminology-governed by docs/C1_misiurewicz_catalogue.md; the
# term `exact-type catalogue` is registered in docs/terminology-registry.md.
#
# A rational ray address `p/q` in lowest terms has, under doubling modulo one,
# an exact preperiod and an exact period read off `q` alone: write `q = 2^l m`
# with `m` odd, and the address has preperiod `l` and period the multiplicative
# order of `2` modulo `m`, with `m = 1` giving period one because zero is
# fixed. An address is of Misiurewicz type when `l >= 1`: the orbit is strictly
# preperiodic.
#
# The catalogue of exact type `(l, k)` is the finite set of such addresses. Its
# size obeys the counting identity
#
#   count(l, k) = 2^(l-1) * sum_{d | k} mu(k/d) (2^d - 1),
#
# because the addresses of exact type `(l, k)` are exactly `p / (2^l m)` in
# lowest terms with `m` odd of multiplicative order `k`, of which there are
# `phi(2^l m) = 2^(l-1) phi(m)`, and the orders sum by Moebius inversion over
# the divisors of `2^k - 1`. `catalogue_matches_count` checks the identity
# against the enumeration, which is the round-one angle-count regression.
#
# The doubling-map number theory is the vendored `rational_dynamics.doubling`
# (upstream finite-math-kernels), exact over BigZ with no cap: its
# `exact_type` reads the preperiod and the period, and its `exact_type_count`
# is the counting identity. What stays here is this repository's data policy,
# two bounds on machine-`Int` addresses, and they govern different things.
# `exact_type` reads a type off any address whose denominator is at most
# `MAX_CATALOGUE_DENOMINATOR` and refuses every other address. A catalogue of
# type `(l, k)` additionally needs both indices at most `MAX_TYPE_INDEX` and
# needs its own denominator `2^l (2^k - 1)` to stay within the same bound,
# which is far more restrictive. So an accepted type need not be one this
# module holds a catalogue of: `1/58` is of type `(1, 28)`, whose period is
# past the index bound, and `1/50` is of type `(1, 20)`, whose indices are both
# inside it while `2 (2^20 - 1)` is past the denominator bound. Ask
# `catalogueable_type` rather than reading catalogueability off acceptance.
# Nothing here can overflow. No floating point and no measured angle appears;
# these are finite symbolic addresses.
#
# Scope: the catalogue is a finite set of addresses. It is not a set of
# parameters, it locates nothing in the plane, and the triviality of the
# fibres of the corresponding parameters is the imported theorem tag
# `KnownTrivialFiberClass`, not a property computed here.

from angle_doubling.angle import type_count
from rational_dynamics.doubling import exact_type_count
from rational_dynamics.doubling import exact_type as doubling_type
from rational_dynamics.integers import bigz_to_int
from rational_dynamics.moebius import moebius
from rational_dynamics.rational import fraction_from_i64

comptime MAX_TYPE_INDEX = 20
comptime MAX_CATALOGUE_DENOMINATOR = 1048576


struct MisiurewiczType(ImplicitlyCopyable):
    """`preperiod` and `period` of a ray address under doubling; a rejected
    value carries no type."""

    var preperiod: Int
    var period: Int
    var rejected: Bool

    def __init__(out self, preperiod: Int, period: Int, rejected: Bool):
        self.preperiod = preperiod
        self.period = period
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected

    def misiurewicz(self) -> Bool:
        """Strictly preperiodic: the orbit never returns to the address."""
        return self.accepted() and self.preperiod >= 1


def rejected_type() -> MisiurewiczType:
    return MisiurewiczType(0, 0, True)


# Regime correspondence: misiurewicz-exact-type
def exact_type(num: Int, den: Int) -> MisiurewiczType:
    """Exact preperiod and period of `num/den` under doubling modulo one.
    Refuses an address outside `[0, 1)`, a non-positive denominator, and a
    denominator beyond the catalogue bound. An accepted type is a true fact
    about the address; it is not a promise that this module holds a catalogue
    of that type, which is `catalogueable_type`."""
    if den <= 0 or num < 0 or num >= den or den > MAX_CATALOGUE_DENOMINATOR:
        return rejected_type()
    var found = doubling_type(fraction_from_i64(Int64(num), Int64(den)))
    if found.rejected:
        return rejected_type()
    try:
        # The period is below the denominator, so it fits; a refusal still fails closed.
        return MisiurewiczType(found.preperiod, bigz_to_int(found.period), False)
    except:
        return rejected_type()


def catalogue_denominator(preperiod: Int, period: Int) -> Int:
    """`2^l (2^k - 1)`, the common denominator of every address of exact type
    `(l, k)`. Returns `-1` when the type is out of range or the denominator
    exceeds the catalogue bound."""
    if preperiod < 1 or period < 1 or preperiod > MAX_TYPE_INDEX or period > MAX_TYPE_INDEX:
        return -1
    # The addresses with `2^(l+k) t = 2^l t` are exactly the multiples of
    # `1 / (2^l (2^k - 1))`, so the vendored `type_count` is this denominator.
    # Both indices are at most `MAX_TYPE_INDEX`, inside its range, so it never
    # refuses here; a refusal would still fail closed below.
    var den = Int(type_count(preperiod, period))
    if den < 1 or den > MAX_CATALOGUE_DENOMINATOR:
        return -1
    return den


def catalogueable_type(preperiod: Int, period: Int) -> Bool:
    """Whether this module holds a catalogue of exact type `(l, k)`: strictly
    stronger than `exact_type` accepting an address of that type, because the
    catalogue denominator must also stay within the bound."""
    return catalogue_denominator(preperiod, period) > 0


# Regime correspondence: misiurewicz-exact-type
def catalogue_count(preperiod: Int, period: Int) -> Int:
    """`2^(l-1) sum_{d | k} mu(k/d) (2^d - 1)`, the size the identity predicts:
    the vendored `exact_type_count`, which is exact for every type. Returns `-1`
    for a type out of range, where this module holds no catalogue."""
    if catalogue_denominator(preperiod, period) < 0:
        return -1
    var count = exact_type_count(preperiod, period)
    if count.rejected:
        return -1
    try:
        return bigz_to_int(count.value)
    except:
        return -1


# Regime correspondence: misiurewicz-exact-type
def catalogue(preperiod: Int, period: Int) -> List[Int]:
    """Numerators, ascending, of every address of exact type `(l, k)` over the
    denominator `catalogue_denominator(l, k)`. Empty for a type out of range."""
    var out = List[Int]()
    var den = catalogue_denominator(preperiod, period)
    if den < 0:
        return out^
    for num in range(den):
        var found = exact_type(num, den)
        if found.accepted() and found.preperiod == preperiod and found.period == period:
            out.append(num)
    return out^


def catalogue_matches_count(preperiod: Int, period: Int) -> Bool:
    """The angle-count regression: enumeration agrees with the identity."""
    var den = catalogue_denominator(preperiod, period)
    if den < 0:
        return False
    return len(catalogue(preperiod, period)) == catalogue_count(preperiod, period)


# --- non-claims ---------------------------------------------------------------


def catalogue_is_a_set_of_parameters() -> Bool:
    # The catalogue holds ray addresses. Associating a parameter with an address
    # needs a landing theorem tag and an adapter, neither of which is here.
    return False


def catalogue_proves_fibre_triviality() -> Bool:
    # Triviality of the fibres of Misiurewicz parameters is the imported tag
    # KnownTrivialFiberClass, under its own hypotheses.
    return False


# --- smoke ------------------------------------------------------------------------


def type_agrees_with_doubling(max_den: Int) -> Bool:
    """`exact_type` against the orbit itself: doubling on Z/den, where the first
    repeated state gives the preperiod and the period directly. Every reduced
    and unreduced address with denominator below `max_den`."""
    for den in range(1, max_den):
        var seen = List[Int](length=den, fill=-1)
        for num in range(den):
            for i in range(den):
                seen[i] = -1
            var point = num
            var step = 0
            while seen[point] < 0:
                seen[point] = step
                point = (2 * point) % den
                step += 1
            var found = exact_type(num, den)
            if not (found.accepted() and found.preperiod == seen[point] and found.period == step - seen[point]):
                return False
    return True


def misiurewicz_catalogue_smoke() -> Bool:
    # 1/2 -> 0 -> 0: preperiod one, period one, and Misiurewicz.
    var half = exact_type(1, 2)
    if not (half.misiurewicz() and half.preperiod == 1 and half.period == 1):
        return False
    # 1/6 -> 1/3 -> 2/3 -> 1/3: preperiod one, period two.
    var sixth = exact_type(1, 6)
    if not (sixth.misiurewicz() and sixth.preperiod == 1 and sixth.period == 2):
        return False
    # 1/3 is periodic, so it is not of Misiurewicz type.
    var third = exact_type(1, 3)
    if not (third.accepted() and third.preperiod == 0 and third.period == 2):
        return False
    if third.misiurewicz():
        return False
    # Reduction first: 2/6 is 1/3, not an address of preperiod one.
    var reducible = exact_type(2, 6)
    if not (reducible.accepted() and reducible.preperiod == 0 and reducible.period == 2):
        return False
    # The pinned catalogues.
    var one_one: List[Int] = [1]
    var two_one: List[Int] = [1, 3]
    var one_two: List[Int] = [1, 5]
    var one_three: List[Int] = [1, 3, 5, 9, 11, 13]
    if catalogue(1, 1) != one_one or catalogue_denominator(1, 1) != 2:
        return False
    if catalogue(2, 1) != two_one or catalogue_denominator(2, 1) != 4:
        return False
    if catalogue(1, 2) != one_two or catalogue_denominator(1, 2) != 6:
        return False
    if catalogue(1, 3) != one_three or catalogue_denominator(1, 3) != 14:
        return False
    # The type against brute-force iteration of the doubling map.
    if not type_agrees_with_doubling(120):
        return False
    var zero = exact_type(0, 1)
    var quarter = exact_type(1, 4)
    if not (zero.preperiod == 0 and zero.period == 1 and quarter.preperiod == 2 and quarter.period == 1):
        return False
    # The counting identity against the enumeration.
    for l in range(1, 5):
        for k in range(1, 5):
            if not catalogue_matches_count(l, k):
                return False
    if catalogue_count(1, 1) != 1 or catalogue_count(2, 3) != 12 or catalogue_count(3, 3) != 24:
        return False
    # Moebius values the identity relies on (the vendored `moebius`).
    try:
        if moebius(1) != 1 or moebius(2) != -1 or moebius(4) != 0 or moebius(6) != 1 or moebius(30) != -1:
            return False
    except:
        return False
    # Fail closed: out-of-range addresses, types, and denominators.
    if exact_type(1, 0).accepted() or exact_type(5, 3).accepted() or exact_type(-1, 4).accepted():
        return False
    # An accepted type need not be catalogueable, by either bound: 1/58 is of
    # type (1, 28), past the index bound, and 1/50 is of type (1, 20), whose
    # indices are inside it while its catalogue denominator is not.
    var past_index = exact_type(1, 58)
    var past_denominator = exact_type(1, 50)
    if not (past_index.accepted() and past_index.preperiod == 1 and past_index.period == 28):
        return False
    if not (past_denominator.accepted() and past_denominator.preperiod == 1 and past_denominator.period == 20):
        return False
    if catalogueable_type(1, 28) or catalogueable_type(1, 20) or not catalogueable_type(1, 3):
        return False
    if catalogue_denominator(0, 2) >= 0 or catalogue_denominator(1, 0) >= 0:
        return False
    if catalogue_denominator(1, MAX_TYPE_INDEX + 1) >= 0 or catalogue_denominator(1, 20) >= 0:
        return False
    if catalogue_count(0, 1) != -1 or len(catalogue(0, 1)) != 0:
        return False
    return not catalogue_is_a_set_of_parameters() and not catalogue_proves_fibre_triviality()
