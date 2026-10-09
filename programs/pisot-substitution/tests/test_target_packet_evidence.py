"""Independent literal-word oracle for the canonical Mojo JSONL receipts.

Small fixtures permit Counter-based prefix comparison and direct unfolding,
independent of Mojo's incidence/prefix caches and normalized orientation rule.
No theorem status is inferred from these finite graphs.
"""

from collections import Counter, defaultdict, deque
import json
from pathlib import Path

import pytest

from psc_research.bpa import _tarjan
from psc_research.synthetic_degree2 import verify_synthetic_template
from psc_research.pip_screen import mat, charpoly, primitive, irreducible, pisot

EVIDENCE = Path(__file__).resolve().parents[1] / "evidence/target-aware-bpa-2026-10-02"


def inflate(sigma, word):
    return tuple(x for letter in word for x in sigma[letter])


def prefix_difference(top, bottom, ti, bi):
    a, b = Counter(top[:ti]), Counter(bottom[:bi])
    return tuple(a[k] - b[k] for k in range(3))


def cuts(top, bottom):
    assert len(top) == len(bottom)
    return [k for k in range(len(top) + 1) if Counter(top[:k]) == Counter(bottom[:k])]


def oriented(states, state, sign):
    assert sign in (-1, 1)
    top, bottom = states[state]
    return (top, bottom) if sign == 1 else (bottom, top)


def starts(sigma, word):
    out = [0]
    for a in word:
        out.append(out[-1] + len(sigma[a]))
    return out


def key(p):
    return (p["state"], p["orientation"], *p["occurrences"], p["factor_edge"])


def reaches_same(h, a, b):
    seen = set()
    while (a, b) not in seen:
        if a == b:
            return True
        seen.add((a, b))
        a, b = h[a], h[b]
    return False


