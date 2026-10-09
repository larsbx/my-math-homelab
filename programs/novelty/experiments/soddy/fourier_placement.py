"""Exact admissible Fourier placement, invisible on unlabeled configurations."""

from experiments.soddy import n6_f7_orbits as arithmetic
from experiments.soddy import intrinsic_selection as selection


def fourier():
    # Character table of the additive group F_2^3, with values in F_7.
    return [[1 if (i & j).bit_count() % 2 == 0 else 6
             for j in range(8)] for i in range(8)]


def placed_defects():
    phi, inv = arithmetic.bridge_isometry()
    f = fourier()
    transition = arithmetic.mat_mul(phi, arithmetic.mat_mul(f, inv))
    transition_inv = arithmetic.mat_inv(transition)
    return [arithmetic.mat_mul(transition,
            arithmetic.mat_mul(d, transition_inv))
            for d in arithmetic.defect_generators()]


def centralizer(a, t):
    # 8=1 in F_7: t=a+8b=a+b.
    b = (t-a) % 7
    return [[(a*int(i == j)+b) % 7 for j in range(8)] for i in range(8)]


def run():
    f = fourier()
    if arithmetic.mat_mul(arithmetic.transpose(f), f) != arithmetic.eye():
        raise ValueError("Fourier matrix violates its orthogonal identity")
    defects = placed_defects()
    if not all(selection.is_permutation(d) and selection.certify(d)["accepted"]
               for d in defects):
        raise ValueError("Fourier placement fails quotient graph compatibility")
    return {
        "field": "F_7", "packing_dimension": 6,
        "fourier_orthogonal": True,
        "admissible_defect_operators": len(defects),
        "all_defects_are_row_permutations": True,
        "unlabeled_defect_action": "identity",
        "centralizer_cases": [
            {"a": a, "t": t,
             "graph_compatible": selection.certify(centralizer(a, t))["accepted"]}
            for a in (1,6) for t in (1,6)],
        "intrinsic_uniqueness_established": False,
    }


if __name__ == "__main__":
    import json
    print(json.dumps(run(), indent=2, sort_keys=True))
