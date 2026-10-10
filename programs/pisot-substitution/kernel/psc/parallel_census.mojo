"""Deterministic MAX-parallel outer fold for the baseline BPA census.

The mathematical unit remains one corpus specimen. Workers build and classify
independent B_sigma automata; they never print and never mutate shared state.
Their results are folded in canonical specimen order by the vendored
parallel_fold package, so changing the worker count cannot change the census
record.

A worker catches an execution exception only to encode the failing specimen
index in the fold. The driver then replays the first failure sequentially and
lets the original kernel raise. An execution failure therefore never becomes
a mathematical census outcome.
"""

from parallel_fold.map_fold import parallel_map_fold

from psc.bpa import build, nonproductive_states
from psc.corpus import STATE_CAP, Specimen


struct BpaCensusResult(Copyable, Movable):
    var terminated: Int
    var capped: Int
    var productive: Int
    var nonproductive: Int
    var max_size: Int
    var nonproductive_indices: List[Int]
    var failed_index: Int

    def __init__(
        out self,
        terminated: Int,
        capped: Int,
        productive: Int,
        nonproductive: Int,
        max_size: Int,
        nonproductive_indices: List[Int],
        failed_index: Int,
    ):
        self.terminated = terminated
        self.capped = capped
        self.productive = productive
        self.nonproductive = nonproductive
        self.max_size = max_size
        self.nonproductive_indices = nonproductive_indices.copy()
        self.failed_index = failed_index

    @staticmethod
    def empty() -> BpaCensusResult:
        return BpaCensusResult(0, 0, 0, 0, 0, List[Int](), -1)


def evaluate_specimen(spec: Specimen) -> BpaCensusResult:
    """One fail-closed specimen evaluation, with no I/O."""
    var out = BpaCensusResult.empty()
    try:
        var a = build(spec.sigma, STATE_CAP)
        if a.capped:
            out.capped = 1
            return out^
        out.terminated = 1
        out.max_size = a.size()
        if len(nonproductive_states(a)) == 0:
            out.productive = 1
        else:
            out.nonproductive = 1
            out.nonproductive_indices.append(spec.index)
        return out^
    except:
        var failed = BpaCensusResult.empty()
        failed.failed_index = spec.index
        return failed^


def merge_bpa_census(a: BpaCensusResult, b: BpaCensusResult) -> BpaCensusResult:
    """Associative, order-preserving merge used by parallel_map_fold."""
    var out = a.copy()
    out.terminated += b.terminated
    out.capped += b.capped
    out.productive += b.productive
    out.nonproductive += b.nonproductive
    if b.max_size > out.max_size:
        out.max_size = b.max_size
    for i in range(len(b.nonproductive_indices)):
        out.nonproductive_indices.append(b.nonproductive_indices[i])
    if b.failed_index >= 0 and (
        out.failed_index < 0 or b.failed_index < out.failed_index
    ):
        out.failed_index = b.failed_index
    return out^


def run_bpa_census(
    corpus: List[Specimen], count: Int, workers: Int
) raises -> BpaCensusResult:
    """Evaluate the first count canonical specimens on up to workers threads."""
    if count < 0 or count > len(corpus):
        raise Error("parallel BPA census count lies outside the corpus")

    def one(s: Int) {corpus} -> BpaCensusResult:
        return evaluate_specimen(corpus[s])

    return parallel_map_fold(
        one,
        merge_bpa_census,
        BpaCensusResult.empty(),
        count,
        workers,
    )


def replay_failure(corpus: List[Specimen], index: Int) raises:
    """Re-run the first worker failure sequentially so its kernel error is preserved."""
    if index < 0 or index >= len(corpus):
        raise Error("parallel BPA census failure index lies outside the corpus")
    var a = build(corpus[index].sigma, STATE_CAP)
    if a.capped:
        raise Error("parallel BPA census failure replay became capped")
    _ = nonproductive_states(a)
    raise Error("parallel BPA census worker failure did not replay")
