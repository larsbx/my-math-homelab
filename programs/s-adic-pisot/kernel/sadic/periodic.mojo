"""Periodic directive sequences and their exact certificates.

A periodic directive sequence `w^infinity` is substitutive, with substitution
the composite `sigma_w` (the embedding `iota` of docs/METHODOLOGY.md). This
module enumerates one Lyndon representative per primitive period up to
rotation, decides admissibility of `w^infinity` in a sofic shift, decides
primitivity of `M_w` by Wielandt's bound, and runs the full verdict pipeline
of a periodic point: primitive -> irreducible -> Pisot -> balanced pair
algorithm.

The unordered Brun family is BST23 (6.9), `beta_{i,j}: j -> i j`, `k -> k`,
with the sofic admissibility (6.10): `beta_{i,j}` is followed by itself or by
some `beta_{j,k}`. Labels list the pairs `i != j` lexicographically, 0-based.

Reference oracle: `reference/sadic_reference/periodic.py`, `bpa.py`.
"""

from substitution_dynamics.automaton import nonproductive_states
from substitution_dynamics.balanced_pair_algorithm import build_bounded
from substitution_dynamics.substitution import Substitution
from sadic.cocycle import is_positive, prefix_matrix
from sadic.directive import DirectiveShift
from sadic.spectrum import charpoly, irreducibility_verdict, pisot_verdict

comptime BPA_TERMINATES = 1
comptime BPA_FAILS = 0
comptime BPA_CAPPED = -1


def brun_unordered(d: Int) raises -> DirectiveShift:
    if d < 2:
        raise Error("Brun substitutions need at least two letters")
    var pi = List[Int]()
    var pj = List[Int]()
    for i in range(d):
        for j in range(d):
            if i != j:
                pi.append(i)
                pj.append(j)
    var k = len(pi)
    var subs = List[Substitution]()
    for t in range(k):
        var images = List[List[Int]]()
        for a in range(d):
            if a == pj[t]:
                images.append([pi[t], pj[t]])
            else:
                images.append([a])
        subs.append(Substitution.checked(images))
    # state 0 admits every label; state 1 + t remembers label t
    var table = List[Int]()
    for t in range(k):
        table.append(1 + t)
    for s in range(k):
        for t in range(k):
            var same = pi[t] == pi[s] and pj[t] == pj[s]
            table.append(1 + t if same or pi[t] == pj[s] else -1)
    return DirectiveShift.checked("brun-unordered-" + String(d), subs, table, 0)


def periodic_admissible(shift: DirectiveShift, word: List[Int]) raises -> Bool:
    """Whether `word^infinity` labels an infinite path from some state."""
    for start in range(shift.states):
        var seen = List[Bool]()
        for _ in range(shift.states):
            seen.append(False)
        var q = start
        while q >= 0 and not seen[q]:
            seen[q] = True
            q = shift.run(word, q)
        if q >= 0:
            return True
    return False


def is_lyndon(w: List[Int]) -> Bool:
    var n = len(w)
    for s in range(1, n):
        # compare w with its rotation by s
        var verdict = 0
        for i in range(n):
            var a = w[i]
            var b = w[(i + s) % n]
            if a != b:
                verdict = -1 if a < b else 1
                break
        if verdict >= 0:
            return False
    return True


def _extend(shift: DirectiveShift, var w: List[Int], n: Int, mut out: List[List[Int]]) raises:
    if len(w) == n:
        if is_lyndon(w) and periodic_admissible(shift, w):
            out.append(w^)
        return
    for a in range(shift.labels()):
        var v = w.copy()
        v.append(a)
        if shift.admits_somewhere(v):
            _extend(shift, v^, n, out)


def periodic_words(shift: DirectiveShift, n: Int) raises -> List[List[Int]]:
    """Lyndon words of length n with `w^infinity` admissible, lexicographically."""
    var out = List[List[Int]]()
    _extend(shift, List[Int](), n, out)
    return out^


def _pattern_product(a: List[Int], b: List[Int], d: Int) -> List[Int]:
    """Product of two 0/1 zero patterns."""
    var out = List[Int]()
    for i in range(d):
        for j in range(d):
            var hit = 0
            for k in range(d):
                if a[i * d + k] != 0 and b[k * d + j] != 0:
                    hit = 1
                    break
            out.append(hit)
    return out^


