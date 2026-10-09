"""Deterministic JSONL receipts for the target-aware BPA diagnostic."""

from psc.target_packets import (
    PacketGraph, OccurrenceAddress, target_free_sccs, cycle_for_scc,
    accumulated_forcing, target_distances, shortest_root, success_path,
    potential_values, monovariant_counterexample, replay_path,
)
from psc.bpa import recurrent_noncoincident_sccs
from psc.exact import q_string


def ints_json(values: List[Int]) -> String:
    var out = String("[")
    for i in range(len(values)):
        if i > 0:
            out += ","
        out += String(values[i])
    return out + "]"


def _bool_json(b: Bool) -> String:
    return "true" if b else "false"


def _address(a: OccurrenceAddress) -> String:
    return ints_json([a.source_occurrence, a.within_image, a.global_position, a.local_position])


def emit_packet(g: PacketGraph, id: Int):
    ref p = g.packets[id]
    var classification = String("inside_irreducible_child")
    if p.key.factor_edge == -1:
        classification = "source_occurrences"
    elif p.interior:
        classification = "interior_child_boundary"
    elif p.key.top == 0 and p.key.bottom == 0:
        classification = "exterior_child_boundary"
    elif p.key.top != p.key.bottom:
        classification = "asynchronous_occurrences"
    print(String('{"record":"packet","id":') + String(id)
          + ',"state":' + String(p.key.state_id) + ',"orientation":' + String(p.key.sign)
          + ',"occurrences":' + ints_json([p.key.top, p.key.bottom])
          + ',"top_address":' + _address(p.top_address) + ',"bottom_address":' + _address(p.bottom_address)
          + ',"target_letters":' + ints_json([p.top_letter, p.bottom_letter])
          + ',"residual":' + ints_json([p.residual.x, p.residual.y, p.residual.z])
          + ',"factor_edge":' + String(p.key.factor_edge)
          + ',"classification":"' + classification + '"'
          + ',"interior":' + _bool_json(p.interior) + ',"success":' + _bool_json(p.success) + '}')


def emit_edge(g: PacketGraph, id: Int):
    ref e = g.edges[id]
    print(String('{"record":"edge","id":') + String(id)
          + ',"source":' + String(e.source) + ',"destination":' + String(e.destination)
          + ',"digits":' + ints_json([e.top_digit, e.bottom_digit])
          + ',"lambda":' + ints_json([e.forcing.x, e.forcing.y, e.forcing.z]) + '}')


def emit_path(g: PacketGraph, path: List[Int]) raises:
    if not replay_path(g, path):
        raise Error("refusing to emit an unreplayed path")
    emit_packet(g, g.edges[path[0]].source)
    for i in range(len(path)):
        emit_edge(g, path[i])
        emit_packet(g, g.edges[path[i]].destination)


