import itertools
from collections import deque, Counter
from multiprocessing import Pool
from lib import pip
src=open('mine.py').read()
i=src.index('    # potentials'); j=src.index("if __name__=='__main__':")
src=src[:i]+'''    return M,r,lt,Ls,sig,E,rec,allv,t,pre
'''+src[j:].split("if __name__=='__main__':")[0]
ns={}; exec(src,ns)
def analyse(s):
    M,r,lt,Ls,sig,E,rec,allv,t,pre=ns['analyse'](s)
    def leftmost(v):
        a,b,w=v; tw=t(w)
        Mw=[sum(M[k][m]*w[m] for m in range(3)) for k in range(3)]
        if abs(tw)<1e-12: return None
        if tw<0:  # A-vertex at 0 inside b: top child 0, bottom child containing 0
            p=pre[a][0]; ca=int(s[a][0])
            for qi,q in enumerate(pre[b]):
                w2=tuple(Mw[k]+q[k]-p[k] for k in range(3)); t2=t(w2); cb=int(s[b][qi])
                if -lt[cb]+1e-12 < t2 <= 1e-12: return (ca,cb,w2)
        else:     # B-vertex inside a: bottom child 0, top child containing it
            q=pre[b][0]; cb=int(s[b][0])
            for pi_,p in enumerate(pre[a]):
                w2=tuple(Mw[k]+q[k]-p[k] for k in range(3)); t2=t(w2); ca=int(s[a][pi_])
                if -1e-12 <= t2 < lt[ca]-1e-12: return (ca,cb,w2)
        raise Exception('no leftmost child')
    # CU: leftmost chain reaches offset zero
    cu={}
    for v0 in allv:
        if v0 in cu: continue
        path=[];x=v0;seen=set();res=None
        while True:
            if x[2]==(0,0,0): res=True;break
            if x in cu: res=cu[x];break
            if x in seen: res=False;break
            seen.add(x);path.append(x)
            nx=leftmost(x)
            if nx not in allv: allv.add(nx)
            x=nx
        for y in path: cu[y]=res
    CU={v for v,b in cu.items() if b}
    rev={v:[] for v in E}
    for v,ch in E.items():
        for u in ch: rev.setdefault(u,[]).append(v)
    good=set(x for x in CU if x in rev); dq=deque(good)
    while dq:
        u=dq.popleft()
        for x in rev.get(u,[]):
            if x not in good: good.add(x); dq.append(x)
    R=[v for v in rec if v[2]!=(0,0,0)]
    return s,len(R),sum(v in CU for v in R),sum(v in good for v in R)
if __name__=='__main__':
    for s in [('1','222','0222'),('1','021','001'),('210','0','110'),('1','2','01'),('01','02','0')]:
        print(analyse(s))
