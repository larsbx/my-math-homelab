from common import *
import random
# decider vs direct word search, on random PIP substitutions (any det)
random.seed(1); n = 0; bad = 0
while n < 300:
    sigma = tuple(tuple(random.randrange(3) for _ in range(random.randint(1, 4))) for _ in range(3))
    if not pip(sigma): continue
    for a, b in ((0, 1), (0, 2), (1, 2)):
        lv = coincidence_level(sigma, a, b)
        # direct: first level <= 9 with a shared tile
        direct = None
        for k in range(0, 10):
            u, w = a_word(sigma, a, k), a_word(sigma, b, k)
            if len(u) * len(w) > 4e6: break
            pa, pb = {}, {}
            v = [0,0,0]
            for pos, ch in enumerate(u):
                pa[(tuple(v), ch)] = 1; v[ch] += 1
            v = [0,0,0]; found = False
            for pos, ch in enumerate(w):
                if (tuple(v), ch) in pa: found = True; break
                v[ch] += 1
            if found: direct = k; break
        if direct is not None and lv != direct: bad += 1; print("MISMATCH", sigma, a, b, lv, direct)
        if lv is None: print("decider says NON-coincident", sigma, a, b)
    n += 1
print("checked", n, "mismatches", bad)
