"""Return lattices of radius-`n` patches over the PIP corpus, exactly.

For **every** specimen and every order `n = 1..MAX_ORDER` this computes
`[Z^3 : Lambda_n]`, where `Lambda_n` is the span of the return vectors of the
length-`n` factors (`psc.return_lattice`, exact through the Rauzy graph). Two
facts hold for any primitive substitution, and `verify_index_profile` refuses a
profile that breaks either; the third is what the census reports:

* **Chain.** A return of a length-`n+1` factor is a return of its length-`n`
  prefix, so `Lambda_{n+1} <= Lambda_n` and each index divides the next.
* **Covering bound.** `M^K Lambda_1 <= Lambda_n` for the covering level `K`
  of `n`, so the index divides `|det M|^K [Z^3 : Lambda_1]`.
* **Tile level.** The census reports how many specimens have
  `Lambda_1 = Z^3` (Solomyak's return set spans `Z<ell>`).

For a unimodular specimen with `Lambda_1 = Z^3` the covering bound gives
`Lambda_n = Z^3` for **every** `n`, not only the orders computed. For
`|det M| = 2` the index is a power of two, recorded as its base-2 logarithm;
its growth beyond `MAX_ORDER` is the recognizability argument of
`docs/return-lattice-literature-gate-2026-10-02.md`, not something this run
decides.

A sampled cross-check reads returns off a prefix of `sigma^k(0)` instead, a
route sharing no step with the Rauzy graph; its index must be a multiple of the
exact one, and the run counts how often the two agree.

Anything impossible raises: a broken chain or covering bound, a sampled index
that is not a multiple of the exact one, a rank-deficient lattice, an
overflow, a disconnected Rauzy graph. A clean run is exact over the 4554 specimens and the
orders computed, and says nothing about other substitutions.
"""

from psc.corpus import pip_corpus, report_progress
from psc.histogram import Histogram
from psc.return_lattice import return_index_profile, sampled_return_index, verify_index_profile

comptime MAX_ORDER = 32
comptime SAMPLE_STRIDE = 50
comptime SAMPLE_LENGTH = 20000


def log2_exact(x: Int) raises -> Int:
    """`k` with `2^k = x`; raises when `x` is not a power of two."""
    var k = 0
    var y = x
    while y > 1 and y % 2 == 0:
        y //= 2
        k += 1
    if y != 1:
        raise Error("index " + String(x) + " is not a power of two")
    return k



def main() raises:
    var corpus = pip_corpus()
    var reported: List[Int] = [1, 2, 4, 8, 16, 32]
    var by_det = Histogram(3)
    var tile_spanning = 0
    var unimodular_certified = 0
    var unimodular_nontrivial = 0
    var verified = 0
    var first_growth = Histogram(MAX_ORDER + 1)
    var still_trivial = 0
    var log2_at = List[Histogram]()
    for _ in range(len(reported)):
        log2_at.append(Histogram(MAX_ORDER))
    var sampled = 0
    var sampled_equal = 0

    for s in range(len(corpus)):
        ref spec = corpus[s]
        var det = abs(spec.incidence.det())
        by_det.record(det)
        var profile = return_index_profile(spec.sigma, MAX_ORDER)
        if profile[0] == 1:
            tile_spanning += 1
        verify_index_profile(spec.sigma, det, profile)
        verified += 1

        if det == 1:
            if profile[0] == 1:
                unimodular_certified += 1
            for n in range(MAX_ORDER):
                if profile[n] != 1:
                    unimodular_nontrivial += 1
                    print("UNIMODULAR NONTRIVIAL", spec.label(), n + 1, profile[n])
                    break
        else:
            var first = 0
            for n in range(MAX_ORDER):
                if profile[n] > 1:
                    first = n + 1
                    break
            if first == 0:
                still_trivial += 1
                print("NONUNIMODULAR TRIVIAL THROUGH", MAX_ORDER, spec.label())
            else:
                first_growth.record(first)
            for r in range(len(reported)):
                log2_at[r].record(log2_exact(profile[reported[r] - 1]))

        if s % SAMPLE_STRIDE == 0:
            for r in range(3):
                var n = reported[r + 1]
                sampled += 1
                var coarse = sampled_return_index(spec.sigma, n, SAMPLE_LENGTH)
                if coarse % profile[n - 1] != 0:
                    raise Error(
                        "sampled index " + String(coarse) + " is not a multiple of the exact "
                        + String(profile[n - 1]) + " at order " + String(n) + " for " + spec.label()
                    )
                if coarse == profile[n - 1]:
                    sampled_equal += 1
        report_progress(s, len(corpus))

    print("corpus:", len(corpus), " orders: 1 ..", MAX_ORDER)
    print(by_det.line("specimens by |det M|"))
    print("Lambda_1 = Z^3:", tile_spanning, " of", len(corpus))
    print("profiles verified against the chain and the covering bound:", verified)
    print("unimodular with Lambda_1 = Z^3, hence Lambda_n = Z^3 for every n:",
          unimodular_certified, " of", by_det.count(1))
    print("unimodular with an index > 1 at some order:", unimodular_nontrivial)
    print("|det M| = 2 still index 1 at order " + String(MAX_ORDER) + ":", still_trivial)
    print(first_growth.line("|det M| = 2 by first order with index > 1"))
    for r in range(len(reported)):
        print(log2_at[r].line(
            "|det M| = 2 by log2 index at order " + String(reported[r])
        ))
    print("sampled cross-checks:", sampled, " equal to exact:", sampled_equal)
