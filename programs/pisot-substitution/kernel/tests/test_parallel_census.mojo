"""Worker-count invariance for the MAX-parallel baseline BPA census."""

from std.testing import assert_equal, assert_true

from mojo_smoke.claims import require_contract
from psc.corpus import pip_corpus
from psc.parallel_census import BpaCensusResult, run_bpa_census


def assert_same(a: BpaCensusResult, b: BpaCensusResult) raises:
    assert_equal(a.terminated, b.terminated)
    assert_equal(a.capped, b.capped)
    assert_equal(a.productive, b.productive)
    assert_equal(a.nonproductive, b.nonproductive)
    assert_equal(a.max_size, b.max_size)
    assert_equal(a.failed_index, b.failed_index)
    assert_equal(len(a.nonproductive_indices), len(b.nonproductive_indices))
    for i in range(len(a.nonproductive_indices)):
        assert_equal(a.nonproductive_indices[i], b.nonproductive_indices[i])


def test_worker_count_does_not_change_the_record() raises:
    var corpus = pip_corpus()
    comptime SAMPLE = 24
    var sequential = run_bpa_census(corpus, SAMPLE, 1)
    assert_equal(sequential.failed_index, -1)
    for workers in [2, 3, 7]:
        var parallel = run_bpa_census(corpus, SAMPLE, workers)
        assert_same(sequential, parallel)


def test_invalid_worker_count_fails_closed() raises:
    var corpus = pip_corpus()
    var rejected = False
    try:
        _ = run_bpa_census(corpus, 8, 0)
    except:
        rejected = True
    assert_true(rejected)


def main() raises:
    test_worker_count_does_not_change_the_record()
    print("[PASS] test_worker_count_does_not_change_the_record")
    test_invalid_worker_count_fails_closed()
    print("[PASS] test_invalid_worker_count_fails_closed")
    print("2 parallel-census tests passed.")
    require_contract("MAX parallel BPA census worker-count invariance")
