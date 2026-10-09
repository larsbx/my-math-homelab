import itertools
from multiprocessing import Pool
from lib import pip
from box2 import box_graph
words=[''.join(p) for k in range(1,4) for p in itertools.product('012',repeat=k)]
corpus=[s for s in itertools.product(words,repeat=3) if pip(s)]
if __name__=='__main__':
    with Pool(4) as p: res=p.map(box_graph,corpus,chunksize=8)
    print('specimens',len(res),'bad',sum(r[0]>0 for r in res),'recurrent total',sum(r[1] for r in res),'max recurrent',max(r[1] for r in res),'max deepest',max(r[2] for r in res))
