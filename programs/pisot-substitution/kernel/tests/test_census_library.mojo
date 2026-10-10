"""Regressions for the shared census library.

Every census and catalogue driver is now a thin survey over `psc.corpus`,
`psc.histogram`, `psc.carrier`, `psc.symmetry` and the defect kernels, so these
tests carry the contracts the drivers rely on: the deterministic corpus order,
the fail-closed histogram, the two edge facts that classify a component, the
relabelling and reversal normal forms, the streaming defect degrees, the
degree-2 trace sieve, and the degree-3 taxonomy that replaced the former
Python catalogue oracle.
"""

from std.testing import assert_equal, assert_false, assert_true

from finite_linear_algebra.mat3 import Mat3
from psc.bpa import build, recurrent_noncoincident_sccs, substitution_incidence
from psc.carrier import (
    carrier_flags,
    has_coincidence_child,
    member_mask,
    productive_within_two,
    profile_component,
    state_sync,
)
from mojo_smoke.claims import require_claim
from psc.corpus import (
    MAX_IMAGE_LENGTH,
    REGIME_NONUNIMODULAR,
    REGIME_UNIMODULAR_COMPLEX,
    REGIME_UNIMODULAR_REAL,
    arithmetic_regime,
    TOTAL_LENGTH_CAP,
    cubic_discriminant,
    image_words,
    image_words_up_to,
    pip_corpus,
    pip_corpus_total_length,
    substitution_of,
    words_of_length,
)
from psc.pisot import CubicScreen, is_pip
from psc.defect_degree import (
    DEGREE_FIVE_PLUS,
    DEGREE_THREE,
    DEGREE_TWO,
    first_defect_degree,
    is_degree3,
    k4,
    n4,
)
from psc.degree2_sieve import (
    first_trace_failure,
    parity_allows_three_states,
    survives_through,
    traces_exterior,
    traces_standard,
)
from psc.degree3_taxonomy import Degree3Row, Degree3Summary, commutes_with_theta
from psc.histogram import Histogram, max_int, min_int
from psc.symmetry import (
    canonical_pair,
    canonical_substitution,
    conjugated_substitution,
    inverse_permutation,
    normalised_pair,
    parse_substitution_key,
    permutations,
    permutations3,
    relabel,
    reversed_pair,
    reversed_substitution,
    reversed_word,
    substitution_key,
    word_key,
    word_less,
)
from psc.words import Pair, is_zero, k2, k3


def tribonacci() raises -> List[List[Int]]:
    return parse_substitution_key("01/02/0")


def test_the_candidate_images_are_the_short_words_in_order() raises:
    var words = image_words()
    assert_equal(len(words), 3 + 9 + 27)
    assert_equal(word_key(words[0]), "0")
    assert_equal(word_key(words[2]), "2")
    assert_equal(word_key(words[3]), "00")
    assert_equal(word_key(words[12]), "000")
    assert_equal(word_key(words[38]), "222")
    # The order is by length first, then lexicographically inside a length.
    for i in range(1, len(words)):
        assert_true(len(words[i - 1]) <= len(words[i]))
        assert_true(len(words[i]) <= MAX_IMAGE_LENGTH)
        if len(words[i - 1]) == len(words[i]):
            assert_true(word_less(words[i - 1], words[i]))
    assert_equal(len(words_of_length(2)), 9)
    assert_equal(substitution_key(substitution_of(words, 0, 1, 2)), "0/1/2")


def test_the_arithmetic_regime_splits_by_determinant_and_discriminant() raises:
    var trib = Mat3(substitution_incidence(tribonacci()))
    assert_equal(abs(trib.det()), 1)
    assert_equal(arithmetic_regime(trib), REGIME_UNIMODULAR_COMPLEX)
    assert_true(cubic_discriminant(trib.charpoly()) < 0)

    var tau = Mat3(substitution_incidence(parse_substitution_key("1/021/001")))
    assert_true(abs(tau.det()) != 1)
    assert_equal(arithmetic_regime(tau), REGIME_NONUNIMODULAR)

    # x^3 - 2x^2 - x + 1 has three real roots, so a positive discriminant.
    var three_real: List[Int] = [1, -1, -2, 1]
    assert_true(cubic_discriminant(three_real) > 0)


def test_the_histogram_reports_its_keys_and_fails_closed() raises:
    var h = Histogram(4)
    h.record(0)
    h.record(3)
    h.record(3)
    assert_equal(h.count(3), 2)
    assert_equal(h.count(1), 0)
    assert_equal(h.maximum(), 3)
    assert_equal(h.total(), 3)
    assert_equal(h.line("keys:"), "keys: 0:1 3:2")
    assert_equal(Histogram(4).maximum(), 0)

    var overflowed = False
    try:
        h.record(4)
    except:
        overflowed = True
    assert_true(overflowed)
    var negative = False
    try:
        h.record(-1)
    except:
        negative = True
    assert_true(negative)
    assert_equal(max_int(2, 5), 5)
    assert_equal(min_int(2, 5), 2)


