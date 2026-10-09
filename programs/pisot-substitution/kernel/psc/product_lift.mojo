"""Product coordinates: polynomials bilinear in the tail variable made affine.

docs/p1a-a1-prime-2026-10-05.md §3m. With `Delta` symbolic in the tail
variable `e`, line-mode offsets and Lemma P1 pick up products `n_j e` (and
`e^2`), so affine line mode refuses. Adding one coordinate `q_j` per product
that occurs makes them affine in `(n, q)`. A region becomes a polyhedron in
`(n, q)` whose real points are those with `q_j = n_j e` (`lift_point`); the
McCormick forms `(n_j - lo_j)(e - lo_e) >= 0`, i.e.
`q_j - lo_e n_j - lo_j e + lo_j lo_e >= 0`, hold at every real point with
`n >= lo`, so they may be added to the polyhedron; so may `(e - lo_e) g >= 0`
for any form `g >= 0` of the region over `n` alone (`rlt_forms`), which
carries a run-length relation through the products. Anything certified on the
whole polyhedron holds at its real points; the converse is not claimed.

The lift fails closed: a degree-2 monomial that is not `n_j e`, a monomial of
degree 3 or more, or a variable past `m` raises.
"""

from psc.cone_witness import aff_const, aff_scale
from psc.poly_line import MONO_BITS, MONO_MASK, Poly, _mono_degree


struct ProductLift(Copyable, Movable):
    """Variables `n_0..n_(m-1)` with tail `n_e`, and the product coordinates
    `q_(prods[i]) = n_(prods[i]) e` at index `m + i` (ascending `prods`)."""

    var m: Int
    var e: Int
    var prods: List[Int]

    def __init__(out self, m: Int, e: Int, var prods: List[Int]):
        self.m = m
        self.e = e
        self.prods = prods^

    def on(self) -> Bool:
        """False for `no_lift()`, the absent lift."""
        return self.m > 0

    def width(self) -> Int:
        """The number of lifted variables, `m + m'`."""
        return self.m + len(self.prods)

    def slot(self, j: Int) raises -> Int:
        """The affine-form slot (1-based) of `q_j`; raises if `q_j` is absent."""
        for i in range(len(self.prods)):
            if self.prods[i] == j:
                return 1 + self.m + i
        raise Error("product coordinate n_" + String(j) + " e is not in the lift")


def no_lift() -> ProductLift:
    """The absent lift: polynomial conditions are proved as polynomials."""
    return ProductLift(0, -1, List[Int]())


def full_lift(m: Int, e: Int) -> ProductLift:
    """Every product `n_j e`, `j = 0..m-1`: `q_j` at variable index `m + j`."""
    var prods = List[Int]()
    for j in range(m):
        prods.append(j)
    return ProductLift(m, e, prods^)


def _vars_of(key: Int, m: Int) raises -> List[Int]:
    """The ascending variable indices of a packed monomial, each `< m`."""
    var out = List[Int]()
    var x = key
    while x != 0:
        var k = (x & MONO_MASK) - 1
        if k >= m:
            raise Error("a monomial variable n_" + String(k) + " past the lift's " + String(m))
        out.append(k)
        x >>= MONO_BITS
    return out^


def _product_index(key: Int, m: Int, e: Int) raises -> Int:
    """The `j` of a degree-2 monomial `n_j e`; raises on any other."""
    var v = _vars_of(key, m)
    if v[0] == e:
        return v[1]
    if v[1] == e:
        return v[0]
    raise Error("degree-2 monomial n_" + String(v[0]) + " n_" + String(v[1]) + " is not a product with the tail")


def lifted_monomial(lift: ProductLift, key: Int) -> Int:
    """The packed variable `q_j` that a degree-2 monomial `n_j e` of the
    lift lifts to; any other monomial unchanged."""
    if _mono_degree(key) != 2:
        return key
    try:
        return lift.slot(_product_index(key, lift.m, lift.e))  # slot = index + 1 = packed variable
    except:
        return key


