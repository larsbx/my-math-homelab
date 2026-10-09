# C1 residual directive carrier: the residual (infinitely renormalizable) class
# carried as a finite directive prefix of tuning substitutions.
# This file is terminology-governed by docs/C1_residual_directive_carrier.md.
#
# Each level is an exact periodic rational ray address (the angle of a
# renormalization centre) together with the tuning pattern it determines: the
# 0/1 kneading prefix of the address and the twist fixed by the internal-address
# continuation rule. The kneading prefix of the whole carrier is the vendored
# `substitution_dynamics.tuning.kneading_prefix` of its patterns; the twist is
# the vendored `continuation_twist` and the internal address the vendored
# `internal_address`. Nothing here decides fibre membership; see the
# non-claims at the end of the file.
#
# Identifying the pattern's substitution with Douady-Hubbard tuning on kneading
# sequences is the theorem tag `TuningKneadingSubstitution` in
# kernel/mojo/c1/theorem_tags/theorem_tag_import_ledger.mojo, scaffolded, not checked.

from dynamics.angle_tuning import address, tuned_angle
from finite_exact.bigint_z import bigz_add, bigz_eq, bigz_lt, bigz_mul
from finite_exact.checked_int import checked_mul
from rational_dynamics.integers import bigz_is_even, bigz_to_int
from rational_dynamics.rational import ReducedFraction, double_mod_one
from substitution_dynamics.internal_address import internal_address
from substitution_dynamics.tuning import TuningPattern, continuation_twist, kneading_prefix

comptime MAX_CARRIER_PERIOD = 62
comptime MAX_KNEADING_WORD = 1048576


struct KneadingPrefixResult(Copyable, Movable):
    """`prefix` is the 0/1 kneading sequence of a periodic address up to, not
    including, its `*` at position `period`; `rejected` carries no data."""

    var prefix: List[Int]
    var period: Int
    var rejected: Bool

    def __init__(out self, prefix: List[Int], period: Int, rejected: Bool):
        self.prefix = prefix.copy()
        self.period = period
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


def rejected_kneading_prefix() -> KneadingPrefixResult:
    return KneadingPrefixResult(List[Int](), 0, True)


# Regime correspondence: angle-kneading-prefix
def kneading_prefix_of(theta: ReducedFraction) -> KneadingPrefixResult:
    """0/1 kneading sequence of a periodic address: letter `k` is 1 when
    `2^k theta` lies strictly between `theta/2` and `(theta+1)/2` modulo one, 0
    when it lies strictly outside, and the sequence stops at the first
    boundary hit, which is position `period - 1`. Rejects a rejected address,
    zero, an even reduced denominator (not periodic), and periods beyond
    `MAX_CARRIER_PERIOD`. Exact: the comparisons are BigZ cross products and
    the doubling is the vendored `double_mod_one`."""
    if theta.rejected or theta.num.is_zero() or bigz_is_even(theta.den):
        return rejected_kneading_prefix()
    var two_den = bigz_add(theta.den, theta.den)
    var upper_num = bigz_add(theta.num, theta.den)
    var prefix = List[Int]()
    var current = theta.copy()
    for k in range(MAX_CARRIER_PERIOD):
        # Compare current = a/b with theta/2 = num/(2 den) and (theta+1)/2 = (num+den)/(2 den).
        var lhs = bigz_mul(current.num, two_den)
        var low = bigz_mul(theta.num, current.den)
        var high = bigz_mul(upper_num, current.den)
        if bigz_eq(lhs, low) or bigz_eq(lhs, high):
            return KneadingPrefixResult(prefix, k + 1, False)
        prefix.append(1 if (bigz_lt(low, lhs) and bigz_lt(lhs, high)) else 0)
        current = double_mod_one(current)
    return rejected_kneading_prefix()


# Regime correspondence: angle-kneading-prefix
def checked_kneading_prefix(num: Int64, den: Int64) -> KneadingPrefixResult:
    """`kneading_prefix_of` the address `num/den`; rejects addresses outside `(0, 1)`."""
    return kneading_prefix_of(address(num, den))


def _address(nu: List[Int]) -> List[Int]:
    """The vendored internal address of `nu`, or empty for a word it refuses."""
    try:
        return internal_address(nu)
    except:
        return List[Int]()


def _internal_address_contains(nu: List[Int], target: Int) -> Bool:
    """Whether `target` occurs in the vendored internal address of `nu`. The
    smoke reads it as the characterization the closed form below must meet."""
    var address = _address(nu)
    for i in range(len(address)):
        if address[i] == target:
            return True
    return False


