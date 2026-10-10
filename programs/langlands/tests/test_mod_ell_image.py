"""Images of rho_ell forced from point counts: 37a1 is surjective mod 3, 5, 7; 11a1 (rational 5-torsion)
is not forced mod 5; and the criterion refuses to conclude from too little data."""
from pathlib import Path

import pytest

from langlands.mod_ell_image import GL2, forced_full, forced_full_classes, frobenius_charpolys
from langlands.newforms import CREMONA_PRIME_LEVEL, newforms_of_level

E37 = newforms_of_level(37)[0]
E11 = newforms_of_level(11)[0]


@pytest.mark.parametrize("ell", [5, 7])
def test_37a1_mod_ell_image_is_forced_full(ell):
    """Every subgroup of GL_2(F_ell) meeting the Frobenius charpoly classes of 37a1 (p <= 60) is the whole group."""
    polys = frobenius_charpolys(E37, ell, 60)
    assert forced_full(ell, polys), (ell, polys)


def test_37a1_mod_3_needs_a_matrix():
    """Mod 3, characteristic polynomials alone cannot force surjectivity: (x-1)^2 is shared by the identity
    and the unipotents, and the normaliser of the non-split Cartan (order 16) meets every observed charpoly
    class.  Refining (x-1)^2 to its non-scalar part -- what the computed matrix at p = 7 supplies, and what
    proof/langlands/LanglandsOracles/ImageMod3.lean certifies -- forces GL_2(F_3)."""
    polys = frobenius_charpolys(E37, 3, 60)
    assert (2, 1) in polys and not forced_full(3, polys)
    G = GL2(3)
    one = G.index[(1, 0, 0, 1)]
    classes = [tuple(i for i in G.with_charpoly(chi) if not (chi == (2, 1) and i == one)) for chi in dict.fromkeys(polys)]
    assert forced_full_classes(G, classes)


@pytest.mark.parametrize("ell", [5, 7])
def test_all_cremona_curves_mod_ell(ell):
    """From point counts p <= 60: every curve's mod-ell image is forced full except 11a1 mod 5 (rational 5-torsion)."""
    not_forced = [f.label for f in CREMONA_PRIME_LEVEL if not forced_full(ell, frobenius_charpolys(f, ell, 60))]
    assert not_forced == (["11a1"] if ell == 5 else []), not_forced


def test_11a1_mod_5_is_not_forced():
    """11a1 has a rational 5-torsion point, so its mod-5 image lies in a Borel: the recursion must find
    a proper subgroup meeting every observed class (a genuine obstruction, not a failure of data)."""
    polys = frobenius_charpolys(E11, 5, 200)
    assert all((1 - t + d) % 5 == 0 for t, d in polys)  # eigenvalue 1 on the rational point
    assert not forced_full(5, polys)


def test_too_little_data_is_not_forced():
    """Classes lying in a common Borel never force GL_2(F_5)."""
    assert not forced_full(5, ((0, 4),))           # x^2 - 1: diag(1, -1) type
    assert not forced_full(5, ((2, 1), (0, 4)))    # unipotent charpoly and diag(1, -1): both inside a Borel


def test_group_orders():
    assert GL2(3).n == 48 and GL2(5).n == 480 and GL2(7).n == 2016


def test_mod5_certificate_classes_of_37a1():
    """The Frobenius classes of 37a1 at p = 2, 3: x^2 - 3x + 2 (30 elements, a single conjugacy class of
    diag(1, 2)) and x^2 - 2x + 3 (20 elements); every pair generates GL_2(F_5), and the first representative
    in Lean's enumeration order has base-5 code 455 (the mod-5 certificate in ImageModL.lean uses this class
    as B of its first certified pair)."""
    from langlands.newforms import newforms_of_level
    E37 = newforms_of_level(37)[0]
    assert (E37.a(2) % 5, E37.a(3) % 5) == (3, 2)
    G = GL2(5)
    A, B = G.with_charpoly((3, 2)), G.with_charpoly((2, 3))
    assert (len(A), len(B)) == (30, 20)
    assert len(G.conjugacy_class_representatives(A)) == 1 and len(G.conjugacy_class_representatives(B)) == 1
    full = frozenset(range(G.n))
    assert all(G.generated(frozenset({g, h})) == full for g in A for h in B)
    code = lambda m: m[0] + 5 * (m[1] + 5 * (m[2] + 5 * m[3]))
    assert code(G.elements[A[0]]) == 455


