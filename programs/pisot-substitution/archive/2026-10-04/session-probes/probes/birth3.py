import itertools
from multiprocessing import Pool
from collections import Counter
from lib import pip, mat, charpoly
from birth2 import births
def f(s):
    try:
        st=births(s)[1]
    except Exception as e:
        return s,None
    sim=sum(v for k,v in st.items() if k[0]=='simultaneous')
    tot=sum(st.values())
    dmax=max([k[2] for k,v in st.items() if k[0]=='catch-up' and v] or [0])
    c=charpoly(mat(s)); return s,(tot,sim,dmax,abs(c[3]))
if __name__=='__main__':
    words=[''.join(p) for k in range(1,4) for p in itertools.product('012',repeat=k)]
    corpus=[s for s in itertools.product(words,repeat=3) if pip(s)][::7]
    with Pool(3) as p: res=p.map(f,corpus,chunksize=4)
    ok=[r for s,r in res if r]
    print('specimens',len(ok),'errors',len(res)-len(ok))
    print('recurrent vertices',sum(r[0] for r in ok),'simultaneous births',sum(r[1] for r in ok))
    print('max catch-up delay by |det|:',sorted(Counter((r[3],r[2]) for r in ok).items()))
