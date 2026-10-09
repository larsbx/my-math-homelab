"""Balance of finite words and the exact lower bound it gives on S-adic languages.

The balance of a finite word `w` over `0..size-1` is the maximum, over
equal-length factors `u, v` of `w` and letters `a`, of `|u|_a - |v|_a`. A
language is C-balanced when every pair of its equal-length factors has
balance at most C (BST19 section 2.4).

Every factor of `sigma_w(a)` lies in the language of every directive
sequence with prefix `w` (BST19 section 2.2: that language is the set of
factors of the words `sigma_{[0,n)}(a)`), so `image_balance` is an exact
*lower* bound on its balance constant. It never certifies balance: an upper
bound needs a proof, not a finite run.

Reference oracle: `reference/sadic_reference`.
"""

from sadic.directive import DirectiveShift


@fieldwise_init
struct BalanceWitness(Copyable, Movable):
    """`value = |u|_letter - |v|_letter` for `u = w[start_hi : start_hi + length]`
    and `v = w[start_lo : start_lo + length]`: the first maximal pair in
    (length, letter, position) order; all zero when no two factors differ."""

    var value: Int
    var length: Int
    var letter: Int
    var start_hi: Int
    var start_lo: Int


def balance(word: List[Int], size: Int) raises -> BalanceWitness:
    var n = len(word)
    # prefix[a * (n + 1) + p] = |w[:p]|_a
    var prefix = List[Int]()
    for a in range(size):
        var c = 0
        prefix.append(0)
        for x in word:
            if x < 0 or x >= size:
                raise Error("letter out of range: " + String(x))
            if x == a:
                c += 1
            prefix.append(c)
    var best = BalanceWitness(0, 0, 0, 0, 0)
    for length in range(1, n + 1):
        for a in range(size):
            var base = a * (n + 1)
            var hi = -1
            var lo = n + 1
            var at_hi = 0
            var at_lo = 0
            for s in range(n - length + 1):
                var c = prefix[base + s + length] - prefix[base + s]
                if c > hi:
                    hi = c
                    at_hi = s
                if c < lo:
                    lo = c
                    at_lo = s
            if hi - lo > best.value:
                best = BalanceWitness(hi - lo, length, a, at_hi, at_lo)
    return best^


def image_balance(shift: DirectiveShift, word: List[Int], letter: Int) raises -> Int:
    """The balance of `sigma_w(letter)`."""
    return balance(shift.image(word, letter), shift.size()).value
