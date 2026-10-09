"""Polynomial line mode: witness paths whose offsets are polynomials.

docs/p1a-a1-prime-2026-10-05.md §3l. Line mode (`psc.cone_witness`) keeps the
offset on a line `c + lambda (e_z - e_y)` and needs `M gamma` affine. In a
cell with `Delta` fixed that holds, as `M (e_z - e_y) = (0, -Delta, -s)` is a
constant. With `Delta = 1 + e` symbolic, a variable `lambda` makes
`lambda M (e_z - e_y)` quadratic, and affine line mode refuses the step.

Here offsets, states and the conditions on them are integer polynomials in
the region's variables, of degree at most `POLY_DEGREE`. The search stays
at a point, in ordinary line mode; only the lift and the verifier are
polynomial. Nothing else changes: a path is verified by recomputing every state from the step data,
each condition is proved on the region (`poly_nonneg_under`: the polynomial
less multiples of at most two of the region's affine assumptions has every
coefficient `>= 0`, so it is `>= 0` at every point), and the end offset must
vanish on the region. A lift carves by a condition's affine part only when
the rest has every coefficient `>= 0` (then the affine part being `>= 0`
suffices); the re-verification proves each condition again.

With a product lift (`psc.product_lift`, §3m) the region's variables are
`(n, q)` and every condition and end offset is rewritten exactly as an
affine form over them (`lift_affine`; anything else is refused), carved by
and proved with the ordinary affine prover. A polynomial equals its lifted
form at every real point `q = n e`, so a proof on the whole polyhedron holds
at its real points.
"""

from std.collections import Dict
from std.os import abort
from finite_exact.rat_q import Q
from psc.product_lift import ProductLift, lift_affine, lift_point, lifted_monomial, no_lift
from finite_linear_algebra.qlinalg import rref
from finite_linear_algebra.scalar import q_int, q_is_zero
from psc.cone_witness import (
    ConeFamily,
    Prover,
    SEG_LETTER,
    SEG_OPAQUE,
    WitnessStep,
    aff_const,
    aff_eval,
    aff_nonneg,
    aff_sub,
    apply_step_line,
    CrossingClose,
    _is_zero,
    _plane_letter_at,
    _plane_range,
    _line_candidates,
    _multipliers,
    within_line,
)

comptime POLY_DEGREE = 8  # the largest degree a state, offset or condition may reach
comptime SCREEN_PRIME_1 = 2147483629  # primes below 2^31: products stay within Int
comptime SCREEN_PRIME_2 = 2147483587
comptime SEARCH_DEGREE = 3  # the degree the lift's candidate search may reach
comptime LIFT_NODES = 4000  # nodes of the lift's depth-first search over candidates
comptime COST_BITS = 24  # with a lift: a lift's key is extent << COST_BITS less its capped cost


# ---------------------------------------------------------------------------
# Sparse integer polynomials. A monomial is the ascending list of its
# variables' indices (0-based, repeats for powers), packed into an Int:
# index + 1 in successive 5-bit fields from the low end, so at most
# `MAX_VARS` variables and degree `MAX_PACKED_DEGREE`; the constant is 0.
# ---------------------------------------------------------------------------

comptime MONO_BITS = 5
comptime MONO_MASK = 31
comptime MAX_VARS = 30
comptime MAX_PACKED_DEGREE = 12


def mono_var(k: Int) -> Int:
    """The packed monomial `n_k`; a variable past the field aborts."""
    if k < 0 or k >= MAX_VARS:
        abort("a polynomial variable past the packed field")
    return k + 1


def _mono_degree(key: Int) -> Int:
    var d = 0
    var x = key
    while x != 0:
        d += 1
        x >>= MONO_BITS
    return d


def _mono_mul(a: Int, b: Int) -> Int:
    """The product of two packed monomials: a merge of two ascending runs."""
    var out = 0
    var shift = 0
    var x = a
    var y = b
    while x != 0 or y != 0:
        var dx = x & MONO_MASK
        var dy = y & MONO_MASK
        if dy == 0 or (dx != 0 and dx <= dy):
            out |= dx << shift
            x >>= MONO_BITS
        else:
            out |= dy << shift
            y >>= MONO_BITS
        shift += MONO_BITS
    return out


def _mono_render(key: Int) -> String:
    var out = String()
    var x = key
    var first = True
    while x != 0:
        if not first:
            out += "."
        out += String((x & MONO_MASK) - 1)
        first = False
        x >>= MONO_BITS
    return out


struct Poly(Copyable, Movable):
    """An integer polynomial: packed monomial -> nonzero coefficient."""

    var terms: Dict[Int, Int]

    def __init__(out self):
        self.terms = Dict[Int, Int]()

    def add_term(mut self, key: Int, c: Int):
        if c == 0:
            return
        var v = self.terms.get(key, 0) + c
        if v == 0:
            _ = self.terms.pop(key, 0)
        else:
            self.terms[key] = v


def poly_const(c: Int) -> Poly:
    var p = Poly()
    p.add_term(0, c)
    return p^


def poly_from_aff(a: List[Int]) -> Poly:
    """`a[0] + sum a[k] n_(k-1)`."""
    var p = Poly()
    p.add_term(0, a[0])
    for k in range(1, len(a)):
        p.add_term(mono_var(k - 1), a[k])
    return p^


def poly_add(p: Poly, q: Poly) -> Poly:
    var out = p.copy()
    for e in q.terms.items():
        out.add_term(e.key, e.value)
    return out^


def poly_scale(p: Poly, s: Int) -> Poly:
    var out = Poly()
    for e in p.terms.items():
        out.add_term(e.key, s * e.value)
    return out^


def poly_sub(p: Poly, q: Poly) -> Poly:
    return poly_add(p, poly_scale(q, -1))


def poly_mul(p: Poly, q: Poly) raises -> Poly:
    var qk = List[Int]()
    var qc = List[Int]()
    for f in q.terms.items():
        qk.append(f.key)
        qc.append(f.value)
    var out = Poly()
    for e in p.terms.items():
        for j in range(len(qk)):
            if _mono_degree(e.key) + _mono_degree(qk[j]) > MAX_PACKED_DEGREE:
                raise Error("a polynomial product past the packed degree")
            out.add_term(_mono_mul(e.key, qk[j]), e.value * qc[j])
    return out^


def poly_degree(p: Poly) raises -> Int:
    var d = 0
    for e in p.terms.items():
        d = max(d, _mono_degree(e.key))
    return d