def product_lift_of(polys: List[Poly], m: Int, e: Int) raises -> ProductLift:
    """The lift with one coordinate per product `n_j e` occurring in `polys`;
    raises on any monomial the lift cannot make affine."""
    if e < 0 or e >= m:
        raise Error("the tail variable is outside the region's variables")
    var seen = List[Bool](length=m, fill=False)
    for p in polys:
        for t in p.terms.items():
            var d = _mono_degree(t.key)
            if d >= 3:
                raise Error("a monomial of degree " + String(d) + " in a product lift")
            if d == 2:
                seen[_product_index(t.key, m, e)] = True
            else:
                _ = _vars_of(t.key, m)
    var prods = List[Int]()
    for j in range(m):
        if seen[j]:
            prods.append(j)
    return ProductLift(m, e, prods^)


def lift_affine(lift: ProductLift, p: Poly) raises -> List[Int]:
    """`p` as an affine form over `(n, q)`, length `1 + m + m'`. A variable
    of index `m..m+m'-1` is a product coordinate already, and may occur
    linearly only."""
    var out = aff_const(lift.width(), 0)
    for t in p.terms.items():
        var d = _mono_degree(t.key)
        if d == 0:
            out[0] += t.value
        elif d == 1:
            out[_vars_of(t.key, lift.width())[0] + 1] += t.value
        elif d == 2:
            out[lift.slot(_product_index(t.key, lift.m, lift.e))] += t.value
        else:
            raise Error("a monomial of degree " + String(d) + " in a product lift")
    return out^


def lift_form(lift: ProductLift, a: List[Int]) raises -> List[Int]:
    """An affine form over `n` (length `1 + m`) padded to `(n, q)`."""
    if len(a) != lift.m + 1:
        raise Error("an affine form of the wrong width for the lift")
    var out = a.copy()
    for _ in range(len(lift.prods)):
        out.append(0)
    return out^


def lift_point(lift: ProductLift, ns: List[Int]) raises -> List[Int]:
    """The real point over `ns`: `ns` followed by `q_j = n_j e`."""
    if len(ns) != lift.m:
        raise Error("a point of the wrong width for the lift")
    var out = ns.copy()
    for j in lift.prods:
        out.append(ns[j] * ns[lift.e])
    return out^


def mccormick_forms(lift: ProductLift, lo: List[Int]) raises -> List[List[Int]]:
    """For each `q_j`, `q_j - lo_e n_j - lo_j e + lo_j lo_e >= 0`: the
    expansion of `(n_j - lo_j)(e - lo_e) >= 0`, valid at every real point
    with `n_j >= lo_j` and `e >= lo_e` (for `j = e`, `e^2 >= 2 lo_e e - lo_e^2`)."""
    var none = List[Bool](length=lift.m, fill=False)
    return mccormick_box_forms(lift, lo, lo, none)


def mccormick_box_forms(lift: ProductLift, lo: List[Int], hi: List[Int], bounded: List[Bool]) raises -> List[List[Int]]:
    """The McCormick envelope of every `q_j` on the box `lo <= n <= hi`
    (`hi_k` only where `bounded_k`): for each sign pattern with both bounds
    present, `s_1 s_2 (n_j - c_1)(e - c_2) >= 0` expanded, `c_1` the bound
    of `n_j` and `c_2` that of `e` (`s = 1` at a lower bound, `-1` at an
    upper). Each product of two nonnegative factors is `>= 0` at every real
    point of the box. Lower-lower first."""
    if len(lo) != lift.m or len(hi) != lift.m or len(bounded) != lift.m:
        raise Error("bounds of the wrong width for the lift")
    var e = lift.e
    var out = List[List[Int]]()
    for j in lift.prods:
        for sj in [1, -1]:
            if sj < 0 and not bounded[j]:
                continue
            var c1 = lo[j] if sj > 0 else hi[j]
            for se in [1, -1]:
                if se < 0 and not bounded[e]:
                    continue
                var c2 = lo[e] if se > 0 else hi[e]
                var sg = sj * se
                var f = aff_const(lift.width(), sg * c1 * c2)
                f[lift.slot(j)] += sg
                f[j + 1] -= sg * c2
                f[e + 1] -= sg * c1
                out.append(f^)
    return out^


