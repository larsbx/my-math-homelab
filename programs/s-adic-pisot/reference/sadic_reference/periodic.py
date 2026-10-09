"""Periodic directive words: necklaces, admissibility of w^infinity, and the
unordered Brun family of BST23 (6.9)/(6.10) (oracle for kernel/sadic)."""

from __future__ import annotations

from sadic_reference import DirectiveShift


def brun_unordered(d: int) -> DirectiveShift:
    """BST23 (6.9): `beta_{i,j}: j -> i j`, `k -> k`, labels the pairs i != j
    in lexicographic order; (6.10): `beta_{i,j}` may be followed by itself or
    by any `beta_{j,k}`. State 0 is initial and admits every label; state
    `1 + label` remembers the last label."""
    pairs = [(i, j) for i in range(d) for j in range(d) if i != j]
    subs = tuple(tuple((i, j) if k == j else (k,) for k in range(d)) for i, j in pairs)
    first = tuple(1 + t for t in range(len(pairs)))
    rows = [first]
    for i, j in pairs:
        rows.append(tuple(1 + t if (k, l) == (i, j) or k == j else -1 for t, (k, l) in enumerate(pairs)))
    return DirectiveShift(f"brun-unordered-{d}", subs, tuple(rows), 0)


def periodic_admissible(shift: DirectiveShift, word) -> bool:
    """Whether `word^infinity` labels an infinite path from some state: the
    partial map `q -> run(word, q)` has a cycle."""
    states = len(shift.transitions)
    for q in range(states):
        seen = set()
        while q >= 0 and q not in seen:
            seen.add(q)
            q = shift.run(word, q)
        if q >= 0:
            return True
    return False


def is_lyndon(w) -> bool:
    """Strictly least among its rotations, hence aperiodic."""
    return all(w < w[i:] + w[:i] for i in range(1, len(w)))


def periodic_words(shift: DirectiveShift, n: int) -> list[tuple[int, ...]]:
    """Lyndon words w of length n with w^infinity admissible, in lexicographic
    order: one representative per primitive periodic directive sequence up to
    rotation. Prefixes are pruned by admissibility from some state."""
    out = []

    def extend(w):
        if len(w) == n:
            if is_lyndon(w) and periodic_admissible(shift, w):
                out.append(w)
            return
        for a in range(shift.labels):
            v = w + (a,)
            if shift.admits_somewhere(v):
                extend(v)

    extend(())
    return out


def periodic_verdict(shift: DirectiveShift, w, max_states: int, max_length: int) -> str:
    """The first failing stage of primitive -> irreducible -> Pisot -> BPA, or
    the BPA outcome (kernel/sadic/periodic.mojo, same strings)."""
    from sadic_reference import compose_all, prefix_matrix
    from sadic_reference.bpa import balanced_pair_algorithm
    from sadic_reference.spectrum import charpoly, irreducibility_verdict, pisot_verdict, primitivity_exponent
    m = prefix_matrix(shift, w)
    if primitivity_exponent(m) < 0:
        return "not-primitive"
    f = charpoly(m)
    irr = irreducibility_verdict(f)[0]
    if irr != 1:
        return f"irreducible:{irr}"
    pv = pisot_verdict(f)
    if pv != 1:
        return f"pisot:{pv}"
    return "bpa:" + balanced_pair_algorithm(compose_all(shift, w), max_states, max_length)


def brun_pairs(d: int) -> list[tuple[int, int]]:
    """The labels of brun_unordered(d): pairs (i, j), i != j, lexicographically."""
    return [(i, j) for i in range(d) for j in range(d) if i != j]


def _least_rotation(w):
    return min(w[i:] + w[:i] for i in range(len(w)))


def brun_relabelings(d: int, w) -> set:
    """The rotation classes (least rotations) of w under every letter
    permutation pi, acting on labels by beta_{i,j} -> beta_{pi(i),pi(j)}."""
    from itertools import permutations
    pairs = brun_pairs(d)
    index = {pair: t for t, pair in enumerate(pairs)}
    return {_least_rotation(tuple(index[(pi[pairs[t][0]], pi[pairs[t][1]])] for t in w))
            for pi in permutations(range(d))}


def brun_orbit_words(d: int, n: int) -> list[tuple[tuple[int, ...], int]]:
    """One representative per orbit of the periodic words of length n under
    rotation and letter permutation: the least word of its orbit, with the
    orbit size (number of rotation classes it contains)."""
    shift = brun_unordered(d)
    out = []
    for w in periodic_words(shift, n):
        orbit = brun_relabelings(d, w)
        if w == min(orbit):
            out.append((w, len(orbit)))
    return out


def initial_letters(sigma) -> tuple[int, ...]:
    return tuple(image[0] for image in sigma)


def final_letters(sigma) -> tuple[int, ...]:
    return tuple(image[-1] for image in sigma)


def in_mirror_barge_class(sigma) -> bool:
    """Constant on initial letters and injective on final letters: the
    reversal of sigma is then in Barge's class (Barge 2016, Theorem 3.13)."""
    return len(set(initial_letters(sigma))) == 1 and len(set(final_letters(sigma))) == len(sigma)


def is_pip(shift: DirectiveShift, w) -> bool:
    """sigma_w is primitive with an irreducible Pisot characteristic polynomial."""
    from sadic_reference import prefix_matrix
    from sadic_reference.spectrum import charpoly, irreducibility_verdict, pisot_verdict, primitivity_exponent
    m = prefix_matrix(shift, w)
    if primitivity_exponent(m) < 0:
        return False
    f = charpoly(m)
    return irreducibility_verdict(f)[0] == 1 and pisot_verdict(f) == 1


def brun_full_classes(d: int, n: int) -> list[tuple[int, ...]]:
    """One word per class of periodic words of length n under rotation and
    letter permutation, among those using every letter (Theorem B: a
    primitive composite uses every letter); the classes are the orbits of
    brun_orbit_words."""
    pairs = brun_pairs(d)
    return [w for w, _ in brun_orbit_words(d, n) if len({x for t in w for x in pairs[t]}) == d]