def poly_eval(p: Poly, ns: List[Int]) raises -> Int:
    var total = 0
    for e in p.terms.items():
        var t = e.value
        var x = e.key
        while x != 0:
            t *= ns[(x & MONO_MASK) - 1]
            x >>= MONO_BITS
        total += t
    return total


def poly_is_zero(p: Poly) -> Bool:
    return len(p.terms) == 0


def poly_is_const(p: Poly) -> Bool:
    for e in p.terms.items():
        if e.key != 0:
            return False
    return True


def poly_affine_part(p: Poly, m: Int) raises -> List[Int]:
    var out = aff_const(m, 0)
    for e in p.terms.items():
        if e.key == 0:
            out[0] += e.value
        elif _mono_degree(e.key) == 1:
            out[e.key] += e.value  # mono_var(k) = k + 1 is the form's slot
    return out^


def poly_higher(p: Poly) raises -> Poly:
    """The terms of degree at least 2."""
    var out = Poly()
    for e in p.terms.items():
        if _mono_degree(e.key) >= 2:
            out.add_term(e.key, e.value)
    return out^


def poly_nonneg(p: Poly) -> Bool:
    """Every coefficient `>= 0`: then `p >= 0` on the orthant."""
    for e in p.terms.items():
        if e.value < 0:
            return False
    return True


def poly_nonneg_under(p: Poly, prover: Prover) raises -> Bool:
    """`p >= 0` on a region: `p`, or `p` less multiples of one or two of its
    affine assumptions (multipliers as in `Prover.nonneg`, read off `p`'s
    affine part), has every coefficient `>= 0`."""
    if poly_nonneg(p):
        return True
    ref A = prover.assume
    for i in range(len(A)):
        var m = len(A[i]) - 1
        var li = _multipliers(poly_affine_part(p, m), A[i])
        for x in range(len(li)):
            var g = poly_sub(p, poly_scale(poly_from_aff(A[i]), li[x]))
            if poly_nonneg(g):
                return True
            for j in range(i, len(A)):
                var lj = _multipliers(poly_affine_part(g, m), A[j])
                for y in range(len(lj)):
                    if poly_nonneg(poly_sub(g, poly_scale(poly_from_aff(A[j]), lj[y]))):
                        return True
    return False


def poly_vanishes_under(p: Poly, prover: Prover) raises -> Bool:
    return poly_nonneg_under(p, prover) and poly_nonneg_under(poly_scale(p, -1), prover)


def _lifted(lift: ProductLift, p: Poly) -> List[Int]:
    """`lift_affine`, or empty when `p` is not affine over the lift."""
    try:
        return lift_affine(lift, p)
    except:
        return List[Int]()


def holds_under(p: Poly, prover: Prover, lift: ProductLift) raises -> Bool:
    """`p >= 0` on the region: `poly_nonneg_under`, or with a lift, its
    lifted form proved `>= 0` by the affine prover over `(n, q)`."""
    if not lift.on():
        return poly_nonneg_under(p, prover)
    var f = _lifted(lift, p)
    return len(f) > 0 and prover.nonneg(f)


def vanishes_under(p: Poly, prover: Prover, lift: ProductLift) raises -> Bool:
    return holds_under(p, prover, lift) and holds_under(poly_scale(p, -1), prover, lift)


def poly_key(p: Poly) -> String:
    """A canonical rendering, for deduplication and diagnostics."""
    var keys = List[Int]()
    for e in p.terms.items():
        keys.append(e.key)
    sort(keys)
    var out = String()
    for k in range(len(keys)):
        out += "[" + _mono_render(keys[k]) + "]" + String(p.terms.get(keys[k], 0)) + " "
    return out^


# ---------------------------------------------------------------------------
# Line mode over polynomials.
# ---------------------------------------------------------------------------


struct PolyStep(Copyable, Movable):
    """A step: segment `seg_a` of `sigma(a)` at offset `off_a`, and the same
    for `b`; offsets are polynomials (0 for a letter segment)."""

    var seg_a: Int
    var off_a: Poly
    var seg_b: Int
    var off_b: Poly

    def __init__(out self, seg_a: Int, var off_a: Poly, seg_b: Int, var off_b: Poly):
        self.seg_a = seg_a
        self.off_a = off_a^
        self.seg_b = seg_b
        self.off_b = off_b^


struct PolyState(Copyable, Movable):
    """The state a step leads to and the conditions (polynomials that must be
    `>= 0`) under which it is a step; `ok` false if structurally refused."""

    var ok: Bool
    var a: Int
    var b: Int
    var gamma: List[Poly]
    var conds: List[Poly]

    def __init__(out self):
        self.ok = False
        self.a = -1
        self.b = -1
        self.gamma = List[Poly]()
        self.conds = List[Poly]()


def m_times_poly(fam: ConeFamily, gamma: List[Poly], cap: Int = POLY_DEGREE) raises -> List[Poly]:
    """`M gamma`, or an empty list past degree `cap`."""
    var out = List[Poly]()
    for i in range(3):
        var acc = Poly()
        for j in range(3):
            acc = poly_add(acc, poly_mul(poly_from_aff(fam.incidence[3 * i + j]), gamma[j]))
        if poly_degree(acc) > cap:
            return List[Poly]()
        out.append(acc^)
    return out^


def _offset_conditions(fam: ConeFamily, a: Int, s: Int, off: Poly, mut conds: List[Poly]) raises -> Bool:
    """The conditions placing `off` inside segment `s`; false if impossible."""
    ref seg = fam.images[a][s]
    if seg.kind == SEG_OPAQUE:
        return False
    if seg.kind == SEG_LETTER:
        return poly_is_zero(off)
    conds.append(off.copy())
    conds.append(poly_sub(poly_sub(poly_from_aff(seg.length), off), poly_const(1)))
    return True


