# C1 carrier density profile: the separated-pair density of every prefix of a
# residual directive carrier, level by level.
# This file is terminology-governed by docs/C1_separated_pair_density.md, whose
# "Next step" it builds: attach a density to each level of a carrier's
# catalogue prefix, so that a refinement step reports the measure it decided as
# well as the addresses it added, and record whether the residue is
# non-increasing along the C1 carrier-refinement order.
# Arithmetic specification: docs/rational-interval-arithmetic-spec.md (binding row
# "finite angle-measure density along a carrier"): every density, residue and
# increment is an unbounded exact rational; rejection is sticky and no floating
# point appears.
#
# A carrier level does not supply its own separator. docs/C1_admissible_separator_codes.md
# requires a separator to carry accepted landing tags on both rays and a
# declared co-landing pair, and an address alone supplies neither, so the
# separator declared for each level is a separate input. Deriving one from the
# level's own address is exactly the vacuous construction the round-two
# correction to N3 refused: it would put every carrier address in its own arc
# and measure the construction rather than anything about the carrier.
#
# That requirement is enforced, not only stated. Two rational endpoints are not
# a separator: an arbitrary pair of distinct angles cuts the circle without
# anything licensing the cut, and reporting its measure at a carrier level
# would report an unproved separation as a decided one. Each level therefore
# declares a landing tag and whether the pair is a declared co-landing, and
# admissible_separator below refuses the level otherwise -- in particular it
# refuses the generic-boundary and MLC tags that the spec forbids, which is
# where an analytic assumption would enter if it entered anywhere.
#
# Two identities are checked, not assumed, and a violation is a rejection
# rather than a reported oddity, because neither can fail on an accepted input:
#
#   the increments sum to the density   sum_k decided_k = density_n
#   the residue never rises             residue_{k+1} <= residue_k
#
# The second is the refinement monotonicity of docs/C1_separated_pair_density.md
# read along the carrier order: a further separator refines the signature
# partition, and splitting a class never raises a sum of squares. It is
# recorded as a field so a reader sees it was checked on this prefix, and it is
# also a kernel self-check, like the atom lengths summing to one.
#
# Nothing here decides a named pair or a carrier. A density approaching one
# leaves the undecided pairs null, never empty, and the infinitely
# renormalizable parameters a carrier describes lie exactly in that null set.
# The measure says nothing about whether two parameters share a fibre.

from c1.residual.residual_directive_carrier import ResidualDirectiveCarrier, checked_directive_level
from c1.separator.separated_density import SeparatedDensityResult, separated_pair_density
from finite_exact.rat_q import Q


struct CarrierDensityLevel(Copyable, Movable):
    """One prefix of the carrier: the measure its separators decide, the
    residue they leave, and the measure this level added.

    `Q` is `Copyable` but not `ImplicitlyCopyable`, so every field assignment
    below copies explicitly."""

    var depth: Int
    var density: Q
    var residue: Q
    var decided: Q
    var classes: Int
    var atoms: Int

    def __init__(out self, depth: Int, density: Q, residue: Q, decided: Q, classes: Int, atoms: Int):
        self.depth = depth
        self.density = density.copy()
        self.residue = residue.copy()
        self.decided = decided.copy()
        self.classes = classes
        self.atoms = atoms


struct CarrierDensityProfile(Copyable, Movable):
    """One level per carrier level, in refinement order. A rejected profile
    carries no levels: a bounded or malformed input is never an empty answer."""

    var levels: List[CarrierDensityLevel]
    var residue_non_increasing: Bool
    var rejected: Bool

    def __init__(out self, levels: List[CarrierDensityLevel], residue_non_increasing: Bool, rejected: Bool):
        self.levels = levels.copy()
        self.residue_non_increasing = residue_non_increasing
        self.rejected = rejected

    def depth(self) -> Int:
        return len(self.levels)

    def accepted(self) -> Bool:
        return not self.rejected


def rejected_profile() -> CarrierDensityProfile:
    return CarrierDensityProfile(List[CarrierDensityLevel](), False, True)


# Landing tags of docs/C1_admissible_separator_codes.md, as integer codes so a
# caller cannot spell one wrong and be believed. The forbidden tags -- generic
# boundary landing, MLC binding -- deliberately have no code: they are every
# value that is not one of these three.
comptime LANDING_RATIONAL_RAY: Int64 = 1
comptime LANDING_PARABOLIC: Int64 = 2
comptime LANDING_HYPERBOLIC_BOUNDARY: Int64 = 3