def primitivity_exponent(m: List[Int], d: Int) raises -> Int:
    """Least k <= (d-1)^2 + 1 with `M^k > 0`, else -1 (Wielandt: not primitive).
    Positivity of `M^k` depends only on the zero pattern of the non-negative
    `M`, so the powers are taken on 0/1 patterns and cannot overflow."""
    if len(m) != d * d:
        raise Error("primitivity needs a d x d matrix")
    var pattern = List[Int]()
    for x in m:
        if x < 0:
            raise Error("primitivity needs a non-negative matrix")
        pattern.append(1 if x > 0 else 0)
    var power = pattern.copy()
    for k in range(1, (d - 1) * (d - 1) + 2):
        if is_positive(power):
            return k
        power = _pattern_product(power, pattern, d)
    return -1


def bpa_verdict(sigma: Substitution, max_states: Int, max_length: Int) raises -> Int:
    """BPA_TERMINATES when the closure of the swap seeds is finite within the
    budgets and every state reaches a coincidence; BPA_FAILS when it is finite
    and some state never does; BPA_CAPPED (inconclusive) otherwise."""
    var bounded = build_bounded(sigma, max_states, max_length)
    if not bounded.complete():
        return BPA_CAPPED
    return BPA_TERMINATES if len(nonproductive_states(bounded.graph)) == 0 else BPA_FAILS


def periodic_verdict(shift: DirectiveShift, w: List[Int], max_states: Int, max_length: Int) -> String:
    """The first failing stage of primitive -> irreducible -> Pisot -> BPA, or
    the BPA outcome. An overflow anywhere is reported as `overflow`."""
    try:
        var d = shift.size()
        var m = prefix_matrix(shift, w)
        if primitivity_exponent(m, d) < 0:
            return "not-primitive"
        var f = charpoly(m, d)
        var irr = irreducibility_verdict(f)
        if irr.verdict != 1:
            return "irreducible:" + String(irr.verdict)
        var pv = pisot_verdict(f)
        if pv != 1:
            return "pisot:" + String(pv)
        var b = bpa_verdict(shift.composite(w), max_states, max_length)
        if b == BPA_TERMINATES:
            return "bpa:terminates"
        return "bpa:fails" if b == BPA_FAILS else "bpa:capped"
    except:
        return "overflow"


def verdict_names() -> List[String]:
    """Every value `periodic_verdict` returns, in census order."""
    return [
        "not-primitive", "irreducible:0", "irreducible:-1", "pisot:0", "pisot:-1",
        "bpa:terminates", "bpa:fails", "bpa:capped", "overflow",
    ]


def verdict_index(v: String) raises -> Int:
    var names = verdict_names()
    for i in range(len(names)):
        if names[i] == v:
            return i
    raise Error("unknown periodic verdict " + v)


def is_open_verdict(v: String) -> Bool:
    """Neither a certified exclusion nor `bpa:terminates`: inconclusive or a
    BPA failure, which a census must report individually."""
    return v == "irreducible:-1" or v == "pisot:-1" or v == "bpa:fails" or v == "bpa:capped" or v == "overflow"


def _permutations(d: Int) -> List[List[Int]]:
    """Every permutation of 0..d-1, lexicographically."""
    var out = List[List[Int]]()
    out.append(List[Int]())
    for _ in range(d):
        var next = List[List[Int]]()
        for p in out:
            for a in range(d):
                var used = False
                for x in p:
                    if x == a:
                        used = True
                if not used:
                    var q = p.copy()
                    q.append(a)
                    next.append(q^)
        out = next^
    return out^


def _brun_label(i: Int, j: Int, d: Int) -> Int:
    """The label of beta_{i,j} in brun_unordered(d): pairs i != j, lexicographic."""
    return i * (d - 1) + (j if j < i else j - 1)


def _less(a: List[Int], b: List[Int]) -> Bool:
    for i in range(len(a)):
        if a[i] != b[i]:
            return a[i] < b[i]
    return False


def _least_rotation(w: List[Int]) -> List[Int]:
    var best = w.copy()
    var n = len(w)
    for s in range(1, n):
        var r = List[Int]()
        for i in range(n):
            r.append(w[(i + s) % n])
        if _less(r, best):
            best = r^
    return best^


