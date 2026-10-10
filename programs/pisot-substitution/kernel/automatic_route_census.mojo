"""The Dumont-Thomas numeration against the fixed point, over the corpus.

Three identities per specimen, each between two computations that share no
step:

  letters      the automaton's output at position n, against the fixed point
               prefix produced by substituting;
  positions    admissible digit words of length k, against |tau^k(c)| produced
               by substituting;
  occurrences  digit words ending at a letter, against an entry of the k-th
               power of the incidence matrix.

Agreement is what makes the numeration usable as a presentation of the fixed
point. It is finite evidence over an enumerated domain and nothing more: it
does not decide any first-order statement, and the step that would -- the
recognisability of addition in this numeration -- is an imported theorem, gated
in `docs/automatic-sequence-route-literature-gate-2026-09-17.md`.
"""

from finite_exact.bigint_z import BigZ, bigz_add, bigz_eq, bigz_from_i64, bigz_zero
from finite_linear_algebra.mat3 import Mat3, identity3
from psc.bpa import substitution_incidence
from psc.corpus import pip_corpus, report_progress
from psc.dumont_thomas import (
    image_lengths,
    letter_at,
    max_image_length,
    occurrences_of_length,
    positions_of_length,
    prolongable_form,
)
from psc.histogram import Histogram, max_int
from psc.oa_overlap_types import fixed_point_prefix, prolongable_point

comptime STRIDE = 20
comptime PREFIX = 300
comptime LEVELS = 6


def main() raises:
    var corpus = pip_corpus()
    var sampled = 0
    var letter_checks = 0
    var letter_failures = 0
    var position_failures = 0
    var occurrence_failures = 0
    var radix = Histogram(32)
    var powers = Histogram(8)
    var deepest = 0

    for s in range(0, len(corpus), STRIDE):
        ref spec = corpus[s]
        var point = prolongable_point(spec.sigma)
        var tau = prolongable_form(spec.sigma)
        sampled += 1
        radix.record(max_image_length(tau))
        powers.record(point.power)

        var u = fixed_point_prefix(spec.sigma, point, PREFIX + 1)
        for n in range(PREFIX):
            letter_checks += 1
            if letter_at(tau, point.letter, n) != u[n]:
                letter_failures += 1
                print("LETTER MISMATCH", spec.label(), "at", n)

        var m = Mat3(substitution_incidence(tau))
        var power = identity3()
        for k in range(LEVELS):
            var lengths = image_lengths(tau, k)
            var counted = positions_of_length(tau, point.letter, k)
            if not bigz_eq(counted, bigz_from_i64(Int64(lengths[point.letter]))):
                position_failures += 1
                print("POSITION MISMATCH", spec.label(), "level", k)
            var total = bigz_zero()
            for target in range(3):
                var occurrences = occurrences_of_length(tau, point.letter, target, k)
                if not bigz_eq(occurrences, bigz_from_i64(Int64(power.at(target, point.letter)))):
                    occurrence_failures += 1
                    print("OCCURRENCE MISMATCH", spec.label(), "level", k, "letter", target)
                total = bigz_add(total, occurrences)
            if not bigz_eq(total, counted):
                occurrence_failures += 1
            deepest = max_int(deepest, lengths[point.letter])
            power = power * m
        report_progress(s, len(corpus))

    print("corpus:", len(corpus), " stride:", STRIDE, " sampled:", sampled)
    print("letter positions checked:", letter_checks, " mismatches:", letter_failures)
    print("position-count mismatches:", position_failures)
    print("occurrence-count mismatches:", occurrence_failures)
    print("longest image reached:", deepest)
    print(powers.line("specimens by prolongable power"))
    print(radix.line("specimens by digit radix"))
