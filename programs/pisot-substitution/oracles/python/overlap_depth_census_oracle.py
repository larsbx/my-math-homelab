"""Python oracle for the depth lines of kernel/swap_overlap_census.mojo (exact Q(beta)).

Recomputes, over the alphabet-3 PIP corpus, the maxima and histograms of the
first-coincidence depth, the first left-aligned depth, and the prefix/suffix
strong-coincidence depths, in the same format as the Mojo census lines."""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parents[2] / 'reference'))
from psc_research.pip_screen import pip_corpus
from psc_research.overlap_graph import (
    OverlapGraph, first_coincidence_depths, first_left_aligned_depths, strong_coincidence_depths)

hist = {k: {} for k in ("coinc", "left", "prefix", "suffix")}
t0 = time.time()
for idx, sigma in enumerate(pip_corpus()):
    g = OverlapGraph(sigma)
    c, b = first_coincidence_depths(g), first_left_aligned_depths(g)
    pre, suf = strong_coincidence_depths(g, depths=c), strong_coincidence_depths(g, suffix=True, depths=c)
    assert all(0 <= bb <= cc for bb, cc in zip(b, c)) and min(pre.values()) >= 0 and min(suf.values()) >= 0
    assert all(cc <= bb + max(pre.values()) for bb, cc in zip(b, c))
    for k, v in (("coinc", max(c)), ("left", max(b)), ("prefix", max(pre.values())), ("suffix", max(suf.values()))):
        hist[k][v] = hist[k].get(v, 0) + 1
    if idx % 500 == 0:
        print("progress", idx, round(time.time() - t0), "s", flush=True)
fmt = lambda h: " ".join(f"{k}:{h[k]}" for k in sorted(h))
print("maximum first-coincidence depth:", max(hist["coinc"]))
print("specimens by maximal first-coincidence depth:", fmt(hist["coinc"]))
print("maximum first left-aligned depth:", max(hist["left"]))
print("specimens by maximal first left-aligned depth:", fmt(hist["left"]))
print("maximum prefix strong-coincidence depth:", max(hist["prefix"]))
print("specimens by prefix strong-coincidence depth:", fmt(hist["prefix"]))
print("maximum suffix strong-coincidence depth:", max(hist["suffix"]))
print("specimens by suffix strong-coincidence depth:", fmt(hist["suffix"]))
