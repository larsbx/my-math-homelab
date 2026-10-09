"""§4 of the vertex-coincidence note: specimens with images of length <= 4
lying neither in the standing corpus (images <= 3) nor in the total-length
<= 8 class. Floating-point PIP screen from lib.py (an oracle, not a
certificate); the exact Mojo census screens the same domains."""
import itertools
from multiprocessing import Pool
from lib import pip
words = [''.join(p) for k in range(1, 5) for p in itertools.product('012', repeat=k)]
def row(a):
    out = [0, 0, 0, 0]  # pip, standing, total<=8, neither
    for b in words:
        for c in words:
            s = (a, b, c)
            if not pip(s):
                continue
            out[0] += 1
            standing = max(map(len, s)) <= 3
            total8 = sum(map(len, s)) <= 8
            out[1] += standing
            out[2] += total8
            out[3] += not standing and not total8
    return out
if __name__ == '__main__':
    with Pool(4) as p:
        rs = p.map(row, words, chunksize=4)
    t = [sum(r[i] for r in rs) for i in range(4)]
    print('images <= 4 PIP', t[0], ' standing', t[1], ' total length <= 8 within it', t[2], ' neither', t[3])
