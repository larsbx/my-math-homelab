"""Theorem K's open family: two witness lemmas, a census, and a pattern tree.

docs/p1a-a1-prime-2026-10-05.md §3f. Theorem K leaves one family of the
catch-up-free `|det M| = 2` class, with one odd letter `o`:

    sigma(o) = y,   sigma(y) = o w_1 o,   sigma(z) = o w_2 o,   w_1, w_2 ∈ {y, z}*,

where all-pairs strong coincidence is equivalent to `{o, y}` being eventually
coincident. `det M = 2 (Z_1 - Z_2)`, with `Z_i` the number of `z` in `w_i`, so
membership forces `|Z_1 - Z_2| = 1`; primitivity forces `Z_1 >= 1`.

**The certificate part** (`named_path`, `family_census`). Lemma Φ1 (`w_1`
begins with `y`) and Lemma Φ2 (`w_1` begins with `z` and the Parikh walks of
`w_1` and `w_2 + e_y` cross) each name an explicit witness path from the words;
the census checks every named path with `verify_witness` on the concrete
substitution and against the words themselves, and decides every remaining
-- non-crossing -- member exactly with `coincidence_level`, raising on a
negative. The lemmas are proved in the note; the census is an exact finite
check on a stated domain, not a proof beyond it.

**The delta split** (`delta_census`, `phi_path`, `phi_census`; note §3g).
`delta = pi(w_1) - pi(w_2)`. Lemma Φ4 (Pisot signs) and Lemma Φ5 (the
`Z_1 = Z_2 + 1` non-crossing shape) are checked on every member; Lemmas
Φ6-Φ8 name paths at the common points of the walks of `w_1` and `w_2 + e_z`,
which close the cell `delta = e_z` (Theorem Φ) and are measured on the rest.
With the `signatures` option `delta_census` also tallies the offset sequence
of each non-crossing member's shortest witness -- exploratory, to find the
next lemma.

**Run-shape cover** (`solve_constraint`, `cover_shape`, `shape_catalog`; note
§3h). A run shape fixes the letters of the maximal runs of `w_1` and `w_2`;
the run lengths are cone variables. The constraints `Z_1 - Z_2 = s` and an
exact `Delta` (or a tail `|Delta| >= D`) are imposed by substitutions that
partition the solutions; each region closes by a constant-offset or a
line-mode witness path (`psc.cone_witness`), a Lemma Φ4 or quadratic Lemma P1
cut, relational and value splits, or an exact decision once no variable is
left. A region still open at the limits or past the budget is reported
open. A cell with no open region is a proof for its whole infinite family.

**The exploratory part** (`cover_family`). A partition tree of word patterns
-- a letter `z`, a maximal run `y^(c + n)`, a run of exactly `c` letters `y`,
or an opaque tail known only by its Parikh vector -- refined atom by atom and
then by relational splits `n_i > n_j | n_i = n_j | n_i < n_j` of the cone
variables. A node closes when a parametric witness path (`psc.cone_witness`)
certifies it, when no member can lie in it, when Lemma P1 cuts it, or when it
is one substitution decided exactly. Every certified leaf is a proof on its
whole region; a node still open at the depth limit is reported as open and
never counted as covered. The tree does **not** converge as it stands (the
open leaves grow with the depth), so it is an instrument, not a cover.

Usage: `mojo run -I . odd_letter_family_certificate.mojo [max_len] [tree_depth | phi | delta | catalog]`,
or `pixi run odd-letter-family-certificate`.
"""

from std.sys import argv
from std.os.path import exists
from finite_linear_algebra.mat3 import Mat3
from psc.bpa import substitution_incidence
from std.collections import Dict
from psc.coincidence_formula import coincidence_level, coincidence_witness, pair_paths
from psc.cone_witness import (
    ConeFamily,
    apply_step,
    Segment,
    WitnessSearch,
    WitnessStep,
    aff_const,
    letter_segment,
    opaque_segment,
    run_of,
    search_witness,
    search_crossing,
    search_witness_line,
    verify_crossing,
    verify_witness,
    verify_witness_line,
    witness_position,
)
from psc.cone_witness import CrossingClose, aff_add, aff_eval, aff_is_const, aff_nonneg, aff_scale, aff_sub, crossing_conditions, lift_path, monotone_paths_meet, Prover, _q_lin, _qa, _q_nonneg, _q_nonneg_under
from psc.poly_line import PointPaths, PolyLift, lift_key, whole_region_lift, lift_path_poly, probe_points, poly_add, poly_affine_part, poly_from_aff, poly_higher, poly_mul, enumerate_point_paths, poly_is_zero, poly_key, solve_crossing_lift, solve_lift, steps_at, verify_crossing_poly, verify_witness_poly
from psc.product_lift import ProductLift, full_lift, lift_affine, lift_form, lift_point, mccormick_box_forms, no_lift, product_substitution, rlt_forms
from psc.prng import SplitMix64
from psc.farkas_lp import lp_infeasible
from psc.pisot import CubicScreen
from a1_normal_form_census import f_at, shared_tile_between

comptime O = 0
comptime Y = 1
comptime Z = 2

comptime A_Z = 0  # the letter z
comptime A_RUN = 1  # a maximal run y^(c + n), n a fresh cone variable
comptime A_FIX = 2  # a maximal run of exactly c letters y
comptime A_TAIL = 3  # any word; opaque

comptime OFFSET_BOUND = 3
comptime MAX_LEVEL = 6
comptime RUN_CAP = 3  # runs are split until their minimum length reaches this
comptime DEFAULT_DEPTH = 14
comptime DEFAULT_SPLITS = 4

comptime LEAF_CERTIFIED = 0
comptime LEAF_EMPTY = 1
comptime LEAF_DECIDED = 2
comptime LEAF_NOT_MEMBER = 3
comptime LEAF_FAILED = 4
comptime LEAF_CUT = 5
comptime NO_DELTA = -1000000  # cover_shape: leave Y_1 - Y_2 free
comptime PEEL_LIMIT = 4  # cover_shape: value splits n = 0 | n >= 1 beyond the relational ones
comptime REGION_BUDGET = 600  # cover_shape: regions examined per cell before reporting the rest open
comptime RUN_TREE_MAX_RUNS = 6  # run_tree: a pattern with this many revealed runs is not refined further
comptime RUN_TREE_SPLITS = 3  # run_tree: relational split depth per pattern
comptime RUN_TREE_PEEL = 3  # run_tree: value splits per pattern
comptime GUIDED_PEEL_LIMIT = 4  # guided cover: value peels on a branch before a region is reported open
comptime REPAIR_MAX_VALUE = 1 << 20  # a base point walked into a region stays far from overflow
comptime PROPAGATE_ROUNDS = 16  # guided cover: rounds of integer bound propagation
comptime SEARCH_NODES = 4000  # guided cover: nodes of the exact point search
comptime SEARCH_SPAN = 8  # guided cover: values tried for an unbounded variable in the point search
comptime LIFT_PATHS = 40  # guided cover: point paths tried by the linear lift
comptime LIFT_PATH_NODES = 5000  # guided cover: nodes of the point-path enumeration
comptime DESCENT_STARTS = 8  # guided cover: feasible non-member points a member descent starts from
comptime DESCENT_STEPS = 64  # guided cover: steps of one member descent
comptime SMALL_POINT_DRAWS = 100  # guided cover: seeded base-point draws in 0..4, tried first
comptime FM_ROWS = 4000  # guided cover: rows Fourier-Motzkin may hold before it gives up
comptime FM_MAGNITUDE = 1 << 40  # and the entry size
comptime FINITE_POINTS = 400  # guided cover: a region shown to hold at most this many points is enumerated
comptime DECIDE_POINTS = 2000  # at the peel limit: a finite region up to this size is decided point by point
comptime VALUE_SPLIT_MAX = 4  # guided cover: a live variable with fewer values is split by value
comptime ALT_BASE_POINTS = 4  # guided cover: further member points tried before a peel
comptime FAR_CANDIDATES = 24  # guided tail cover: candidates tried with a moderately large tail variable first
comptime BASE_POINT_SEED = 20261006  # guided cover: seed of the base-point search
comptime BASE_POINT_DRAWS = 300  # guided cover: generic draws before the constant fallbacks
comptime REVEAL_MAX_LEVEL = 6  # reveal census: witness depth before the Lemma X closure counts
comptime REVEAL_CAP = 8  # reveal census: largest r tried before reporting capped
comptime TAIL_VALUES = 64  # q-lift: tail values a real-point search enumerates before it truncates
comptime LINE_CAP = 1 << 16  # q-lift: the line offset a point search may reach (a run length)
comptime EAGER_EQUALITIES = 4  # q-lift: implied equalities substituted per region before its envelope
comptime Q_OFFSET_BOUND = 4  # q-lift: the point search's bound off the line (zy | yz passes (y, y, -4 e_o))
comptime AFFINE_SLOPES = 3  # q-lift: the e-parametric value split tries L = n_k - c e for c in 0..AFFINE_SLOPES
comptime AFFINE_REACH = 1 << 16  # q-lift: its search for a bound of L gives up past this value
comptime LAZY_PATH_NODES = 2000000  # q-lift: nodes of the lazy point-path enumeration before a region is reported open
comptime RUN_TREE_BUDGET = 300  # run_tree: regions examined per pattern before reporting the rest open


struct Pattern(Copyable, Movable, Writable):
    """Atoms of a word pattern, with the run length `c` of each run atom."""

    var atoms: List[Int]
    var mins: List[Int]

    def __init__(out self, var atoms: List[Int], var mins: List[Int]):
        self.atoms = atoms^
        self.mins = mins^

    def is_open(self) -> Bool:
        return len(self.atoms) > 0 and self.atoms[len(self.atoms) - 1] == A_TAIL

    def zeds(self) -> Int:
        var n = 0
        for k in range(len(self.atoms)):
            if self.atoms[k] == A_Z:
                n += 1
        return n

    def variables(self) -> Int:
        var n = 0
        for k in range(len(self.atoms)):
            if self.atoms[k] == A_RUN:
                n += 1
            elif self.atoms[k] == A_TAIL:
                n += 2
        return n

    def write_to[W: Writer](self, mut w: W):
        if len(self.atoms) == 0:
            w.write("ε")
        for k in range(len(self.atoms)):
            var a = self.atoms[k]
            if a == A_Z:
                w.write("z")
            elif a == A_RUN:
                w.write("y^(", self.mins[k], "+)")
            elif a == A_FIX:
                if self.mins[k] == 1:
                    w.write("y")
                else:
                    w.write("y^", self.mins[k])
            else:
                w.write("*")


def any_word() -> Pattern:
    return Pattern(List[Int]([A_TAIL]), List[Int]([0]))


def _replace(p: Pattern, k: Int, atoms: List[Int], mins: List[Int]) -> Pattern:
    """`p` with atom `k` replaced by the given atoms."""
    var na = List[Int]()
    var nm = List[Int]()
    for i in range(len(p.atoms)):
        if i == k:
            for j in range(len(atoms)):
                na.append(atoms[j])
                nm.append(mins[j])
        else:
            na.append(p.atoms[i])
            nm.append(p.mins[i])
    return Pattern(na^, nm^)


def refinements(p: Pattern, k: Int, z_free: Bool) -> List[Pattern]:
    """The partition of atom `k`. With `z_free` false the tail may hold no
    more `z`, so only its two `z`-free parts are kept."""
    var out = List[Pattern]()
    if p.atoms[k] == A_TAIL:
        out.append(_replace(p, k, List[Int](), List[Int]()))
        out.append(_replace(p, k, List[Int]([A_RUN]), List[Int]([1])))
        if z_free:
            out.append(_replace(p, k, List[Int]([A_Z, A_TAIL]), List[Int]([0, 0])))
            out.append(_replace(p, k, List[Int]([A_RUN, A_Z, A_TAIL]), List[Int]([1, 0, 0])))
    elif p.atoms[k] == A_RUN:
        var c = p.mins[k]
        out.append(_replace(p, k, List[Int]([A_FIX]), List[Int]([c])))
        out.append(_replace(p, k, List[Int]([A_RUN]), List[Int]([c + 1])))
    return out^


def _segments(p: Pattern, m: Int, subst: List[List[Int]], mut slot: Int) -> List[Segment]:
    """`o w o` for the pattern `w`. Its variable slots, from `slot` on, read
    their affine forms over the `m` free variables from `subst`: one slot
    per run (the run is `y^(c + form)`), two per tail (its `y`- and
    `z`-counts)."""
    var segs = List[Segment]()
    segs.append(letter_segment(m, O))
    for k in range(len(p.atoms)):
        var a = p.atoms[k]
        if a == A_Z:
            segs.append(letter_segment(m, Z))
        elif a == A_FIX:
            segs.append(run_of(Y, aff_const(m, p.mins[k])))
        elif a == A_RUN:
            var len_form = subst[slot].copy()
            len_form[0] += p.mins[k]
            slot += 1
            segs.append(run_of(Y, len_form^))
        else:
            var par = List[List[Int]]()
            par.append(aff_const(m, 0))
            par.append(subst[slot].copy())
            par.append(subst[slot + 1].copy())
            slot += 2
            segs.append(opaque_segment(par^))
    segs.append(letter_segment(m, O))
    return segs^


def identity_subst(m: Int) -> List[List[Int]]:
    var out = List[List[Int]]()
    for k in range(m):
        var f = aff_const(m, 0)
        f[k + 1] = 1
        out.append(f^)
    return out^


def family_of(p1: Pattern, p2: Pattern, subst: List[List[Int]]) raises -> ConeFamily:
    var m = len(subst)
    var images = List[List[Segment]]()
    var img_o = List[Segment]()
    img_o.append(letter_segment(m, Y))
    images.append(img_o^)
    var slot = 0
    images.append(_segments(p1, m, subst, slot))
    images.append(_segments(p2, m, subst, slot))
    return ConeFamily(m, images^)


def member_sigma(w1: List[Int], w2: List[Int]) -> List[List[Int]]:
    var s = List[List[Int]]()
    s.append(List[Int]([Y]))
    var iy = List[Int]([O])
    for k in range(len(w1)):
        iy.append(w1[k])
    iy.append(O)
    var iz = List[Int]([O])
    for k in range(len(w2)):
        iz.append(w2[k])
    iz.append(O)
    s.append(iy^)
    s.append(iz^)
    return s^


def matches(p: Pattern, w: List[Int]) -> Bool:
    """Does the word `w` belong to the pattern? Runs are maximal, so the match
    is greedy and unique."""
    var i = 0
    for k in range(len(p.atoms)):
        var a = p.atoms[k]
        if a == A_TAIL:
            return True
        if a == A_Z:
            if i >= len(w) or w[i] != Z:
                return False
            i += 1
            continue
        var run = 0
        while i < len(w) and w[i] == Y:
            run += 1
            i += 1
        if a == A_FIX and run != p.mins[k]:
            return False
        if a == A_RUN and run < p.mins[k]:
            return False
    return i == len(w)


def _f_value(fam: ConeFamily, ns: List[Int], t: Int) raises -> Int:
    return f_at(Mat3(substitution_incidence(fam.instantiate(ns))), t)


def pisot_cut(fam: ConeFamily) raises -> Int:
    """`t` in `{1, -1}` if `f(t) = det(tI - M)` is affine on the node with all
    coefficients nonnegative, so that Lemma P1 (`f(1) < 0`, `f(-1) < 0` for a
    PIP member) leaves no member; 0 otherwise. Affinity is checked at the
    base, the unit points, every sum of two unit points and every doubled one
    -- enough for a polynomial of degree at most two in each pair of
    variables, which `f` is, the variables sitting in two rows of `M`."""
    var m = fam.m
    for t in [1, -1]:
        var zero = List[Int](length=m, fill=0)
        var f0 = _f_value(fam, zero, t)
        var form = List[Int]([f0])
        for k in range(m):
            var e = zero.copy()
            e[k] = 1
            form.append(_f_value(fam, e, t) - f0)
        var affine = True
        for j in range(m):
            for k in range(j, m):
                var e = zero.copy()
                e[j] += 1
                e[k] += 1
                if _f_value(fam, e, t) != f0 + form[j + 1] + form[k + 1]:
                    affine = False
        if affine and aff_nonneg(form):
            return t
    return 0


struct Node(Copyable, Movable, Writable):
    """A region of the family: two patterns, the affine forms of their variable
    slots over the free variables, and the free-variable pairs already split
    relationally."""

    var p1: Pattern
    var p2: Pattern
    var subst: List[List[Int]]
    var compared: List[Int]
    var depth: Int

    def __init__(out self, var p1: Pattern, var p2: Pattern, var subst: List[List[Int]], var compared: List[Int], depth: Int):
        self.p1 = p1^
        self.p2 = p2^
        self.subst = subst^
        self.compared = compared^
        self.depth = depth

    def write_to[W: Writer](self, mut w: W):
        w.write("w1 = ", self.p1, "  w2 = ", self.p2)
        if len(self.compared) > 0:
            w.write("  slots")
            for k in range(len(self.subst)):
                w.write(" ", _form(self.subst[k]))


def _form(f: List[Int]) -> String:
    var out = String(f[0])
    for k in range(1, len(f)):
        if f[k] != 0:
            out += ("+" if f[k] > 0 else "") + String(f[k]) + "n" + String(k)
    return out


struct Leaf(Copyable, Movable):
    var kind: Int
    var node: Node
    var level: Int
    var steps: List[WitnessStep]

    def __init__(out self, kind: Int, var node: Node, level: Int, var steps: List[WitnessStep]):
        self.kind = kind
        self.node = node^
        self.level = level
        self.steps = steps^


struct FamilyCover(Copyable, Movable):
    var leaves: List[Leaf]
    var nodes: Int
    var certified: Int
    var empty: Int
    var decided: Int
    var not_member: Int
    var cut: Int
    var failed: Int

    def __init__(out self):
        self.leaves = List[Leaf]()
        self.nodes = 0
        self.certified = 0
        self.empty = 0
        self.decided = 0
        self.not_member = 0
        self.cut = 0
        self.failed = 0


def _no_member(p1: Pattern, p2: Pattern) -> Bool:
    """No member of the family lies in the node: `w_1` complete without `z`,
    or the revealed `z`-counts already force `|Z_1 - Z_2| != 1`."""
    var z1 = p1.zeds()
    var z2 = p2.zeds()
    if not p1.is_open() and z1 == 0:
        return True
    if not p1.is_open() and not p2.is_open():
        return abs(z1 - z2) != 1
    if not p1.is_open():
        return z2 > z1 + 1
    if not p2.is_open():
        return z1 > z2 + 1
    return False


def _z_free(p: Pattern, other: Pattern) -> Bool:
    """May the tail of `p` still hold a `z`? Not if `other` is complete and
    `p` already has `Z_other + 1` of them."""
    if other.is_open():
        return True
    return p.zeds() < other.zeds() + 1


def _pick(p1: Pattern, p2: Pattern) -> List[Int]:
    """The earliest refinable atom, `w_1` first on ties: `[word, index]`, or
    `[-1, -1]` if none."""
    var longest = max(len(p1.atoms), len(p2.atoms))
    for k in range(longest):
        for wi in range(2):
            ref p = p1 if wi == 0 else p2
            if k >= len(p.atoms):
                continue
            if p.atoms[k] == A_TAIL or (p.atoms[k] == A_RUN and p.mins[k] < RUN_CAP):
                return List[Int]([wi, k])
    return List[Int]([-1, -1])


def _live(subst: List[List[Int]], k: Int) -> Bool:
    for i in range(len(subst)):
        if subst[i][k + 1] != 0:
            return True
    return False


def _split(subst: List[List[Int]], i: Int, j: Int, which: Int) -> List[List[Int]]:
    """Substitute `n_i <- n_j + 1 + n_i` (case 0), `n_i <- n_j` (case 1) or
    `n_j <- n_i + 1 + n_j` (case 2) in every form: a partition of `(n_i, n_j)`
    into `n_i > n_j`, `n_i = n_j`, `n_i < n_j`."""
    var out = List[List[Int]]()
    for k in range(len(subst)):
        var f = subst[k].copy()
        if which == 0:
            f[0] += f[i + 1]
            f[j + 1] += f[i + 1]
        elif which == 1:
            f[j + 1] += f[i + 1]
            f[i + 1] = 0
        else:
            f[0] += f[j + 1]
            f[i + 1] += f[j + 1]
        out.append(f^)
    return out^


def _next_pair(node: Node) -> List[Int]:
    """The first pair of live free variables not yet split, or `[-1, -1]`."""
    var m = len(node.subst)
    for i in range(m):
        if not _live(node.subst, i):
            continue
        for j in range(i + 1, m):
            if not _live(node.subst, j):
                continue
            var code = i * 1000 + j
            var seen = False
            for c in range(len(node.compared)):
                if node.compared[c] == code:
                    seen = True
            if not seen:
                return List[Int]([i, j])
    return List[Int]([-1, -1])


def cover_family(depth_limit: Int, split_limit: Int) raises -> FamilyCover:
    """The partition tree. Atoms are refined first, up to `depth_limit`; a
    node whose patterns are fully refined (no tail, every run at `RUN_CAP`)
    is then split relationally, up to `split_limit` splits."""
    var out = FamilyCover()
    var screen = CubicScreen()
    var stack = List[Node]()
    stack.append(Node(any_word(), any_word(), identity_subst(4), List[Int](), 0))
    while len(stack) > 0:
        var node = stack.pop()
        out.nodes += 1
        if _no_member(node.p1, node.p2):
            out.leaves.append(Leaf(LEAF_EMPTY, node^, 0, List[WitnessStep]()))
            out.empty += 1
            continue
        var fam = family_of(node.p1, node.p2, node.subst)
        var cut = pisot_cut(fam)
        if cut != 0:
            out.leaves.append(Leaf(LEAF_CUT, node^, cut, List[WitnessStep]()))
            out.cut += 1
            continue
        var w = search_witness(fam, O, Y, OFFSET_BOUND, MAX_LEVEL, True)
        if w.found:
            if not verify_witness(fam, O, Y, w.steps):
                raise Error("a witness path the search found does not verify")
            out.leaves.append(Leaf(LEAF_CERTIFIED, node^, len(w.steps), w.steps.copy()))
            out.certified += 1
            continue
        var any_live = False
        for k in range(len(node.subst)):
            if _live(node.subst, k):
                any_live = True
        if not any_live:
            var sigma = fam.instantiate(List[Int](length=fam.m, fill=0))
            var mat = Mat3(substitution_incidence(sigma))
            if abs(mat.det()) != 2 or not screen.is_pip(mat):
                out.leaves.append(Leaf(LEAF_NOT_MEMBER, node^, 0, List[WitnessStep]()))
                out.not_member += 1
                continue
            var lev = coincidence_level(sigma, O, Y)
            if lev < 0:
                raise Error("SC REFUTED in Theorem K's family: {o, y} is not eventually coincident")
            out.leaves.append(Leaf(LEAF_DECIDED, node^, lev, List[WitnessStep]()))
            out.decided += 1
            continue
        var pick = _pick(node.p1, node.p2)
        if pick[0] >= 0:
            if node.depth >= depth_limit:
                out.leaves.append(Leaf(LEAF_FAILED, node^, 0, List[WitnessStep]()))
                out.failed += 1
                continue
            var kids = refinements(node.p1, pick[1], _z_free(node.p1, node.p2)) if pick[0] == 0 else refinements(node.p2, pick[1], _z_free(node.p2, node.p1))
            for c in range(len(kids)):
                var q1 = kids[c].copy() if pick[0] == 0 else node.p1.copy()
                var q2 = node.p2.copy() if pick[0] == 0 else kids[c].copy()
                var m = q1.variables() + q2.variables()
                stack.append(Node(q1^, q2^, identity_subst(m), List[Int](), node.depth + 1))
            continue
        var pair = _next_pair(node)
        if pair[0] < 0 or len(node.compared) >= split_limit:
            out.leaves.append(Leaf(LEAF_FAILED, node^, 0, List[WitnessStep]()))
            out.failed += 1
            continue
        for which in range(3):
            var comp = node.compared.copy()
            comp.append(pair[0] * 1000 + pair[1])
            stack.append(Node(node.p1.copy(), node.p2.copy(), _split(node.subst, pair[0], pair[1], which), comp^, node.depth))
    return out^


def slot_values(p: Pattern, w: List[Int]) -> List[Int]:
    """For a word the pattern matches, the values its variable slots take:
    `len - c` for each run, the `y`- and `z`-counts of the tail."""
    var out = List[Int]()
    var i = 0
    for k in range(len(p.atoms)):
        var a = p.atoms[k]
        if a == A_Z:
            i += 1
        elif a == A_TAIL:
            var ny = 0
            var nz = 0
            while i < len(w):
                if w[i] == Y:
                    ny += 1
                else:
                    nz += 1
                i += 1
            out.append(ny)
            out.append(nz)
        else:
            var run = 0
            while i < len(w) and w[i] == Y:
                run += 1
                i += 1
            if a == A_RUN:
                out.append(run - p.mins[k])
    return out^


