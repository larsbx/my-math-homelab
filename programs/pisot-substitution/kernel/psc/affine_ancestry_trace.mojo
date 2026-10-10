"""Exact order-sensitive affine ancestry traces for the open G1b-2 gate.

For a relative renewal address let q_t be the difference between the Parikh
vectors of the proper prefixes preceding the selected top and bottom children
at ancestry level t. The exact recurrence x_(t+1) = M x_t + q_t starts at the
source defect and ends at zero. This is finite diagnostic machinery, not a
proof that the trace has finitely many states uniformly over all returns.
"""

from psc.renewal import Diff3
from psc.renewal_address import RelativeRenewalAddress


struct AffineTraceTables(Copyable, Movable):
    """Substitution-local incidence and proper-prefix Parikh tables."""

    var sigma: List[List[Int]]
    var incidence: List[Int]
    var prefix_offsets: List[Int]
    var prefix_parikhs: List[Int]

    def __init__(out self, sigma: List[List[Int]], incidence: List[Int], prefix_offsets: List[Int], prefix_parikhs: List[Int]):
        self.sigma = sigma.copy()
        self.incidence = incidence.copy()
        self.prefix_offsets = prefix_offsets.copy()
        self.prefix_parikhs = prefix_parikhs.copy()


struct AffineAncestryTrace(Copyable, Movable):
    var top_letters: List[Int]
    var bottom_letters: List[Int]
    var defects: List[Int]

    def __init__(out self, top_letters: List[Int], bottom_letters: List[Int], defects: List[Int]):
        self.top_letters = top_letters.copy()
        self.bottom_letters = bottom_letters.copy()
        self.defects = defects.copy()

    def state_count(self) -> Int:
        return len(self.top_letters)

    def depth(self) -> Int:
        return self.state_count() - 1

    def defect_at(self, level: Int) raises -> Diff3:
        if level < 0 or level >= self.state_count():
            raise Error("affine-trace level is out of range")
        var k = 3 * level
        return Diff3(self.defects[k], self.defects[k + 1], self.defects[k + 2])

    def closes(self) raises -> Bool:
        return self.defect_at(self.depth()).is_zero()


def _validate_sigma(sigma: List[List[Int]]) raises:
    if len(sigma) != 3:
        raise Error("affine trace requires a three-letter substitution")
    for a in range(3):
        if len(sigma[a]) == 0:
            raise Error("affine trace requires a non-erasing substitution")
        for j in range(len(sigma[a])):
            if sigma[a][j] < 0 or sigma[a][j] >= 3:
                raise Error("affine-trace substitution letter lies outside 0..2")


