"""Ordered hub words and local hierarchy-offset negatives for actual packets.

The strict DerivedSystem/legality contract is not relaxed here. Packet supports
can be productive and nonclosed. The RelativeHierarchyOffset *format* is used
for a verified depth-one actual factor partition, with exterior sentinels at
that parent's ends. Such a snapshot is not a certified arbitrary-depth legal
tower. Undefined hub residuals remain -1, including diagonal children.
"""

from psc.target_packets import PacketGraph, verify_packet, replay_path
from psc.hierarchy_offset import RelativeHierarchyOffset, Vec3
from psc.hub_selector import strict_star_pair_viable, strict_star_selector_phase
from psc.affine_ancestry_trace import _prefix_parikh
from finite_graph.scc import sccs, has_cycle


def _check_hub(hub: Int) raises:
    if hub < 0 or hub >= 3:
        raise Error("hub lies outside 0..2")


def hub_side(g: PacketGraph, state: Int, hub: Int) raises -> Int:
    """Canonical first-letter side: 0/1, or -1 outside the hub-star domain."""
    _check_hub(hub)
    if state < 0 or state >= g.bpa.size():
        raise Error("invalid hub state ID")
    ref p = g.bpa.states[state]
    if p.u[0] == p.v[0]:
        return -1
    if p.u[0] == hub:
        return 0
    if p.v[0] == hub:
        return 1
    return -1


def factor_hub_residual(g: PacketGraph, factor: Int, hub: Int) raises -> Int:
    if factor < 0 or factor >= len(g.factors):
        raise Error("invalid factor ID")
    ref f = g.factors[factor]
    var parent = hub_side(g, f.parent, hub)
    var child = hub_side(g, f.child, hub)
    if parent < 0 or child < 0:
        return -1
    if f.sign != 1 and f.sign != -1:
        raise Error("invalid actual factor orientation")
    return parent ^ child ^ Int(f.sign == -1)


def ordered_hub_word(g: PacketGraph, state: Int, hub: Int) raises -> List[Int]:
    _ = hub_side(g, state, hub)
    var out = List[Int]()
    # PacketGraph stores two expansions per state, + then - orientation.
    for j in range(len(g.expansions[2 * state].factors)):
        out.append(factor_hub_residual(g, g.expansions[2 * state].factors[j], hub))
    return out^


def packet_support(g: PacketGraph, comp: List[Int]) raises -> List[Int]:
    if len(comp) == 0:
        raise Error("packet component must be nonempty")
    var seen = List[Bool](length=g.bpa.size(), fill=False)
    for i in range(len(comp)):
        var pid = comp[i]
        if pid < 0 or pid >= len(g.packets):
            raise Error("invalid packet component ID")
        seen[g.packets[pid].key.state_id] = True
    var out = List[Int]()
    for s in range(g.bpa.size()):
        if seen[s]:
            out.append(s)
    return out^


def support_child_closed(g: PacketGraph, support: List[Int]) raises -> Bool:
    var seen = List[Bool](length=g.bpa.size(), fill=False)
    for i in range(len(support)):
        if support[i] < 0 or support[i] >= g.bpa.size():
            raise Error("invalid BPA support ID")
        if g.bpa.states[support[i]].is_coincidence():
            return False
        seen[support[i]] = True
    for i in range(len(support)):
        var s = support[i]
        for j in range(len(g.expansions[2 * s].factors)):
            if not seen[g.factors[g.expansions[2 * s].factors[j]].child]:
                return False
    return len(support) > 0


def compatible_support_phase(g: PacketGraph, support: List[Int], hub: Int) raises -> Int:
    """Endpoint/first-child compatibility only; not the strict-system bridge.

    Returns -1 when incompatible, otherwise 0/1. This function intentionally
    does not label a candidate good edge as eventually coincident.
    """
    _check_hub(hub)
    if len(support) == 0:
        raise Error("hub phase requires a nonempty support")
    var good = List[Int]()
    var h = List[Int]()
    for a in range(3):
        h.append(g.tables.sigma[a][0])
        if a != hub:
            good.append(a)
    var phase = strict_star_selector_phase(h, good[0], good[1])
    if phase < 0 or phase > 1:
        return -1
    for i in range(len(support)):
        var s = support[i]
        _ = hub_side(g, s, hub)
        ref state = g.bpa.states[s]
        if state.u[0] == state.v[0] or not strict_star_pair_viable(h, good[0], good[1], state.u[0], state.v[0]):
            return -1
        if len(g.expansions[2 * s].factors) == 0:
            return -1
        if factor_hub_residual(g, g.expansions[2 * s].factors[0], hub) != phase:
            return -1
    return phase


