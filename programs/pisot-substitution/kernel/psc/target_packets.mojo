"""Realizable, occurrence-sensitive BPA diagnostics for issue #9.

Only descendants in one actual irreducible child are interned. Descendants
in different balanced children are recorded as splits, never glued into a
letter-pair state. Their disjoint balanced spans remain disjoint on inflation.
The graph is a finite local-address quotient, not a universal depth theorem.
"""

from psc.affine_ancestry_trace import (
    AffineTraceTables, build_affine_trace_tables, _incidence_action, _prefix_parikh,
)
from psc.bpa import apply_substitution, coincidence_boundaries, decompose, normalise, require_complete, seed_states
from psc.hierarchy_offset import prefix_difference3
from psc.renewal import Diff3
from psc.words import Pair, is_balanced
from substitution_dynamics.automaton import Automaton, sccs, has_cycle
from substitution_dynamics.balanced_pairs import sync_after
from psc.exact import Q, q_int, require_q
from finite_linear_algebra.qlinalg import matvec


struct PacketKey(ImplicitlyCopyable, Copyable, Movable, Equatable, Hashable):
    var state_id: Int
    var sign: Int
    var top: Int
    var bottom: Int
    var factor_edge: Int

    def __init__(out self, state_id: Int, sign: Int, top: Int, bottom: Int, factor_edge: Int):
        self.state_id = state_id
        self.sign = sign
        self.top = top
        self.bottom = bottom
        self.factor_edge = factor_edge


struct OccurrenceAddress(Copyable, Movable, Equatable):
    var source_occurrence: Int
    var within_image: Int
    var global_position: Int
    var local_position: Int

    def __init__(out self, source: Int, digit: Int, global_position: Int, local: Int):
        self.source_occurrence = source
        self.within_image = digit
        self.global_position = global_position
        self.local_position = local


struct FactorEdge(Copyable, Movable, Equatable):
    var parent: Int
    var ordinal: Int
    var child: Int
    var sign: Int
    var start: Int
    var end: Int
    var total: Int

    def __init__(out self, parent: Int, ordinal: Int, child: Int, sign: Int, start: Int, end: Int, total: Int):
        self.parent = parent
        self.ordinal = ordinal
        self.child = child
        self.sign = sign
        self.start = start
        self.end = end
        self.total = total


struct Expansion(Copyable, Movable):
    var top: List[Int]
    var bottom: List[Int]
    var top_starts: List[Int]
    var bottom_starts: List[Int]
    var child_at: List[Int]
    var factors: List[Int]

    def __init__(out self, var top: List[Int], var bottom: List[Int], var ts: List[Int], var bs: List[Int], var child_at: List[Int], var factors: List[Int]):
        self.top = top^
        self.bottom = bottom^
        self.top_starts = ts^
        self.bottom_starts = bs^
        self.child_at = child_at^
        self.factors = factors^


struct TargetPacket(Copyable, Movable):
    var key: PacketKey
    var top_address: OccurrenceAddress
    var bottom_address: OccurrenceAddress
    var top_letter: Int
    var bottom_letter: Int
    var residual: Diff3
    var interior: Bool
    var success: Bool

    def __init__(out self, key: PacketKey, top: OccurrenceAddress, bottom: OccurrenceAddress, a: Int, b: Int, residual: Diff3, interior: Bool, success: Bool):
        self.key = key.copy()
        self.top_address = top.copy()
        self.bottom_address = bottom.copy()
        self.top_letter = a
        self.bottom_letter = b
        self.residual = residual.copy()
        self.interior = interior
        self.success = success


struct PacketEdge(Copyable, Movable):
    var source: Int
    var destination: Int
    var top_digit: Int
    var bottom_digit: Int
    var forcing: Diff3

    def __init__(out self, source: Int, destination: Int, top_digit: Int, bottom_digit: Int, forcing: Diff3):
        self.source = source
        self.destination = destination
        self.top_digit = top_digit
        self.bottom_digit = bottom_digit
        self.forcing = forcing.copy()


