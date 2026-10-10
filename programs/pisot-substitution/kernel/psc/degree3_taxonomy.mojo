"""Exact taxonomy of the degree-3 catalogue rows.

A `Degree3Row` is one reachable noncoincident state with `K2 = 0`, `K3 != 0`
together with the substitution that reaches it and its carrier flags. The
summary classifies the rows by relabelling (`psc.symmetry`), reversal,
incidence arithmetic, the derived matrix `Theta(K3)`, and one- and two-step
inflation shape, printing the `DEGREE3_*` lines the CI workflow pins. This is
analysis of finite census output only, not a theorem about general PIP
substitutions.
"""

from std.collections import Set

from finite_linear_algebra.mat3 import Mat3
from finite_linear_algebra.tensor3 import theta
from psc.bpa import children, substitution_incidence
from psc.defect_degree import is_degree3
from psc.symmetry import (
    canonical_pair,
    canonical_substitution,
    normalised_pair,
    reversed_pair,
    reversed_substitution,
    substitution_key,
    word_less,
)
from psc.words import Pair, k3


struct Degree3Row(Copyable, Movable):
    var sigma: List[List[Int]]
    var state: Pair
    var recurrent: Bool
    var sink: Bool
    var centralizer: Bool
    var productive_within_two: Bool

    def __init__(
        out self,
        sigma: List[List[Int]],
        state: Pair,
        recurrent: Bool,
        sink: Bool,
        centralizer: Bool,
        productive_within_two: Bool,
    ):
        self.sigma = sigma.copy()
        self.state = state.copy()
        self.recurrent = recurrent
        self.sink = sink
        self.centralizer = centralizer
        self.productive_within_two = productive_within_two


def seed_length7() -> Pair:
    """The length-7 seed of the Spectral Black Box, `(0112201, 1200112)`."""
    var u: List[Int] = [0, 1, 1, 2, 2, 0, 1]
    var v: List[Int] = [1, 2, 0, 0, 1, 1, 2]
    return normalised_pair(u, v)


def commutes_with_theta(m: Mat3, state: Pair) -> Bool:
    """`M Theta(K3) == Theta(K3) M`: the centralizer test of the catalogue."""
    var a = theta(k3(state))
    return m * a == a * m


def coincidence_children(cs: List[Pair]) -> Int:
    var n = 0
    for i in range(len(cs)):
        if cs[i].is_coincidence():
            n += 1
    return n


def sorted_keys(keys: Set[String]) -> List[String]:
    var out = List[String]()
    for key in keys:
        out.append(key)
    sort(out)
    return out^


def sorted_ints(values: Set[Int]) -> List[Int]:
    var out = List[Int]()
    for v in values:
        out.append(v)
    sort(out)
    return out^


def csv(values: List[Int]) -> String:
    var out = String("")
    for i in range(len(values)):
        out += ("," if i > 0 else "") + String(values[i])
    return out


def poly_key(poly: List[Int]) -> String:
    return csv(poly)


