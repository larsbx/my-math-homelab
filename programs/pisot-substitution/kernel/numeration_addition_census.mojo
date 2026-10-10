"""Addition automata over the corpus, each verified on a bounded domain.

For every sampled specimen: build the linear numeration the substitution
carries, compare its greedy digits with the Dumont-Thomas path digits, and --
where the digit alphabet is small enough to be worth the triple alphabet --
build the addition automaton and check it against the arithmetic it claims to
recognise. Every true sum below the bound must be accepted and every near miss
rejected; a single failure of either kind is printed and counted.

Three outcomes are kept apart, which is the point of the driver. A built and
verified automaton is finite evidence about that specimen. A construction that
exceeds the state cap is a refusal: the Pisot theorem says a finite state set
exists, this exploration did not find one inside the cap, and neither fact is a
verdict about the specimen. A specimen skipped for its alphabet size was never
attempted.

The refusal arrives as a flag on the result, not as an exception, and this
driver catches nothing. Anything that does raise here -- an unsupported
incidence matrix, an arithmetic failure, a defect in this file -- aborts the
census rather than being counted as an inconclusive specimen, because a defect
reported as inconclusive evidence is the one outcome that would make these
counts a lie.

Nothing here decides a coincidence condition or moves a ledger entry
(`docs/automatic-sequence-route-literature-gate-2026-09-17.md`).
"""

from finite_automata.dfa import minimised
from psc.corpus import pip_corpus, report_progress
from psc.dumont_thomas import max_image_length, prolongable_form
from psc.histogram import Histogram, max_int
from psc.linear_numeration import (
    agrees_with_path_digits,
    basis_obeys_recurrence,
    greedy_digits,
    longest_basis,
    max_greedy_digit,
)
from psc.numeration_addition import addition_automaton, triple_word
from psc.oa_overlap_types import prolongable_point

comptime STRIDE = 25
comptime RADIX_CAP = 4
comptime STATE_CAP = 3000
comptime SUM_BOUND = 25
comptime NEAR_MISSES = 3


def main() raises:
    var corpus = pip_corpus()
    var sampled = 0
    var agree = 0
    var differ = 0
    var built = 0
    var refused = 0
    var skipped = 0
    var recurrence_failures = 0
    var sums_checked = 0
    var false_rejects = 0
    var false_accepts = 0
    var largest = 0
    var out_of_domain = 0
    var built_out_of_domain = 0
    var radices = Histogram(32)

    for s in range(0, len(corpus), STRIDE):
        ref spec = corpus[s]
        sampled += 1
        var point = prolongable_point(spec.sigma)
        var tau = prolongable_form(spec.sigma)
        # A substitution made prolongable by a power can have images longer
        # than the overlap kernel's certified domain. Counting them says
        # whether this run exercised the field built for that case at all.
        var powered_past_domain = max_image_length(tau) > 3
        if powered_past_domain:
            out_of_domain += 1
        var u = longest_basis(tau, point.letter, 20)
        if not basis_obeys_recurrence(tau, point.letter, 20):
            recurrence_failures += 1
            print("RECURRENCE MISMATCH", spec.label())
            continue
        if agrees_with_path_digits(tau, point.letter, 120):
            agree += 1
        else:
            differ += 1

        var radix = max_greedy_digit(u, 200) + 1
        radices.record(radix)
        if radix > RADIX_CAP:
            skipped += 1
            continue
        var result = addition_automaton(tau, point.letter, radix, STATE_CAP)
        if not result.accepted():
            refused += 1
        else:
            var add = result.automaton.copy()
            built += 1
            if powered_past_domain:
                built_out_of_domain += 1
            largest = max_int(largest, minimised(add).states())
            for n in range(SUM_BOUND):
                for m in range(SUM_BOUND):
                    sums_checked += 1
                    var true_word = triple_word(
                        radix, greedy_digits(u, n), greedy_digits(u, m),
                        greedy_digits(u, n + m)
                    )
                    if not add.accepts(true_word):
                        false_rejects += 1
                        print("FALSE REJECT", spec.label(), n, "+", m)
                    for offset in range(1, NEAR_MISSES + 1):
                        var false_word = triple_word(
                            radix, greedy_digits(u, n), greedy_digits(u, m),
                            greedy_digits(u, n + m + offset)
                        )
                        if add.accepts(false_word):
                            false_accepts += 1
                            print("FALSE ACCEPT", spec.label(), n, "+", m, "+", offset)
        report_progress(s, len(corpus))

    print("corpus:", len(corpus), " stride:", STRIDE, " sampled:", sampled)
    print("greedy digits equal the path digits:", agree, " differ:", differ)
    print("basis recurrence mismatches:", recurrence_failures)
    print("addition automata built:", built, " refused at the cap:", refused,
          " skipped for alphabet:", skipped)
    print("sums checked:", sums_checked, " false rejects:", false_rejects,
          " false accepts:", false_accepts)
    print("powered images past the certified overlap domain:", out_of_domain,
          " of those, built:", built_out_of_domain)
    print("largest minimised addition automaton:", largest)
    print(radices.line("specimens by digit alphabet"))
