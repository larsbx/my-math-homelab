#!/usr/bin/env python3
"""Exact, operator-quotiented H3 experiment; see docs/experiments/h3-conditioned-shell.md.

No characteristic polynomial enters a label, a quotient, or a statistic. The
sample unit is a (left-comb value, integer L-product) class. First and last
lexicographic representatives are both analysed because letter invariants
need not descend to this quotient. All collision fibres are certified.
"""
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import sys
from collections import Counter, defaultdict
from fractions import Fraction
from itertools import combinations, combinations_with_replacement
from math import isqrt
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
sys.path.insert(0, str(HERE))

import defect_census as C  # noqa: E402
import h3_integral as PILOT  # noqa: E402

OUT = ROOT / "data/n2/h3-conditioned-v1.json"
CERTS = ROOT / "data/n2/h3-conditioned-certificates-v1.json.gz"
BASE_REVISION = "664fcc39f104a08fddc7c255d0c925b6262d035f"
# Fixed in advance, including a second seed, a second shell and length five.
CONFIGS = ((3, 10, 1, 4), (3, 10, 2, 4), (5, 8, 1, 4), (3, 5, 1, 5))
COMPLEX = ((1, 2, 0, 0, 0, 0, 0, 0), (2, 1, 0, 0, 0, 0, 0, 0))
EXPLORATORY_EDGES = {
    "coordinate-1234-p3": tuple(combinations((1, 2, 3, 4), 2)),
    "coordinate-1247-p3": tuple(combinations((1, 2, 4, 7), 2)),
    "coordinate-cycle-12347-p3": ((1, 2), (2, 3), (3, 4), (4, 7), (7, 1)),
}


def compact(obj) -> str:
    return json.dumps(obj, sort_keys=True, separators=(",", ":"))


def digest(obj) -> str:
    return "sha256:" + hashlib.sha256(compact(obj).encode("utf-8")).hexdigest()


def choose2(n: int) -> int:
    return n * (n - 1) // 2


def ratio(a: int | Fraction, b: int | Fraction):
    """An exact reduced fraction, or null for an unsupported comparison."""
    return str(Fraction(a) / b) if b else None


def shell(n: int, dim: int = C.DIM) -> tuple[tuple[int, ...], ...]:
    """Same lexicographic shell as the pilot, using an integer square root."""
    if n < 0 or dim < 0:
        raise ValueError("nonnegative norm and dimension required")
    if dim == 0:
        return ((),) if n == 0 else ()
    r = isqrt(n)
    return tuple((t,) + rest for t in range(-r, r + 1)
                 for rest in shell(n - t * t, dim - 1))


def norm(x):
    return sum(t * t for t in x)


def conj(x):
    return (x[0],) + tuple(-t for t in x[1:])


def mul(x, y):
    """Integer product in the kernel's pinned convention; no modular lift."""
    out = [0] * C.DIM
    for (i, j), (k, sign) in C.STRUCTURE.items():
        out[k] += sign * x[i] * y[j]
    return tuple(out)


def left(x):
    columns = [mul(x, e) for e in C.BASIS]
    return tuple(zip(*columns))


def sparse_columns(a):
    return tuple(tuple((i, a[i][j]) for i in range(C.DIM) if a[i][j])
                 for j in range(C.DIM))


def right_multiply(a, columns):
    return tuple(tuple(sum(r[i] * t for i, t in col) for col in columns) for r in a)


def evaluate(letters):
    if not letters or any(len(a) != C.DIM for a in letters):
        raise ValueError("a nonempty word in eight-coordinate letters is required")
    v, product = letters[0], left(letters[0])
    for a in letters[1:]:
        v = mul(v, a)
        product = right_multiply(product, sparse_columns(left(a)))
    return v, product


