"""Strong coincidence decided by formula, against the overlap graph, per pair.

For **every** specimen this decides `SC(i, j)` for each pair of letters by the
search of `psc.coincidence_formula`, which is cheap enough that sampling would
be a false economy, and then checks the answer twice over against two things
that share no step with it:

* **Each witness, re-derived.** A shortest accepted word splits into two
  Dumont-Thomas paths; `path_prefix_parikh` and `path_letter` recompute the
  Parikh vectors and the letters. This is a *consistency* check and is counted
  as one: those functions reuse `incidence_step`, the recurrence the automaton
  is built on, so a defect there could make the witness and its check agree.
  It catches a wrong witness, not a wrong recurrence.
* **Each level, against the images themselves.** Sampled, because it inflates:
  `sigma^k(i)` and `sigma^k(j)` are built by substituting and scanned for a
  position where the prefixes carry one Parikh vector and the letters agree.
  Nothing in it touches the automaton, the incidence matrix or the Perron
  field, and it must find one at the reported level and none below it. This is
  the check with no shared step, which is why it is stated apart from the one
  above rather than folded into it.
* **Each level, against the overlap graph.** A left-aligned non-coincidence
  vertex `(i, j, 0)` of the seed-patch overlap automaton is productive exactly
  when the pair is eventually coincident, and its first-coincidence depth is
  the least number of inflations that reaches one. That depth and the shortest
  witness are computed from different objects -- exact cubic tile geometry on
  one side, an integer Parikh difference on the other -- and must agree. This
  one *is* sampled, because building the graph is what costs, and the two
  counts are reported apart so a reader can see which claim covers what.

The exploration carries no budget outcome: its state set is finite by the
argument in `psc.coincidence_formula`, so a cap is a guard against a defect in
that file and exceeding it raises. This driver catches nothing, so anything
that raises aborts the census rather than being counted as an inconclusive
specimen.

Deciding the condition per specimen is not deciding it for the family. Strong
coincidence for alphabet-3 Pisot substitutions is open, and a clean sweep here
is elimination of counterexamples over a finite corpus and nothing more.
"""

from finite_automata.dfa import minimised, same_language
from psc.bpa import apply_substitution
from psc.coincidence_elimination import coincidence_by_elimination
from psc.coincidence_formula import (
    coincidence_automaton,
    coincidence_witness,
    pair_paths,
    path_letter,
    path_prefix_parikh,
)
from psc.corpus import STATE_CAP, pip_corpus, report_progress
from psc.dumont_thomas import max_image_length
from psc.histogram import Histogram, max_int
from psc.overlap_seed_patch import (
    PerronCache,
    build_seed_overlap_graph_from_tables,
    first_coincidence_depths,
)
from psc.words import ALPHABET

# The formula is cheap, so every specimen is decided; the overlap graph is not,
# so the cross-check is sampled. Keeping them apart is the point: the verdict
# covers the corpus, and the agreement covers a sample of it.
comptime COMPARE_STRIDE = 30

# Assembling the formula out of the kernel builds products before it minimises
# them, so it is the most expensive check here and the most sparsely sampled.
comptime ELIMINATE_STRIDE = 300

# Inflating `sigma^k` costs the length of the image, so the one check that
# shares no step with the automaton is sampled too.
comptime INFLATE_STRIDE = 150


def least_level_by_images(
    sigma: List[List[Int]], top: Int, bottom: Int, max_level: Int
) raises -> Int:
    """The definition, carried out by substituting: the least `k` at which
    `sigma^k(top)` and `sigma^k(bottom)` carry one letter at one position after
    prefixes of one Parikh vector.

    Deliberately shares nothing with `psc.coincidence_formula` -- no incidence
    matrix, no Perron field, no digit path. It is the check that makes the
    census's agreement mean something."""
    var above: List[Int] = [top]
    var below: List[Int] = [bottom]
    for level in range(max_level + 1):
        var counted_above = List[Int](length=ALPHABET, fill=0)
        var counted_below = List[Int](length=ALPHABET, fill=0)
        var shorter = len(above) if len(above) < len(below) else len(below)
        for p in range(shorter):
            var balanced = True
            for letter in range(ALPHABET):
                if counted_above[letter] != counted_below[letter]:
                    balanced = False
            if balanced and above[p] == below[p]:
                return level
            counted_above[above[p]] += 1
            counted_below[below[p]] += 1
        above = apply_substitution(sigma, above)
        below = apply_substitution(sigma, below)
    return -1


