"""Parametric witness paths: one exact check that proves a shared tile on a
whole cone of substitutions.

A *cone family* is a three-letter substitution whose images are sequences of
segments -- a single letter, a run of one letter whose length is an affine
form in cone variables `n_1, ..., n_m >= 0`, or an *opaque* word known only by
its affine Parikh vector, inside which no position is ever named. The
incidence matrix `M` then has affine entries.

A *witness path* from the pair `(a_0, b_0)` is a sequence of steps; step `l`
picks a position in `sigma(a_l)` and one in `sigma(b_l)`, each a segment and
an affine offset inside it, and moves to the letters there with Parikh offset

    gamma_(l+1) = M gamma_l + pi(sigma(a_l)[:i_l]) - pi(sigma(b_l)[:k_l]).

If every `gamma_l` is a *constant* vector, every condition of the path -- an
offset lies inside its run, `gamma_(l+1)` is the constant the path says -- is
an affine identity or an affine inequality in the `n_k`, and an affine form is
nonnegative on all of `Z_{>=0}^m` iff its constant and its coefficients are
(sufficiency is all that is used). A path ending at `(a, a, 0)` after `n`
steps is then a shared tile of `sigma^n(a_0)` and `sigma^n(b_0)` for **every**
member of the cone at once: unrolling the recursion, `gamma_n` is the
difference of the Parikh vectors of the two prefixes in front of the two
positions, and the letters there are equal.

*Line mode* (`search_witness_line`, `verify_witness_line`) relaxes the
constant-offset requirement along one direction `u`: offsets may be affine in
the cone variables along `u` as long as `M gamma` stays affine, which is
checked exactly; it serves families where `M u` is constant.

`search_witness` finds a path by breadth-first search over the finitely many
states `(a, b, gamma)` with `|gamma_i| <= bound`; `verify_witness` re-derives
every state from the step data alone and checks every condition. The search
is a means of finding a certificate; the verification is the certificate.
A failed search is reported as such and is never a verdict about the cone.
"""

from std.collections import Dict

comptime Y_LETTER = 2


def aff_const(m: Int, c: Int) -> List[Int]:
    var out = List[Int](length=m + 1, fill=0)
    out[0] = c
    return out^


def aff_add(a: List[Int], b: List[Int]) -> List[Int]:
    var out = List[Int]()
    for k in range(len(a)):
        out.append(a[k] + b[k])
    return out^


def aff_sub(a: List[Int], b: List[Int]) -> List[Int]:
    var out = List[Int]()
    for k in range(len(a)):
        out.append(a[k] - b[k])
    return out^


def aff_scale(a: List[Int], s: Int) -> List[Int]:
    var out = List[Int]()
    for k in range(len(a)):
        out.append(s * a[k])
    return out^


def aff_is_const(a: List[Int]) -> Bool:
    for k in range(1, len(a)):
        if a[k] != 0:
            return False
    return True


def aff_nonneg(a: List[Int]) -> Bool:
    """Sufficient for `a(n) >= 0` on all of `Z_{>=0}^m`."""
    for k in range(len(a)):
        if a[k] < 0:
            return False
    return True


def aff_eval(a: List[Int], ns: List[Int]) -> Int:
    var v = a[0]
    for k in range(len(ns)):
        v += a[k + 1] * ns[k]
    return v


struct Prover(Copyable, Movable):
    """Proves `f >= 0` on a region that carries assumptions `A_j >= 0`: true
    when `f - l_i A_i - l_j A_j` has nonnegative coefficients for some
    integers `l_i, l_j >= 0` (a Farkas certificate with at most two
    multipliers, drawn from 1 and the coefficient ratios of `f` to `A_i`;
    sufficient, exact). With no assumptions it is the coefficient-sign test
    on the whole orthant."""

    var assume: List[List[Int]]

    def __init__(out self):
        self.assume = List[List[Int]]()

    def __init__(out self, var assume: List[List[Int]]):
        self.assume = assume^

    def nonneg(self, f: List[Int]) -> Bool:
        if aff_nonneg(f):
            return True
        for i in range(len(self.assume)):
            var li = _multipliers(f, self.assume[i])
            for x in range(len(li)):
                var g = aff_sub(f, aff_scale(self.assume[i], li[x]))
                if aff_nonneg(g):
                    return True
                for j in range(i, len(self.assume)):
                    var lj = _multipliers(g, self.assume[j])
                    for y in range(len(lj)):
                        if aff_nonneg(aff_sub(g, aff_scale(self.assume[j], lj[y]))):
                            return True
        return False

    def vanishes(self, f: List[Int]) -> Bool:
        """`f = 0` on the region; with no assumptions, `f` is identically 0."""
        return self.nonneg(f) and self.nonneg(aff_scale(f, -1))


def _multipliers(f: List[Int], a: List[Int]) -> List[Int]:
    """Candidate multipliers `l >= 1` for `f - l a`: 1, and each positive
    integer ratio `f_k / a_k` of variable coefficients (it cancels one, as
    the multiple of a tightened form that restores its source does)."""
    var out = List[Int]([1])
    for k in range(1, len(f)):
        if a[k] != 0 and f[k] != 0 and (f[k] > 0) == (a[k] > 0) and f[k] % a[k] == 0:
            var l = f[k] // a[k]
            var seen = False
            for t in range(len(out)):
                if out[t] == l:
                    seen = True
            if not seen:
                out.append(l)
    return out^


comptime SEG_LETTER = 0
comptime SEG_RUN = 1
comptime SEG_OPAQUE = 2


struct Segment(Copyable, Movable):
    """A single `letter`; a run of `letter` of affine `length`; or an opaque
    word known only by its affine Parikh vector, inside which no position is
    ever named. `parikh` holds the three affine counts for every kind."""

    var kind: Int
    var letter: Int
    var length: List[Int]
    var parikh: List[List[Int]]

    def __init__(out self, kind: Int, letter: Int, var length: List[Int], var parikh: List[List[Int]]):
        self.kind = kind
        self.letter = letter
        self.length = length^
        self.parikh = parikh^

    def is_run(self) -> Bool:
        return self.kind == SEG_RUN


def _unit_parikh(letter: Int, var amount: List[Int]) -> List[List[Int]]:
    var m = len(amount) - 1
    var out = List[List[Int]]()
    for i in range(3):
        if i == letter:
            out.append(amount.copy())
        else:
            out.append(aff_const(m, 0))
    return out^


def letter_segment(m: Int, letter: Int) -> Segment:
    return Segment(SEG_LETTER, letter, aff_const(m, 1), _unit_parikh(letter, aff_const(m, 1)))


def run_of(letter: Int, var length: List[Int]) -> Segment:
    """A run of `letter` with affine `length`."""
    var p = _unit_parikh(letter, length.copy())
    return Segment(SEG_RUN, letter, length^, p^)


def run_segment(var length: List[Int]) -> Segment:
    """A run of `y = 2`, the letter of the swap family's runs."""
    return run_of(Y_LETTER, length^)


