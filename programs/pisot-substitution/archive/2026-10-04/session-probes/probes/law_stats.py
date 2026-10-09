"""Summary statistics of §5.5 of the vertex-coincidence note, recomputed from
../bulk/law.json (written by law.py: specimen, K_V, mu, |det|, beta; floating
point, an oracle and not a certificate)."""
import json, math
rows = json.load(open('../bulk/law.json'))
x = [k * math.log(1 / mu) for s, k, mu, d, b in rows]
print('specimens', len(rows))
print('K_V log(1/mu) in [%.3f, %.3f]' % (min(x), max(x)))
xs = [1 / math.log(1 / mu) for s, k, mu, d, b in rows]
ys = [k for s, k, mu, d, b in rows]
n = len(xs); mx = sum(xs) / n; my = sum(ys) / n
cov = sum((a - mx) * (b - my) for a, b in zip(xs, ys))
vx = sum((a - mx) ** 2 for a in xs); vy = sum((b - my) ** 2 for b in ys)
print('corr(K_V, 1/log(1/mu)) %.3f' % (cov / math.sqrt(vx * vy)))
print('mu over K_V >= 15:', sorted({round(mu, 4) for s, k, mu, d, b in rows if k >= 15}))
print('max mu over K_V <= 3: %.3f' % max(mu for s, k, mu, d, b in rows if k <= 3))
