# C1 separated-pair density: the exact angle measure of the pairs a finite
# separator-catalogue prefix already decides.
# This file is terminology-governed by docs/C1_separated_pair_density.md.
# Arithmetic specification: docs/rational-interval-arithmetic-spec.md (binding row
# "finite angle-measure density"): every length, square, and sum is an unbounded
# exact rational; rejection is sticky and no floating point appears.
#
# A catalogue prefix contributes finitely many two-ray separators. Each one is a
# pair of distinct rational ray addresses and splits the external-angle circle
# into the arc between them and its complement, so it assigns every angle a
# side. Two parameters are separated at the prefix exactly when some separator
# puts them on opposite sides, that is, when their side signatures differ. The
# separator endpoints cut the circle into atoms; atoms sharing a signature are
# one undecided class, and under the product of Lebesgue measure on angles
#
#   density = 1 - sum_c |C_c|^2,     residue = sum_c |C_c|^2
#
# over the signature classes C_c. It is the parameter-space analogue of the
# common fraction `f_m` of the PSC overlap route. Endpoints must not be
# flattened into one cut set: disjoint separators leave their outside atoms in
# one class, and treating those atoms as distinct overstates the decided
# measure (separators (0, 1/4) and (1/2, 3/4) give 5/8, not 3/4).
#
# Nothing here decides a named pair: a residue tending to zero would make the
# undecided pairs null, never empty, which is exactly the leak of the theorem
# tag `HarmonicMeasureAlmostEveryFibreTrivial` in
# kernel/mojo/c1/theorem_tags/theorem_tag_import_ledger.mojo.

from finite_exact.rat_q import Q, q_from_bigz
from rational_dynamics.rational import fraction_from_i64


struct SeparatedDensityResult(Copyable, Movable):
    """`density` and `residue` sum to one; `classes` counts the side-signature
    classes and `atoms` the arcs the endpoints cut. A rejected result carries
    no measure.

    `Q` is `Copyable` but not `ImplicitlyCopyable`, so every field assignment
    below copies explicitly."""

    var density: Q
    var residue: Q
    var classes: Int
    var atoms: Int
    var rejected: Bool

    def __init__(out self, density: Q, residue: Q, classes: Int, atoms: Int, rejected: Bool):
        self.density = density.copy()
        self.residue = residue.copy()
        self.classes = classes
        self.atoms = atoms
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


def rejected_density() -> SeparatedDensityResult:
    return SeparatedDensityResult(Q.zero(), Q.zero(), 0, 0, True)


def _address(num: Int64, den: Int64) raises -> Q:
    """A normalized ray address in `[0, 1)` as an exact rational."""
    # `fraction_from_i64` refuses a negative numerator or a non-positive
    # denominator; an address is also below one.
    var addr = fraction_from_i64(num, den)
    if addr.rejected or num >= den:
        raise Error("endpoint is not a normalized ray address")
    var value = q_from_bigz(addr.num, addr.den)
    if not value.accepted():
        raise Error("endpoint is not an accepted rational")
    return value^


def _inserted(cuts: List[Q], value: Q) -> List[Q]:
    """`cuts` with `value` inserted, kept ascending, a repetition dropped."""
    var at = len(cuts)
    for j in range(len(cuts)):
        if value.eq(cuts[j]):
            return cuts.copy()
        if value.lt(cuts[j]):
            at = j
            break
    var next = List[Q]()
    for j in range(at):
        next.append(cuts[j].copy())
    next.append(value.copy())
    for j in range(at, len(cuts)):
        next.append(cuts[j].copy())
    return next^


def _inside(point: Q, low: Q, high: Q) -> Bool:
    """The side a separator with endpoints `low < high` assigns to `point`.
    Which side is called inside is a convention: flipping it complements one
    bit of every signature and leaves the classes, hence the density, alone."""
    return low.lt(point) and point.lt(high)


