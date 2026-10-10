"""Mojo-first legal ancestry towers for the C4 recognizability route.

For a fixed radius R and requested descent height q, a sufficiently deep
zero-return cut can be protected from original source-letter supertile
boundaries by the conservative recurrence

    m_0 = R
    m_(j+1) = (m_j + 1) * L,

where L=max_a |sigma(a)|.

This module is the canonical executable implementation.  It is deliberately
optimized for the standing three-letter regime:
- level-n letter-image lengths are computed by a 3-entry dynamic program;
- source-supertile containment is checked by a streaming cursor, without
  allocating block objects;
- full iterated words are materialized only when the exact zero-return set is
  actually needed.
"""

from psc.bpa import apply_substitution, coincidence_boundaries, sigma3
from psc.words import Pair, is_balanced


struct CutLocation(Copyable, Movable):
    var source_index: Int
    var offset: Int

    def __init__(out self, source_index: Int, offset: Int):
        self.source_index = source_index
        self.offset = offset


def descent_margin(radius: Int, descent_levels: Int, max_image_length: Int) raises -> Int:
    if radius < 0 or descent_levels < 0:
        raise Error("radius and descent_levels must be nonnegative")
    if max_image_length <= 0:
        raise Error("max image length must be positive")
    var margin = radius
    for _ in range(descent_levels):
        margin = (margin + 1) * max_image_length
    return margin


def substitution_max_image_length(sigma: List[List[Int]]) raises -> Int:
    if len(sigma) == 0:
        raise Error("substitution must be nonempty")
    var maximum = 0
    for a in range(len(sigma)):
        if len(sigma[a]) == 0:
            raise Error("substitution must be non-erasing")
        if len(sigma[a]) > maximum:
            maximum = len(sigma[a])
    return maximum


def apply_substitution_n(
    sigma: List[List[Int]], w: List[Int], depth: Int
) raises -> List[Int]:
    if depth < 0:
        raise Error("depth must be nonnegative")
    if depth == 0:
        # sigma is not consulted, so it is not validated: as before.
        return w.copy()
    return sigma3(sigma).apply_n(w, depth)


def image_lengths_at_depth(sigma: List[List[Int]], depth: Int) raises -> List[Int]:
    """Return |sigma^depth(a)| for the fixed three-letter alphabet.

    This is a compact dynamic program: no substituted word is materialized.
    """
    if len(sigma) != 3:
        raise Error("legal tower kernel currently requires three letters")
    if depth < 0:
        raise Error("depth must be nonnegative")
    var lengths: List[Int] = [1, 1, 1]
    for _ in range(depth):
        var next: List[Int] = [0, 0, 0]
        for a in range(3):
            var total = 0
            for j in range(len(sigma[a])):
                total += lengths[sigma[a][j]]
            next[a] = total
        lengths = next^
    return lengths^


def context_inside_source_supertile(
    base_word: List[Int], image_lengths: List[Int], cut: Int, radius: Int
) raises -> Bool:
    """Check radius-R containment by streaming cumulative supertile lengths."""
    if radius < 0:
        raise Error("radius must be nonnegative")
    var total = 0
    for i in range(len(base_word)):
        total += image_lengths[base_word[i]]
    if cut < 0 or cut > total:
        raise Error("cut lies outside source-supertiling")

    var start = 0
    for i in range(len(base_word)):
        var end = start + image_lengths[base_word[i]]
        if start <= cut - radius and cut + radius <= end:
            return True
        start = end
    return False


def locate_in_one_inflation(
    sigma: List[List[Int]], source_word: List[Int], output_cut: Int
) raises -> CutLocation:
    """Canonical completed-source index and within-image offset for one cut."""
    if output_cut < 0:
        raise Error("output cut must be nonnegative")
    var cursor = 0
    for i in range(len(source_word)):
        var next = cursor + len(sigma[source_word[i]])
        if output_cut < next:
            return CutLocation(i, output_cut - cursor)
        cursor = next
    if output_cut == cursor:
        return CutLocation(len(source_word), 0)
    raise Error("output cut lies outside inflated word")


def single_supertile_zero_returns(
    sigma: List[List[Int]], p: Pair, depth: Int, radius: Int
) raises -> List[Int]:
    """Interior zero returns radius-R deep inside one original-letter supertile per side."""
    if depth < 0 or radius < 0:
        raise Error("depth and radius must be nonnegative")
    if not is_balanced(p):
        raise Error("legal-context extraction requires a balanced pair")

    var top = apply_substitution_n(sigma, p.u, depth)
    var bottom = apply_substitution_n(sigma, p.v, depth)
    if len(top) != len(bottom):
        raise Error("balanced iterates have unequal lengths")
    var lengths = image_lengths_at_depth(sigma, depth)
    var returns = coincidence_boundaries(top, bottom)
    var out = List[Int]()
    for i in range(len(returns)):
        var cut = returns[i]
        if cut <= 0 or cut >= len(top):
            continue
        if context_inside_source_supertile(p.u, lengths, cut, radius) and context_inside_source_supertile(
            p.v, lengths, cut, radius
        ):
            out.append(cut)
    return out^