struct PacketGraph(Copyable, Movable):
    var bpa: Automaton
    var tables: AffineTraceTables
    var expansions: List[Expansion]
    var top_prefixes: List[List[Int]]
    var bottom_prefixes: List[List[Int]]
    var factors: List[FactorEdge]
    var packets: List[TargetPacket]
    var edges: List[PacketEdge]
    var adj: List[List[Int]]
    var roots: List[List[Int]]
    var birth: List[Int]
    var split_count: Int
    var target: Int
    var synchronize: Bool

    def __init__(out self, bpa: Automaton, tables: AffineTraceTables, target: Int, synchronize: Bool):
        self.bpa = bpa.copy()
        self.tables = tables.copy()
        self.expansions = List[Expansion]()
        self.top_prefixes = List[List[Int]]()
        self.bottom_prefixes = List[List[Int]]()
        self.factors = List[FactorEdge]()
        self.packets = List[TargetPacket]()
        self.edges = List[PacketEdge]()
        self.adj = List[List[Int]]()
        self.roots = List[List[Int]]()
        self.birth = List[Int]()
        self.split_count = 0
        self.target = target
        self.synchronize = synchronize


def _oriented(a: Automaton, state: Int, sign: Int) raises -> Pair:
    if state < 0 or state >= a.size() or (sign != 1 and sign != -1):
        raise Error("invalid packet BPA ID/orientation")
    if sign == 1:
        return a.states[state].copy()
    return Pair(a.states[state].v, a.states[state].u)


def _starts(sigma: List[List[Int]], word: List[Int]) -> List[Int]:
    var out: List[Int] = [0]
    var cursor = 0
    for i in range(len(word)):
        cursor += len(sigma[word[i]])
        out.append(cursor)
    return out^


def _prefix_coordinates(word: List[Int]) -> List[Int]:
    """One streaming Parikh pass per word, flat fixed-three coordinates."""
    var out: List[Int] = [0, 0, 0]
    var x = 0
    var y = 0
    var z = 0
    for i in range(len(word)):
        if word[i] == 0:
            x += 1
        elif word[i] == 1:
            y += 1
        else:
            z += 1
        out.append(x)
        out.append(y)
        out.append(z)
    return out^


def _local_residual(g: PacketGraph, state: Int, sign: Int, top: Int, bottom: Int) -> Diff3:
    var ti = 3 * top
    var bi = 3 * bottom
    if sign == 1:
        return Diff3(g.top_prefixes[state][ti] - g.bottom_prefixes[state][bi], g.top_prefixes[state][ti + 1] - g.bottom_prefixes[state][bi + 1], g.top_prefixes[state][ti + 2] - g.bottom_prefixes[state][bi + 2])
    return Diff3(g.bottom_prefixes[state][ti] - g.top_prefixes[state][bi], g.bottom_prefixes[state][ti + 1] - g.top_prefixes[state][bi + 1], g.bottom_prefixes[state][ti + 2] - g.top_prefixes[state][bi + 2])


def _letter_at(a: Automaton, state: Int, sign: Int, side: Int, position: Int) -> Int:
    if (sign == 1 and side == 0) or (sign == -1 and side == 1):
        return a.states[state].u[position]
    return a.states[state].v[position]