def test_a_component_is_classified_by_its_two_edge_facts() raises:
    var sigma = tribonacci()
    var a = build(sigma, 20000)
    var comps = recurrent_noncoincident_sccs(a)
    assert_true(len(comps) > 0)
    var flags = carrier_flags(a, comps)
    for ci in range(len(comps)):
        var shape = profile_component(a, comps[ci])
        assert_equal(shape.size, len(comps[ci]))
        # On this corpus every recurrent component leaks a coincidence, so no
        # component is a strict carrier and each sink is productive.
        assert_true(shape.direct_coincidence)
        assert_false(shape.is_closed_nonproductive())
        assert_equal(shape.is_sink(), not shape.noncoincident_exit)
        var mask = member_mask(a.size(), comps[ci])
        for s in range(len(comps[ci])):
            assert_true(mask[comps[ci][s]])
            assert_true(flags.recurrent[comps[ci][s]])
            assert_equal(flags.sink[comps[ci][s]], shape.is_sink())
            var state = comps[ci][s]
            if has_coincidence_child(a, state):
                assert_true(productive_within_two(a, state))

    var sync = state_sync(sigma, a.states[0])
    assert_true(sync.any() == (sync.newborn or sync.inherited))
    assert_equal(sync.clean_newborn(), sync.newborn and not sync.inherited)
    assert_true(sync.join(sync).newborn == sync.newborn)


def test_relabelling_and_reversal_normal_forms() raises:
    assert_equal(len(permutations3()), 6)
    assert_equal(len(permutations(4)), 24)
    assert_equal(word_key(permutations(3)[0]), "012")
    assert_equal(word_key(inverse_permutation([1, 2, 0])), "201")
    var perm: List[Int] = [1, 2, 0]
    assert_equal(word_key(relabel([0, 0, 2], perm)), "110")
    assert_equal(word_key(reversed_word([0, 1, 2])), "210")

    var u: List[Int] = [1, 0]
    var v: List[Int] = [0, 1]
    assert_equal(normalised_pair(u, v).key(), "01|10")
    assert_equal(canonical_pair(Pair(u, v)).key(), "01|10")
    assert_equal(reversed_pair(Pair(u, v)).key(), "01|10")

    var sigma = parse_substitution_key("011/2/120")
    assert_equal(substitution_key(sigma), "011/2/120")
    assert_equal(substitution_key(canonical_substitution(sigma)), "011/2/120")
    assert_equal(substitution_key(reversed_substitution(sigma)), "110/2/021")
    # Conjugating by a permutation and by its inverse returns the original.
    var conjugated = conjugated_substitution(sigma, perm)
    assert_equal(substitution_key(conjugated_substitution(conjugated, inverse_permutation(perm))), "011/2/120")
    # Relabelling does not change the canonical representative.
    for p in range(len(permutations3())):
        var image = conjugated_substitution(sigma, permutations3()[p])
        assert_equal(substitution_key(canonical_substitution(image)), "011/2/120")

    var malformed = False
    try:
        _ = parse_substitution_key("01/2")
    except:
        malformed = True
    assert_true(malformed)


def test_the_defect_degree_is_the_first_nonvanishing_invariant() raises:
    var swap_u: List[Int] = [0, 1]
    var swap_v: List[Int] = [1, 0]
    var swap = Pair(swap_u, swap_v)
    assert_equal(first_defect_degree(swap), DEGREE_TWO)
    assert_false(is_zero(k2(swap)))
    assert_false(is_degree3(swap))

    var same: List[Int] = [0, 1, 2]
    var coincidence = Pair(same, same)
    assert_equal(first_defect_degree(coincidence), DEGREE_FIVE_PLUS)
    assert_true(is_zero(k4(coincidence)))

    # N4 counts the scattered subwords of length four, so the only length-four
    # subword of a four-letter word is the word itself.
    var word: List[Int] = [0, 1, 2, 0]
    var counts = n4(word)
    var total = 0
    for i in range(len(counts)):
        total += counts[i]
    assert_equal(len(counts), 81)
    assert_equal(total, 1)
    assert_equal(counts[27 * 0 + 9 * 1 + 3 * 2 + 0], 1)