def _reachable(subst: List[List[Int]], want: List[Int], k: Int, mut ns: List[Int], bound: Int) -> Bool:
    if k == len(ns):
        for s in range(len(subst)):
            var v = subst[s][0]
            for j in range(len(ns)):
                v += subst[s][j + 1] * ns[j]
            if v != want[s]:
                return False
        return True
    for x in range(bound + 1):
        ns[k] = x
        if _reachable(subst, want, k + 1, ns, bound):
            return True
    return False


def leaf_index(cov: FamilyCover, w1: List[Int], w2: List[Int], bound: Int) -> Int:
    """The leaf whose region contains `(w_1, w_2)`: the patterns match and the
    slot values are the node's forms at some point with coordinates at most
    `bound`. -1 if none."""
    for i in range(len(cov.leaves)):
        ref nd = cov.leaves[i].node
        if not matches(nd.p1, w1) or not matches(nd.p2, w2):
            continue
        var want = slot_values(nd.p1, w1)
        var v2 = slot_values(nd.p2, w2)
        for k in range(len(v2)):
            want.append(v2[k])
        if len(nd.compared) == 0:
            return i  # identity forms: a match is membership
        var ns = List[Int](length=len(nd.subst), fill=0)
        if _reachable(nd.subst, want, 0, ns, bound):
            return i
    return -1


def main() raises:
    var args = argv()
    var max_len = Int(String(args[1])) if len(args) > 1 else 6
    var c = family_census(max_len)
    print("Theorem K's family, |w_1|, |w_2| <=", max_len, ":", c.members, "PIP members with |det M| = 2")
    print("  Lemma Phi1 (w1 begins with y):", c.by_phi1, "  Lemma Phi2 (walks cross):", c.by_phi2, "  named path failed:", c.lemma_failed)
    print("  non-crossing, decided exactly:", c.non_crossing, " deepest level", c.max_level)
    for k in range(16):
        if c.levels[k] != 0:
            print("    level", k, ":", c.levels[k])
    if len(args) > 2 and String(args[2]) == "catalog":
        var cat = shape_catalog(max_len, 3, 4, True)
        var closed = 0
        var closed_keys = Dict[String, Int]()
        for k in range(len(cat)):
            if cat[k].open == 0:
                closed += 1
                closed_keys[cat[k].key] = 1
        print("shape cells:", len(cat), " closed:", closed)
        var pc2 = phi_census(max_len)
        var res_total = 0
        var res_closed = 0
        for e in pc2.shapes.items():
            var parts = e.key.split(" | ")
            var head = parts[0].split(" ")
            var cell = delta_cell(Int(String(head[1])), Int(String(head[0])), 3)
            var key = String(head[0]) + " " + String(cell[0]) + ("+" if cell[1] == 1 else "") + " | " + String(parts[1]) + " | " + String(parts[2])
            res_total += e.value
            if key in closed_keys:
                res_closed += e.value
        print("residue members:", res_total, " in closed shape cells:", res_closed, " left:", res_total - res_closed)
        return
    if len(args) > 2 and String(args[2]) == "zcap":
        # Theorem K's members with Z_2 <= cap, every Delta: zcap s cap budget [journal]
        var s = Int(String(args[3]))
        var cap = Int(String(args[4]))
        var budget = Int(String(args[5])) if len(args) > 5 else 5000
        var journal = String(args[6]) if len(args) > 6 else String()
        var c = zcap_cover(s, cap, budget, True, journal)
        print("s =", s, " Z_2 <=", cap, ", every Delta: patterns", c.patterns, " closed", c.closed, " regions", c.regions, " -> ", "CLOSED" if c.closed == c.patterns else "OPEN", flush=True)
        return
    if len(args) > 2 and String(args[2]) == "zfloor":
        # Theorem K's tail members with Z_2 >= floor, Lemma P1 linear:
        # zfloor s delta floor budget [max_runs] [journal]
        var s = Int(String(args[3]))
        var d = Int(String(args[4]))
        var floor = Int(String(args[5]))
        var budget = Int(String(args[6]))
        var max_runs = Int(String(args[7])) if len(args) > 7 else 8
        var journal = String(args[8]) if len(args) > 8 else String()
        print("s =", s, " |Delta| >=", abs(d), " Z_2 >=", floor, ": guided run tree, region budget", budget, "per pattern, at most", max_runs, "revealed runs", flush=True)
        var leaves = run_tree_guided(s, d, max_runs, budget, True, s == 1, s == -1, journal, floor)
        var closed = 0
        for k in range(len(leaves)):
            if leaves[k].closed:
                closed += 1
        print("s =", s, " |Delta| >=", abs(d), " Z_2 >=", floor, ": leaves", len(leaves), " closed", closed, " -> ", "CLOSED" if closed == len(leaves) else "OPEN", flush=True)
        return
    if len(args) > 2 and String(args[2]) == "qlift":
        # one tail pattern by the guided cover over (n, q), q_j = n_j e:
        # qlift s delta floor budget l1 open1 l2 open2 (l like "zy", "-" empty)
        var s = Int(String(args[3]))
        var d = Int(String(args[4]))
        var floor = Int(String(args[5]))
        var budget = Int(String(args[6]))
        var pat = RunPattern(_letters(String(args[7])), String(args[8]) == "1", _letters(String(args[9])), String(args[10]) == "1")
        if s == 1:
            pat.tail_run1 = d
        var c = cover_pattern_guided(pat, s, d, budget, True, True, z_floor=floor, q_lift=True)
        print(pat, ": regions", c.regions, " certified", c.certified, " line", c.line_certified, " poly", c.poly_certified, " crossing", c.crossing_certified, " cut", c.cut, " decided", c.decided, " not member", c.not_member, " open", c.open, " budget exhausted" if c.budget_exhausted else "", flush=True)
        for k in range(len(c.open_forms)):
            var line = String("  open slots")
            for i in range(len(c.open_forms[k])):
                line += " [" + _form_str(c.open_forms[k][i]) + "]"
            print(line)
        return
    if len(args) > 2 and String(args[2]) == "cell":
        # one delta cell by the guided run tree:
        # cell s delta budget [max_runs] [tail|xblock|plain] [journal path]
        var s = Int(String(args[3]))
        var d = Int(String(args[4]))
        var budget = Int(String(args[5]))
        var max_runs = Int(String(args[6])) if len(args) > 6 else 8
        print("cell s =", s, " Delta =", d, ": guided run tree, region budget", budget, "per pattern, at most", max_runs, "revealed runs", flush=True)
        var tail_cell = len(args) > 7 and String(args[7]) == "tail"
        var xroot = len(args) > 7 and String(args[7]) == "xblock"
        var journal = String(args[8]) if len(args) > 8 else String()
        var leaves = run_tree_guided(s, d, max_runs, budget, True, tail_cell, xroot, journal)
        var closed = 0
        for k in range(len(leaves)):
            if leaves[k].closed:
                closed += 1
        print("cell s =", s, " Delta =", d, ": leaves", len(leaves), " closed", closed, " -> ", "CLOSED" if closed == len(leaves) else "OPEN", flush=True)
        return
    if len(args) > 2 and String(args[2]) == "reveal":
        # exhaustive: lengths 1..max_len of the longer word
        print("least revealed runs of a Lemma X certificate (level <=", REVEAL_MAX_LEVEL, ", r capped at", REVEAL_CAP, "; 0 = capped):")
        var first = Int(String(args[3])) if len(args) > 3 else 2
        for L in range(first, max_len + 1):
            var h = reveal_census(L, REVEAL_MAX_LEVEL, REVEAL_CAP)
            var line = "  longer word of length " + String(L) + ":"
            for r in range(len(h)):
                if h[r] != 0:
                    line += "  r=" + String(r) + ": " + String(h[r])
            print(line, flush=True)
        return
    if len(args) > 2 and String(args[2]) == "reveal-sample":
        var seed = Int(String(args[3]))
        var lo = Int(String(args[4]))
        var hi = Int(String(args[5]))
        var want = Int(String(args[6]))
        var budget = 400 * want
        var h = reveal_sample(seed, lo, hi, want, budget, REVEAL_MAX_LEVEL, REVEAL_CAP)
        var line = "seed " + String(seed) + ", lengths " + String(lo) + ".." + String(hi) + ", budget " + String(budget) + " draws: " + String(h[REVEAL_CAP + 1]) + " members" + (" (budget exhausted)" if h[REVEAL_CAP + 1] < want else "") + ";"
        for r in range(REVEAL_CAP + 1):
            if h[r] != 0:
                line += "  r=" + String(r) + ": " + String(h[r])
        print(line)
        return
    if len(args) > 2 and String(args[2]) == "excursions":
        var residue = residue_members(max_len)
        var hist = Dict[Int, Int]()
        for k in range(len(residue)):
            var n = common_points(residue[k].w1, residue[k].w2)
            hist[n] = hist.get(n, 0) + 1
        print("residue members:", len(residue), "; by number of common points:")
        for e in hist.items():
            print("   ", e.key, ":", e.value)
        return
    if len(args) > 2 and String(args[2]) == "runs":
        var residue = residue_members(max_len)
        print("run tree (max runs", RUN_TREE_MAX_RUNS, " splits", RUN_TREE_SPLITS, " peel", RUN_TREE_PEEL, " budget", RUN_TREE_BUDGET, "per pattern); residue members:", len(residue))
        var cell_s = List[Int]([1, 1, 1, -1, -1, -1])
        var cell_d = List[Int]([1, 2, 3, 0, -1, -2])
        for k in range(len(cell_s)):
            var s = cell_s[k]
            var d = cell_d[k]
            print("  cell s", s, " Delta", d, flush=True)
            var leaves = run_tree(s, d, False, RUN_TREE_MAX_RUNS, RUN_TREE_SPLITS, RUN_TREE_PEEL, RUN_TREE_BUDGET, True)
            var t = run_tree_tally(leaves, residue, s, d)
            print("  cell s", s, " Delta", d, ": leaves", t.leaves, " closed", t.closed_leaves, "; residue members", t.members, " in closed leaves", t.in_closed, flush=True)
        return
    if len(args) > 2 and String(args[2]) == "phi":
        var pc = phi_census(max_len, len(args) > 3)
        print("Lemmas Phi6-Phi8: non-crossing", pc.non_crossing, " covered", pc.by_lemma, " failed", pc.lemma_failed, " delta = e_z residue", pc.cell_ez_residue)
        for e in pc.residue.items():
            print("    residue (s dy)", e.key, ":", e.value)
        for k in range(16):
            if pc.residue_levels[k] != 0:
                print("    residue level", k, ":", pc.residue_levels[k])
        for e in pc.signatures.items():
            print("  SIG", e.key)
        for e in pc.shapes.items():
            print("  SHAPE", e.value, " ", e.key)
        return
    if len(args) > 2 and String(args[2]) == "delta":
        var dc = delta_census(max_len, True)
        print("delta split: members", dc.members, " sign violations", dc.sign_violations, " non-crossing", dc.non_crossing, " shape violations", dc.shape_violations)
        print("cells (s dy level): count")
        for e in dc.cells.items():
            print("   ", e.key, ":", e.value)
        print("signatures (s dy | gamma:a,b ...): count")
        for e in dc.signatures.items():
            print("   ", e.value, "  ", e.key)
        return
    if len(args) > 2:
        var depth = Int(String(args[2]))
        var cov = cover_family(depth, DEFAULT_SPLITS)
        print("exploratory pattern tree to depth", depth, ":", cov.nodes, "nodes; certified", cov.certified, " empty", cov.empty, " Lemma P1 cuts", cov.cut, " decided", cov.decided, " not members", cov.not_member, " OPEN", cov.failed)


# ---------------------------------------------------------------------------
# Lemmas Φ1 and Φ2 (docs/p1a-a1-prime-2026-10-05.md §3f): explicit witness
# paths named from the words, checked by `verify_witness` on the concrete
# substitution and against the words themselves. No search.
# ---------------------------------------------------------------------------


def concrete_family(sigma: List[List[Int]]) raises -> ConeFamily:
    """A single substitution as a cone family with no variables: one letter
    segment per letter, so a segment index is a position."""
    var images = List[List[Segment]]()
    for a in range(3):
        var img = List[Segment]()
        for k in range(len(sigma[a])):
            img.append(letter_segment(0, sigma[a][k]))
        images.append(img^)
    return ConeFamily(0, images^)


def _step(i: Int, k: Int) -> WitnessStep:
    return WitnessStep(i, aff_const(0, 0), k, aff_const(0, 0))


def crossing(w1: List[Int], w2: List[Int]) -> List[Int]:
    """The first `(i, k)` with `i, k >= 1` and `pi(w1[:i]) = pi(w2[:k]) + e_y`,
    or `[-1, -1]`: the Parikh walk of `w_1` meets that of `w_2` shifted by
    `e_y`. The lengths force `i = k + 1`, and then equal `y`-counts up to one
    give equal `z`-counts."""
    var py2 = List[Int]([0])
    for j in range(len(w2)):
        py2.append(py2[j] + (1 if w2[j] == Y else 0))
    var y1 = 0
    for i in range(1, len(w1) + 1):
        if w1[i - 1] == Y:
            y1 += 1
        var k = i - 1
        if k >= 1 and k <= len(w2) and y1 == py2[k] + 1:
            return List[Int]([i, k])
    return List[Int]([-1, -1])


def named_path(w1: List[Int], w2: List[Int]) -> List[WitnessStep]:
    """Lemma Φ1 (`w_1` begins with `y`) or Lemma Φ2 (`w_1` begins with `z` and
    the walks cross): the path the lemma names, or an empty list."""
    var steps = List[WitnessStep]()
    if len(w1) == 0:
        return steps^
    steps.append(_step(0, 1))  # sigma(o) = y at 0; sigma(y) = o w1 o at 1
    if w1[0] == Y:
        if len(w1) < 2:
            return List[WitnessStep]()
        steps.append(_step(2, 1))  # gamma = -e_y + pi(o y) - pi(o) = 0
        if w1[1] != Y:
            steps.append(_step(0, 0))  # (z, y, 0): both images begin with o
        return steps^
    var c = crossing(w1, w2)
    if c[0] < 0:
        return List[WitnessStep]()
    steps.append(_step(c[0], c[1]))  # gamma = e_b - e_a, letters w1[i-1], w2[k-1]
    if w1[c[0] - 1] != w2[c[1] - 1]:
        var a = w1[c[0] - 1]
        var b = w2[c[1] - 1]
        var la = len(w1) + 1 if a == Y else len(w2) + 1
        var lb = len(w1) + 1 if b == Y else len(w2) + 1
        steps.append(_step(la, lb))  # the two final o's
    return steps^


struct FamilyCensus(Copyable, Movable):
    var members: Int
    var by_phi1: Int
    var by_phi2: Int
    var non_crossing: Int
    var lemma_failed: Int
    var levels: List[Int]  # exact levels of the non-crossing members
    var max_level: Int

    def __init__(out self):
        self.members = 0
        self.by_phi1 = 0
        self.by_phi2 = 0
        self.non_crossing = 0
        self.lemma_failed = 0
        self.levels = List[Int](length=16, fill=0)
        self.max_level = 0


def _words(max_len: Int) -> List[List[Int]]:
    var out = List[List[Int]]()
    out.append(List[Int]())
    var start = 0
    for _ in range(max_len):
        var end = len(out)
        for k in range(start, end):
            for letter in [Y, Z]:
                var w = out[k].copy()
                w.append(letter)
                out.append(w^)
        start = end
    return out^


def family_census(max_len: Int) raises -> FamilyCensus:
    """Every PIP member with `|det M| = 2` and `|w_1|, |w_2| <= max_len`: the
    lemma's named path verifies and names a shared tile of the actual words,
    or the member is non-crossing and is decided by `coincidence_level`
    (a negative would raise)."""
    var out = FamilyCensus()
    var screen = CubicScreen()
    var words = _words(max_len)
    for a in range(len(words)):
        ref w1 = words[a]
        var z1 = 0
        for k in range(len(w1)):
            if w1[k] == Z:
                z1 += 1
        for b in range(len(words)):
            ref w2 = words[b]
            var z2 = 0
            for k in range(len(w2)):
                if w2[k] == Z:
                    z2 += 1
            if abs(z1 - z2) != 1:
                continue
            var sigma = member_sigma(w1, w2)
            var mat = Mat3(substitution_incidence(sigma))
            if abs(mat.det()) != 2 or not screen.is_pip(mat):
                continue
            out.members += 1
            var steps = named_path(w1, w2)
            if len(steps) > 0:
                var fam = concrete_family(sigma)
                var ok = verify_witness(fam, O, Y, steps)
                if ok:
                    var pos = witness_position(fam, O, Y, steps, List[Int]())
                    ok = shared_tile_between(sigma, O, Y, len(steps), pos)
                if not ok:
                    out.lemma_failed += 1
                elif w1[0] == Y:
                    out.by_phi1 += 1
                else:
                    out.by_phi2 += 1
                continue
            out.non_crossing += 1
            var lev = coincidence_level(sigma, O, Y)
            if lev < 0:
                raise Error("SC REFUTED in Theorem K's family: {o, y} is not eventually coincident")
            out.levels[min(lev, 15)] += 1
            if lev > out.max_level:
                out.max_level = lev
    return out^


# ---------------------------------------------------------------------------
# The delta split (docs/p1a-a1-prime-2026-10-05.md §3g). delta = pi(w_1) -
# pi(w_2) = (Y_1 - Y_2, Z_1 - Z_2) = (dy, s). Lemma Φ4 (Pisot signs) and
# Lemma Φ5 (the s = +1 non-crossing shape) are checked on every member; the
# non-crossing members are then sorted by (s, dy) and by the offset sequence
# of their shortest witness -- exploratory, to find the next lemma.
# ---------------------------------------------------------------------------


def _signature(sigma: List[List[Int]]) raises -> String:
    """The offsets and letter pairs along the shortest `{o, y}` witness that
    `coincidence_witness` returns, as `gamma:a,b|...`."""
    var w = coincidence_witness(sigma, O, Y)
    if w.empty:
        raise Error("SC REFUTED in Theorem K's family")
    var radix = 0
    for a in range(3):
        radix = max(radix, len(sigma[a]))
    var paths = pair_paths(radix, w.word)
    var m = Mat3(substitution_incidence(sigma))
    var g = List[Int]([0, 0, 0])
    var a = O
    var b = Y
    var names = List[String](["o", "y", "z"])
    var out = String("")
    for l in range(len(w.word)):
        var i = paths[0][l]
        var k = paths[1][l]
        var g2 = List[Int]()
        for r in range(3):
            var v = 0
            for c in range(3):
                v += m.e[3 * r + c] * g[c]
            for j in range(i):
                if sigma[a][j] == r:
                    v += 1
            for j in range(k):
                if sigma[b][j] == r:
                    v -= 1
            g2.append(v)
        g = g2^
        a = sigma[a][i]
        b = sigma[b][k]
        if l > 0:
            out += "|"
        out += "(" + String(g[0]) + "," + String(g[1]) + "," + String(g[2]) + ")" + names[a] + names[b]
    return out


struct DeltaCensus(Copyable, Movable):
    var members: Int
    var sign_violations: Int  # Lemma Φ4: s = +1 needs dy >= 0; s = -1 needs dy <= 0 and Z_2 >= 2
    var shape_violations: Int  # Lemma Φ5: s = +1 non-crossing has w_1 = u y^dy, pi(u) = pi(w_2) + e_z
    var non_crossing: Int
    var cells: Dict[String, Int]  # "s dy level" -> count
    var signatures: Dict[String, Int]  # "s dy | signature" -> count

    def __init__(out self):
        self.members = 0
        self.sign_violations = 0
        self.shape_violations = 0
        self.non_crossing = 0
        self.cells = Dict[String, Int]()
        self.signatures = Dict[String, Int]()


def _bump(mut d: Dict[String, Int], key: String) raises:
    if key in d:
        d[key] = d[key] + 1
    else:
        d[key] = 1


def delta_census(max_len: Int, with_signatures: Bool) raises -> DeltaCensus:
    var out = DeltaCensus()
    var screen = CubicScreen()
    var words = _words(max_len)
    for ia in range(len(words)):
        ref w1 = words[ia]
        for ib in range(len(words)):
            ref w2 = words[ib]
            var y1 = 0
            var z1 = 0
            var y2 = 0
            var z2 = 0
            for k in range(len(w1)):
                if w1[k] == Y:
                    y1 += 1
                else:
                    z1 += 1
            for k in range(len(w2)):
                if w2[k] == Y:
                    y2 += 1
                else:
                    z2 += 1
            var s = z1 - z2
            if abs(s) != 1:
                continue
            var sigma = member_sigma(w1, w2)
            var mat = Mat3(substitution_incidence(sigma))
            if not screen.is_pip(mat):
                continue
            out.members += 1
            var dy = y1 - y2
            if (s == 1 and dy < 0) or (s == -1 and (dy > 0 or z2 < 2)):
                out.sign_violations += 1
            if len(w1) == 0 or w1[0] != Z or crossing(w1, w2)[0] >= 0:
                continue
            out.non_crossing += 1
            if s == 1:
                # w_1 = u y^dy with pi(u) = pi(w_2) + e_z
                var lu = len(w1) - dy
                var ok = lu >= 0
                if ok:
                    for k in range(lu, len(w1)):
                        if w1[k] != Y:
                            ok = False
                    var uy = 0
                    for k in range(lu):
                        if w1[k] == Y:
                            uy += 1
                    if uy != y2 or (lu - uy) != z2 + 1:
                        ok = False
                if not ok:
                    out.shape_violations += 1
            var lev = coincidence_level(sigma, O, Y)
            if lev < 0:
                raise Error("SC REFUTED in Theorem K's family: {o, y} is not eventually coincident")
            _bump(out.cells, String(s) + " " + String(dy) + " " + String(lev))
            if with_signatures:
                _bump(out.signatures, String(s) + " " + String(dy) + " | " + _signature(sigma))
    return out^


# ---------------------------------------------------------------------------
# Lemmas Φ6-Φ8 (§3g): named paths for the non-crossing members. Each lemma
# supplies the core positions; `_finish` closes a state that is already good
# (equal letters at offset 0; two letters of {y, z} at offset 0, which meet
# again at their images' initial o; or offset e_b - e_a, which meet at the
# final o). `verify_witness` then checks everything.
# ---------------------------------------------------------------------------


def _walk(w: List[Int]) -> List[List[Int]]:
    """Prefix Parikh vectors `(y, z)` of `w`, lengths 0 to |w|."""
    var out = List[List[Int]]()
    out.append(List[Int]([0, 0]))
    for k in range(len(w)):
        var p = out[k].copy()
        if w[k] == Y:
            p[0] += 1
        else:
            p[1] += 1
        out.append(p^)
    return out^


def _finish(fam: ConeFamily, var steps: List[WitnessStep]) -> List[WitnessStep]:
    """Append the closing step, if the state the steps reach is good; return
    an empty list otherwise."""
    var a = O
    var b = Y
    var g = List[Int]([0, 0, 0])
    for l in range(len(steps)):
        var r = apply_step(fam, a, b, g, steps[l])
        if not r.ok:
            return List[WitnessStep]()
        a = r.a
        b = r.b
        g = r.gamma.copy()
    if a == b and g == List[Int]([0, 0, 0]):
        return steps^
    if a == O or b == O:
        return List[WitnessStep]()
    if g == List[Int]([0, 0, 0]):
        steps.append(_step(0, 0))
        return steps^
    var want = List[Int]([0, 0, 0])
    want[b] += 1
    want[a] -= 1
    if g == want:
        steps.append(_step(len(fam.images[a]) - 1, len(fam.images[b]) - 1))
        return steps^
    return List[WitnessStep]()


def _factor_closures(fam: ConeFamily, var head: List[WitnessStep], w: List[Int], dy: Int, dz: Int) -> List[WitnessStep]:
    """From a state `(a, a, g)` whose next offset needs a factor of `w = w_a`
    with Parikh `(dy, dz)` -- a-side position after it, b-side at its start --
    or with Parikh `-(dy, dz)` the other way round: try every occurrence, in
    both the start form and the end form shifted by one."""
    var pw = _walk(w)
    for f0 in range(len(w) + 1):
        for f1 in range(f0 + 1, len(w) + 1):
            var fy = pw[f1][0] - pw[f0][0]
            var fz = pw[f1][1] - pw[f0][1]
            var forms = List[List[Int]]()
            if fy == dy and fz == dz:
                forms.append(List[Int]([f1 + 1, f0 + 1]))
                forms.append(List[Int]([f1, f0]))
            if fy == -dy and fz == -dz:
                forms.append(List[Int]([f0 + 1, f1 + 1]))
                forms.append(List[Int]([f0, f1]))
            for k in range(len(forms)):
                var s = head.copy()
                s.append(_step(forms[k][0], forms[k][1]))
                var done = _finish(fam, s^)
                if len(done) > 0:
                    return done^
    return List[WitnessStep]()


