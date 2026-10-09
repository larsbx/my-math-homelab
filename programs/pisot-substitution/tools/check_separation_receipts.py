#!/usr/bin/env python3
"""Independent oracle for the archived Mojo sweep's receipt integrity.

Checks corpus membership/order, accounting, symmetry and proper-power witnesses.
Does not independently recompute separation radii or prove a universal claim.
"""
from __future__ import annotations
import argparse
from collections import Counter, defaultdict
from functools import lru_cache
import hashlib
import itertools
import json
from pathlib import Path
import re
import sys
from zipfile import ZipFile

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'reference'))
from psc_research.pip_screen import mat, charpoly, primitive, irreducible, pisot

ARCHIVE = Path(__file__).resolve().parents[1] / 'archive/2026-10-02/separation-radius-total-length'


def require(condition, message):
    if not condition:
        raise ValueError(message)


@lru_cache(maxsize=1)
def independent_corpus():
    words = [w for n in range(1, 7) for w in itertools.product(range(1, 4), repeat=n)]
    index = {w: i for i, w in enumerate(words)}
    by_length = {n: [w for w in words if len(w) == n] for n in range(1, 7)}
    cache, rows = {}, []
    for la in range(1, 7):
        for lb in range(1, 8-la):
            for lc in range(1, 9-la-lb):
                for a, b, c in itertools.product(by_length[la], by_length[lb], by_length[lc]):
                    matrix = mat({1: a, 2: b, 3: c})
                    key = tuple(x for row in matrix for x in row)
                    if key not in cache:
                        t, u, d = charpoly(matrix)
                        cache[key] = primitive(matrix) and irreducible(t, u, d) and pisot(t, u, d)
                    if cache[key]:
                        rows.append((tuple(index[w] for w in (a, b, c)),
                                     '/'.join(''.join(str(v-1) for v in w) for w in (a, b, c))))
    rows.sort()
    require(len(rows) == 24486, 'independent corpus cardinality changed')
    return rows


def orbit_key(images):
    sigma = tuple(tuple(map(int, w)) for w in images.split('/'))
    orbit = []
    for p in itertools.permutations(range(3)):
        for reverse in (False, True):
            conjugate = [None]*3
            for a, word in enumerate(sigma):
                conjugate[p[a]] = tuple(p[v] for v in (word[::-1] if reverse else word))
            orbit.append(tuple(conjugate))
    return '/'.join(''.join(map(str, w)) for w in min(orbit))


def check_log(log):
    records, obstructions, exceptions = [], [], []
    radii, witnesses, declared_orbits = Counter(), defaultdict(list), {}
    emitted_exceptions = []
    for line in log.splitlines():
        require(not line.startswith('INCONCLUSIVE'), 'inconclusive specimen retained')
        m = re.fullmatch(r'SEPARATED (\d+) (\d+) (\d+) ([012]+/[012]+/[012]+) radius (\d+)', line)
        if m:
            i, j, k, images, radius = m.groups()
            radius = int(radius)
            require(0 <= radius <= 12, 'radius outside declared budget')
            records.append(((int(i), int(j), int(k)), images))
            radii[radius] += 1
            if radius > 6:
                exceptions.append({'images': images, 'radius': radius, 'orbit': orbit_key(images)})
        m = re.fullmatch(r'OBSTRUCTED (\d+) (\d+) (\d+) ([012]+/[012]+/[012]+) orbit (.*)', line)
        if m:
            i, j, k, images, key = m.groups()
            require(key == orbit_key(images), 'incorrect obstruction orbit')
            records.append(((int(i), int(j), int(k)), images))
            obstructions.append(images)
        m = re.fullmatch(r'POWER_WITNESS ([012]+/[012]+/[012]+) pair (\d+) (\d+) level (\d+)', line)
        if m:
            images, a, b, n = m.groups()
            a, b, n = map(int, (a, b, n))
            require(0 <= a < b < 3 and 1 <= n <= 6, 'invalid power witness bounds')
            sigma = [tuple(map(int, w)) for w in images.split('/')]
            word = (a, b)
            for _ in range(n):
                word = tuple(v for x in word for v in sigma[x])
            require(any(len(word) % d == 0 and word == word[:d]*(len(word)//d)
                        for d in range(1, len(word))), 'false power witness')
            witnesses[images].append([a, b, n])
        m = re.fullmatch(r'EXCEPTIONAL ([012]+/[012]+/[012]+) radius (\d+) orbit (.*)', line)
        if m:
            images, radius, key = m.groups()
            emitted_exceptions.append({'images': images, 'radius': int(radius), 'orbit': key})
        m = re.fullmatch(r'EXCEPTIONAL_ORBIT (.*) members (\d+)', line)
        if m:
            key, count = m.groups()
            require(key not in declared_orbits, 'duplicate exceptional orbit')
            declared_orbits[key] = int(count)
    require(records == independent_corpus(), 'missing, duplicated or reordered corpus member')
    require(set(witnesses) == set(obstructions), 'obstruction without exact power witness')
    require(emitted_exceptions == exceptions, 'exceptional records disagree with specimen radii')
    require(declared_orbits == dict(Counter(r['orbit'] for r in exceptions)), 'incorrect orbit totals')
    require(log.splitlines().count('COMPLETE separation sweep: 24486 classified; 0 inconclusive') == 1,
            'missing or duplicated completion receipt')
    require(f'structurally nonseparating: {len(obstructions)} inconclusive: 0' in log,
            'incorrect structural accounting')
    hist = 'separation-radius distribution (decided specimens):' + ''.join(
        f' {k}:{radii[k]}' for k in sorted(radii))
    require(hist in log, 'histogram disagrees with specimen records')
    require(sum(radii.values()) + len(obstructions) == 24486, 'incomplete classification')
    return {'radii': {str(k): radii[k] for k in sorted(radii)},
            'structurally_nonseparating': len(obstructions),
            'exceptional_orbits': declared_orbits, 'exceptional_specimens': exceptions,
            'power_witnesses': dict(sorted(witnesses.items()))}


def check_archive(archive=ARCHIVE):
    for row in (archive / 'SHA256SUMS').read_text().splitlines():
        digest, name = row.split('  ', 1)
        require(name in {'evidence.zip', 'summary.json'}, 'unexpected archive hash path')
        require(hashlib.sha256((archive / name).read_bytes()).hexdigest() == digest,
                f'archive hash mismatch: {name}')
    with ZipFile(archive / 'evidence.zip') as zipped:
        raw = zipped.read('separation-radius.log')
        require(bool(zipped.read('build/claim-receipts.tsv')), 'missing test receipts')
    summary = json.loads((archive / 'summary.json').read_text())
    require(hashlib.sha256(raw).hexdigest() == summary['log_sha256'], 'log hash mismatch')
    require(hashlib.sha256((archive / 'evidence.zip').read_bytes()).hexdigest() == summary['artifact_sha256'],
            'artifact hash mismatch')
    computed = check_log(raw.decode())
    for key, value in computed.items():
        require(summary[key] == value, f'derived summary mismatch: {key}')
    return summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', type=Path, default=ARCHIVE)
    args = parser.parse_args()
    summary = check_archive(args.archive)
    print('OK: all 24486 identities, radius counts, exceptional orbits and power witnesses match')
    print('finite radii:', summary['radii'], 'structurally nonseparating:', summary['structurally_nonseparating'])


if __name__ == '__main__':
    main()