def brun_orbit(d: Int, w: List[Int]) -> List[List[Int]]:
    """The distinct rotation classes (least rotations) of w under every letter
    permutation pi, acting on labels by beta_{i,j} -> beta_{pi(i),pi(j)}."""
    var out = List[List[Int]]()
    for pi in _permutations(d):
        var r = List[Int]()
        for t in w:
            var i = t // (d - 1)
            var j0 = t % (d - 1)
            var j = j0 if j0 < i else j0 + 1
            r.append(_brun_label(pi[i], pi[j], d))
        var c = _least_rotation(r)
        var seen = False
        for x in out:
            if not _less(x, c) and not _less(c, x):
                seen = True
        if not seen:
            out.append(c^)
    return out^


def brun_orbit_words(d: Int, n: Int) raises -> List[List[Int]]:
    """The least word of each orbit of periodic words of length n under
    rotation and letter permutation, followed by its orbit size as a last entry."""
    var out = List[List[Int]]()
    for w in periodic_words(brun_unordered(d), n):
        var orbit = brun_orbit(d, w)
        var least = True
        for x in orbit:
            if _less(x, w):
                least = False
        if least:
            var entry = w.copy()
            entry.append(len(orbit))
            out.append(entry^)
    return out^


def _normal_form(ps: List[Int], qs: List[Int], s: Int, d: Int) -> List[Int]:
    """Labels of the rotation by s, letters renumbered by first appearance."""
    var n = len(ps)
    var name = List[Int]()
    for _ in range(d):
        name.append(-1)
    var next = 0
    var out = List[Int]()
    for t in range(n):
        var p = ps[(t + s) % n]
        var q = qs[(t + s) % n]
        if name[p] < 0:
            name[p] = next
            next += 1
        if name[q] < 0:
            name[q] = next
            next += 1
        out.append(_brun_label(name[p], name[q], d))
    return out^


def _is_class_least(ps: List[Int], qs: List[Int], d: Int) -> Bool:
    """No rotation renumbers to a smaller word, and w is not a proper power."""
    var own = _normal_form(ps, qs, 0, d)
    var n = len(ps)
    for s in range(1, n):
        var r = _normal_form(ps, qs, s, d)
        var equal = True
        for t in range(n):
            if r[t] != own[t]:
                equal = False
                if r[t] < own[t]:
                    return False
                break
        if equal:
            var power = True
            for t in range(n):
                if ps[(t + s) % n] != ps[t] or qs[(t + s) % n] != qs[t]:
                    power = False
                    break
            if power:
                return False
    return True


def _extend_classes(d: Int, n: Int, mut ps: List[Int], mut qs: List[Int], used: Int, mut out: List[List[Int]]):
    var k = len(ps)
    if d - used > n - k:
        return
    var p = ps[k - 1]
    var q = qs[k - 1]
    if k == n:
        # cyclic admissibility back to beta_{0,1}
        if ((p == 0 and q == 1) or q == 0) and used == d and _is_class_least(ps, qs, d):
            out.append(_normal_form(ps, qs, 0, d))
        return
    # repeat the label
    ps.append(p)
    qs.append(q)
    _extend_classes(d, n, ps, qs, used, out)
    _ = ps.pop()
    _ = qs.pop()
    # move to beta_{q,r}: an existing letter, or the next new one
    var top = used + 1 if used < d else used
    for r in range(top):
        if r == q:
            continue
        ps.append(q)
        qs.append(r)
        _extend_classes(d, n, ps, qs, used + 1 if r == used else used, out)
        _ = ps.pop()
        _ = qs.pop()


def brun_classes(d: Int, n: Int) -> List[List[Int]]:
    """One word per class of periodic words of length n under rotation and
    letter permutation, among those using every letter (Theorem B: a
    primitive composite uses every letter). Letters are numbered by first
    appearance, so each word starts with beta_{0,1}; it is the least such
    renumbering over its rotations. Proper powers are excluded. Unlike
    brun_orbit_words this never enumerates the d! relabellings."""
    var out = List[List[Int]]()
    var ps: List[Int] = [0]
    var qs: List[Int] = [1]
    _extend_classes(d, n, ps, qs, 2, out)
    return out^


def is_pip(shift: DirectiveShift, w: List[Int]) raises -> Bool:
    """sigma_w is primitive with an irreducible Pisot characteristic polynomial."""
    var d = shift.size()
    var m = prefix_matrix(shift, w)
    if primitivity_exponent(m, d) < 0:
        return False
    var f = charpoly(m, d)
    return irreducibility_verdict(f).verdict == 1 and pisot_verdict(f) == 1