@pytest.mark.parametrize("name,counts", [
    ("real-secondary", (507, 948, 4)),
    ("non-pisot-strict", (46, 82, 1)),
    ("gf-actual", (153, 235, 1)),
])
def test_mojo_graph_against_literal_word_oracle(name, counts):
    rows = [json.loads(line) for line in (EVIDENCE / f"{name}.jsonl").read_text().splitlines()]
    by = defaultdict(list)
    for row in rows:
        by[row["record"]].append(row)
    header, = by["header"]
    summary, = by["summary"]
    sigma = header["sigma"]
    states = {r["id"]: (tuple(r["top"]), tuple(r["bottom"])) for r in by["state"]}
    factors = {r["id"]: r for r in by["factor"]}
    packets = {r["id"]: r for r in by["packet"]}
    edges = {r["id"]: r for r in by["edge"]}
    packet_index = {key(p): i for i, p in packets.items()}
    assert len(packet_index) == len(packets)
    assert (len(packets), len(edges), len(by["target_free_scc"])) == counts
    assert header["complete"] and header["status"] == "diagnostic"
    assert summary["part_b"] == "open"
    assert all(summary[c] == "unchanged" for c in ("C4", "G1", "PSC"))

    # Reconstruct the ordered child table from words, including orientation.
    factor_ids = {}
    for fid, f in factors.items():
        u, v = states[f["parent"]]
        top, bottom = inflate(sigma, u), inflate(sigma, v)
        boundaries = cuts(top, bottom)
        j = f["ordinal"]
        lo, hi = boundaries[j:j + 2]
        raw = (top[lo:hi], bottom[lo:hi])
        normalized = min(raw, raw[::-1])
        assert states[f["child"]] == normalized
        assert f["orientation"] == (1 if raw == normalized else -1)
        assert f["span"] == [lo, hi, len(top)]
        factor_ids[f["parent"], j] = fid

    # Each packet must be an actual occurrence with a checked birth receipt.
    for p in packets.values():
        top, bottom = oriented(states, p["state"], p["orientation"])
        ti, bi = p["occurrences"]
        assert p["target_letters"] == [top[ti], bottom[bi]]
        assert tuple(p["residual"]) == prefix_difference(top, bottom, ti, bi)
        if p["factor_edge"] == -1:
            assert p["orientation"] == 1
            assert p["top_address"] == [ti, -1, ti, ti]
            assert p["bottom_address"] == [bi, -1, bi, bi]
            assert not p["success"] and not p["interior"]
            assert p["classification"] == "source_occurrences"
            continue
        f = factors[p["factor_edge"]]
        parent = oriented(states, f["parent"], p["orientation"] * f["orientation"])
        inflated = tuple(inflate(sigma, w) for w in parent)
        lo, hi, total = f["span"]
        assert cuts(*inflated)[f["ordinal"]:f["ordinal"] + 2] == [lo, hi]
        actual = []
        for side, address in enumerate((p["top_address"], p["bottom_address"])):
            source, digit, absolute, local = address
            assert 0 <= digit < len(sigma[parent[side][source]])
            assert absolute == starts(sigma, parent[side])[source] + digit
            assert lo <= absolute < hi and local == absolute - lo
            assert local == p["occurrences"][side]
            actual.append(absolute)
        ti, bi = actual
        interior = ti == bi == lo and 0 < lo < total
        assert p["interior"] == interior
        classification = "interior_child_boundary" if interior else (
            "exterior_child_boundary" if p["occurrences"] == [0, 0] else (
                "asynchronous_occurrences" if p["occurrences"][0] != p["occurrences"][1] else "inside_irreducible_child"
            )
        )
        assert p["classification"] == classification
        a, b = p["target_letters"]
        matches = a == b and (header["target"] == -1 or a == header["target"])
        if header["synchronize_right"]:
            matches = reaches_same([w[0] for w in sigma], a, b)
        assert p["success"] == (interior and not any(p["residual"]) and matches)

    # Compare every allowed descendant edge and all split descendants. This
    # checks completeness, not just correctness of whichever edges were emitted.
    expected_edges = Counter()
    expected_keys = set()
    splits = 0
    for state, (u, v) in states.items():
        if u != v:
            expected_keys.update((state, 1, i, j, -1) for i in range(len(u)) for j in range(len(v)))
    for pid, p in packets.items():
        if p["success"] or states[p["state"]][0] == states[p["state"]][1]:
            continue
        parent = oriented(states, p["state"], p["orientation"])
        expanded = tuple(inflate(sigma, w) for w in parent)
        boundaries = cuts(*expanded)
        child_at = {k: j for j, (lo, hi) in enumerate(zip(boundaries, boundaries[1:])) for k in range(lo, hi)}
        for td in range(len(sigma[p["target_letters"][0]])):
            for bd in range(len(sigma[p["target_letters"][1]])):
                ti = starts(sigma, parent[0])[p["occurrences"][0]] + td
                bi = starts(sigma, parent[1])[p["occurrences"][1]] + bd
                if child_at[ti] != child_at[bi]:
                    splits += 1
                    continue
                ordinal = child_at[ti]
                fid = factor_ids[p["state"], ordinal]
                lo, hi = boundaries[ordinal:ordinal + 2]
                raw = (expanded[0][lo:hi], expanded[1][lo:hi])
                normalized = min(raw, raw[::-1])
                sign = 1 if raw == normalized else -1
                if normalized[0] == normalized[1]:
                    sign = p["orientation"]
                dest_key = (factors[fid]["child"], sign, ti - lo, bi - lo, fid)
                expected_keys.add(dest_key)
                expected_edges[pid, packet_index[dest_key], td, bd] += 1
    assert expected_keys == set(packet_index)
    assert expected_edges == Counter((e["source"], e["destination"], *e["digits"]) for e in edges.values())
    assert splits == header["split_descendants"]

    incidence = [[Counter(sigma[j])[i] for j in range(3)] for i in range(3)]
    def action(v):
        return tuple(sum(incidence[i][j] * v[j] for j in range(3)) for i in range(3))
    for e in edges.values():
        p, q = packets[e["source"]], packets[e["destination"]]
        a, b = p["target_letters"]
        assert tuple(e["lambda"]) == prefix_difference(sigma[a], sigma[b], *e["digits"])
        assert tuple(q["residual"]) == tuple(x + y for x, y in zip(action(p["residual"]), e["lambda"]))

    active = {i: [] for i, p in packets.items() if not p["success"]}
    reverse = defaultdict(list)
    for e in edges.values():
        reverse[e["destination"]].append(e["source"])
        if e["source"] in active and e["destination"] in active:
            active[e["source"]].append(e["destination"])
    recurrent = [frozenset(c) for c in _tarjan(active) if len(c) > 1 or c[0] in active[c[0]]]
    assert set(recurrent) == {frozenset(r["members"]) for r in by["target_free_scc"]}
    for r in by["target_free_scc"]:
        members = set(r["members"])
        assert r["has_exit"] == any(e["source"] in members and e["destination"] not in members for e in edges.values())

    for r in by["affine_cycle"]:
        path = [edges[i] for i in r["edges"]]
        assert path and path[-1]["destination"] == path[0]["source"]
        assert all(a["destination"] == b["source"] for a, b in zip(path, path[1:]))
        forcing = (0, 0, 0)
        scaled = tuple(packets[path[0]["source"]]["residual"])
        for e in path:
            scaled = action(scaled)
            forcing = tuple(x + y for x, y in zip(action(forcing), e["lambda"]))
        assert tuple(r["accumulated_lambda"]) == forcing
        assert tuple(x + y for x, y in zip(scaled, forcing)) == tuple(packets[path[0]["source"]]["residual"])

    depth = {i: 0 for i, p in packets.items() if p["success"]}
    queue = deque(depth)
    while queue:
        v = queue.popleft()
        for u in reverse[v]:
            if u not in depth:
                depth[u] = depth[v] + 1
                queue.append(u)
    for r in by["source_scc"]:
        root_depths = [depth[i] for i, p in packets.items() if p["factor_edge"] == -1 and p["state"] in r["states"] and i in depth]
        assert r["shortest_depth"] == min(root_depths, default=-1)
        roots = [(i, p) for i, p in packets.items() if p["factor_edge"] == -1 and p["state"] in r["states"]]
        assert r["roots_without_target"] == sum(i not in depth for i, _ in roots)
        per_state = [min((depth[i] for i, p in roots if p["state"] == s and i in depth), default=-1) for s in r["states"]]
        assert r["states_without_target"] == per_state.count(-1)
        assert r["max_state_shortest_depth"] == max(per_state)
        if r["shortest_depth"] >= 0:
            path = [edges[i] for i in r["edges"]]
            assert len(path) == r["shortest_depth"] and path[0]["source"] == r["root"]
            assert packets[path[-1]["destination"]]["success"]
            assert all(a["destination"] == b["source"] for a, b in zip(path, path[1:]))
    for r in by["monovariant"]:
        assert r["result"] == "counterexample"
        path = [edges[i] for i in r["edges"]]
        assert packets[path[0]["source"]]["factor_edge"] == -1
        assert all(a["destination"] == b["source"] for a, b in zip(path, path[1:]))
        p, q = (packets[path[-1][k]] for k in ("source", "destination"))
        assert not p["success"] and not q["success"]
        def value(p):
            return sum(abs(x) for x in p["residual"]) if r["potential"] == "l1" else sum(x * w for x, w in zip(p["residual"], r["weights"]))
        assert value(q) > value(p) or r["strict"] and value(q) == value(p)
    assert summary["packets_without_target"] == len(packets) - len(depth)
    assert summary["terminal_misses"] == sum(not p["success"] and not any(e["source"] == i for e in edges.values()) for i, p in packets.items())