def generators(p: int, m: int, seed: int):
    """SHA-256 rank sample without replacement; ties broken lexicographically.

    Only conjugation orbits of size two are eligible. Their lexicographic
    minimum is used in the population, so the formal inverse index is unique.
    Conjugates have norm p and are p times inverses, not inverses over Q.
    """
    population = tuple(x for x in shell(p) if x < conj(x))
    if not 1 <= m <= len(population):
        raise ValueError("generator count outside the conjugation-orbit population")
    ordered = sorted(population, key=lambda x: (digest(["h3-shell/v1", p, seed, x]), x))
    base = tuple(ordered[:m])
    return base + tuple(conj(x) for x in base)


def reduced(word, m):
    return all(b != (a + m) % (2 * m) for a, b in zip(word, word[1:]))


def enumerate_words(gens, length):
    """All reduced index tuples, lexicographic, with prefix arithmetic reused."""
    k, m = len(gens), len(gens) // 2
    columns = [sparse_columns(left(a)) for a in gens]

    def visit(word, value, product):
        if len(word) == length:
            yield word, value, product
            return
        for i, a in enumerate(gens):
            if i != (word[-1] + m) % k:
                yield from visit(word + (i,), mul(value, a), right_multiply(product, columns[i]))

    if length < 1:
        raise ValueError("positive word length required")
    for i, a in enumerate(gens):
        yield from visit((i,), a, left(a))


def rank_q(rows):
    """Rank over Q, independently of any finite-field degeneration."""
    a, rank = [list(map(Fraction, r)) for r in rows], 0
    for j in range(C.DIM):
        pivot = next((i for i in range(rank, len(a)) if a[i][j]), None)
        if pivot is None:
            continue
        a[rank], a[pivot] = a[pivot], a[rank]
        for i in range(rank + 1, len(a)):
            f = a[i][j] / a[rank][j]
            a[i] = [s - f * t for s, t in zip(a[i], a[rank])]
        rank += 1
    return rank


def bilinear(x, y):
    return 2 * sum(a * b for a, b in zip(x, y))


def pure(x):
    return (0,) + x[1:]


def phi(p, q, r):
    return bilinear(mul(p, q), r)


def psi(p, q, r, s):
    # The paper's convention: [p,q,r] = p(qr) - (pq)r.
    assoc = tuple(a - b for a, b in zip(mul(p, mul(q, r)), mul(mul(p, q), r)))
    return bilinear(assoc, s)


class Labels:
    def __init__(self, gens, length):
        self.gens, self.length = gens, length
        self.gram = [[bilinear(a, b) for b in gens] for a in gens]
        self.q = {}
        self.forms = {}
        if length >= 4:
            ps = [pure(a) for a in gens]
            for k, form in ((3, phi), (4, psi)):
                for ids in combinations(range(len(gens)), k):
                    self.forms[ids] = form(*(ps[i] for i in ids))

    def form(self, ids):
        if len(set(ids)) < len(ids):
            return 0
        sign = (-1) ** sum(a > b for i, a in enumerate(ids) for b in ids[i + 1:])
        return sign * self.forms[tuple(sorted(ids))]

    def __call__(self, word):
        classical = (2,) + tuple(2 * self.gens[i][0] for i in word) + tuple(
            self.gram[word[i]][word[j]]
            for i, j in combinations_with_replacement(range(len(word)), 2))
        if len(word) == 2:
            if word not in self.q:
                x, y = (self.gens[i] for i in word)
                self.q[word] = rank_q((C.BASIS[0], x, y, mul(x, y)))
            extra = (self.q[word],)
        else:
            extra = tuple(self.form(tuple(word[i] for i in ids))
                          for k in (3, 4) for ids in combinations(range(len(word)), k))
        return classical, extra


def quotient(gens, length):
    labels, classes = Labels(gens, length), {}
    for word, value, product in enumerate_words(gens, length):
        label = labels(word)
        key = value, product
        if key not in classes:
            classes[key] = {"value": value, "product": product, "count": 1,
                            "first": word, "last": word, "first_label": label,
                            "last_label": label, "ambiguous_classical": False,
                            "ambiguous_enriched": False}
        else:
            r = classes[key]
            r["count"] += 1
            r["last"], r["last_label"] = word, label
            r["ambiguous_classical"] |= label[0] != r["first_label"][0]
            r["ambiguous_enriched"] |= label != r["first_label"]
    return list(classes.values())


