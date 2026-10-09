import math
from collections import deque
import mine
src=open('mine.py').read()
i=src.index('    # potentials'); j=src.index("if __name__=='__main__':")
src=src[:i]+'''    return M,r,lt,Ls,sig,E,rec,allv,t
'''+src[j:].split("if __name__=='__main__':")[0]
ns={}; exec(src,ns)
s=('1','2','01')
M,r,lt,Ls,sig,E,rec,allv,t=ns['analyse'](s)
rev={v:[] for v in allv}
for v,ch in E.items():
    for u in ch: rev[u].append(v)
dist={v:0 for v in allv if v[2]==(0,0,0)}; nxt={}
dq=deque(dist)
while dq:
    u=dq.popleft()
    for x in rev[u]:
        if x not in dist: dist[x]=dist[u]+1; nxt[x]=u; dq.append(x)
print('beta',r[0].real,'lambda',r[1],'|lambda|',abs(r[1]))
print('l',lt)
rows=sorted(rec,key=lambda v:-dist[v])
from collections import Counter
print('depth histogram over recurrent:',sorted(Counter(dist[v] for v in rec).items()))
for v in rows[:12]:
    z=sig(v[2],1)
    path=[];x=v
    while x[2]!=(0,0,0): x=nxt[x]; path.append(x)
    print(v, 't=%.4f'%t(v[2]), '|z|=%.4f'%abs(z), 'depth',dist[v], 'hit',path[-1])