def _prepare(mut g: PacketGraph) raises:
    var index = Dict[String, Int]()
    for s in range(g.bpa.size()):
        ref p = g.bpa.states[s]
        if not is_balanced(p) or p != normalise(p) or len(coincidence_boundaries(p.u, p.v)) != 2 or p.key() in index:
            raise Error("packet source is not a unique normalized irreducible BPA state")
        if p.is_coincidence() and len(g.bpa.adj[s]) != 0:
            raise Error("actual BPA coincidences must remain terminal")
        index[g.bpa.states[s].key()] = s
    var reached = List[Bool](length=g.bpa.size(), fill=False)
    var queue = List[Int]()
    var seeds = seed_states()
    for i in range(len(seeds)):
        var key = normalise(seeds[i]).key()
        if key not in index:
            raise Error("packet BPA omits an actual swap seed")
        queue.append(index[key])
        reached[index[key]] = True
    var head = 0
    while head < len(queue):
        var s = queue[head]
        head += 1
        for j in range(len(g.bpa.adj[s])):
            var child = g.bpa.adj[s][j]
            if child < 0 or child >= g.bpa.size():
                raise Error("invalid BPA child index")
            if not reached[child]:
                reached[child] = True
                queue.append(child)
    if len(queue) != g.bpa.size():
        raise Error("packet BPA contains states unreachable from actual swap seeds")
    for s in range(g.bpa.size()):
        var parent = g.bpa.states[s].copy()
        g.top_prefixes.append(_prefix_coordinates(parent.u))
        g.bottom_prefixes.append(_prefix_coordinates(parent.v))
        var top = apply_substitution(g.tables.sigma, parent.u)
        var bottom = apply_substitution(g.tables.sigma, parent.v)
        var cuts = coincidence_boundaries(top, bottom)
        var cs = decompose(top, bottom)
        var fs = List[Int]()
        var at = List[Int](length=len(top), fill=-1)
        # Coincidences are terminal, exactly as in the canonical BPA.
        if not parent.is_coincidence():
            if len(cuts) != len(cs) + 1 or len(g.bpa.adj[s]) != len(cs):
                raise Error("zero-return cuts disagree with ordered factorization")
            for j in range(len(cs)):
                var child = normalise(cs[j])
                if child.key() not in index or g.bpa.adj[s][j] != index[child.key()]:
                    raise Error("actual ordered factorization disagrees with BPA adjacency")
                var sign = 1 if child == cs[j] else -1
                var fid = len(g.factors)
                g.factors.append(FactorEdge(s, j, index[child.key()], sign, cuts[j], cuts[j + 1], len(top)))
                fs.append(fid)
                for k in range(cuts[j], cuts[j + 1]):
                    at[k] = fid
        var ts = _starts(g.tables.sigma, parent.u)
        var bs = _starts(g.tables.sigma, parent.v)
        g.expansions.append(Expansion(top.copy(), bottom.copy(), ts.copy(), bs.copy(), at.copy(), fs.copy()))
        g.expansions.append(Expansion(bottom^, top^, bs^, ts^, at^, fs^))


def make_root(g: PacketGraph, state: Int, top: Int, bottom: Int) raises -> TargetPacket:
    if state < 0 or state >= g.bpa.size():
        raise Error("root state lies outside actual BPA")
    if top < 0 or top >= g.bpa.states[state].length() or bottom < 0 or bottom >= g.bpa.states[state].length():
        raise Error("root occurrence lies outside actual BPA word")
    var r = _local_residual(g, state, 1, top, bottom)
    return TargetPacket(PacketKey(state, 1, top, bottom, -1), OccurrenceAddress(top, -1, top, top), OccurrenceAddress(bottom, -1, bottom, bottom), g.bpa.states[state].u[top], g.bpa.states[state].v[bottom], r, False, False)


def descendant(g: PacketGraph, p: TargetPacket, td: Int, bd: Int) raises -> TargetPacket:
    """Actual child-local descendant; rejects a split, invalid address or terminal."""
    if p.key.state_id < 0 or p.key.state_id >= g.bpa.size() or (p.key.sign != 1 and p.key.sign != -1):
        raise Error("invalid packet BPA ID/orientation")
    if g.bpa.states[p.key.state_id].is_coincidence() or p.key.top < 0 or p.key.bottom < 0 or p.key.top >= g.bpa.states[p.key.state_id].length() or p.key.bottom >= g.bpa.states[p.key.state_id].length():
        raise Error("cannot expand terminal/invalid packet")
    var a = _letter_at(g.bpa, p.key.state_id, p.key.sign, 0, p.key.top)
    var b = _letter_at(g.bpa, p.key.state_id, p.key.sign, 1, p.key.bottom)
    if td < 0 or td >= len(g.tables.sigma[a]) or bd < 0 or bd >= len(g.tables.sigma[b]):
        raise Error("packet digit lies outside its source image")
    ref ex = g.expansions[2 * p.key.state_id + Int(p.key.sign == -1)]
    var ti = ex.top_starts[p.key.top] + td
    var bi = ex.bottom_starts[p.key.bottom] + bd
    var fid = ex.child_at[ti]
    if fid < 0 or ex.child_at[bi] != fid:
        raise Error("occurrence descendants split across actual BPA children")
    ref factor = g.factors[fid]
    var sign = p.key.sign * factor.sign
    var local_top = ti - factor.start
    var local_bottom = bi - factor.start
    var residual = _local_residual(g, factor.child, sign, local_top, local_bottom)
    var interior = ti == bi and ti == factor.start and factor.start > 0 and factor.start < factor.total
    var matches_target = ex.top[ti] == ex.bottom[bi] and (g.target == -1 or ex.top[ti] == g.target)
    if g.synchronize:
        var h: List[Int] = [g.tables.sigma[0][0], g.tables.sigma[1][0], g.tables.sigma[2][0]]
        matches_target = sync_after(h, ex.top[ti], ex.bottom[bi]) >= 0
    var success = interior and residual.x == 0 and residual.y == 0 and residual.z == 0 and matches_target
    return TargetPacket(PacketKey(factor.child, sign, local_top, local_bottom, fid), OccurrenceAddress(p.key.top, td, ti, local_top), OccurrenceAddress(p.key.bottom, bd, bi, local_bottom), ex.top[ti], ex.bottom[bi], Diff3(residual.x, residual.y, residual.z), interior, success)