# Regime correspondence: separated-pair-density
def separated_pair_density(lefts_n: List[Int64], lefts_d: List[Int64], rights_n: List[Int64], rights_d: List[Int64]) -> SeparatedDensityResult:
    """Exact density of the pairs the separators decide. Fails closed on a
    length mismatch, a malformed or out-of-range endpoint, a separator whose
    rays coincide, or atoms whose exact lengths do not sum to one (which no
    accepted input can produce, so it is a kernel self-check)."""
    var count = len(lefts_n)
    if len(lefts_d) != count or len(rights_n) != count or len(rights_d) != count:
        return rejected_density()
    try:
        var lows = List[Q]()
        var highs = List[Q]()
        var cuts = List[Q]()
        for i in range(count):
            var left = _address(lefts_n[i], lefts_d[i])
            var right = _address(rights_n[i], rights_d[i])
            if left.eq(right):
                raise Error("a two-ray separator needs two distinct rays")
            if left.lt(right):
                lows.append(left.copy())
                highs.append(right.copy())
            else:
                lows.append(right.copy())
                highs.append(left.copy())
            cuts = _inserted(cuts, left)
            cuts = _inserted(cuts, right)
        var atoms = len(cuts)
        if atoms < 2:
            # No separator: the circle is one atom and no pair is decided.
            return SeparatedDensityResult(Q.zero(), Q.one(), 1, 1, False)
        var two = Q(2, 1)
        var lengths = List[Q]()
        var mids = List[Q]()
        var total = Q.zero()
        for j in range(atoms):
            var low = cuts[j].copy()
            var high = cuts[0].add(Q.one())
            if j + 1 < atoms:
                high = cuts[j + 1].copy()
            var length = high.sub(low)
            var mid = low.add(high).div(two)
            if not mid.lt(Q.one()):
                mid = mid.sub(Q.one())
            if not (length.accepted() and mid.accepted()):
                return rejected_density()
            total = total.add(length)
            lengths.append(length^)
            mids.append(mid^)
        if not (total.accepted() and total.eq(Q.one())):
            return rejected_density()
        # Group atoms by side signature: atom j joins the first earlier atom
        # that every separator puts on the same side.
        var class_of = List[Int]()
        var class_lengths = List[Q]()
        for j in range(atoms):
            var found = -1
            for k in range(j):
                var same = True
                for s in range(count):
                    if _inside(mids[j], lows[s], highs[s]) != _inside(mids[k], lows[s], highs[s]):
                        same = False
                        break
                if same:
                    found = class_of[k]
                    break
            if found < 0:
                class_of.append(len(class_lengths))
                class_lengths.append(lengths[j].copy())
            else:
                class_of.append(found)
                class_lengths[found] = class_lengths[found].add(lengths[j])
        var residue = Q.zero()
        for c in range(len(class_lengths)):
            residue = residue.add(class_lengths[c].square())
        var density = Q.one().sub(residue)
        if not (density.accepted() and residue.accepted()):
            return rejected_density()
        return SeparatedDensityResult(density, residue, len(class_lengths), atoms, False)
    except:
        return rejected_density()


# --- non-claims ---------------------------------------------------------------


def density_one_implies_every_pair_separated() -> Bool:
    # A null set of undecided pairs is not an empty one. The infinitely
    # renormalizable parameters of docs/C1_residual_directive_carrier.md are
    # the standing example.
    return False


def finite_prefix_density_decides_persistent_non_separation() -> Bool:
    return False


def density_is_harmonic_measure_of_the_boundary() -> Bool:
    # The measure here is Lebesgue measure on external angles, pushed to pairs.
    # Identifying it with harmonic measure on the boundary of M is the imported
    # theorem tag's business, under that tag's hypotheses.
    return False


# --- smoke ------------------------------------------------------------------------


def _is(result: SeparatedDensityResult, num: Int64, den: Int64) -> Bool:
    return result.accepted() and result.density.eq(Q(num, den))