def opaque_segment(var parikh: List[List[Int]]) -> Segment:
    """An unrevealed word with affine Parikh vector `parikh`."""
    var length = aff_add(aff_add(parikh[0], parikh[1]), parikh[2])
    return Segment(SEG_OPAQUE, -1, length^, parikh^)


struct ConeFamily(Copyable, Movable):
    var m: Int
    var images: List[List[Segment]]
    var incidence: List[List[Int]]  # entry 3 i + j: count of letter i in sigma(j)

    def __init__(out self, m: Int, var images: List[List[Segment]]) raises:
        if len(images) != 3:
            raise Error("a cone family has three images")
        self.m = m
        self.images = images^
        self.incidence = List[List[Int]]()
        for _ in range(9):
            self.incidence.append(aff_const(m, 0))
        for j in range(3):
            for s in range(len(self.images[j])):
                ref seg = self.images[j][s]
                if len(seg.length) != m + 1:
                    raise Error("a segment has the wrong number of cone variables")
                for i in range(3):
                    if len(seg.parikh[i]) != m + 1:
                        raise Error("a segment Parikh form has the wrong number of cone variables")
                    self.incidence[3 * i + j] = aff_add(self.incidence[3 * i + j], seg.parikh[i])

    def m_times(self, gamma: List[Int]) -> List[List[Int]]:
        """`M gamma` for a constant `gamma`, as three affine forms."""
        var out = List[List[Int]]()
        for i in range(3):
            var acc = aff_const(self.m, 0)
            for j in range(3):
                acc = aff_add(acc, aff_scale(self.incidence[3 * i + j], gamma[j]))
            out.append(acc^)
        return out^

    def prefix_before(self, a: Int, s: Int) -> List[List[Int]]:
        """Parikh vector of the segments of `sigma(a)` before segment `s`."""
        var pre = List[List[Int]]()
        for _ in range(3):
            pre.append(aff_const(self.m, 0))
        for k in range(s):
            for i in range(3):
                pre[i] = aff_add(pre[i], self.images[a][k].parikh[i])
        return pre^

    def start_of(self, a: Int, s: Int) -> List[Int]:
        """Index of the first letter of segment `s` in `sigma(a)`."""
        var st = aff_const(self.m, 0)
        for k in range(s):
            st = aff_add(st, self.images[a][k].length)
        return st^

    def instantiate(self, ns: List[Int]) raises -> List[List[Int]]:
        """A member of the cone at `ns`, as a plain substitution. An opaque
        segment is written as its letters in alphabet order; a witness path
        never names a position inside one and reads it only through its
        Parikh vector, so any arrangement gives the same verdict."""
        if len(ns) != self.m:
            raise Error("wrong number of cone coordinates")
        var sigma = List[List[Int]]()
        for a in range(3):
            var img = List[Int]()
            for s in range(len(self.images[a])):
                ref seg = self.images[a][s]
                if seg.kind == SEG_LETTER:
                    img.append(seg.letter)
                    continue
                for i in range(3):
                    var n = aff_eval(seg.parikh[i], ns)
                    if n < 0:
                        raise Error("a segment count is negative at this cone point")
                    for _ in range(n):
                        img.append(i)
            sigma.append(img^)
        return sigma^


struct WitnessStep(Copyable, Movable):
    """Segment and affine offset inside it, on each side."""

    var seg_a: Int
    var off_a: List[Int]
    var seg_b: Int
    var off_b: List[Int]

    def __init__(out self, seg_a: Int, var off_a: List[Int], seg_b: Int, var off_b: List[Int]):
        self.seg_a = seg_a
        self.off_a = off_a^
        self.seg_b = seg_b
        self.off_b = off_b^


struct WitnessSearch(Copyable, Movable):
    var found: Bool
    var steps: List[WitnessStep]

    def __init__(out self):
        self.found = False
        self.steps = List[WitnessStep]()


def _offset_ok(fam: ConeFamily, a: Int, s: Int, off: List[Int], prover: Prover = Prover()) -> Bool:
    ref seg = fam.images[a][s]
    if seg.kind == SEG_OPAQUE:
        return False
    if seg.kind == SEG_LETTER:
        for k in range(len(off)):
            if off[k] != 0:
                return False
        return True
    # 0 <= off <= length - 1
    return prover.nonneg(off) and prover.nonneg(aff_sub(aff_sub(seg.length, off), aff_const(fam.m, 1)))


struct StepResult(Copyable, Movable):
    """The state a step leads to; `ok` is false if any condition failed, and
    `why` then says which."""

    var ok: Bool
    var why: String
    var a: Int
    var b: Int
    var gamma: List[Int]

    def __init__(out self, ok: Bool, why: String, a: Int, b: Int, var gamma: List[Int]):
        self.ok = ok
        self.why = why
        self.a = a
        self.b = b
        self.gamma = gamma^


def _refused(why: String) -> StepResult:
    return StepResult(False, why, -1, -1, List[Int]([0, 0, 0]))


def apply_step(fam: ConeFamily, a: Int, b: Int, gamma: List[Int], step: WitnessStep, prover: Prover = Prover()) -> StepResult:
    """The state a step leads to, with every condition of the step checked on
    the whole cone. Used by both the search and the verifier."""
    if step.seg_a < 0 or step.seg_a >= len(fam.images[a]) or step.seg_b < 0 or step.seg_b >= len(fam.images[b]):
        return _refused("a witness step names a segment that does not exist")
    if not _offset_ok(fam, a, step.seg_a, step.off_a, prover) or not _offset_ok(fam, b, step.seg_b, step.off_b, prover):
        return _refused("a witness offset is not provably inside its segment")
    var mg = fam.m_times(gamma)
    var pa = fam.prefix_before(a, step.seg_a)
    var pb = fam.prefix_before(b, step.seg_b)
    ref sa = fam.images[a][step.seg_a]
    ref sb = fam.images[b][step.seg_b]
    var g2 = List[Int]()
    for i in range(3):
        var d = aff_sub(aff_add(mg[i], pa[i]), pb[i])
        if sa.is_run() and sa.letter == i:
            d = aff_add(d, step.off_a)
        if sb.is_run() and sb.letter == i:
            d = aff_sub(d, step.off_b)
        if not aff_is_const(d):
            return _refused("a witness Parikh offset is not constant on the cone")
        g2.append(d[0])
    return StepResult(True, "", sa.letter, sb.letter, g2^)


def _key(a: Int, b: Int, gamma: List[Int], bound: Int) -> Int:
    var w = 2 * bound + 1
    return (((a * 3 + b) * w + gamma[0] + bound) * w + gamma[1] + bound) * w + gamma[2] + bound


def _in_box(gamma: List[Int], bound: Int) -> Bool:
    for i in range(3):
        if gamma[i] < -bound or gamma[i] > bound:
            return False
    return True


