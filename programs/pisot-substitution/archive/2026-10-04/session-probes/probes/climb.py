import math, itertools
from collections import deque, Counter
from multiprocessing import Pool
from lib import pip
src=open('mine.py').read()
i=src.index('    # potentials'); j=src.index("if __name__=='__main__':")
src=src[:i]+'''    return M,r,lt,Ls,sig,E,rec,allv,t
'''+src[j:].split("if __name__=='__main__':")[0]
ns={}; exec(src,ns)
def f(s):
    M,r,lt,Ls,sig,E,rec,allv,t=ns['analyse'](s)
    rev={v:[] for v in allv}
    for v,ch in E.items():
        for u in ch: rev[u].append(v)
    dist={v:0 for v in allv if v[2]==(0,0,0)}
    dq=deque(dist)
    while dq:
        u=dq.popleft()
        for x in rev[u]:
            if x not in dist: dist[x]=dist[u]+1; dq.append(x)
    beta=r[0].real; lmin=min(lt)
    KV=max(dist[v] for v in rec)
    arg=[v for v in rec if dist[v]==KV]
    same=all(v[0]==v[1] for v in arg)
    # climb: diagonal steps until |beta^n t| >= lmin
    def climb(v):
        tv=abs(t(v[2]))
        return 0 if tv==0 else max(0,math.ceil(math.log(lmin/tv)/math.log(beta)))
    resid=max(dist[v]-climb(v) for v in rec)
    return s,KV,same,max(climb(v) for v in arg),resid
if __name__=='__main__':
    words=[''.join(p) for k in range(1,4) for p in itertools.product('012',repeat=k)]
    corpus=[s for s in itertools.product(words,repeat=3) if pip(s)][::7]
    with Pool(3) as p: res=p.map(f,corpus,chunksize=4)
    print('sample',len(res),'argmax all same-letter:',sum(x[2] for x in res))
    print('K_V hist',sorted(Counter(x[1] for x in res).items()))
    print('residual (depth - climb) max over recurrent, hist:',sorted(Counter(x[4] for x in res).items()))
    print('K_V - residual_max ... examples deepest:',sorted(res,key=lambda x:-x[1])[:5])