def phi_path(w1: List[Int], w2: List[Int]) raises -> List[WitnessStep]:
    """The first of Lemmas Φ6, Φ7, Φ8 that applies, as a path; empty if none."""
    var sigma = member_sigma(w1, w2)
    var fam = concrete_family(sigma)
    var dy = 0
    var dz = 0
    for k in range(len(w1)):
        dy += 1 if w1[k] == Y else 0
        dz += 1 if w1[k] == Z else 0
    for k in range(len(w2)):
        dy -= 1 if w2[k] == Y else 0
        dz -= 1 if w2[k] == Z else 0
    var p1 = _walk(w1)
    var p2 = _walk(w2)
    # Common points: pi(w1[:t]) = pi(w2[:t-1]) + e_z, with both next letters.
    for t in range(1, len(w1)):
        if t - 1 >= len(w2):
            break
        if p1[t][0] != p2[t - 1][0] or p1[t][1] != p2[t - 1][1] + 1:
            continue
        var head = List[WitnessStep]()
        head.append(_step(0, 1))
        head.append(_step(t + 1, t))
        var a = w1[t]
        var b = w2[t - 1]
        if a == b:  # Lemma Φ6
            var done = _factor_closures(fam, head^, w1 if a == Y else w2, dy, dz)
            if len(done) > 0:
                return done^
        elif a == Z and b == Y:  # Lemma Φ8: W_2 meets W_1 + delta
            for m in range(len(w2) + 1):
                for n in range(len(w1) + 1):
                    if p2[m][0] != p1[n][0] + dy or p2[m][1] != p1[n][1] + dz:
                        continue
                    for shift in range(2):
                        var s = head.copy()
                        s.append(_step(m + 1 - shift, n + 1 - shift))
                        var done = _finish(fam, s^)
                        if len(done) > 0:
                            return done^
    # Lemma Φ7: delta = e_z, w1 = zz..., w2 = y...
    if dy == 0 and dz == 1 and len(w1) >= 2 and w1[0] == Z and w1[1] == Z and len(w2) >= 1 and w2[0] == Y:
        var head = List[WitnessStep]()
        head.append(_step(0, 1))
        head.append(_step(2, 0))
        head.append(_step(1, 0))
        var done = _factor_closures(fam, head^, w1, -1, -1)  # the a-side sits at the factor's start
        if len(done) > 0:
            return done^
    return List[WitnessStep]()


struct PhiCensus(Copyable, Movable):
    var non_crossing: Int
    var by_lemma: Int
    var lemma_failed: Int
    var residue: Dict[String, Int]  # "s dy" -> residual count
    var residue_levels: List[Int]
    var cell_ez_residue: Int  # delta = e_z members no lemma covers
    var signatures: Dict[String, Int]  # residue only, when asked for: "s dy | w1 w2 | signature"
    var shapes: Dict[String, Int]  # residue only: "s dy | run shape of w1 | of w2"

    def __init__(out self):
        self.non_crossing = 0
        self.by_lemma = 0
        self.lemma_failed = 0
        self.residue = Dict[String, Int]()
        self.residue_levels = List[Int](length=16, fill=0)
        self.cell_ez_residue = 0
        self.signatures = Dict[String, Int]()
        self.shapes = Dict[String, Int]()


def run_shape(w: List[Int]) -> String:
    """The letters of `w`'s maximal runs, in order: `zzyyz` has shape `zyz`."""
    var names = List[String](["o", "y", "z"])
    var out = String("")
    for k in range(len(w)):
        if k == 0 or w[k] != w[k - 1]:
            out += names[w[k]]
    return out if len(w) > 0 else String("ε")


def _word_name(w: List[Int]) -> String:
    var names = List[String](["o", "y", "z"])
    var out = String("")
    for k in range(len(w)):
        out += names[w[k]]
    return out if len(w) > 0 else String("ε")


def phi_census(max_len: Int, with_signatures: Bool = False) raises -> PhiCensus:
    """Every non-crossing PIP member with `|det M| = 2`, `|w_i| <= max_len`:
    a Lemma Φ6-Φ8 path that verifies and names a shared tile of the words, or
    a residual member decided exactly."""
    var out = PhiCensus()
    var screen = CubicScreen()
    var words = _words(max_len)
    for ia in range(len(words)):
        ref w1 = words[ia]
        if len(w1) == 0 or w1[0] != Z:
            continue
        for ib in range(len(words)):
            ref w2 = words[ib]
            var p1 = _walk(w1)
            var p2 = _walk(w2)
            var s = p1[len(w1)][1] - p2[len(w2)][1]
            if abs(s) != 1 or crossing(w1, w2)[0] >= 0:
                continue
            var sigma = member_sigma(w1, w2)
            var mat = Mat3(substitution_incidence(sigma))
            if not screen.is_pip(mat):
                continue
            out.non_crossing += 1
            var steps = phi_path(w1, w2)
            if len(steps) > 0:
                var fam = concrete_family(sigma)
                var ok = verify_witness(fam, O, Y, steps)
                if ok:
                    ok = shared_tile_between(sigma, O, Y, len(steps), witness_position(fam, O, Y, steps, List[Int]()))
                if ok:
                    out.by_lemma += 1
                else:
                    out.lemma_failed += 1
                continue
            var dy = p1[len(w1)][0] - p2[len(w2)][0]
            _bump(out.residue, String(s) + " " + String(dy))
            if s == 1 and dy == 0:
                out.cell_ez_residue += 1
            var lev = coincidence_level(sigma, O, Y)
            if lev < 0:
                raise Error("SC REFUTED in Theorem K's family: {o, y} is not eventually coincident")
            out.residue_levels[min(lev, 15)] += 1
            _bump(out.shapes, String(s) + " " + String(dy) + " | " + run_shape(w1) + " | " + run_shape(w2))
            if with_signatures:
                _bump(out.signatures, String(s) + " " + String(dy) + " | " + _signature(sigma) + " | " + _word_name(w1) + " " + _word_name(w2))
    return out^


# ---------------------------------------------------------------------------
# Run-shape cover (§3h): the delta split with run-length splits. A run shape
# fixes the letters of the maximal runs of w_1 and of w_2; each run has length
# 1 + (its cone form). The determinant constraint Z_1 - Z_2 = s, and when
# asked a fixed Delta = Y_1 - Y_2, are imposed by exact substitutions that
# partition the solutions; each region is then covered by a witness path, a
# Lemma Φ4 cut, relational splits n_i > n_j | n_i = n_j | n_i < n_j, or an
# exact decision once no variable is left. Open regions are reported.
# ---------------------------------------------------------------------------


def _substitute_ge(subst: List[List[Int]], p: Int, q: Int) -> List[List[Int]]:
    """`n_p <- n_q + n_p`: the region `n_p >= n_q`."""
    var out = List[List[Int]]()
    for k in range(len(subst)):
        var f = subst[k].copy()
        f[q + 1] += f[p + 1]
        out.append(f^)
    return out^


def _substitute_gt(subst: List[List[Int]], p: Int, q: Int) -> List[List[Int]]:
    """`n_q <- n_p + 1 + n_q`: the region `n_q > n_p`."""
    var out = List[List[Int]]()
    for k in range(len(subst)):
        var f = subst[k].copy()
        f[0] += f[q + 1]
        f[p + 1] += f[q + 1]
        out.append(f^)
    return out^


def _set_value(subst: List[List[Int]], p: Int, v: Int) -> List[List[Int]]:
    var out = List[List[Int]]()
    for k in range(len(subst)):
        var f = subst[k].copy()
        f[0] += v * f[p + 1]
        f[p + 1] = 0
        out.append(f^)
    return out^


def solve_constraint(subst: List[List[Int]], pos: List[Int], neg: List[Int], target: Int) -> List[List[List[Int]]]:
    """All regions of `sum_pos n - sum_neg n = target` over `n >= 0`, as
    substitutions; the regions partition the solutions. Each variable is
    assumed to occur in the constraint once (identity forms on these slots)."""
    var out = List[List[List[Int]]]()
    if len(pos) == 0 and len(neg) == 0:
        if target == 0:
            out.append(subst.copy())
        return out^
    if len(neg) == 0 or len(pos) == 0:
        var side = pos.copy() if len(neg) == 0 else neg.copy()
        var t = target if len(neg) == 0 else -target
        if t < 0:
            return out^
        var rest = List[Int]()
        for k in range(1, len(side)):
            rest.append(side[k])
        if len(rest) == 0:
            out.append(_set_value(subst, side[0], t))
            return out^
        for v in range(t + 1):
            var reduced = _set_value(subst, side[0], v)
            var sub = solve_constraint(reduced, rest, List[Int](), t - v) if len(neg) == 0 else solve_constraint(reduced, List[Int](), rest, v - t)
            for k in range(len(sub)):
                out.append(sub[k].copy())
        return out^
    var p = pos[0]
    var q = neg[0]
    var neg_rest = List[Int]()
    for k in range(1, len(neg)):
        neg_rest.append(neg[k])
    var pos_rest = List[Int]()
    for k in range(1, len(pos)):
        pos_rest.append(pos[k])
    # n_p >= n_q: n_p = n_q + r, r in slot p; the constraint loses n_q
    var a = solve_constraint(_substitute_ge(subst, p, q), pos, neg_rest, target)
    for k in range(len(a)):
        out.append(a[k].copy())
    # n_q > n_p: n_q = n_p + 1 + r, r in slot q; the constraint loses n_p
    var b = solve_constraint(_substitute_gt(subst, p, q), pos_rest, neg, target + 1)
    for k in range(len(b)):
        out.append(b[k].copy())
    return out^


struct ShapeRegion(Copyable, Movable):
    var subst: List[List[Int]]
    var compared: List[Int]
    var depth: Int

    def __init__(out self, var subst: List[List[Int]], var compared: List[Int], depth: Int):
        self.subst = subst^
        self.compared = compared^
        self.depth = depth


struct ShapeCover(Copyable, Movable):
    var regions: Int
    var certified: Int
    var line_certified: Int
    var crossing_certified: Int
    var poly_certified: Int  # line paths lifted over polynomials (psc.poly_line)
    var cut: Int
    var decided: Int
    var not_member: Int
    var open: Int
    var max_level: Int
    var budget_exhausted: Bool
    var open_forms: List[List[List[Int]]]

    def __init__(out self):
        self.budget_exhausted = False
        self.regions = 0
        self.certified = 0
        self.line_certified = 0
        self.crossing_certified = 0
        self.poly_certified = 0
        self.cut = 0
        self.decided = 0
        self.not_member = 0
        self.open = 0
        self.max_level = 0
        self.open_forms = List[List[List[Int]]]()


struct RunPattern(Copyable, Movable, Writable):
    """The runs of `w_1` and `w_2` (their letters, in order) and whether each
    word continues with an opaque tail standing for any further runs."""

    var l1: List[Int]
    var open1: Bool
    var l2: List[Int]
    var open2: Bool
    var suffix1: List[Int]  # letters closing w_1 (Lemma Phi5: y^Delta)
    var suffix2: List[Int]  # letters closing w_2 (Lemma Phi5': 2 - Delta letters)
    var tail_run1: Int  # > 0: w_1 closes with y^(tail_run1 + e), e the cell's tail variable
    var xblock: Bool  # w_2 = v x with x a second block (Lemma Phi5': the last 2 - Delta letters)
    var xl: List[Int]  # the runs of x, in reading order
    var xopen: Bool  # x has an opaque part
    var xend: Bool  # x is revealed from its end: its opaque part comes first

    def __init__(out self, var l1: List[Int], open1: Bool, var l2: List[Int], open2: Bool, var suffix1: List[Int] = List[Int](), var suffix2: List[Int] = List[Int]()):
        self.l1 = l1^
        self.open1 = open1
        self.l2 = l2^
        self.open2 = open2
        self.suffix1 = suffix1^
        self.suffix2 = suffix2^
        self.tail_run1 = 0
        self.xblock = False
        self.xl = List[Int]()
        self.xopen = False
        self.xend = False

    def runs(self) -> Int:
        return len(self.l1) + len(self.l2) + len(self.xl)

    def slots(self) -> Int:
        """Run slots of w_1, its tail's (y, z) slots, the same for w_2, then
        the same for the block x of w_2."""
        return self.runs() + (2 if self.open1 else 0) + (2 if self.open2 else 0) + (2 if self.xblock and self.xopen else 0)

    def write_to[W: Writer](self, mut w: W):
        var names = List[String](["o", "y", "z"])
        for wi in range(2):
            ref letters = self.l1 if wi == 0 else self.l2
            var opn = self.open1 if wi == 0 else self.open2
            if wi == 1:
                w.write(" | ")
            if len(letters) == 0 and not opn:
                w.write("ε")
            for k in range(len(letters)):
                w.write(names[letters[k]])
            if opn:
                w.write("*")
            if wi == 0 and self.tail_run1 > 0:
                w.write(" +y^(", self.tail_run1, "+e)")
            if wi == 1 and self.xblock:
                w.write(" +[")
                if self.xopen and self.xend:
                    w.write("*")
                for k in range(len(self.xl)):
                    w.write(names[self.xl[k]])
                if self.xopen and not self.xend:
                    w.write("*")
                w.write("]")
            ref suf = self.suffix1 if wi == 0 else self.suffix2
            if len(suf) > 0:
                w.write(" +")
                for k in range(len(suf)):
                    w.write(names[suf[k]])


def pattern_family(pat: RunPattern, subst: List[List[Int]]) raises -> ConeFamily:
    """`sigma(o) = y`, `sigma(y) = o w_1 o`, `sigma(z) = o w_2 o`: each run has
    length `1 + form`, each tail is an opaque word with Parikh `(0, ty, tz)`."""
    var m = len(subst[0]) - 1
    var images = List[List[Segment]]()
    var img_o = List[Segment]()
    img_o.append(letter_segment(m, Y))
    images.append(img_o^)
    var slot = 0
    for wi in range(2):
        ref letters = pat.l1 if wi == 0 else pat.l2
        var opn = pat.open1 if wi == 0 else pat.open2
        var img = List[Segment]()
        img.append(letter_segment(m, O))
        for k in range(len(letters)):
            var f = subst[slot].copy()
            f[0] += 1
            slot += 1
            img.append(run_of(letters[k], f^))
        if opn:
            var par = List[List[Int]]()
            par.append(aff_const(m, 0))
            par.append(subst[slot].copy())
            par.append(subst[slot + 1].copy())
            slot += 2
            img.append(opaque_segment(par^))
        if wi == 0 and pat.tail_run1 > 0:
            var f = subst[pat.slots()].copy()
            f[0] += pat.tail_run1
            img.append(run_of(Y, f^))
        if wi == 1 and pat.xblock:
            # slots: the runs of x, then its opaque part's (y, z); in the
            # image the opaque part comes last, or first when x is revealed
            # from its end
            var runs = List[Segment]()
            for k in range(len(pat.xl)):
                var f = subst[slot].copy()
                f[0] += 1
                slot += 1
                runs.append(run_of(pat.xl[k], f^))
            if pat.xopen:
                var par = List[List[Int]]()
                par.append(aff_const(m, 0))
                par.append(subst[slot].copy())
                par.append(subst[slot + 1].copy())
                slot += 2
                if pat.xend:
                    img.append(opaque_segment(par^))
                    for k in range(len(runs)):
                        img.append(runs[k].copy())
                else:
                    for k in range(len(runs)):
                        img.append(runs[k].copy())
                    img.append(opaque_segment(par^))
            else:
                for k in range(len(runs)):
                    img.append(runs[k].copy())
        ref suf = pat.suffix1 if wi == 0 else pat.suffix2
        for k in range(len(suf)):
            img.append(letter_segment(m, suf[k]))
        img.append(letter_segment(m, O))
        images.append(img^)
    return ConeFamily(m, images^)


def shape_family(l1: List[Int], l2: List[Int], subst: List[List[Int]]) raises -> ConeFamily:
    """A run shape with no tails; see `pattern_family`."""
    return pattern_family(RunPattern(l1.copy(), False, l2.copy(), False), subst)


def pattern_counts(pat: RunPattern, subst: List[List[Int]]) -> List[List[Int]]:
    """Affine forms of `Y_1, Z_1, Y_2, Z_2`."""
    var m = len(subst[0]) - 1
    var out = List[List[Int]]()
    for _ in range(4):
        out.append(aff_const(m, 0))
    var slot = 0
    for wi in range(2):
        ref letters = pat.l1 if wi == 0 else pat.l2
        var opn = pat.open1 if wi == 0 else pat.open2
        for k in range(len(letters)):
            var f = subst[slot].copy()
            f[0] += 1
            var idx = 2 * wi + (0 if letters[k] == Y else 1)
            out[idx] = aff_add(out[idx], f)
            slot += 1
        if opn:
            out[2 * wi] = aff_add(out[2 * wi], subst[slot])
            out[2 * wi + 1] = aff_add(out[2 * wi + 1], subst[slot + 1])
            slot += 2
    if pat.xblock:
        for k in range(len(pat.xl)):
            var f = subst[slot].copy()
            f[0] += 1
            var idx = 2 + (0 if pat.xl[k] == Y else 1)
            out[idx] = aff_add(out[idx], f)
            slot += 1
        if pat.xopen:
            out[2] = aff_add(out[2], subst[slot])
            out[3] = aff_add(out[3], subst[slot + 1])
    for wi in range(2):
        ref suf = pat.suffix1 if wi == 0 else pat.suffix2
        for k in range(len(suf)):
            out[2 * wi + (0 if suf[k] == Y else 1)][0] += 1
    if pat.tail_run1 > 0:
        var f = subst[pat.slots()].copy()
        f[0] += pat.tail_run1
        out[0] = aff_add(out[0], f)
    return out^


def _quadratic_nonneg(a: List[Int], b: List[Int], c: List[Int]) -> Bool:
    """Is `a * b + c` (affine forms over `n >= 0`) provably nonnegative: all
    coefficients of the expanded quadratic polynomial nonnegative?"""
    var m = len(a) - 1
    if a[0] * b[0] + c[0] < 0:
        return False
    for i in range(1, m + 1):
        if a[0] * b[i] + a[i] * b[0] + c[i] < 0:
            return False
        for j in range(i, m + 1):
            var q = a[i] * b[j] + (a[j] * b[i] if j != i else 0)
            if q < 0:
                return False
    return True


def _pisot_quadratic(counts: List[List[Int]], s: Int) -> List[List[Int]]:
    """Lemma P1's quadratic form of the family as `[a, b, c]`, `f = a b + c`:
    for s = +1, `Z_2 (Delta - 1) - 2 Y_2 - Delta - 3`; for s = -1,
    `Z_2 (|Delta| - 1) - 2 Y_1 - |Delta| + 3`. A PIP member has `f < 0`."""
    var dy = aff_sub(counts[0], counts[2])
    var ad = dy.copy() if s == 1 else aff_scale(dy, -1)
    var factor = ad.copy()
    factor[0] -= 1
    var rest = aff_scale(ad, -1)
    if s == 1:
        rest = aff_sub(rest, aff_scale(counts[2], 2))
        rest[0] -= 3
    else:
        rest = aff_sub(rest, aff_scale(counts[0], 2))
        rest[0] += 3
    var out = List[List[Int]]()
    out.append(counts[3].copy())
    out.append(factor^)
    out.append(rest^)
    return out^


def mccormick_forms(counts: List[List[Int]], s: Int, a0: Int, b0: Int) -> List[List[Int]]:
    """Lemma P1's `f = a b + c` at the corner `(a0, b0)`: the affine forms
    G_1 = a - a0, G_2 = b - b0, G_3 = a0 b + b0 a - a0 b0 + c, with
    f = G_3 + G_1 G_2 identically, so f >= 0 where all three are >= 0."""
    var q = _pisot_quadratic(counts, s)
    var g1 = q[0].copy()
    g1[0] -= a0
    var g2 = q[1].copy()
    g2[0] -= b0
    var g3 = aff_add(aff_add(aff_scale(q[1], a0), aff_scale(q[0], b0)), q[2])
    g3[0] -= a0 * b0
    var out = List[List[Int]]()
    out.append(g1^)
    out.append(g2^)
    out.append(g3^)
    return out^


def _orthant_floor(f: List[Int]) -> Int:
    """The least value of an affine form on the orthant, if it has no
    negative coefficient (its constant); else -2^40, meaning unbounded."""
    for k in range(1, len(f)):
        if f[k] < 0:
            return -(1 << 40)
    return f[0]


def pisot_carve_forms(counts: List[List[Int]], s: Int, ns: List[Int]) -> List[List[Int]]:
    """At a point `ns` where Lemma P1's quadratic form `f = a b + c` is >= 0
    (no PIP member there), the McCormick forms at a corner whose quadrant
    contains the point: `(2, b(p))` or `(a(p), b_lo)`, with `b_lo` the
    least value of `b` on the orthant; either way
    `G_3(p) = f(p) - (a(p) - a_0)(b(p) - b_0) = f(p)`. The corner taken
    leaves the shorter descent for later cuts: `b(p) - b_lo` steps in `b`,
    or `a(p) - 2` in `a`. Empty if f(ns) < 0."""
    var q = _pisot_quadratic(counts, s)
    var ap = aff_eval(q[0], ns)
    var bp = aff_eval(q[1], ns)
    if ap * bp + aff_eval(q[2], ns) < 0 or ap < 2:
        return List[List[Int]]()
    var b_lo = _orthant_floor(q[1])
    if b_lo > -(1 << 40) and ap - 2 < bp - b_lo:
        return mccormick_forms(counts, s, ap, b_lo)
    return mccormick_forms(counts, s, 2, bp)


def pisot_cut(counts: List[List[Int]], s: Int) -> Bool:
    """No PIP member in the region. Lemma Φ4: for s = +1 if `Y_2 - Y_1 - 1 >= 0`;
    for s = -1 if `Y_1 - Y_2 - 1 >= 0` or `1 - Z_2 >= 0`. Lemma P1 in the exact
    forms of §3h: for s = +1 if `Z_2 (Delta - 1) - 2 Y_2 - Delta - 3 >= 0`,
    for s = -1 if `Z_2 (|Delta| - 1) - 2 Y_1 - |Delta| + 3 >= 0`, with
    `Delta = Y_1 - Y_2`. Each condition is checked by coefficient signs."""
    var dy = aff_sub(counts[0], counts[2])
    if s == 1:
        var g = aff_scale(dy, -1)
        g[0] -= 1
        if aff_nonneg(g):
            return True
    else:
        var g = dy.copy()
        g[0] -= 1
        if aff_nonneg(g):
            return True
        var h = aff_scale(counts[3], -1)
        h[0] += 1
        if aff_nonneg(h):
            return True
    var q = _pisot_quadratic(counts, s)
    return _quadratic_nonneg(q[0], q[1], q[2])


def _pattern_starts(pat: RunPattern, s: Int, delta: Int, tail: Bool) raises -> List[List[List[Int]]]:
    """The regions of the pattern's variables solving `Z_1 - Z_2 = s` and
    `Y_1 - Y_2 = delta` (or the tail `|Delta| >= |delta|`), as substitutions."""
    var slots = pat.slots()
    var m = slots + (1 if tail else 0)
    var zpos = List[Int]()
    var zneg = List[Int]()
    var ypos = List[Int]()
    var yneg = List[Int]()
    var zconst = 0
    var yconst = 0
    var slot = 0
    for wi in range(2):
        ref letters = pat.l1 if wi == 0 else pat.l2
        var opn = pat.open1 if wi == 0 else pat.open2
        var sg = 1 if wi == 0 else -1
        for k in range(len(letters)):
            if letters[k] == Z:
                if wi == 0:
                    zpos.append(slot)
                else:
                    zneg.append(slot)
                zconst += sg
            else:
                if wi == 0:
                    ypos.append(slot)
                else:
                    yneg.append(slot)
                yconst += sg
            slot += 1
        if opn:
            if wi == 0:
                ypos.append(slot)
                zpos.append(slot + 1)
            else:
                yneg.append(slot)
                zneg.append(slot + 1)
            slot += 2
    if pat.xblock:
        for k in range(len(pat.xl)):
            if pat.xl[k] == Z:
                zneg.append(slot)
                zconst -= 1
            else:
                yneg.append(slot)
                yconst -= 1
            slot += 1
        if pat.xopen:
            yneg.append(slot)
            zneg.append(slot + 1)
            slot += 2
    for wi in range(2):
        ref suf = pat.suffix1 if wi == 0 else pat.suffix2
        for k in range(len(suf)):
            if suf[k] == Y:
                yconst += 1 if wi == 0 else -1
            else:
                zconst += 1 if wi == 0 else -1
    var starts = solve_constraint(identity_subst(m), zpos, zneg, s - zconst)
    if delta != NO_DELTA:
        if tail and pat.tail_run1 > 0:
            yconst += pat.tail_run1  # the run y^(D + e) carries Delta = D + e
        elif tail:
            if delta > 0 or (delta == 0 and s == 1):
                yneg.append(slots)  # Y_1 - Y_2 - e = delta
            else:
                ypos.append(slots)  # Y_1 - Y_2 + e = delta
        var both = List[List[List[Int]]]()
        for k in range(len(starts)):
            var more = solve_constraint(starts[k], ypos, yneg, delta - yconst)
            for j in range(len(more)):
                both.append(more[j].copy())
        starts = both^
    if pat.xblock:
        starts = _impose_x_block(pat, m, starts)
    return starts^


