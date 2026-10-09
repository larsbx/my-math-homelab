"""Targeted search: PeriodicPairVertexCoincidence where contraction is slowest.

Conjecture UH (docs/p1b-vertex-coincidence-box-2026-10-02.md §5.5) puts the
first-hit depth at about `1/log(1/mu)`, `mu` the modulus of the contracting
conjugates, so a strict zipper -- a counterexample to the Pisot substitution
conjecture for its substitution (Theorem S) -- is most plausible where `mu` is
close to 1. This driver enumerates the PIP substitutions on `{0,1,2}` with
images of length at most `MAX_LEN` and a complex contracting pair with
`mu^2 = |det M| / beta > (MU_NUM/MU_DEN)^2`, decided exactly: for `q > 1`,
`beta < q` iff `chi(q) > 0`, since `beta` is the only root of `chi` above 1.
It then decides the vertex coincidence on each (`psc.vertex_coincidence`).

Selection by `mu` is a search strategy, not a census: the candidates are a
stated subset, and only their verdicts are certificates.

Usage: `mojo run -I . vertex_coincidence_targeted.mojo MAX_LEN MU_NUM MU_DEN [count | STRIDE]`;
with `count` it only reports how many candidates there are, with `STRIDE` it
decides every STRIDE-th candidate in canonical order (an exploratory sample
that says so in its output). The threshold arithmetic is checked: a threshold
whose cleared denominators overflow raises rather than selecting wrongly.
"""

from std.sys import argv
from finite_linear_algebra.mat3 import Mat3
from parallel_fold.map_fold import parallel_map_fold
from std.math import gcd
from psc.bpa import substitution_incidence
from finite_exact.checked_int import checked_add, checked_mul
from psc.corpus import Specimen, cubic_discriminant, image_words_up_to, substitution_of
from psc.pisot import CubicScreen
from psc.vertex_coincidence import decide_vertex_coincidence

comptime WORKERS = 4
def slow_contraction(m: Mat3, mu_num: Int, mu_den: Int) raises -> Bool:
    """Complex contracting pair with `|det M| / beta > (mu_num/mu_den)^2`, exactly."""
    var chi = m.charpoly()
    if cubic_discriminant(chi) >= 0:
        return False
    var d = abs(m.det())
    # q = d * DEN^2 / NUM^2 = N / D; test q > 1 and chi(q) > 0, cleared of denominators
    var g = gcd(mu_num, mu_den)
    var a = mu_num // g
    var b = mu_den // g
    var n = checked_mul(d, checked_mul(b, b))
    var den = checked_mul(a, a)
    if n <= den:
        return False
    # den^3 chi(n/den), every product checked: an overflow raises, never wraps
    var n2 = checked_mul(n, n)
    var d2 = checked_mul(den, den)
    var value = checked_mul(n2, n)
    value = checked_add(value, checked_mul(chi[2], checked_mul(n2, den)))
    value = checked_add(value, checked_mul(chi[1], checked_mul(n, d2)))
    value = checked_add(value, checked_mul(chi[0], checked_mul(d2, den)))
    return value > 0


struct Targeted(Copyable, Movable):
    var specimens: Int
    var holds: Int
    var capped: Int
    var failing: List[Int]
    var failed_index: Int
    var max_deepest: Int
    var max_deepest_index: Int
    var max_states: Int

    def __init__(out self):
        self.specimens = 0
        self.holds = 0
        self.capped = 0
        self.failing = List[Int]()
        self.failed_index = -1
        self.max_deepest = -1
        self.max_deepest_index = -1
        self.max_states = 0


def merge(a: Targeted, b: Targeted) -> Targeted:
    var out = a.copy()
    out.specimens += b.specimens
    out.holds += b.holds
    out.capped += b.capped
    for i in range(len(b.failing)):
        out.failing.append(b.failing[i])
    if b.failed_index >= 0 and (out.failed_index < 0 or b.failed_index < out.failed_index):
        out.failed_index = b.failed_index
    if b.max_deepest > out.max_deepest:
        out.max_deepest = b.max_deepest
        out.max_deepest_index = b.max_deepest_index
    if b.max_states > out.max_states:
        out.max_states = b.max_states
    return out^


def main() raises:
    var args = argv()
    if len(args) < 4:
        raise Error("usage: MAX_LEN MU_NUM MU_DEN [count]")
    var max_len = Int(String(args[1]))
    var mu_num = Int(String(args[2]))
    var mu_den = Int(String(args[3]))
    if mu_num <= 0 or mu_num >= mu_den:
        raise Error("the threshold mu_num/mu_den must lie in (0, 1)")
    var words = image_words_up_to(max_len)
    var screen = CubicScreen()
    var candidates = List[Specimen]()
    for i in range(len(words)):
        for j in range(len(words)):
            for k in range(len(words)):
                var sigma = substitution_of(words, i, j, k)
                var m = Mat3(substitution_incidence(sigma))
                if not slow_contraction(m, mu_num, mu_den):
                    continue
                if screen.is_pip(m):
                    candidates.append(Specimen(len(candidates), i, j, k, sigma^, m^))
    print("images of length <=", max_len, "complex pair, mu >", mu_num, "/", mu_den, "PIP:", len(candidates))
    if len(args) > 4 and String(args[4]) == "count":
        return
    var stride = Int(String(args[4])) if len(args) > 4 else 1
    if stride < 1:
        raise Error("stride must be positive")
    if stride > 1:
        var sampled = List[Specimen]()
        for s in range(0, len(candidates), stride):
            sampled.append(candidates[s].copy())
        candidates = sampled^
        print("deterministic sample: every", stride, "th candidate in canonical order,", len(candidates), "specimens")

    def one(s: Int) {candidates} -> Targeted:
        var out = Targeted()
        out.specimens = 1
        try:
            var v = decide_vertex_coincidence(candidates[s].sigma)
            if v.capped:
                out.capped = 1
                return out^
            if v.holds:
                out.holds = 1
            else:
                out.failing.append(s)
            out.max_deepest = v.deepest
            out.max_deepest_index = s
            out.max_states = v.states
        except:
            out.failed_index = s
        return out^

    var r = parallel_map_fold(one, merge, Targeted(), len(candidates), WORKERS)
    if r.failed_index >= 0:
        _ = decide_vertex_coincidence(candidates[r.failed_index].sigma)
        raise Error("targeted search: worker failure did not replay")
    print("decided:", r.specimens, " holds for every r:", r.holds, " capped:", r.capped, " fails:", len(r.failing))
    for i in range(len(r.failing)):
        var spec = candidates[r.failing[i]].copy()
        print("STRICT ZIPPER specimen:", spec.label(), decide_vertex_coincidence(spec.sigma).witness)
    if r.max_deepest_index >= 0:
        print("deepest K_V:", r.max_deepest, "specimen", candidates[r.max_deepest_index].label(), " largest box graph:", r.max_states)
