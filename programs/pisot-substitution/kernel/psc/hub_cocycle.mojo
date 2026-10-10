"""Hub-side interpretation of the strict-component orientation cocycle.

Fix a hub letter c supplied by the Barge-Diamond star normal form. Every strict
state's first-letter pair must contain c exactly once. For a normalized state S,
let x_c(S) be 0 when c is on the canonical top side and 1 when it is on the
canonical bottom side.

For a raw child occurrence e:T->S with orientation sign bit b(e), the physical
hub side is

    y_c(e) = x_c(S) + b(e) mod 2.

Consequently

    r_c(e) = y_c(e) + x_c(T)
           = b(e) + x_c(T) + x_c(S) mod 2.

Thus r_c is exactly the orientation signing after the vertex gauge x_c. It has a
concrete boundary meaning: 0 when the raw child carries the hub on the same side
as the canonical parent, 1 when it carries it on the opposite side. Gauge
transformation does not change Perron compatibility/strictness.
"""

from psc.derived_system import DerivedSystem
from finite_graph.signing import SignedEdge, perron_phase


def _bit(x: Int) -> Int:
    var r = x % 2
    if r < 0:
        r += 2
    return r


def _validate_hub(hub: Int) raises:
    if hub < 0 or hub >= 3:
        raise Error("hub letter lies outside 0..2")


def support_is_strongly_connected(system: DerivedSystem) raises -> Bool:
    """Exact SCC check on the derived support graph.

    `DerivedSystem` validates strict child closure, but its public constructor
    can represent a non-SCC support. Perron phase is only a component-level
    invariant, so callers must not silently feed a reducible support to the
    signing solver.
    """
    var n = system.size()
    if n <= 0:
        raise Error("derived support must be nonempty")
    if len(system.images) != n or len(system.child_signs) != n:
        raise Error("derived support arrays disagree with state count")

    var seen = List[Bool]()
    for _ in range(n):
        seen.append(False)
    var queue = List[Int]()
    seen[0] = True
    queue.append(0)
    var head = 0
    while head < len(queue):
        var src = queue[head]
        head += 1
        if len(system.images[src]) != len(system.child_signs[src]):
            raise Error("derived child/sign arrays disagree")
        for j in range(len(system.images[src])):
            var dst = system.images[src][j]
            if dst < 0 or dst >= n:
                raise Error("derived child state ID out of range")
            if not seen[dst]:
                seen[dst] = True
                queue.append(dst)
    for v in range(n):
        if not seen[v]:
            return False

    # Reverse reachability from 0. A fixed-point scan avoids allocating a
    # second adjacency structure; this path runs once per phase check, not in
    # the hot ancestry loop.
    var reverse_seen = List[Bool]()
    for _ in range(n):
        reverse_seen.append(False)
    reverse_seen[0] = True
    var changed = True
    while changed:
        changed = False
        for src in range(n):
            if reverse_seen[src]:
                continue
            for j in range(len(system.images[src])):
                var dst = system.images[src][j]
                if reverse_seen[dst]:
                    reverse_seen[src] = True
                    changed = True
                    break
    for v in range(n):
        if not reverse_seen[v]:
            return False
    return True


def canonical_hub_side(system: DerivedSystem, state_id: Int, hub: Int) raises -> Int:
    """0=top, 1=bottom for the normalized state's first-letter hub occurrence."""
    _validate_hub(hub)
    if state_id < 0 or state_id >= system.size():
        raise Error("state ID lies outside derived system")
    ref state = system.states[state_id]
    if state.length() == 0:
        raise Error("strict state must be nonempty")
    var top = state.u[0]
    var bottom = state.v[0]
    if top == bottom:
        raise Error("strict first-letter pair must be distinct")
    if top == hub:
        return 0
    if bottom == hub:
        return 1
    raise Error("state first-letter pair does not contain the chosen hub")


struct HubCocycle(Copyable, Movable):
    var hub: Int
    var canonical_sides: List[Int]
    var physical_child_sides: List[List[Int]]
    var residual_bits: List[List[Int]]

    def __init__(
        out self,
        hub: Int,
        canonical_sides: List[Int],
        physical_child_sides: List[List[Int]],
        residual_bits: List[List[Int]],
    ):
        self.hub = hub
        self.canonical_sides = canonical_sides.copy()
        self.physical_child_sides = physical_child_sides.copy()
        self.residual_bits = residual_bits.copy()


def build_hub_cocycle(system: DerivedSystem, hub: Int) raises -> HubCocycle:
    """Build the hub-side gauge data once for an interned strict component."""
    _validate_hub(hub)
    var x = List[Int]()
    for state_id in range(system.size()):
        x.append(canonical_hub_side(system, state_id, hub))

    var physical = List[List[Int]]()
    var residual = List[List[Int]]()
    for src in range(system.size()):
        if len(system.images[src]) != len(system.child_signs[src]):
            raise Error("derived child/sign arrays disagree")
        var py = List[Int]()
        var rr = List[Int]()
        for j in range(len(system.images[src])):
            var dst = system.images[src][j]
            if dst < 0 or dst >= system.size():
                raise Error("derived child state ID out of range")
            var sign = system.child_signs[src][j]
            var b = 0
            if sign == -1:
                b = 1
            elif sign != 1:
                raise Error("derived child orientation must be +/-1")
            var y = _bit(x[dst] + b)
            py.append(y)
            rr.append(_bit(y + x[src]))
        physical.append(py^)
        residual.append(rr^)
    return HubCocycle(hub, x, physical, residual)


def orientation_signed_edges(system: DerivedSystem) raises -> List[SignedEdge]:
    """Original orientation cochain b(e) on every child occurrence."""
    var out = List[SignedEdge]()
    for src in range(system.size()):
        if len(system.images[src]) != len(system.child_signs[src]):
            raise Error("derived child/sign arrays disagree")
        for j in range(len(system.images[src])):
            var dst = system.images[src][j]
            if dst < 0 or dst >= system.size():
                raise Error("derived child state ID out of range")
            var sign = system.child_signs[src][j]
            var b = 0
            if sign == -1:
                b = 1
            elif sign != 1:
                raise Error("derived child orientation must be +/-1")
            out.append(SignedEdge(src, dst, b))
    return out^


def hub_residual_edges(system: DerivedSystem, cocycle: HubCocycle) raises -> List[SignedEdge]:
    """Gauge-transformed cochain r_c(e)=b+x(src)+x(dst)."""
    if len(cocycle.residual_bits) != system.size():
        raise Error("hub cocycle/component size mismatch")
    var out = List[SignedEdge]()
    for src in range(system.size()):
        if len(cocycle.residual_bits[src]) != len(system.images[src]):
            raise Error("hub residual/image lengths disagree")
        for j in range(len(system.images[src])):
            var dst = system.images[src][j]
            if dst < 0 or dst >= system.size():
                raise Error("derived child state ID out of range")
            out.append(SignedEdge(src, dst, cocycle.residual_bits[src][j]))
    return out^


def hub_gauge_preserves_perron_phase(system: DerivedSystem, hub: Int) raises -> Bool:
    """Exact phase invariance on one strongly connected derived support."""
    if not support_is_strongly_connected(system):
        raise Error("Perron phase requires one strongly connected derived support")
    var cocycle = build_hub_cocycle(system, hub)
    var original = orientation_signed_edges(system)
    var gauged = hub_residual_edges(system, cocycle)
    return perron_phase(system.size(), original) == perron_phase(system.size(), gauged)
