import sys, itertools
from math import gcd
from multiprocessing import Pool
from lib import *
L=int(sys.argv[1])
words=[''.join(p) for k in range(1,L+1) for p in itertools.product('012',repeat=k)]
def det3(a,b,c):
    return a[0]*(b[1]*c[2]-b[2]*c[1])-a[1]*(b[0]*c[2]-b[2]*c[0])+a[2]*(b[0]*c[1]-b[1]*c[0])
def simple_cycles(edges):
    cyc=[]
    V='012'
    for start in V:
        stack=[(start,[start])]
        while stack:
            v,path=stack.pop()
            for (a,c) in edges:
                if a!=v: continue
                if c==start: cyc.append(path[:])
                elif c not in path and c>start: stack.append((c,path+[c]))
    return cyc
def index(s):
    lang=two_letter(s)
    edges={(u[0],u[1]) for u in lang}
    vecs=[]
    for cy in simple_cycles(edges):
        v=[0,0,0]
        for ch in cy: v[int(ch)]+=1
        vecs.append(v)
    g=0
    for a,b,c in itertools.combinations(vecs,3): g=gcd(g,det3(a,b,c))
    return g
def work(s0):
    out=[];n=0
    for s1 in words:
        for s2 in words:
            s=(s0,s1,s2)
            M=mat(s)
            if not primitive(M) or charpoly(M)[3]==0: continue
            n+=1
            i=index(s)
            if i>1: out.append((s,i))
    return n,out
if __name__=='__main__':
    with Pool(16) as p:
        res=p.map(work,words,chunksize=1)
    print('pip',sum(r[0] for r in res)); bad=[x for r in res for x in r[1]]
    print('bad',len(bad),bad[:20])