def rlt_forms(lift: ProductLift, g: List[Int], lo_e: Int, hi_e: Int, bounded_e: Bool) raises -> List[List[Int]]:
    """For a form `g` over `(n, q)` with no product coordinate, the
    expansions of `(e - lo_e) g >= 0` and, when `bounded_e`,
    `(hi_e - e) g >= 0`: `+-(g_0 e + sum_k g_k q_k) -+ c g` with
    `n_k e = q_k` (`q_e = e^2`). Each is a product of two factors `>= 0`,
    so it holds at every real point with `g >= 0` and
    `lo_e <= e <= hi_e`; the McCormick forms are the case `g = n_j - lo_j`.
    Raises when `g` names a product coordinate, or an `n_k` whose `q_k`
    is not in the lift."""
    if len(g) != lift.width() + 1:
        raise Error("a form of the wrong width for the lift")
    for i in range(lift.m + 1, len(g)):
        if g[i] != 0:
            raise Error("a product times the tail is not in the lift")
    var out = List[List[Int]]()
    for sg in [1, -1]:
        if sg < 0 and not bounded_e:
            continue
        var c = lo_e if sg > 0 else hi_e
        var f = aff_scale(g, -sg * c)
        f[lift.e + 1] += sg * g[0]
        for k in range(lift.m):
            if g[k + 1] != 0:
                f[lift.slot(k)] += sg * g[k + 1]
        out.append(f^)
    return out^


struct ProductSubst(Copyable, Movable):
    """The product coordinates a substitution `n_k := L` changes, as
    variable indices and replacement forms over `(n, q)` (applied after
    `n_k := L`, in order); `ok` false when some `L e` or `n_j L` is not
    affine in the lift's coordinates."""

    var ok: Bool
    var vars: List[Int]
    var forms: List[List[Int]]

    def __init__(out self, ok: Bool):
        self.ok = ok
        self.vars = List[Int]()
        self.forms = List[List[Int]]()


def product_substitution(lift: ProductLift, k: Int, repl: List[Int]) -> ProductSubst:
    """Keep `q_j = n_j e` through `n_k := L`, `L = repl`: for `k != e`,
    `q_k := L_0 e + sum_i L_i q_i` (every `q_i` with `L_i != 0` in the
    lift); for `k = e` with `L = c + lam e`, `q_j := c n_j + lam q_j` and
    `q_e := c^2 + 2 c lam e + lam^2 q_e`. Not ok when `L` names a product
    coordinate, or `k = e` and `L` names another variable. A product
    coordinate `k >= m` changes nothing else (it is then free of the
    relation, which costs completeness only)."""
    var w = lift.width()
    var out = ProductSubst(True)
    if k >= lift.m:
        return out^
    for i in range(lift.m, w):
        if repl[i + 1] != 0:
            return ProductSubst(False)
    var e = lift.e
    if k != e:
        var at = -1
        for i in range(len(lift.prods)):
            if lift.prods[i] == k:
                at = i
        if at < 0:
            return out^
        var f = aff_const(w, 0)
        f[e + 1] = repl[0]
        for i in range(lift.m):
            if repl[i + 1] == 0:
                continue
            var slot = -1
            for t in range(len(lift.prods)):
                if lift.prods[t] == i:
                    slot = 1 + lift.m + t
            if slot < 0:
                return ProductSubst(False)
            f[slot] += repl[i + 1]
        out.vars.append(lift.m + at)
        out.forms.append(f^)
        return out^
    for i in range(lift.m):
        if i != e and repl[i + 1] != 0:
            return ProductSubst(False)
    var c = repl[0]
    var lam = repl[e + 1]
    for t in range(len(lift.prods)):
        var j = lift.prods[t]
        var f = aff_const(w, 0)
        if j == e:
            f[0] = c * c
            f[e + 1] = 2 * c * lam
            f[1 + lift.m + t] = lam * lam
        else:
            f[j + 1] = c
            f[1 + lift.m + t] = lam
        out.vars.append(lift.m + t)
        out.forms.append(f^)
    return out^
