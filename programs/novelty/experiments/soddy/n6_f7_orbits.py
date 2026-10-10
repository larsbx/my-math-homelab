"""Exact n=6, F_7 defect/Apollonian orbit comparison.

This is a finite experiment, not a theorem or a novelty claim.  Matrices act
on column vectors and all arithmetic is modulo 7.
"""

from collections import deque

MOD = 7
DIM = 8


def eye(n=DIM):
    return [[int(i == j) for j in range(n)] for i in range(n)]


def transpose(a):
    return [list(row) for row in zip(*a)]


def mat_mul(a, b):
    return [[sum(a[i][k] * b[k][j] for k in range(len(b))) % MOD
             for j in range(len(b[0]))] for i in range(len(a))]


def mat_vec(a, v):
    return tuple(sum(a[i][j] * v[j] for j in range(len(v))) % MOD
                 for i in range(len(a)))


def mat_inv(a):
    n = len(a)
    aug = [[x % MOD for x in row] + e for row, e in zip(a, eye(n))]
    for col in range(n):
        pivot = next((r for r in range(col, n) if aug[r][col]), None)
        if pivot is None:
            raise ValueError("singular matrix")
        aug[col], aug[pivot] = aug[pivot], aug[col]
        scale = pow(aug[col][col], -1, MOD)
        aug[col] = [(scale * x) % MOD for x in aug[col]]
        for r in range(n):
            if r != col and aug[r][col]:
                scale = aug[r][col]
                aug[r] = [(x - scale * y) % MOD
                          for x, y in zip(aug[r], aug[col])]
    return [row[n:] for row in aug]


def matrix_key(a):
    return tuple(tuple(row) for row in a)


def gram_preserved(a, q):
    return mat_mul(transpose(a), mat_mul(q, a)) == q


def quadratic(q, v):
    return sum(v[i] * q[i][j] * v[j]
               for i in range(len(v)) for j in range(len(v))) % MOD


def projective(v):
    first = next((x for x in v if x % MOD), None)
    if first is None:
        raise ValueError("zero vector has no projective class")
    scale = pow(first, -1, MOD)
    return tuple(scale * x % MOD for x in v)


def cd_conj(x):
    if len(x) == 1:
        return x
    half = len(x) // 2
    return cd_conj(x[:half]) + tuple(-z % MOD for z in x[half:])


def cd_add(x, y):
    return tuple((a + b) % MOD for a, b in zip(x, y))


def cd_neg(x):
    return tuple(-a % MOD for a in x)


def cd_mul(x, y):
    """Cayley-Dickson product (a,b)(c,d)=(ac-conj(d)b, da+bconj(c))."""
    if len(x) == 1:
        return (x[0] * y[0] % MOD,)
    half = len(x) // 2
    a, b, c, d = x[:half], x[half:], y[:half], y[half:]
    left = cd_add(cd_mul(a, c), cd_neg(cd_mul(cd_conj(d), b)))
    right = cd_add(cd_mul(d, a), cd_mul(b, cd_conj(c)))
    return left + right


def basis(i):
    return tuple(int(i == j) for j in range(DIM))


def left_matrix(x):
    columns = [cd_mul(x, basis(j)) for j in range(DIM)]
    return [[columns[j][i] for j in range(DIM)] for i in range(DIM)]


def descartes_gram():
    # For packing dimension n=6, I-(1/6)J = I+J over F_7.
    return [[(int(i == j) + 1) % MOD for j in range(DIM)]
            for i in range(DIM)]


def bridge_isometry():
    # Phi=I+J and Phi^{-1}=I+3J satisfy Phi^T Q Phi=I over F_7.
    phi = descartes_gram()
    phi_inv = [[(int(i == j) + 3) % MOD for j in range(DIM)]
               for i in range(DIM)]
    return phi, phi_inv


def defect_generators():
    phi, phi_inv = bridge_isometry()
    generators = {}
    for i in range(DIM):
        for j in range(DIM):
            x, y = basis(i), basis(j)
            xy = cd_mul(x, y)
            defect = mat_mul(left_matrix(x),
                             mat_mul(left_matrix(y), mat_inv(left_matrix(xy))))
            transported = mat_mul(phi, mat_mul(defect, phi_inv))
            generators[matrix_key(transported)] = transported
    return list(generators.values())


def apollonian_generators():
    # Reflection i: b_i -> 2/(n-1) sum_{j!=i} b_j - b_i; 2/5=6 mod 7.
    generators = []
    for i in range(DIM):
        a = eye()
        a[i] = [6 if j != i else -1 % MOD for j in range(DIM)]
        generators.append(a)
    return generators


def orbit(generators, seed):
    start = projective(seed)
    seen = {start}
    queue = deque([start])
    while queue:
        v = queue.popleft()
        for g in generators:
            w = projective(mat_vec(g, v))
            if w not in seen:
                seen.add(w)
                queue.append(w)
    return seen


def run():
    q = descartes_gram()
    phi, phi_inv = bridge_isometry()
    defect = defect_generators()
    apollonian = apollonian_generators()
    seed = (1, 2, 0, 0, 0, 0, 0, 0)
    assert mat_mul(phi, phi_inv) == eye()
    assert mat_mul(transpose(phi), mat_mul(q, phi)) == eye()
    assert quadratic(q, seed) == 0
    assert all(gram_preserved(g, q) for g in defect + apollonian)
    return {
        "field": "F_7",
        "packing_dimension": 6,
        "ambient_dimension": DIM,
        "defect_generator_count": len(defect),
        "apollonian_generator_count": len(apollonian),
        "defect_projective_orbit_size": len(orbit(defect, seed)),
        "apollonian_projective_orbit_size": len(orbit(apollonian, seed)),
        "combined_projective_orbit_size": len(orbit(defect + apollonian, seed)),
    }


def framing_audit():
    """Two valid bridges need not give equivalent joint actions with fixed A.

    Reflect the octonion norm coordinates in u=(1,1,1,0,...,0).
    Both Phi and Phi*h are isometries. Only the defect group is moved;
    the Descartes seed and Apollonian generators remain fixed.
    """
    phi, phi_inv = bridge_isometry()
    u = (1, 1, 1, 0, 0, 0, 0, 0)
    scale = 2 * pow(sum(x*x for x in u) % MOD, -1, MOD) % MOD
    h = [[(int(i == j) - scale*u[i]*u[j]) % MOD
          for j in range(DIM)] for i in range(DIM)]
    c = mat_mul(phi, mat_mul(h, phi_inv))
    alternate_phi = mat_mul(phi, h)
    q = descartes_gram()
    if mat_mul(transpose(alternate_phi), mat_mul(q, alternate_phi)) != eye():
        raise ValueError("alternate bridge is not an isometry")
    if mat_mul(c, c) != eye() or not gram_preserved(c, q):
        raise ValueError("bridge transition is not an orthogonal involution")
    defects = defect_generators()
    moved = [mat_mul(c, mat_mul(d, c)) for d in defects]
    if not all(gram_preserved(d, q) for d in moved):
        raise ValueError("transported generator violates the Gram identity")
    seed = (1, 2, 0, 0, 0, 0, 0, 0)
    apollonian = apollonian_generators()
    return {
        "original_combined_orbit": len(orbit(defects + apollonian, seed)),
        "alternate_combined_orbit": len(orbit(moved + apollonian, seed)),
        "alternate_defect_orbit": len(orbit(moved, seed)),
    }


if __name__ == "__main__":
    import json
    print(json.dumps(run(), indent=2, sort_keys=True))
