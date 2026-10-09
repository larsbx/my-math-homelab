"""Boundary synchronization as a productivity detector, on any alphabet.

A recurrent noncoincident component of `B_sigma` is *productive at level `n`*
when some state produces a single-tile coincidence block within `n`
inflations, and is *caught at level `n`* when some state has a zero-return cut
whose adjacent letters coalesce under the prefix or suffix endpoint map. The
C3 mechanism claims the second detects the first; a productive component with
no synchronizing cut is the event that would refute it, so the sweep keeps
every such witness.

Everything here is exact. The specimen generator is deterministic given its
seed (`psc.prng`), so the sweep is reproducible, but a randomized search is
exploratory evidence: it eliminates nothing outside the substitutions it
actually visits.
"""

from psc.bounded_bpa import BUDGET_LENGTH, build_bounded
from finite_linear_algebra.integer_matrix import is_primitive
from psc.prng import SplitMix64
from substitution_dynamics.automaton import Automaton, recurrent_noncoincident_sccs
from substitution_dynamics.balanced_pairs import (
    coincidence_boundaries,
    decompose,
    synchronizing_boundary_positions,
)
from substitution_dynamics.substitution import Substitution
from substitution_dynamics.words import Pair


def random_substitution(
    mut rng: SplitMix64, size: Int, min_length: Int, max_length: Int
) raises -> Substitution:
    """A uniformly drawn substitution with images of length `min..max`."""
    var images = List[List[Int]]()
    for _ in range(size):
        var word = List[Int]()
        for _ in range(rng.between(min_length, max_length)):
            word.append(rng.below(size))
        images.append(word^)
    return Substitution.checked(images^)


def is_primitive_substitution(sigma: Substitution) raises -> Bool:
    return is_primitive(sigma.incidence(), sigma.size)


def produces_single_tile_coincidence(sigma: Substitution, p: Pair, max_iterate: Int) -> Bool:
    """Whether inflating `p` at most `max_iterate` times cuts out a
    single-letter coincidence block."""
    var u = p.u.copy()
    var v = p.v.copy()
    for _ in range(max_iterate):
        u = sigma.apply(u)
        v = sigma.apply(v)
        var blocks = decompose(u, v, sigma.size)
        for b in range(len(blocks)):
            if blocks[b].length() == 1 and blocks[b].is_coincidence():
                return True
    return False


def synchronizing_cut_count(sigma: Substitution, p: Pair, max_iterate: Int) -> Int:
    """Zero-return cuts of `p` and of its first `max_iterate` inflations whose
    adjacent endpoint pair coalesces."""
    var u = p.u.copy()
    var v = p.v.copy()
    var hits = 0
    for level in range(max_iterate + 1):
        if level > 0:
            u = sigma.apply(u)
            v = sigma.apply(v)
        var cuts = coincidence_boundaries(u, v, sigma.size)
        hits += len(synchronizing_boundary_positions(sigma, u, v, cuts))
    return hits


def component_is_productive(
    sigma: Substitution, a: Automaton, comp: List[Int], max_iterate: Int
) -> Bool:
    for s in range(len(comp)):
        if produces_single_tile_coincidence(sigma, a.states[comp[s]], max_iterate):
            return True
    return False


def component_is_caught(
    sigma: Substitution, a: Automaton, comp: List[Int], max_iterate: Int
) -> Bool:
    for s in range(len(comp)):
        if synchronizing_cut_count(sigma, a.states[comp[s]], max_iterate) > 0:
            return True
    return False


struct SweepTally(Copyable, Movable):
    """Counts accumulated over a boundary-synchronization sweep."""

    var trials: Int
    var primitive: Int
    var capped: Int
    var length_exhausted: Int
    var components: Int
    var productive: Int
    var caught: Int
    var productive_but_missed: Int
    var caught_but_unproductive: Int

    def __init__(out self):
        self.trials = 0
        self.primitive = 0
        self.capped = 0
        self.length_exhausted = 0
        self.components = 0
        self.productive = 0
        self.caught = 0
        self.productive_but_missed = 0
        self.caught_but_unproductive = 0

    def record_component(mut self, productive: Bool, caught: Bool):
        self.components += 1
        self.productive += 1 if productive else 0
        self.caught += 1 if caught else 0
        self.productive_but_missed += 1 if productive and not caught else 0
        self.caught_but_unproductive += 1 if caught and not productive else 0

    def print_lines(self):
        print("trials drawn:", self.trials)
        print("primitive specimens:", self.primitive)
        print("specimens inconclusive (state budget):", self.capped)
        print("specimens inconclusive (length budget):", self.length_exhausted)
        print("recurrent noncoincident SCCs:", self.components)
        print("productive SCCs:", self.productive)
        print("boundary-synchronization caught SCCs:", self.caught)
        print("productive but missed:", self.productive_but_missed)
        print("caught but not productive at this level:", self.caught_but_unproductive)


struct SweepConfig(Copyable, Movable):
    """Everything that determines a sweep, so a run is reproducible from it."""

    var seed: Int
    var trials: Int
    var sizes: List[Int]
    var min_image: Int
    var max_image: Int
    var max_states: Int
    var max_length: Int
    var max_iterate: Int

    def __init__(
        out self,
        seed: Int,
        trials: Int,
        var sizes: List[Int],
        min_image: Int,
        max_image: Int,
        max_states: Int,
        max_length: Int,
        max_iterate: Int,
    ):
        self.seed = seed
        self.trials = trials
        self.sizes = sizes^
        self.min_image = min_image
        self.max_image = max_image
        self.max_states = max_states
        self.max_length = max_length
        self.max_iterate = max_iterate


def substitution_key(sigma: Substitution) -> String:
    """`sigma(0)/sigma(1)/...` with one digit per letter."""
    var out = String("")
    for a in range(sigma.size):
        if a > 0:
            out += "/"
        for j in range(len(sigma.images[a])):
            out += String(sigma.images[a][j])
    return out


def run_sweep(config: SweepConfig, report: Bool = False) raises -> SweepTally:
    """Draw `config.trials` substitutions and compare the two verdicts on every
    recurrent noncoincident component. With `report`, the first productive
    component that no synchronizing cut catches is printed as an exact witness."""
    var rng = SplitMix64(config.seed)
    var tally = SweepTally()
    var printed_witness = False

    for _ in range(config.trials):
        tally.trials += 1
        var size = rng.choice(config.sizes)
        var sigma = random_substitution(rng, size, config.min_image, config.max_image)
        if not is_primitive_substitution(sigma):
            continue
        tally.primitive += 1

        var bounded = build_bounded(sigma, config.max_states, config.max_length)
        if not bounded.complete():
            if bounded.exhausted == BUDGET_LENGTH:
                tally.length_exhausted += 1
            else:
                tally.capped += 1
            continue

        ref a = bounded.graph
        var comps = recurrent_noncoincident_sccs(a)
        for ci in range(len(comps)):
            var productive = component_is_productive(sigma, a, comps[ci], config.max_iterate)
            var caught = component_is_caught(sigma, a, comps[ci], config.max_iterate)
            tally.record_component(productive, caught)
            if report and productive and not caught and not printed_witness:
                print(
                    "SYNC_MISS_JSON {\"sigma\":\"" + substitution_key(sigma)
                    + "\",\"size\":" + String(size)
                    + ",\"scc\":" + String(ci)
                    + ",\"scc_size\":" + String(len(comps[ci]))
                    + ",\"state\":\"" + a.states[comps[ci][0]].key() + "\"}"
                )
                printed_witness = True
    return tally^