def emit_report(g: PacketGraph, dump: Bool, weights: List[Int], l1: Bool, strict: Bool) raises:
    var sigma = String("[")
    for i in range(3):
        if i > 0:
            sigma += ","
        sigma += ints_json(g.tables.sigma[i])
    sigma += "]"
    print(String('{"record":"header","schema":"target-aware-bpa-v1","status":"diagnostic","sigma":') + sigma
          + ',"target":' + String(g.target) + ',"synchronize_right":' + _bool_json(g.synchronize)
          + ',"packets":' + String(len(g.packets)) + ',"edges":' + String(len(g.edges))
          + ',"split_descendants":' + String(g.split_count) + ',"complete":true}')
    for s in range(g.bpa.size()):
        print(String('{"record":"state","id":') + String(s) + ',"top":' + ints_json(g.bpa.states[s].u) + ',"bottom":' + ints_json(g.bpa.states[s].v) + '}')
    for f in range(len(g.factors)):
        ref e = g.factors[f]
        print(String('{"record":"factor","id":') + String(f)
              + ',"parent":' + String(e.parent) + ',"ordinal":' + String(e.ordinal)
              + ',"child":' + String(e.child) + ',"orientation":' + String(e.sign)
              + ',"span":' + ints_json([e.start, e.end, e.total]) + '}')
    if dump:
        for p in range(len(g.packets)):
            emit_packet(g, p)
        for e in range(len(g.edges)):
            emit_edge(g, e)

    var comps = target_free_sccs(g)
    for c in range(len(comps)):
        var inside = List[Bool](length=len(g.packets), fill=False)
        for i in range(len(comps[c])):
            inside[comps[c][i]] = True
        var exit = False
        for i in range(len(comps[c])):
            var src = comps[c][i]
            for j in range(len(g.adj[src])):
                if not inside[g.edges[g.adj[src][j]].destination]:
                    exit = True
        print(String('{"record":"target_free_scc","id":') + String(c) + ',"members":' + ints_json(comps[c]) + ',"has_exit":' + _bool_json(exit) + '}')
        var path = cycle_for_scc(g, comps[c])
        var forcing = accumulated_forcing(g, path)
        print(String('{"record":"affine_cycle","scc":') + String(c)
              + ',"edges":' + ints_json(path) + ',"power":' + String(len(path))
              + ',"accumulated_lambda":[' + q_string(forcing[0]) + ',' + q_string(forcing[1]) + ',' + q_string(forcing[2]) + '],"replayed":true}')
        if not dump:
            emit_path(g, path)

    var distances = target_distances(g)
    var sources = recurrent_noncoincident_sccs(g.bpa)
    for c in range(len(sources)):
        var root = shortest_root(g, distances, sources[c])
        var depth = -1 if root == -1 else distances.depth[root]
        var path = List[Int]()
        if root >= 0:
            path = success_path(g, distances, root)
        var missed_roots = 0
        var missed_states = 0
        var max_state_shortest = -1
        for i in range(len(sources[c])):
            var state = sources[c][i]
            var state_root = shortest_root(g, distances, [state])
            if state_root < 0:
                missed_states += 1
            else:
                max_state_shortest = max(max_state_shortest, distances.depth[state_root])
            for j in range(len(g.roots[state])):
                if distances.depth[g.roots[state][j]] < 0:
                    missed_roots += 1
        print(String('{"record":"source_scc","id":') + String(c) + ',"states":' + ints_json(sources[c])
              + ',"shortest_depth":' + String(depth) + ',"root":' + String(root) + ',"edges":' + ints_json(path)
              + ',"roots_without_target":' + String(missed_roots) + ',"states_without_target":' + String(missed_states)
              + ',"max_state_shortest_depth":' + String(max_state_shortest) + '}')
        if root >= 0 and not dump:
            emit_path(g, path)
    # Per-state depths also preserve delayed seed controls that an SCC minimum hides.
    for s in range(g.bpa.size()):
        if g.bpa.states[s].is_coincidence():
            continue
        var root = shortest_root(g, distances, [s])
        var depth = -1 if root < 0 else distances.depth[root]
        print(String('{"record":"source_state","state":') + String(s) + ',"shortest_depth":' + String(depth) + '}')

    var values = potential_values(g, weights, l1)
    var witness = monovariant_counterexample(g, values, strict)
    var potential = String("l1") if l1 else String("linear")
    var result = String("no_violation_on_this_graph") if len(witness) == 0 else String("counterexample")
    print(String('{"record":"monovariant","potential":"') + potential + '","weights":' + ints_json(weights)
          + ',"strict":' + _bool_json(strict) + ',"result":"' + result + '","edges":' + ints_json(witness) + '}')
    if len(witness) > 0:
        ref e = g.edges[witness[len(witness) - 1]]
        print(String('{"record":"potential_values","source":') + String(values[e.source]) + ',"destination":' + String(values[e.destination]) + '}')
        if not dump:
            emit_path(g, witness)
    var terminal_misses = 0
    var unreachable = 0
    for i in range(len(g.packets)):
        if distances.depth[i] < 0:
            unreachable += 1
        if not g.packets[i].success and len(g.adj[i]) == 0:
            terminal_misses += 1
    print(String('{"record":"summary","target_free_recurrent_sccs":') + String(len(comps))
          + ',"packets_without_target":' + String(unreachable) + ',"terminal_misses":' + String(terminal_misses)
          + ',"source_sccs":' + String(len(sources)) + ',"part_b":"open","C4":"unchanged","G1":"unchanged","PSC":"unchanged"}')