def _candidates(fam: ConeFamily, a: Int, b: Int, gamma: List[Int], bound: Int, end_pins: Bool) -> List[WitnessStep]:
    """Every step whose target offset is constant with entries in the box. A
    coordinate no run touches must already be constant; a run's offset is
    solved from its target. With both positions in runs of one letter, one
    offset is pinned to 0, 1 or 2 -- and, with `end_pins`, also to 0, 1 or 2
    from the end of its run."""
    var out = List[WitnessStep]()
    var m = fam.m
    var mg = fam.m_times(gamma)
    for sa in range(len(fam.images[a])):
        ref ga = fam.images[a][sa]
        if ga.kind == SEG_OPAQUE:
            continue
        var pa = fam.prefix_before(a, sa)
        var la = ga.letter if ga.is_run() else -1
        for sb in range(len(fam.images[b])):
            ref gb = fam.images[b][sb]
            if gb.kind == SEG_OPAQUE:
                continue
            var pb = fam.prefix_before(b, sb)
            var lb = gb.letter if gb.is_run() else -1
            var d = List[List[Int]]()
            var fixed = True
            for i in range(3):
                d.append(aff_sub(aff_add(mg[i], pa[i]), pb[i]))
                if i != la and i != lb and not aff_is_const(d[i]):
                    fixed = False
            if not fixed:
                continue
            if la < 0 and lb < 0:
                out.append(WitnessStep(sa, aff_const(m, 0), sb, aff_const(m, 0)))
            elif lb < 0:
                for t in range(-bound, bound + 1):
                    out.append(WitnessStep(sa, aff_sub(aff_const(m, t), d[la]), sb, aff_const(m, 0)))
            elif la < 0:
                for t in range(-bound, bound + 1):
                    out.append(WitnessStep(sa, aff_const(m, 0), sb, aff_sub(d[lb], aff_const(m, t))))
            elif la == lb:
                for t in range(-bound, bound + 1):
                    var dd = aff_sub(aff_const(m, t), d[la])  # off_a - off_b must equal dd
                    for p in range(3):
                        out.append(WitnessStep(sa, aff_add(dd, aff_const(m, p)), sb, aff_const(m, p)))
                        out.append(WitnessStep(sa, aff_const(m, p), sb, aff_sub(aff_const(m, p), dd)))
                        if end_pins:
                            var eb = aff_sub(gb.length, aff_const(m, p + 1))
                            out.append(WitnessStep(sa, aff_add(dd, eb), sb, eb.copy()))
                            var ea = aff_sub(ga.length, aff_const(m, p + 1))
                            out.append(WitnessStep(sa, ea.copy(), sb, aff_sub(ea, dd)))
            else:
                for t1 in range(-bound, bound + 1):
                    for t2 in range(-bound, bound + 1):
                        out.append(WitnessStep(sa, aff_sub(aff_const(m, t1), d[la]), sb, aff_sub(d[lb], aff_const(m, t2))))
    return out^


def search_witness(fam: ConeFamily, a0: Int, b0: Int, bound: Int, max_level: Int, end_pins: Bool = False) -> WitnessSearch:
    """Breadth-first search for a constant-offset witness path from `(a0, b0, 0)`
    to some `(a, a, 0)`, of length at most `max_level`."""
    var w = 2 * bound + 1
    var size = 9 * w * w * w
    var seen = List[Bool](length=size, fill=False)
    var parent = List[Int](length=size, fill=-1)
    var via = List[WitnessStep]()
    var via_of = List[Int](length=size, fill=-1)
    var fa = List[Int]()
    var fb = List[Int]()
    var fg = List[List[Int]]()
    var zero = List[Int]([0, 0, 0])
    var k0 = _key(a0, b0, zero, bound)
    seen[k0] = True
    fa.append(a0)
    fb.append(b0)
    fg.append(zero.copy())
    var out = WitnessSearch()
    for _ in range(max_level):
        var na = List[Int]()
        var nb = List[Int]()
        var ng = List[List[Int]]()
        for f in range(len(fa)):
            var kf = _key(fa[f], fb[f], fg[f], bound)
            var cands = _candidates(fam, fa[f], fb[f], fg[f], bound, end_pins)
            for c in range(len(cands)):
                var child = apply_step(fam, fa[f], fb[f], fg[f], cands[c])
                if not child.ok or not _in_box(child.gamma, bound):
                    continue
                var kc = _key(child.a, child.b, child.gamma, bound)
                if seen[kc]:
                    continue
                seen[kc] = True
                parent[kc] = kf
                via_of[kc] = len(via)
                via.append(cands[c].copy())
                if child.a == child.b and child.gamma == zero:
                    var rev = List[WitnessStep]()
                    var cur = kc
                    while cur != k0:
                        rev.append(via[via_of[cur]].copy())
                        cur = parent[cur]
                    for i in range(len(rev) - 1, -1, -1):
                        out.steps.append(rev[i].copy())
                    out.found = True
                    return out^
                na.append(child.a)
                nb.append(child.b)
                ng.append(child.gamma.copy())
        fa = na^
        fb = nb^
        fg = ng^
    return out^


def verify_witness(fam: ConeFamily, a0: Int, b0: Int, steps: List[WitnessStep], prover: Prover = Prover()) -> Bool:
    """Re-derive every state from the steps alone; true iff every condition
    holds on the whole cone and the path ends at `(a, a, 0)`."""
    if len(steps) == 0:
        return False
    var a = a0
    var b = b0
    var gamma = List[Int]([0, 0, 0])
    for l in range(len(steps)):
        var child = apply_step(fam, a, b, gamma, steps[l], prover)
        if not child.ok:
            return False
        a = child.a
        b = child.b
        gamma = child.gamma.copy()
    return a == b and gamma == List[Int]([0, 0, 0])


def witness_position(fam: ConeFamily, a0: Int, b0: Int, steps: List[WitnessStep], ns: List[Int]) raises -> Int:
    """The position of the shared tile in `sigma^n(a0)` at the cone point `ns`,
    for an independent check against the words themselves."""
    var sigma = fam.instantiate(ns)
    var a = a0
    var pos = 0
    var word = List[Int]([a0])
    for l in range(len(steps)):
        # position at level l + 1: length of sigma(word[:pos]) plus the offset
        var p2 = 0
        for k in range(pos):
            p2 += len(sigma[word[k]])
        var st = aff_eval(fam.start_of(a, steps[l].seg_a), ns)
        var off = aff_eval(steps[l].off_a, ns) if fam.images[a][steps[l].seg_a].is_run() else 0
        p2 += st + off
        var nxt = List[Int]()
        for k in range(len(word)):
            for c in range(len(sigma[word[k]])):
                nxt.append(sigma[word[k]][c])
        word = nxt^
        pos = p2
        a = word[pos]
    return pos


# ---------------------------------------------------------------------------
# Line mode: offsets affine along one direction. Lemma W needs nothing of the
# offsets but bookkeeping; what keeps every check affine is that `M gamma` be
# affine. With `gamma = c + lambda u`, `c` constant and `lambda` affine, that
# holds when `M u` is constant -- for Theorem K's family `u = e_z - e_y` and
# `M u = -delta`, constant once the cell fixes `delta`. `m_times_affine`
# computes `M gamma` as an exact quadratic and refuses it unless the
# quadratic part vanishes, so the mode fails closed if that premise fails.
# ---------------------------------------------------------------------------


