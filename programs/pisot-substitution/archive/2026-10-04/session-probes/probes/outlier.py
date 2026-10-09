import itertools
from multiprocessing import Pool
from lib import pip, mat, charpoly
from box2 import box_graph
words=[''.join(p) for k in range(1,4) for p in itertools.product('012',repeat=k)]
def disc(c):
    a,b,cc=c[1],c[2],c[3]
    return 18*a*b*cc-4*a**3*cc+a*a*b*b-4*b**3-27*cc*cc
cand=[s for s in itertools.product(words,repeat=3) if pip(s) and abs(charpoly(mat(s))[3])==1 and disc(charpoly(mat(s)))<0]
def f(s): return s, box_graph(s)
if __name__=='__main__':
    print(len(cand))
    with Pool(4) as p:
        for s,r in p.imap_unordered(f,cand,chunksize=8):
            if r[2]>=12: print(s, r, charpoly(mat(s)), flush=True)
