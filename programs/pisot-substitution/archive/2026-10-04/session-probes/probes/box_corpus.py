import itertools, time
from multiprocessing import Pool
from lib import pip
from box import box_graph
words=[''.join(p) for k in range(1,4) for p in itertools.product('012',repeat=k)]
corpus=[s for s in itertools.product(words,repeat=3) if pip(s)]
def f(s):
    t=time.time(); r=box_graph(s); return s,r,time.time()-t
if __name__=='__main__':
    print(len(corpus),flush=True)
    bad=[];mx=(0,None);n=0
    with Pool(4) as p:
        for s,r,dt in p.imap_unordered(f,corpus,chunksize=4):
            n+=1
            if r[2]: bad.append((s,r))
            if r[1]>mx[0]: mx=(r[1],s)
            if n%500==0: print(n,len(bad),mx,flush=True)
    print('done',n,'bad',len(bad),bad[:10],'max',mx)