def _forcing(g: PacketGraph, p: TargetPacket, td: Int, bd: Int) raises -> Diff3:
    var tp = _prefix_parikh(g.tables, p.top_letter, td)
    var bp = _prefix_parikh(g.tables, p.bottom_letter, bd)
    return Diff3(tp.x - bp.x, tp.y - bp.y, tp.z - bp.z)


def _intern(mut g: PacketGraph, mut index: Dict[PacketKey, Int], p: TargetPacket, cap: Int, birth: Int) raises -> Int:
    if p.key in index:
        if not same_packet(p, g.packets[index[p.key]]):
            raise Error("packet identity discarded occurrence/address information")
        return index[p.key]
    if len(g.packets) >= cap:
        raise Error("packet cap exhausted: diagnostic inconclusive")
    var id = len(g.packets)
    index[p.key] = id
    g.packets.append(p.copy())
    g.adj.append(List[Int]())
    g.birth.append(birth)
    return id


def build_packets(sigma: List[List[Int]], a: Automaton, packet_cap: Int = 200000, edge_cap: Int = 2000000, target: Int = -1, synchronize: Bool = False) raises -> PacketGraph:
    """All actual occurrence pairs in source words, then their factorized lifts.

    Roots are observed positions in the already-realized seed closure, not
    arbitrary letters or residuals. Incoming factor IDs remain part of identity.
    Caps raise before any SCC or depth verdict can be emitted.
    """
    require_complete(a)
    if a.alphabet != 3 or packet_cap <= 0 or edge_cap <= 0 or target < -1 or target > 2 or (synchronize and target != -1):
        raise Error("invalid target-packet input/configuration")
    var tables = build_affine_trace_tables(sigma)
    # Machine-integer local residuals are bounded here; cycle accumulation uses Q.
    for i in range(3):
        if len(sigma[i]) > 256:
            raise Error("image length exceeds diagnostic arithmetic budget (256)")
    for s in range(a.size()):
        if a.states[s].length() > 100000:
            raise Error("BPA word length exceeds diagnostic arithmetic budget (100000)")
    var g = PacketGraph(a, tables, target, synchronize)
    _prepare(g)
    var index = Dict[PacketKey, Int]()
    for s in range(a.size()):
        var roots = List[Int]()
        if not a.states[s].is_coincidence():
            for ti in range(a.states[s].length()):
                for bi in range(a.states[s].length()):
                    roots.append(_intern(g, index, make_root(g, s, ti, bi), packet_cap, -1))
        g.roots.append(roots^)
    var head = 0
    while head < len(g.packets):
        var p = g.packets[head].copy()
        if not p.success and not g.bpa.states[p.key.state_id].is_coincidence():
            var exid = 2 * p.key.state_id + Int(p.key.sign == -1)
            for td in range(len(sigma[p.top_letter])):
                for bd in range(len(sigma[p.bottom_letter])):
                    var ti = g.expansions[exid].top_starts[p.key.top] + td
                    var bi = g.expansions[exid].bottom_starts[p.key.bottom] + bd
                    if g.expansions[exid].child_at[ti] != g.expansions[exid].child_at[bi]:
                        g.split_count += 1
                        continue
                    if len(g.edges) >= edge_cap:
                        raise Error("packet edge cap exhausted: diagnostic inconclusive")
                    var next = descendant(g, p, td, bd)
                    var forcing = _forcing(g, p, td, bd)
                    var mr = _incidence_action(g.tables, p.residual)
                    if next.residual != Diff3(mr.x + forcing.x, mr.y + forcing.y, mr.z + forcing.z):
                        raise Error("actual packet violates the affine residual identity")
                    var eid = len(g.edges)
                    var dst = _intern(g, index, next, packet_cap, eid)
                    g.edges.append(PacketEdge(head, dst, td, bd, forcing))
                    g.adj[head].append(eid)
        head += 1
    return g^


