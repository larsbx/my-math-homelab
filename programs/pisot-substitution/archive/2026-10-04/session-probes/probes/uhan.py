import glob,re,itertools,math
from collections import Counter
from lib import mat,charpoly,roots
w=[''.join(p) for k in range(1,5) for p in itertools.product('012',repeat=k)]
recs=[]
for f in glob.glob('../bulk/uh4/chunk_*.log'):
    for m in re.finditer(r'K_V record: (\d+) (\d+) (\d+) (-?\d+)',open(f).read()):
        recs.append(tuple(int(x) for x in m.groups()))
print('records',len(recs),'distinct',len(set(recs[i][:3] for i in range(len(recs)))))
cache={}
vals=[];worst=[]
for i,j,k,kv in recs:
    s=(w[i],w[j],w[k]); c=tuple(charpoly(mat(s)))
    if c not in cache:
        r=roots(list(c)); cache[c]=max(abs(r[1]),abs(r[2]))
    mu=cache[c]; v=kv*math.log(1/mu)
    vals.append(v); worst.append((v,kv,mu,s,abs(c[3])))
worst.sort(reverse=True)
print('K_V*log(1/mu): min %.3f max %.3f'%(min(vals),max(vals)))
print('above 3.2:',sum(v>3.2 for v in vals),' above 3.5:',sum(v>3.5 for v in vals))
for x in worst[:8]: print('%.3f K_V=%d mu=%.4f %s |det|=%d'%x)
xs=[1/math.log(1/(worst_mu)) for worst_mu in [x[2] for x in worst]]; ys=[x[1] for x in worst]
n=len(xs); mx=sum(xs)/n; my=sum(ys)/n
cov=sum((a-mx)*(b-my) for a,b in zip(xs,ys)); vx=sum((a-mx)**2 for a in xs); vy=sum((b-my)**2 for b in ys)
print('corr %.3f'%(cov/math.sqrt(vx*vy)))
data=[(x[1],x[2]) for x in worst]
for a in range(0,9):
    c=max((kv-a)*math.log(1/mu) for kv,mu in data)
    print('a=%d  c=%.3f'%(a,c))
# standing corpus subset check for the same envelopes (images <=3)
std=[(x[1],x[2]) for x in worst if max(map(len,x[3]))<=3]
print('standing subset',len(std))
for a in range(0,9):
    print('  std a=%d c=%.3f'%(a,max((kv-a)*math.log(1/mu) for kv,mu in std)))
