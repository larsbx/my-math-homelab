"""Independent literal-factor oracle for the ordered-hub/offset exports."""

from collections import Counter, defaultdict, deque
import hashlib
import json
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
OLD = ROOT / "evidence/target-aware-bpa-2026-10-02"
NEW = ROOT / "evidence/ordered-hub-packets-2026-10-06"


def records(path):
    out = defaultdict(list)
    for line in path.read_text().splitlines():
        row = json.loads(line)
        out[row["record"]].append(row)
    return out


def inflate(sigma, word):
    return tuple(x for letter in word for x in sigma[letter])


def diff(top, bottom, i, j):
    a, b = Counter(top[:i]), Counter(bottom[:j])
    return [a[k] - b[k] for k in range(3)]


def viable_phase(sigma, states, support, hub):
    h = [w[0] for w in sigma]
    forbidden = frozenset(set(range(3)) - {hub})
    phases = set()
    viable = set()
    for a in range(3):
        for b in range(a + 1, 3):
            x, y = a, b
            seen = set()
            while x != y and frozenset((x, y)) != forbidden and (x, y) not in seen:
                seen.add((x, y))
                x, y = h[x], h[y]
            if x == y or frozenset((x, y)) == forbidden:
                continue
            viable.add(frozenset((a, b)))
            phases.add(int(b == hub) ^ int(h[b] == hub))
    if len(phases) != 1:
        return -1
    phase, = phases
    if any(frozenset((states[s][0][0], states[s][1][0])) not in viable for s in support):
        return -1
    return phase


def acyclic(vertices, edges):
    indegree = {v: 0 for v in vertices}
    adj = defaultdict(list)
    for e in edges.values():
        if e["source"] in vertices and e["destination"] in vertices:
            adj[e["source"]].append(e["destination"])
            indegree[e["destination"]] += 1
    queue = deque(v for v in vertices if indegree[v] == 0)
    count = 0
    while queue:
        v = queue.popleft()
        count += 1
        for w in adj[v]:
            indegree[w] -= 1
            if indegree[w] == 0:
                queue.append(w)
    return count == len(vertices)


