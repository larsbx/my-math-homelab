"""Deterministic ordered-hub receipt mining on the three retained fixtures."""

from std.sys import argv
from psc.bounded_bpa import build_bounded
from psc.bpa import sigma3
from target_aware_bpa import parse_sigma
from psc.target_packets import build_packets, target_free_sccs, cycle_for_scc, witness_to_edge
from psc.target_packet_report import ints_json
from psc.packet_hub_analysis import (
    ordered_hub_word, packet_support, support_child_closed, compatible_support_phase,
    local_factor_offset, nonzero_cut_subgraph_recurrent, offset_increase_in_scc,
    cycle_hub_word,
)


def bool_json(value: Bool) -> String:
    return "true" if value else "false"


def main() raises:
    var args = argv()
    var sigma: List[List[Int]] = [[1], [0, 2], [2, 0, 2]]
    if len(args) == 3 and args[1] == "--sigma":
        sigma = parse_sigma(args[2])
    elif len(args) != 1:
        raise Error("usage: ordered_hub_packets [--sigma image0/image1/image2]")
    var a = build_bounded(sigma3(sigma), 20000, 10000)
    if not a.complete():
        raise Error("BPA budget exhausted; no ordered-hub verdict")
    var g = build_packets(sigma, a.graph, 200000, 2000000)
    var comps = target_free_sccs(g)
    var sigma_json = String("[")
    for i in range(3):
        if i > 0:
            sigma_json += ","
        sigma_json += ints_json(sigma[i])
    sigma_json += "]"
    print(String('{"record":"header","schema":"ordered-hub-packets-v1","status":"finite-diagnostic","sigma":')
        + sigma_json + ',"packets":' + String(len(g.packets)) + ',"edges":' + String(len(g.edges))
        + ',"sccs":' + String(len(comps)) + ',"radius":1,"offset_scope":"incoming-parent-depth-one","undefined_hub_bit":-1}')
    for c in range(len(comps)):
        var support = packet_support(g, comps[c])
        var phases = List[Int]()
        for hub in range(3):
            phases.append(compatible_support_phase(g, support, hub))
        var nonzero = 0
        var aligned_nonzero = 0
        for i in range(len(comps[c])):
            ref p = g.packets[comps[c][i]]
            if p.key.top != p.key.bottom:
                nonzero += 1
            elif p.residual.x != 0 or p.residual.y != 0 or p.residual.z != 0:
                aligned_nonzero += 1
        var has_exit = False
        var inside = List[Bool](length=len(g.packets), fill=False)
        for i in range(len(comps[c])):
            inside[comps[c][i]] = True
        for i in range(len(comps[c])):
            var src = comps[c][i]
            for j in range(len(g.adj[src])):
                if not inside[g.edges[g.adj[src][j]].destination]:
                    has_exit = True
        print(String('{"record":"scc_profile","id":') + String(c)
            + ',"members":' + ints_json(comps[c]) + ',"support":' + ints_json(support)
            + ',"has_exit":' + bool_json(has_exit)
            + ',"strict_child_closed_support":' + bool_json(support_child_closed(g, support))
            + ',"compatible_hub_phases":' + ints_json(phases)
            + ',"nonzero_cut_packets":' + String(nonzero)
            + ',"aligned_nonzero_defect_packets":' + String(aligned_nonzero)
            + ',"nonzero_cut_subgraph_recurrent":' + bool_json(nonzero_cut_subgraph_recurrent(g, comps[c]))
            + ',"offset_increase_edge":' + String(offset_increase_in_scc(g, comps[c])) + '}')
        for i in range(len(support)):
            var state = support[i]
            var ids = g.expansions[2 * state].factors.copy()
            for hub in range(3):
                print(String('{"record":"ordered_hub_row","scc":') + String(c)
                    + ',"state":' + String(state) + ',"hub":' + String(hub)
                    + ',"factors":' + ints_json(ids) + ',"bits":' + ints_json(ordered_hub_word(g, state, hub)) + '}')
        for i in range(len(comps[c])):
            var pid = comps[c][i]
            var off = local_factor_offset(g, pid)
            print(String('{"record":"local_offset","scc":') + String(c) + ',"packet":' + String(pid)
                + ',"defect":' + ints_json([off.defect.x, off.defect.y, off.defect.z])
                + ',"correction":' + ints_json([off.correction.x, off.correction.y, off.correction.z])
                + ',"cut_delta":' + String(off.cut_delta) + ',"block_delta":' + String(off.block_index_delta)
                + ',"offsets":' + ints_json([off.top_block_offset, off.bottom_block_offset])
                + ',"states":' + ints_json([off.top_state_id, off.bottom_state_id])
                + ',"orientations":' + ints_json([off.top_orientation, off.bottom_orientation])
                + ',"top_context":' + ints_json(off.top_context) + ',"bottom_context":' + ints_json(off.bottom_context) + '}')
        var path = cycle_for_scc(g, comps[c])
        var entry = witness_to_edge(g, path[0])
        var packets = List[Int]()
        var ordinals = List[Int]()
        var deltas = List[Int]()
        for i in range(len(path)):
            ref edge = g.edges[path[i]]
            packets.append(edge.source)
            deltas.append(g.packets[edge.source].key.top - g.packets[edge.source].key.bottom)
            ordinals.append(g.factors[g.packets[edge.destination].key.factor_edge].ordinal)
        for hub in range(3):
            print(String('{"record":"cycle_hub_word","scc":') + String(c) + ',"hub":' + String(hub)
                + ',"edges":' + ints_json(path) + ',"packets":' + ints_json(packets)
                + ',"root_witness_through_first_edge":' + ints_json(entry)
                + ',"child_ordinals":' + ints_json(ordinals) + ',"cut_deltas":' + ints_json(deltas)
                + ',"bits":' + ints_json(cycle_hub_word(g, path, hub)) + ',"replayed":true}')
    print('{"record":"status","C4":"unchanged","G1":"unchanged","PSC":"unchanged","issue_9":"open"}')
