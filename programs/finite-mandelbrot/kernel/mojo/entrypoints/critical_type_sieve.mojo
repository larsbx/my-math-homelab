# critical_type_sieve.mojo
#
# Prints, for every exact type (ell, k) with ell + k <= HORIZON and ell != 1,
# the total of N_p(ell, k) over the odd primes p <= PRIME_BOUND and the number
# of those primes (pixi run type-sieve). These are raw totals including bad
# discriminant/resultant primes. Their finite mean is research evidence about
# the limiting number of distinct Q-irreducible factors; see
# kernel/mojo/dynamics/critical_type_sieve.mojo for the required hypotheses.

from dynamics.critical_type_sieve import type_counts

comptime HORIZON = 8
comptime PRIME_BOUND = 20000


def odd_primes(bound: Int) -> List[Int]:
    var composite = List[Bool](length=bound + 1, fill=False)
    var out = List[Int]()
    for n in range(3, bound + 1, 2):
        if not composite[n]:
            out.append(n)
            for m in range(n * n, bound + 1, 2 * n):
                composite[m] = True
    return out^


def main():
    var primes = odd_primes(PRIME_BOUND)
    var width = HORIZON + 1
    var totals = List[Int](length=width * width, fill=0)
    for p in primes:
        var t = type_counts(p, HORIZON)
        for i in range(width * width):
            totals[i] += t.counts[i]
    print("ell k total primes  (odd primes p <= " + String(PRIME_BOUND) + ")")
    for horizon in range(1, HORIZON + 1):
        for k in range(1, horizon + 1):
            var ell = horizon - k
            if ell != 1:
                print(ell, k, totals[ell * width + k], len(primes))