def _x_block_forms(pat: RunPattern, m: Int) -> List[List[Int]]:
    """Over the pattern's variables: `Z(x) - 2` and
    `E = Z(x) - 2 + Y_1 - Y(v)`, where `w_2 = v x`. Lemma Phi5' asks
    `Z(x) >= 2` and `|x| = 2 - Delta`, which is `E = 0`."""
    var zx = aff_const(m, -2)
    var e = aff_const(m, -2)
    var slot = 0
    for wi in range(2):
        ref letters = pat.l1 if wi == 0 else pat.l2
        var opn = pat.open1 if wi == 0 else pat.open2
        for k in range(len(letters)):
            if letters[k] == Y:
                # a run of length 1 + n_slot
                if wi == 0:
                    e[0] += 1
                    e[slot + 1] += 1
                else:
                    e[0] -= 1
                    e[slot + 1] -= 1
            slot += 1
        if opn:
            if wi == 0:
                e[slot + 1] += 1
            else:
                e[slot + 1] -= 1
            slot += 2
    for k in range(len(pat.xl)):
        if pat.xl[k] == Z:
            zx[0] += 1
            zx[slot + 1] += 1
            e[0] += 1
            e[slot + 1] += 1
        slot += 1
    if pat.xopen:
        zx[slot + 2] += 1
        e[slot + 2] += 1
    for k in range(len(pat.suffix1)):
        if pat.suffix1[k] == Y:
            e[0] += 1
    var out = List[List[Int]]()
    out.append(zx^)
    out.append(e^)
    return out^


def _compose(form: List[Int], subst: List[List[Int]]) -> List[Int]:
    """A form over the pattern's variables, rewritten over a region's."""
    var out = aff_const(len(subst[0]) - 1, form[0])
    for k in range(len(subst)):
        if form[k + 1] != 0:
            out = aff_add(out, aff_scale(subst[k], form[k + 1]))
    return out^


def _impose_x_block(pat: RunPattern, m: Int, starts: List[List[List[Int]]]) raises -> List[List[List[Int]]]:
    """Restrict regions to Lemma Phi5''s shape: Z(x) >= 2 and E = 0."""
    var forms = _x_block_forms(pat, m)
    var neg_e = aff_scale(forms[1], -1)
    var out = List[List[List[Int]]]()
    for r in range(len(starts)):
        var bag = starts[r].copy()
        var n = len(bag)
        bag.append(_compose(forms[0], starts[r]))
        bag.append(_compose(forms[1], starts[r]))
        bag.append(_compose(neg_e, starts[r]))
        var a = impose_nonneg(bag, n)
        for i in range(len(a)):
            var b = impose_equal(a[i], n + 1)
            for j in range(len(b)):
                out.append(_drop_tail(b[j], n))
    return out^


def cover_pattern(pat: RunPattern, s: Int, delta: Int, split_limit: Int, tail: Bool = False, peel_limit: Int = PEEL_LIMIT, region_budget: Int = REGION_BUDGET) raises -> ShapeCover:
    """Cover every member of the pattern with `Z_1 - Z_2 = s`, and with
    `Y_1 - Y_2 = delta` unless `delta` is `NO_DELTA` -- or, with `tail`, with
    `|Y_1 - Y_2| >= |delta|` on `delta`'s side, carried by one extra variable."""
    var out = ShapeCover()
    var screen = CubicScreen()
    var m = pat.slots() + (1 if tail else 0)
    var starts = _pattern_starts(pat, s, delta, tail)
    var stack = List[ShapeRegion]()
    for k in range(len(starts)):
        stack.append(ShapeRegion(starts[k].copy(), List[Int](), 0))
    while len(stack) > 0:
        var reg = stack.pop()
        out.regions += 1
        if out.regions > region_budget:
            # budget exhausted: everything still unexamined is reported open
            out.open += 1 + len(stack)
            out.budget_exhausted = True
            break
        if pisot_cut(pattern_counts(pat, reg.subst), s):
            out.cut += 1
            continue
        var fam = pattern_family(pat, reg.subst)
        var w = search_witness(fam, O, Y, OFFSET_BOUND, MAX_LEVEL, True)
        if w.found:
            if not verify_witness(fam, O, Y, w.steps):
                raise Error("a witness path the search found does not verify")
            out.certified += 1
            out.max_level = max(out.max_level, len(w.steps))
            continue
        var wl = search_witness_line(fam, O, Y, OFFSET_BOUND, MAX_LEVEL, Y, Z)
        if wl.found:
            if not verify_witness_line(fam, O, Y, wl.steps):
                raise Error("a line-mode witness path the search found does not verify")
            out.certified += 1
            out.line_certified += 1
            out.max_level = max(out.max_level, len(wl.steps))
            continue
        var wc = search_crossing(fam, O, Y, OFFSET_BOUND, MAX_LEVEL - 2, Y, Z, Y, Z)
        if wc.found:
            if not verify_crossing(fam, O, Y, wc.steps, wc.close[0], Y, Z):
                raise Error("a crossing closure the search found does not verify")
            out.certified += 1
            out.crossing_certified += 1
            out.max_level = max(out.max_level, len(wc.steps) + 2)
            continue
        var any_live = False
        for k in range(m):
            if _live(reg.subst, k):
                any_live = True
        if not any_live:
            var sigma = fam.instantiate(List[Int](length=m, fill=0))
            var mat = Mat3(substitution_incidence(sigma))
            if abs(mat.det()) != 2 or not screen.is_pip(mat):
                out.not_member += 1
                continue
            var lev = coincidence_level(sigma, O, Y)
            if lev < 0:
                raise Error("SC REFUTED in Theorem K's family: {o, y} is not eventually coincident")
            out.decided += 1
            out.max_level = max(out.max_level, lev)
            continue
        var node = Node(any_word(), any_word(), reg.subst.copy(), reg.compared.copy(), 0)
        var pair = _next_pair(node)
        if pair[0] < 0 or len(reg.compared) >= split_limit:
            # value split of the first live variable: n = 0 | n = 1 + n'
            var first = -1
            for k in range(m):
                if _live(reg.subst, k) and first < 0:
                    first = k
            if first < 0 or reg.depth >= split_limit + peel_limit:
                out.open += 1
                out.open_forms.append(reg.subst.copy())
                continue
            stack.append(ShapeRegion(_set_value(reg.subst, first, 0), reg.compared.copy(), reg.depth + 1))
            var shifted = List[List[Int]]()
            for k in range(len(reg.subst)):
                var f = reg.subst[k].copy()
                f[0] += f[first + 1]
                shifted.append(f^)
            stack.append(ShapeRegion(shifted^, reg.compared.copy(), reg.depth + 1))
            continue
        for which in range(3):
            var comp = reg.compared.copy()
            comp.append(pair[0] * 1000 + pair[1])
            stack.append(ShapeRegion(_split(reg.subst, pair[0], pair[1], which), comp^, reg.depth + 1))
    return out^


def cover_shape(l1: List[Int], l2: List[Int], s: Int, delta: Int, split_limit: Int, tail: Bool = False, peel_limit: Int = PEEL_LIMIT, region_budget: Int = REGION_BUDGET) raises -> ShapeCover:
    """A run shape with no tails; see `cover_pattern`."""
    return cover_pattern(RunPattern(l1.copy(), False, l2.copy(), False), s, delta, split_limit, tail, peel_limit, region_budget)


def _letters(shape: String) -> List[Int]:
    var out = List[Int]()
    var b = shape.as_bytes()
    for k in range(len(b)):
        if Int(b[k]) == ord("y"):
            out.append(Y)
        elif Int(b[k]) == ord("z"):
            out.append(Z)
    return out^


def delta_cell(dy: Int, s: Int, exact_cap: Int) -> List[Int]:
    """The cover cell of `Delta`: `[delta, tail]`, exact for `|Delta| <=
    exact_cap`, else the tail `|Delta| >= exact_cap + 1` on its side."""
    if abs(dy) <= exact_cap:
        return List[Int]([dy, 0])
    return List[Int]([(exact_cap + 1) if dy > 0 else -(exact_cap + 1), 1])


struct CatalogEntry(Copyable, Movable):
    var key: String
    var open: Int
    var certified: Int
    var cut: Int

    def __init__(out self, key: String, open: Int, certified: Int, cut: Int):
        self.key = key
        self.open = open
        self.certified = certified
        self.cut = cut


def shape_catalog(max_len: Int, exact_cap: Int, split_limit: Int, verbose: Bool = False) raises -> List[CatalogEntry]:
    """Cover every (run shape, s, Delta cell) that a residual member of
    `phi_census(max_len)` falls in; one entry per cell, with its open count."""
    var pc = phi_census(max_len)
    var done = Dict[String, Int]()
    var out = List[CatalogEntry]()
    for e in pc.shapes.items():
        var parts = e.key.split(" | ")
        var head = parts[0].split(" ")
        var s = Int(String(head[0]))
        var dy = Int(String(head[1]))
        var cell = delta_cell(dy, s, exact_cap)
        var key = String(s) + " " + String(cell[0]) + ("+" if cell[1] == 1 else "") + " | " + String(parts[1]) + " | " + String(parts[2])
        if key in done:
            continue
        var l2 = _letters(String(parts[2])) if String(parts[2]) != "ε" else List[Int]()
        var c = cover_shape(_letters(String(parts[1])), l2, s, cell[0], split_limit, cell[1] == 1, split_limit)
        done[key] = len(out)
        out.append(CatalogEntry(key, c.open, c.certified, c.cut))
        if verbose:
            print("   ", "closed" if c.open == 0 else ("BUDGET" if c.budget_exhausted else "OPEN  "), key, "  regions", c.regions, " certified", c.certified, " (line", c.line_certified, ") cut", c.cut, " decided", c.decided, " open", c.open, flush=True)
    return out^


# ---------------------------------------------------------------------------
# Run tree (§3i): induction on the number of runs. A pattern's tail stands for
# any further runs; runs alternate, so a tail is either empty or one more run
# of the other letter followed by a new tail -- a partition. Each pattern is
# covered by `cover_pattern` in the given delta cell; an uncovered pattern is
# refined by one run, up to `max_runs`. If every branch closes, the cell is
# proved for words with any number of runs.
# ---------------------------------------------------------------------------


struct RunTreeLeaf(Copyable, Movable):
    var pattern: RunPattern
    var closed: Bool
    var open_regions: Int
    var certified: Int
    var cut: Int

    def __init__(out self, var pattern: RunPattern, closed: Bool, open_regions: Int, certified: Int, cut: Int):
        self.pattern = pattern^
        self.closed = closed
        self.open_regions = open_regions
        self.certified = certified
        self.cut = cut


def refine_pattern(pat: RunPattern) -> List[RunPattern]:
    """Partition an open pattern by one run of its open block with fewest
    revealed runs (w_1, then w_2, then the block x of w_2 on ties): its tail
    ends, or continues with a run of the letter other than its last run's
    (either letter if it has no run yet). Every other field is inherited."""
    var out = List[RunPattern]()
    var pick = -1
    var fewest = 1 << 30
    if pat.open1 and len(pat.l1) < fewest:
        pick = 0
        fewest = len(pat.l1)
    if pat.open2 and len(pat.l2) < fewest:
        pick = 1
        fewest = len(pat.l2)
    if pat.xblock and pat.xopen and len(pat.xl) < fewest:
        pick = 2
    if pick < 0:
        return out^
    var last = -1
    if pick == 0 and len(pat.l1) > 0:
        last = pat.l1[len(pat.l1) - 1]
    elif pick == 1 and len(pat.l2) > 0:
        last = pat.l2[len(pat.l2) - 1]
    elif pick == 2 and len(pat.xl) > 0:
        # the run next to x's opaque part
        last = pat.xl[0] if pat.xend else pat.xl[len(pat.xl) - 1]
    var nexts = List[Int]()
    if last < 0:
        nexts.append(Y)
        nexts.append(Z)
    else:
        nexts.append(Z if last == Y else Y)
    var closed = pat.copy()
    if pick == 0:
        closed.open1 = False
    elif pick == 1:
        closed.open2 = False
    else:
        closed.xopen = False
    out.append(closed^)
    for k in range(len(nexts)):
        var kid = pat.copy()
        if pick == 0:
            kid.l1.append(nexts[k])
        elif pick == 1:
            kid.l2.append(nexts[k])
        elif pat.xend:
            kid.xl.insert(0, nexts[k])
        else:
            kid.xl.append(nexts[k])
        out.append(kid^)
    return out^


def run_tree(s: Int, delta: Int, tail: Bool, max_runs: Int, split_limit: Int, peel_limit: Int, budget: Int, verbose: Bool = False) raises -> List[RunTreeLeaf]:
    """The run tree of one delta cell, from the root `w_1 = z^+ *`, `w_2 = *`
    (`w_1` beginning with `y` is Lemma Φ1; `w_1` without `z` is not
    primitive)."""
    var out = List[RunTreeLeaf]()
    var stack = List[RunPattern]()
    stack.append(RunPattern(List[Int]([Z]), True, List[Int](), True))
    while len(stack) > 0:
        var pat = stack.pop()
        var c = cover_pattern(pat, s, delta, split_limit, tail, peel_limit, budget)
        if c.open == 0:
            if verbose:
                print("    closed ", pat, "  regions", c.regions, " certified", c.certified, " (line", c.line_certified, ") cut", c.cut, " decided", c.decided, flush=True)
            out.append(RunTreeLeaf(pat.copy(), True, 0, c.certified, c.cut))
            continue
        var kids = refine_pattern(pat)
        if pat.runs() >= max_runs or len(kids) == 0:
            if verbose:
                print("    OPEN   ", pat, "  regions", c.regions, " open", c.open, " budget" if c.budget_exhausted else "", flush=True)
            out.append(RunTreeLeaf(pat.copy(), False, c.open, c.certified, c.cut))
            continue
        if verbose:
            print("    refine ", pat, "  (open", c.open, ")", flush=True)
        for k in range(len(kids)):
            stack.append(kids[k].copy())
    return out^


def _run_letters(w: List[Int]) -> List[Int]:
    var out = List[Int]()
    for k in range(len(w)):
        if k == 0 or w[k] != w[k - 1]:
            out.append(w[k])
    return out^


def pattern_matches(pat: RunPattern, w1: List[Int], w2: List[Int]) -> Bool:
    """Does the word pair lie in the pattern: each word's run letters equal the
    revealed ones, or begin with them when the word has a tail; with a
    suffix, a word ends in its suffix and the runs are those of the rest."""
    var cores = List[List[Int]]()
    for wi in range(2):
        ref w = w1 if wi == 0 else w2
        ref suf = pat.suffix1 if wi == 0 else pat.suffix2
        var n = len(w) - len(suf)
        if n < 0:
            return False
        for k in range(len(suf)):
            if w[n + k] != suf[k]:
                return False
        var core = List[Int]()
        for k in range(n):
            core.append(w[k])
        cores.append(core^)
    for wi in range(2):
        var runs = _run_letters(cores[wi])
        ref letters = pat.l1 if wi == 0 else pat.l2
        var opn = pat.open1 if wi == 0 else pat.open2
        if len(runs) < len(letters) or (not opn and len(runs) != len(letters)):
            return False
        for k in range(len(letters)):
            if runs[k] != letters[k]:
                return False
    return True


struct ResidueMember(Copyable, Movable):
    var w1: List[Int]
    var w2: List[Int]
    var s: Int
    var dy: Int

    def __init__(out self, var w1: List[Int], var w2: List[Int], s: Int, dy: Int):
        self.w1 = w1^
        self.w2 = w2^
        self.s = s
        self.dy = dy


def residue_members(max_len: Int) raises -> List[ResidueMember]:
    """The members `phi_census` leaves: non-crossing, `w_1` beginning with `z`,
    no Lemma Φ6-Φ8 path."""
    var out = List[ResidueMember]()
    var screen = CubicScreen()
    var words = _words(max_len)
    for ia in range(len(words)):
        ref w1 = words[ia]
        if len(w1) == 0 or w1[0] != Z:
            continue
        for ib in range(len(words)):
            ref w2 = words[ib]
            var p1 = _walk(w1)
            var p2 = _walk(w2)
            var s = p1[len(w1)][1] - p2[len(w2)][1]
            if abs(s) != 1 or crossing(w1, w2)[0] >= 0:
                continue
            var mat = Mat3(substitution_incidence(member_sigma(w1, w2)))
            if not screen.is_pip(mat):
                continue
            if len(phi_path(w1, w2)) > 0:
                continue
            out.append(ResidueMember(w1.copy(), w2.copy(), s, p1[len(w1)][0] - p2[len(w2)][0]))
    return out^


def run_leaf_index(leaves: List[RunTreeLeaf], w1: List[Int], w2: List[Int]) raises -> Int:
    """The run-tree leaf holding a word pair. The leaves partition the pairs
    whose `w_1` begins with `z`, so anything but exactly one match raises."""
    var hit = -1
    for k in range(len(leaves)):
        if pattern_matches(leaves[k].pattern, w1, w2):
            if hit >= 0:
                raise Error("run-tree leaves overlap")
            hit = k
    if hit < 0:
        raise Error("run-tree leaves miss a word pair")
    return hit


struct RunTreeTally(Copyable, Movable):
    var leaves: Int
    var closed_leaves: Int
    var members: Int
    var in_closed: Int

    def __init__(out self):
        self.leaves = 0
        self.closed_leaves = 0
        self.members = 0
        self.in_closed = 0


def run_tree_tally(leaves: List[RunTreeLeaf], residue: List[ResidueMember], s: Int, delta: Int) raises -> RunTreeTally:
    """How many residue members of the cell `(s, Delta)` lie in closed leaves."""
    var t = RunTreeTally()
    t.leaves = len(leaves)
    for k in range(len(leaves)):
        if leaves[k].closed:
            t.closed_leaves += 1
    for k in range(len(residue)):
        if residue[k].s != s or residue[k].dy != delta:
            continue
        t.members += 1
        if leaves[run_leaf_index(leaves, residue[k].w1, residue[k].w2)].closed:
            t.in_closed += 1
    return t^


def common_points(w1: List[Int], w2: List[Int]) -> Int:
    """The number of common points (§3g): `t >= 1` with `w_1[t]`, `w_2[t - 1]`
    defined and `pi(w_1[:t]) = pi(w_2[:t - 1]) + e_z`. The prefix lengths
    differ by one, so equal `y`-counts suffice."""
    var n = 0
    var y1 = 0
    var y2 = 0
    for t in range(1, len(w1)):
        if w1[t - 1] == Y:
            y1 += 1
        if t - 1 > len(w2) - 1:
            break
        if t >= 2 and w2[t - 2] == Y:
            y2 += 1
        if y1 == y2:
            n += 1
    return n



# ---------------------------------------------------------------------------
# How much a Lemma X certificate must reveal (§3j). A member's words are read
# only at *revealed* points: positions inside the first r runs of each word,
# the suffix that Lemma Phi5 (s = +1: w_1 = u y^Delta) or Lemma Phi5' (s = -1:
# the last 2 - Delta letters of w_2) makes explicit, the synchronized cuts
# (w_1 near |w_2| + 1, w_2 near |w_1|), and, for a closure step, the lagged
# images of the other word's revealed points. A certificate is an exact path
# through revealed positions to a state that Lemma X closes on revealed
# endpoints: it would close every member that agrees on those points.
# ---------------------------------------------------------------------------


def _run_starts(w: List[Int], r: Int) -> Int:
    """Length of the first `r` runs of `w`."""
    var runs = 0
    for k in range(1, len(w)):
        if w[k] != w[k - 1]:
            runs += 1
            if runs == r:
                return k
    return len(w)


def _sorted_unique(var xs: List[Int]) -> List[Int]:
    sort(xs)
    var out = List[Int]()
    for k in range(len(xs)):
        if k == 0 or xs[k] != xs[k - 1]:
            out.append(xs[k])
    return out^


struct Revealed(Copyable, Movable):
    """Revealed positions (letters readable) and points (walk values readable)
    of both words, for one member and one `r`."""

    var words: List[List[Int]]
    var walks: List[List[List[Int]]]
    var known: List[List[Bool]]  # known[i][p]: letter p of word i is revealed
    var points: List[List[Int]]  # revealed prefix lengths of word i
    var sigma: List[List[Int]]
    var mat: List[List[Int]]

    def __init__(out self, w1: List[Int], w2: List[Int], r: Int):
        self.words = List[List[Int]]()
        self.words.append(w1.copy())
        self.words.append(w2.copy())
        self.walks = List[List[List[Int]]]()
        self.walks.append(_walk(w1))
        self.walks.append(_walk(w2))
        var s = self.walks[0][len(w1)][1] - self.walks[1][len(w2)][1]
        self.known = List[List[Bool]]()
        self.points = List[List[Int]]()
        for i in range(2):
            ref w = self.words[i]
            var lim = _run_starts(w, r)
            var kn = List[Bool]()
            for p in range(len(w)):
                kn.append(p < lim)
            var pts = List[Int]([0, len(w)])
            var runs = 0
            for k in range(1, len(w)):
                if w[k] != w[k - 1]:
                    runs += 1
                    if runs <= r:
                        pts.append(k)
            self.known.append(kn^)
            self.points.append(pts^)
        var l1 = len(w1)
        var l2 = len(w2)
        if s == 1:
            # Lemma Phi5: w_1 = u y^Delta with |u| = |w_2| + 1.
            for p in range(min(l2 + 1, l1), l1):
                self.known[0][p] = True
            for p in range(l2, min(l2 + 3, l1)):
                self.points[0].append(p)
        elif s == -1:
            # Lemma Phi5': the last 2 - Delta letters of w_2 start at |w_1| - 1.
            for p in range(max(l1 - 1, 0), l2):
                self.known[1][p] = True
                self.points[1].append(p)
            for p in range(max(l1 - 1, 0), min(l1 + 2, l2)):
                self.points[1].append(p)
        for i in range(2):
            self.points[i] = _sorted_unique(self.points[i].copy())
        self.sigma = member_sigma(w1, w2)
        self.mat = List[List[Int]]()
        for i in range(3):
            var row = List[Int]()
            for j in range(3):
                var n = 0
                for k in range(len(self.sigma[j])):
                    n += 1 if self.sigma[j][k] == i else 0
                row.append(n)
            self.mat.append(row^)

    def m_times(self, g: List[Int]) -> List[Int]:
        var out = List[Int](length=3, fill=0)
        for i in range(3):
            for j in range(3):
                out[i] += self.mat[i][j] * g[j]
        return out^

    def positions(self, a: Int) -> List[Int]:
        """Revealed positions of `sigma(a)`: its ends and revealed letters."""
        var out = List[Int]()
        var n = len(self.sigma[a])
        if a == O:
            out.append(0)
            return out^
        ref kn = self.known[0 if a == Y else 1]
        for p in range(n):
            if p == 0 or p == n - 1 or kn[p - 1]:
                out.append(p)
        return out^


def _lemma_x_closes(rv: Revealed, a: Int, b: Int, mg: List[Int]) -> Bool:
    """Lemma X from the state with letters `a, b` in {y, z} and `M gamma = mg`
    (o-part 0): `W_a` meets `W_b - mg` between revealed points."""
    var wa = 0 if a == Y else 1
    var wb = 0 if b == Y else 1
    ref pa = rv.walks[wa]
    ref pb = rv.walks[wb]
    var la = len(rv.words[wa])
    var lb = len(rv.words[wb])
    var lag = -mg[1] - mg[2]
    var ia = rv.points[wa].copy()
    var kb = rv.points[wb].copy()
    for k in range(len(rv.points[wb])):
        var i = rv.points[wb][k] + lag
        if i >= 0 and i <= la:
            ia.append(i)
    for i in range(len(rv.points[wa])):
        var k = rv.points[wa][i] - lag
        if k >= 0 and k <= lb:
            kb.append(k)
    var pts_a = _sorted_unique(ia^)
    var pts_b = _sorted_unique(kb^)
    for i0 in range(len(pts_a)):
        for i1 in range(i0 + 1, len(pts_a)):
            for k0 in range(len(pts_b)):
                for k1 in range(k0 + 1, len(pts_b)):
                    var q0 = List[Int]([pb[pts_b[k0]][0] - mg[1], pb[pts_b[k0]][1] - mg[2]])
                    var q1 = List[Int]([pb[pts_b[k1]][0] - mg[1], pb[pts_b[k1]][1] - mg[2]])
                    if monotone_paths_meet(pa[pts_a[i0]], pa[pts_a[i1]], q0, q1, pts_a[i1] < la and pts_b[k1] < lb):
                        return True
    return False


