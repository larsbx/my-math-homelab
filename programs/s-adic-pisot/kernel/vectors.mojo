"""Print the cross-language battery that tools/cross_check.py recomputes with
the Python oracle. One line per fact, `shift|kind|word|value`, words as
digit strings; any disagreement fails closed."""

from sadic.balance import image_balance
from sadic.cocycle import cross_ratio_bound, first_positive_prefix, is_positive, positive_blocks, prefix_matrix
from sadic.directive import DirectiveShift, arnoux_rauzy, brun3, words_of_length
from sadic.overlap import morphic_balance_bound, positive_suffix_ratio, return_overlap_bound, window_overlap_bound
from sadic.periodic import brun_unordered, periodic_verdict, periodic_words, primitivity_exponent
from sadic.spectrum import charpoly, disc_zero_count, irreducibility_verdict, pisot_verdict

comptime MAX_LEN = 5
comptime SPECTRAL_LEN = 4
comptime PERIODIC_LEN = 6
comptime BRUN5_LEN = 6
comptime BPA_STATES = 20000
comptime BPA_LENGTH = 2000


def digits(w: List[Int]) -> String:
    var s = String("")
    for x in w:
        s += String(x)
    return s


def joined(m: List[Int]) -> String:
    var s = String("")
    for i in range(len(m)):
        if i > 0:
            s += ","
        s += String(m[i])
    return s


def emit(shift: DirectiveShift) raises:
    var d = shift.size()
    for n in range(MAX_LEN + 1):
        for w in words_of_length(shift.labels(), n):
            var m = prefix_matrix(shift, w)
            var key = shift.name + "|"
            print(key + "matrix|" + digits(w) + "|" + joined(m))
            print(key + "first-positive|" + digits(w) + "|" + String(first_positive_prefix(shift, w)))
            if is_positive(m):
                var r = cross_ratio_bound(m, d)
                print(key + "cross-ratio|" + digits(w) + "|" + String(r.num) + "/" + String(r.den))
                var suffix = positive_suffix_ratio(m, d)
                print(key + "suffix-ratio|" + digits(w) + "|" + String(suffix.num) + "/" + String(suffix.den))
                for c in range(4):
                    print(key + "return-overlap-" + String(c) + "|" + digits(w) + "|" + String(return_overlap_bound(m, d, c)))
                    for window in range(3):
                        print(key + "window-overlap-" + String(c) + "-" + String(window) + "|" + digits(w) + "|" + String(window_overlap_bound(m, d, c, 2, window)))
            for a in range(d):
                print(key + "image-balance-" + String(a) + "|" + digits(w) + "|" + String(image_balance(shift, w, a)))
    for w in positive_blocks(shift, MAX_LEN):
        print(shift.name + "|positive-block|" + digits(w) + "|1")


def emit_spectral(shift: DirectiveShift) raises:
    var d = shift.size()
    for n in range(1, SPECTRAL_LEN + 1):
        for w in words_of_length(shift.labels(), n):
            var m = prefix_matrix(shift, w)
            var key = shift.name + "|"
            var f = charpoly(m, d)
            print(key + "charpoly|" + digits(w) + "|" + joined(f))
            print(key + "primitivity|" + digits(w) + "|" + String(primitivity_exponent(m, d)))
            var irr = irreducibility_verdict(f)
            print(key + "irreducible|" + digits(w) + "|" + String(irr.verdict) + "," + String(irr.witness))
            if irr.verdict == 1:
                print(key + "pisot|" + digits(w) + "|" + String(pisot_verdict(f)))


def emit_polynomial(f: List[Int]) raises:
    """Exact facts on one monic polynomial (coefficients lowest first)."""
    var key = "poly|"
    var irr = irreducibility_verdict(f)
    print(key + "irreducible|" + joined(f) + "|" + String(irr.verdict) + "," + String(irr.witness))
    var disc = String("inc")
    try:
        disc = String(disc_zero_count(f))
    except:
        pass
    print(key + "disc|" + joined(f) + "|" + disc)
    if irr.verdict == 1:
        print(key + "pisot|" + joined(f) + "|" + String(pisot_verdict(f)))


def emit_periodic_spectral(shift: DirectiveShift, max_period: Int) raises:
    """Budget-free facts on the periodic composites: no balanced pairs."""
    var d = shift.size()
    for n in range(1, max_period + 1):
        for w in periodic_words(shift, n):
            var m = prefix_matrix(shift, w)
            var key = shift.name + "|"
            var f = charpoly(m, d)
            print(key + "charpoly|" + joined(w) + "|" + joined(f))
            print(key + "primitivity|" + joined(w) + "|" + String(primitivity_exponent(m, d)))
            var irr = irreducibility_verdict(f)
            print(key + "irreducible|" + joined(w) + "|" + String(irr.verdict) + "," + String(irr.witness))
            if irr.verdict == 1:
                print(key + "pisot|" + joined(w) + "|" + String(pisot_verdict(f)))


def emit_periodic(shift: DirectiveShift) raises:
    for n in range(1, PERIODIC_LEN + 1):
        for w in periodic_words(shift, n):
            print(shift.name + "|periodic|" + joined(w) + "|" + periodic_verdict(shift, w, BPA_STATES, BPA_LENGTH))


def main() raises:
    for d in range(1, 5):
        for c in range(4):
            for j in range(1, 5):
                print("balance|morphic-" + String(d) + "-" + String(c) + "-" + String(j) + "||" + String(morphic_balance_bound(d, c, j)))
    var anchor_word: List[Int] = [0, 1, 2]
    print("anchor-ar3|window||" + String(window_overlap_bound(prefix_matrix(arnoux_rauzy(3), anchor_word), 3, 3, 2, 9)))
    emit(arnoux_rauzy(2))
    emit(arnoux_rauzy(3))
    emit(brun3())
    emit_spectral(arnoux_rauzy(3))
    emit_spectral(brun3())
    emit_periodic(brun_unordered(4))
    # the polynomial battery: a reducible quintic and sextic refuted only by
    # the factor search, z^4 + 1 (zeros on the circle), irreducible quartics,
    # and a sextic whose Schur-Cohn recursion overflows 64 bits
    var polys: List[List[Int]] = [
        [-1, 5, -10, 10, -6, 1],
        [1, 0, 0, 0, 1],
        [1, -4, 6, -5, 1],
        [-1, -1, -1, -1, 1],
        [1, 1, 1, -1, -1, -1, 1],
        [1, -6, 16, -24, 20, -9, 1],
    ]
    for f in polys:
        emit_polynomial(f)
    emit_periodic_spectral(brun_unordered(5), BRUN5_LEN)