def poly_step(fam: ConeFamily, a: Int, b: Int, gamma: List[Poly], step: PolyStep, cap: Int = POLY_DEGREE) raises -> PolyState:
    """`gamma' = M gamma + pi(sigma(a)[:i]) - pi(sigma(b)[:k])`, with the
    run offsets added in their letters' coordinates, and the offset
    conditions."""
    var out = PolyState()
    if step.seg_a < 0 or step.seg_a >= len(fam.images[a]) or step.seg_b < 0 or step.seg_b >= len(fam.images[b]):
        return out^
    if not _offset_conditions(fam, a, step.seg_a, step.off_a, out.conds) or not _offset_conditions(fam, b, step.seg_b, step.off_b, out.conds):
        return out^
    var mg = m_times_poly(fam, gamma, cap)
    if len(mg) == 0:
        return out^
    var pa = fam.prefix_before(a, step.seg_a)
    var pb = fam.prefix_before(b, step.seg_b)
    ref sa = fam.images[a][step.seg_a]
    ref sb = fam.images[b][step.seg_b]
    for i in range(3):
        var d = poly_sub(poly_add(mg[i], poly_from_aff(pa[i])), poly_from_aff(pb[i]))
        if sa.is_run() and sa.letter == i:
            d = poly_add(d, step.off_a)
        if sb.is_run() and sb.letter == i:
            d = poly_sub(d, step.off_b)
        if poly_degree(d) > cap:
            return PolyState()
        out.gamma.append(d^)
    out.ok = True
    out.a = sa.letter
    out.b = sb.letter
    return out^


def verify_witness_poly(fam: ConeFamily, a0: Int, b0: Int, steps: List[PolyStep], prover: Prover, lift: ProductLift = no_lift()) raises -> Bool:
    """Re-derive every state from the steps alone; true iff every offset
    condition is proved on the region and the path ends at `(a, a, 0)` with
    the offset proved to vanish there (over `(n, q)` with a lift)."""
    if len(steps) == 0:
        return False
    var a = a0
    var b = b0
    var gamma = List[Poly]()
    for _ in range(3):
        gamma.append(Poly())
    for l in range(len(steps)):
        var r = poly_step(fam, a, b, gamma, steps[l])
        if not r.ok:
            return False
        for k in range(len(r.conds)):
            if not holds_under(r.conds[k], prover, lift):
                return False
        a = r.a
        b = r.b
        gamma = r.gamma.copy()
    if a != b:
        return False
    for i in range(3):
        if not vanishes_under(gamma[i], prover, lift):
            return False
    return True


def _anchors(fam: ConeFamily, a: Int, s: Int, v: Int, ns: List[Int]) -> List[Poly]:
    """Offsets into segment `s` of `sigma(a)` taking the value `v` at `ns`:
    `v` itself, and `v` counted from the segment's end."""
    var out = List[Poly]()
    ref seg = fam.images[a][s]
    if not seg.is_run():
        out.append(Poly())
        return out^
    out.append(poly_const(v))
    var end = poly_add(poly_sub(poly_from_aff(seg.length), poly_const(aff_eval(seg.length, ns))), poly_const(v))
    out.append(end^)
    return out^


def _lift_candidates(fam: ConeFamily, a: Int, b: Int, gamma: List[Poly], sa: Int, va: Int, sb: Int, vb: Int, target: List[Int], ns: List[Int], ly: Int, lz: Int, free_line: Bool = False) raises -> List[PolyStep]:
    """Steps on segments `sa`, `sb` whose offsets take the point's values
    `va`, `vb` at `ns`: each offset anchored at the segment's start or end,
    or solved so that its letter's coordinate of the new state is the
    constant `target` (the point's new state), or, for two runs in the line
    letters, one solved from the other so that the `ly + lz` sum is
    constant. Candidates are filtered by their values at `ns`. With
    `free_line` no offset is solved for a constant line coordinate: there
    the point's position on the line is a run length, and pinning it would
    carve a slice."""
    var out = List[PolyStep]()
    var mg = m_times_poly(fam, gamma, SEARCH_DEGREE)
    if len(mg) == 0:
        return out^
    ref ga = fam.images[a][sa]
    ref gb = fam.images[b][sb]
    if ga.kind == SEG_OPAQUE or gb.kind == SEG_OPAQUE:
        return out^
    var pa = fam.prefix_before(a, sa)
    var pb = fam.prefix_before(b, sb)
    var d = List[Poly]()
    for i in range(3):
        d.append(poly_sub(poly_add(mg[i], poly_from_aff(pa[i])), poly_from_aff(pb[i])))
    var la = ga.letter if ga.is_run() else -1
    var lb = gb.letter if gb.is_run() else -1
    var offs_a = _anchors(fam, a, sa, va, ns)
    var offs_b = _anchors(fam, b, sb, vb, ns)
    if la >= 0 and la != lb and not (free_line and (la == ly or la == lz)):
        offs_a.append(poly_sub(poly_const(target[la]), d[la]))
    if lb >= 0 and lb != la and not (free_line and (lb == ly or lb == lz)):
        offs_b.append(poly_sub(d[lb], poly_const(target[lb])))
    var base_a = len(offs_a)
    var base_b = len(offs_b)
    if (la == ly or la == lz) and (lb == ly or lb == lz):
        var need = poly_sub(poly_const(target[ly] + target[lz]), poly_add(d[ly], d[lz]))
        for k in range(base_b):
            offs_a.append(poly_add(need, offs_b[k]))
        for k in range(base_a):
            offs_b.append(poly_sub(offs_a[k], need))
    for i in range(len(offs_a)):
        if poly_eval(offs_a[i], ns) != va:
            continue
        for j in range(len(offs_b)):
            if poly_eval(offs_b[j], ns) != vb:
                continue
            out.append(PolyStep(sa, offs_a[i].copy(), sb, offs_b[j].copy()))
    return out^


struct PolyLift(Copyable, Movable):
    var ok: Bool
    var steps: List[PolyStep]
    var ineqs: List[List[Int]]  # affine carving forms, each >= 0 at the base point
    var a: Int
    var b: Int
    var gamma: List[Poly]
    var why: String

    def __init__(out self):
        self.ok = False
        self.steps = List[PolyStep]()
        self.ineqs = List[List[Int]]()
        self.a = -1
        self.b = -1
        self.gamma = List[Poly]()
        self.why = String()


def carving_forms_of(conds: List[Poly], m: Int, ns: List[Int], mut ineqs: List[List[Int]], lift: ProductLift = no_lift()) raises -> Bool:
    """Affine forms implying each condition: its affine part, usable when the
    rest has every coefficient `>= 0` and the part is `>= 0` at `ns`; with a
    lift, the condition's exact form over `(n, q)`, `>= 0` at the real point
    `ns`."""
    for k in range(len(conds)):
        var f = _lifted(lift, conds[k]) if lift.on() else poly_affine_part(conds[k], m)
        if len(f) == 0 or (not lift.on() and not poly_nonneg(poly_higher(conds[k]))):
            return False
        if aff_eval(f, ns) < 0:
            return False
        if not aff_nonneg(f):
            ineqs.append(f^)
    return True


