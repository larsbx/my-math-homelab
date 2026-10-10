"""Barge-Diamond endpoint-pair eliminator for alphabet-3 strict PIP SCCs.

The finite combinatorics here are exact.  The mathematical bridge uses
Barge-Diamond (2002), Theorem 1: a Pisot substitution has at least one pair of
distinct letters whose unit segments are eventually coincident.

For a strict nonproductive balanced-pair state, the unordered pair of first
letters cannot be eventually coincident.  Under the deterministic first-child
selector that pair evolves by the prefix endpoint map.  A type-G endpoint map
is a 3-cycle on letters and acts transitively on the three unordered distinct
letter pairs, so one bad pair would force all three pairs to be bad, contradicting
Barge-Diamond.  Types A/B are already excluded by the globally synchronizing
endpoint theorem.  Thus only C/D/E/F remain admissible on either side; the
suffix statement is the prefix statement for the reversed substitution.

Choosing any one Barge-Diamond-good pair also gives a fixed hub letter: every
strict right-boundary pair must contain the third letter complementary to that
good pair.  The helpers below expose this finite star-shaped normal form for the
next parity/cocycle stage.
"""

from psc.endpoint_core import endpoint_type


def _validate_letter(a: Int) raises:
    if a < 0 or a >= 3:
        raise Error("letter lies outside 0..2")


def _validate_endpoint_map(h: List[Int]) raises:
    if len(h) != 3:
        raise Error("endpoint map must have exactly three letters")
    for i in range(3):
        _validate_letter(h[i])


def unordered_pair_id(a: Int, b: Int) raises -> Int:
    """Encode {0,1},{0,2},{1,2} as 0,1,2."""
    _validate_letter(a)
    _validate_letter(b)
    if a == b:
        raise Error("unordered pair requires distinct letters")
    var lo = a
    var hi = b
    if lo > hi:
        var tmp = lo
        lo = hi
        hi = tmp
    if lo == 0 and hi == 1:
        return 0
    if lo == 0 and hi == 2:
        return 1
    return 2


def complementary_hub_letter(good_a: Int, good_b: Int) raises -> Int:
    """Third letter outside one distinct Barge-Diamond-good pair."""
    _ = unordered_pair_id(good_a, good_b)
    return 3 - good_a - good_b


def avoids_good_pair_and_contains_hub(
    good_a: Int, good_b: Int, x: Int, y: Int
) raises -> Bool:
    """Finite star condition for a distinct strict boundary pair.

    If {good_a,good_b} is eventually coincident, a strict boundary pair must
    avoid that edge.  On three letters every other distinct edge contains the
    complementary hub letter.
    """
    var good_id = unordered_pair_id(good_a, good_b)
    var pair_id = unordered_pair_id(x, y)
    if pair_id == good_id:
        return False
    var hub = complementary_hub_letter(good_a, good_b)
    return x == hub or y == hub


def pair_orbit_mask(h: List[Int], a: Int, b: Int) raises -> Int:
    """Bit mask of distinct unordered pairs visited before coalescence/repeat.

    Bits 0,1,2 correspond to {0,1},{0,2},{1,2}.  Four iterations suffice on
    three unordered pairs; a repeated pair has entered its eventual cycle.
    """
    _validate_endpoint_map(h)
    _validate_letter(a)
    _validate_letter(b)
    if a == b:
        return 0
    var x = a
    var y = b
    var mask = 0
    for _ in range(4):
        if x == y:
            return mask
        var bit = 1 << unordered_pair_id(x, y)
        if (mask & bit) != 0:
            return mask
        mask |= bit
        x = h[x]
        y = h[y]
    return mask


def pair_orbit_coalesces(h: List[Int], a: Int, b: Int) raises -> Bool:
    """Whether the endpoint-map orbits of a,b meet."""
    _validate_endpoint_map(h)
    _validate_letter(a)
    _validate_letter(b)
    var x = a
    var y = b
    for _ in range(8):
        if x == y:
            return True
        x = h[x]
        y = h[y]
    return False


def type_g_pair_action_is_transitive(h: List[Int]) raises -> Bool:
    """Exact finite check: every distinct pair visits all three pair types."""
    _validate_endpoint_map(h)
    if endpoint_type(h) != 6:
        return False
    return (
        pair_orbit_mask(h, 0, 1) == 7
        and pair_orbit_mask(h, 0, 2) == 7
        and pair_orbit_mask(h, 1, 2) == 7
    )


def strict_pip_endpoint_type_admissible(h: List[Int]) raises -> Bool:
    """Necessary endpoint-type condition for an alphabet-3 strict PIP SCC.

    A/B fail by global endpoint synchronization; G fails by Barge-Diamond plus
    first-child pair-orbit transitivity.  C/D/E/F are not claimed realizable;
    they merely survive these two eliminators.
    """
    _validate_endpoint_map(h)
    var t = endpoint_type(h)
    return t >= 2 and t <= 5