def m_times_affine(fam: ConeFamily, gamma: List[List[Int]]) -> List[List[Int]]:
    """`M gamma` for affine `gamma`, or an empty list if it is not affine."""
    var m = fam.m
    var out = List[List[Int]]()
    for i in range(3):
        var acc = aff_const(m, 0)
        var quad = List[Int](length=(m + 1) * (m + 1), fill=0)
        for j in range(3):
            ref a = fam.incidence[3 * i + j]
            ref g = gamma[j]
            acc[0] += a[0] * g[0]
            for k in range(1, m + 1):
                acc[k] += a[0] * g[k] + a[k] * g[0]
                for l in range(1, m + 1):
                    quad[k * (m + 1) + l] += a[k] * g[l]
        for k in range(1, m + 1):
            for l in range(k, m + 1):
                var q = quad[k * (m + 1) + l] + (quad[l * (m + 1) + k] if l != k else 0)
                if q != 0:
                    return List[List[Int]]()
        out.append(acc^)
    return out^


struct LineResult(Copyable, Movable):
    var ok: Bool
    var a: Int
    var b: Int
    var gamma: List[List[Int]]

    def __init__(out self, ok: Bool, a: Int, b: Int, var gamma: List[List[Int]]):
        self.ok = ok
        self.a = a
        self.b = b
        self.gamma = gamma^


def _line_refused() -> LineResult:
    return LineResult(False, -1, -1, List[List[Int]]())


def apply_step_line(fam: ConeFamily, a: Int, b: Int, gamma: List[List[Int]], step: WitnessStep, prover: Prover = Prover()) -> LineResult:
    """A step with affine offsets: segment bounds and run offsets checked on
    the whole cone, `M gamma` required affine. No constancy is asked of the
    new offset; the path's end asks it to vanish identically."""
    if step.seg_a < 0 or step.seg_a >= len(fam.images[a]) or step.seg_b < 0 or step.seg_b >= len(fam.images[b]):
        return _line_refused()
    if not _offset_ok(fam, a, step.seg_a, step.off_a, prover) or not _offset_ok(fam, b, step.seg_b, step.off_b, prover):
        return _line_refused()
    var mg = m_times_affine(fam, gamma)
    if len(mg) == 0:
        return _line_refused()
    var pa = fam.prefix_before(a, step.seg_a)
    var pb = fam.prefix_before(b, step.seg_b)
    ref sa = fam.images[a][step.seg_a]
    ref sb = fam.images[b][step.seg_b]
    var g2 = List[List[Int]]()
    for i in range(3):
        var d = aff_sub(aff_add(mg[i], pa[i]), pb[i])
        if sa.is_run() and sa.letter == i:
            d = aff_add(d, step.off_a)
        if sb.is_run() and sb.letter == i:
            d = aff_sub(d, step.off_b)
        g2.append(d^)
    return LineResult(True, sa.letter, sb.letter, g2^)


def _is_zero(gamma: List[List[Int]]) -> Bool:
    for i in range(len(gamma)):
        for k in range(len(gamma[i])):
            if gamma[i][k] != 0:
                return False
    return True


def verify_witness_line(fam: ConeFamily, a0: Int, b0: Int, steps: List[WitnessStep], prover: Prover = Prover()) -> Bool:
    """Re-derive every state from the steps alone in line mode; true iff every
    condition holds on the whole cone and the path ends at `(a, a, 0)` with
    the offset identically zero."""
    if len(steps) == 0:
        return False
    var a = a0
    var b = b0
    var gamma = List[List[Int]]()
    for _ in range(3):
        gamma.append(aff_const(fam.m, 0))
    for l in range(len(steps)):
        var r = apply_step_line(fam, a, b, gamma, steps[l], prover)
        if not r.ok:
            return False
        a = r.a
        b = r.b
        gamma = r.gamma.copy()
    if a != b:
        return False
    for i in range(3):
        if not prover.vanishes(gamma[i]):
            return False
    return True


def _line_key(a: Int, b: Int, gamma: List[List[Int]]) -> String:
    var out = String(a) + ":" + String(b)
    for i in range(3):
        out += "|"
        for k in range(len(gamma[i])):
            out += String(gamma[i][k]) + ","
    return out


def _within(gamma: List[List[Int]], bound: Int) -> Bool:
    for i in range(3):
        for k in range(len(gamma[i])):
            if gamma[i][k] < -bound or gamma[i][k] > bound:
                return False
    return True


def within_line(gamma: List[List[Int]], bound: Int, ly: Int, lz: Int, line_cap: Int) -> Bool:
    """`_within`, or with `line_cap > 0` along the line `e_lz - e_ly` alone:
    the coordinate off the line and the `ly + lz` sum within `bound`, the
    position on the line (the `lz` coordinate) within `line_cap`."""
    if line_cap <= 0:
        return _within(gamma, bound)
    var lo = 3 - ly - lz
    for k in range(len(gamma[0])):
        var s = gamma[ly][k] + gamma[lz][k]
        if abs(gamma[lo][k]) > bound or abs(s) > bound or abs(gamma[lz][k]) > line_cap:
            return False
    return True


def _line_candidates(fam: ConeFamily, a: Int, b: Int, gamma: List[List[Int]], bound: Int, ly: Int, lz: Int) -> List[WitnessStep]:
    """Constant-target steps as in `_candidates`, plus steps that keep the new
    offset on the line `c + lambda (e_lz - e_ly)`: its other coordinate and
    its `ly + lz` sum constant, solving or pinning run offsets for that."""
    var out = List[WitnessStep]()
    var m = fam.m
    var mg = m_times_affine(fam, gamma)
    if len(mg) == 0:
        return out^
    var lo = 3 - ly - lz  # the coordinate off the line
    for sa in range(len(fam.images[a])):
        ref ga = fam.images[a][sa]
        if ga.kind == SEG_OPAQUE:
            continue
        var pa = fam.prefix_before(a, sa)
        var la = ga.letter if ga.is_run() else -1
        for sb in range(len(fam.images[b])):
            ref gb = fam.images[b][sb]
            if gb.kind == SEG_OPAQUE:
                continue
            var pb = fam.prefix_before(b, sb)
            var lb = gb.letter if gb.is_run() else -1
            var d = List[List[Int]]()
            for i in range(3):
                d.append(aff_sub(aff_add(mg[i], pa[i]), pb[i]))
            # constant targets, as before
            var fixed = True
            for i in range(3):
                if i != la and i != lb and not aff_is_const(d[i]):
                    fixed = False
            if fixed:
                if la < 0 and lb < 0:
                    out.append(WitnessStep(sa, aff_const(m, 0), sb, aff_const(m, 0)))
                elif lb < 0:
                    for t in range(-bound, bound + 1):
                        out.append(WitnessStep(sa, aff_sub(aff_const(m, t), d[la]), sb, aff_const(m, 0)))
                elif la < 0:
                    for t in range(-bound, bound + 1):
                        out.append(WitnessStep(sa, aff_const(m, 0), sb, aff_sub(d[lb], aff_const(m, t))))
                elif la != lb:
                    for t1 in range(-bound, bound + 1):
                        for t2 in range(-bound, bound + 1):
                            out.append(WitnessStep(sa, aff_sub(aff_const(m, t1), d[la]), sb, aff_sub(d[lb], aff_const(m, t2))))
            # line targets: coordinate lo constant, ly + lz sum constant
            if (la == lo or lb == lo) or not aff_is_const(d[lo]):
                continue
            var ssum = aff_add(d[ly], d[lz])
            var ra = la == ly or la == lz
            var rb = lb == ly or lb == lz
            for t in range(-bound, bound + 1):
                var need = aff_sub(aff_const(m, t), ssum)  # off_a - off_b must equal need
                if not ra and not rb:
                    if aff_is_const(need) and need[0] == 0:
                        out.append(WitnessStep(sa, aff_const(m, 0), sb, aff_const(m, 0)))
                elif ra and not rb:
                    out.append(WitnessStep(sa, need.copy(), sb, aff_const(m, 0)))
                elif rb and not ra:
                    out.append(WitnessStep(sa, aff_const(m, 0), sb, aff_scale(need, -1)))
                else:
                    for p in range(3):
                        out.append(WitnessStep(sa, aff_add(need, aff_const(m, p)), sb, aff_const(m, p)))
                        out.append(WitnessStep(sa, aff_const(m, p), sb, aff_sub(aff_const(m, p), need)))
                        var eb = aff_sub(gb.length, aff_const(m, p + 1))
                        out.append(WitnessStep(sa, aff_add(need, eb), sb, eb.copy()))
                        var ea = aff_sub(ga.length, aff_const(m, p + 1))
                        out.append(WitnessStep(sa, ea.copy(), sb, aff_sub(ea, need)))
    return out^