def test_the_degree_two_trace_sieve_is_exact() raises:
    # Tribonacci: chi(x) = x^3 - x^2 - x - 1, so (T, U, D) = (1, -1, 1).
    var trib = Mat3(substitution_incidence(tribonacci()))
    var chi = trib.charpoly()
    var t = -chi[2]
    var u = chi[1]
    var d = -chi[0]
    assert_equal(t, 1)
    assert_equal(u, -1)
    assert_equal(d, 1)
    assert_true(parity_allows_three_states(t, u, d))

    var p = traces_standard(t, u, d, 4)
    var q = traces_exterior(t, u, d, 4)
    assert_equal(p[0], 3)
    assert_equal(p[1], t)
    assert_equal(p[2], t * t - 2 * u)
    assert_equal(q[1], u)
    # tr(M^k) follows Newton's recurrence in (T, U, D).
    assert_equal(p[3], t * p[2] - u * p[1] + d * p[0])
    assert_equal(p[4], t * p[3] - u * p[2] + d * p[1])

    assert_equal(first_trace_failure(t, u, d, 12), 0)
    assert_true(survives_through(0, 12))
    assert_true(survives_through(7, 6))
    assert_false(survives_through(7, 7))
    # A cubic whose exterior square out-traces it fails at the first power.
    assert_equal(first_trace_failure(1, 3, 1, 12), 1)


def test_the_degree_three_taxonomy_reproduces_the_known_orbit() raises:
    """The 24 catalogue rows come from two substitution conjugacy classes; the
    taxonomy must recover both, their four state relabelling classes, and the
    closure of each under reversal."""
    var rows = List[Degree3Row]()
    var bases: List[String] = ["011/2/120", "1/210/002"]
    var perms = permutations3()
    var seen = Dict[String, Bool]()
    for b in range(len(bases)):
        var base = parse_substitution_key(bases[b])
        for p in range(len(perms)):
            var sigma = conjugated_substitution(base, perms[p])
            if substitution_key(sigma) in seen:
                continue
            seen[substitution_key(sigma)] = True
            var a = build(sigma, 20000)
            var comps = recurrent_noncoincident_sccs(a)
            var flags = carrier_flags(a, comps)
            var m = Mat3(substitution_incidence(sigma))
            for v in range(a.size()):
                ref state = a.states[v]
                if state.is_coincidence() or not is_degree3(state):
                    continue
                assert_true(is_zero(k2(state)))
                assert_false(is_zero(k3(state)))
                assert_equal(first_defect_degree(state), DEGREE_THREE)
                rows.append(
                    Degree3Row(
                        sigma, state, flags.recurrent[v], flags.sink[v],
                        commutes_with_theta(m, state), productive_within_two(a, v),
                    )
                )

    var summary = Degree3Summary(rows)
    assert_equal(summary.occurrences, 24)
    assert_equal(len(summary.state_classes), 4)
    assert_equal(len(summary.sigma_classes), 2)
    assert_equal(word_key(summary.lengths), "919")
    assert_equal(summary.seed_orbit_matches, 0)
    assert_true(summary.state_reversal_closed)
    assert_true(summary.sigma_reversal_closed)
    assert_equal(summary.centralizer_hits, 0)
    assert_equal(summary.theta_absdet2, 24)
    assert_equal(summary.theta_trace_sq6, 24)
    assert_equal(summary.length9_single_d3_successor, 12)
    assert_equal(summary.length19_five_child_one_coincidence, 12)
    assert_equal(summary.productive_within_two, 24)
    assert_equal(summary.charpoly_line(), "-1,0,-2,1")
    assert_equal(summary.sigma_classes[0], "011/2/120")
    assert_equal(summary.sigma_classes[1], "1/210/002")
    assert_equal(summary.state_classes[2], "011202001|120001120")


def test_the_memoized_screen_accepts_exactly_what_is_pip_accepts() raises:
    """`CubicScreen` against `is_pip` on a stride through the candidate space.

    The screen memoizes irreducibility and the Pisot test by characteristic
    cubic, which is sound because both are functions of that cubic alone,
    while primitivity stays a per-matrix test. The claim is exact agreement,
    not agreement in aggregate, so the comparison is verdict by verdict; the
    stride keeps the test to a seventh of the 59,319 candidates rather than
    all of them, and `pip_corpus` covers the rest by its own pinned size. The
    stride is 7 because it is coprime to the 39 images: a stride sharing a
    factor with the innermost range would sample the same few images of the
    third letter over and over, which is how a sieve like this quietly stops
    testing anything.

    The distinct-cubic count is the reason the memo is worth having: the
    candidates that reach a cubic at all carry far fewer cubics than
    candidates, so the exact decision procedure runs once per question instead
    of once per asking.
    """
    var words = image_words()
    var screen = CubicScreen()
    var compared = 0
    var accepted = 0
    var step = 0
    for i in range(len(words)):
        for j in range(len(words)):
            for k in range(len(words)):
                step += 1
                if step % 7 != 0:
                    continue
                var m = Mat3(substitution_incidence(substitution_of(words, i, j, k)))
                var memoized = screen.is_pip(m)
                assert_equal(memoized, is_pip(m))
                assert_equal(memoized, screen.is_pip(m))    # a repeat is not a new verdict
                compared += 1
                if memoized:
                    accepted += 1
    assert_equal(compared, 8474)
    assert_equal(accepted, 633)
    # 174 distinct cubics behind 8,474 candidates, and 177 behind all 59,319:
    # the memo is worth having because that ratio is the whole point of it.
    assert_equal(screen.distinct_cubics(), 174)