struct ContinuationResult(ImplicitlyCopyable):
    """The last letter of `A(nu)`, the periodic continuation of `nu_1 ... nu_(n-1) *`
    whose internal address contains `n`; `rejected` for an empty prefix or a
    letter outside `{0, 1}`, the only inputs on which it is not defined."""

    var last_letter: Int
    var rejected: Bool

    def __init__(out self, last_letter: Int, rejected: Bool):
        self.last_letter = last_letter
        self.rejected = rejected


# Regime correspondence: angle-kneading-prefix
def continuation_last_letter(prefix: List[Int]) -> ContinuationResult:
    """`1 - prefix_(n-S)`, the vendored closed form `continuation_twist` read as
    a letter (upstream docs/tuning-substitutions-spec.md section 1.3): of the
    two continuations of a non-empty 0/1 prefix exactly one has `n` in its
    internal address, and this is its last letter. Fails closed on an empty
    prefix and on any letter outside `{0, 1}`, which the vendored kernel
    refuses."""
    try:
        # twist on means tau(1) = prefix . 0, so the continuation ends in 0.
        return ContinuationResult(0 if continuation_twist(prefix) else 1, False)
    except:
        return ContinuationResult(0, True)


struct DirectiveLevel(Copyable, Movable):
    """One renormalization level: the reduced periodic address and its tuning pattern."""

    var num: Int64
    var den: Int64
    var pattern: TuningPattern

    def __init__(out self, num: Int64, den: Int64, pattern: TuningPattern):
        self.num = num
        self.den = den
        self.pattern = pattern.copy()

    def same_address(self, other: DirectiveLevel) -> Bool:
        return self.num == other.num and self.den == other.den


struct DirectiveLevelResult(Copyable, Movable):
    var level: DirectiveLevel
    var rejected: Bool

    def __init__(out self, level: DirectiveLevel, rejected: Bool):
        self.level = level.copy()
        self.rejected = rejected


def _placeholder_level() -> DirectiveLevel:
    var one: List[Int] = [1]
    return DirectiveLevel(0, 1, TuningPattern(one, False))


# Regime correspondence: angle-kneading-prefix
def checked_directive_level(num: Int64, den: Int64) -> DirectiveLevelResult:
    """The tuning pattern of a periodic address: prefix its kneading prefix,
    twist chosen so that the image of `1` is `A(nu)` (the continuation whose
    internal address contains the period). Fails closed on any rejection."""
    var theta = address(num, den)
    var kneading = kneading_prefix_of(theta)
    if kneading.rejected or len(kneading.prefix) == 0:
        return DirectiveLevelResult(_placeholder_level(), True)
    try:
        # The vendored continuation pattern: tau(1) = prefix . (1 xor twist) is A(nu).
        var pattern = TuningPattern.continuation(kneading.prefix)
        # The reduced address is no larger than the input, so it fits `Int64`.
        var level = DirectiveLevel(Int64(bigz_to_int(theta.num)), Int64(bigz_to_int(theta.den)), pattern)
        return DirectiveLevelResult(level, False)
    except:
        return DirectiveLevelResult(_placeholder_level(), True)


struct ResidualDirectiveCarrier(Copyable, Movable):
    """A finite directive prefix: levels in renormalization order. Refinement
    appends a level and returns a new carrier; the carrier is never mutated."""

    var levels: List[DirectiveLevel]

    def __init__(out self, levels: List[DirectiveLevel]):
        self.levels = levels.copy()

    @staticmethod
    def empty() -> ResidualDirectiveCarrier:
        return ResidualDirectiveCarrier(List[DirectiveLevel]())

    def depth(self) -> Int:
        return len(self.levels)

    def refined(self, level: DirectiveLevel) -> ResidualDirectiveCarrier:
        var levels = self.levels.copy()
        levels.append(level.copy())
        return ResidualDirectiveCarrier(levels)

    def agrees_to_depth(self, other: ResidualDirectiveCarrier, k: Int) -> Bool:
        """Both carriers have at least `k` levels and the first `k` addresses agree."""
        if k < 0 or self.depth() < k or other.depth() < k:
            return False
        for i in range(k):
            if not self.levels[i].same_address(other.levels[i]):
                return False
        return True

    def kneading_word(self) raises -> List[Int]:
        """The kneading prefix of `A_1 * ... * A_n`: the first `p_1 ... p_n - 1`
        letters shared by every tuning of these levels (vendored kernel). Fails
        closed before expanding when the period overflows or exceeds
        `MAX_KNEADING_WORD` letters."""
        var period: Int
        try:
            period = self.checked_period()
        except:
            raise Error("carrier period exceeds the kneading word bound")
        if period > MAX_KNEADING_WORD:
            raise Error("carrier period exceeds the kneading word bound")
        var patterns = List[TuningPattern]()
        for i in range(len(self.levels)):
            patterns.append(self.levels[i].pattern.copy())
        return kneading_prefix(patterns)

    def checked_period(self) raises -> Int:
        """`p_1 ... p_n`, raising on overflow (`finite_exact.checked_int`):
        sixty-three period-2 levels already exceed `Int64`, so the product is
        never trusted unchecked."""
        var p = 1
        for i in range(len(self.levels)):
            p = checked_mul(p, self.levels[i].pattern.period())
        return p