def search_witness_line(fam: ConeFamily, a0: Int, b0: Int, bound: Int, max_level: Int, ly: Int, lz: Int, line_cap: Int = 0) -> WitnessSearch:
    """Breadth-first search in line mode: offsets may be affine along
    `e_lz - e_ly`, with every coefficient within `bound`; with
    `line_cap > 0`, the position along the line within `line_cap` instead
    (`_within_line`: at a point the line offset `lambda` may be a run length)."""
    var out = WitnessSearch()
    var zero = List[List[Int]]()
    for _ in range(3):
        zero.append(aff_const(fam.m, 0))
    var seen = Dict[String, Int]()
    var parents = List[Int]()
    var vias = List[WitnessStep]()
    var sa_ = List[Int]()
    var sb_ = List[Int]()
    var sg = List[List[List[Int]]]()
    seen[_line_key(a0, b0, zero)] = 0
    parents.append(-1)
    vias.append(WitnessStep(0, aff_const(fam.m, 0), 0, aff_const(fam.m, 0)))
    sa_.append(a0)
    sb_.append(b0)
    sg.append(zero.copy())
    var start = 0
    for _ in range(max_level):
        var end = len(sa_)
        for f in range(start, end):
            var cands = _line_candidates(fam, sa_[f], sb_[f], sg[f], bound, ly, lz)
            for c in range(len(cands)):
                var r = apply_step_line(fam, sa_[f], sb_[f], sg[f], cands[c])
                if not r.ok or not within_line(r.gamma, bound, ly, lz, line_cap):
                    continue
                var key = _line_key(r.a, r.b, r.gamma)
                if key in seen:
                    continue
                seen[key] = len(sa_)
                parents.append(f)
                vias.append(cands[c].copy())
                sa_.append(r.a)
                sb_.append(r.b)
                sg.append(r.gamma.copy())
                if r.a == r.b and _is_zero(r.gamma):
                    var rev = List[WitnessStep]()
                    var cur = len(sa_) - 1
                    while cur != 0:
                        rev.append(vias[cur].copy())
                        cur = parents[cur]
                    for i in range(len(rev) - 1, -1, -1):
                        out.steps.append(rev[i].copy())
                    out.found = True
                    return out^
        start = end
    return out^


# ---------------------------------------------------------------------------
# Crossing closure (Lemma X of docs/p1a-a1-prime-2026-10-05.md §3j). Inside a
# range of segments that holds only the letters `u` and `v`, the prefix
# Parikh vector walks a monotone lattice path in the (u, v)-plane, its third
# coordinate constant. Two such paths P: p0 -> p1 and Q: q0 -> q1 whose
# levels |.| = u + v overlap share a lattice point strictly before both ends
# when Q starts weakly on one side of P and ends strictly on the other:
# g(n) = Q_u(n) - P_u(n) moves by at most 1 per level, is >= 0 at the first
# common level and < 0 at the last (or the mirror), so it vanishes before
# the last. Only the four endpoints are read, never the arrangement inside,
# so the ranges may cross opaque segments. At the shared point the next
# offset is 0 and both letters lie in {u, v}: equal letters are a shared
# tile, and unequal ones are one level from one when sigma(u) and sigma(v)
# begin with the same letter.
# ---------------------------------------------------------------------------


def monotone_paths_meet(p0: List[Int], p1: List[Int], q0: List[Int], q1: List[Int], interior_end: Bool) -> Bool:
    """Lemma X on integer endpoints `(u, v)`: monotone paths `P: p0 -> p1` and
    `Q: q0 -> q1` share a point at a level `< min(|p1|, |q1|)`, or `<=` it
    when `interior_end` (a letter follows both ends). `crossing_holds` is the
    same test with every endpoint an affine form on a cone."""
    var nlo = max(p0[0] + p0[1], q0[0] + q0[1])
    var nhi = min(p1[0] + p1[1], q1[0] + q1[1])
    if nlo > nhi or (nlo == nhi and not interior_end):
        return False
    var nw = q0[0] >= p0[0] and q0[1] <= p0[1]
    var se = q0[0] <= p0[0] and q0[1] >= p0[1]
    if interior_end:
        return (nw and q1[0] <= p1[0] and q1[1] >= p1[1]) or (se and q1[0] >= p1[0] and q1[1] <= p1[1])
    return (nw and q1[0] < p1[0] and q1[1] > p1[1]) or (se and q1[0] > p1[0] and q1[1] < p1[1])


struct CrossingClose(Copyable, Movable):
    """Segment ranges `[s0, s1)` of `sigma(a)` and `[t0, t1)` of `sigma(b)`."""

    var s0: Int
    var s1: Int
    var t0: Int
    var t1: Int

    def __init__(out self, s0: Int, s1: Int, t0: Int, t1: Int):
        self.s0 = s0
        self.s1 = s1
        self.t0 = t0
        self.t1 = t1


def _plane_range(fam: ConeFamily, a: Int, s0: Int, s1: Int, third: Int) -> Bool:
    """Every segment in `[s0, s1)` avoids the letter `third`."""
    if s0 < 0 or s1 > len(fam.images[a]) or s0 >= s1:
        return False
    for k in range(s0, s1):
        ref seg = fam.images[a][k]
        if seg.kind == SEG_OPAQUE:
            for c in range(len(seg.parikh[third])):
                if seg.parikh[third][c] != 0:
                    return False
        elif seg.letter == third:
            return False
    return True