struct Degree3Summary(Copyable, Movable):
    var occurrences: Int
    var state_classes: List[String]
    var sigma_classes: List[String]
    var lengths: List[Int]
    var seed_orbit_matches: Int
    var state_reversal_closed: Bool
    var sigma_reversal_closed: Bool
    var det_values: List[Int]
    var charpolys: List[List[Int]]
    var centralizer_hits: Int
    var theta_absdet2: Int
    var theta_trace_sq6: Int
    var length9_single_d3_successor: Int
    var length19_five_child_one_coincidence: Int
    var productive_within_two: Int

    def __init__(out self, rows: List[Degree3Row]):
        var state_keys = Set[String]()
        var sigma_keys = Set[String]()
        var lengths = Set[Int]()
        var dets = Set[Int]()
        var poly_keys = Set[String]()
        var polys = List[List[Int]]()
        var seed = canonical_pair(seed_length7())
        self.occurrences = len(rows)
        self.seed_orbit_matches = 0
        self.centralizer_hits = 0
        self.theta_absdet2 = 0
        self.theta_trace_sq6 = 0
        self.length9_single_d3_successor = 0
        self.length19_five_child_one_coincidence = 0
        self.productive_within_two = 0

        for r in range(len(rows)):
            ref row = rows[r]
            state_keys.add(canonical_pair(row.state).key())
            sigma_keys.add(substitution_key(canonical_substitution(row.sigma)))
            lengths.add(row.state.length())
            if canonical_pair(row.state) == seed:
                self.seed_orbit_matches += 1

            var m = Mat3(substitution_incidence(row.sigma))
            dets.add(m.det())
            var poly = m.charpoly()
            if poly_key(poly) not in poly_keys:
                poly_keys.add(poly_key(poly))
                polys.append(poly^)
            var a = theta(k3(row.state))
            if row.centralizer:
                self.centralizer_hits += 1
            if abs(a.det()) == 2:
                self.theta_absdet2 += 1
            if (a * a).trace() == 6:
                self.theta_trace_sq6 += 1

            var cs = children(row.sigma, row.state)
            var direct = coincidence_children(cs)
            if row.state.length() == 9 and len(cs) == 1 and cs[0].length() == 19 and is_degree3(cs[0]):
                self.length9_single_d3_successor += 1
            if row.state.length() == 19 and len(cs) == 5 and direct == 1:
                self.length19_five_child_one_coincidence += 1
            if row.productive_within_two:
                self.productive_within_two += 1

        self.state_classes = sorted_keys(state_keys)
        self.sigma_classes = sorted_keys(sigma_keys)
        self.lengths = sorted_ints(lengths)
        self.det_values = sorted_ints(dets)
        sort(polys, word_less)
        self.charpolys = polys^

        self.state_reversal_closed = True
        self.sigma_reversal_closed = True
        for r in range(len(rows)):
            ref row = rows[r]
            if canonical_pair(reversed_pair(row.state)).key() not in state_keys:
                self.state_reversal_closed = False
            if substitution_key(canonical_substitution(reversed_substitution(row.sigma))) not in sigma_keys:
                self.sigma_reversal_closed = False

    def charpoly_line(self) -> String:
        var out = String("")
        for i in range(len(self.charpolys)):
            out += (";" if i > 0 else "") + poly_key(self.charpolys[i])
        return out

    def print_lines(self):
        print("DEGREE3_OCCURRENCES", self.occurrences)
        print("DEGREE3_STATE_RELABEL_CLASSES", len(self.state_classes))
        print("DEGREE3_SUBSTITUTION_CONJUGACY_CLASSES", len(self.sigma_classes))
        print("DEGREE3_LENGTHS " + csv(self.lengths))
        print("DEGREE3_SEED_ORBIT_MATCHES", self.seed_orbit_matches)
        print("DEGREE3_STATE_REVERSAL_CLOSED", 1 if self.state_reversal_closed else 0)
        print("DEGREE3_SIGMA_REVERSAL_CLOSED", 1 if self.sigma_reversal_closed else 0)
        print("DEGREE3_SIGMA_DET_VALUES " + csv(self.det_values))
        print("DEGREE3_SIGMA_CHARPOLYS " + self.charpoly_line())
        print("DEGREE3_CENTRALIZER_HITS", self.centralizer_hits)
        print("DEGREE3_THETA_ABSDET2", self.theta_absdet2)
        print("DEGREE3_THETA_TRACE_SQ6", self.theta_trace_sq6)
        print("DEGREE3_LENGTH9_SINGLE_D3_SUCCESSOR", self.length9_single_d3_successor)
        print("DEGREE3_LENGTH19_FIVE_CHILD_ONE_COINCIDENCE", self.length19_five_child_one_coincidence)
        print("DEGREE3_PRODUCTIVE_WITHIN_TWO", self.productive_within_two)
        for i in range(len(self.state_classes)):
            print("DEGREE3_STATE_CLASS " + self.state_classes[i])
        for i in range(len(self.sigma_classes)):
            print("DEGREE3_SIGMA_CLASS " + self.sigma_classes[i])
