"""Exact global compatibility test for linear F7 configuration actions.

Scope: n=6, row-permutation quotient, fixed replacement multigraph.
No completeness claim over all octonion placements or graph automorphisms.
"""

from collections import Counter

from experiments.soddy import n6_f7_configurations as configuration
from experiments.soddy import n6_f7_orbits as arithmetic


def is_permutation(a):
    return (all(x in (0, 1) for row in a for x in row)
            and all(sum(row) == 1 for row in a)
            and all(sum(row) == 1 for row in arithmetic.transpose(a)))


def certify(candidate):
    """Necessary and sufficient identities for this linear quotient action.

    Invertible W allows cancellation on the right, so all configurations
    reduce to these finite matrix identities, without sampled vertices.
    """
    q = arithmetic.descartes_gram()
    configuration.validate(candidate, q)
    inv = arithmetic.mat_inv(candidate)
    conjugates = [arithmetic.mat_mul(candidate, arithmetic.mat_mul(
        configuration.adjacent_swap(i), inv)) for i in range(7)]
    quotient_ok = all(is_permutation(p) for p in conjugates)
    generators = arithmetic.apollonian_generators()
    left = Counter(configuration.unlabeled_key(arithmetic.mat_mul(candidate, s))
                   for s in generators)
    right = Counter(configuration.unlabeled_key(arithmetic.mat_mul(s, candidate))
                    for s in generators)
    adjacency_ok = left == right
    bad_index = next((i for i, p in enumerate(conjugates)
                      if not is_permutation(p)), None)
    return {
        "gram_preserved": True,
        "quotient_well_defined": quotient_ok,
        "neighbor_identity": adjacency_ok,
        "accepted": quotient_ok and adjacency_ok,
        "first_failed_swap": bad_index,
        "conjugated_swap_witness": None if bad_index is None
            else conjugates[bad_index],
        "neighbor_counts": {
            "transport_then_replace": [
                {"rows": [list(row) for row in key], "multiplicity": left[key]}
                for key in sorted(left)],
            "replace_then_transport": [
                {"rows": [list(row) for row in key], "multiplicity": right[key]}
                for key in sorted(right)],
        },
    }


def replay(candidate, certificate):
    """Reject stale or modified certificates by exact deterministic replay."""
    try:
        return certify(candidate) == certificate
    except (ValueError, TypeError, IndexError):
        return False


def census():
    cases = [certify(d) for d in arithmetic.defect_generators()]
    return {
        "scope": "basis defects at Phi=I+J, n=6 over F_7",
        "distinct_candidates": len(cases),
        "accepted_candidates": sum(c["accepted"] for c in cases),
        "accepted_nonidentity_candidates": sum(
            c["accepted"] and d != arithmetic.eye()
            for d, c in zip(arithmetic.defect_generators(), cases)),
        "certificates": cases,
        "all_placements_enumerated": False,
        "intrinsic_selection_established": False,
    }


if __name__ == "__main__":
    import json
    print(json.dumps(census(), sort_keys=True, indent=2))
