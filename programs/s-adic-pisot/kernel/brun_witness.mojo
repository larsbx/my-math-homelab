"""Search for Theorem C witnesses of the unordered Brun algorithm in dimension d.

A witness is a periodic admissible word w whose composite sigma_w is
primitive, has an irreducible Pisot characteristic polynomial, and on which
the balanced pair algorithm terminates (docs/charter-theorem-c-higher-d.md).

Stage `pip` enumerates `brun_classes(d, n)`: one word per class under
rotation and letter permutation, among the words of period n using every
letter. It prints every class whose composite is primitive, irreducible and
Pisot (`is_pip`), with its characteristic polynomial, then the number of
classes and of those kept. Every decision is exact.

Stage `bpa` runs the balanced pair algorithm on one word with the given
budgets and prints the verdict and the size of the explored graph. Stage
`bpa-rev` runs it on the reversal of sigma_w: its subshift is the mirror
image of X_{sigma_w}, so one has pure discrete spectrum iff the other does.

Usage:
  mojo run -I . brun_witness.mojo pip d n
  mojo run -I . brun_witness.mojo bpa|bpa-rev d max_states max_length w_1 ... w_n
"""

from std.sys import argv

from substitution_dynamics.automaton import nonproductive_states
from substitution_dynamics.balanced_pair_algorithm import build_bounded
from sadic.cocycle import prefix_matrix
from sadic.periodic import brun_classes, brun_unordered, is_pip
from substitution_dynamics.substitution import Substitution
from sadic.spectrum import charpoly


def joined(w: List[Int]) -> String:
    var s = String("")
    for i in range(len(w)):
        if i > 0:
            s += ","
        s += String(w[i])
    return s


def reversal(sigma: Substitution) -> Substitution:
    var images = List[List[Int]]()
    for a in range(sigma.size):
        var img = sigma.image(a)
        var r = List[Int]()
        for i in range(len(img) - 1, -1, -1):
            r.append(img[i])
        images.append(r^)
    return Substitution(images^, sigma.size)


def main() raises:
    var args = argv()
    var mode = args[1]
    var d = Int(args[2])
    if mode == "pip":
        var n = Int(args[3])
        var shift = brun_unordered(d)
        var classes = brun_classes(d, n)
        var kept = 0
        for w in classes:
            if is_pip(shift, w):
                kept += 1
                print("pip " + joined(w) + " | " + joined(charpoly(prefix_matrix(shift, w), d)))
        print("classes " + String(len(classes)) + " pip " + String(kept) + " (d=" + String(d) + ", period " + String(n) + ")")
    elif mode == "bpa" or mode == "bpa-rev":
        var states = Int(args[3])
        var length = Int(args[4])
        var w = List[Int]()
        for i in range(5, len(args)):
            w.append(Int(args[i]))
        var sigma = brun_unordered(d).composite(w)
        if mode == "bpa-rev":
            sigma = reversal(sigma)
        var b = build_bounded(sigma, states, length)
        var verdict = String("capped")
        if b.complete():
            verdict = "terminates" if len(nonproductive_states(b.graph)) == 0 else "fails"
        print(mode + " " + joined(w) + " | " + verdict + " states " + String(b.graph.size()) + " longest " + String(b.longest_state))
    else:
        raise Error("mode must be pip, bpa or bpa-rev")