def test_words_to_are_shortest_words():
    """COMPUTED: the bidirectional search returns valid words of minimal length, checked against a plain
    breadth-first search over the multiplication table on GL_2(F_5) and GL_2(F_7) for every element of a class
    B against a class-A representative (the exporter's use)."""
    for ell, zeta in [(5, 2), (7, 3)]:
        G = GL2(ell)
        S = [G.index[(1, 1, 0, 1)], G.index[(1, 0, 1, 1)], G.index[(1, 0, 0, zeta)]]
        A, B = G.with_charpoly((1, 1)), G.with_charpoly((0, 1))
        gens = [A[0], B[0]]
        for h in B:
            gens = [A[0], h]
            # reference: breadth-first over words, lengths only
            dist = {g: 1 for g in gens}
            frontier = list(dict.fromkeys(gens))
            while frontier:
                nxt = []
                for x in frontier:
                    for g in gens:
                        y = G.table[x][g]
                        if y not in dist:
                            dist[y] = dist[x] + 1
                            nxt.append(y)
                frontier = nxt
            ws = G.words_to(gens, S)
            for s in S:
                w = ws[s]
                assert (len(w) == dist[s]) if s in dist else (w == [])
                if w:
                    val = gens[w[0]]
                    for b in w[1:]:
                        val = G.mul(val, gens[b])
                    assert val == s


@pytest.mark.parametrize("ell", [2, 3])
def test_words_to_handles_target_order_and_unreachable_components(ell):
    """COMPUTED: whole-layer reuse preserves shortest nonempty words in either target order; searches
    outside the generated subgroup terminate. Covers duplicate generators and the identity target."""
    from collections import deque
    from itertools import product

    G = GL2(ell)
    u, v = G.index[(1, 1, 0, 1)], G.index[(1, 0, 1, 1)]
    generator_lists = (list(product(range(G.n), repeat=2)) if ell == 2 else
                       [(G.one,), (u,), (u, u), (u, v)])
    for gens in generator_lists:
        dist = {g: 1 for g in gens}
        todo = deque(dist)
        while todo:
            x = todo.popleft()
            for g in gens:
                y = G.table[x][g]
                if y not in dist:
                    dist[y] = dist[x] + 1
                    todo.append(y)
        # Unreachable / deepest targets first can exhaust or grow the shared forward search;
        # reversing that order also covers targets already reached during an earlier search.
        targets = sorted(range(G.n), key=lambda t: dist.get(t, G.n), reverse=True)
        for order in (targets, targets[::-1]):
            ws = G.words_to(list(gens), order)
            assert set(ws) == set(order)
            for target, word in ws.items():
                assert len(word) == dist.get(target, 0)
                if word:
                    value = gens[word[0]]
                    for letter in word[1:]:
                        value = G.table[value][gens[letter]]
                    assert value == target


def test_words_to_without_generators_are_unreachable():
    """COMPUTED: with no generators no nonempty word exists, including for the identity target;
    words_to uses [] as unreachable, rather than an empty-word identity certificate."""
    G = GL2(3)
    targets = [G.one, 0, G.one]
    assert G.words_to([], targets) == {t: [] for t in targets}
    assert G.words_to([], []) == {}


def test_generated_by_nothing_is_trivial():
    """The empty generating set generates {1}, with or without the multiplication table (review fix: the
    vectorised closure concatenated an empty list of product columns)."""
    groups = (GL2(5), GL2(5, table=False), GL2(11))
    assert groups[0].table is not None and groups[1].table is None and groups[2].table is None
    for G in groups:
        assert G.generated(frozenset()) == frozenset({G.one})


def test_conjugacy_pruning_only_for_invariant_sets():
    """Reducing the first set to conjugacy representatives is sound only when every set is closed under
    conjugation.  In GL_2(F_2) the sets [(0, 3), (3,)] are not: element 3 alone generates a proper subgroup
    meeting both, so the answer must be False (a pruned search would wrongly certify the full image)."""
    G = GL2(2)
    assert not G.is_conjugation_invariant((3,)) or len(G.conjugates(3)) == 1
    sets = [(0, 3), (3,)]
    if G.is_conjugation_invariant((3,)):
        pytest.skip("element 3 is central in this enumeration; pick a non-invariant set")
    assert not forced_full_classes(G, sets)
    # with every element of the first set tried, the proper subgroup <3> is found; invariant sets are still pruned
    assert G.is_conjugation_invariant(G.with_charpoly((1, 1)))


