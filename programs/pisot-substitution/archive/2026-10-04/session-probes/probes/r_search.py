from lib import *
step={('O','0'):'I',('I','2'):'I',('I','1'):'O'}
def run(s,w):
    for ch in w:
        s=step.get((s,ch))
        if s is None: return None
    return s
need={'0':('O','I'),'2':('I','I'),'1':('I','O')}
words=[''.join(p) for L in range(1,6) for p in itertools.product('012',repeat=L)]
cand={a:[w for w in words if run(need[a][0],w)==need[a][1]] for a in '012'}
found=[s for s in itertools.product(cand['0'],cand['1'],cand['2']) if pip(s)]
print(len(found)); print(found[:15])