def reveal_certificate(w1: List[Int], w2: List[Int], r: Int, max_level: Int) raises -> Int:
    """The level of the first certificate that reads only revealed data (an
    exact shared tile, or Lemma X plus its two levels), or -1."""
    var rv = Revealed(w1, w2, r)
    var seen = Dict[String, Int]()
    var fa = List[Int]([O])
    var fb = List[Int]([Y])
    var fg = List[List[Int]]()
    fg.append(List[Int]([0, 0, 0]))
    var bound = len(w1) + len(w2) + 4
    for level in range(1, max_level + 1):
        var na = List[Int]()
        var nb = List[Int]()
        var ng = List[List[Int]]()
        for f in range(len(fa)):
            var a = fa[f]
            var b = fb[f]
            var mg = rv.m_times(fg[f])
            var pa = rv.positions(a)
            var pb = rv.positions(b)
            for x in range(len(pa)):
                for y in range(len(pb)):
                    var g2 = mg.copy()
                    for k in range(pa[x]):
                        g2[rv.sigma[a][k]] += 1
                    for k in range(pb[y]):
                        g2[rv.sigma[b][k]] -= 1
                    var a2 = rv.sigma[a][pa[x]]
                    var b2 = rv.sigma[b][pb[y]]
                    if g2[0] == 0 and g2[1] == 0 and g2[2] == 0:
                        if a2 == b2:
                            return level
                        if a2 != O and b2 != O:
                            return level + 1
                    if abs(g2[0]) > bound or abs(g2[1]) > bound or abs(g2[2]) > bound:
                        continue
                    var key = String(a2) + String(b2) + " " + String(g2[0]) + " " + String(g2[1]) + " " + String(g2[2])
                    if key in seen:
                        continue
                    seen[key] = 1
                    if a2 != O and b2 != O:
                        var m2 = rv.m_times(g2)
                        if m2[0] == 0 and _lemma_x_closes(rv, a2, b2, m2):
                            return level + 2
                    na.append(a2)
                    nb.append(b2)
                    ng.append(g2^)
        fa = na^
        fb = nb^
        fg = ng^
    return -1


def least_reveal(w1: List[Int], w2: List[Int], max_level: Int, cap: Int) raises -> Int:
    """Least `r <= cap` with a revealed certificate, or -1 (capped)."""
    for r in range(1, cap + 1):
        if reveal_certificate(w1, w2, r, max_level) >= 0:
            return r
    return -1


def _noncrossing_member(mut screen: CubicScreen, w1: List[Int], w2: List[Int]) raises -> Bool:
    var p1 = _walk(w1)
    var p2 = _walk(w2)
    if abs(p1[len(w1)][1] - p2[len(w2)][1]) != 1 or crossing(w1, w2)[0] >= 0:
        return False
    return screen.is_pip(Mat3(substitution_incidence(member_sigma(w1, w2))))


def reveal_census(length: Int, max_level: Int, cap: Int) raises -> List[Int]:
    """Histogram of `least_reveal` (index 0: capped) over the non-crossing PIP
    members with `w_1` beginning with `z` and longer word of exactly `length`."""
    var hist = List[Int](length=cap + 1, fill=0)
    var screen = CubicScreen()
    var words = _words(length)
    for ia in range(len(words)):
        ref w1 = words[ia]
        if len(w1) == 0 or w1[0] != Z:
            continue
        for ib in range(len(words)):
            ref w2 = words[ib]
            if max(len(w1), len(w2)) != length or not _noncrossing_member(screen, w1, w2):
                continue
            var r = least_reveal(w1, w2, max_level, cap)
            hist[max(r, 0)] += 1
    return hist^


def reveal_sample(seed: Int, lo: Int, hi: Int, want: Int, budget: Int, max_level: Int, cap: Int) raises -> List[Int]:
    """The same histogram over a seeded sample: lengths uniform in
    `[lo, hi]`, letters fair; draws stop at `budget`. Entry `cap + 1` holds
    the members sampled, so a short count shows an exhausted budget."""
    var hist = List[Int](length=cap + 2, fill=0)
    var rng = SplitMix64(seed)
    var screen = CubicScreen()
    var draws = 0
    while hist[cap + 1] < want and draws < budget:
        draws += 1
        var l1 = rng.between(lo, hi)
        var l2 = rng.between(lo, hi)
        var w1 = List[Int]([Z])
        for _ in range(l1 - 1):
            w1.append(Y if rng.below(2) == 0 else Z)
        var w2 = List[Int]()
        for _ in range(l2):
            w2.append(Y if rng.below(2) == 0 else Z)
        if not _noncrossing_member(screen, w1, w2):
            continue
        hist[cap + 1] += 1
        hist[max(least_reveal(w1, w2, max_level, cap), 0)] += 1
    return hist^



# ---------------------------------------------------------------------------
# Certificate-guided partition (§3k). A region is the image of an orthant
# under an affine substitution of the cone variables. `impose_nonneg` splits a
# region into finitely many regions that exactly cover the points where an
# affine form F is nonnegative, for any integer coefficients, and on each of
# them F is nonnegative coefficientwise -- so the ordinary verifiers accept it.
# For a variable n_p with coefficient a > 0 write F = a n_p - R. Either
# R <= 0, and F >= 0 holds throughout; or R >= 1, and then n_p >= ceil(R / a):
# split the other variables by their residues mod a until R / a is affine,
# and substitute n_p <- ceil(R / a) + n_p. Both cases recurse on R, which
# omits n_p, so the recursion ends. With no positive coefficient the
# variables of F are bounded and are enumerated.
# ---------------------------------------------------------------------------


def _subst_var(forms: List[List[Int]], p: Int, repl: List[Int]) -> List[List[Int]]:
    """Every form with the variable `n_p` replaced by the affine form `repl`
    (which may itself contain `n_p`)."""
    var out = List[List[Int]]()
    for k in range(len(forms)):
        var g = forms[k].copy()
        var c = g[p + 1]
        g[p + 1] = 0
        if c != 0:
            for j in range(len(g)):
                g[j] += c * repl[j]
        out.append(g^)
    return out^


def _drop_tail(forms: List[List[Int]], keep: Int) -> List[List[Int]]:
    var out = List[List[Int]]()
    for k in range(keep):
        out.append(forms[k].copy())
    return out^


def _residues(forms: List[List[Int]], idx: Int, a: Int, p: Int) -> List[List[List[Int]]]:
    """Split every variable other than `n_p` whose coefficient in `forms[idx]`
    is not divisible by `a` as `n_k <- a n_k + rho`, rho in [0, a)."""
    var out = List[List[List[Int]]]()
    out.append(forms.copy())
    var m = len(forms[0]) - 1
    for k in range(m):
        if k == p:
            continue
        var next = List[List[List[Int]]]()
        for r in range(len(out)):
            var c = out[r][idx][k + 1]
            if c % a == 0:
                next.append(out[r].copy())
                continue
            for rho in range(a):
                var repl = aff_const(m, rho)
                repl[k + 1] = a
                next.append(_subst_var(out[r], k, repl))
        out = next^
    return out^


comptime IMPOSE_MAX_MODULUS = 3  # impose_nonneg: residue splits beyond this modulus are refused
comptime IMPOSE_MAX_VALUES = 64  # impose_nonneg: bounded variables enumerated beyond this are refused