def admissible_separator(tag: Int64, co_landing: Bool, ln: Int64, ld: Int64, rn: Int64, rd: Int64) -> Bool:
    """Whether the declared separator of one level may be measured at all: an
    accepted landing tag, a declared co-landing pair, positive denominators and
    two distinct rays. Nothing here is derived from the level's address."""
    if not co_landing:
        return False
    if tag != LANDING_RATIONAL_RAY and tag != LANDING_PARABOLIC and tag != LANDING_HYPERBOLIC_BOUNDARY:
        return False
    if ld <= 0 or rd <= 0:
        return False
    return ln * rd != rn * ld


def _prefix(values: List[Int64], count: Int) -> List[Int64]:
    var out = List[Int64]()
    for i in range(count):
        out.append(values[i])
    return out^


# Regime correspondence: separated-pair-density
def carrier_density_profile(
    level_nums: List[Int64],
    level_dens: List[Int64],
    lefts_n: List[Int64],
    lefts_d: List[Int64],
    rights_n: List[Int64],
    rights_d: List[Int64],
    tags: List[Int64],
    co_landings: List[Bool],
) -> CarrierDensityProfile:
    """The density of every prefix of the carrier `level_nums/level_dens`,
    under the separator declared for each level. Fails closed on a length
    mismatch, a level address that is not a periodic ray address, a separator
    that is not admissible under docs/C1_admissible_separator_codes.md, a
    separator the density kernel refuses, and on either identity above
    failing."""
    var count = len(level_nums)
    if len(level_dens) != count or len(lefts_n) != count or len(lefts_d) != count:
        return rejected_profile()
    if len(rights_n) != count or len(rights_d) != count:
        return rejected_profile()
    if len(tags) != count or len(co_landings) != count:
        return rejected_profile()
    for i in range(count):
        if not admissible_separator(
            tags[i], co_landings[i], lefts_n[i], lefts_d[i], rights_n[i], rights_d[i]
        ):
            return rejected_profile()
    var carrier = ResidualDirectiveCarrier.empty()
    for i in range(count):
        var level = checked_directive_level(level_nums[i], level_dens[i])
        if level.rejected:
            return rejected_profile()
        carrier = carrier.refined(level.level)
    if carrier.depth() != count:
        return rejected_profile()

    var levels = List[CarrierDensityLevel]()
    var previous_density = Q.zero()
    var previous_residue = Q.one()
    var total_decided = Q.zero()
    var non_increasing = True
    for k in range(1, count + 1):
        var here = separated_pair_density(
            _prefix(lefts_n, k), _prefix(lefts_d, k), _prefix(rights_n, k), _prefix(rights_d, k)
        )
        if not here.accepted():
            return rejected_profile()
        var decided = here.density.sub(previous_density)
        if not decided.accepted() or decided.lt(Q.zero()):
            return rejected_profile()
        if previous_residue.lt(here.residue):
            non_increasing = False
        total_decided = total_decided.add(decided)
        if not total_decided.accepted():
            return rejected_profile()
        var row = CarrierDensityLevel(k, here.density, here.residue, decided, here.classes, here.atoms)
        levels.append(row.copy())
        previous_density = here.density.copy()
        previous_residue = here.residue.copy()
    if not non_increasing:
        return rejected_profile()
    if count > 0 and not total_decided.eq(previous_density):
        return rejected_profile()
    return CarrierDensityProfile(levels, non_increasing, False)


# --- non-claims ---------------------------------------------------------------


def profile_decides_carrier_membership() -> Bool:
    # A density is a measure of pairs, not a verdict on any pair, and a carrier
    # prefix decides membership of no parameter.
    return False


def residue_zero_at_some_level_is_reachable() -> Bool:
    # Finitely many separators cut finitely many atoms, so some class has
    # positive measure and the residue stays positive at every finite level.
    return False


def density_increment_measures_carrier_progress() -> Bool:
    # The increment is the measure this level decided, not progress towards
    # C1: the remaining pairs are where the frontier is, and they are null in
    # the limit at best, never empty.
    return False


# --- smoke ------------------------------------------------------------------------