struct _LiftFrame(Copyable, Movable):
    var level: Int
    var a: Int
    var b: Int
    var gamma: List[Poly]
    var steps: List[PolyStep]
    var ineqs: List[List[Int]]

    def __init__(out self, level: Int, a: Int, b: Int, var gamma: List[Poly], var steps: List[PolyStep], var ineqs: List[List[Int]]):
        self.level = level
        self.a = a
        self.b = b
        self.gamma = gamma^
        self.steps = steps^
        self.ineqs = ineqs^


def _affine_end(gamma: List[Poly], lift: ProductLift) raises -> Bool:
    """No term of degree >= 2, or with a lift, affine over `(n, q)`."""
    for i in range(3):
        if lift.on():
            if len(_lifted(lift, gamma[i])) == 0:
                return False
        elif not poly_is_zero(poly_higher(gamma[i])):
            return False
    return True


def lifts_to_zero(gamma: List[Poly], lift: ProductLift) raises -> Bool:
    """Every end offset lifts to the zero form over `(n, q)` (and lifts)."""
    for i in range(len(gamma)):
        var f = _lifted(lift, gamma[i])
        if len(f) == 0 or not _is_zero(List[List[Int]]([f^])):
            return False
    return True


def lift_path_poly(fam: ConeFamily, point: ConeFamily, ns: List[Int], a0: Int, b0: Int, steps: List[WitnessStep], ly: Int, lz: Int, lift: ProductLift = no_lift(), probes: List[List[Int]] = List[List[Int]]()) raises -> PolyLift:
    """`psc.cone_witness.lift_path` over polynomials: replay the point
    family's `steps` on the region family. At each level the candidates are
    built from the point's step (`_lift_candidates`, offsets agreeing with
    the point's) and must reach the point's letters and carve by affine
    forms. A depth-first search over them (lowest degree, then fewest forms,
    first; at most `LIFT_NODES` nodes) returns the first lift whose end
    offset has no term of degree >= 2, so that it can vanish on a region
    (with a lift: whose conditions and end offset are affine over `(n, q)`,
    `ns` then a real point of width `1 + m + m'`). With a lift the search
    does not stop at the first such lift: it ranks children by whether
    their state is affine over `(n, q)` and returns the complete lift of
    largest `lift_key` on `probes` (`probe_points` of the region), so
    a lift that copies the base point's run lengths into its offsets (and
    so carves a slice) loses to one uniform over the region."""
    var out = PolyLift()
    _check_width(fam, lift)
    # the point path's states, level by level
    var targets = List[List[Int]]()
    var letters = List[List[Int]]()
    var ap = a0
    var bp = b0
    var gp = List[List[Int]]()
    for _ in range(3):
        gp.append(aff_const(0, 0))
    for l in range(len(steps)):
        var rp = apply_step_line(point, ap, bp, gp, steps[l])
        if not rp.ok:
            out.why = "level " + String(l) + ": the point path does not replay"
            return out^
        var t = List[Int]()
        for i in range(3):
            t.append(rp.gamma[i][0])
        targets.append(t^)
        letters.append(List[Int]([rp.a, rp.b]))
        ap = rp.a
        bp = rp.b
        gp = rp.gamma.copy()
    var zero = List[Poly]()
    for _ in range(3):
        zero.append(Poly())
    var stack = List[_LiftFrame]()
    stack.append(_LiftFrame(0, a0, b0, zero^, List[PolyStep](), List[List[Int]]()))
    var nodes = 0
    var deepest = 0
    var non_affine_ends = 0
    var fallback = PolyLift()
    var best = 0
    while len(stack) > 0 and nodes < LIFT_NODES:
        nodes += 1
        var fr = stack.pop()
        var l = fr.level
        if l == len(steps):
            if _affine_end(fr.gamma, lift):
                var got = PolyLift()
                got.ok = True
                got.a = fr.a
                got.b = fr.b
                got.steps = fr.steps.copy()
                got.ineqs = fr.ineqs.copy()
                got.gamma = fr.gamma.copy()
                if not lift.on():
                    return got^
                # with a lift, the complete lift of largest extent on the
                # region (an end offset vanishing on a slice only is kept
                # while one vanishing on more is sought)
                var key = lift_key(got, probes, lift)
                if not fallback.ok or key > best:
                    best = key
                    fallback = got^
                continue
            non_affine_ends += 1
            continue
        deepest = max(deepest, l)
        var cands = _lift_candidates(fam, fr.a, fr.b, fr.gamma, steps[l].seg_a, steps[l].off_a[0], steps[l].seg_b, steps[l].off_b[0], targets[l], ns, ly, lz, lift.on())
        var children = List[_LiftFrame]()
        var ranks = List[Int]()
        for c in range(len(cands)):
            var rc = poly_step(fam, fr.a, fr.b, fr.gamma, cands[c], SEARCH_DEGREE)
            if not rc.ok or rc.a != letters[l][0] or rc.b != letters[l][1]:
                continue
            var forms = fr.ineqs.copy()
            var before = len(forms)
            if not carving_forms_of(rc.conds, fam.m, ns, forms, lift):
                continue
            var degree = 0
            for i in range(3):
                degree = max(degree, poly_degree(rc.gamma[i]))
            if lift.on():
                # over (n, q) the products n_j e are free: a state affine
                # there ranks first whatever its degree in n
                degree = 0 if _affine_end(rc.gamma, lift) else 1 + degree
            var st = fr.steps.copy()
            st.append(cands[c].copy())
            ranks.append(64 * degree + len(forms) - before)
            children.append(_LiftFrame(l + 1, rc.a, rc.b, rc.gamma.copy(), st^, forms^))
        # push the worst first, so the best is explored first
        while len(children) > 0:
            var worst = 0
            for k in range(1, len(children)):
                if ranks[k] > ranks[worst]:
                    worst = k
            stack.append(children[worst].copy())
            _ = children.pop(worst)
            _ = ranks.pop(worst)
    if fallback.ok:
        return fallback^
    out.why = "no lift with an affine end (" + String(nodes) + " nodes, deepest level " + String(deepest) + ", " + String(non_affine_ends) + " non-affine ends)"
    return out^