def test_failed_mechanisms_have_concrete_controls():
    sigma = ((1,), (0, 2), (2, 0, 2))
    one_based = {i + 1: tuple(a + 1 for a in w) for i, w in enumerate(sigma)}
    matrix = mat(one_based)
    t, u, d = charpoly(matrix)
    assert (t, u, d) == (2, -1, -1)
    assert primitive(matrix) and irreducible(t, u, d) and pisot(t, u, d)
    assert t*t*u*u - 4*u*u*u - 4*t*t*t*d - 27*d*d + 18*t*u*d == 49
    assert len({w[0] for w in sigma}) == 3
    assert len(sigma[0]) != len(sigma[1])  # naive pair exhaustion mismatch
    top, bottom = (0, 1), (1, 0)
    top, bottom = inflate(sigma, top), inflate(sigma, bottom)
    assert cuts(top, bottom) == [0, len(top)]  # depth one fails
    top, bottom = inflate(sigma, top), inflate(sigma, bottom)
    assert cuts(top, bottom) == [0, 3, 4, 5, 6]
    assert top[1] == bottom[1] and prefix_difference(top, bottom, 1, 1) != (0, 0, 0)
    assert top[3] == bottom[3] and prefix_difference(top, bottom, 3, 3) == (0, 0, 0)
    assert verify_synthetic_template()  # algebraic/endpoint layers still accept G/F