def _levels(nums: List[Int64], dens: List[Int64]) -> CarrierDensityProfile:
    """The wake pairs declared for the basilica, rabbit and airplane levels:
    1/3 with 2/3, 1/7 with 2/7, 3/7 with 4/7. Imported co-landings, not
    quantities derived from the carrier's addresses, and each declared as a
    rational-ray landing because that is what Douady-Hubbard wake theory
    supplies for them."""
    var lefts_n = List[Int64]()
    var lefts_d = List[Int64]()
    var rights_n = List[Int64]()
    var rights_d = List[Int64]()
    var tags = List[Int64]()
    var co_landings = List[Bool]()
    for i in range(len(nums)):
        tags.append(LANDING_RATIONAL_RAY)
        co_landings.append(True)
        if nums[i] == 1 and dens[i] == 3:
            lefts_n.append(1)
            lefts_d.append(3)
            rights_n.append(2)
            rights_d.append(3)
        elif nums[i] == 1 and dens[i] == 7:
            lefts_n.append(1)
            lefts_d.append(7)
            rights_n.append(2)
            rights_d.append(7)
        else:
            lefts_n.append(3)
            lefts_d.append(7)
            rights_n.append(4)
            rights_d.append(7)
    return carrier_density_profile(
        nums, dens, lefts_n, lefts_d, rights_n, rights_d, tags, co_landings
    )


def sweep_picks() -> List[Tuple[Int, Int]]:
    """The sweep corpus: separators (a/12, b/12) spread over the circle, declared
    and audited in tests/test_generator_refinement.py."""
    return [(0, 1), (1, 3), (2, 7), (3, 4), (4, 10), (5, 9), (6, 11), (7, 8), (2, 5)]