def main() raises:
    var corpus = pip_corpus()
    var perron = PerronCache()
    var decided = 0
    var capped_graphs = 0
    var compared = 0
    var pairs = 0
    var witnesses = 0
    var bad_witnesses = 0
    var depth_matches = 0
    var depth_mismatches = 0
    var without_coincidence = 0
    var inflated = 0
    var inflated_agrees = 0
    var inflated_differs = 0
    var eliminated = 0
    var elimination_agrees = 0
    var elimination_differs = 0
    var deepest = 0
    var levels = Histogram(256)

    for s in range(len(corpus)):
        ref spec = corpus[s]
        decided += 1
        var radix = max_image_length(spec.sigma)

        # Every ordered pair, so a left-aligned overlap vertex is found in
        # whichever orientation the graph happens to carry it.
        var mine = List[Int]()
        for i in range(ALPHABET):
            for j in range(ALPHABET):
                pairs += 1
                var found = coincidence_witness(spec.sigma, i, j)
                if found.empty:
                    mine.append(-1)
                    continue
                var level = len(found.word)
                mine.append(level)
                levels.record(level)
                deepest = max_int(deepest, level)

                # The witness, re-derived through this module's own path
                # functions: consistency, not independence -- the check with
                # no shared step is the inflated one below.
                witnesses += 1
                var paths = pair_paths(radix, found.word)
                var top = path_prefix_parikh(spec.sigma, i, paths[0])
                var bottom = path_prefix_parikh(spec.sigma, j, paths[1])
                var agrees = path_letter(spec.sigma, i, paths[0]) == path_letter(
                    spec.sigma, j, paths[1]
                )
                for letter in range(ALPHABET):
                    if top[letter] != bottom[letter]:
                        agrees = False
                if not agrees:
                    bad_witnesses += 1
                    print("BAD WITNESS", spec.label(), i, j)

        # Strong coincidence is every pair coinciding, and the per-pair levels
        # are already in hand: asking the module again would rebuild the same
        # three automata to learn the same thing.
        var all_pairs = True
        for i in range(ALPHABET):
            for j in range(i + 1, ALPHABET):
                if mine[i * ALPHABET + j] < 0:
                    all_pairs = False
        if not all_pairs:
            without_coincidence += 1
            print("NO STRONG COINCIDENCE", spec.label())

        # The one check with no shared step: the images themselves.
        if s % INFLATE_STRIDE == 0:
            for i in range(ALPHABET):
                for j in range(ALPHABET):
                    inflated += 1
                    if least_level_by_images(spec.sigma, i, j, 24) == mine[
                        i * ALPHABET + j
                    ]:
                        inflated_agrees += 1
                    else:
                        inflated_differs += 1
                        print("IMAGE LEVEL DIFFERS", spec.label(), i, j)

        # The formula assembled conjunct by conjunct out of the automata kernel
        # must accept the language the purpose-built automaton accepts. Two
        # routes to one condition, and the letters come off the Dumont-Thomas
        # letter map on one of them and off the exploration's own state on the
        # other.
        if s % ELIMINATE_STRIDE == 0:
            eliminated += 1
            for i in range(ALPHABET):
                for j in range(ALPHABET):
                    if same_language(
                        coincidence_by_elimination(spec.sigma, i, j),
                        minimised(coincidence_automaton(spec.sigma, i, j)),
                    ):
                        elimination_agrees += 1
                    else:
                        elimination_differs += 1
                        print("ELIMINATION DIFFERS", spec.label(), i, j)

        if s % COMPARE_STRIDE != 0:
            report_progress(s, len(corpus))
            continue
        var tables = perron.tables_for(spec.sigma)
        var graph = build_seed_overlap_graph_from_tables(tables, STATE_CAP)
        if graph.capped:
            capped_graphs += 1
            print("CAPPED OVERLAP GRAPH", spec.label())
            report_progress(s, len(corpus))
            continue
        compared += 1
        var depths = first_coincidence_depths(graph)
        for v in range(graph.size()):
            ref state = graph.states[v]
            if state.is_coincidence() or not state.shift.is_zero():
                continue
            if depths[v] == mine[state.top * ALPHABET + state.bottom]:
                depth_matches += 1
            else:
                depth_mismatches += 1
                print("DEPTH MISMATCH", spec.label(), state.top, state.bottom,
                      " overlap:", depths[v],
                      " formula:", mine[state.top * ALPHABET + state.bottom])
        report_progress(s, len(corpus))

    print("corpus:", len(corpus), " specimens decided:", decided,
          " compare stride:", COMPARE_STRIDE)
    print("ordered pairs decided:", pairs, " witnesses re-derived:", witnesses,
          " that did not check:", bad_witnesses)
    print("pair levels checked against the inflated images:", inflated,
          " equal:", inflated_agrees, " different:", inflated_differs)
    print("specimens without strong coincidence:", without_coincidence)
    print("overlap graphs compared:", compared, " capped:", capped_graphs)
    print("left-aligned depths equal to the witness level:", depth_matches,
          " different:", depth_mismatches)
    print("specimens whose formula was assembled from the kernel:", eliminated,
          " pair languages equal:", elimination_agrees,
          " different:", elimination_differs)
    print("deepest coincidence level:", deepest)
    print(levels.line("pairs by coincidence level"))