def same_packet(a: TargetPacket, b: TargetPacket) -> Bool:
    return a.key == b.key and a.top_address == b.top_address and a.bottom_address == b.bottom_address and a.top_letter == b.top_letter and a.bottom_letter == b.bottom_letter and a.residual == b.residual and a.interior == b.interior and a.success == b.success


def verify_packet(g: PacketGraph, p: TargetPacket) raises -> Bool:
    """Replay from literal substitution words, independently of expansion caches."""
    if p.key.state_id < 0 or p.key.state_id >= g.bpa.size() or (p.key.sign != 1 and p.key.sign != -1):
        return False
    if p.key.factor_edge == -1:
        return p.key.sign == 1 and same_packet(p, make_root(g, p.key.state_id, p.key.top, p.key.bottom))
    if p.key.factor_edge < 0 or p.key.factor_edge >= len(g.factors):
        return False
    ref f = g.factors[p.key.factor_edge]
    var parent_sign = p.key.sign * f.sign
    var parent = _oriented(g.bpa, f.parent, parent_sign)
    var top = apply_substitution(g.tables.sigma, parent.u)
    var bottom = apply_substitution(g.tables.sigma, parent.v)
    var cuts = coincidence_boundaries(top, bottom)
    var cs = decompose(top, bottom)
    if f.ordinal < 0 or f.ordinal >= len(cs) or f.child != p.key.state_id or cuts[f.ordinal] != f.start or cuts[f.ordinal + 1] != f.end or len(top) != f.total:
        return False
    var raw = cs[f.ordinal].copy()
    var canonical = normalise(raw)
    if canonical != g.bpa.states[f.child]:
        return False
    if canonical.is_coincidence() and f.sign != 1:
        return False
    # A coincidence has identical physical sides; retain the inherited sign.
    if not canonical.is_coincidence() and p.key.sign != (1 if raw == canonical else -1):
        return False
    var ts = p.top_address.source_occurrence
    var bs = p.bottom_address.source_occurrence
    var td = p.top_address.within_image
    var bd = p.bottom_address.within_image
    if ts < 0 or ts >= parent.length() or bs < 0 or bs >= parent.length() or td < 0 or bd < 0:
        return False
    if td >= len(g.tables.sigma[parent.u[ts]]) or bd >= len(g.tables.sigma[parent.v[bs]]):
        return False
    var ti = _starts(g.tables.sigma, parent.u)[ts] + td
    var bi = _starts(g.tables.sigma, parent.v)[bs] + bd
    if ti < f.start or ti >= f.end or bi < f.start or bi >= f.end:
        return False
    if p.top_address != OccurrenceAddress(ts, td, ti, ti - f.start) or p.bottom_address != OccurrenceAddress(bs, bd, bi, bi - f.start) or p.key.top != ti - f.start or p.key.bottom != bi - f.start:
        return False
    var r = prefix_difference3(top, bottom, ti, bi)
    var interior = ti == bi and ti == f.start and f.start > 0 and f.start < f.total
    var matches_target = top[ti] == bottom[bi] and (g.target == -1 or top[ti] == g.target)
    if g.synchronize:
        var h: List[Int] = [g.tables.sigma[0][0], g.tables.sigma[1][0], g.tables.sigma[2][0]]
        matches_target = sync_after(h, top[ti], bottom[bi]) >= 0
    return p.residual == Diff3(r.x, r.y, r.z) and p.top_letter == top[ti] and p.bottom_letter == bottom[bi] and p.interior == interior and p.success == (interior and p.residual.is_zero() and matches_target)


def replay_edge(g: PacketGraph, eid: Int) raises -> Bool:
    """Recompute words/addresses/residual/target classification, not only lambda."""
    if eid < 0 or eid >= len(g.edges):
        return False
    ref e = g.edges[eid]
    if e.source < 0 or e.source >= len(g.packets) or e.destination < 0 or e.destination >= len(g.packets):
        return False
    ref p = g.packets[e.source]
    if p.success or not verify_packet(g, p) or not verify_packet(g, g.packets[e.destination]):
        return False
    var word = _oriented(g.bpa, p.key.state_id, p.key.sign)
    var r = prefix_difference3(word.u, word.v, p.key.top, p.key.bottom)
    if p.residual != Diff3(r.x, r.y, r.z) or p.top_letter != word.u[p.key.top] or p.bottom_letter != word.v[p.key.bottom]:
        return False
    var next = descendant(g, p, e.top_digit, e.bottom_digit)
    var forcing = prefix_difference3(g.tables.sigma[p.top_letter], g.tables.sigma[p.bottom_letter], e.top_digit, e.bottom_digit)
    return same_packet(next, g.packets[e.destination]) and e.forcing == Diff3(forcing.x, forcing.y, forcing.z)


