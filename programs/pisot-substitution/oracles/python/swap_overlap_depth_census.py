"""Exact first-coincidence-depth census over the seed-patch overlap graphs of
the alphabet-3 PIP corpus (independent Python oracle of the depth lines of
kernel/swap_overlap_census.mojo).  Finite evidence only."""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parents[2] / 'reference'))
from psc_research.pip_screen import pip_corpus
from psc_research.overlap_graph import OverlapGraph, first_coincidence_depths

corpus = pip_corpus()
print("PIP specimens:", len(corpus), flush=True)
t0 = time.time(); hist = {}; worst_overall = 0; worst_sigma = None
for idx, sigma in enumerate(corpus):
    g = OverlapGraph(sigma, max_states=20000)
    assert not g.capped
    d = first_coincidence_depths(g)
    assert min(d) >= 0, ("nonproductive", idx, sigma)
    w = max(d); hist[w] = hist.get(w, 0) + 1
    if w > worst_overall:
        worst_overall, worst_sigma = w, sigma
    if idx % 500 == 0:
        print("progress", idx, "elapsed", round(time.time() - t0), "s", flush=True)
print("maximum first-coincidence depth:", worst_overall, "attained by", worst_sigma)
print("specimens by maximal first-coincidence depth:", " ".join(f"{k}:{v}" for k, v in sorted(hist.items())))