# --- non-claims ---------------------------------------------------------------


def carrier_agreement_proves_same_fiber() -> Bool:
    return False


def directive_prefix_decides_residual_membership() -> Bool:
    return False


def dgp_parity_twist_is_general() -> Bool:
    # The parity twist of the vendored `TuningPattern.dgp` reproduces the
    # continuation rule on real centres only; the rabbit (1/7) refutes it.
    return False


# --- smoke ------------------------------------------------------------------------


def _carrier(nums: List[Int64], dens: List[Int64]) -> ResidualDirectiveCarrier:
    var carrier = ResidualDirectiveCarrier.empty()
    for i in range(len(nums)):
        var level = checked_directive_level(nums[i], dens[i])
        if level.rejected:
            return ResidualDirectiveCarrier.empty()
        carrier = carrier.refined(level.level)
    return carrier^


def _tuned_matches(nums: List[Int64], dens: List[Int64], tuned: ReducedFraction) -> Bool:
    """The carrier's kneading prefix equals the kneading prefix of the address
    obtained by exact angle tuning (`angle_tuning.tuned_angle`, cross-checked by
    the independent oracle reference/python/c1/kneading_reference.py)."""
    var carrier = _carrier(nums, dens)
    if carrier.depth() != len(nums):
        return False
    var expected = kneading_prefix_of(tuned)
    try:
        return expected.accepted() and carrier.kneading_word() == expected.prefix
    except:
        return False