def probe_points(ns: List[Int], lift: ProductLift, region: List[List[Int]]) raises -> List[List[Int]]:
    """The real points `ns + t d` of `region` (every form `>= 0`), lifted:
    `d` one of `e_k`, `e_k + e_l`, `e_k - e_l`, `e_l - e_k` over the run
    variables, `t` in 1, 3, 10, 30, `n >= 0`. They only score lifts
    (`lift_key`); nothing is certified on them."""
    var out = List[List[Int]]()
    var dirs = List[List[Int]]()
    for k in range(lift.m):
        dirs.append(List[Int]([k, 1, -1, 0]))
        for l in range(k + 1, lift.m):
            dirs.append(List[Int]([k, 1, l, 1]))
            dirs.append(List[Int]([k, 1, l, -1]))
            dirs.append(List[Int]([k, -1, l, 1]))
    for d in dirs:
        for t in [1, 3, 10, 30]:
            var x = List[Int](ns[: lift.m])
            x[d[0]] += t * d[1]
            if d[2] >= 0:
                x[d[2]] += t * d[3]
            if x[d[0]] < 0 or (d[2] >= 0 and x[d[2]] < 0):
                continue
            var p = lift_point(lift, x)
            var inside = True
            for f in region:
                if aff_eval(f, p) < 0:
                    inside = False
                    break
            if inside:
                out.append(p^)
    return out^


def lift_key(lr: PolyLift, probes: List[List[Int]], lift: ProductLift) -> Int:
    """How well a lift covers its region, larger is better:
    `extent << COST_BITS` less its cost (capped below `2^COST_BITS`).
    `extent` counts the probe points where its carving forms hold and its
    end offset vanishes, both over `(n, q)`; `cost` is the L1 norm of every
    lifted offset plus 4 times that of the end offset, large when a base
    point's run length was copied into a constant or coefficient (or an
    offset is not affine there). With no probe point, `extent` is 1 when
    the end offset lifts to zero, so a lift vanishing on the whole region
    still ranks first. An end offset not affine over `(n, q)`
    scores -1. Only a choice among lifts: each is
    carved by its own forms and re-verified."""
    var forms = lr.ineqs.copy()
    var cost = 0
    var end_cost = 0
    for st in lr.steps:
        for off in [st.off_a.copy(), st.off_b.copy()]:
            var f = _lifted(lift, off)
            if len(f) == 0:
                cost += 1 << COST_BITS
            for x in f:
                cost += abs(x)
    for i in range(len(lr.gamma)):
        var g = _lifted(lift, lr.gamma[i])
        if len(g) == 0:
            return -1
        var neg = List[Int]()
        for x in g:
            end_cost += 4 * abs(x)
            neg.append(-x)
        forms.append(g^)
        forms.append(neg^)
    cost += end_cost
    var extent = 1 if len(probes) == 0 and end_cost == 0 else 0
    for p in probes:
        var ok = True
        for f in forms:
            if aff_eval(f, p) < 0:
                ok = False
                break
        if ok:
            extent += 1
    return (extent << COST_BITS) - min(cost, (1 << COST_BITS) - 1)


def whole_region_lift(lr: PolyLift, probes: List[List[Int]], lift: ProductLift) raises -> Bool:
    """The lift's end offset lifts to the zero form over `(n, q)` and its
    carving forms hold at every probe point (`lift_key`'s extent is all of
    `probes`): no lift ranks above it but a cheaper one."""
    # the key is extent << COST_BITS less a cost below 2^COST_BITS
    return lifts_to_zero(lr.gamma, lift) and (lift_key(lr, probes, lift) + (1 << COST_BITS) - 1) >> COST_BITS == max(len(probes), 1)


def poly_steps(steps: List[WitnessStep]) -> List[PolyStep]:
    """Affine steps as polynomial ones."""
    var out = List[PolyStep]()
    for k in range(len(steps)):
        out.append(PolyStep(steps[k].seg_a, poly_from_aff(steps[k].off_a), steps[k].seg_b, poly_from_aff(steps[k].off_b)))
    return out^


def steps_at(steps: List[PolyStep], ns: List[Int]) raises -> List[WitnessStep]:
    """The steps at a point: constant offsets (forms over no variables), for
    the point family's ordinary verifier."""
    var out = List[WitnessStep]()
    for k in range(len(steps)):
        out.append(WitnessStep(steps[k].seg_a, List[Int]([poly_eval(steps[k].off_a, ns)]), steps[k].seg_b, List[Int]([poly_eval(steps[k].off_b, ns)])))
    return out^


# ---------------------------------------------------------------------------
# Lifting by linear algebra. Fix the point path's segments; then the letters
# of every state are fixed, and the end offset is linear in the run offsets:
# gamma_L = P_0 + sum over unknowns t_j of t_j P_j, each offset an unknown
# affine form o = c + sum u_k n_k. "gamma_L = 0 identically" and "each
# offset takes the point's value at ns" are linear equations over Q in the
# unknowns. A solution (free unknowns 0) that is integral gives a path on
# the whole region whose only conditions are the offsets' affine bounds.
# ---------------------------------------------------------------------------


def _q_to_int(x: Q) raises -> Int:
    """An exact rational that is a small integer, or raise."""
    if x.rejected:
        raise Error("a rejected rational in a lift")
    if x.den.limb_count() != 1 or x.den.limb(0) != 1:
        raise Error("not an integer")
    if x.num.is_zero():
        return 0
    if x.num.limb_count() != 1 or x.num.limb(0) > UInt64(1 << 40):
        raise Error("an integer too large for a lift")
    var v = Int(x.num.limb(0))
    return v if x.num.sign > 0 else -v


def _pow_mod(a: Int, e: Int, p: Int) -> Int:
    var r = 1
    var b = a % p
    var k = e
    while k > 0:
        if k & 1:
            r = (r * b) % p
        b = (b * b) % p
        k >>= 1
    return r


def _consistent_mod(rows: List[List[Q]], ncols: Int, p: Int) raises -> Bool:
    """Whether the augmented system (last column the right-hand side) is
    consistent mod `p`, by Gaussian elimination over GF(p). The entries are
    small integers."""
    var a = List[List[Int]]()
    for i in range(len(rows)):
        var row = List[Int]()
        for j in range(ncols + 1):
            row.append(_q_to_int(rows[i][j]) % p)
        a.append(row^)
    var r = 0
    for c in range(ncols):
        if r == len(a):
            break
        var piv = -1
        for i in range(r, len(a)):
            if a[i][c] != 0:
                piv = i
                break
        if piv < 0:
            continue
        a.swap_elements(r, piv)
        var inv = _pow_mod(a[r][c], p - 2, p)
        for j in range(c, ncols + 1):
            a[r][j] = (a[r][j] * inv) % p
        for i in range(len(a)):
            if i != r and a[i][c] != 0:
                var f = a[i][c]
                for j in range(c, ncols + 1):
                    a[i][j] = (a[i][j] - f * a[r][j]) % p
        r += 1
    for i in range(r, len(a)):
        if a[i][ncols] % p != 0:
            return False
    return True