def _twelfth(n: Int) -> Tuple[Int64, Int64]:
    """n/12 in lowest terms, with 0 as 0/1."""
    var g = 12
    while n % g != 0 or 12 % g != 0:
        g -= 1
    return (Int64(n // g), Int64(12 // g))


def sweep_profiles_accepted() -> Bool:
    """Every prefix of one to three sweep separators yields an accepted profile.
    carrier_density_profile refuses a profile whose residue rises or whose
    increments do not sum to its density, so acceptance is both identities."""
    var picks = sweep_picks()
    var subsets = List[List[Int]]()
    for a in range(len(picks)):
        subsets.append([a])
        for b in range(a + 1, len(picks)):
            subsets.append([a, b])
            for c in range(b + 1, len(picks)):
                subsets.append([a, b, c])
    for chosen in subsets:
        var level_n = List[Int64]()
        var level_d = List[Int64]()
        var ln = List[Int64]()
        var ld = List[Int64]()
        var rn = List[Int64]()
        var rd = List[Int64]()
        var tags = List[Int64]()
        var co = List[Bool]()
        for i in chosen:
            var lo = _twelfth(picks[i][0])
            var hi = _twelfth(picks[i][1])
            level_n.append(1)
            level_d.append(3)
            ln.append(lo[0])
            ld.append(lo[1])
            rn.append(hi[0])
            rd.append(hi[1])
            tags.append(LANDING_RATIONAL_RAY)
            co.append(True)
        var profile = carrier_density_profile(level_n, level_d, ln, ld, rn, rd, tags, co)
        if not (profile.accepted() and profile.depth() == len(chosen)):
            return False
    return True


def _is(value: Q, num: Int64, den: Int64) -> Bool:
    return value.eq(Q(num, den))


def carrier_density_profile_smoke() -> Bool:
    # Basilica alone: one separator, the 4/9 of docs/C1_separated_pair_density.md.
    var one_n: List[Int64] = [1]
    var one_d: List[Int64] = [3]
    var basilica = _levels(one_n, one_d)
    if not (basilica.accepted() and basilica.depth() == 1):
        return False
    if not (_is(basilica.levels[0].density, 4, 9) and _is(basilica.levels[0].decided, 4, 9)):
        return False
    if not (_is(basilica.levels[0].residue, 5, 9) and basilica.levels[0].classes == 2):
        return False

    # Basilica then rabbit: the second level decides 22/147 more, and the
    # residue falls from 5/9 to 179/441.
    var two_n: List[Int64] = [1, 1]
    var two_d: List[Int64] = [3, 7]
    var refined = _levels(two_n, two_d)
    if not (refined.accepted() and refined.depth() == 2 and refined.residue_non_increasing):
        return False
    if not (_is(refined.levels[0].density, 4, 9) and _is(refined.levels[1].density, 262, 441)):
        return False
    if not (_is(refined.levels[1].decided, 22, 147) and _is(refined.levels[1].residue, 179, 441)):
        return False
    if not (refined.levels[1].classes == 3 and refined.levels[1].atoms == 4):
        return False
    if not refined.levels[1].residue.lt(refined.levels[0].residue):
        return False

    # A third level: the airplane wake adds 8/147 and the residue keeps falling.
    var three_n: List[Int64] = [1, 1, 3]
    var three_d: List[Int64] = [3, 7, 7]
    var deeper = _levels(three_n, three_d)
    if not (deeper.accepted() and deeper.depth() == 3 and deeper.residue_non_increasing):
        return False
    if not (_is(deeper.levels[2].density, 286, 441) and _is(deeper.levels[2].decided, 8, 147)):
        return False
    if not deeper.levels[2].residue.lt(deeper.levels[1].residue):
        return False
    # The prefix of a longer carrier is the shorter carrier's profile.
    if not (deeper.levels[0].density.eq(refined.levels[0].density) and deeper.levels[1].density.eq(refined.levels[1].density)):
        return False

    # An empty carrier has an empty profile, and nothing is decided.
    var empty = _levels(List[Int64](), List[Int64]())
    if not (empty.accepted() and empty.depth() == 0):
        return False

    # Fail closed: a length mismatch, a preperiodic level address, a malformed
    # one, and a separator whose two rays coincide.
    var short_n: List[Int64] = [1]
    var short_d: List[Int64] = [3]
    var pair_n: List[Int64] = [1, 2]
    var pair_d: List[Int64] = [3, 3]
    var two_tags: List[Int64] = [LANDING_RATIONAL_RAY, LANDING_RATIONAL_RAY]
    var two_yes: List[Bool] = [True, True]
    if carrier_density_profile(
        short_n, short_d, pair_n, pair_d, pair_n, pair_d, two_tags, two_yes
    ).accepted():
        return False
    var preperiodic_n: List[Int64] = [1]
    var preperiodic_d: List[Int64] = [2]
    if _levels(preperiodic_n, preperiodic_d).accepted():
        return False
    var malformed_n: List[Int64] = [1]
    var malformed_d: List[Int64] = [0]
    if _levels(malformed_n, malformed_d).accepted():
        return False
    var one_tag: List[Int64] = [LANDING_RATIONAL_RAY]
    var one_yes: List[Bool] = [True]
    if carrier_density_profile(
        one_n, one_d, one_n, one_d, one_n, one_d, one_tag, one_yes
    ).accepted():
        return False

    # The admissibility gate itself, which nothing above exercises because
    # every separator above is a declared rational-ray co-landing. The
    # basilica pair is the accepted input of the first case in this function,
    # so only the tag and the co-landing flag differ here.
    var left_n: List[Int64] = [1]
    var left_d: List[Int64] = [3]
    var right_n: List[Int64] = [2]
    var right_d: List[Int64] = [3]
    var generic: List[Int64] = [0]   # not one of the three accepted tags
    var mlc: List[Int64] = [4]       # nor is any other value
    var undeclared: List[Bool] = [False]
    if carrier_density_profile(
        one_n, one_d, left_n, left_d, right_n, right_d, generic, one_yes
    ).accepted():
        return False
    if carrier_density_profile(
        one_n, one_d, left_n, left_d, right_n, right_d, mlc, one_yes
    ).accepted():
        return False
    if carrier_density_profile(
        one_n, one_d, left_n, left_d, right_n, right_d, one_tag, undeclared
    ).accepted():
        return False
    # ... and it is not a gate that refuses everything: the same pair with an
    # accepted tag and a declared co-landing is the 4/9 of the first case.
    var admitted = carrier_density_profile(
        one_n, one_d, left_n, left_d, right_n, right_d, one_tag, one_yes
    )
    if not (admitted.accepted() and _is(admitted.levels[0].density, 4, 9)):
        return False
    if not admissible_separator(LANDING_PARABOLIC, True, 1, 3, 2, 3):
        return False
    if not admissible_separator(LANDING_HYPERBOLIC_BOUNDARY, True, 1, 3, 2, 3):
        return False
    if admissible_separator(LANDING_RATIONAL_RAY, True, 1, 3, 1, 3):
        return False
    # Both identities on every prefix of every small catalogue the sweep draws.
    if not sweep_profiles_accepted():
        return False

    return (
        not profile_decides_carrier_membership()
        and not residue_zero_at_some_level_is_reachable()
        and not density_increment_measures_carrier_progress()
    )