def moments(records, policy, enriched):
    cells = defaultdict(Counter)
    for r in records:
        classical, extra = r[policy + "_label"]
        cells[(classical, extra) if enriched else classical][r["value"]] += 1
    histogram = Counter()
    pairs = collisions = singletons = 0
    for counts in cells.values():
        n, c = sum(counts.values()), sum(choose2(t) for t in counts.values())
        histogram[n, len(counts), c] += 1
        pairs += choose2(n)
        collisions += c
        singletons += n == 1
    return {"strata": len(cells), "singleton_strata": singletons, "eligible_pairs": pairs,
            "value_only_pairs": collisions, "collision_rate": ratio(collisions, pairs),
            "cell_histogram": [{"size": n, "values": v, "collisions": c, "cells": t}
                               for (n, v, c), t in sorted(histogram.items())]}


def matched_controls(records, policy):
    """Exact noncollision null and label-permutation expectation, within Gram/trace blocks."""
    blocks = defaultdict(list)
    for r in records:
        classical, _ = r[policy + "_label"]
        blocks[classical, 2 * r["value"][0]].append(r)
    all_pairs = all_same = collisions = same = 0
    expectation = Fraction(0)
    blocks_with_collisions = informative = 0
    witness = None
    for key, group in sorted(blocks.items()):
        labels = Counter(r[policy + "_label"][1] for r in group)
        values = Counter(r["value"] for r in group)
        joint = Counter((r["value"], r[policy + "_label"][1]) for r in group)
        pairs = choose2(len(group))
        shared = sum(choose2(t) for t in labels.values())
        c = sum(choose2(t) for t in values.values())
        s = sum(choose2(t) for t in joint.values())
        all_pairs += pairs
        all_same += shared
        collisions += c
        same += s
        if c:
            blocks_with_collisions += 1
            informative += len(labels) > 1 and len(values) > 1
            expectation += Fraction(c * shared, pairs)
        if witness is None and len(values) > 1:
            a = min(group, key=lambda r: r[policy])
            b = min((r for r in group if r["value"] != a["value"]), key=lambda r: r[policy])
            witness = {"left": a[policy], "right": b[policy], "equal_gram_and_trace": True,
                       "values_equal": False, "extra_labels_equal": a[policy + "_label"][1] == b[policy + "_label"][1]}
    noncolliding, noncolliding_same = all_pairs - collisions, all_same - same
    return {"matching": "Gram(1, letters) and trace(value); quotient representatives",
            "eligible_pairs": all_pairs, "collision_pairs": collisions, "collision_same_extra": same,
            "noncollision_pairs": noncolliding, "noncollision_same_extra": noncolliding_same,
            "collision_share": ratio(same, collisions), "noncollision_share": ratio(noncolliding_same, noncolliding),
            "enrichment_ratio": ratio(Fraction(same, collisions), Fraction(noncolliding_same, noncolliding))
            if collisions and noncolliding else None,
            "permuted_label_expected_same": str(expectation), "blocks_with_collisions": blocks_with_collisions,
            "informative_blocks": informative, "noncollision_certificate": witness}


def word_id(word, k):
    out = 0
    for i in word:
        out = k * out + i
    return out