def impose_nonneg(forms: List[List[Int]], idx: Int) raises -> List[List[List[Int]]]:
    """Regions partitioning the points of `forms` (a region with constraint
    forms appended) where `forms[idx] >= 0`; on each, that form is
    nonnegative coefficientwise."""
    var out = List[List[List[Int]]]()
    ref F = forms[idx]
    var m = len(F) - 1
    if aff_nonneg(F):
        out.append(forms.copy())
        return out^
    var p = -1
    for k in range(m):
        if F[k + 1] > 0 and (p < 0 or F[k + 1] < F[p + 1]):
            p = k
    if p < 0:
        if F[0] < 0:
            return out^
        var k = -1
        for j in range(m):
            if F[j + 1] < 0 and k < 0:
                k = j
        if F[0] // (-F[k + 1]) + 1 > IMPOSE_MAX_VALUES:
            raise Error("impose_nonneg: refused (too many values)")
        for v in range(F[0] // (-F[k + 1]) + 1):
            var sub = impose_nonneg(_subst_var(forms, k, aff_const(m, v)), idx)
            for r in range(len(sub)):
                out.append(sub[r].copy())
        return out^
    var a = F[p + 1]
    if a > IMPOSE_MAX_MODULUS:
        raise Error("impose_nonneg: refused (modulus)")
    var R = aff_scale(F, -1)
    R[p + 1] = 0  # F = a n_p - R
    var n = len(forms)
    # R <= 0: F >= 0 throughout
    var with_a = forms.copy()
    with_a.append(aff_scale(R, -1))
    var regs_a = impose_nonneg(with_a, n)
    for r in range(len(regs_a)):
        out.append(_drop_tail(regs_a[r], n))
    # R >= 1: n_p >= ceil(R / a)
    var with_b = forms.copy()
    with_b.append(aff_sub(R, aff_const(m, 1)))
    with_b.append(R.copy())
    var regs_b = impose_nonneg(with_b, n)
    for r in range(len(regs_b)):
        var pieces = _residues(regs_b[r], n + 1, a, p)
        for q in range(len(pieces)):
            ref rc = pieces[q][n + 1]
            var repl = aff_const(m, 0)
            for k in range(1, m + 1):
                repl[k] = rc[k] // a
            repl[0] = -((-rc[0]) // a)  # ceil(rc0 / a)
            repl[p + 1] = 1
            var done = _subst_var(pieces[q], p, repl)
            if not aff_nonneg(done[idx]):
                raise Error("impose_nonneg: the imposed form is not coefficientwise nonnegative")
            out.append(_drop_tail(done, n))
    return out^


def impose_equal(forms: List[List[Int]], idx: Int) raises -> List[List[List[Int]]]:
    """Regions partitioning the points of `forms` where `forms[idx] = 0`. With a
    variable of coefficient +-1, `E = +-(n_p - R)` and the set is `R >= 0` with
    `n_p <- R` (one imposition, `n_p` then dead); otherwise `E >= 0` and
    `-E >= 0`."""
    ref E = forms[idx]
    var m = len(E) - 1
    var p = -1
    for k in range(m):
        if (E[k + 1] == 1 or E[k + 1] == -1) and p < 0:
            p = k
    var out = List[List[List[Int]]]()
    if p < 0:
        var n = len(forms)
        var with_neg = forms.copy()
        with_neg.append(aff_scale(E, -1))
        var a = impose_nonneg(with_neg, idx)
        for i in range(len(a)):
            var b = impose_nonneg(a[i], n)
            for j in range(len(b)):
                out.append(_drop_tail(b[j], n))
        return out^
    # n_p = R with R = -(E - c n_p) / c, c = +-1
    var c = E[p + 1]
    var R = aff_scale(E, -c)
    R[p + 1] = 0
    var n = len(forms)
    var bag = forms.copy()
    bag.append(R.copy())
    var regs = impose_nonneg(bag, n)
    for r in range(len(regs)):
        ref rc = regs[r][n]
        var done = _subst_var(regs[r], p, rc)
        out.append(_drop_tail(done, n))
    return out^


struct Carved(Copyable, Movable):
    var ok: Bool
    var inside: List[List[List[Int]]]
    var outside: List[List[List[Int]]]

    def __init__(out self):
        self.ok = True
        self.inside = List[List[List[Int]]]()
        self.outside = List[List[List[Int]]]()


def try_carve(forms: List[List[Int]], first: Int, count: Int, keep: Int) raises -> Carved:
    """`carve`, or a result with `ok` false when `impose_nonneg` refuses a
    split as too fragmenting (the caller then does something else)."""
    try:
        return carve(forms, first, count, keep)
    except e:
        if "refused" in String(e):
            var out = Carved()
            out.ok = False
            return out^
        raise e^


def carve(forms: List[List[Int]], first: Int, count: Int, keep: Int) raises -> Carved:
    """Partition by the forms `first .. first + count - 1`: the regions where
    all are nonnegative (with every form kept), and the rest, region `j`
    being where the first `j` hold and form `j` is negative (slots only)."""
    var out = Carved()
    out.inside.append(forms.copy())
    for j in range(count):
        var idx = first + j
        var next = List[List[List[Int]]]()
        for r in range(len(out.inside)):
            ref f = out.inside[r]
            var neg = f.copy()
            var g = aff_scale(f[idx], -1)
            g[0] -= 1
            neg.append(g^)
            var outs = impose_nonneg(neg, len(neg) - 1)
            for q in range(len(outs)):
                out.outside.append(_drop_tail(outs[q], keep))
            var ins = impose_nonneg(f, idx)
            for q in range(len(ins)):
                next.append(ins[q].copy())
        out.inside = next^
    return out^


def point_subst(forms: List[List[Int]], ns: List[Int]) -> List[List[Int]]:
    """The slot values of a region at the point `ns`, as forms without variables."""
    var out = List[List[Int]]()
    for k in range(len(forms)):
        out.append(aff_const(0, aff_eval(forms[k], ns)))
    return out^


def _member_at(pat: RunPattern, subst: List[List[Int]], ns: List[Int], mut screen: CubicScreen) raises -> Bool:
    var sigma = pattern_family(pat, point_subst(subst, ns)).instantiate(List[Int]())
    var mat = Mat3(substitution_incidence(sigma))
    return abs(mat.det()) == 2 and screen.is_pip(mat)


def _base_point(pat: RunPattern, subst: List[List[Int]], mut screen: CubicScreen) raises -> List[Int]:
    """A member point of the region, generic first: distinct primes, so that
    no small linear relation among the variables holds by accident; then
    every variable 2, 1 or 3, the origin and the unit points; empty if none
    is a member. A generic point keeps the certificate from exploiting a
    boundary value or a coincidence, so the carved region is a full cone and
    not a slice."""
    var m = len(subst[0]) - 1
    var tries = List[List[Int]]()
    # small points first: a member with short runs keeps its certificate's
    # offsets within the search's bound, and the linear lift asks identities
    # of the whole region, so accidental relations at the point do no harm
    for variant in range(4):
        var small = List[Int]()
        for k in range(m):
            if variant == 0:
                small.append(1 + k % 3)
            elif variant == 1:
                small.append(1 + (2 * k + 1) % 3)
            elif variant == 2:
                small.append(2 + k % 2)
            else:
                small.append(1)
        tries.append(small^)
    var srng = SplitMix64(BASE_POINT_SEED + 1)
    for _ in range(SMALL_POINT_DRAWS):
        var ns = List[Int]()
        for _ in range(m):
            ns.append(srng.between(0, 4))
        tries.append(ns^)
    var primes = List[Int]([2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53])
    for variant in range(6):
        var generic = List[Int]()
        for k in range(m):
            if variant == 0:
                generic.append(primes[k % len(primes)])
            elif variant == 1:
                generic.append(primes[(m - 1 - k) % len(primes)])
            elif variant == 2:
                generic.append(2 + (3 * k) % 7)
            elif variant == 3:
                generic.append(1 + (5 * k + 2) % 9)
            elif variant == 4:
                generic.append(primes[(2 * k + 1) % len(primes)] % 13 + 1)
            else:
                generic.append(1 + (7 * k + 3) % 11)
        tries.append(generic^)
    for g in [2, 1, 3]:
        tries.append(List[Int](length=m, fill=g))
    tries.append(List[Int](length=m, fill=0))
    for k in range(m):
        var e = List[Int](length=m, fill=0)
        e[k] = 1
        tries.append(e^)
    for t in range(len(tries)):
        if t == 6:
            # before the constant fallbacks: a seeded search for a generic
            # member (the seed fixes the run; certificates are verified anyway)
            var rng = SplitMix64(BASE_POINT_SEED)
            for _ in range(BASE_POINT_DRAWS):
                var ns = List[Int]()
                for _ in range(m):
                    ns.append(rng.between(1, 16))
                if _member_at(pat, subst, ns, screen):
                    return ns^
        if _member_at(pat, subst, tries[t], screen):
            return tries[t].copy()
    return List[Int]()


def _generic_point(subst: List[List[Int]]) -> List[Int]:
    """The distinct-primes point of a region, member or not."""
    var m = len(subst[0]) - 1
    var primes = List[Int]([2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53])
    var out = List[Int]()
    for k in range(m):
        out.append(primes[k % len(primes)])
    return out^



def _carving_forms(ineqs: List[List[Int]]) -> List[List[Int]]:
    """The forms worth carving by: those not already coefficientwise
    nonnegative, each once."""
    var out = List[List[Int]]()
    for k in range(len(ineqs)):
        if aff_nonneg(ineqs[k]):
            continue
        var seen = False
        for j in range(len(out)):
            if out[j] == ineqs[k]:
                seen = True
        if not seen:
            out.append(ineqs[k].copy())
    return out^


def _guided_bag(slots: List[List[Int]], ineqs: List[List[Int]], steps: List[WitnessStep]) -> List[List[Int]]:
    """Slots, then the forms to carve by, then each step's two offsets."""
    var bag = slots.copy()
    for k in range(len(ineqs)):
        bag.append(ineqs[k].copy())
    for k in range(len(steps)):
        bag.append(steps[k].off_a.copy())
        bag.append(steps[k].off_b.copy())
    return bag^


def _steps_from_bag(bag: List[List[Int]], first: Int, steps: List[WitnessStep]) -> List[WitnessStep]:
    var out = List[WitnessStep]()
    for k in range(len(steps)):
        out.append(WitnessStep(steps[k].seg_a, bag[first + 2 * k].copy(), steps[k].seg_b, bag[first + 2 * k + 1].copy()))
    return out^


struct GuidedRegion(Copyable, Movable):
    """A region that carries its own inequalities: the points `n >= 0` with
    every `assume` form `>= 0`, mapped to slot values by `subst`. With a
    product lift (`lift.on()`) the variables are `(n, q)`, the slots are
    forms over `n` alone, and the region stands for its real points
    `q_j = n_j e`, which every substitution keeps real (`_region_subst`)."""

    var subst: List[List[Int]]
    var assume: List[List[Int]]
    var depth: Int  # value peels behind it
    var corner: Int  # uniform McCormick corners already applied
    var split: Bool  # split by the value of Lemma P1's factor a = Z_2 already
    var lift: ProductLift

    def __init__(out self, var subst: List[List[Int]], var assume: List[List[Int]], depth: Int, corner: Int = 0, split: Bool = False, var lift: ProductLift = no_lift()):
        self.subst = subst^
        self.assume = assume^
        self.depth = depth
        self.corner = corner
        self.split = split
        self.lift = lift^


def tighten(f: List[Int]) -> List[Int]:
    """The same integer points: `c + g L >= 0`, with `g` the gcd of the
    variable coefficients, holds iff `floor(c / g) + L >= 0` (L is integral)."""
    var g = 0
    for k in range(1, len(f)):
        var a = abs(f[k])
        var b = g
        while b != 0:
            var r = a % b
            a = b
            b = r
        g = a
    if g <= 1:
        return f.copy()
    var out = List[Int]()
    out.append(f[0] // g)  # floor division
    for k in range(1, len(f)):
        out.append(f[k] // g)
    return out^


def _with_assumptions(reg: GuidedRegion, more: List[List[Int]]) -> GuidedRegion:
    var a = reg.assume.copy()
    for k in range(len(more)):
        a.append(tighten(more[k]))
    return GuidedRegion(reg.subst.copy(), a^, reg.depth, reg.corner, reg.split, reg.lift.copy())


def _region_subst(reg: GuidedRegion, k: Int, repl: List[Int], depth: Int) -> GuidedRegion:
    """`n_k := repl`. With a product lift the product coordinates follow
    (`product_substitution`), so real points stay real; a substitution they
    cannot follow is imposed as `n_k = repl` (two assumptions) instead."""
    var sub = _subst_var(reg.subst, k, repl)
    var a = _subst_var(reg.assume, k, repl)
    if reg.lift.on():
        var ps = product_substitution(reg.lift, k, repl)
        if not ps.ok:
            var d = aff_scale(repl, -1)
            d[k + 1] += 1
            var same = GuidedRegion(reg.subst.copy(), reg.assume.copy(), depth, reg.corner, reg.split, reg.lift.copy())
            return _with_assumptions(same, List[List[Int]]([d.copy(), aff_scale(d, -1)]))
        for i in range(len(ps.vars)):
            sub = _subst_var(sub, ps.vars[i], ps.forms[i])
            a = _subst_var(a, ps.vars[i], ps.forms[i])
    for i in range(len(a)):
        a[i] = tighten(a[i])
    return GuidedRegion(sub^, a^, depth, reg.corner, reg.split, reg.lift.copy())


def _point_vars(reg: GuidedRegion, m: Int) -> Int:
    """The variables that pick a point: all `m`, or with a product lift the
    `n` alone (the first `lift.m`; the `q` follow them)."""
    return reg.lift.m if reg.lift.on() else m


def _realize(reg: GuidedRegion, x: List[Int]) raises -> List[Int]:
    """With a product lift, the real point over `x`'s `n`: `q_j = n_j e`."""
    if not reg.lift.on():
        return x.copy()
    var ns = List[Int]()
    for k in range(reg.lift.m):
        ns.append(x[k])
    return lift_point(reg.lift, ns)


def _tail_fixed_forms(reg: GuidedRegion, ev: Int) -> List[List[Int]]:
    """The assumptions at the real points with `e = ev`, as forms over `n`
    (`q_j = ev n_j` is linear there; `e` itself enters the constant)."""
    ref L = reg.lift
    var out = List[List[Int]]()
    for i in range(len(reg.assume)):
        ref f = reg.assume[i]
        var g = List[Int]()
        for k in range(L.m + 1):
            g.append(f[k])
        g[0] += f[L.e + 1] * ev
        g[L.e + 1] = 0
        for t in range(len(L.prods)):
            var c = f[1 + L.m + t]
            if L.prods[t] == L.e:
                g[0] += c * ev * ev
            else:
                g[L.prods[t] + 1] += c * ev
        out.append(g^)
    return out^


def _walk_in(reg: GuidedRegion, start: List[Int], box: Box) raises -> List[Int]:
    """`start` clamped to the box and walked into the region by
    `_repair_into`; empty if it is not reached. With a product lift the walk
    keeps `e` and moves `n` on the forms `_tail_fixed_forms`, so the point it
    returns is real."""
    var m = len(start)
    var c = start.copy()
    for k in range(m):
        c[k] = max(c[k], box.lo[k])
        if box.bounded[k]:
            c[k] = min(c[k], box.hi[k])
    if not reg.lift.on():
        return c^ if _satisfies(reg.assume, c) else _repair_into(reg.assume, c)
    var x = _realize(reg, c)
    if _satisfies(reg.assume, x):
        return x^
    var fixed = _tail_fixed_forms(reg, c[reg.lift.e])
    var ns = List[Int]()
    for k in range(reg.lift.m):
        ns.append(c[k])
    ns = _repair_into(fixed, ns)
    if len(ns) == 0:
        return ns^
    x = lift_point(reg.lift, ns)
    if not _satisfies(reg.assume, x):
        raise Error("a real point walked in on the tail-fixed forms is outside the region")
    return x^


def _region_live(reg: GuidedRegion, k: Int) -> Bool:
    return _live(reg.subst, k) or _live(reg.assume, k)


struct Box(Copyable, Movable):
    """Integer bounds `lo_k <= n_k <= hi_k` implied by a region's assumptions
    (`bounded_k` false: no upper bound); `empty` when they contradict."""

    var empty: Bool
    var lo: List[Int]
    var hi: List[Int]
    var bounded: List[Bool]

    def __init__(out self, m: Int):
        self.empty = False
        self.lo = List[Int](length=m, fill=0)
        self.hi = List[Int](length=m, fill=0)
        self.bounded = List[Bool](length=m, fill=False)


def _ceil_div(a: Int, b: Int) -> Int:
    return -((-a) // b)


def propagate_bounds(assume: List[List[Int]], m: Int) -> Box:
    return propagate_bounds_from(assume, Box(m))


def propagate_bounds_from(assume: List[List[Int]], var box: Box) -> Box:
    """Bound propagation over the integers: from `a_k n_k + R >= 0` and the
    largest value `R` can take on the current box, `a_k n_k >= -max R`.
    Every bound holds at every integer point of the region, so a crossed
    pair of bounds proves it empty. Iterated to a fixed point, at most
    `PROPAGATE_ROUNDS` rounds; `propagate_bounds_from` starts from a given
    box (its bounds assumed to hold)."""
    for _ in range(PROPAGATE_ROUNDS):
        var changed = False
        for i in range(len(assume)):
            ref f = assume[i]
            var top = f[0]  # the maximum of f over the box, without unbounded terms
            var unbounded = 0
            for k in range(1, len(f)):
                if f[k] > 0:
                    if box.bounded[k - 1]:
                        top += f[k] * box.hi[k - 1]
                    else:
                        unbounded += 1
                elif f[k] < 0:
                    top += f[k] * box.lo[k - 1]
            if unbounded == 0 and top < 0:
                box.empty = True
                return box^
            for k in range(1, len(f)):
                var a = f[k]
                if a == 0:
                    continue
                var own_unbounded = 1 if (a > 0 and not box.bounded[k - 1]) else 0
                if unbounded - own_unbounded > 0:
                    continue
                var own = 0
                if a > 0 and box.bounded[k - 1]:
                    own = a * box.hi[k - 1]
                elif a < 0:
                    own = a * box.lo[k - 1]
                var rest = top - own  # max of the other terms
                if a > 0:
                    var lo = _ceil_div(-rest, a)
                    if lo > box.lo[k - 1]:
                        box.lo[k - 1] = lo
                        changed = True
                else:
                    var hi = rest // (-a)
                    if not box.bounded[k - 1] or hi < box.hi[k - 1]:
                        box.hi[k - 1] = hi
                        box.bounded[k - 1] = True
                        changed = True
                if box.bounded[k - 1] and box.lo[k - 1] > box.hi[k - 1]:
                    box.empty = True
                    return box^
                if box.lo[k - 1] > REPAIR_MAX_VALUE:
                    return box^  # far out: stop refining, nothing is claimed
        if not changed:
            break
    return box^


def _refutes(f: List[Int]) -> Bool:
    """`f >= 0` has no point with `n >= 0`: no positive coefficient and a
    negative constant."""
    if f[0] >= 0:
        return False
    for k in range(1, len(f)):
        if f[k] > 0:
            return False
    return True


def _gcd(a: Int, b: Int) -> Int:
    var x = abs(a)
    var y = abs(b)
    while y != 0:
        var r = x % y
        x = y
        y = r
    return x


def _normalized(f: List[Int]) -> List[Int]:
    """The row divided by the gcd of its entries (same rational half-space)."""
    var g = 0
    for k in range(len(f)):
        g = _gcd(g, f[k])
    if g <= 1:
        return f.copy()
    var out = List[Int]()
    for k in range(len(f)):
        out.append(f[k] // g)
    return out^


struct FMResult(Copyable, Movable):
    """`ok` false when a cap was hit (nothing is claimed); `empty` when the
    rational relaxation is empty; else `rows`, the constraints left on the
    kept variable."""

    var ok: Bool
    var empty: Bool
    var rows: List[List[Int]]

    def __init__(out self, ok: Bool, empty: Bool, var rows: List[List[Int]]):
        self.ok = ok
        self.empty = empty
        self.rows = rows^


def fm_infeasible(assume: List[List[Int]], m: Int) -> Bool:
    """Fourier-Motzkin elimination of every variable from the assumptions
    and `n >= 0`: true only when the rational relaxation is empty, which
    makes the region (its integer points) empty. Capped: past `FM_ROWS`
    rows or entries of `FM_MAGNITUDE`, it answers false (unknown)."""
    var r = fm_eliminate(assume, m, -1)
    return r.ok and r.empty


def fm_bounds(assume: List[List[Int]], m: Int, keep: Int) -> Box:
    """Integer bounds on variable `keep` over the region's rational
    relaxation (every other variable eliminated): `lo`/`hi` in a Box of
    width 1; `empty` when the relaxation is empty; unbounded above when no
    upper bound survives. A capped elimination claims nothing (lower bound 0,
    unbounded)."""
    var box = Box(1)
    var r = fm_eliminate(assume, m, keep)
    if not r.ok:
        return box^
    if r.empty:
        box.empty = True
        return box^
    for i in range(len(r.rows)):
        var a = r.rows[i][keep + 1]
        var c = r.rows[i][0]
        if a > 0:
            box.lo[0] = max(box.lo[0], _ceil_div(-c, a))
        elif a < 0:
            var h = c // (-a)
            if not box.bounded[0] or h < box.hi[0]:
                box.hi[0] = h
                box.bounded[0] = True
    if box.bounded[0] and box.lo[0] > box.hi[0]:
        box.empty = True
    return box^


def fm_eliminate(assume: List[List[Int]], m: Int, keep: Int) -> FMResult:
    var rows = List[List[Int]]()
    for i in range(len(assume)):
        rows.append(_normalized(assume[i]))
    for k in range(m):
        var e = aff_const(m, 0)
        e[k + 1] = 1
        rows.append(e^)
    for k in range(m):
        if k == keep:
            continue
        var pos = List[List[Int]]()
        var neg = List[List[Int]]()
        var rest = List[List[Int]]()
        for i in range(len(rows)):
            var a = rows[i][k + 1]
            if a > 0:
                pos.append(rows[i].copy())
            elif a < 0:
                neg.append(rows[i].copy())
            else:
                rest.append(rows[i].copy())
        if len(pos) * len(neg) + len(rest) > FM_ROWS:
            return FMResult(False, False, List[List[Int]]())
        for i in range(len(pos)):
            for j in range(len(neg)):
                var ap = pos[i][k + 1]
                var an = -neg[j][k + 1]
                var r = List[Int]()
                for t in range(m + 1):
                    var v = an * pos[i][t] + ap * neg[j][t]
                    if abs(v) > FM_MAGNITUDE:
                        return FMResult(False, False, List[List[Int]]())
                    r.append(v)
                rest.append(_normalized(r))
        # drop constant rows that hold; a constant row that fails is empty
        rows = List[List[Int]]()
        for i in range(len(rest)):
            var constant = True
            for t in range(1, m + 1):
                if rest[i][t] != 0:
                    constant = False
                    break
            if constant:
                if rest[i][0] < 0:
                    return FMResult(True, True, List[List[Int]]())
                continue
            var dup = False
            for j in range(len(rows)):
                if rows[j] == rest[i]:
                    dup = True
                    break
            if not dup:
                rows.append(rest[i].copy())
    if keep < 0:
        for i in range(len(rows)):
            if rows[i][0] < 0:
                return FMResult(True, True, List[List[Int]]())
        return FMResult(True, False, List[List[Int]]())
    return FMResult(True, False, rows^)


def _implied_equality(reg: GuidedRegion, m: Int) -> GuidedRegion:
    """The region with one assumption it holds with equality substituted
    away: an assumption `A` with a unit coefficient such that `A >= 1` is
    infeasible with the rest (Fourier-Motzkin) is `A = 0` at every point, so
    its unit variable is solved for. Returns the region unchanged (same
    assumptions) when none is found. With a product lift only an `n` the
    product coordinates can follow is solved for."""
    for i in range(len(reg.assume)):
        ref a = reg.assume[i]
        if aff_is_const(a):
            continue
        # a = c n_v + R = 0, so n_v = -c R (>= 0 is kept as an assumption)
        var v = -1
        var repl = List[Int]()
        for k in range(_point_vars(reg, m)):
            if (a[k + 1] == 1 or a[k + 1] == -1) and _region_live(reg, k):
                var r = a.copy()
                r[k + 1] = 0
                repl = aff_scale(r, -a[k + 1])
                if not reg.lift.on() or product_substitution(reg.lift, k, repl).ok:
                    v = k
                    break
        if v < 0:
            continue
        var probe = reg.assume.copy()
        var up = a.copy()
        up[0] -= 1
        probe.append(up^)
        if not fm_infeasible(probe, m):
            continue
        var piece = _region_subst(reg, v, repl, reg.depth)
        return _with_assumptions(piece, List[List[Int]]([repl.copy()]))
    return reg.copy()


def _point_line_search(point: ConeFamily, reg: GuidedRegion) -> WitnessSearch:
    """`search_witness_line` at a point of the region. With a product lift
    the line offset may grow to a run length (`LINE_CAP`): its lambda is
    affine in n, and a lift turns lambda M (e_z - e_y) into q."""
    if reg.lift.on():
        return search_witness_line(point, O, Y, Q_OFFSET_BOUND, MAX_LEVEL, Y, Z, LINE_CAP)
    return search_witness_line(point, O, Y, OFFSET_BOUND, MAX_LEVEL, Y, Z)


def _decide_point(pat: RunPattern, piece: GuidedRegion, m: Int, mut screen: CubicScreen, mut out: ShapeCover) raises:
    """Case (d) for one point of a region (every live variable substituted):
    not a member, or coincident by a witness path or Lemma X closure found
    and verified on the point's own family (b, c), else by
    `coincidence_level`; a negative raises."""
    var fam = pattern_family(pat, piece.subst)
    var sigma = fam.instantiate(List[Int](length=m, fill=0))
    var mat = Mat3(substitution_incidence(sigma))
    if abs(mat.det()) != 2 or not screen.is_pip(mat):
        out.not_member += 1
        return
    var wp = _point_line_search(fam, piece)
    if wp.found and verify_witness_line(fam, O, Y, wp.steps):
        out.decided += 1
        out.max_level = max(out.max_level, len(wp.steps))
        return
    var cp = search_crossing(fam, O, Y, OFFSET_BOUND, MAX_LEVEL - 2, Y, Z, Y, Z)
    if cp.found and verify_crossing(fam, O, Y, cp.steps, cp.close[0], Y, Z):
        out.decided += 1
        out.max_level = max(out.max_level, len(cp.steps) + 2)
        return
    var lev = -1
    try:
        lev = coincidence_level(sigma, O, Y)
    except:
        # past the exact procedure's bounds: undecided, reported open
        out.open += 1
        out.open_forms.append(piece.subst.copy())
        return
    if lev < 0:
        raise Error("SC REFUTED in Theorem K's family: {o, y} is not eventually coincident")
    out.decided += 1
    out.max_level = max(out.max_level, lev)


def _finite_points(reg: GuidedRegion, m: Int, cap: Int = FINITE_POINTS) raises -> List[GuidedRegion]:
    """The region as its integer points, when Fourier-Motzkin bounds every
    live variable and the box holds at most `FINITE_POINTS` points: one
    fully substituted region per point satisfying the assumptions (an exact
    partition of the region). Empty when the region is not shown finite.
    With a product lift, its real points: the `n` are enumerated."""
    var out = List[GuidedRegion]()
    var lo = List[Int]()
    var hi = List[Int]()
    var live = List[Int]()
    var size = 1
    for k in range(_point_vars(reg, m)):
        if not _region_live(reg, k):
            continue
        var b = fm_bounds(reg.assume, m, k)
        if b.empty:
            return out^
        if not b.bounded[0]:
            return List[GuidedRegion]()
        live.append(k)
        lo.append(b.lo[0])
        hi.append(b.hi[0])
        size *= b.hi[0] - b.lo[0] + 1
        if size > cap:
            return List[GuidedRegion]()
    # enumerate the box, keep the points of the region
    var cur = lo.copy()
    while True:
        var ns = List[Int](length=m, fill=0)
        for t in range(len(live)):
            ns[live[t]] = cur[t]
        if _satisfies(reg.assume, _realize(reg, ns)):
            var piece = reg.copy()
            for t in range(len(live)):
                piece = _region_subst(piece, live[t], aff_const(m, cur[t]), piece.depth)
            out.append(piece^)
        var t = 0
        while t < len(live):
            cur[t] += 1
            if cur[t] <= hi[t]:
                break
            cur[t] = lo[t]
            t += 1
        if t == len(live):
            break
    return out^


def _value_split(reg: GuidedRegion, m: Int) raises -> List[GuidedRegion]:
    """The region split by every value of the live point variable with the
    fewest values, when it has at most `VALUE_SPLIT_MAX`: from its
    propagated lower bound `lo`, the first `lo + d` such that a checked
    Farkas certificate refutes `n_k >= lo + d + 1` (`lp_infeasible`), so
    every integer point of the region has `lo <= n_k <= lo + d`. A
    partition, each piece one variable fewer (with a product lift the
    products follow, `_region_subst`). Empty when no live variable has so
    few values."""
    var box = propagate_bounds(reg.assume, m)
    var best = -1
    var best_d = VALUE_SPLIT_MAX
    for k in range(_point_vars(reg, m)):
        if not _region_live(reg, k):
            continue
        for d in range(best_d):
            var capped = box.bounded[k] and box.lo[k] + d >= box.hi[k]
            if not capped:
                var above = aff_const(m, -(box.lo[k] + d + 1))
                above[k + 1] = 1
                var probe = reg.assume.copy()
                probe.append(above^)
                capped = lp_infeasible(probe, m)
            if capped:
                best = k
                best_d = d
                break
        if best_d == 0:
            break
    if best < 0:
        return List[GuidedRegion]()
    return _value_pieces(reg, best, box.lo[best], box.lo[best] + best_d, m)


def _value_pieces(reg: GuidedRegion, k: Int, lo: Int, hi: Int, m: Int, c: Int = 0) -> List[GuidedRegion]:
    """The region with `n_k := v + c e` for every `v` in `lo..hi` (with a
    product lift; `c = 0` otherwise), one level deeper: a partition of the
    real points when every one has `lo <= n_k - c e <= hi`. The products
    follow (`_region_subst`). With a product lift a piece carries
    `v + c e >= 0` unless `c = 0` and `v >= 0`; without one it carries
    nothing."""
    var out = List[GuidedRegion]()
    for v in range(lo, hi + 1):
        var repl = aff_const(m, v)
        if c == 0 and (v >= 0 or not reg.lift.on()):
            out.append(_region_subst(reg, k, repl, reg.depth + 1))
            continue
        if c != 0:
            repl[reg.lift.e + 1] = c
        var piece = _region_subst(reg, k, repl, reg.depth + 1)
        out.append(_with_assumptions(piece, List[List[Int]]([repl^])))
    return out^


def _refuted_with(reg: GuidedRegion, m: Int, extra: List[Int]) raises -> Bool:
    """No real point of the region has `extra >= 0`: the region with it and
    its envelope (`_with_envelope`, valid at every real point there) is
    refuted by bound propagation or a checked Farkas certificate."""
    var p = _with_envelope(_with_assumptions(reg, List[List[Int]]([extra.copy()])), m)
    return propagate_bounds(p.assume, m).empty or lp_infeasible(p.assume, m)


def _affine_top(reg: GuidedRegion, m: Int, form: List[Int]) raises -> Int:
    """A `h` in `-AFFINE_REACH..AFFINE_REACH` such that no real point of the
    region has `form >= h + 1` (`_refuted_with`), the least such found by
    doubling from 0 and then bisection; `AFFINE_REACH + 1` when none is.
    Every `h` returned was refuted at."""
    var good = AFFINE_REACH + 1  # least value refuted at so far
    var bad = -AFFINE_REACH - 1  # a value not refuted at
    var h = 0
    var step = 1
    while abs(h) <= AFFINE_REACH:
        var g = form.copy()
        g[0] -= h + 1
        if _refuted_with(reg, m, g):
            good = h
            if bad > -AFFINE_REACH - 1:
                break
            h -= step
        else:
            bad = h
            if good <= AFFINE_REACH:
                break
            h += step
        step *= 2
    if good > AFFINE_REACH:
        return good
    while good - bad > 1 and bad >= -AFFINE_REACH:
        var mid = bad + (good - bad) // 2
        var g = form.copy()
        g[0] -= mid + 1
        if _refuted_with(reg, m, g):
            good = mid
        else:
            bad = mid
    return good


def _affine_value_split(reg: GuidedRegion, m: Int) raises -> List[GuidedRegion]:
    """With a product lift, the region split by the values of an
    `e`-parametric form `L = n_k - c e` (`c` in `0..AFFINE_SLOPES`, `n_k`
    live, `k != e` unless `c = 0`) with the fewest values, fewer than
    `VALUE_SPLIT_MAX`: `L <= hi` from `_affine_top` and `L >= lo` from a
    refutation of `L <= lo - 1`, each a checked certificate on the region
    with the probe and its envelope, so every real point has
    `lo <= L <= hi`. The pieces `n_k := v + c e` (`_value_pieces`) are a
    partition of the real points, each one run length fewer. Empty when no
    such form is found."""
    if not reg.lift.on():
        return List[GuidedRegion]()
    var e = reg.lift.e
    var best_k = -1
    var best_c = 0
    var best_lo = 0
    var best_d = VALUE_SPLIT_MAX
    for k in range(reg.lift.m):
        if not _region_live(reg, k):
            continue
        for c in range(AFFINE_SLOPES + 1):
            if k == e and c != 0:
                continue
            var form = aff_const(m, 0)
            form[k + 1] = 1
            form[e + 1] -= c
            var hi = _affine_top(reg, m, form)
            if hi > AFFINE_REACH:
                continue
            for d in range(best_d):
                var below = aff_scale(form, -1)  # L <= hi - d - 1
                below[0] = hi - d - 1
                if _refuted_with(reg, m, below):
                    best_k = k
                    best_c = c
                    best_lo = hi - d
                    best_d = d
                    break
            if best_d == 0:
                break
        if best_d == 0:
            break
    if best_k < 0:
        return List[GuidedRegion]()
    return _value_pieces(reg, best_k, best_lo, best_lo + best_d, m, best_c)


def _assume_empty(assume: List[List[Int]], m: Int) -> Bool:
    """Sufficient for no integer point: an assumption, or the sum of two or
    three, refutes itself; or bound propagation crosses a pair of bounds."""
    var n = len(assume)
    for i in range(n):
        if _refutes(assume[i]):
            return True
        for j in range(i, n):
            var fij = aff_add(assume[i], assume[j])
            if _refutes(fij):
                return True
            for k in range(j, n):
                if _refutes(aff_add(fij, assume[k])):
                    return True
    return propagate_bounds(assume, m).empty or fm_infeasible(assume, m)


def _satisfies(assume: List[List[Int]], ns: List[Int]) -> Bool:
    for k in range(len(assume)):
        if aff_eval(assume[k], ns) < 0:
            return False
    return True


def _aff_times(a: List[Int], b: List[Int]) -> List[Int]:
    """The product of two affine forms, as a quadratic form (psc.cone_witness's
    upper-triangular layout)."""
    var w = len(a)
    var q = List[Int](length=w * w, fill=0)
    q[0] = a[0] * b[0]
    for k in range(1, w):
        q[k] += a[0] * b[k] + a[k] * b[0]
        for l in range(1, w):
            var lo = min(k, l)
            var hi = max(k, l)
            q[lo * w + hi] += a[k] * b[l]
    return q^


def pisot_cut_under(counts: List[List[Int]], s: Int, prover: Prover) -> Bool:
    """`pisot_cut` on a region with assumptions: Lemma Phi4's linear forms,
    or Lemma P1's quadratic f = a b + c, shown >= 0 by the prover."""
    if pisot_cut(counts, s):
        return True
    var dy = aff_sub(counts[0], counts[2])
    if s == 1:
        var g = aff_scale(dy, -1)
        g[0] -= 1
        if prover.nonneg(g):
            return True
    else:
        var g = dy.copy()
        g[0] -= 1
        if prover.nonneg(g):
            return True
        var h = aff_scale(counts[3], -1)
        h[0] += 1
        if prover.nonneg(h):
            return True
    var q = _pisot_quadratic(counts, s)
    return _q_nonneg_under(_q_lin(_aff_times(q[0], q[1]), _qa(q[2]), 1), prover)


def mccormick_cut(counts: List[List[Int]], s: Int, g: List[List[Int]], prover: Prover) -> Bool:
    """No PIP member where G_1, G_2, G_3 >= 0 (`pisot_carve_forms`): Lemma
    P1's f less G_1 G_2 + G_3 has nonnegative coefficients (it is 0), and the
    prover shows each G_i >= 0 on the region."""
    var q = _pisot_quadratic(counts, s)
    var f = _q_lin(_aff_times(q[0], q[1]), _qa(q[2]), 1)
    var rest = _q_lin(_q_lin(f, _aff_times(g[0], g[1]), -1), _qa(g[2]), -1)
    if not _q_nonneg(rest):
        return False
    for k in range(3):
        if not prover.nonneg(g[k]):
            return False
    return True


def _base_candidates(m: Int) raises -> List[List[Int]]:
    """Small points first (short runs keep a certificate's offsets within
    the search's bound; the linear lift asks identities of the whole region,
    so relations that hold at the point by accident do no harm), then
    generic points (distinct primes, mixed sequences), a seeded search,
    constant points, the origin and the unit points."""
    var tries = List[List[Int]]()
    var primes = List[Int]([2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53])
    for variant in range(6):
        var generic = List[Int]()
        for k in range(m):
            if variant == 0:
                generic.append(primes[k % len(primes)])
            elif variant == 1:
                generic.append(primes[(m - 1 - k) % len(primes)])
            elif variant == 2:
                generic.append(2 + (3 * k) % 7)
            elif variant == 3:
                generic.append(1 + (5 * k + 2) % 9)
            elif variant == 4:
                generic.append(primes[(2 * k + 1) % len(primes)] % 13 + 1)
            else:
                generic.append(1 + (7 * k + 3) % 11)
        tries.append(generic^)
    var rng = SplitMix64(BASE_POINT_SEED)
    for _ in range(BASE_POINT_DRAWS):
        var ns = List[Int]()
        for _ in range(m):
            ns.append(rng.between(0, 16))
        tries.append(ns^)
    for g in [2, 1, 3]:
        tries.append(List[Int](length=m, fill=g))
    tries.append(List[Int](length=m, fill=0))
    for k in range(m):
        var e = List[Int](length=m, fill=0)
        e[k] = 1
        tries.append(e^)
    return tries^


def _violation(assume: List[List[Int]], ns: List[Int]) -> Int:
    var v = 0
    for k in range(len(assume)):
        v += max(0, -aff_eval(assume[k], ns))
    return v


def _repair_into(assume: List[List[Int]], start: List[Int]) -> List[Int]:
    """Walk `start` into the region by local search on the total violation:
    at each step, of the moves that satisfy the worst-violated assumption
    through one variable (raise it, or lower it towards 0), take the one
    that leaves the least total violation; stop when it no longer drops.
    Guidance only; empty if no point is reached."""
    var ns = start.copy()
    var total = _violation(assume, ns)
    for _ in range(4 * len(assume) + 8):
        if total == 0:
            return ns^
        var worst = -1
        var worst_value = 0
        for k in range(len(assume)):
            var v = aff_eval(assume[k], ns)
            if v < worst_value:
                worst = k
                worst_value = v
        if worst_value < -REPAIR_MAX_VALUE:
            return List[Int]()
        var best = List[Int]()
        var best_total = total
        for k in range(1, len(assume[worst])):
            var a = assume[worst][k]
            if a == 0:
                continue
            var step = (-worst_value + abs(a) - 1) // abs(a)
            var trial = ns.copy()
            if a > 0:
                trial[k - 1] += step
            else:
                trial[k - 1] = max(0, trial[k - 1] - step)
            if trial[k - 1] > REPAIR_MAX_VALUE or trial[k - 1] == ns[k - 1]:
                continue
            var t = _violation(assume, trial)
            if t < best_total:
                best = trial^
                best_total = t
        if len(best) == 0:
            return List[Int]()
        ns = best^
        total = best_total
    return ns^ if total == 0 else List[Int]()


struct PointSearch(Copyable, Movable):
    """A point of a region (`point` nonempty), or a proof that it has none
    (`empty`: the search exhausted every branch untruncated), or neither."""

    var point: List[Int]
    var empty: Bool

    def __init__(out self, var point: List[Int], empty: Bool):
        self.point = point^
        self.empty = empty


def search_point(assume: List[List[Int]], m: Int, span_cap: Int = 0) -> PointSearch:
    """Depth-first search over values with bound propagation at every node:
    fix the first free variable that occurs in an assumption to each value
    of its domain (at most `SEARCH_SPAN` values when unbounded, which
    truncates the search), and accept a box whose lower corner satisfies
    every assumption. A variable in no assumption is free and stays at its
    lower bound. Each branching partitions a domain and propagation keeps
    every integer point, so an untruncated search that finds nothing within
    `SEARCH_NODES` nodes proves the region empty. With `span_cap > 0` a
    bounded domain of more values is truncated to its first `span_cap`."""
    var occurs = List[Bool](length=m, fill=False)
    for i in range(len(assume)):
        for k in range(m):
            if assume[i][k + 1] != 0:
                occurs[k] = True
    var root = propagate_bounds(assume, m)
    if root.empty:
        return PointSearch(List[Int](), True)
    var stack = List[Box]()
    stack.append(root^)
    var nodes = 0
    var truncated = False
    while len(stack) > 0:
        if nodes >= SEARCH_NODES:
            truncated = True
            break
        nodes += 1
        var box = stack.pop()
        if _satisfies(assume, box.lo):
            return PointSearch(box.lo.copy(), False)
        var pick = -1
        for k in range(m):
            if occurs[k] and (not box.bounded[k] or box.lo[k] < box.hi[k]):
                pick = k
                break
        if pick < 0:
            continue  # every occurring variable fixed, and the point fails
        var top = box.hi[pick]
        if not box.bounded[pick]:
            top = box.lo[pick] + SEARCH_SPAN - 1
            truncated = True
        elif span_cap > 0 and top - box.lo[pick] >= span_cap:
            top = box.lo[pick] + span_cap - 1
            truncated = True
        # push larger values first, so the smallest is tried first
        var v = top
        while v >= box.lo[pick]:
            var child = box.copy()
            child.lo[pick] = v
            child.hi[pick] = v
            child.bounded[pick] = True
            var next = propagate_bounds_from(assume, child^)
            if not next.empty:
                stack.append(next^)
            v -= 1
    return PointSearch(List[Int](), not truncated)


def _descend_to_member(pat: RunPattern, reg: GuidedRegion, s: Int, start: List[Int], mut screen: CubicScreen) raises -> List[Int]:
    """From a point of the region, coordinate descent on Lemma P1's form
    `f` (a member has `f < 0`): halve or decrement one variable, keeping the
    region's inequalities, taking the move that lowers `f` most, until a
    member is reached; empty if `f` stops decreasing first. Guidance only."""
    var q = _pisot_quadratic(pattern_counts(pat, reg.subst), s)
    var x = start.copy()
    for _ in range(DESCENT_STEPS):
        var fx = aff_eval(q[0], x) * aff_eval(q[1], x) + aff_eval(q[2], x)
        if fx < 0 and _member_at(pat, reg.subst, x, screen):
            return x^
        var best = List[Int]()
        var best_f = fx
        for k in range(len(x)):
            if x[k] == 0:
                continue
            if k >= _point_vars(reg, len(x)):
                continue
            for v in [x[k] // 2, x[k] - 1]:
                var y = x.copy()
                y[k] = v
                y = _realize(reg, y)
                if not _satisfies(reg.assume, y):
                    continue
                var fy = aff_eval(q[0], y) * aff_eval(q[1], y) + aff_eval(q[2], y)
                if fy < best_f:
                    best = y^
                    best_f = fy
        if len(best) == 0:
            return List[Int]()
        x = best^
    return List[Int]()


def _base_point_in(pat: RunPattern, reg: GuidedRegion, mut screen: CubicScreen, want_member: Bool, far: Int = -1, s: Int = 0) raises -> List[Int]:
    """A point of the region (its assumptions hold there): the first member
    among the candidates, each walked into the region, or, unless
    `want_member`, the first point. With `far >= 0` (a tail cell's `e`),
    candidates with that coordinate moderately large come first: past the
    threshold where a tail's certificate no longer depends on `e`, a lifted
    one covers every larger `e` at once, while its offsets stay within the
    search's bound (at `e = 40` they did not)."""
    var m = len(reg.subst[0]) - 1
    var box = propagate_bounds(reg.assume, m)
    if box.empty:
        return List[Int]()
    var tries = _base_candidates(m)
    if far >= 0:
        var near = tries^
        tries = List[List[Int]]()
        for t in range(min(FAR_CANDIDATES, len(near))):
            for e in [5, 3]:
                var c = near[t].copy()
                c[far] = e
                tries.append(c^)
        for t in range(len(near)):
            tries.append(near[t].copy())
    var feasible = List[List[Int]]()
    for t in range(len(tries)):
        var ns = _walk_in(reg, tries[t], box)
        if len(ns) == 0:
            continue
        if not want_member:
            return ns^
        if _member_at(pat, reg.subst, ns, screen):
            return ns^
        if len(feasible) < DESCENT_STARTS:
            feasible.append(ns^)
    if want_member and s != 0:
        for t in range(len(feasible)):
            var d = _descend_to_member(pat, reg, s, feasible[t], screen)
            if len(d) > 0:
                return d^
    if not want_member:
        return _point_search(reg, m).point.copy()
    return List[Int]()


def _point_search(reg: GuidedRegion, m: Int) raises -> PointSearch:
    """`search_point`, or with a product lift its real points: for each
    value `ev` of `e` in its propagated range, `search_point` on the forms
    `_tail_fixed_forms(reg, ev)` over `n`, which hold exactly at the real
    points with `e = ev`. `empty` (no real point) only when `e` is bounded,
    takes at most `TAIL_VALUES` values, and every search is exhausted."""
    if not reg.lift.on():
        return search_point(reg.assume, m)
    var box = propagate_bounds(reg.assume, m)
    if box.empty:
        return PointSearch(List[Int](), True)
    ref L = reg.lift
    var lo = box.lo[L.e]
    var truncated = not box.bounded[L.e] or box.hi[L.e] - lo >= TAIL_VALUES
    var hi = lo + TAIL_VALUES - 1 if truncated else box.hi[L.e]
    for ev in range(lo, hi + 1):
        var ps = search_point(_tail_fixed_forms(reg, ev), L.m, TAIL_VALUES)
        if len(ps.point) > 0:
            var p = ps.point.copy()
            p[L.e] = ev
            var x = lift_point(L, p)
            if not _satisfies(reg.assume, x):
                raise Error("a real point found on the tail-fixed forms is outside the region")
            return PointSearch(x^, False)
        if not ps.empty:
            truncated = True
    return PointSearch(List[Int](), not truncated)


def cover_pattern_guided(pat: RunPattern, s: Int, delta: Int, region_budget: Int, tail: Bool = False, verbose: Bool = False, cut_first: Bool = True, corners: Int = 0, z_split: Int = 0, z_cap: Bool = False, z_floor: Int = 0, q_lift: Bool = False) raises -> ShapeCover:
    """Cover the pattern's members in one delta cell by certificate-guided
    partition. Regions carry their own inequalities. At a point of each region
    find a certificate (an exact line-mode path, else a Lemma X closure), lift
    it, and split the region by the lifted forms: where they all hold the
    certificate is re-verified by the ordinary verifier under the region's
    inequalities; the rest goes back on the stack. A non-PIP point carves the
    McCormick quadrant of Lemma P1. Regions left at the budget are reported
    open.

    With `z_floor > 0` the claim is restricted to `Z_2 >= z_floor`, and
    Lemma P1 enters once, linearly (`z_floor_forms`): each start region
    carries `Z_2 >= z_floor` and the McCormick consequence of `f <= -1`.

    With `q_lift` (a tail cell; docs §3m) the variables are `(n, q)`,
    `q_j = n_j e` with `e` the variable of `|Delta| - 1` (`_q_lift_start`,
    `psc.product_lift`): each start region carries Lemma P1 exactly,
    `f <= -1` as an affine form over `(n, q)`, and `Z_2 >= z_floor` if
    asked; every region has the equalities it implies substituted
    (`_implied_equality`) and gets the McCormick envelope of its box and the
    RLT cuts `(e - lo_e) g` of its assumptions over `n` (`_with_envelope`),
    and one Fourier-Motzkin refutes with them is not a member; base points
    are real, found by a point search whose line offset may be a run length
    (`_point_line_search`); polynomial lifts whose conditions are affine over
    `(n, q)` are chosen by their extent on the region (`lift_key`), carved
    by and verified on the whole polyhedron, which holds every real point of
    the region; a region where no base point is found is not a member when
    a checked Farkas certificate refutes its polyhedron (`lp_infeasible`) or
    its bounded `e` admits no real point (`_point_search`), and else is split
    by the values of a variable such certificates bound (`_value_split`),
    or of a form `n_k - c e` bounded by certificates on probes that carry
    their envelope (`_affine_value_split`), before it is reported open; a
    region past the peel limit where no certificate lifts gets one deep
    lazy lift (`_lazy_lift`) from its base point before it is reported
    open. Off by default: without it every step above is the plain cover's."""
    var out = ShapeCover()
    var screen = CubicScreen()
    var mn = pat.slots() + (1 if tail else 0)
    if q_lift and (not tail or z_split > 0):
        raise Error("q_lift needs a tail cell and no z_split")
    var m = 2 * mn if q_lift else mn
    var starts = _pattern_starts(pat, s, delta, tail)
    var stack = List[GuidedRegion]()
    for k in range(len(starts)):
        if q_lift:
            stack.append(_q_lift_start(pat, s, starts[k], z_floor))
            out.cut += 1
            continue
        var start = GuidedRegion(starts[k].copy(), List[List[Int]](), 0)
        if z_floor > 0:
            var g = z_floor_forms(pattern_counts(pat, starts[k]), s, z_floor)
            if len(g) == 0:
                raise Error("z_floor needs |Delta| - 1 bounded below on the pattern")
            start = _with_assumptions(start, g)
            out.cut += 1
        stack.append(start^)
    while len(stack) > 0:
        var reg = stack.pop()
        out.regions += 1
        if out.regions > region_budget:
            out.open += 1 + len(stack)
            out.budget_exhausted = True
            break
        if _assume_empty(reg.assume, m):
            out.not_member += 1
            continue
        reg = _pin_fixed(reg, m)
        if reg.lift.on():
            # substitute the equalities the region implies at once (the
            # products follow): left in, n_4 = n_2 - 3 hides a constant
            # 32 - n_2 inside 6 (q_4 - q_2) and lifts slice along the ray
            for _ in range(EAGER_EQUALITIES):
                var flat = _implied_equality(reg, m)
                if len(flat.assume) == len(reg.assume) and flat.subst == reg.subst:
                    break
                reg = _pin_fixed(flat, m)
        reg = _with_envelope(reg, m)
        if reg.lift.on() and _assume_empty(reg.assume, m):
            # refuted with the envelope: no real point
            out.not_member += 1
            continue
        var prover = Prover(reg.assume.copy())
        if pisot_cut_under(pattern_counts(pat, reg.subst), s, prover):
            out.cut += 1
            continue
        # split once by the value of Lemma P1's factor a = Z_2: a = k for
        # k <= z_split by substitution (there f is affine), and a > z_split
        if z_split > 0 and not reg.split:
            var pieces = _split_by_factor(reg, _pisot_quadratic(pattern_counts(pat, reg.subst), s)[0], z_split)
            if len(pieces) > 0:
                # with z_cap the claim is restricted to Z_2 <= z_split: the
                # last piece (Z_2 > z_split) is left out, not covered
                var keep = len(pieces) - 1 if z_cap else len(pieces)
                for k in range(keep):
                    stack.append(pieces[k].copy())
                continue
        # where Lemma P1's form is affine on the region (Delta fixed), split
        # by it once: {f >= 0} holds no member, the rest carries f <= -1
        var split = _affine_pisot_form(pattern_counts(pat, reg.subst), s)
        if len(split) > 0 and not prover.nonneg(_minus_one_minus(split)):
            var cut_piece = _with_assumptions(reg, List[List[Int]]([split.copy()]))
            if not pisot_cut_under(pattern_counts(pat, cut_piece.subst), s, Prover(cut_piece.assume.copy())):
                raise Error("an affine Lemma P1 split is not cut")
            out.cut += 1
            _push_complements(stack, reg, List[List[Int]]([split^]))
            continue
        if reg.corner < corners - 1:
            # a uniform McCormick corner (2 + corner, 0): Lemma P1's f >= 0
            # on the quadrant, whatever the base point
            var g = mccormick_forms(pattern_counts(pat, reg.subst), s, 2 + reg.corner, 0)
            var inside = _with_assumptions(reg, g)
            if not mccormick_cut(pattern_counts(pat, inside.subst), s, g, Prover(inside.assume.copy())):
                raise Error("a McCormick corner is not cut")
            var next = GuidedRegion(reg.subst.copy(), reg.assume.copy(), reg.depth, reg.corner + 1, reg.split, reg.lift.copy())
            _push_complements(stack, next, g)
            out.cut += 1
            continue
        var any_live = False
        for k in range(_point_vars(reg, m)):
            if _region_live(reg, k):
                any_live = True
        if not any_live and reg.lift.on():
            # a live q_j always comes with its live n_j; a region that broke
            # that would settle real points as non-members
            for k in range(_point_vars(reg, m), m):
                if _region_live(reg, k):
                    raise Error("a product coordinate is live while no run length is")
        # a member if the candidates hit one, else any point of a live region
        var far = (reg.lift.e if reg.lift.on() else mn - 1) if tail else -1
        var ns = _base_point_in(pat, reg, screen, True, far, s)
        if len(ns) == 0 and any_live:
            ns = _base_point_in(pat, reg, screen, False, far)
        if len(ns) == 0:
            # with a lift, a checked Farkas certificate where Fourier-Motzkin
            # gave up: the polyhedron, so every real point, is empty
            if not any_live or (reg.lift.on() and lp_infeasible(reg.assume, m)) or _point_search(reg, m).empty:
                out.not_member += 1
                continue
            if reg.depth >= GUIDED_PEEL_LIMIT:
                var pts = _finite_points(reg, m, DECIDE_POINTS)
                if len(pts) > 0:
                    for k in range(len(pts)):
                        _decide_point(pat, pts[k], m, screen, out)
                    continue
                if reg.lift.on():
                    var pieces = _value_split(reg, m)
                    if len(pieces) == 0:
                        pieces = _affine_value_split(reg, m)
                    if len(pieces) > 0:
                        if verbose:
                            _trace(out.regions, "value split (" + String(len(pieces)) + " values)", List[Int](), reg.subst, List[List[Int]](), 0, len(pieces))
                        stack.extend(pieces^)
                        continue
                var flat = _implied_equality(reg, m)
                if len(flat.assume) != len(reg.assume) or flat.subst != reg.subst:
                    stack.append(flat^)
                    continue
                out.open += 1
                out.open_forms.append(reg.subst.copy())
                if verbose:
                    _trace(out.regions, "open (no point)", List[Int](), reg.subst, reg.assume, 0, 0)
                continue
            _peel(stack, reg, m)
            continue
        # a non-PIP point by Lemma P1: the McCormick quadrant it opens is cut
        # (first, or only once no certificate lifts from the point)
        if cut_first and _mccormick_carve(pat, s, reg, ns, stack, verbose, out.regions):
            out.cut += 1
            continue
        var fam = pattern_family(pat, reg.subst)
        # a certificate for the whole region at once, as in cover_pattern
        var whole = search_witness(fam, O, Y, OFFSET_BOUND, MAX_LEVEL, True)
        if whole.found:
            if not verify_witness(fam, O, Y, whole.steps):
                raise Error("a witness path the search found does not verify")
            out.certified += 1
            out.max_level = max(out.max_level, len(whole.steps))
            continue
        var whole_line = search_witness_line(fam, O, Y, OFFSET_BOUND, MAX_LEVEL, Y, Z)
        if whole_line.found:
            if not verify_witness_line(fam, O, Y, whole_line.steps):
                raise Error("a line-mode witness path the search found does not verify")
            out.certified += 1
            out.line_certified += 1
            out.max_level = max(out.max_level, len(whole_line.steps))
            continue
        var done = _certify_at(pat, fam, reg, ns, stack, out, verbose)
        if not done:
            # other member points of the region: a certificate that does not
            # lift from one point may lift from another
            var alts = _member_points_in(pat, reg, screen, ns, ALT_BASE_POINTS)
            for k in range(len(alts)):
                if _certify_at(pat, fam, reg, alts[k], stack, out, verbose):
                    done = True
                    break
        if not done and not cut_first and _mccormick_carve(pat, s, reg, ns, stack, verbose, out.regions):
            out.cut += 1
            done = True
        if not done:
            # no liftable certificate: peel a live variable, n = 0 | n >= 1
            # (a region without one is a single point)
            var pts = List[GuidedRegion]()
            if any_live and reg.depth >= GUIDED_PEEL_LIMIT:
                pts = _finite_points(reg, m, DECIDE_POINTS)
            var flat = reg.copy()
            if any_live and reg.depth >= GUIDED_PEEL_LIMIT and len(pts) == 0:
                flat = _implied_equality(reg, m)
            if len(pts) > 0:
                for k in range(len(pts)):
                    _decide_point(pat, pts[k], m, screen, out)
            elif flat.subst != reg.subst:
                stack.append(flat^)
            elif any_live and reg.depth >= GUIDED_PEEL_LIMIT and reg.lift.on() and _certify_at(pat, fam, reg, ns, stack, out, verbose, True):
                # q-lift, before reporting it open: the deep lazy lift
                # (liftable paths of zy | yzyz sit at levels 4-5)
                if verbose:
                    print("  #" + String(out.regions), "certified by the deep lazy lift", flush=True)
            elif any_live and reg.depth >= GUIDED_PEEL_LIMIT:
                out.open += 1
                out.open_forms.append(reg.subst.copy())
                if verbose:
                    _trace(out.regions, "open (no certificate)", ns, reg.subst, reg.assume, 0, 0)
            elif any_live:
                _peel(stack, reg, m)
            else:
                _decide_point(pat, reg, m, screen, out)
    return out^


def _q_lift_start(pat: RunPattern, s: Int, start: List[List[Int]], z_floor: Int) raises -> GuidedRegion:
    """A start region of the q-lift. Its `e` is the variable of
    `b = |Delta| - 1 = c + sum lam_i n_i`: with one variable, that one; with
    several (a split renamed the tail into a sum), all `lam_i >= 0` and some
    `lam_v = 1`, the unimodular change `t = n_v + sum_(i != v) lam_i n_i`
    in `n_v`'s place, with `n_v = t - sum lam_i n_i >= 0` kept as an
    assumption (`t >= 0` holds as every `n_i` does). It carries Lemma P1 as
    the affine form `-1 - f >= 0` over `(n, q)` and `Z_2 >= z_floor`."""
    var mn = len(start[0]) - 1
    var sub = start.copy()
    var assume = List[List[Int]]()
    var b = _pisot_quadratic(pattern_counts(pat, sub), s)[1].copy()
    var v = -1
    var count = 0
    for j in range(mn):
        if b[j + 1] != 0:
            count += 1
            if b[j + 1] < 0:
                raise Error("q_lift needs |Delta| - 1 with nonnegative coefficients")
            if b[j + 1] == 1 and v < 0:
                v = j
    if count > 0 and v < 0:
        raise Error("q_lift needs a unit coefficient in |Delta| - 1")
    if count > 1:
        # n_v := n_v - sum_(i != v) lam_i n_i, and that is >= 0
        var repl = aff_const(mn, 0)
        for j in range(mn):
            repl[j + 1] = -b[j + 1]
        repl[v + 1] = 1
        sub = _subst_var(sub, v, repl)
        assume.append(repl^)
    var lift = full_lift(mn, v if v >= 0 else mn - 1)
    var counts = pattern_counts(pat, sub)
    var q = _pisot_quadratic(counts, s)
    var f = poly_add(poly_mul(poly_from_aff(q[0]), poly_from_aff(q[1])), poly_from_aff(q[2]))
    var more = List[List[Int]]()
    for k in range(len(assume)):
        more.append(lift_form(lift, assume[k]))
    more.append(_minus_one_minus(lift_affine(lift, f)))
    if z_floor > 0:
        var zf = lift_form(lift, counts[3])
        zf[0] -= z_floor
        more.append(zf^)
    var lifted = List[List[Int]]()
    for i in range(len(sub)):
        lifted.append(lift_form(lift, sub[i]))
    return _with_assumptions(GuidedRegion(lifted^, List[List[Int]](), 0, lift=lift^), more)


def _with_envelope(reg: GuidedRegion, m: Int) raises -> GuidedRegion:
    """With a product lift, the region with the McCormick envelope of every
    `q_j` on its propagated box of `n` (`mccormick_box_forms`) and, for
    every assumption `g` over `n` alone, `(e - lo_e) g >= 0` and
    `(hi_e - e) g >= 0` on the box of `e` (`rlt_forms`): each holds at every
    real point of the region. Less the forms it already implies. The cuts
    carry relations such as `q_1 <= e (21 + 4e - n_3)` that the box alone
    loses, so Fourier-Motzkin can refute a region with no real point."""
    if not reg.lift.on():
        return reg.copy()
    var box = propagate_bounds(reg.assume, m)
    if box.empty:
        return reg.copy()
    ref L = reg.lift
    var lo = List[Int]()
    var hi = List[Int]()
    var bounded = List[Bool]()
    for k in range(L.m):
        lo.append(box.lo[k])
        hi.append(box.hi[k])
        bounded.append(box.bounded[k])
    # only where n_j and e are live: a variable substituted away has its q_j
    # substituted with it, and a form would bring both back as free variables
    var forms = List[List[Int]]()
    var all = mccormick_box_forms(L, lo, hi, bounded)
    for i in range(len(all)):
        for t in range(len(L.prods)):
            if all[i][1 + L.m + t] != 0 and _region_live(reg, L.prods[t]) and _region_live(reg, L.e):
                forms.append(all[i].copy())
    if _region_live(reg, L.e):
        for g in reg.assume:
            if not aff_is_const(g) and _q_free(g, L):
                forms.extend(rlt_forms(L, g, lo[L.e], hi[L.e], bounded[L.e]))
    return _with_assumptions(reg, _new_forms(forms, reg))


def _q_free(g: List[Int], lift: ProductLift) -> Bool:
    """No product coordinate in the form."""
    for i in range(lift.m + 1, len(g)):
        if g[i] != 0:
            return False
    return True


def _pin_fixed(reg: GuidedRegion, m: Int) -> GuidedRegion:
    """Substitute every variable whose propagated bounds coincide: every
    integer point of the region has that value there."""
    var box = propagate_bounds(reg.assume, m)
    var out = reg.copy()
    for k in range(_point_vars(reg, m)):
        if box.bounded[k] and box.lo[k] == box.hi[k] and _region_live(out, k):
            out = _region_subst(out, k, aff_const(m, box.lo[k]), out.depth)
    return out^


def _split_by_factor(reg: GuidedRegion, a: List[Int], top: Int) -> List[GuidedRegion]:
    """A partition of the region by the value of the affine form `a`, whose
    least value on the orthant is its constant (no negative coefficient):
    `a = k` for each `k` from that constant to `top`, by substituting a
    variable with a unit coefficient (or, lacking one, as two
    assumptions), and `a >= top + 1`. Every piece is marked split. Empty
    when `a` is constant or may be negative."""
    var out = List[GuidedRegion]()
    var lo = _orthant_floor(a)
    if lo <= -(1 << 40) or aff_is_const(a):
        return out^
    var m = len(a) - 1
    var marked = reg.copy()
    marked.split = True
    for k in range(lo, top + 1):
        var g = a.copy()
        g[0] -= k
        var v = -1
        for j in range(m):
            if g[j + 1] == 1 or g[j + 1] == -1:
                v = j
                break
        if v < 0:
            out.append(_with_assumptions(marked, List[List[Int]]([g.copy(), aff_scale(g, -1)])))
            continue
        # g = c n_v + R = 0, so n_v = -c R, which must be >= 0
        var c = g[v + 1]
        var r = g.copy()
        r[v + 1] = 0
        var repl = aff_scale(r, -c)
        var piece = _region_subst(marked, v, repl, marked.depth)
        out.append(_with_assumptions(piece, List[List[Int]]([repl.copy()])))
    var rest = a.copy()
    rest[0] -= top + 1
    out.append(_with_assumptions(marked, List[List[Int]]([rest^])))
    return out^


def _affine_pisot_form(counts: List[List[Int]], s: Int) raises -> List[Int]:
    """Lemma P1's form `f = a b + c` as an affine form, when its quadratic
    part vanishes (as with `Delta` fixed); else empty."""
    var q = _pisot_quadratic(counts, s)
    var f = _q_lin(_aff_times(q[0], q[1]), _qa(q[2]), 1)
    var m = len(counts[0]) - 1
    var w = m + 1
    for i in range(1, w):
        for j in range(i, w):
            if f[i * w + j] != 0:
                return List[Int]()
    var out = List[Int]()
    for k in range(w):
        out.append(f[k])
    return out^


def z_floor_forms(counts: List[List[Int]], s: Int, z_floor: Int) -> List[List[Int]]:
    """Lemma P1 on `Z_2 >= z_floor` as linear forms: `a - z_floor`,
    `b - b_lo` and `-1 - G_3`, the McCormick forms of `f = a b + c`
    (`a = Z_2`, `b = |Delta| - 1`) at the corner `(z_floor, b_lo)`, `b_lo`
    the least value of `b` on the orthant. On the quadrant `f >= G_3`, so
    every PIP member (`f <= -1`) with `Z_2 >= z_floor` satisfies all three.
    Empty if `b` is unbounded below on the orthant."""
    var b_lo = _orthant_floor(_pisot_quadratic(counts, s)[1])
    if b_lo <= -(1 << 40):
        return List[List[Int]]()
    var g = mccormick_forms(counts, s, z_floor, b_lo)
    g[2] = _minus_one_minus(g[2])
    return g^


def _minus_one_minus(f: List[Int]) -> List[Int]:
    var g = aff_scale(f, -1)
    g[0] -= 1
    return g^


def _mccormick_carve(pat: RunPattern, s: Int, reg: GuidedRegion, ns: List[Int], mut stack: List[GuidedRegion], verbose: Bool = False, index: Int = 0) raises -> Bool:
    """At a non-PIP point, cut the McCormick quadrant of Lemma P1 it opens
    (checked by `mccormick_cut`) and push the rest of the region. False if
    Lemma P1's form is negative at the point."""
    var pc = pisot_carve_forms(pattern_counts(pat, reg.subst), s, ns)
    if len(pc) == 0:
        return False
    var inside = _with_assumptions(reg, pc)
    if not mccormick_cut(pattern_counts(pat, inside.subst), s, pc, Prover(inside.assume.copy())):
        raise Error("a McCormick-carved region is not cut")
    if verbose:
        _trace(index, "McCormick cut", ns, reg.subst, pc, 1, len(pc))
    _push_complements(stack, reg, pc)
    return True


def _new_forms(forms: List[List[Int]], reg: GuidedRegion) -> List[List[Int]]:
    """The forms the region does not already imply (by the prover): an
    implied form carves nothing, and its complement is empty."""
    var prover = Prover(reg.assume.copy())
    var out = List[List[Int]]()
    for k in range(len(forms)):
        if not prover.nonneg(forms[k]):
            out.append(forms[k].copy())
    return out^


def _certify_at(pat: RunPattern, fam: ConeFamily, reg: GuidedRegion, ns: List[Int], mut stack: List[GuidedRegion], mut out: ShapeCover, verbose: Bool, deep: Bool = False) raises -> Bool:
    """Certify part of `reg` from the point `ns`: an exact line-mode path,
    lifted (affine, then over polynomials), else a Lemma X closure, lifted
    likewise. On success the carved piece is verified, counted, and its
    complements pushed. `deep`: the q-lift's lazy point-path search runs
    to `LAZY_PATH_NODES` nodes with no path cap (`_lazy_lift`)."""
    var point = pattern_family(pat, point_subst(reg.subst, ns))
    var done = False
    # an exact line-mode path at the point
    var wp = _point_line_search(point, reg)
    if wp.found:
        var lr = lift_path(fam, point, ns, O, Y, wp.steps, OFFSET_BOUND, Y, Z)
        if verbose and not (lr.ok and lr.a == lr.b):
            print("  lift failed (path):", lr.why if not lr.ok else "ends off the diagonal")
        if lr.ok and lr.a == lr.b:
            var ineqs = lr.ineqs.copy()
            for i in range(3):
                if not _is_zero_form(lr.gamma[i]):
                    ineqs.append(lr.gamma[i].copy())
                    ineqs.append(aff_scale(lr.gamma[i], -1))
            ineqs = _new_forms(_carving_forms(ineqs), reg)
            if not _satisfies(ineqs, ns):
                raise Error("a lifted path does not hold at its own base point")
            var inside = _with_assumptions(reg, ineqs)
            if verbose:
                _trace(out.regions, "path", ns, reg.subst, ineqs, 1, len(ineqs))
            if not verify_witness_line(fam, O, Y, lr.steps, Prover(inside.assume.copy())):
                raise Error("a carved region does not verify its lifted path")
            out.certified += 1
            out.line_certified += 1
            out.max_level = max(out.max_level, len(lr.steps))
            _push_complements(stack, reg, ineqs)
            done = True
        else:
            # lift again with candidates built from the point's own step,
            # over polynomials (the region's M gamma may be quadratic)
            var levels = _poly_carve(fam, point, ns, wp.steps, reg, stack, verbose, out.regions, deep)
            if levels > 0:
                out.certified += 1
                out.line_certified += 1
                out.poly_certified += 1
                out.max_level = max(out.max_level, levels)
                done = True
    if not done:
        var cp = search_crossing(point, O, Y, OFFSET_BOUND, MAX_LEVEL - 2, Y, Z, Y, Z)
        if cp.found:
            var lr = lift_path(fam, point, ns, O, Y, cp.steps, OFFSET_BOUND, Y, Z)
            if verbose and not lr.ok:
                print("  lift failed (crossing):", lr.why)
            var ineqs = lr.ineqs.copy()
            if lr.ok and crossing_conditions(fam, lr.a, lr.b, lr.gamma, Y, Z, cp.close[0], ns, ineqs):
                ineqs = _new_forms(_carving_forms(ineqs), reg)
                if not _satisfies(ineqs, ns):
                    raise Error("a lifted crossing does not hold at its own base point")
                var inside = _with_assumptions(reg, ineqs)
                if verbose:
                    _trace(out.regions, "crossing", ns, reg.subst, ineqs, 1, len(ineqs))
                if not verify_crossing(fam, O, Y, lr.steps, cp.close[0], Y, Z, Prover(inside.assume.copy())):
                    raise Error("a carved region does not verify its lifted crossing")
                out.certified += 1
                out.crossing_certified += 1
                out.max_level = max(out.max_level, len(lr.steps) + 2)
                _push_complements(stack, reg, ineqs)
                done = True
            else:
                var levels = _poly_crossing_carve(fam, point, ns, cp.steps, cp.close[0], reg, stack, verbose, out.regions)
                if levels > 0:
                    out.certified += 1
                    out.crossing_certified += 1
                    out.poly_certified += 1
                    out.max_level = max(out.max_level, levels)
                    done = True
    return done


def _member_points_in(pat: RunPattern, reg: GuidedRegion, mut screen: CubicScreen, skip: List[Int], count: Int) raises -> List[List[Int]]:
    """Up to `count` member points of the region other than `skip`, from the
    base-point candidates (each clamped and walked into the region)."""
    var out = List[List[Int]]()
    var m = len(reg.subst[0]) - 1
    var box = propagate_bounds(reg.assume, m)
    if box.empty:
        return out^
    var tries = _base_candidates(m)
    for t in range(len(tries)):
        if len(out) >= count:
            break
        var ns = _walk_in(reg, tries[t], box)
        if len(ns) == 0 or ns == skip:
            continue
        var seen = False
        for k in range(len(out)):
            if out[k] == ns:
                seen = True
        if seen or not _member_at(pat, reg.subst, ns, screen):
            continue
        out.append(ns^)
    return out^


def _lazy_lift(fam: ConeFamily, point: ConeFamily, ns: List[Int], reg: GuidedRegion, probes: List[List[Int]], deep: Bool) raises -> PolyLift:
    """q-lift: the other point paths, lifted as they are enumerated
    (`PointPaths`, bound `Q_OFFSET_BOUND` off the line, the line offset
    free, at most `LIFT_PATHS` paths and `LIFT_PATH_NODES` nodes, or if
    `deep` `LAZY_PATH_NODES` nodes and no path cap). The first path
    `solve_lift` solves is returned; else each path's candidate-tree lift
    (`lift_path_poly`) ending on the diagonal competes by `lift_key`, and
    the search stops at the first whole-region lift (`whole_region_lift`).
    Only a choice: the caller carves by the lift's forms and re-verifies
    it."""
    var it = PointPaths(O, Y, Q_OFFSET_BOUND, MAX_LEVEL, Y, Z, LAZY_PATH_NODES if deep else LIFT_PATH_NODES, LINE_CAP)
    var best = PolyLift()
    best.why = "no point path lifts"
    var key = 0
    var paths = 0
    while (deep or paths < LIFT_PATHS) and it.next(point):
        paths += 1
        var alt = solve_lift(fam, point, ns, O, Y, it.path, reg.lift)
        if alt.ok:
            return alt^
        alt = lift_path_poly(fam, point, ns, O, Y, it.path, Y, Z, reg.lift, probes)
        if not alt.ok or alt.a != alt.b:
            continue
        if whole_region_lift(alt, probes, reg.lift):
            return alt^
        var k = lift_key(alt, probes, reg.lift)
        if not best.ok or k > key:
            key = k
            best = alt^
    if not best.ok:
        best.why = "none of " + String(paths) + " point paths lifts (" + String(it.nodes) + " nodes)"
    return best^


def _poly_carve(fam: ConeFamily, point: ConeFamily, ns: List[Int], steps: List[WitnessStep], reg: GuidedRegion, mut stack: List[GuidedRegion], verbose: Bool, index: Int, deep: Bool = False) raises -> Int:
    """Lift a point path over polynomials (`psc.poly_line`), carve the region
    by its affine forms, re-verify the path on the carved region with
    `verify_witness_poly` under the region's inequalities (a failure
    raises), and push the rest. The path's length, or 0 if it does not lift
    or its end offset keeps a term of degree >= 2. With a product lift the
    candidate tree's lift competes with the solved one by `lift_key` on the
    region's probe points (`solve_lift` sets its free unknowns to 0, which
    can pin a free line parameter to its value at the point and carve a
    slice), and when neither solves, the other point paths are lifted as
    they are enumerated (`_lazy_lift`)."""
    var lr = solve_lift(fam, point, ns, O, Y, steps, reg.lift)
    var probes = List[List[Int]]()
    if reg.lift.on():
        probes = probe_points(ns, reg.lift, reg.assume)
        var lp = lift_path_poly(fam, point, ns, O, Y, steps, Y, Z, reg.lift, probes)
        if lp.ok and lp.a == lp.b and (not lr.ok or lift_key(lp, probes, reg.lift) > lift_key(lr, probes, reg.lift)):
            lr = lp^
    if not lr.ok and reg.lift.on():
        lr = _lazy_lift(fam, point, ns, reg, probes, deep)
        if verbose and not lr.ok:
            print("  lazy lift failed:", lr.why)
    elif not lr.ok:
        # other point paths, other segments: the first that solves
        var paths = enumerate_point_paths(point, O, Y, OFFSET_BOUND, MAX_LEVEL, Y, Z, LIFT_PATHS, LIFT_PATH_NODES)
        var tried = 0
        for k in range(len(paths)):
            tried += 1
            var alt = solve_lift(fam, point, ns, O, Y, paths[k], reg.lift)
            if alt.ok:
                lr = alt^
                break
        if verbose and not lr.ok:
            print("  linear lift failed on", tried, "point paths:", lr.why)
        if not lr.ok:
            lr = lift_path_poly(fam, point, ns, O, Y, steps, Y, Z)
    if not lr.ok or lr.a != lr.b:
        if verbose:
            print("  polynomial lift failed:", lr.why if not lr.ok else "ends off the diagonal")
        return 0
    var ineqs = lr.ineqs.copy()
    for i in range(3):
        if reg.lift.on():
            ineqs.append(lift_affine(reg.lift, lr.gamma[i]))
            ineqs.append(aff_scale(ineqs[len(ineqs) - 1], -1))
            continue
        if not poly_is_zero(poly_higher(lr.gamma[i])):
            if verbose:
                print("  polynomial lift failed: the end offset is not affine; coordinate", i, "has higher part", poly_key(poly_higher(lr.gamma[i])))
            return 0
        var g = poly_affine_part(lr.gamma[i], fam.m)
        if not _is_zero_form(g):
            ineqs.append(g.copy())
            ineqs.append(aff_scale(g, -1))
    ineqs = _new_forms(_carving_forms(ineqs), reg)
    if not _satisfies(ineqs, ns):
        raise Error("a polynomial lift does not hold at its own base point")
    var inside = _with_assumptions(reg, ineqs)
    if verbose:
        _trace(index, "polynomial path", ns, reg.subst, ineqs, 1, len(ineqs))
    if not verify_witness_poly(fam, O, Y, lr.steps, Prover(inside.assume.copy()), reg.lift):
        raise Error("a carved region does not verify its polynomial path")
    # an independent check in plain arithmetic: the path at the base point
    if not verify_witness_line(point, O, Y, steps_at(lr.steps, ns)):
        raise Error("a polynomial path fails at its own base point")
    _push_complements(stack, reg, ineqs)
    return len(lr.steps)


def _poly_crossing_carve(fam: ConeFamily, point: ConeFamily, ns: List[Int], steps: List[WitnessStep], cl: CrossingClose, reg: GuidedRegion, mut stack: List[GuidedRegion], verbose: Bool, index: Int) raises -> Int:
    """`_poly_carve` for a Lemma X closure: solve the point path's offsets so
    the closure's third coordinate offset vanishes on the region
    (`solve_crossing_lift`), carve, re-verify with `verify_crossing_poly`
    under the region's inequalities and check the closure in plain
    arithmetic at the base point (each failure raises). The level reached,
    or 0."""
    var lr = solve_crossing_lift(fam, point, ns, O, Y, steps, cl, Y, Z, reg.lift)
    if not lr.ok:
        if verbose:
            print("  linear crossing lift failed:", lr.why)
        return 0
    var ineqs = _new_forms(_carving_forms(lr.ineqs), reg)
    if not _satisfies(ineqs, ns):
        raise Error("a solved crossing does not hold at its own base point")
    var inside = _with_assumptions(reg, ineqs)
    if verbose:
        _trace(index, "polynomial crossing", ns, reg.subst, ineqs, 1, len(ineqs))
    if not verify_crossing_poly(fam, O, Y, lr.steps, cl, Y, Z, Prover(inside.assume.copy()), reg.lift):
        raise Error("a carved region does not verify its polynomial crossing")
    if not verify_crossing(point, O, Y, steps_at(lr.steps, ns), cl, Y, Z):
        raise Error("a polynomial crossing fails at its own base point")
    _push_complements(stack, reg, ineqs)
    return len(lr.steps) + 2


def _push_complements(mut stack: List[GuidedRegion], reg: GuidedRegion, forms: List[List[Int]]):
    """The rest of `reg` once the region where every form is >= 0 is settled:
    for each j, the forms before j hold and form j is <= -1. A partition;
    pieces shown empty are not pushed."""
    var m = len(reg.subst[0]) - 1
    for j in range(len(forms)):
        var more = List[List[Int]]()
        for i in range(j):
            more.append(forms[i].copy())
        var neg = aff_scale(forms[j], -1)
        neg[0] -= 1
        more.append(neg^)
        var piece = _with_assumptions(reg, more)
        if not _assume_empty(piece.assume, m):
            stack.append(piece^)


def _peel(mut stack: List[GuidedRegion], reg: GuidedRegion, m: Int):
    """Partition the region one level deeper: by every value of a live
    variable whose propagated domain is small (at most `VALUE_SPLIT_MAX`
    values; every integer point of the region lies in it), else by
    `n = 0 | n >= 1` on the live variable occurring most often."""
    var box = propagate_bounds(reg.assume, m)
    for k in range(_point_vars(reg, m)):
        if box.bounded[k] and box.hi[k] > box.lo[k] and box.hi[k] - box.lo[k] < VALUE_SPLIT_MAX and _region_live(reg, k):
            stack.extend(_value_pieces(reg, k, box.lo[k], box.hi[k], m))
            return
    var pick = _peel_variable_in(reg, _point_vars(reg, m))
    var shift = aff_const(m, 1)
    shift[pick + 1] = 1
    stack.append(_region_subst(reg, pick, aff_const(m, 0), reg.depth + 1))
    stack.append(_region_subst(reg, pick, shift, reg.depth + 1))


def _peel_variable_in(reg: GuidedRegion, m: Int) -> Int:
    """The live variable occurring most often in the slots and assumptions."""
    var best = -1
    var best_count = -1
    for k in range(m):
        var count = 0
        for i in range(len(reg.subst)):
            if reg.subst[i][k + 1] != 0:
                count += 1
        for i in range(len(reg.assume)):
            if reg.assume[i][k + 1] != 0:
                count += 1
        if count > best_count:
            best = k
            best_count = count
    return best


def _peel_variable(reg: List[List[Int]], m: Int, ns: List[Int]) -> Int:
    """The live variable to peel: the one with the most occurrences in the
    slots (the run lengths it drives), first on ties."""
    var best = -1
    var best_count = -1
    for k in range(m):
        var count = 0
        for i in range(len(reg)):
            if reg[i][k + 1] != 0:
                count += 1
        if count > best_count:
            best = k
            best_count = count
    return best


def _form_str(f: List[Int]) -> String:
    var out = String(f[0])
    for k in range(1, len(f)):
        if f[k] != 0:
            out += (" +" if f[k] > 0 else " ") + String(f[k]) + "n" + String(k - 1)
    return out


def _trace(index: Int, kind: String, ns: List[Int], reg: List[List[Int]], ineqs: List[List[Int]], inside: Int, outside: Int):
    var line = "  #" + String(index) + " " + kind + " at"
    for k in range(len(ns)):
        line += " " + String(ns[k])
    line += " | slots"
    for k in range(len(reg)):
        line += " [" + _form_str(reg[k]) + "]"
    line += " | carve by"
    for k in range(len(ineqs)):
        if not aff_nonneg(ineqs[k]):
            line += " {" + _form_str(ineqs[k]) + " >= 0}"
    line += " -> in " + String(inside) + ", out " + String(outside)
    print(line, flush=True)


def _is_zero_form(f: List[Int]) -> Bool:
    for k in range(len(f)):
        if f[k] != 0:
            return False
    return True


def suffix_roots(s: Int, delta: Int) -> List[RunPattern]:
    """The run-tree roots of a delta cell with the longer word's suffix made
    explicit. s = +1: w_1 = u y^Delta (Lemma Phi5). s = -1: w_2 = v x with
    |x| = 2 - Delta and at least two z in x (Lemma Phi5'). A non-crossing
    member lies under exactly one root; a crossing one is Lemma Phi2's."""
    var out = List[RunPattern]()
    if s == 1:
        var suf = List[Int]()
        for _ in range(delta):
            suf.append(Y)
        out.append(RunPattern(List[Int]([Z]), True, List[Int](), True, suf^, List[Int]()))
        return out^
    var words = _words(2 - delta)
    for k in range(len(words)):
        if len(words[k]) != 2 - delta:
            continue
        var zs = 0
        for j in range(len(words[k])):
            zs += 1 if words[k][j] == Z else 0
        if zs >= 2:
            out.append(RunPattern(List[Int]([Z]), True, List[Int](), True, List[Int](), words[k].copy()))
    return out^


def _journal_load(path: String) raises -> Dict[String, String]:
    var out = Dict[String, String]()
    if path.byte_length() == 0 or not exists(path):
        return out^
    with open(path, "r") as f:
        var text = f.read()
        for line in text.split("\n"):
            var parts = String(line).split(" => ")
            if len(parts) == 2:
                out[String(parts[0])] = String(parts[1])
    return out^


def _journal_add(path: String, key: String, verdict: String) raises:
    if path.byte_length() == 0:
        return
    with open(path, "a") as f:
        f.write(key + " => " + verdict + "\n")


def run_tree_guided(s: Int, delta: Int, max_runs: Int, budget: Int, verbose: Bool = False, tail: Bool = False, xblock_root: Bool = False, journal: String = "", z_floor: Int = 0) raises -> List[RunTreeLeaf]:
    """The run tree of one delta cell under its suffix roots, each pattern
    covered by certificate-guided partition. With `tail` (s = +1 only), the
    cell is `Delta >= delta`: w_1 closes with y^(delta + e).

    With a `journal` path, each pattern's verdict is appended to it as it is
    decided, and verdicts already there are replayed instead of recomputed,
    so a run interrupted by a restart resumes. A replayed verdict is not
    re-verified: a run that a proof cites is one without a journal.

    With `z_floor > 0` the claim is the members with `Z_2 >= z_floor`, Lemma
    P1 entering linearly (`cover_pattern_guided`)."""
    var out = List[RunTreeLeaf]()
    var done = _journal_load(journal)
    var stack = List[RunPattern]()
    if s == -1 and (tail or xblock_root):
        # w_2 = v x with x the last 2 - Delta letters, at least two z
        var root = RunPattern(List[Int]([Z]), True, List[Int](), True)
        root.xblock = True
        root.xopen = True
        root.xend = True  # the witnesses read x from its end (A1' note 3l)
        stack.append(root^)
    elif tail:
        var root = RunPattern(List[Int]([Z]), True, List[Int](), True)
        root.tail_run1 = delta
        stack.append(root^)
    else:
        stack = suffix_roots(s, delta)
    while len(stack) > 0:
        var pat = stack.pop()
        var key = String(pat) + (" (Z_2 >= " + String(z_floor) + ")" if z_floor > 0 else "")
        if key in done:
            var verdict = done[key]
            if verbose:
                print("    replay ", pat, " ", verdict, flush=True)
            if verdict == "closed":
                out.append(RunTreeLeaf(pat.copy(), True, 0, 0, 0))
                continue
            if verdict == "open":
                out.append(RunTreeLeaf(pat.copy(), False, 1, 0, 0))
                continue
            var replayed = refine_pattern(pat)
            for k in range(len(replayed)):
                stack.append(replayed[k].copy())
            continue
        var c = cover_pattern_guided(pat, s, delta, budget, tail, z_floor=z_floor)
        if c.open == 0:
            _journal_add(journal, key, "closed")
            if verbose:
                print("    closed ", pat, "  regions", c.regions, " certified", c.certified, " (line", c.line_certified, ", crossing", c.crossing_certified, ") cut", c.cut, " not member", c.not_member, flush=True)
            out.append(RunTreeLeaf(pat.copy(), True, 0, c.certified, c.cut))
            continue
        var kids = refine_pattern(pat)
        if pat.runs() >= max_runs or len(kids) == 0:
            _journal_add(journal, key, "open")
            if verbose:
                print("    OPEN   ", pat, "  regions", c.regions, " open", c.open, " budget" if c.budget_exhausted else "", flush=True)
            out.append(RunTreeLeaf(pat.copy(), False, c.open, c.certified, c.cut))
            continue
        _journal_add(journal, key, "refine")
        if verbose:
            print("    refine ", pat, "  (open", c.open, ")", flush=True)
        for k in range(len(kids)):
            stack.append(kids[k].copy())
    return out^


def _alternating_runs(first: Int, n: Int) -> List[Int]:
    var out = List[Int]()
    var c = first
    for _ in range(n):
        out.append(c)
        c = Z if c == Y else Y
    return out^


struct ZCapCover(Copyable, Movable):
    var patterns: Int
    var closed: Int
    var regions: Int
    var open_patterns: List[String]

    def __init__(out self):
        self.patterns = 0
        self.closed = 0
        self.regions = 0
        self.open_patterns = List[String]()


def zcap_cover(s: Int, cap: Int, budget: Int, verbose: Bool = False, journal: String = "") raises -> ZCapCover:
    """Theorem K's members with `Z_2 <= cap`, for every `Delta` of the sign's
    tail (`s = +1`: `Delta = 1 + e`, the core `u` of Lemma Φ5 before
    `y^Delta`; `s = −1`: `Delta = −e`), by finitely many fully revealed run
    patterns: `w_1` (or `u`) beginning with `z` with at most `Z_1 = Z_2 + s`
    z-runs, `w_2` with at most `cap`. Each pattern is covered with the region
    split by the value of `Z_2` and the pieces above `cap` left out
    (`z_cap`). Runs alternate, so every pair lies under exactly one
    pattern. With a `journal`, verdicts are appended and replayed as in
    `run_tree_guided` (a run a proof cites is one without a journal)."""
    var out = ZCapCover()
    var done = _journal_load(journal)
    var z1_max = cap + s
    var l1s = List[List[Int]]()
    for n in range(1, 2 * z1_max + 1):
        l1s.append(_alternating_runs(Z, n))
    var l2s = List[List[Int]]()
    l2s.append(List[Int]())
    for first in [Y, Z]:
        for n in range(1, 2 * cap + 2):
            var w = _alternating_runs(first, n)
            var zr = 0
            for k in range(len(w)):
                if w[k] == Z:
                    zr += 1
            if zr <= cap:
                l2s.append(w^)
    for i in range(len(l1s)):
        for j in range(len(l2s)):
            var pat = RunPattern(l1s[i].copy(), False, l2s[j].copy(), False)
            if s == 1:
                pat.tail_run1 = 1
            var key = String(pat) + " (Z_2 <= " + String(cap) + ")"
            out.patterns += 1
            if key in done:
                if done[key] == "closed":
                    out.closed += 1
                else:
                    out.open_patterns.append(String(pat))
                continue
            var c = cover_pattern_guided(pat, s, 1 if s == 1 else 0, budget, True, False, True, 0, cap, True)
            out.regions += c.regions
            if c.open == 0 and not c.budget_exhausted:
                out.closed += 1
                _journal_add(journal, key, "closed")
            else:
                _journal_add(journal, key, "open")
                out.open_patterns.append(String(pat))
                if verbose:
                    print("    OPEN   ", pat, "  regions", c.regions, " open", c.open, " budget" if c.budget_exhausted else "", flush=True)
    return out^