def replay_path(g: PacketGraph, path: List[Int], cycle: Bool = False) raises -> Bool:
    if len(path) == 0:
        return False
    for i in range(len(path)):
        if not replay_edge(g, path[i]):
            return False
        if i > 0 and g.edges[path[i - 1]].destination != g.edges[path[i]].source:
            return False
    return not cycle or g.edges[path[len(path) - 1]].destination == g.edges[path[0]].source


def target_free_sccs(g: PacketGraph) raises -> List[List[Int]]:
    """Every recurrent SCC after deleting successes; exits are retained/reported."""
    var states = List[Pair]()
    var adj = List[List[Int]]()
    var dummy: List[Int] = [0]
    for i in range(len(g.packets)):
        # Reuse the vendored iterative index-based SCC kernel via a graph view.
        states.append(Pair(dummy, dummy))
        var row = List[Int]()
        if not g.packets[i].success:
            for j in range(len(g.adj[i])):
                var dst = g.edges[g.adj[i][j]].destination
                if not g.packets[dst].success:
                    row.append(dst)
        adj.append(row^)
    var view = Automaton(states, adj, False, 3)
    var all = sccs(view)
    var out = List[List[Int]]()
    for i in range(len(all)):
        if has_cycle(view, all[i]):
            out.append(all[i].copy())
    return out^


def cycle_for_scc(g: PacketGraph, comp: List[Int]) raises -> List[Int]:
    """One deterministic shortest return for the first internal edge, per SCC."""
    var inside = List[Bool](length=len(g.packets), fill=False)
    for i in range(len(comp)):
        inside[comp[i]] = True
    for i in range(len(comp)):
        var start = comp[i]
        for j in range(len(g.adj[start])):
            var first = g.adj[start][j]
            var next = g.edges[first].destination
            if not inside[next]:
                continue
            if next == start:
                return [first]
            var prev = List[Int](length=len(g.packets), fill=-1)
            var queue: List[Int] = [next]
            prev[next] = -2
            var head = 0
            while head < len(queue) and prev[start] == -1:
                var at = queue[head]
                head += 1
                for k in range(len(g.adj[at])):
                    var eid = g.adj[at][k]
                    var dst = g.edges[eid].destination
                    if inside[dst] and prev[dst] == -1:
                        prev[dst] = eid
                        queue.append(dst)
            if prev[start] == -1:
                raise Error("recurrent component has no return path")
            var back = List[Int]()
            var cursor = start
            while cursor != next:
                back.append(prev[cursor])
                cursor = g.edges[prev[cursor]].source
            var path: List[Int] = [first]
            for k in range(len(back) - 1, -1, -1):
                path.append(back[k])
            if not replay_path(g, path, True):
                raise Error("extracted packet cycle failed independent replay")
            return path^
    raise Error("recurrent component has no internal edge")


def accumulated_forcing(g: PacketGraph, path: List[Int]) raises -> List[Q]:
    """Exact sum M^(k-1-t) lambda_t, including arbitrarily long cycles."""
    if not replay_path(g, path):
        raise Error("cannot accumulate an invalid packet path")
    var matrix = List[List[Q]]()
    for i in range(3):
        var row = List[Q]()
        for j in range(3):
            row.append(q_int(g.tables.incidence[3 * i + j]))
        matrix.append(row^)
    var forcing: List[Q] = [Q.zero(), Q.zero(), Q.zero()]
    var first = g.packets[g.edges[path[0]].source].residual.copy()
    var scaled: List[Q] = [q_int(first.x), q_int(first.y), q_int(first.z)]
    for i in range(len(path)):
        forcing = matvec(matrix, forcing)
        scaled = matvec(matrix, scaled)
        var q = g.edges[path[i]].forcing.copy()
        forcing[0] = require_q(forcing[0].add(q_int(q.x)), "cycle forcing")
        forcing[1] = require_q(forcing[1].add(q_int(q.y)), "cycle forcing")
        forcing[2] = require_q(forcing[2].add(q_int(q.z)), "cycle forcing")
    var last = g.packets[g.edges[path[len(path) - 1]].destination].residual.copy()
    var expected: List[Q] = [q_int(last.x), q_int(last.y), q_int(last.z)]
    for i in range(3):
        if not require_q(scaled[i].add(forcing[i]), "cycle identity").eq(expected[i]):
            raise Error("accumulated forcing fails the affine path identity")
    return forcing^