def residual_directive_carrier_smoke() -> Bool:
    var doubling = checked_kneading_prefix(1, 3)
    var airplane = checked_kneading_prefix(3, 7)
    var rabbit = checked_kneading_prefix(1, 7)
    var expected_doubling: List[Int] = [1]
    var expected_airplane: List[Int] = [1, 0]
    var expected_rabbit: List[Int] = [1, 1]
    if not (doubling.accepted() and doubling.period == 2 and doubling.prefix == expected_doubling):
        return False
    if not (airplane.accepted() and airplane.period == 3 and airplane.prefix == expected_airplane):
        return False
    if not (rabbit.accepted() and rabbit.period == 3 and rabbit.prefix == expected_rabbit):
        return False

    # The internal address of the continuation is the classical one: the
    # basilica is 1 -> 2, the rabbit 1 -> 3, the airplane 1 -> 2 -> 3.
    var rabbit_letter = continuation_last_letter(rabbit.prefix)
    var airplane_letter = continuation_last_letter(airplane.prefix)
    var doubling_letter = continuation_last_letter(doubling.prefix)
    if rabbit_letter.rejected or airplane_letter.rejected or doubling_letter.rejected:
        return False
    var rabbit_nu = rabbit.prefix.copy()
    rabbit_nu.append(rabbit_letter.last_letter)
    var airplane_nu = airplane.prefix.copy()
    airplane_nu.append(airplane_letter.last_letter)
    var doubling_nu = doubling.prefix.copy()
    doubling_nu.append(doubling_letter.last_letter)
    var rabbit_address: List[Int] = [1, 3]
    var airplane_address: List[Int] = [1, 2, 3]
    var doubling_address: List[Int] = [1, 2]
    if _address(rabbit_nu) != rabbit_address:
        return False
    if _address(airplane_nu) != airplane_address:
        return False
    if _address(doubling_nu) != doubling_address:
        return False
    if not _internal_address_contains(rabbit_nu, 3) or _internal_address_contains(rabbit_nu, 2):
        return False
    # The closed-form letter is the unique continuation with the period in its
    # brute-force internal address, for every 0/1 prefix of length at most 10.
    for length in range(1, 11):
        for w in range(1 << length):
            var word = List[Int]()
            for i in range(length):
                word.append((w >> i) & 1)
            var letter = continuation_last_letter(word)
            if letter.rejected:
                return False
            var chosen = word.copy()
            chosen.append(letter.last_letter)
            var other = word.copy()
            other.append(1 - letter.last_letter)
            if not _internal_address_contains(chosen, length + 1) or _internal_address_contains(other, length + 1):
                return False
    var empty_prefix = List[Int]()
    var off_alphabet: List[Int] = [1, 2]
    if not (continuation_last_letter(empty_prefix).rejected and continuation_last_letter(off_alphabet).rejected):
        return False
    # Rejections: zero, preperiodic, malformed, out of range.
    if checked_kneading_prefix(0, 1).accepted() or checked_kneading_prefix(1, 2).accepted():
        return False
    if checked_kneading_prefix(1, 0).accepted() or checked_kneading_prefix(7, 5).accepted():
        return False
    # Twists: the rabbit's continuation A(11*) = 110 (twist on), the airplane's A(10*) = 100 (twist on),
    # the satellite period-4 centre 2/5 has A(101*) = 1011 (twist off).
    var rabbit_level = checked_directive_level(1, 7)
    var airplane_level = checked_directive_level(3, 7)
    var satellite_level = checked_directive_level(2, 5)
    if rabbit_level.rejected or airplane_level.rejected or satellite_level.rejected:
        return False
    if not (rabbit_level.level.pattern.twist and airplane_level.level.pattern.twist and not satellite_level.level.pattern.twist):
        return False
    # Exact angle tuning agrees with the substitution kneading prefix.
    var n1: List[Int64] = [1, 1]
    var d1: List[Int64] = [3, 3]
    var n2: List[Int64] = [1, 1, 1]
    var d2: List[Int64] = [3, 3, 3]
    var n3: List[Int64] = [7, 1]
    var d3: List[Int64] = [15, 3]
    var n4: List[Int64] = [1, 1]
    var d4: List[Int64] = [7, 3]
    var n5: List[Int64] = [1, 3]
    var d5: List[Int64] = [7, 7]
    # The angle each carrier tunes to is derived here, not quoted: `angle_tuning`
    # substitutes the root-ray blocks of the component, and the star product of
    # the levels must reach the same address. A level of the doubling component
    # is the pair (1/3, 2/3), the rabbit is (1/7, 2/7), and the primitive
    # period-four component is (7/15, 8/15); a repeated level is a repeated
    # tuning, so three doubling levels tune 1/3 twice.
    var doubling_once = tuned_angle(1, 3, 2, 3, 1, 3)
    var once_num: Int64
    var once_den: Int64
    try:
        once_num = Int64(bigz_to_int(doubling_once.num))
        once_den = Int64(bigz_to_int(doubling_once.den))
    except:
        return False
    var doubling_twice = tuned_angle(1, 3, 2, 3, once_num, once_den)
    var primitive_four = tuned_angle(7, 15, 8, 15, 1, 3)
    var rabbit_third = tuned_angle(1, 7, 2, 7, 1, 3)
    var rabbit_airplane = tuned_angle(1, 7, 2, 7, 3, 7)
    if doubling_once.rejected or doubling_twice.rejected or primitive_four.rejected:
        return False
    if rabbit_third.rejected or rabbit_airplane.rejected:
        return False
    if not _tuned_matches(n1, d1, doubling_once):
        return False
    if not _tuned_matches(n2, d2, doubling_twice):
        return False
    if not _tuned_matches(n3, d3, primitive_four):
        return False
    if not _tuned_matches(n4, d4, rabbit_third):
        return False
    if not _tuned_matches(n5, d5, rabbit_airplane):
        return False
    # Refinement is strict and agreement is prefix-wise.
    var base = _carrier(n1, d1)
    var deeper = _carrier(n2, d2)
    var deeper_period: Int
    try:
        deeper_period = deeper.checked_period()
    except:
        return False
    if not (base.depth() == 2 and deeper.depth() == 3 and deeper_period == 8):
        return False
    # Sixty-three period-2 levels form a valid carrier whose period 2^63 does not fit.
    var doubling_level = checked_directive_level(1, 3)
    var wide = ResidualDirectiveCarrier.empty()
    for _ in range(63):
        wide = wide.refined(doubling_level.level)
    var overflowed = False
    try:
        _ = wide.checked_period()
    except:
        overflowed = True
    if not (wide.depth() == 63 and overflowed):
        return False
    var refused = False
    try:
        _ = wide.kneading_word()
    except:
        refused = True
    if not refused:
        return False
    # Period 63 lies beyond MAX_CARRIER_PERIOD: 92737 divides 2^63 - 1.
    if checked_kneading_prefix(1, 92737).accepted():
        return False
    if not (base.agrees_to_depth(deeper, 2) and not base.agrees_to_depth(deeper, 3)):
        return False
    var other = _carrier(n4, d4)
    if other.agrees_to_depth(base, 1) or not other.agrees_to_depth(base, 0):
        return False
    return (
        not carrier_agreement_proves_same_fiber()
        and not directive_prefix_decides_residual_membership()
        and not dgp_parity_twist_is_general()
    )
