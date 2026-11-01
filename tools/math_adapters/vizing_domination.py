"""Independent finite Vizing-domination historical casebase checker.

Works from exact-SHA source graph6 rows plus the source's declared 3
classes. It does NOT trust the source's degree-IR canonicalization:
- independently decodes graph6 adjacency;
- searches complete degree-constrained graph-isomorphism bijections;
- independently enumerates dominating subsets to establish gamma=4.

Only the 16 *historical* cases are checked. The 491-entry authoritative
census is unavailable here; the unproved general Vizing conjecture
remains outside scope. No heuristic graph hash can substitute for an
isomorphism witness or exhaustive rejecting search.
"""
from __future__ import annotations

from collections import Counter
from hashlib import sha256
from itertools import combinations
import json


def fail_if_not(flag, reason):
    if not flag:
        raise ValueError(reason)


def decode_graph6(line):
    fail_if_not(isinstance(line, str) and not line.startswith(">>graph6<<"),
                "unexpected graph6 header")
    fail_if_not(len(line) >= 1 and all(63 <= ord(c) <= 126 for c in line),
                "invalid graph6 characters")
    n = ord(line[0]) - 63
    fail_if_not(n == 10, "historical corpus must remain 10 vertices")
    bits_needed = n * (n-1)//2
    fail_if_not(len(line) == 1+(bits_needed+5)//6,
                "invalid graph6 payload length")
    data = [int((ord(c)-63) & (1 << j) != 0)
            for c in line[1:] for j in range(5,-1,-1)]
    fail_if_not(all(bit == 0 for bit in data[bits_needed:]),
                "graph6 padding nonzero")
    neighbors = [0]*n
    k = 0
    for v in range(1,n):
        for u in range(v):
            if data[k]:
                neighbors[v] |= 1 << u
                neighbors[u] |= 1 << v
            k += 1
    return tuple(neighbors)


def degree_signature(adj):
    return tuple(sorted(mask.bit_count() for mask in adj))


def neighborhood_signature(adj, v):
    degree = [a.bit_count() for a in adj]
    return (degree[v], tuple(sorted(degree[w] for w in range(len(adj))
                                    if (adj[v] >> w) & 1)))


def find_isomorphism(a, b):
    """Exhaustive exact adjacency-preserving permutation, or None."""
    n = len(a)
    if n != len(b) or degree_signature(a) != degree_signature(b):
        return None
    ac = [neighborhood_signature(a, u) for u in range(n)]
    bc = [neighborhood_signature(b, v) for v in range(n)]
    options = [tuple(v for v in range(n) if bc[v] == ac[u])
               for u in range(n)]
    if any(not group for group in options):
        return None
    mapping = [-1]*n
    used = 0

    def recurse(mapped, used_mask):
        if mapped == n:
            return tuple(mapping)
        pending = []
        for u in range(n):
            if mapping[u] >= 0:
                continue
            allowed = tuple(v for v in options[u]
                            if not (used_mask >> v) & 1
                            and all(
                                bool((a[u] >> prior) & 1) ==
                                bool((b[v] >> mapping[prior]) & 1)
                                for prior in range(n) if mapping[prior] >= 0))
            if not allowed:
                return None
            pending.append((len(allowed), -sum(
                (a[u] >> w) & 1 for w in range(n)
                if mapping[w] >= 0), u, allowed))
        _, _, u, choices = min(pending)
        for v in choices:
            mapping[u] = v
            result = recurse(mapped+1, used_mask | (1<<v))
            if result is not None:
                return result
            mapping[u] = -1
        return None

    return recurse(0, used)


def check_mapping(a, b, permutation):
    n = len(a)
    return (permutation is not None and
            sorted(permutation) == list(range(n)) and
            all(bool((a[u]>>v) & 1) ==
                bool((b[permutation[u]]>>permutation[v]) & 1)
                for u in range(n) for v in range(n)))