def _plane_letter_at(fam: ConeFamily, a: Int, s: Int, u: Int, v: Int) -> Bool:
    """Segment `s` of `sigma(a)` exists, is nonempty, and holds `u` or `v`."""
    if s >= len(fam.images[a]):
        return False
    ref seg = fam.images[a][s]
    if seg.kind == SEG_OPAQUE or (seg.letter != u and seg.letter != v):
        return False
    return aff_nonneg(aff_sub(seg.length, aff_const(fam.m, 1)))


def _aff_lt(x: List[Int], y: List[Int]) -> Bool:
    """Sufficient for `x < y` on the whole cone."""
    return aff_nonneg(aff_sub(aff_sub(y, x), aff_const(len(x) - 1, 1)))


def _aff_le(x: List[Int], y: List[Int]) -> Bool:
    return aff_nonneg(aff_sub(y, x))


# Quadratic forms in the cone variables, as a flat (m + 1) x (m + 1) upper
# triangle: entry [0][0] the constant, [0][k] the coefficient of n_k, and
# [i][j] (1 <= i <= j) that of n_i n_j. At a closure M gamma may be quadratic
# when M has variable entries (a variable Delta) and gamma a variable line
# coefficient; Lemma X only compares such forms with affine ones.


def _qa(a: List[Int]) -> List[Int]:
    var m = len(a) - 1
    var q = List[Int](length=(m + 1) * (m + 1), fill=0)
    for k in range(m + 1):
        q[k] = a[k]
    return q^


def _q_lin(a: List[Int], b: List[Int], sb: Int) -> List[Int]:
    """`a + sb * b`."""
    var out = a.copy()
    for k in range(len(out)):
        out[k] += sb * b[k]
    return out^


def _q_minus_const(a: List[Int], c: Int) -> List[Int]:
    var out = a.copy()
    out[0] -= c
    return out^


def m_times_quad(fam: ConeFamily, gamma: List[List[Int]]) -> List[List[Int]]:
    """`M gamma` for affine `gamma`, as three quadratic forms."""
    var m = fam.m
    var w = m + 1
    var out = List[List[Int]]()
    for i in range(3):
        var q = List[Int](length=w * w, fill=0)
        for j in range(3):
            ref a = fam.incidence[3 * i + j]
            ref g = gamma[j]
            q[0] += a[0] * g[0]
            for k in range(1, w):
                q[k] += a[0] * g[k] + a[k] * g[0]
                for l in range(1, w):
                    var lo = min(k, l)
                    var hi = max(k, l)
                    q[lo * w + hi] += a[k] * g[l]
        out.append(q^)
    return out^


def _q_nonneg(q: List[Int]) -> Bool:
    for k in range(len(q)):
        if q[k] < 0:
            return False
    return True


def _q_nonneg_under(q: List[Int], prover: Prover) -> Bool:
    """A quadratic form is >= 0 on the region if it, less one or two of the
    region's affine assumptions times multipliers as in `Prover.nonneg`
    (read off its affine part), has nonnegative coefficients."""
    if _q_nonneg(q):
        return True
    ref A = prover.assume
    for i in range(len(A)):
        var m = len(A[i]) - 1
        var li = _multipliers(_q_affine_part(q, m), A[i])
        for x in range(len(li)):
            var g = _q_lin(q, _qa(A[i]), -li[x])
            if _q_nonneg(g):
                return True
            for j in range(i, len(A)):
                var lj = _multipliers(_q_affine_part(g, m), A[j])
                for y in range(len(lj)):
                    if _q_nonneg(_q_lin(g, _qa(A[j]), -lj[y])):
                        return True
    return False


def _q_quad_part_nonneg(q: List[Int], m: Int) -> Bool:
    var w = m + 1
    for i in range(1, w):
        for j in range(i, w):
            if q[i * w + j] < 0:
                return False
    return True


def _q_affine_part(q: List[Int], m: Int) -> List[Int]:
    var out = List[Int]()
    for k in range(m + 1):
        out.append(q[k])
    return out^


def _q_eval(q: List[Int], ns: List[Int]) -> Int:
    var w = len(ns) + 1
    var v = q[0]
    for k in range(1, w):
        v += q[k] * ns[k - 1]
        for l in range(k, w):
            v += q[k * w + l] * ns[k - 1] * ns[l - 1]
    return v


struct CrossingForms(Copyable, Movable):
    """Lemma X at one state and one pair of ranges: whether the structure
    holds, the third coordinate's offset (must vanish), and per variant
    (0: weak end, NW then SE; 1: weak, SE then NW; 2, 3: strict) the forms
    that must be nonnegative; a weak variant is empty when not allowed."""

    var ok: Bool
    var off: List[Int]
    var variants: List[List[List[Int]]]

    def __init__(out self):
        self.ok = False
        self.off = List[Int]()
        self.variants = List[List[List[Int]]]()


def _crossing_forms(fam: ConeFamily, a: Int, b: Int, gamma: List[List[Int]], u: Int, v: Int, cl: CrossingClose) -> CrossingForms:
    var out = CrossingForms()
    var third = 3 - u - v
    if not _plane_range(fam, a, cl.s0, cl.s1, third) or not _plane_range(fam, b, cl.t0, cl.t1, third):
        return out^
    ref hu = fam.images[u][0]
    ref hv = fam.images[v][0]
    if hu.kind != SEG_LETTER or hv.kind != SEG_LETTER or hu.letter != hv.letter:
        return out^
    var mg = m_times_quad(fam, gamma)
    var pa0 = fam.prefix_before(a, cl.s0)
    var pa1 = fam.prefix_before(a, cl.s1)
    var pb0 = fam.prefix_before(b, cl.t0)
    var pb1 = fam.prefix_before(b, cl.t1)
    out.off = _q_lin(_q_lin(mg[third], _qa(pa0[third]), 1), _qa(pb0[third]), -1)
    # The meeting point needs pre_a(i) = pre_b(k) - M gamma: Q = pre_b - M gamma.
    var q0u = _q_lin(_qa(pb0[u]), mg[u], -1)
    var q0v = _q_lin(_qa(pb0[v]), mg[v], -1)
    var q1u = _q_lin(_qa(pb1[u]), mg[u], -1)
    var q1v = _q_lin(_qa(pb1[v]), mg[v], -1)
    var p0u = _qa(pa0[u])
    var p0v = _qa(pa0[v])
    var p1u = _qa(pa1[u])
    var p1v = _qa(pa1[v])
    var lp0 = _q_lin(p0u, p0v, 1)
    var lp1 = _q_lin(p1u, p1v, 1)
    var lq0 = _q_lin(q0u, q0v, 1)
    var lq1 = _q_lin(q1u, q1v, 1)
    # Strict at the last common level unless both ranges stop before a
    # plane letter, which then follows the shared point even at that level.
    var inner = _plane_letter_at(fam, a, cl.s1, u, v) and _plane_letter_at(fam, b, cl.t1, u, v)
    for variant in range(4):
        var c = List[List[Int]]()
        var weak_end = variant < 2
        if weak_end and not inner:
            out.variants.append(c^)
            continue
        var slack = 0 if weak_end else 1
        c.append(_q_minus_const(_q_lin(lp1, lp0, -1), slack))
        c.append(_q_minus_const(_q_lin(lq1, lp0, -1), slack))
        c.append(_q_minus_const(_q_lin(lp1, lq0, -1), slack))
        c.append(_q_minus_const(_q_lin(lq1, lq0, -1), slack))
        if variant % 2 == 0:  # Q starts weakly NW, ends SE
            c.append(_q_lin(q0u, p0u, -1))
            c.append(_q_lin(p0v, q0v, -1))
            c.append(_q_minus_const(_q_lin(p1u, q1u, -1), slack))
            c.append(_q_minus_const(_q_lin(q1v, p1v, -1), slack))
        else:  # Q starts weakly SE, ends NW
            c.append(_q_lin(p0u, q0u, -1))
            c.append(_q_lin(q0v, p0v, -1))
            c.append(_q_minus_const(_q_lin(q1u, p1u, -1), slack))
            c.append(_q_minus_const(_q_lin(p1v, q1v, -1), slack))
        out.variants.append(c^)
    out.ok = True
    return out^


