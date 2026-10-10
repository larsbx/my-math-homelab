"""Symbolic re-derivation of Theorem E §3b.2 (det) and §3b.5 (f(±1)), and §3b.3 exclusions."""
import sympy as S
p, q, r, t = S.symbols('p q r t')
X, C, Y = 0, 1, 2
def col(first, k, last):
    v = [0, 0, 0]; v[first] += 1; v[Y] += k; v[last] += 1; return v
def M(sx, sc, tt, sy):
    cols = [col(X, p, sx), col(C, q, sc), col(tt, r, sy)]
    return S.Matrix(3, 3, lambda a, b: cols[b][a])
name = {X: 'x', C: 'c'}
for e in S.utilities.iterables.cartes([X, C], repeat=4):
    m = M(*e); f = (t*S.eye(3) - m).det()
    print(tuple(name[z] for z in e), 'det =', S.factor(m.det()), '| f(1) =', S.expand(f.subs(t, 1)), '| f(-1) =', S.expand(f.subs(t, -1)))
