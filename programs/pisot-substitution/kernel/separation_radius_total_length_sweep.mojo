"""Deterministic exhaustive exploratory survey of the total-length <=8 class.

Prints every specimen's exact images and outcome in corpus order. Summary
histograms are partial unless COMPLETE is reached. Any resource cap or other
failure refuses completion after retaining all failed specimen identities.
"""
from psc.corpus import STATE_CAP, TOTAL_LENGTH_CAP, pip_corpus_total_length, report_progress
from psc.histogram import Histogram
from psc.overlap_seed_patch import PerronCache, build_seed_overlap_graph_from_tables
from psc.overlap_collar import patch_power_level
from psc.separation_sweep import SEPARATION_RADIUS_CAP, COLLARED_STATE_CAP, COLLAPSE_LEVEL_CAP, classify_separation, orbit_key
from psc.symmetry import substitution_key


def main() raises:
    print("CLASS ternary PIP total-image-length <=", TOTAL_LENGTH_CAP)
    print("BUDGET radius", SEPARATION_RADIUS_CAP, "collared-states", COLLARED_STATE_CAP, "overlap-states", STATE_CAP)
    var corpus = pip_corpus_total_length(TOTAL_LENGTH_CAP)
    if len(corpus) != 24486:
        raise Error("total-length corpus count changed")
    var perron = PerronCache()
    var radii = Histogram(SEPARATION_RADIUS_CAP + 1)
    var obstructed = 0
    var failed = 0
    var exceptional = Dict[String, Int]()
    for s in range(len(corpus)):
        ref spec = corpus[s]
        var images = substitution_key(spec.sigma)
        try:
            var tables = perron.tables_for(spec.sigma)
            var graph = build_seed_overlap_graph_from_tables(tables, STATE_CAP)
            var radius = classify_separation(tables, graph)
            if radius < 0:
                obstructed += 1
                print("OBSTRUCTED", spec.label(), images, "orbit", orbit_key(spec.sigma))
                for a in range(3):
                    for b in range(a + 1, 3):
                        var level = patch_power_level(spec.sigma, a, b, COLLAPSE_LEVEL_CAP)
                        if level >= 0:
                            print("POWER_WITNESS", images, "pair", a, b, "level", level)
            else:
                radii.record(radius)
                print("SEPARATED", spec.label(), images, "radius", radius)
                if radius > 6:
                    var key = orbit_key(spec.sigma)
                    exceptional[key] = exceptional.get(key, 0) + 1
                    print("EXCEPTIONAL", images, "radius", radius, "orbit", key)
        except e:
            failed += 1
            print("INCONCLUSIVE", spec.label(), images, e)
        report_progress(s + 1)
    print("PIP specimens:", len(corpus))
    print(radii.line("separation-radius distribution (decided specimens):"))
    print("structurally nonseparating:", obstructed, "inconclusive:", failed)
    # Dict insertion order is not evidence order: print orbit keys in corpus order.
    var emitted = Dict[String, Bool]()
    for s in range(len(corpus)):
        var key = orbit_key(corpus[s].sigma)
        if key in exceptional and key not in emitted:
            print("EXCEPTIONAL_ORBIT", key, "members", exceptional[key])
            emitted[key] = True
    if failed != 0 or radii.total() + obstructed != len(corpus):
        raise Error("incomplete separation sweep; no complete distribution certified")
    print("COMPLETE separation sweep: 24486 classified; 0 inconclusive")
