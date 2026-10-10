"""All affine F2^3 structures on eight rows; no distinguished structure.

The planes encode a ternary heap operation. Translations act on a marked
row in the decorated state, not as new transformations of an unlabeled
packing configuration. Everything here is an exact finite experiment.
"""

from itertools import permutations, combinations


def standard_planes():
    return tuple(q for q in combinations(range(8), 4)
                 if q[0] ^ q[1] ^ q[2] ^ q[3] == 0)


def relabel(planes, p):
    if tuple(sorted(p)) != tuple(range(8)):
        raise ValueError("relabeling must be a permutation of eight rows")
    return tuple(sorted(tuple(sorted(p[i] for i in q)) for q in planes))


def structures():
    return tuple(sorted({relabel(standard_planes(), p)
                         for p in permutations(range(8))}))


def heap(planes, a, b, c):
    if any(type(i) is not int or not 0 <= i < 8 for i in (a,b,c)):
        raise ValueError("row indices must be canonical integers in range(8)")
    if a == b:
        return c
    if a == c:
        return b
    if b == c:
        return a
    triple = {a,b,c}
    matches = [set(q) - triple for q in planes if triple <= set(q)]
    if len(matches) != 1 or len(matches[0]) != 1:
        raise ValueError("planes do not specify a unique ternary completion")
    return next(iter(matches[0]))


def translations(planes, origin):
    return tuple(sorted(tuple(heap(planes, origin, target, v) for v in range(8))
                        for target in range(8)))


def compose(p, q):
    return tuple(p[q[i]] for i in range(8))


def run():
    all_structures = structures()
    return {"affine_structures": len(all_structures),
            "planes_per_structure": len(standard_planes()),
            "relabeling_stabilizer_order": 40320 // len(all_structures),
            "marked_decorations_per_labeled_configuration": 8*len(all_structures),
            "translation_group_order_per_structure": 8,
            "distinguished_structure_selected": False,
            "new_action_on_unlabeled_packing_established": False,
            "lean_certified": False}


if __name__ == "__main__":
    print(run())