def _check_width(fam: ConeFamily, lift: ProductLift) raises:
    if lift.on() and lift.width() != fam.m:
        raise Error("a product lift of another width than the region family's")


def solve_lift(fam: ConeFamily, point: ConeFamily, ns: List[Int], a0: Int, b0: Int, steps: List[WitnessStep], lift: ProductLift = no_lift()) raises -> PolyLift:
    """The point path's segments, with affine offsets solving `gamma_L = 0`
    identically on the region and agreeing with the point's offsets at `ns`;
    `ineqs` are the offsets' affine bounds not already nonnegative."""
    return _solve(fam, point, ns, a0, b0, steps, False, CrossingClose(0, 0, 0, 0), -1, -1, lift)


def solve_crossing_lift(fam: ConeFamily, point: ConeFamily, ns: List[Int], a0: Int, b0: Int, steps: List[WitnessStep], cl: CrossingClose, u: Int, v: Int, lift: ProductLift = no_lift()) raises -> PolyLift:
    """The point path's segments, with affine offsets making Lemma X's third
    coordinate offset vanish identically at the path's end and agreeing with
    the point; `ineqs` adds, to the offsets' bounds, the affine parts of a
    closure variant that holds at `ns` (each usable only when the rest of
    its condition has every coefficient `>= 0`)."""
    return _solve(fam, point, ns, a0, b0, steps, True, cl, u, v, lift)


def _solve(fam: ConeFamily, point: ConeFamily, ns: List[Int], a0: Int, b0: Int, steps: List[WitnessStep], close: Bool, cl: CrossingClose, u: Int, v: Int, lift: ProductLift) raises -> PolyLift:
    var out = PolyLift()
    _check_width(fam, lift)
    var m = fam.m
    var L = len(steps)
    # the point path: letters and offsets
    var la = List[Int]()
    var lb = List[Int]()
    var ap = a0
    var bp = b0
    var gp = List[List[Int]]()
    for _ in range(3):
        gp.append(aff_const(0, 0))
    var letters_a = List[Int]([a0])
    var letters_b = List[Int]([b0])
    for l in range(L):
        var rp = apply_step_line(point, ap, bp, gp, steps[l])
        if not rp.ok:
            out.why = "the point path does not replay"
            return out^
        ap = rp.a
        bp = rp.b
        gp = rp.gamma.copy()
        letters_a.append(ap)
        letters_b.append(bp)
    if not close and ap != bp:
        out.why = "the point path ends off the diagonal"
        return out^
    # unknowns: for each level and side with a run segment, m + 1 of them
    var owner_level = List[Int]()
    var owner_side = List[Int]()
    var first = List[Int]()  # per level and side (2 l + side): first unknown, or -1
    var count = 0
    for l in range(L):
        for side in range(2):
            var a = letters_a[l] if side == 0 else letters_b[l]
            var sg = steps[l].seg_a if side == 0 else steps[l].seg_b
            if fam.images[a][sg].kind == SEG_OPAQUE:
                out.why = "a step names an opaque segment"
                return out^
            if fam.images[a][sg].is_run():
                first.append(count)
                for _ in range(m + 1):
                    owner_level.append(l)
                    owner_side.append(side)
                count += m + 1
            else:
                first.append(-1)
    # gamma as parts: index 0 the constant part, 1 + j the coefficient of t_j
    var parts = List[List[Poly]]()
    for _ in range(count + 1):
        var z = List[Poly]()
        for _ in range(3):
            z.append(Poly())
        parts.append(z^)
    # the constant part: the path with every offset 0
    for l in range(L):
        var a = letters_a[l]
        var b = letters_b[l]
        var pa = fam.prefix_before(a, steps[l].seg_a)
        var pb = fam.prefix_before(b, steps[l].seg_b)
        var mg = m_times_poly(fam, parts[0])
        if len(mg) == 0:
            out.why = "the end offset's degree exceeds the cap"
            return out^
        for i in range(3):
            mg[i] = poly_sub(poly_add(mg[i], poly_from_aff(pa[i])), poly_from_aff(pb[i]))
        parts[0] = mg^
    # an offset entering at level l in letter i reaches the end as
    # M^(L - 1 - l) e_i: the powers once per letter, then a monomial factor
    var powers = List[List[List[Poly]]]()  # powers[i][j] = M^j e_i
    for i in range(3):
        var row = List[List[Poly]]()
        var v = List[Poly]()
        for k in range(3):
            v.append(poly_const(1 if k == i else 0))
        for j in range(L):
            row.append(v.copy())
            if j + 1 < L:
                v = m_times_poly(fam, v)
                if len(v) == 0:
                    out.why = "the end offset's degree exceeds the cap"
                    return out^
        powers.append(row^)
    for l in range(L):
        for side in range(2):
            var f = first[2 * l + side]
            if f < 0:
                continue
            var a = letters_a[l] if side == 0 else letters_b[l]
            var letter = fam.images[a][steps[l].seg_a if side == 0 else steps[l].seg_b].letter
            var sign = 1 if side == 0 else -1
            ref vec = powers[letter][L - 1 - l]
            for i in range(3):
                parts[1 + f][i] = poly_scale(vec[i], sign)
            for k in range(m):
                var mono = Poly()
                mono.add_term(mono_var(k), sign)
                for i in range(3):
                    parts[1 + f + 1 + k][i] = poly_mul(vec[i], mono)
    # the closing forms, linear in the unknowns: gamma_L itself, or Lemma
    # X's third coordinate offset (M gamma_L)[third] + pre_a - pre_b
    if close:
        var third = 3 - u - v
        var pa0 = fam.prefix_before(ap, cl.s0)
        var pb0 = fam.prefix_before(bp, cl.t0)
        for j in range(count + 1):
            var acc = Poly()
            for k in range(3):
                acc = poly_add(acc, poly_mul(poly_from_aff(fam.incidence[3 * third + k]), parts[j][k]))
            if j == 0:
                acc = poly_sub(poly_add(acc, poly_from_aff(pa0[third])), poly_from_aff(pb0[third]))
            if poly_degree(acc) > POLY_DEGREE:
                out.why = "the closure's degree exceeds the cap"
                return out^
            var only = List[Poly]()
            only.append(acc^)
            only.append(Poly())
            only.append(Poly())
            parts[j] = only^
    # equations: every monomial of every closing form vanishes (with a lift,
    # every coefficient of its form over (n, q): n_j e and q_j share one)
    var keys = List[Int]()
    var seen = Dict[Int, Int]()
    var acc = List[List[Int]]()
    for j in range(count + 1):
        for i in range(3):
            for e in parts[j][i].terms.items():
                var key = 4 * (lifted_monomial(lift, e.key) if lift.on() else e.key) + i
                if key not in seen:
                    seen[key] = len(keys)
                    keys.append(key)
                    acc.append(List[Int](length=count + 1, fill=0))
                # the constant part goes to the right-hand side
                acc[seen[key]][count if j == 0 else j - 1] += -e.value if j == 0 else e.value
    var rows = List[List[Q]]()
    for r in range(len(keys)):
        var row = List[Q]()
        for j in range(count + 1):
            row.append(q_int(acc[r][j]))
        rows.append(row^)
    # agreement with the point's offsets
    for l in range(L):
        for side in range(2):
            var f = first[2 * l + side]
            if f < 0:
                continue
            var row = List[Q]()
            for _ in range(count + 1):
                row.append(q_int(0))
            row[f] = q_int(1)
            for k in range(m):
                row[f + 1 + k] = q_int(ns[k])
            row[count] = q_int(steps[l].off_a[0] if side == 0 else steps[l].off_b[0])
            rows.append(row^)
    # screen mod two primes (guidance only: a system consistent over Q is
    # consistent mod p unless p divides a pivot, and whatever is solved
    # below is solved exactly and verified)
    if not _consistent_mod(rows, count, SCREEN_PRIME_1) and not _consistent_mod(rows, count, SCREEN_PRIME_2):
        out.why = "no affine offsets make the end offset vanish on the region (mod p)"
        return out^
    var red = rref(rows)
    ref R = red[0]
    ref pivots = red[1]
    var t = List[Int](length=count, fill=0)
    for r in range(len(pivots)):
        if pivots[r] == count:
            out.why = "no affine offsets make the end offset vanish on the region"
            return out^
        try:
            t[pivots[r]] = _q_to_int(R[r][count])
        except:
            out.why = "the solving offsets are not integral"
            return out^
    # the offsets, the path, and its conditions
    for l in range(L):
        var offs = List[Poly]()
        for side in range(2):
            var f = first[2 * l + side]
            if f < 0:
                offs.append(Poly())
                continue
            var c = List[Int]()
            for k in range(m + 1):
                c.append(t[f + k])
            offs.append(poly_from_aff(c))
        out.steps.append(PolyStep(steps[l].seg_a, offs[0].copy(), steps[l].seg_b, offs[1].copy()))
    var gamma = List[Poly]()
    for _ in range(3):
        gamma.append(Poly())
    var a = a0
    var b = b0
    for l in range(L):
        var r = poly_step(fam, a, b, gamma, out.steps[l])
        if not r.ok:
            out.why = "the solved path does not step"
            return out^
        if not carving_forms_of(r.conds, m, ns, out.ineqs, lift):
            out.why = "the solved offsets leave the region's runs at the point"
            return out^
        a = r.a
        b = r.b
        gamma = r.gamma.copy()
    if close:
        var cf = poly_crossing_forms(fam, a, b, gamma, u, v, cl)
        var off_zero = lifts_to_zero(List[Poly]([cf.off.copy(), Poly(), Poly()]), lift) if lift.on() else poly_is_zero(cf.off)
        if not cf.ok or not off_zero:
            out.why = "the solved closure does not stand"
            return out^
        var found = False
        for variant in range(4):
            ref c = cf.variants[variant]
            if len(c) == 0:
                continue
            var forms = List[List[Int]]()
            if carving_forms_of(c, m, ns, forms, lift):
                for k in range(len(forms)):
                    out.ineqs.append(forms[k].copy())
                found = True
                break
        if not found:
            out.why = "no closure variant holds at the point by affine forms"
            return out^
    out.ok = True
    out.a = a
    out.b = b
    out.gamma = gamma^
    return out^


