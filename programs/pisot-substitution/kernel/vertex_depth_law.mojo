"""Exact check of contraction-rate depth laws against vertex-coincidence records.

Input: the `K_V record: i j k K_V` lines that `vertex_coincidence_census.mojo
... records` prints, saved to FILE; the labels index
`image_words_up_to(MAX_LEN)`. Each record is judged against three laws by
`psc.depth_law` (exact; undecided specimens are reported, never counted as a
verdict): `K_V <= 3.2/log(1/mu)`, `K_V <= 4/log(1/mu)` and
`K_V <= 7 + 1/log(1/mu)`.

Usage: `mojo run -I . vertex_depth_law.mojo FILE MAX_LEN`.
"""

from std.sys import argv
from finite_exact.rat_q import Q
from psc.corpus import image_words_up_to, substitution_of
from psc.depth_law import Law, MuSquared, judge, standard_laws


def main() raises:
    var args = argv()
    if len(args) != 3:
        raise Error("usage: FILE MAX_LEN")
    var words = image_words_up_to(Int(String(args[2])))
    var text: String
    with open(String(args[1]), "r") as f:
        text = f.read()
    var laws = standard_laws()
    var records = 0
    for line in text.split("\n"):
        var s = String(line)
        if not s.startswith("K_V record: "):
            continue
        var parts = s[byte=12:].split(" ")
        var sigma = substitution_of(words, Int(String(parts[0])), Int(String(parts[1])), Int(String(parts[2])))
        var k_v = Int(String(parts[3]))
        var mu = MuSquared(sigma)
        for l in range(len(laws)):
            judge(laws[l], mu, k_v)
        records += 1
    print("records:", records)
    for l in range(len(laws)):
        print(laws[l].name, " holds:", laws[l].holds, " violates:", laws[l].violates, " undecided:", laws[l].undecided)