def legal_tower_zero_returns(
    sigma: List[List[Int]],
    p: Pair,
    depth: Int,
    radius: Int,
    descent_levels: Int,
) raises -> List[Int]:
    if descent_levels < 0 or descent_levels > depth:
        raise Error("descent_levels must lie in 0..depth")
    var margin = descent_margin(
        radius, descent_levels, substitution_max_image_length(sigma)
    )
    return single_supertile_zero_returns(sigma, p, depth, margin)


def first_legal_tower_cut(
    sigma: List[List[Int]],
    p: Pair,
    depth: Int,
    radius: Int,
    descent_levels: Int,
) raises -> Int:
    """Return first protected zero return, or -1 when this depth has none."""
    var cuts = legal_tower_zero_returns(sigma, p, depth, radius, descent_levels)
    if len(cuts) == 0:
        return -1
    return cuts[0]


def tower_source_cuts(
    sigma: List[List[Int]],
    p: Pair,
    depth: Int,
    top_cut: Int,
    descent_levels: Int,
) raises -> List[List[Int]]:
    """Return `[top_cut,bottom_cut]` after each requested desubstitution.

    The level words are built once and reused, avoiding repeated expansion of
    the same prefixes during the descent.
    """
    if depth < 1 or descent_levels < 0 or descent_levels > depth:
        raise Error("invalid tower depth/descent_levels")
    if not is_balanced(p):
        raise Error("tower source cuts require a balanced pair")

    var top_levels = List[List[Int]]()
    var bottom_levels = List[List[Int]]()
    top_levels.append(p.u.copy())
    bottom_levels.append(p.v.copy())
    for level in range(1, depth + 1):
        top_levels.append(apply_substitution(sigma, top_levels[level - 1]))
        bottom_levels.append(apply_substitution(sigma, bottom_levels[level - 1]))

    if top_cut < 0 or top_cut > len(top_levels[depth]):
        raise Error("top cut lies outside depth word")
    var top_pos = top_cut
    var bottom_pos = top_cut
    var out = List[List[Int]]()
    for descent in range(descent_levels):
        var level = depth - descent
        var top_loc = locate_in_one_inflation(sigma, top_levels[level - 1], top_pos)
        var bottom_loc = locate_in_one_inflation(sigma, bottom_levels[level - 1], bottom_pos)
        top_pos = top_loc.source_index
        bottom_pos = bottom_loc.source_index
        var pair: List[Int] = [top_pos, bottom_pos]
        out.append(pair^)
    return out^


def verify_legal_tower(
    sigma: List[List[Int]],
    p: Pair,
    depth: Int,
    cut: Int,
    radius: Int,
    descent_levels: Int,
) raises -> Bool:
    """Exact finite verifier for a protected legal tower."""
    if descent_levels < 0 or descent_levels > depth:
        raise Error("descent_levels must lie in 0..depth")
    var protected = legal_tower_zero_returns(sigma, p, depth, radius, descent_levels)
    var found = False
    for i in range(len(protected)):
        if protected[i] == cut:
            found = True
    if not found:
        return False

    var source_cuts = tower_source_cuts(sigma, p, depth, cut, descent_levels)
    for descent in range(descent_levels):
        var source_depth = depth - descent - 1
        var lengths = image_lengths_at_depth(sigma, source_depth)
        if not context_inside_source_supertile(
            p.u, lengths, source_cuts[descent][0], radius
        ):
            return False
        if not context_inside_source_supertile(
            p.v, lengths, source_cuts[descent][1], radius
        ):
            return False
    return True


def tower_count_forces_existence(
    p: Pair,
    total_length: Int,
    max_zero_return_gap: Int,
    radius: Int,
    descent_levels: Int,
    max_image_length: Int,
) raises -> Bool:
    """Safe counting criterion for existence of a protected tower top."""
    if total_length < 0:
        raise Error("total length must be nonnegative")
    if max_zero_return_gap <= 0:
        raise Error("max zero-return gap must be positive")
    var margin = descent_margin(radius, descent_levels, max_image_length)
    var bad_positions = (len(p.u) + len(p.v) + 2) * (2 * margin + 1)
    var zero_return_lower_bound = (
        (total_length + max_zero_return_gap - 1) // max_zero_return_gap + 1
    )
    return zero_return_lower_bound > bad_positions