def crossing_holds(fam: ConeFamily, a: Int, b: Int, gamma: List[List[Int]], u: Int, v: Int, cl: CrossingClose, prover: Prover = Prover()) -> Bool:
    """Lemma X at the state `(a, b, gamma)`: every condition checked on the
    whole cone, so the state reaches a shared tile within two levels. A
    condition may be quadratic (variable `M` times a variable line
    coefficient); it holds if every coefficient is nonnegative."""
    var cf = _crossing_forms(fam, a, b, gamma, u, v, cl)
    if not cf.ok:
        return False
    if not _q_nonneg_under(cf.off, prover) or not _q_nonneg_under(_q_lin(_qa(aff_const(fam.m, 0)), cf.off, -1), prover):
        return False
    for variant in range(4):
        ref c = cf.variants[variant]
        if len(c) == 0:
            continue
        var all = True
        for k in range(len(c)):
            if not _q_nonneg_under(c[k], prover):
                all = False
        if all:
            return True
    return False


def find_crossing(fam: ConeFamily, a: Int, b: Int, gamma: List[List[Int]], u: Int, v: Int) -> List[CrossingClose]:
    """The first pair of segment ranges satisfying Lemma X, or an empty list."""
    var out = List[CrossingClose]()
    if (a != u and a != v) or (b != u and b != v):
        return out^
    var na = len(fam.images[a])
    var nb = len(fam.images[b])
    for s0 in range(na):
        for s1 in range(s0 + 1, na + 1):
            if not _plane_range(fam, a, s0, s1, 3 - u - v):
                break
            for t0 in range(nb):
                for t1 in range(t0 + 1, nb + 1):
                    if not _plane_range(fam, b, t0, t1, 3 - u - v):
                        break
                    var cl = CrossingClose(s0, s1, t0, t1)
                    if crossing_holds(fam, a, b, gamma, u, v, cl):
                        out.append(cl^)
                        return out^
    return out^


struct CrossingSearch(Copyable, Movable):
    var found: Bool
    var steps: List[WitnessStep]
    var close: List[CrossingClose]

    def __init__(out self):
        self.found = False
        self.steps = List[WitnessStep]()
        self.close = List[CrossingClose]()


def search_crossing(fam: ConeFamily, a0: Int, b0: Int, bound: Int, max_level: Int, ly: Int, lz: Int, u: Int, v: Int) -> CrossingSearch:
    """Breadth-first search, in line mode, for a path to a state that Lemma X
    closes."""
    var out = CrossingSearch()
    var zero = List[List[Int]]()
    for _ in range(3):
        zero.append(aff_const(fam.m, 0))
    var seen = Dict[String, Int]()
    var parents = List[Int]()
    var vias = List[WitnessStep]()
    var sa_ = List[Int]()
    var sb_ = List[Int]()
    var sg = List[List[List[Int]]]()
    seen[_line_key(a0, b0, zero)] = 0
    parents.append(-1)
    vias.append(WitnessStep(0, aff_const(fam.m, 0), 0, aff_const(fam.m, 0)))
    sa_.append(a0)
    sb_.append(b0)
    sg.append(zero.copy())
    var start = 0
    for level in range(max_level + 1):
        var end = len(sa_)
        for f in range(start, end):
            var cl = find_crossing(fam, sa_[f], sb_[f], sg[f], u, v)
            if len(cl) > 0:
                var rev = List[WitnessStep]()
                var cur = f
                while cur != 0:
                    rev.append(vias[cur].copy())
                    cur = parents[cur]
                for i in range(len(rev) - 1, -1, -1):
                    out.steps.append(rev[i].copy())
                out.close.append(cl[0].copy())
                out.found = True
                return out^
        if level == max_level:
            break
        for f in range(start, end):
            var cands = _line_candidates(fam, sa_[f], sb_[f], sg[f], bound, ly, lz)
            for c in range(len(cands)):
                var r = apply_step_line(fam, sa_[f], sb_[f], sg[f], cands[c])
                if not r.ok or not _within(r.gamma, bound):
                    continue
                var key = _line_key(r.a, r.b, r.gamma)
                if key in seen:
                    continue
                seen[key] = len(sa_)
                parents.append(f)
                vias.append(cands[c].copy())
                sa_.append(r.a)
                sb_.append(r.b)
                sg.append(r.gamma.copy())
        start = end
    return out^


def verify_crossing(fam: ConeFamily, a0: Int, b0: Int, steps: List[WitnessStep], cl: CrossingClose, u: Int, v: Int, prover: Prover = Prover()) -> Bool:
    """Re-derive the path's last state in line mode and check Lemma X there."""
    var a = a0
    var b = b0
    var gamma = List[List[Int]]()
    for _ in range(3):
        gamma.append(aff_const(fam.m, 0))
    for l in range(len(steps)):
        var r = apply_step_line(fam, a, b, gamma, steps[l], prover)
        if not r.ok:
            return False
        a = r.a
        b = r.b
        gamma = r.gamma.copy()
    return crossing_holds(fam, a, b, gamma, u, v, cl, prover)


# ---------------------------------------------------------------------------
# Lifting a certificate found at one point of a region (docs/p1a-a1-prime-
# 2026-10-05.md §3k). A region of a cone is the image of an orthant; at a base
# point `ns` it is a single substitution, where `search_witness_line` or
# `search_crossing` may find a certificate. `lift_path` replays it on the
# region: the same segments, and among the line candidates of each step the
# one whose offset agrees with the point's. Instead of requiring each
# condition on the whole region, it collects the affine forms that must be
# nonnegative there. The certificate holds wherever they all are, a region
# containing `ns`; carving it out is the caller's business, and the carved
# piece is checked again by the ordinary verifiers.
# ---------------------------------------------------------------------------


struct CollectResult(Copyable, Movable):
    var ok: Bool
    var a: Int
    var b: Int
    var gamma: List[List[Int]]
    var ineqs: List[List[Int]]

    def __init__(out self, ok: Bool, a: Int, b: Int, var gamma: List[List[Int]], var ineqs: List[List[Int]]):
        self.ok = ok
        self.a = a
        self.b = b
        self.gamma = gamma^
        self.ineqs = ineqs^