def _parse_cert(ell):
    """The exported mod-ell certificate from DataModL{ell}.lean: S, pairs (tA, dA, tB, dB, gRep, witnesses, words), curves."""
    import re
    text = (Path(__file__).resolve().parents[1] / "proof" / "langlands" / "LanglandsOracles" / f"DataModL{ell}.lean").read_text()
    block = text[text.index(f"def mod{ell}Pair0"):text.index("\nend Oracles", text.index(f"def mod{ell}Cert"))]
    S = [int(v) for v in re.search(r"S := \[([^\]]*)\]", block).group(1).split(",")]
    pairs = []
    for m in re.finditer(r"tA := (\d+), dA := (\d+), tB := (\d+), dB := (\d+), gRep := (\d+),\s*witnessesA := \[(.*?)\],\s*wordsB := \[(.*?)\] \}", block, re.S):
        tA, dA, tB, dB, gRep = (int(m.group(i)) for i in range(1, 6))
        wit = [tuple(int(v) for v in w) for w in re.findall(r"\((\d+), (\d+), (\d+)\)", m.group(6))]
        words = [(int(h), [(int(s), [c == "1" for c in bin(int(w))[3:]])  # 0b1 marker, then the letters
                           for s, w in re.findall(r"\((\d+), (\d+)\)", ws)])
                 for h, ws in re.findall(r"\((\d+), \[((?:\(\d+, \d+\)(?:, )?)+)\]\)", m.group(7))]
        pairs.append((tA, dA, tB, dB, gRep, wit, words))
    curves = re.findall(r'label := "([^"]+)", ainvs := \[([^\]]*)\], pair := (\d+), p1 := (\d+), p2 := (\d+)', block)
    return S, pairs, curves


@pytest.mark.parametrize("ell,zeta", [(5, 2), (7, 3), (11, 2), (13, 2), (17, 3), (19, 2), (23, 5), (29, 2), (31, 3)])
def test_word_certificates_are_valid(ell, zeta):
    """Mirror of proof/langlands/LanglandsOracles/ImageModL.lean: S = {E12(1), E21(1), diag(1, zeta)} generates GL_2(F_ell);
    for every certified pair, the conjugators send gRep onto every element of class A, the words in {gRep, h}
    evaluate to S for every h in class B, and the classes are single conjugacy classes without scalars; for
    ell <= 7 additionally every (g, h) in A x B generates (the fact the words certify)."""
    G = GL2(ell)
    full = frozenset(range(G.n))
    code = lambda i: (lambda m: m[0] + ell * (m[1] + ell * (m[2] + ell * m[3])))(G.elements[i])
    decode = {code(i): i for i in range(G.n)}
    S, pairs, curves = _parse_cert(ell)
    assert [G.elements[decode[s]] for s in S] == [(1, 1, 0, 1), (1, 0, 1, 1), (1, 0, 0, zeta)]
    assert G.generated(frozenset(decode[s] for s in S)) == full
    assert pairs and curves
    assert len(pairs) == block_pair_count(ell)
    for tA, dA, tB, dB, gRep, wit, words in pairs:
        A, B = G.with_charpoly((tA, dA)), G.with_charpoly((tB, dB))
        assert decode[gRep] == A[0]
        # in the enumeration order of the class (Lean's `classMats`: lexicographic in (a, b, c)), which the kernel walks pointwise
        assert [g for g, _, _ in wit] == [code(g) for g in A] and [h for h, _ in words] == [code(h) for h in B]
        for g, C, Ci in wit:
            assert G.mul(decode[C], decode[Ci]) == G.one and G.mul(G.mul(decode[C], decode[gRep]), decode[Ci]) == decode[g]
        for h, ws in words:
            assert [s for s, _ in ws] == S
            for s, w in ws:
                gens = [decode[gRep], decode[h]]
                val = gens[w[0]]
                for b in w[1:]:
                    val = G.mul(val, gens[b])
                assert val == decode[s]
        if ell <= 7:
            assert len(G.conjugacy_class_representatives(A)) == 1 and len(G.conjugacy_class_representatives(B)) == 1
            assert all(G.generated(frozenset({g, h})) == full for g in A for h in B)
    labels = [c[0] for c in curves]
    assert labels == ([l for l in ALL_LABELS if l != "11a1"] if ell == 5 else ALL_LABELS)


ALL_LABELS = [f.label for f in CREMONA_PRIME_LEVEL]


def block_pair_count(ell):
    import re
    text = (Path(__file__).resolve().parents[1] / "proof" / "langlands" / "LanglandsOracles" / f"DataModL{ell}.lean").read_text()
    return int(re.search(rf"Mod-{ell} image certificates: S, (\d+) certified class pairs", text).group(1))