def word_indices(code, k, n):
    if not isinstance(code, int) or not 0 <= code < k ** n:
        raise ValueError("word identifier outside enumeration")
    return tuple((code // k ** j) % k for j in reversed(range(n)))


def certificate_record(r, k):
    # Operator equality/inequality is replayed as full matrices, not inferred
    # from hashes. Compact IDs retain every collision fibre without huge diffs.
    return [word_id(r["first"], k), word_id(r["last"], k), r["count"]]


def analyse(gens, length, config_id, stage="prespecified_sample"):
    records = quotient(gens, length)
    fibres = defaultdict(list)
    product_values = defaultdict(set)
    for r in records:
        fibres[r["value"]].append(r)
        product_values[r["product"]].add(r["value"])
    raw_operator = sum(choose2(r["count"]) for r in records)
    raw_value = sum(choose2(sum(r["count"] for r in group)) for group in fibres.values()) - raw_operator
    q_value = sum(choose2(len(group)) for group in fibres.values())
    collisions = [{"value": v, "classes": [certificate_record(r, len(gens)) for r in sorted(group, key=lambda r: r["first"])]}
                  for v, group in sorted(fibres.items()) if len(group) > 1]
    alias = next((r for r in records if r["count"] > 1), None)
    policies = {p: {"classical": moments(records, p, False), "enriched": moments(records, p, True),
                    "matched_control": matched_controls(records, p)} for p in ("first", "last")}
    row = {"id": config_id, "stage": stage, "length": length, "norm": norm(gens[0]), "generators": gens,
           "generator_digest": digest(gens), "words": sum(r["count"] for r in records),
           "operator_classes": len(records), "distinct_values": len(fibres),
           "operator_products_with_multiple_values": sum(len(v) > 1 for v in product_values.values()),
           "raw_operator_collision_pairs": raw_operator, "raw_value_only_pairs": raw_value,
           "quotient_value_only_pairs": q_value, "collision_fibres": len(collisions),
           "ambiguous_classical_classes": sum(r["ambiguous_classical"] for r in records),
           "ambiguous_enriched_classes": sum(r["ambiguous_enriched"] for r in records),
           "conditioning": "Gram plus dim Q" if length == 2 else "Gram plus all phi triples and psi quadruples",
           "policies": policies}
    cert = {"id": config_id, "length": length, "norm": norm(gens[0]), "generators": gens,
            "collision_fibres": collisions,
            "operator_alias": {"value": alias["value"], "class": certificate_record(alias, len(gens))} if alias else None,
            "noncollision_controls": {p: policies[p]["matched_control"]["noncollision_certificate"] for p in policies}}
    if length == 2:
        row["dim_Q_quotient_units"] = dict(sorted(Counter(r["first_label"][1][0] for r in records).items()))
    return row, cert


def exploratory_generators():
    """Support-seeking panels added after the prespecified rows lacked matched collisions.

    Every panel tried is retained, including the panels with no enrichment.
    These are structured corpora, not random or confirmatory samples.
    """
    yield "unit-p1", generators(1, 7, 1)
    base = tuple((2,) + tuple(-int(i == j) for i in range(1, 8)) for j in (1, 2, 3, 4, 7))
    yield "axis-12347-p5", base + tuple(conj(x) for x in base)
    for name, edges in EXPLORATORY_EDGES.items():
        base = []
        for i, j in edges:
            for sign in (-1, 1):
                v = [0] * C.DIM
                v[0], v[min(i, j)], v[max(i, j)] = 1, -1, sign
                base.append(tuple(v))
        base = tuple(base)
        yield name, base + tuple(conj(x) for x in base)


def read_certificates():
    return json.loads(gzip.decompress(CERTS.read_bytes()))


def negative_controls():
    """Retain the original pilot witness and the two form-only falsifiers."""
    import word_g2 as G
    source = json.loads((ROOT / "data/n2/word-g2-v1.json").read_text())
    forms = {}
    for kind, cert in source["certificates"].items():
        preserved = G.compare(tuple(map(tuple, cert["letters"])), tuple(map(tuple, cert["reflections"])), cert["ell"])
        forms[kind] = {**cert, "phi_preserved": preserved[0], "psi_preserved": preserved[1],
                       "charpoly_preserved": preserved[2]}
    v, a = evaluate(tuple(map(tuple, PILOT.CERTIFICATE["left"])))
    w, b = evaluate(tuple(map(tuple, PILOT.CERTIFICATE["right"])))
    return {"pilot_length_three": {**PILOT.CERTIFICATE, "value": v,
                                    "values_equal": v == w, "operators_equal": a == b},
            "finite_field_form_only": forms}


def build():
    rows, certificates = [], []
    for p, m, seed, length in CONFIGS:
        gens = generators(p, m, seed)
        name = f"p{p}-m{m}-s{seed}-n{length}"
        for n in (2, length):
            row, cert = analyse(gens, n, name if n == length else name.rsplit("-n", 1)[0] + "-n2")
            rows.append(row)
            certificates.append(cert)
        print(f"enumerated {name}: {row['words']} words, {row['quotient_value_only_pairs']} quotient collisions, "
              f"{row['policies']['first']['matched_control']['informative_blocks']} informative matched blocks",
              file=sys.stderr, flush=True)
    gens = COMPLEX + tuple(conj(x) for x in COMPLEX)
    row, cert = analyse(gens, 4, "complex-p5-m2-n4", "negative_control")
    rows.append(row)
    certificates.append(cert)
    for name, gens in exploratory_generators():
        row, cert = analyse(gens, 4, "exploratory-" + name, "exploratory_support_panel")
        rows.append(row)
        certificates.append(cert)
        print(f"enumerated exploratory-{name}: {row['quotient_value_only_pairs']} quotient collisions, "
              f"{row['policies']['first']['matched_control']['informative_blocks']} informative matched blocks",
              file=sys.stderr, flush=True)
    controls = negative_controls()
    bundle = {"schema": "novelty-lab/n2-h3-conditioned-certificates/v1",
              "class_encoding": "[first word ID, last word ID, multiplicity]; base-k IDs, first letter most significant",
              "rows": certificates, "controls": controls}
    cert_text = compact(bundle) + "\n"
    sources = ("experiments/n2/h3_conditioned.py", "experiments/n2/h3_integral.py",
               "experiments/n2/defect_census.py", "kernel/n1/cayley_dickson.py",
               "experiments/n2/word_g2.py", "experiments/n2/word_defects.py",
               "experiments/n2/rank_law.py", "data/n2/word-g2-v1.json")
    data = {"schema": "novelty-lab/n2-h3-conditioned/v1", "date": "2026-10-04", "base_revision": BASE_REVISION,
            "status": "bounded experiment; H3 open",
            "arithmetic": "unbounded Python integers; rational rank; B=2 dot product; no modular equality test",
            "runtime_contract": "Python 3.12+ standard library; SHA-256 sampling; no random module or floating point",
            "shell": "Z^8 in cayley-dickson/v1 (-1,-1,-1); standard coordinate order, not an E8/maximal order",
            "sample_population": "lexicographic minima of size-two conjugation orbits in S_p",
            "sampling": "m smallest (sha256(compact JSON [h3-shell/v1,p,seed,x]), x); append conjugates",
            "enumeration": "all lexicographic reduced index words; exclude adjacent conjugate indices",
            "quotient": "equal (left-comb value, exact L-product); one representative, multiplicity diagnostic only",
            "configs": CONFIGS, "controls": controls, "rows": rows,
            "exploratory_contract": "all five support panels retained; added after sampled rows had no Gram-matched collisions",
            "certificate_container": "gzip; digest binds decompressed canonical UTF-8 JSON, not compression bytes",
            "certificate_digest": "sha256:" + hashlib.sha256(cert_text.encode()).hexdigest(),
            "source_digests": {s: "sha256:" + hashlib.sha256((ROOT / s).read_bytes()).hexdigest() for s in sources}}
    return json.dumps(data, indent=2, sort_keys=True) + "\n", cert_text


def replay(bundle):
    """Verify every retained collision pair, both representatives, and negative controls."""
    pairs = 0
    for row in bundle["rows"]:
        gens = tuple(map(tuple, row["generators"]))
        n, m = row["length"], len(gens) // 2
        if tuple(conj(x) for x in gens[:m]) != gens[m:] or any(norm(x) != row["norm"] for x in gens):
            raise ValueError("invalid shell/conjugation convention")
        labels = Labels(gens, n)

        def checked(ids):
            ids = tuple(ids)
            if len(ids) != n or any(not 0 <= i < 2 * m for i in ids) or not reduced(ids, m):
                raise ValueError("invalid reduced word")
            return evaluate(tuple(gens[i] for i in ids))

        def checked_class(rec, expected):
            first, last, multiplicity = rec
            if multiplicity < 1 or first > last:
                raise ValueError("invalid quotient multiplicity/representative order")
            v, a = checked(word_indices(first, 2 * m, n))
            w, b = (v, a) if last == first else checked(word_indices(last, 2 * m, n))
            if v != expected or w != v or a != b:
                raise ValueError("collision certificate does not replay")
            return a

        for fibre in row["collision_fibres"]:
            expected = tuple(fibre["value"])
            operators = [checked_class(r, expected) for r in fibre["classes"]]
            if len(operators) < 2 or len(set(operators)) != len(operators):
                raise ValueError("operator collision was not quotiented out")
            pairs += choose2(len(operators))
        alias = row["operator_alias"]
        if alias:
            checked_class(alias["class"], tuple(alias["value"]))
            if alias["class"][0] == alias["class"][1] or alias["class"][2] < 2:
                raise ValueError("invalid operator-alias negative control")
        for policy, cert in row["noncollision_controls"].items():
            if cert:
                v, _ = checked(cert["left"])
                w, _ = checked(cert["right"])
                a, b = labels(tuple(cert["left"])), labels(tuple(cert["right"]))
                if v == w or v[0] != w[0] or a[0] != b[0] or (a[1] == b[1]) != cert["extra_labels_equal"]:
                    raise ValueError(f"invalid {policy} matched negative control")
    expected_controls = negative_controls()
    if compact(expected_controls) != compact(bundle["controls"]):
        raise ValueError("negative controls changed")
    c = expected_controls["pilot_length_three"]
    if not c["values_equal"] or c["operators_equal"]:
        raise ValueError("pilot value-only control failed")
    for kind, cert in expected_controls["finite_field_form_only"].items():
        if cert["charpoly_preserved"] or cert["phi_preserved"] != (kind == "phi_only") or cert["psi_preserved"] != (kind == "psi_only"):
            raise ValueError("form-only falsifier failed")
    return pairs


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true")
    mode.add_argument("--replay", action="store_true")
    args = parser.parse_args(argv)
    if args.replay:
        summary = json.loads(OUT.read_text())
        if "sha256:" + hashlib.sha256(gzip.decompress(CERTS.read_bytes())).hexdigest() != summary["certificate_digest"]:
            raise ValueError("certificate digest mismatch")
        bundle = read_certificates()
        if [(r["id"], r["generators"], r["quotient_value_only_pairs"]) for r in summary["rows"]] != [
                (r["id"], r["generators"], sum(choose2(len(f["classes"])) for f in r["collision_fibres"])) for r in bundle["rows"]]:
            raise ValueError("certificate coverage does not match the summary")
        print(f"OK: {replay(bundle)} quotient collision pairs replay")
        return 0
    text, cert_text = build()
    if args.check:
        ok = OUT.exists() and CERTS.exists() and OUT.read_text() == text and gzip.decompress(CERTS.read_bytes()).decode() == cert_text
        print("OK: conditioned H3 evidence is current" if ok else "stale: conditioned H3 evidence")
        return 0 if ok else 1
    OUT.write_text(text, encoding="utf-8")
    CERTS.write_bytes(gzip.compress(cert_text.encode("utf-8"), mtime=0))
    print(f"wrote {OUT.name} and {CERTS.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