struct TargetDistances(Copyable, Movable):
    var depth: List[Int]
    var next_edge: List[Int]

    def __init__(out self, var depth: List[Int], var next_edge: List[Int]):
        self.depth = depth^
        self.next_edge = next_edge^


def target_distances(g: PacketGraph) -> TargetDistances:
    var rev = List[List[Int]]()
    var depth = List[Int](length=len(g.packets), fill=-1)
    var next_edge = List[Int](length=len(g.packets), fill=-1)
    var queue = List[Int]()
    for i in range(len(g.packets)):
        rev.append(List[Int]())
        if g.packets[i].success:
            depth[i] = 0
            queue.append(i)
    for i in range(len(g.edges)):
        rev[g.edges[i].destination].append(i)
    var head = 0
    while head < len(queue):
        var dst = queue[head]
        head += 1
        for i in range(len(rev[dst])):
            var eid = rev[dst][i]
            var src = g.edges[eid].source
            if depth[src] == -1:
                depth[src] = depth[dst] + 1
                next_edge[src] = eid
                queue.append(src)
    return TargetDistances(depth^, next_edge^)


def shortest_root(g: PacketGraph, distances: TargetDistances, comp: List[Int]) -> Int:
    var root = -1
    for i in range(len(comp)):
        ref roots = g.roots[comp[i]]
        for j in range(len(roots)):
            var id = roots[j]
            if distances.depth[id] >= 0 and (root == -1 or distances.depth[id] < distances.depth[root]):
                root = id
    return root


def success_path(g: PacketGraph, distances: TargetDistances, root: Int) raises -> List[Int]:
    if root < 0 or root >= len(g.packets) or distances.depth[root] < 0:
        raise Error("no successful interior target path from this root")
    var path = List[Int]()
    var at = root
    for _ in range(distances.depth[root]):
        var eid = distances.next_edge[at]
        path.append(eid)
        at = g.edges[eid].destination
    if not g.packets[at].success or not replay_path(g, path):
        raise Error("shortest target path failed replay")
    return path^


def witness_to_edge(g: PacketGraph, eid: Int) raises -> List[Int]:
    var back = List[Int]()
    var at = g.edges[eid].source
    while g.birth[at] >= 0:
        var birth = g.birth[at]
        back.append(birth)
        at = g.edges[birth].source
    var out = List[Int]()
    for i in range(len(back) - 1, -1, -1):
        out.append(back[i])
    out.append(eid)
    if not replay_path(g, out):
        raise Error("monovariant witness failed replay")
    return out^


def potential_values(g: PacketGraph, weights: List[Int], l1: Bool) raises -> List[Int]:
    if len(weights) != 3:
        raise Error("linear residual potential needs three integer weights")
    for i in range(3):
        if weights[i] < -1000000 or weights[i] > 1000000:
            raise Error("potential weight exceeds arithmetic budget (1000000)")
    var out = List[Int]()
    for i in range(len(g.packets)):
        var r = g.packets[i].residual.copy()
        if l1:
            out.append(abs(r.x) + abs(r.y) + abs(r.z))
        else:
            out.append(weights[0] * r.x + weights[1] * r.y + weights[2] * r.z)
    return out^


def monovariant_counterexample(g: PacketGraph, values: List[Int], strict: Bool) raises -> List[Int]:
    """First replayable violation of a supplied per-packet decreasing potential."""
    if len(values) != len(g.packets):
        raise Error("potential does not cover every packet")
    for i in range(len(g.edges)):
        ref e = g.edges[i]
        if g.packets[e.source].success or g.packets[e.destination].success:
            continue
        if values[e.destination] > values[e.source] or (strict and values[e.destination] == values[e.source]):
            return witness_to_edge(g, i)
    return List[Int]()
