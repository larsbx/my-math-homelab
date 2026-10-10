"""Exact seed-patch overlap-graph census over the alphabet-3 PIP corpus
(independent Python oracle of kernel/swap_overlap_census.mojo).  Finite evidence
only; see docs/overlap-finiteness-and-coincidence-density-2026-09-13.md."""
import sys, time
sys.path.insert(0, str(__import__('pathlib').Path(__file__).resolve().parents[2] / 'reference'))
from psc_research.pip_screen import pip_corpus
from psc_research.overlap_graph import OverlapGraph

corpus = pip_corpus()
print("PIP specimens:", len(corpus), flush=True)
t0 = time.time(); built = capped = failed = 0; largest = total = 0; bad_specimens = bad_states = 0
for idx, sigma in enumerate(corpus):
    try:
        g = OverlapGraph(sigma, max_states=20000)
    except Exception as e:  # fail closed, report
        failed += 1; print("FAILED", idx, sigma, e, flush=True); continue
    if g.capped:
        capped += 1; print("CAPPED", idx, sigma, flush=True); continue
    built += 1; n = len(g.states); total += n; largest = max(largest, n)
    bad = len(g.nonproductive())
    if bad:
        bad_specimens += 1; bad_states += bad; print("NONPRODUCTIVE", idx, sigma, bad, flush=True)
    if idx % 500 == 0:
        print("progress", idx, "elapsed", round(time.time() - t0), "s", flush=True)
print("overlap graphs built:", built, " capped:", capped, " failed:", failed)
print("largest seed-patch overlap graph:", largest)
print("total seed-patch overlap states:", total)
print("nonproductive overlap specimens:", bad_specimens, " states:", bad_states)