def _packed_factor(g: PacketGraph, fid: Int, parent_sign: Int) raises -> Int:
    ref f = g.factors[fid]
    var sign = parent_sign * f.sign
    if sign != 1 and sign != -1:
        raise Error("invalid local hierarchy orientation")
    return 2 * f.child + Int(sign == -1)


def local_factor_offset(g: PacketGraph, pid: Int) raises -> RelativeHierarchyOffset:
    """Exact radius-one snapshot in the incoming parent's actual partition.

    Context has the strict hierarchy module's convention: left neighbor then
    current block. Both occurrences are in one child by the packet contract,
    so Delta_block=0. Exterior sentinels mean only 'outside this finite parent'.
    Incoming proper-prefix correction is recomputed from the address digits.
    """
    if pid < 0 or pid >= len(g.packets):
        raise Error("invalid offset packet ID")
    ref p = g.packets[pid]
    if not verify_packet(g, p):
        raise Error("offset refuses an unreplayed packet")
    if p.key.factor_edge < 0:
        raise Error("local factor offset requires an incoming actual factor")
    ref f = g.factors[p.key.factor_edge]
    var parent_sign = p.key.sign * f.sign
    ref factors = g.expansions[2 * f.parent].factors
    if factors[f.ordinal] != p.key.factor_edge:
        raise Error("incoming ordinal disagrees with actual factor order")
    var context = List[Int]()
    if f.ordinal == 0:
        context.append(2 * g.bpa.size())
    else:
        context.append(_packed_factor(g, factors[f.ordinal - 1], parent_sign))
    context.append(_packed_factor(g, p.key.factor_edge, parent_sign))
    ref parent = g.bpa.states[f.parent]
    var a = parent.u[p.top_address.source_occurrence]
    var b = parent.v[p.bottom_address.source_occurrence]
    if parent_sign == -1:
        a = parent.v[p.top_address.source_occurrence]
        b = parent.u[p.bottom_address.source_occurrence]
    var top_prefix = _prefix_parikh(g.tables, a, p.top_address.within_image)
    var bottom_prefix = _prefix_parikh(g.tables, b, p.bottom_address.within_image)
    var correction = Vec3(top_prefix.x - bottom_prefix.x, top_prefix.y - bottom_prefix.y, top_prefix.z - bottom_prefix.z)
    var defect = Vec3(p.residual.x, p.residual.y, p.residual.z)
    var delta = p.top_address.global_position - p.bottom_address.global_position
    if delta != p.key.top - p.key.bottom or defect.total() != delta:
        raise Error("local cut displacement does not equal the defect total")
    return RelativeHierarchyOffset(defect, correction, delta, 0, p.key.top, p.key.bottom,
        p.key.state_id, p.key.state_id, p.key.sign, p.key.sign, context, context)


def nonzero_cut_subgraph_recurrent(g: PacketGraph, comp: List[Int]) raises -> Bool:
    """Exact finite test, no uniform inference from acyclicity."""
    var active = List[Bool](length=len(g.packets), fill=False)
    for i in range(len(comp)):
        var pid = comp[i]
        if pid < 0 or pid >= len(g.packets):
            raise Error("invalid packet component ID")
        active[pid] = g.packets[pid].key.top != g.packets[pid].key.bottom
    var adj = List[List[Int]]()
    for p in range(len(g.packets)):
        var row = List[Int]()
        if active[p]:
            for j in range(len(g.adj[p])):
                var dst = g.edges[g.adj[p][j]].destination
                if active[dst]:
                    row.append(dst)
        adj.append(row^)
    var comps = sccs(adj)
    for i in range(len(comps)):
        if has_cycle(adj, comps[i]):
            return True
    return False


def offset_increase_in_scc(g: PacketGraph, comp: List[Int]) raises -> Int:
    var inside = List[Bool](length=len(g.packets), fill=False)
    for i in range(len(comp)):
        if comp[i] < 0 or comp[i] >= len(g.packets):
            raise Error("invalid packet component ID")
        inside[comp[i]] = True
    for eid in range(len(g.edges)):
        ref e = g.edges[eid]
        if inside[e.source] and inside[e.destination]:
            ref p = g.packets[e.source]
            ref q = g.packets[e.destination]
            if abs(q.key.top - q.key.bottom) > abs(p.key.top - p.key.bottom):
                return eid
    return -1


def cycle_hub_word(g: PacketGraph, path: List[Int], hub: Int) raises -> List[Int]:
    _check_hub(hub)
    if not replay_path(g, path, True):
        raise Error("hub cycle refuses an unreplayed occurrence path")
    var out = List[Int]()
    for i in range(len(path)):
        var dst = g.edges[path[i]].destination
        out.append(factor_hub_residual(g, g.packets[dst].key.factor_edge, hub))
    return out^