struct PolyCrossingForms(Copyable, Movable):
    """`psc.cone_witness.CrossingForms` over polynomials."""

    var ok: Bool
    var off: Poly
    var variants: List[List[Poly]]

    def __init__(out self):
        self.ok = False
        self.off = Poly()
        self.variants = List[List[Poly]]()


def poly_crossing_forms(fam: ConeFamily, a: Int, b: Int, gamma: List[Poly], u: Int, v: Int, cl: CrossingClose) raises -> PolyCrossingForms:
    """Lemma X at `(a, b, gamma)` over polynomials, exactly as
    `psc.cone_witness._crossing_forms`: the third coordinate's offset (must
    vanish) and, per variant, the forms that must be `>= 0`."""
    var out = PolyCrossingForms()
    var third = 3 - u - v
    if not _plane_range(fam, a, cl.s0, cl.s1, third) or not _plane_range(fam, b, cl.t0, cl.t1, third):
        return out^
    ref hu = fam.images[u][0]
    ref hv = fam.images[v][0]
    if hu.kind != SEG_LETTER or hv.kind != SEG_LETTER or hu.letter != hv.letter:
        return out^
    var mg = m_times_poly(fam, gamma)
    if len(mg) == 0:
        return out^
    var pa0 = fam.prefix_before(a, cl.s0)
    var pa1 = fam.prefix_before(a, cl.s1)
    var pb0 = fam.prefix_before(b, cl.t0)
    var pb1 = fam.prefix_before(b, cl.t1)
    out.off = poly_sub(poly_add(mg[third], poly_from_aff(pa0[third])), poly_from_aff(pb0[third]))
    var q0u = poly_sub(poly_from_aff(pb0[u]), mg[u])
    var q0v = poly_sub(poly_from_aff(pb0[v]), mg[v])
    var q1u = poly_sub(poly_from_aff(pb1[u]), mg[u])
    var q1v = poly_sub(poly_from_aff(pb1[v]), mg[v])
    var p0u = poly_from_aff(pa0[u])
    var p0v = poly_from_aff(pa0[v])
    var p1u = poly_from_aff(pa1[u])
    var p1v = poly_from_aff(pa1[v])
    var lp0 = poly_add(p0u, p0v)
    var lp1 = poly_add(p1u, p1v)
    var lq0 = poly_add(q0u, q0v)
    var lq1 = poly_add(q1u, q1v)
    var inner = _plane_letter_at(fam, a, cl.s1, u, v) and _plane_letter_at(fam, b, cl.t1, u, v)
    for variant in range(4):
        var c = List[Poly]()
        var weak_end = variant < 2
        if weak_end and not inner:
            out.variants.append(c^)
            continue
        var slack = poly_const(0 if weak_end else 1)
        c.append(poly_sub(poly_sub(lp1, lp0), slack))
        c.append(poly_sub(poly_sub(lq1, lp0), slack))
        c.append(poly_sub(poly_sub(lp1, lq0), slack))
        c.append(poly_sub(poly_sub(lq1, lq0), slack))
        if variant % 2 == 0:
            c.append(poly_sub(q0u, p0u))
            c.append(poly_sub(p0v, q0v))
            c.append(poly_sub(poly_sub(p1u, q1u), slack))
            c.append(poly_sub(poly_sub(q1v, p1v), slack))
        else:
            c.append(poly_sub(p0u, q0u))
            c.append(poly_sub(q0v, p0v))
            c.append(poly_sub(poly_sub(q1u, p1u), slack))
            c.append(poly_sub(poly_sub(p1v, q1v), slack))
        out.variants.append(c^)
    out.ok = True
    return out^