def _eighth(k: Int) -> Tuple[Int64, Int64]:
    """k/8 in lowest terms, with 0 as 0/1."""
    var g = 8
    while k % g != 0:
        g //= 2
    return (Int64(k // g), Int64(8 // g))


def _eighths(chosen: List[Int]) -> SeparatedDensityResult:
    """The prefix of the eighth-separators (k/8, j/8) indexed by `chosen`, k < j in
    lexicographic order: (0,1), (0,2), ..., (0,7), (1,2), ..."""
    var pairs = List[Tuple[Int, Int]]()
    for k in range(8):
        for j in range(k + 1, 8):
            pairs.append((k, j))
    var ln = List[Int64]()
    var ld = List[Int64]()
    var rn = List[Int64]()
    var rd = List[Int64]()
    for i in chosen:
        var lo = _eighth(pairs[i][0])
        var hi = _eighth(pairs[i][1])
        ln.append(lo[0])
        ld.append(lo[1])
        rn.append(hi[0])
        rd.append(hi[1])
    return separated_pair_density(ln, ld, rn, rd)


def refinement_laws_hold() -> Bool:
    """On every prefix of one to three of the first seven eighth-separators:
    density = 1 - residue, 0 <= density <= 1 - 1/classes, and adding any of the
    seven never lowers the density."""
    var subsets = List[List[Int]]()
    for a in range(7):
        subsets.append([a])
        for b in range(a + 1, 7):
            subsets.append([a, b])
            for c in range(b + 1, 7):
                subsets.append([a, b, c])
    for chosen in subsets:
        var here = _eighths(chosen)
        if not here.accepted():
            return False
        if not here.density.eq(Q.one().sub(here.residue)) or here.density.lt(Q.zero()):
            return False
        if Q.one().sub(Q(1, Int64(here.classes))).lt(here.density):
            return False
        for extra in range(7):
            var longer = chosen.copy()
            longer.append(extra)
            if _eighths(longer).density.lt(here.density):
                return False
    return True


def separated_density_smoke() -> Bool:
    # One separator with endpoints 1/3 and 2/3: arcs 1/3 and 2/3 on opposite sides.
    var one_ln: List[Int64] = [1]
    var one_ld: List[Int64] = [3]
    var one_rn: List[Int64] = [2]
    var one_rd: List[Int64] = [3]
    var single = separated_pair_density(one_ln, one_ld, one_rn, one_rd)
    if not (_is(single, 4, 9) and single.classes == 2 and single.atoms == 2 and single.residue.eq(Q(5, 9))):
        return False
    # Reversing the endpoints names the complementary side and changes nothing.
    var flipped = separated_pair_density(one_rn, one_rd, one_ln, one_ld)
    if not (_is(flipped, 4, 9) and flipped.classes == 2):
        return False
    # Two disjoint separators: the two outside atoms stay one undecided class,
    # so the density is 5/8, not the 3/4 a flattened cut set would report.
    var two_ln: List[Int64] = [0, 1]
    var two_ld: List[Int64] = [1, 2]
    var two_rn: List[Int64] = [1, 3]
    var two_rd: List[Int64] = [4, 4]
    var disjoint = separated_pair_density(two_ln, two_ld, two_rn, two_rd)
    if not (_is(disjoint, 5, 8) and disjoint.atoms == 4 and disjoint.classes == 3):
        return False
    if not disjoint.density.lt(Q(3, 4)):
        return False
    # Nested separators of the rabbit wake: three classes of 1/7, 2/7, 4/7.
    var nest_ln: List[Int64] = [1, 2]
    var nest_ld: List[Int64] = [7, 7]
    var nest_rn: List[Int64] = [2, 4]
    var nest_rd: List[Int64] = [7, 7]
    var nested = separated_pair_density(nest_ln, nest_ld, nest_rn, nest_rd)
    if not (_is(nested, 4, 7) and nested.classes == 3 and nested.residue.eq(Q(3, 7))):
        return False
    # Refinement never lowers the density: add the separator 0 to 1/3.
    var more_ln: List[Int64] = [1, 0]
    var more_ld: List[Int64] = [3, 1]
    var more_rn: List[Int64] = [2, 1]
    var more_rd: List[Int64] = [3, 3]
    var refined = separated_pair_density(more_ln, more_ld, more_rn, more_rd)
    if not (_is(refined, 2, 3) and refined.classes == 3):
        return False
    if not single.density.lt(refined.density):
        return False
    # Repeating a separator is not refinement.
    var twice_ln: List[Int64] = [1, 1]
    var twice_ld: List[Int64] = [3, 3]
    var twice_rn: List[Int64] = [2, 2]
    var twice_rd: List[Int64] = [3, 3]
    if not _is(separated_pair_density(twice_ln, twice_ld, twice_rn, twice_rd), 4, 9):
        return False
    # No separator decides nothing.
    var none = separated_pair_density(List[Int64](), List[Int64](), List[Int64](), List[Int64]())
    if not (_is(none, 0, 1) and none.classes == 1 and none.residue.eq(Q.one())):
        return False
    # Fail closed: coincident rays, malformed address, out-of-range address, length mismatch.
    var same_n: List[Int64] = [1]
    var same_d: List[Int64] = [3]
    if separated_pair_density(same_n, same_d, same_n, same_d).accepted():
        return False
    var bad_d: List[Int64] = [0]
    if separated_pair_density(one_ln, bad_d, one_rn, one_rd).accepted():
        return False
    var over_n: List[Int64] = [7]
    var over_d: List[Int64] = [5]
    if separated_pair_density(one_ln, one_ld, over_n, over_d).accepted():
        return False
    if separated_pair_density(two_ln, two_ld, one_rn, one_rd).accepted():
        return False
    var neg_n: List[Int64] = [-1]
    if separated_pair_density(neg_n, one_ld, one_rn, one_rd).accepted():
        return False
    var two_sixths_n: List[Int64] = [2]
    var two_sixths_d: List[Int64] = [6]
    if separated_pair_density(one_ln, one_ld, two_sixths_n, two_sixths_d).accepted():
        return False
    if not refinement_laws_hold():
        return False
    return (
        not density_one_implies_every_pair_separated()
        and not finite_prefix_density_decides_persistent_non_separation()
        and not density_is_harmonic_measure_of_the_boundary()
    )
