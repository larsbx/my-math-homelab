"""The alphabet-3 short-image PIP corpus as a first-class census object.

Every census and catalogue driver in this repository surveys the same finite
corpus: the primitive irreducible Pisot substitutions on `{0,1,2}` whose three
images have length 1, 2 or 3. `image_words` enumerates the 39 candidate images
in the deterministic order every driver has always used (by length, then
lexicographically), `pip_corpus` screens the `39^3 = 59319` triples once with
the exact decision procedure of `psc.pisot`, and a `Specimen` carries the
indices, the images and the incidence matrix so that no driver recomputes
them. A specimen's `label` (`i j k`) and `json_fields` are the replayable
identity printed by every diagnostic line.

`pip_corpus_total_length` enumerates a wider class for exploratory sweeps,
not for censuses: every PIP substitution whose three images have total length
at most `TOTAL_LENGTH_CAP` (24486 specimens at 8), the domain of a lost
earlier sweep
(docs/lost-depth-indexed-formulation-2026-10-01.md). Its image words extend
`image_words` in the same order, so a standing specimen keeps its label there.

The corpus is finite evidence only: its 4554 members prove nothing about the
general PIP regime.
"""

from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from psc.pisot import CubicScreen, is_pip
from psc.words import ALPHABET

comptime MAX_IMAGE_LENGTH = 3
comptime TOTAL_LENGTH_CAP = 8
comptime PROGRESS_STRIDE = 500

# Fail-closed state cap shared by every balanced-pair and overlap-graph census.
comptime STATE_CAP = 20000

# Arithmetic regime of the incidence cubic, as printed by the C4 census.
comptime REGIME_NONUNIMODULAR = 0
comptime REGIME_UNIMODULAR_REAL = 1
comptime REGIME_UNIMODULAR_COMPLEX = 2
comptime REGIME_ZERO_DISCRIMINANT = 3


struct Specimen(Copyable, Movable):
    """One corpus member: image indices into `image_words`, images, incidence."""

    var index: Int
    var i: Int
    var j: Int
    var k: Int
    var sigma: List[List[Int]]
    var incidence: Mat3

    def __init__(
        out self,
        index: Int,
        i: Int,
        j: Int,
        k: Int,
        var sigma: List[List[Int]],
        var incidence: Mat3,
    ):
        self.index = index
        self.i = i
        self.j = j
        self.k = k
        self.sigma = sigma^
        self.incidence = incidence^

    def longest_image(self) -> Int:
        """`max_a |sigma(a)|`, the slicing key of the total-length corpus."""
        var longest = 0
        for a in range(len(self.sigma)):
            if len(self.sigma[a]) > longest:
                longest = len(self.sigma[a])
        return longest

    def label(self) -> String:
        """`i j k`: the image indices, as every diagnostic line prints them."""
        return String(self.i) + " " + String(self.j) + " " + String(self.k)

    def json_fields(self) -> String:
        """`"i":i,"j":j,"k":k`, the specimen identity inside a JSON record."""
        return (
            "\"i\":" + String(self.i)
            + ",\"j\":" + String(self.j)
            + ",\"k\":" + String(self.k)
        )


def words_of_length(n: Int) -> List[List[Int]]:
    """Every word of length `n` over `{0,1,2}`, lexicographically."""
    var out: List[List[Int]] = [List[Int]()]
    for _ in range(n):
        var longer = List[List[Int]]()
        for w in range(len(out)):
            for a in range(ALPHABET):
                var ext = out[w].copy()
                ext.append(a)
                longer.append(ext^)
        out = longer^
    return out^


def image_words_up_to(max_length: Int) -> List[List[Int]]:
    """Every word of length `1..max_length` over `{0,1,2}`, by length first,
    then lexicographically."""
    var out = List[List[Int]]()
    for n in range(1, max_length + 1):
        var words = words_of_length(n)
        for w in range(len(words)):
            out.append(words[w].copy())
    return out^


def image_words() -> List[List[Int]]:
    """The 39 candidate images: every word of length 1, 2 or 3 over `{0,1,2}`."""
    return image_words_up_to(MAX_IMAGE_LENGTH)


def substitution_of(words: List[List[Int]], i: Int, j: Int, k: Int) -> List[List[Int]]:
    """`0 -> words[i]`, `1 -> words[j]`, `2 -> words[k]`."""
    var sigma = List[List[Int]]()
    sigma.append(words[i].copy())
    sigma.append(words[j].copy())
    sigma.append(words[k].copy())
    return sigma^


def screened_triples(words: List[List[Int]], max_total: Int) raises -> List[Specimen]:
    """Every PIP triple over the length-sorted `words` with total image length
    at most `max_total`, screened exactly, in `(i, j, k)` order."""
    var screen = CubicScreen()
    var out = List[Specimen]()
    for i in range(len(words)):
        for j in range(len(words)):
            if len(words[i]) + len(words[j]) + 1 > max_total:
                break
            for k in range(len(words)):
                if len(words[i]) + len(words[j]) + len(words[k]) > max_total:
                    break
                var sigma = substitution_of(words, i, j, k)
                var m = Mat3(substitution_incidence(sigma))
                if screen.is_pip(m):
                    out.append(Specimen(len(out), i, j, k, sigma^, m^))
    return out^


def pip_corpus() raises -> List[Specimen]:
    """The 4554 PIP specimens with images of length at most 3, screened exactly
    and returned in the canonical `(i, j, k)` order."""
    return screened_triples(image_words(), ALPHABET * MAX_IMAGE_LENGTH)


def pip_corpus_total_length(max_total: Int) raises -> List[Specimen]:
    """The PIP specimens with total image length at most `max_total`, labelled
    by indices into `image_words_up_to(max_total - 2)`."""
    if max_total < ALPHABET:
        raise Error("a substitution on three letters has total image length >= 3")
    return screened_triples(image_words_up_to(max_total - (ALPHABET - 1)), max_total)


def corpus_for(mode: String) raises -> List[Specimen]:
    """The census domain a driver's first argument selects: `total` gives the
    specimens of total image length at most `TOTAL_LENGTH_CAP`; `len4` the
    135990 specimens with images of length at most 4; anything else (no
    argument, or a trailing flag such as `records`) the standing corpus."""
    if mode == "total":
        return pip_corpus_total_length(TOTAL_LENGTH_CAP)
    if mode == "len4":
        return screened_triples(image_words_up_to(4), 12)
    return pip_corpus()


def report_progress(done: Int, stride: Int = PROGRESS_STRIDE):
    """One `progress:` line every `stride` specimens, for long censuses."""
    if done % stride == 0:
        print("progress:", done)


def cubic_discriminant(poly: List[Int]) -> Int:
    """Discriminant of the monic cubic `c0 + c1 x + c2 x^2 + x^3`."""
    var c = poly[0]
    var b = poly[1]
    var a = poly[2]
    return (
        a * a * b * b
        - 4 * b * b * b
        - 4 * a * a * a * c
        - 27 * c * c
        + 18 * a * b * c
    )


def arithmetic_regime(m: Mat3) -> Int:
    """`|det M| > 1`, or unimodular with three real roots, a complex pair, or a
    repeated root (a zero discriminant, impossible for an irreducible cubic and
    reported so that the census fails loudly rather than misclassifying)."""
    if abs(m.det()) != 1:
        return REGIME_NONUNIMODULAR
    var disc = cubic_discriminant(m.charpoly())
    if disc < 0:
        return REGIME_UNIMODULAR_COMPLEX
    if disc > 0:
        return REGIME_UNIMODULAR_REAL
    return REGIME_ZERO_DISCRIMINANT
