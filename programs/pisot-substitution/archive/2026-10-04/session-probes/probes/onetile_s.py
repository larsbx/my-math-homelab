import itertools
from multiprocessing import Pool
from lib import pip
from onetile import analyse
def f(s):
    try: return analyse(s)
    except Exception as e: return (s,'ERR',str(e))
if __name__=='__main__':
    words=[''.join(p) for k in range(1,4) for p in itertools.product('012',repeat=k)]
    corpus=[s for s in itertools.product(words,repeat=3) if pip(s)][::7]
    with Pool(4) as p: res=p.map(f,corpus,chunksize=4)
    err=[r for r in res if r[1]=='ERR']; ok=[r for r in res if r[1]!='ERR']
    print('specimens',len(ok),'errors',len(err), err[:3])
    print('recurrent',sum(r[1] for r in ok),'in CU',sum(r[2] for r in ok),'reach CU',sum(r[3] for r in ok))
    bad=[r for r in ok if r[3]<r[1]]
    print('specimens where Q1 fails:',len(bad),bad[:5])