def verify_crossing_poly(fam: ConeFamily, a0: Int, b0: Int, steps: List[PolyStep], cl: CrossingClose, u: Int, v: Int, prover: Prover, lift: ProductLift = no_lift()) raises -> Bool:
    """Re-derive the path's last state over polynomials (every offset
    condition proved on the region) and check Lemma X there: the third
    coordinate's offset proved to vanish, and every form of some variant
    proved `>= 0`."""
    var a = a0
    var b = b0
    var gamma = List[Poly]()
    for _ in range(3):
        gamma.append(Poly())
    for l in range(len(steps)):
        var r = poly_step(fam, a, b, gamma, steps[l])
        if not r.ok:
            return False
        for k in range(len(r.conds)):
            if not holds_under(r.conds[k], prover, lift):
                return False
        a = r.a
        b = r.b
        gamma = r.gamma.copy()
    var cf = poly_crossing_forms(fam, a, b, gamma, u, v, cl)
    if not cf.ok or not vanishes_under(cf.off, prover, lift):
        return False
    for variant in range(4):
        ref c = cf.variants[variant]
        if len(c) == 0:
            continue
        var all = True
        for k in range(len(c)):
            if not holds_under(c[k], prover, lift):
                all = False
                break
        if all:
            return True
    return False


struct PointPaths(Movable):
    """`enumerate_point_paths` one path at a time: the same depth-first
    search by iterative deepening, resumable, so a caller can stop at the
    first path it accepts. `next` returns False once `max_level` is passed
    or `max_nodes` nodes are spent; else `path` holds the next path, in the
    order `enumerate_point_paths` lists them."""

    var a0: Int
    var b0: Int
    var bound: Int
    var max_level: Int
    var ly: Int
    var lz: Int
    var max_nodes: Int
    var line_cap: Int
    var depth: Int
    var nodes: Int
    var sa: List[Int]
    var sb: List[Int]
    var sg: List[List[List[Int]]]
    var sp: List[List[WitnessStep]]
    var pending: List[List[WitnessStep]]  # paths found at the last node, in order
    var path: List[WitnessStep]

    def __init__(out self, a0: Int, b0: Int, bound: Int, max_level: Int, ly: Int, lz: Int, max_nodes: Int, line_cap: Int = 0):
        self.a0 = a0
        self.b0 = b0
        self.bound = bound
        self.max_level = max_level
        self.ly = ly
        self.lz = lz
        self.max_nodes = max_nodes
        self.line_cap = line_cap
        self.depth = 0
        self.nodes = 0
        self.sa = List[Int]()
        self.sb = List[Int]()
        self.sg = List[List[List[Int]]]()
        self.sp = List[List[WitnessStep]]()
        self.pending = List[List[WitnessStep]]()
        self.path = List[WitnessStep]()

    def next(mut self, point: ConeFamily) -> Bool:
        while len(self.pending) == 0:
            if len(self.sa) == 0:
                if self.depth >= self.max_level:
                    return False
                self.depth += 1
                var zero = List[List[Int]]()
                for _ in range(3):
                    zero.append(aff_const(point.m, 0))
                self.sa.append(self.a0)
                self.sb.append(self.b0)
                self.sg.append(zero^)
                self.sp.append(List[WitnessStep]())
            if self.nodes >= self.max_nodes:
                return False
            self.nodes += 1
            var a = self.sa.pop()
            var b = self.sb.pop()
            var g = self.sg.pop()
            var path = self.sp.pop()
            if len(path) == self.depth:
                continue
            var cands = _line_candidates(point, a, b, g, self.bound, self.ly, self.lz)
            for c in range(len(cands)):
                var r = apply_step_line(point, a, b, g, cands[c])
                if not r.ok or not within_line(r.gamma, self.bound, self.ly, self.lz, self.line_cap):
                    continue
                var p2 = path.copy()
                p2.append(cands[c].copy())
                if r.a == r.b and _is_zero(r.gamma):
                    if len(p2) == self.depth:
                        self.pending.append(p2^)
                    continue
                self.sa.append(r.a)
                self.sb.append(r.b)
                self.sg.append(r.gamma.copy())
                self.sp.append(p2^)
        self.path = self.pending.pop(0)
        return True


def enumerate_point_paths(point: ConeFamily, a0: Int, b0: Int, bound: Int, max_level: Int, ly: Int, lz: Int, max_paths: Int, max_nodes: Int, line_cap: Int = 0) -> List[List[WitnessStep]]:
    """Witness paths of a point family (constant offsets), by depth-first
    search over the line candidates, shortest first by iterative deepening:
    each depth limit up to `max_level` in turn, and `max_nodes` nodes in
    all (`PointPaths`); no node is expanded once `max_paths` paths are kept,
    so every path closed at the node that reaches the limit is kept, and
    `max_paths = 0` keeps none. Distinct paths may share states:
    `solve_lift` asks only for their segments. `line_cap` as in
    `within_line`."""
    var out = List[List[WitnessStep]]()
    var it = PointPaths(a0, b0, bound, max_level, ly, lz, max_nodes, line_cap)
    while (len(out) < max_paths or len(it.pending) > 0) and it.next(point):
        out.append(it.path.copy())
    return out^
