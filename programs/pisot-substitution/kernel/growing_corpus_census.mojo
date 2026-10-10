"""CLI for one deterministic shard of the growing PIP research corpus.

Usage:
  mojo run -I . growing_corpus_census.mojo MAX_LEN START COUNT WORKERS
"""

from std.sys import argv

from psc.growing_corpus import (
    accepted_line,
    band_total,
    image_words_up_to,
    run_growth_band,
)


def main() raises:
    var args = argv()
    if len(args) != 5:
        raise Error(
            "usage: growing_corpus_census.mojo MAX_LEN START COUNT WORKERS"
        )
    var max_len = atol(args[1])
    var start = atol(args[2])
    var count = atol(args[3])
    var workers = atol(args[4])

    var result = run_growth_band(max_len, start, count, workers)
    var total = band_total(max_len)
    var words = image_words_up_to(max_len)

    print("schema\tpsc-growing-corpus-shard/v1")
    print("max_image_length\t" + String(max_len))
    print("start_offset\t" + String(start))
    print("screened\t" + String(result.screened))
    print("accepted\t" + String(len(result.accepted_offsets)))
    print("next_offset\t" + String(start + result.screened))
    print("band_total\t" + String(total))
    print("columns\toffset\tsubstitution\tchi0\tchi1\tchi2")
    for i in range(len(result.accepted_offsets)):
        print(
            "A\t"
            + accepted_line(words, max_len, result.accepted_offsets[i])
        )
