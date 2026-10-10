from __future__ import annotations

from .bpa import boundary_sync_hits, build_bpa, endpoint_maps, recurrent_noncoincident_sccs, scc_is_productive, sync_pairs

EXAMPLES = {
    "tribonacci": {1: (1, 2), 2: (1, 3), 3: (1,)},
    "flipped_tribonacci": {1: (2, 1), 2: (3, 1), 3: (1,)},
    "smith": {1: (2,), 2: (1, 3), 3: (1, 3, 1, 2)},
}


def summarize(name: str, sigma: dict[int, tuple[int, ...]]) -> None:
    print(f"== {name} ==")
    plus, minus = endpoint_maps(sigma)
    print(f"sigma_+ = {plus}")
    print(f"sigma_- = {minus}")
    print(f"|Sync_+| = {len(sync_pairs(plus))}; |Sync_-| = {len(sync_pairs(minus))}")
    graph = build_bpa(sigma, max_states=2000)
    comps = recurrent_noncoincident_sccs(graph)
    print(f"states = {len(graph)}, recurrent noncoincident SCCs = {len(comps)}")
    for i, comp in enumerate(comps):
        hits = boundary_sync_hits(sigma, comp, max_iterate=1)
        print(f"  SCC {i}: size={len(comp)} productive@1={scc_is_productive(sigma, comp, 1)} BSL_hits@1={len(hits)}")
        if hits:
            print(f"    first hit: {hits[0]}")
    print()


def main() -> None:
    for name, sigma in EXAMPLES.items():
        summarize(name, sigma)


if __name__ == "__main__":
    main()
