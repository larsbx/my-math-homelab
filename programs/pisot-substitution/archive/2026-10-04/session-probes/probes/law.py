import itertools, math
from multiprocessing import Pool
from lib import pip, mat, charpoly, roots
from box2 import box_graph
words=[''.join(p) for k in range(1,4) for p in itertools.product('012',repeat=k)]
corpus=[s for s in itertools.product(words,repeat=3) if pip(s)]
def f(s):
    c=charpoly(mat(s)); r=roots(c); mu=max(abs(r[1]),abs(r[2]))
    return s, box_graph(s)[2], mu, abs(c[3]), r[0].real
if __name__=='__main__':
    with Pool(4) as p: res=p.map(f,corpus,chunksize=8)
    import json; json.dump([(list(s),k,mu,d,b) for s,k,mu,d,b in res],open('law.json','w'))
    vals=[k*math.log(1/mu) for s,k,mu,d,b in res]
    print('K_V*log(1/mu): min %.3f max %.3f'%(min(vals),max(vals)))
    # by K_V: range of mu
    from collections import defaultdict
    g=defaultdict(list)
    for s,k,mu,d,b in res: g[k].append(mu)
    for k in sorted(g): print(k, len(g[k]), 'mu in [%.4f, %.4f]'%(min(g[k]),max(g[k])))
    # correlation
    xs=[1/math.log(1/mu) for s,k,mu,d,b in res]; ys=[k for s,k,mu,d,b in res]
    n=len(xs); mx=sum(xs)/n; my=sum(ys)/n
    cov=sum((x-mx)*(y-my) for x,y in zip(xs,ys)); vx=sum((x-mx)**2 for x in xs); vy=sum((y-my)**2 for y in ys)
    print('corr(K_V, 1/log(1/mu)) = %.3f'%(cov/math.sqrt(vx*vy)))
    # least squares K_V ~ a + c/log(1/mu)
    c=cov/vx; a=my-c*mx; resid=[y-(a+c*x) for x,y in zip(xs,ys)]
    print('fit K_V = %.2f + %.2f / log(1/mu); residual range [%.2f, %.2f]'%(a,c,min(resid),max(resid)))
