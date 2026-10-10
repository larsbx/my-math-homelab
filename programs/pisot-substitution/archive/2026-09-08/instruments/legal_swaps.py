"""legal_swaps.py — legality-filtered swap seeds for ABBLS-faithful BPA runs.

A genuine balanced-pair swap seed (ab,ba) requires both ab and ba to be legal length-2
factors of L(sigma). standard_seeds() emits every a<b swap regardless; ~40% are not legal
(see ABBLS_SEED_LEGALITY_2026_06_13.md). Use legal_swaps for G2/structural SCC work to avoid
~2% spurious recurrent-SCC over-counting. Termination is seed-legality-invariant, so for G1
or the non-termination refutation bar either seeding is sound.
"""
import sys; sys.path.insert(0, "/mnt/user-data/outputs"); sys.path.insert(0, "/mnt/project")
from bd_exact import legal_two_words

def legal_swaps(s):
    L2 = legal_two_words(s)
    return [((a, b), (b, a)) for a in range(s.k) for b in range(a + 1, s.k)
            if (a, b) in L2 and (b, a) in L2]

if __name__ == "__main__":
    # GATE: legal_swaps subset of standard_seeds, and termination invariant on a sample.
    from balanced_pair import build_bpa, standard_seeds
    import census
    subset_ok = True; term_ok = True; n = 0
    for s in census.enum_k3(max_len=3):
        if not census.is_pip(s)[0]: continue
        n += 1
        if n > 200: break
        ls = set(legal_swaps(s)); ss = set(standard_seeds(s))
        if not ls.issubset(ss): subset_ok = False
        if ls:
            ta = build_bpa(s, list(ss), max_states=5000).finite
            tl = build_bpa(s, list(ls), max_states=5000).finite
            if ta != tl: term_ok = False
    print(f"GATE over {n} PIP: legal_swaps ⊆ standard_seeds: {subset_ok}; "
          f"termination(all)==termination(legal): {term_ok}")
    print("PASS" if subset_ok and term_ok else "REVIEW")