def _collect_refused() -> CollectResult:
    return CollectResult(False, -1, -1, List[List[Int]](), List[List[Int]]())


def _offset_needs(fam: ConeFamily, a: Int, s: Int, off: List[Int], mut ineqs: List[List[Int]]) -> Bool:
    """The forms that place `off` inside segment `s`; false if impossible."""
    ref seg = fam.images[a][s]
    if seg.kind == SEG_OPAQUE:
        return False
    if seg.kind == SEG_LETTER:
        for k in range(len(off)):
            if off[k] != 0:
                return False
        return True
    ineqs.append(off.copy())
    ineqs.append(aff_sub(aff_sub(seg.length, off), aff_const(fam.m, 1)))
    return True


def apply_step_collect(fam: ConeFamily, a: Int, b: Int, gamma: List[List[Int]], step: WitnessStep) -> CollectResult:
    """`apply_step_line`, with the offset bounds returned instead of checked."""
    if step.seg_a < 0 or step.seg_a >= len(fam.images[a]) or step.seg_b < 0 or step.seg_b >= len(fam.images[b]):
        return _collect_refused()
    var ineqs = List[List[Int]]()
    if not _offset_needs(fam, a, step.seg_a, step.off_a, ineqs) or not _offset_needs(fam, b, step.seg_b, step.off_b, ineqs):
        return _collect_refused()
    var mg = m_times_affine(fam, gamma)
    if len(mg) == 0:
        return _collect_refused()
    var pa = fam.prefix_before(a, step.seg_a)
    var pb = fam.prefix_before(b, step.seg_b)
    ref sa = fam.images[a][step.seg_a]
    ref sb = fam.images[b][step.seg_b]
    var g2 = List[List[Int]]()
    for i in range(3):
        var d = aff_sub(aff_add(mg[i], pa[i]), pb[i])
        if sa.is_run() and sa.letter == i:
            d = aff_add(d, step.off_a)
        if sb.is_run() and sb.letter == i:
            d = aff_sub(d, step.off_b)
        g2.append(d^)
    return CollectResult(True, sa.letter, sb.letter, g2^, ineqs^)


def _all_at_least_zero(forms: List[List[Int]], ns: List[Int]) -> Bool:
    for k in range(len(forms)):
        if aff_eval(forms[k], ns) < 0:
            return False
    return True


def _hard_count(forms: List[List[Int]]) -> Int:
    """Forms not already nonnegative on the whole orthant."""
    var n = 0
    for k in range(len(forms)):
        if not aff_nonneg(forms[k]):
            n += 1
    return n


struct LiftResult(Copyable, Movable):
    var ok: Bool
    var steps: List[WitnessStep]
    var ineqs: List[List[Int]]
    var a: Int
    var b: Int
    var gamma: List[List[Int]]
    var why: String  # when not ok: the level and the condition that stopped it

    def __init__(out self):
        self.ok = False
        self.steps = List[WitnessStep]()
        self.ineqs = List[List[Int]]()
        self.a = -1
        self.b = -1
        self.gamma = List[List[Int]]()
        self.why = String()


def lift_path(fam: ConeFamily, point: ConeFamily, ns: List[Int], a0: Int, b0: Int, steps: List[WitnessStep], bound: Int, ly: Int, lz: Int) -> LiftResult:
    """Replay the point family's `steps` on the region family `fam` (the same
    segments; `point` is `fam` at `ns`), collecting the forms each step needs.
    Every collected form is nonnegative at `ns`."""
    var out = LiftResult()
    var a = a0
    var b = b0
    var gr = List[List[Int]]()
    var gp = List[List[Int]]()
    for _ in range(3):
        gr.append(aff_const(fam.m, 0))
        gp.append(aff_const(0, 0))
    var ap = a0
    var bp = b0
    for l in range(len(steps)):
        var rp = apply_step_line(point, ap, bp, gp, steps[l])
        if not rp.ok:
            out.why = "level " + String(l) + ": the point path does not replay"
            return out^
        if len(m_times_affine(fam, gr)) == 0:
            out.why = "level " + String(l) + ": M gamma is quadratic on the region"
            return out^
        var cands = _line_candidates(fam, a, b, gr, bound, ly, lz)
        var best = -1
        var best_hard = 1 << 30
        var best_res = _collect_refused()
        for c in range(len(cands)):
            if cands[c].seg_a != steps[l].seg_a or cands[c].seg_b != steps[l].seg_b:
                continue
            var rc = apply_step_collect(fam, a, b, gr, cands[c])
            if not rc.ok or rc.a != rp.a or rc.b != rp.b:
                continue
            var agrees = True
            for i in range(3):
                if aff_eval(rc.gamma[i], ns) != rp.gamma[i][0]:
                    agrees = False
            if not agrees or not _all_at_least_zero(rc.ineqs, ns):
                continue
            var hard = _hard_count(rc.ineqs)
            if hard < best_hard:
                best = c
                best_hard = hard
                best_res = rc^
        if best < 0:
            out.why = "level " + String(l) + ": no line candidate agrees with the point"
            return out^
        out.steps.append(cands[best].copy())
        for k in range(len(best_res.ineqs)):
            out.ineqs.append(best_res.ineqs[k].copy())
        a = best_res.a
        b = best_res.b
        gr = best_res.gamma.copy()
        ap = rp.a
        bp = rp.b
        gp = rp.gamma.copy()
    out.ok = True
    out.a = a
    out.b = b
    out.gamma = gr^
    return out^


def crossing_conditions(fam: ConeFamily, a: Int, b: Int, gamma: List[List[Int]], u: Int, v: Int, cl: CrossingClose, ns: List[Int], mut ineqs: List[List[Int]]) -> Bool:
    """The affine forms under which `crossing_holds` holds, in a variant that
    holds at `ns`. A quadratic condition enters as its affine part when its
    quadratic part is coefficientwise nonnegative (then the affine part being
    nonnegative suffices), and makes the variant unusable otherwise; the
    third coordinate's vanishing enters as a pair of opposite forms and must
    be affine. False if no variant qualifies."""
    var cf = _crossing_forms(fam, a, b, gamma, u, v, cl)
    if not cf.ok or not _q_quad_part_nonneg(cf.off, fam.m) or not _q_quad_part_nonneg(_q_lin(_qa(aff_const(fam.m, 0)), cf.off, -1), fam.m):
        return False
    var off = _q_affine_part(cf.off, fam.m)
    for variant in range(4):
        ref c = cf.variants[variant]
        if len(c) == 0:
            continue
        var forms = List[List[Int]]()
        forms.append(off.copy())
        forms.append(aff_scale(off, -1))
        var usable = True
        for k in range(len(c)):
            if not _q_quad_part_nonneg(c[k], fam.m) or _q_eval(c[k], ns) < 0:
                usable = False
                break
            forms.append(_q_affine_part(c[k], fam.m))
        if usable and _all_at_least_zero(forms, ns):
            for k in range(len(forms)):
                ineqs.append(forms[k].copy())
            return True
    return False