def test_the_corpus_is_the_screened_corpus() raises:
    """The corpus a memoized screen builds is the pinned one, in order."""
    var corpus = pip_corpus()
    assert_equal(len(corpus), 4554)
    for s in range(len(corpus)):
        assert_equal(corpus[s].index, s)
        assert_true(is_pip(Mat3(substitution_incidence(corpus[s].sigma))))


def test_the_long_images_extend_the_short_images_in_order() raises:
    """Indices into `image_words` stay valid in the longer list, so a standing
    specimen keeps its `i j k` label in the total-length corpus."""
    var short = image_words()
    var long = image_words_up_to(TOTAL_LENGTH_CAP - 2)
    assert_equal(len(long), 3 + 9 + 27 + 81 + 243 + 729)
    for i in range(len(short)):
        assert_equal(word_key(long[i]), word_key(short[i]))
    for i in range(1, len(long)):
        assert_true(len(long[i - 1]) <= len(long[i]))
        if len(long[i - 1]) == len(long[i]):
            assert_true(word_less(long[i - 1], long[i]))


def test_the_total_length_corpus_contains_the_standing_corpus() raises:
    """24486 PIP specimens with total image length at most 8; slicing by the
    longest image gives 72 / 4554 / 14670 / 22080 / 24486, and the slice at 3
    is the standing corpus, label for label and in order."""
    var corpus = pip_corpus_total_length(TOTAL_LENGTH_CAP)
    var standing = pip_corpus()
    assert_equal(len(corpus), 24486)
    var slices = List[Int](length=TOTAL_LENGTH_CAP - 1, fill=0)
    var seen = 0
    for s in range(len(corpus)):
        ref spec = corpus[s]
        assert_equal(spec.index, s)
        assert_true(
            len(spec.sigma[0]) + len(spec.sigma[1]) + len(spec.sigma[2])
            <= TOTAL_LENGTH_CAP
        )
        assert_true(is_pip(Mat3(substitution_incidence(spec.sigma))))
        var longest = spec.longest_image()
        slices[longest] += 1
        if longest <= MAX_IMAGE_LENGTH:
            assert_equal(spec.label(), standing[seen].label())
            seen += 1
    assert_equal(seen, len(standing))
    var cumulative = 0
    var expected: List[Int] = [0, 0, 72, 4554, 14670, 22080, 24486]
    for longest in range(1, TOTAL_LENGTH_CAP - 1):
        cumulative += slices[longest]
        assert_equal(cumulative, expected[longest])


def main() raises:
    test_the_candidate_images_are_the_short_words_in_order()
    print("[PASS] test_the_candidate_images_are_the_short_words_in_order")
    test_the_arithmetic_regime_splits_by_determinant_and_discriminant()
    print("[PASS] test_the_arithmetic_regime_splits_by_determinant_and_discriminant")
    test_the_histogram_reports_its_keys_and_fails_closed()
    print("[PASS] test_the_histogram_reports_its_keys_and_fails_closed")
    test_a_component_is_classified_by_its_two_edge_facts()
    print("[PASS] test_a_component_is_classified_by_its_two_edge_facts")
    test_relabelling_and_reversal_normal_forms()
    print("[PASS] test_relabelling_and_reversal_normal_forms")
    test_the_defect_degree_is_the_first_nonvanishing_invariant()
    print("[PASS] test_the_defect_degree_is_the_first_nonvanishing_invariant")
    test_the_degree_two_trace_sieve_is_exact()
    print("[PASS] test_the_degree_two_trace_sieve_is_exact")
    test_the_degree_three_taxonomy_reproduces_the_known_orbit()
    print("[PASS] test_the_degree_three_taxonomy_reproduces_the_known_orbit")
    test_the_memoized_screen_accepts_exactly_what_is_pip_accepts()
    print("[PASS] test_the_memoized_screen_accepts_exactly_what_is_pip_accepts")
    test_the_corpus_is_the_screened_corpus()
    print("[PASS] test_the_corpus_is_the_screened_corpus")
    test_the_long_images_extend_the_short_images_in_order()
    print("[PASS] test_the_long_images_extend_the_short_images_in_order")
    test_the_total_length_corpus_contains_the_standing_corpus()
    print("[PASS] test_the_total_length_corpus_contains_the_standing_corpus")
    print("12 census-library tests passed.")
    require_claim("BoundedDegree3Exclusion")
    require_claim("BoundedDegree2WedgeProductivity")
    require_claim("ParitySieve")
    require_claim("DefectIntertwiner")