def domination_number(adj):
    """Exhaust all cardinalities in increasing order, never assume gamma."""
    n = len(adj)
    whole = (1<<n)-1
    for k in range(n+1):
        for chosen in combinations(range(n),k):
            covered = 0
            for v in chosen:
                covered |= (1<<v) | adj[v]
            if covered == whole:
                return k, tuple(chosen)
    raise AssertionError("whole vertex set dominates any finite graph")


def verify_casebase(text, declared, *, source_commit, sources_sha256):
    fail_if_not(isinstance(source_commit,str) and len(source_commit)==40
                and all(v in "0123456789abcdef" for v in source_commit),
                "invalid source SHA")
    fail_if_not(set(sources_sha256) == {"graph6","classes"},
                "incomplete fixture checksums")
    fail_if_not(declared.get("schema_version") == 1
                and declared.get("kind") == "historical_casebase_only",
                "source fixture changed its historical-domain contract")
    fail_if_not(declared.get("promotion_status") ==
                "blocked_pending_authoritative_census",
                "source fixture unexpectedly promoted")
    lines = text.splitlines()
    fail_if_not(len(lines) == 16 and all(line == line.strip() and line
                                        for line in lines),
                "historical graph6 corpus must contain exactly 16 rows")
    graphs = [decode_graph6(code) for code in lines]
    group_claims = declared["classes"]
    fail_if_not(len(group_claims) == 3, "unexpected source class count")
    groups = []
    assigned = set()
    witnesses = []
    for row in group_claims:
        ids = row["entry_ids"]
        fail_if_not(ids and sorted(ids) == ids and len(ids) == len(set(ids)),
                    "malformed source iso IDs")
        fail_if_not(row["representative_graph6"] == lines[ids[0]-1],
                    "source representative differs from primary fixture")
        head = graphs[ids[0]-1]
        for id_ in ids:
            fail_if_not(type(id_) is int and 1 <= id_ <= len(lines)
                        and id_ not in assigned, "invalid/duplicate graph entry ID")
            assigned.add(id_)
            match = find_isomorphism(head, graphs[id_-1])
            fail_if_not(check_mapping(head, graphs[id_-1], match),
                        f"source claims nonisomorphic graph in class: {id_}")
            witnesses.append({"entry_id":id_, "representative_id":ids[0],
                              "bijection": list(match)})
        groups.append({"representative_id": ids[0], "entry_ids": ids,
                       "size": len(ids)})
    fail_if_not(assigned == set(range(1,17)), "unclassified historical entry")
    for i,j in combinations(range(len(groups)),2):
        a = graphs[groups[i]["representative_id"]-1]
        b = graphs[groups[j]["representative_id"]-1]
        fail_if_not(find_isomorphism(a,b) is None,
                    "two purported distinct classes are isomorphic")
    gamma_witnesses = []
    for i, graph in enumerate(graphs,1):
        gamma, witness = domination_number(graph)
        fail_if_not(gamma == 4, f"historical graph {i} has gamma={gamma}, not 4")
        gamma_witnesses.append({"entry_id":i, "domination_number": gamma,
                                "dominating_vertices":list(witness)})
    group_sizes = sorted(len(g["entry_ids"]) for g in groups)
    fail_if_not(group_sizes == [1,1,14], "source historical 16-to-3 split changed")
    return {
        "schema":"HOMELAB-VD-EXACT-HISTORICAL-CASEBASE-1",
        "source_commit":source_commit,
        "source_sha256":sources_sha256,
        "n_graphs":len(graphs),"order":10,"iso_classes":len(groups),
        "group_sizes":group_sizes,
        "iso_witnesses":witnesses,
        "gamma_witnesses":gamma_witnesses,
        "methods":["complete_degree_constrained_graph_isomorphism_search",
                   "independent_exhaustive_dominating_subset_search"],
        "verdict":"finite_historical_casebase_verified",
        "scope":"16 source historical records only; authoritative 491-entry census unavailable",
        "census_complete":False,
        "vizing_conjecture_proved":False,
        "next_research_obligation":
          "Acquire and independently deduplicate the missing authoritative "
          "491-entry n=10 gamma=4 census; historical 16-to-3 does not prove "
          "the reported full census or Vizing domination.",
    }
