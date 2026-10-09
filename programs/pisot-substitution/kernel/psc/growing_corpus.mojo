"""Deterministic exact screening for the append-only growing PIP corpus.

The standing 4,554-member corpus remains the theorem-facing finite domain.
This module enumerates strictly larger image-length bands for research evidence.

Band L contains exactly the three-letter substitutions whose nonempty images
have length at most L and at least one image has length exactly L. Bands are
therefore disjoint. An offset in a band identifies one substitution forever.

Screening uses the same exact `psc.pisot.is_pip` predicate as the standing
corpus. MAX parallelism is only the execution schedule: accepted offsets are
folded back in canonical order.
"""

from finite_linear_algebra.mat3 import Mat3
from parallel_fold.map_fold import parallel_map_fold
from psc.bpa import substitution_incidence
from psc.corpus import substitution_of, words_of_length
from psc.pisot import is_pip
from psc.symmetry import substitution_key

comptime MAX_GROWTH_IMAGE_LENGTH = 8


struct TripleIndex(ImplicitlyCopyable, Copyable, Movable, Equatable):
    var i: Int
    var j: Int
    var k: Int

    def __init__(out self, i: Int, j: Int, k: Int):
        self.i = i
        self.j = j
        self.k = k

    def __eq__(self, other: TripleIndex) -> Bool:
        return self.i == other.i and self.j == other.j and self.k == other.k

    def __ne__(self, other: TripleIndex) -> Bool:
        return not (self == other)


def _require_growth_length(max_len: Int) raises:
    if max_len < 1 or max_len > MAX_GROWTH_IMAGE_LENGTH:
        raise Error(
            "growing corpus image length lies outside the audited operational envelope 1.."
            + String(MAX_GROWTH_IMAGE_LENGTH)
        )


def _image_word_count_unchecked(max_len: Int) -> Int:
    var term = 1
    var total = 0
    for _ in range(max_len):
        term *= 3
        total += term
    return total


def image_word_count(max_len: Int) raises -> Int:
    _require_growth_length(max_len)
    return _image_word_count_unchecked(max_len)


def band_total(max_len: Int) raises -> Int:
    """Number of substitutions in exact maximum-image-length band `max_len`."""
    _require_growth_length(max_len)
    var current = _image_word_count_unchecked(max_len)
    var previous = _image_word_count_unchecked(max_len - 1)
    return current * current * current - previous * previous * previous


def _band_index_unchecked(max_len: Int, offset: Int) -> TripleIndex:
    """Map one valid band offset to image-word indices.

    Partition by the first coordinate whose image has the new length:
      A: i is new;
      B: i old, j new;
      C: i,j old, k new.
    """
    var w = _image_word_count_unchecked(max_len)
    var previous = _image_word_count_unchecked(max_len - 1)
    var new_words = w - previous

    var block_a = new_words * w * w
    if offset < block_a:
        var i = previous + offset // (w * w)
        var r = offset % (w * w)
        return TripleIndex(i, r // w, r % w)

    var q = offset - block_a
    var block_b = previous * new_words * w
    if q < block_b:
        var i = q // (new_words * w)
        var r = q % (new_words * w)
        var j = previous + r // w
        return TripleIndex(i, j, r % w)

    q -= block_b
    var i = q // (previous * new_words)
    var r = q % (previous * new_words)
    var j = r // new_words
    return TripleIndex(i, j, previous + r % new_words)


def band_index(max_len: Int, offset: Int) raises -> TripleIndex:
    _require_growth_length(max_len)
    var total = band_total(max_len)
    if offset < 0 or offset >= total:
        raise Error("growing corpus band offset lies outside the band")
    return _band_index_unchecked(max_len, offset)


def image_words_up_to(max_len: Int) raises -> List[List[Int]]:
    _require_growth_length(max_len)
    var out = List[List[Int]]()
    for n in range(1, max_len + 1):
        var words = words_of_length(n)
        for w in range(len(words)):
            out.append(words[w].copy())
    return out^


struct GrowthResult(Copyable, Movable):
    var screened: Int
    var accepted_offsets: List[Int]

    def __init__(out self, screened: Int, accepted_offsets: List[Int]):
        self.screened = screened
        self.accepted_offsets = accepted_offsets.copy()

    @staticmethod
    def empty() -> GrowthResult:
        return GrowthResult(0, List[Int]())

    @staticmethod
    def one(offset: Int, accepted: Bool) -> GrowthResult:
        var offsets = List[Int]()
        if accepted:
            offsets.append(offset)
        return GrowthResult(1, offsets)


def merge_growth(a: GrowthResult, b: GrowthResult) -> GrowthResult:
    var out = a.copy()
    out.screened += b.screened
    for i in range(len(b.accepted_offsets)):
        out.accepted_offsets.append(b.accepted_offsets[i])
    return out^


def run_growth_band(
    max_len: Int,
    start_offset: Int,
    count: Int,
    workers: Int,
) raises -> GrowthResult:
    """Screen one contiguous slice of one exact image-length band."""
    _require_growth_length(max_len)
    if count < 0:
        raise Error("growing corpus candidate count must be nonnegative")
    var total = band_total(max_len)
    if start_offset < 0 or start_offset > total or count > total - start_offset:
        raise Error("growing corpus slice lies outside the band")
    var words = image_words_up_to(max_len)

    def one(local: Int) {words, var max_len, var start_offset} -> GrowthResult:
        var offset = start_offset + local
        var triple = _band_index_unchecked(max_len, offset)
        var sigma = substitution_of(words, triple.i, triple.j, triple.k)
        var m = Mat3(substitution_incidence(sigma))
        return GrowthResult.one(offset, is_pip(m))

    return parallel_map_fold(
        one,
        merge_growth,
        GrowthResult.empty(),
        count,
        workers,
    )


def accepted_line(
    words: List[List[Int]], max_len: Int, offset: Int
) -> String:
    """Canonical TSV payload for one already-screened accepted substitution."""
    var triple = _band_index_unchecked(max_len, offset)
    var sigma = substitution_of(words, triple.i, triple.j, triple.k)
    var m = Mat3(substitution_incidence(sigma))
    var chi = m.charpoly()
    return (
        String(offset)
        + "\t" + substitution_key(sigma)
        + "\t" + String(chi[0])
        + "\t" + String(chi[1])
        + "\t" + String(chi[2])
    )
