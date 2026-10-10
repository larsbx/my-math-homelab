"""Python oracle for kernel/overlap_contracting_census.mojo: first left-aligned depth b(O) against the
contracting lower bound m_0(O) of psc_research.overlap_contracting, over the
alphabet-3 PIP corpus.  Verifies b >= m_0 on every vertex and reports the
distribution of the excess b - m_0 and of m_0 itself."""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parents[2] / 'reference'))
from psc_research.pip_screen import pip_corpus
from psc_research.overlap_graph import OverlapGraph, first_left_aligned_depths
from psc_research.overlap_contracting import ContractingBound

hist = {"excess": {}, "m0": {}, "max_excess": {}, "max_m0": {}}
by_case = {"complex": {"max_excess": 0, "max_m0": 0, "n": 0}, "real": {"max_excess": 0, "max_m0": 0, "n": 0}}
t0 = time.time(); n_vertices = 0
for idx, sigma in enumerate(pip_corpus()):
    g = OverlapGraph(sigma); cb = ContractingBound(g); b = first_left_aligned_depths(g)
    cache, worst_e, worst_m = {}, 0, 0
    for k, s in enumerate(g.states):
        m0 = cache.get(s[2])
        if m0 is None:
            m0 = cache[s[2]] = cb.least_level(s[2])
        assert 0 <= m0 <= b[k], (sigma, s, b[k], m0)
        e = b[k] - m0
        hist["excess"][e] = hist["excess"].get(e, 0) + 1
        hist["m0"][m0] = hist["m0"].get(m0, 0) + 1
        worst_e, worst_m = max(worst_e, e), max(worst_m, m0)
        n_vertices += 1
    hist["max_excess"][worst_e] = hist["max_excess"].get(worst_e, 0) + 1
    hist["max_m0"][worst_m] = hist["max_m0"].get(worst_m, 0) + 1
    case = by_case["complex" if cb.complex else "real"]
    case["n"] += 1; case["max_excess"] = max(case["max_excess"], worst_e); case["max_m0"] = max(case["max_m0"], worst_m)
    if idx % 500 == 0:
        print("progress", idx, round(time.time() - t0), "s", flush=True)
fmt = lambda h: " ".join(f"{k}:{h[k]}" for k in sorted(h))
print("vertices checked:", n_vertices)
print("maximum contracting lower bound m0:", max(hist["m0"]))
print("vertices by contracting lower bound m0:", fmt(hist["m0"]))
print("maximum excess b - m0:", max(hist["excess"]))
print("vertices by excess b - m0:", fmt(hist["excess"]))
print("specimens by maximal excess:", fmt(hist["max_excess"]))
print("specimens by maximal m0:", fmt(hist["max_m0"]))
c, r = by_case["complex"], by_case["real"]
print(f"complex-pair specimens: {c['n']}  maximal m0: {c['max_m0']}  maximal excess: {c['max_excess']}")
print(f"real-conjugate specimens: {r['n']}  maximal m0: {r['max_m0']}  maximal excess: {r['max_excess']}")