def build_affine_trace_tables(sigma: List[List[Int]]) raises -> AffineTraceTables:
    _validate_sigma(sigma)
    var incidence: List[Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var offsets: List[Int] = [0]
    var prefixes = List[Int]()
    for parent in range(3):
        var x = 0
        var y = 0
        var z = 0
        for j in range(len(sigma[parent])):
            prefixes.append(x)
            prefixes.append(y)
            prefixes.append(z)
            var child = sigma[parent][j]
            incidence[3 * child + parent] += 1
            if child == 0:
                x += 1
            elif child == 1:
                y += 1
            else:
                z += 1
        offsets.append(len(prefixes) // 3)
    return AffineTraceTables(sigma, incidence, offsets, prefixes)


def _incidence_action(tables: AffineTraceTables, x: Diff3) -> Diff3:
    return Diff3(
        tables.incidence[0] * x.x + tables.incidence[1] * x.y + tables.incidence[2] * x.z,
        tables.incidence[3] * x.x + tables.incidence[4] * x.y + tables.incidence[5] * x.z,
        tables.incidence[6] * x.x + tables.incidence[7] * x.y + tables.incidence[8] * x.z,
    )


def _prefix_parikh(tables: AffineTraceTables, parent: Int, child_index: Int) raises -> Diff3:
    if parent < 0 or parent >= 3:
        raise Error("affine-trace parent letter lies outside 0..2")
    if child_index < 0 or child_index >= len(tables.sigma[parent]):
        raise Error("affine-trace child index lies outside parent image")
    var k = 3 * (tables.prefix_offsets[parent] + child_index)
    return Diff3(tables.prefix_parikhs[k], tables.prefix_parikhs[k + 1], tables.prefix_parikhs[k + 2])


def affine_ancestry_trace_with_tables(tables: AffineTraceTables, address: RelativeRenewalAddress) raises -> AffineAncestryTrace:
    if address.level <= 0:
        raise Error("affine trace requires a positive address level")
    if len(address.top_digits) != 2 * address.level or len(address.bottom_digits) != 2 * address.level:
        raise Error("affine-trace digit length does not match address level")
    var top_letters = List[Int]()
    var bottom_letters = List[Int]()
    var defects = List[Int]()
    var top = address.top_source_letter
    var bottom = address.bottom_source_letter
    var x = address.source_defect.copy()
    if x.x + x.y + x.z != address.source_index_delta:
        raise Error("affine-trace source displacement/defect identity failed")
    var scaled = address.source_defect.copy()
    var correction = Diff3(0, 0, 0)
    top_letters.append(top)
    bottom_letters.append(bottom)
    defects.append(x.x)
    defects.append(x.y)
    defects.append(x.z)
    for t in range(address.level):
        var top_parent = address.top_digits[2 * t]
        var top_index = address.top_digits[2 * t + 1]
        var bottom_parent = address.bottom_digits[2 * t]
        var bottom_index = address.bottom_digits[2 * t + 1]
        if top_parent != top or bottom_parent != bottom:
            raise Error("affine-trace digits do not follow substitution paths")
        var tp = _prefix_parikh(tables, top_parent, top_index)
        var bp = _prefix_parikh(tables, bottom_parent, bottom_index)
        scaled = _incidence_action(tables, scaled)
        correction = _incidence_action(tables, correction)
        correction.x += tp.x - bp.x
        correction.y += tp.y - bp.y
        correction.z += tp.z - bp.z
        var next = _incidence_action(tables, x)
        next.x += tp.x - bp.x
        next.y += tp.y - bp.y
        next.z += tp.z - bp.z
        top = tables.sigma[top_parent][top_index]
        bottom = tables.sigma[bottom_parent][bottom_index]
        x = next.copy()
        top_letters.append(top)
        bottom_letters.append(bottom)
        defects.append(x.x)
        defects.append(x.y)
        defects.append(x.z)
    if scaled != address.scaled_defect:
        raise Error("affine trace disagrees with stored scaled defect")
    if correction != address.correction:
        raise Error("affine trace disagrees with stored correction")
    var trace = AffineAncestryTrace(top_letters, bottom_letters, defects)
    if not trace.closes():
        raise Error("affine ancestry recurrence does not close at the renewal cut")
    return trace^


def affine_ancestry_trace(sigma: List[List[Int]], address: RelativeRenewalAddress) raises -> AffineAncestryTrace:
    """Convenience wrapper; census callers should reuse precomputed tables."""
    var tables = build_affine_trace_tables(sigma)
    return affine_ancestry_trace_with_tables(tables, address)


def same_affine_state(a: AffineAncestryTrace, ai: Int, b: AffineAncestryTrace, bi: Int) raises -> Bool:
    if ai < 0 or ai >= a.state_count() or bi < 0 or bi >= b.state_count():
        raise Error("affine-state comparison index is out of range")
    return a.top_letters[ai] == b.top_letters[bi] and a.bottom_letters[ai] == b.bottom_letters[bi] and a.defect_at(ai) == b.defect_at(bi)


def common_terminal_trace_length(a: AffineAncestryTrace, b: AffineAncestryTrace) raises -> Int:
    var count = 0
    var ai = a.state_count() - 1
    var bi = b.state_count() - 1
    while ai >= 0 and bi >= 0 and same_affine_state(a, ai, b, bi):
        count += 1
        ai -= 1
        bi -= 1
    return count


def is_affine_pump_extension(
    longer: AffineAncestryTrace, shorter: AffineAncestryTrace
) raises -> Bool:
    """Whether deleting an initial exact state loop gives `shorter`.

    This certifies equality of the entire retained paired-state suffix.  It
    does not by itself prove that deletion preserves global realizability.
    """
    var excess = longer.depth() - shorter.depth()
    if excess <= 0:
        return False
    if not same_affine_state(longer, 0, longer, excess):
        return False
    if shorter.state_count() != longer.state_count() - excess:
        return False
    for i in range(shorter.state_count()):
        if not same_affine_state(longer, excess + i, shorter, i):
            return False
    return True


def first_repeated_affine_state(trace: AffineAncestryTrace) raises -> Tuple[Int, Int]:
    for right in range(1, trace.state_count()):
        for left in range(right):
            if same_affine_state(trace, left, trace, right):
                return (left, right)
    return (-1, -1)


def first_proper_repeated_affine_state(
    trace: AffineAncestryTrace
) raises -> Tuple[Int, Int]:
    """First repeat with both endpoints strictly inside the trace."""
    for right in range(2, trace.depth()):
        for left in range(1, right):
            if same_affine_state(trace, left, trace, right):
                return (left, right)
    return (-1, -1)


def proper_affine_splice_matches_certified_address(
    tables: AffineTraceTables,
    longer: RelativeRenewalAddress,
    shorter: RelativeRenewalAddress,
    start: Int,
    end: Int,
) raises -> Bool:
    """Check a proper repeated-state deletion against a certified address.

    Both input traces and all their stored certificates are independently
    validated first. Equality includes source data and every retained ordered
    top/bottom digit. This certifies an exact symbolic address splice; it does
    not assert that arbitrary splices preserve global occurrence context.
    """
    var long_trace = affine_ancestry_trace_with_tables(tables, longer)
    _ = affine_ancestry_trace_with_tables(tables, shorter)
    if start <= 0 or end <= start or end >= long_trace.depth():
        return False
    if not same_affine_state(long_trace, start, long_trace, end):
        return False
    if shorter.level != longer.level - (end - start):
        return False
    if (
        shorter.source_index_delta != longer.source_index_delta
        or shorter.source_defect != longer.source_defect
        or shorter.top_source_letter != longer.top_source_letter
        or shorter.bottom_source_letter != longer.bottom_source_letter
    ):
        return False
    var short_level = 0
    for long_level in range(longer.level):
        if long_level >= start and long_level < end:
            continue
        if (
            shorter.top_digits[2 * short_level] != longer.top_digits[2 * long_level]
            or shorter.top_digits[2 * short_level + 1] != longer.top_digits[2 * long_level + 1]
            or shorter.bottom_digits[2 * short_level] != longer.bottom_digits[2 * long_level]
            or shorter.bottom_digits[2 * short_level + 1] != longer.bottom_digits[2 * long_level + 1]
        ):
            return False
        short_level += 1
    return short_level == shorter.level