@pytest.mark.parametrize("name", ["real-secondary", "non-pisot-strict", "gf-actual"])
def test_full_order_and_relative_offsets_against_literal_factorization(name):
    old = records(OLD / f"{name}.jsonl")
    new = records(NEW / f"{name}.jsonl")
    sigma = old["header"][0]["sigma"]
    states = {r["id"]: (tuple(r["top"]), tuple(r["bottom"])) for r in old["state"]}
    packets = {r["id"]: r for r in old["packet"]}
    edges = {r["id"]: r for r in old["edge"]}
    factors = {r["id"]: r for r in old["factor"]}
    ordered = {s: sorted((f for f in factors.values() if f["parent"] == s), key=lambda f: f["ordinal"]) for s in states}

    # Hub bits are computed from literal inflated child words, not cached signs.
    def residual(fid, hub):
        f = factors[fid]
        u, v = states[f["parent"]]
        top, bottom = inflate(sigma, u), inflate(sigma, v)
        cuts = [k for k in range(len(top) + 1) if Counter(top[:k]) == Counter(bottom[:k])]
        lo, hi = cuts[f["ordinal"]:f["ordinal"] + 2]
        assert f["span"] == [lo, hi, len(top)]
        assert states[f["child"]] == min((top[lo:hi], bottom[lo:hi]), (bottom[lo:hi], top[lo:hi]))
        parent_pair, raw_pair = (u[0], v[0]), (top[lo], bottom[lo])
        if any(pair[0] == pair[1] or hub not in pair for pair in (parent_pair, raw_pair)):
            return -1
        return int(parent_pair[1] == hub) ^ int(raw_pair[1] == hub)

    header, = new["header"]
    assert header["schema"] == "ordered-hub-packets-v1"
    assert header["status"] == "finite-diagnostic"
    assert header["sigma"] == sigma
    assert header["packets"] == len(packets) and header["edges"] == len(edges)
    assert header["offset_scope"] == "incoming-parent-depth-one" and header["radius"] == 1
    assert header["undefined_hub_bit"] == -1
    assert header["sccs"] == len(old["target_free_scc"])
    profiles = {r["id"]: r for r in new["scc_profile"]}
    assert set(profiles) == {r["id"] for r in old["target_free_scc"]}
    expected_rows, expected_offsets, expected_cycles = set(), set(), set()
    for c in old["target_free_scc"]:
        profile = profiles[c["id"]]
        members = set(c["members"])
        support = sorted({packets[p]["state"] for p in members})
        assert profile["members"] == c["members"] and profile["support"] == support
        assert profile["has_exit"] == c["has_exit"]
        closed = all(f["child"] in support and states[f["child"]][0] != states[f["child"]][1] for s in support for f in ordered[s])
        assert profile["strict_child_closed_support"] == closed
        phases = [viable_phase(sigma, states, support, hub) for hub in range(3)]
        assert profile["compatible_hub_phases"] == phases
        for hub, phase in enumerate(phases):
            if phase >= 0:
                assert all(residual(ordered[s][0]["id"], hub) == phase for s in support)
        nonzero = {p for p in members if packets[p]["occurrences"][0] != packets[p]["occurrences"][1]}
        aligned_nonzero = {p for p in members - nonzero if any(packets[p]["residual"])}
        assert profile["nonzero_cut_packets"] == len(nonzero)
        assert profile["aligned_nonzero_defect_packets"] == len(aligned_nonzero)
        assert profile["nonzero_cut_subgraph_recurrent"] == (not acyclic(nonzero, edges))
        increases = [eid for eid, e in edges.items() if e["source"] in members and e["destination"] in members
                     and abs(packets[e["destination"]]["occurrences"][0] - packets[e["destination"]]["occurrences"][1])
                     > abs(packets[e["source"]]["occurrences"][0] - packets[e["source"]]["occurrences"][1])]
        assert profile["offset_increase_edge"] == (min(increases) if increases else -1)
        expected_rows.update((c["id"], s, h) for s in support for h in range(3))
        expected_offsets.update((c["id"], p) for p in members)
        expected_cycles.update((c["id"], h) for h in range(3))
    assert len(new["ordered_hub_row"]) == len(expected_rows)
    assert {(r["scc"], r["state"], r["hub"]) for r in new["ordered_hub_row"]} == expected_rows
    for r in new["ordered_hub_row"]:
        ids = [f["id"] for f in ordered[r["state"]]]
        assert r["factors"] == ids
        assert r["bits"] == [residual(fid, r["hub"]) for fid in ids]
    assert len(new["local_offset"]) == len(expected_offsets)
    assert {(r["scc"], r["packet"]) for r in new["local_offset"]} == expected_offsets
    for off in new["local_offset"]:
        p = packets[off["packet"]]
        f = factors[p["factor_edge"]]
        sign = p["orientation"] * f["orientation"]
        u, v = states[f["parent"]]
        if sign == -1:
            u, v = v, u
        top, bottom = inflate(sigma, u), inflate(sigma, v)
        ti, bi = p["top_address"][2], p["bottom_address"][2]
        assert off["defect"] == diff(top, bottom, ti, bi) == p["residual"]
        ta, ba = p["top_address"], p["bottom_address"]
        assert off["correction"] == diff(sigma[u[ta[0]]], sigma[v[ba[0]]], ta[1], ba[1])
        assert off["cut_delta"] == ti - bi == sum(off["defect"])
        assert off["block_delta"] == 0 and off["offsets"] == [ti - f["span"][0], bi - f["span"][0]]
        assert off["states"] == [p["state"], p["state"]]
        assert off["orientations"] == [p["orientation"], p["orientation"]]
        def packed(child):
            return 2 * child["child"] + int(sign * child["orientation"] == -1)
        row = ordered[f["parent"]]
        context = [2 * len(states) if f["ordinal"] == 0 else packed(row[f["ordinal"] - 1]), packed(f)]
        assert off["top_context"] == off["bottom_context"] == context
    assert len(new["cycle_hub_word"]) == len(expected_cycles)
    assert {(r["scc"], r["hub"]) for r in new["cycle_hub_word"]} == expected_cycles
    old_cycles = {r["scc"]: r for r in old["affine_cycle"]}
    for r in new["cycle_hub_word"]:
        path = r["edges"]
        assert path == old_cycles[r["scc"]]["edges"] and r["replayed"]
        assert r["packets"] == [edges[e]["source"] for e in path]
        assert r["child_ordinals"] == [factors[packets[edges[e]["destination"]]["factor_edge"]]["ordinal"] for e in path]
        assert r["bits"] == [residual(packets[edges[e]["destination"]]["factor_edge"], r["hub"]) for e in path]
        assert r["cut_deltas"] == [packets[edges[e]["source"]]["occurrences"][0] - packets[edges[e]["source"]]["occurrences"][1] for e in path]
        entry = r["root_witness_through_first_edge"]
        assert packets[edges[entry[0]]["source"]]["factor_edge"] == -1
        assert entry[-1] == path[0]
        for e, f in zip(entry, entry[1:]):
            assert edges[e]["destination"] == edges[f]["source"]
        assert all(not packets[edges[e]["source"]]["success"] for e in entry + path)
    status, = new["status"]
    assert status == {"record": "status", "C4": "unchanged", "G1": "unchanged", "PSC": "unchanged", "issue_9": "open"}


def test_pip_negative_is_hub_coherent_and_repeats_the_full_local_snapshot():
    by = records(NEW / "real-secondary.jsonl")
    off = {r["packet"]: r for r in by["local_offset"]}
    cycles = [r for r in by["cycle_hub_word"] if r["scc"] == 0 and r["hub"] in (0, 1)]
    assert len(cycles) == 2
    for c in cycles:
        assert c["edges"] == [396, 820] and c["bits"] == [1, 1]
        assert c["child_ordinals"] == [2, 0] and c["cut_deltas"] == [0, 1]
    assert off[209]["defect"] == [-1, 1, 0] and off[429]["defect"] == [1, -1, 1]
    assert off[209]["cut_delta"] == 0 and off[429]["cut_delta"] == 1
    assert off[209]["top_context"] == [20, 17] and off[429]["top_context"] == [11, 14]
    assert not by["scc_profile"][0]["strict_child_closed_support"]


def test_export_and_input_hashes():
    for manifest in (NEW / "SHA256SUMS", NEW / "INPUT_SHA256SUMS"):
        for line in manifest.read_text().splitlines():
            digest, rel = line.split()
            path = ROOT / rel
            assert hashlib.sha256(path.read_bytes()).hexdigest() == digest
