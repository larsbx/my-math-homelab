import itertools, sys
from collections import deque
from multiprocessing import Pool
from lib import pip, mat, charpoly, roots
import box
def analyse(s):
    M=mat(s); c=charpoly(M); r=roots(c)
    L=[box.left_eig(M,lam) for lam in r]
    Ls=[[x/Lk[0] for x in Lk] for Lk in L]   # sigma_k(l) normalised by l_0
    lt=[x.real for x in Ls[0]]
    pre=[[[s[a][:k].count(str(b)) for b in range(3)] for k in range(len(s[a]))] for a in range(3)]
    D={tuple(q[k]-p[k] for k in range(3)) for a in range(3) for b in range(3) for p in pre[a] for q in pre[b]}
    B=[max(abs(sum(Ls[m][k]*d[k] for k in range(3))) for d in D)/(1-abs(r[m]))*1.02+1e-9 for m in (1,2)]
    lmax=max(lt)
    t=lambda w: sum(lt[k]*w[k] for k in range(3))
    sig=lambda w,m: sum(Ls[m][k]*w[k] for k in range(3))
    # enumerate box via slab
    a=Ls; det=(a[0][0]*(a[1][1]*a[2][2]-a[1][2]*a[2][1])-a[0][1]*(a[1][0]*a[2][2]-a[1][2]*a[2][0])+a[0][2]*(a[1][0]*a[2][1]-a[1][1]*a[2][0]))
    inv=[[0]*3 for _ in range(3)]
    for i in range(3):
        for j in range(3):
            mm=[[a[x][y] for y in range(3) if y!=i] for x in range(3) if x!=j]
            inv[i][j]=((-1)**(i+j))*(mm[0][0]*mm[1][1]-mm[0][1]*mm[1][0])/det
    yb=[lmax,B[0],B[1]]
    R=[int(sum(abs(inv[k][m])*yb[m] for m in range(3)))+1 for k in range(3)]
    V=set()
    for w0 in range(-R[0],R[0]+1):
        for w1 in range(-R[1],R[1]+1):
            base=lt[0]*w0+lt[1]*w1
            lo=int((-lmax-base)/lt[2])-1; hi=int((lmax-base)/lt[2])+1
            for w2 in range(lo,hi+1):
                w=(w0,w1,w2)
                if all(abs(sig(w,m))<=B[m-1] for m in (1,2)):
                    tw=t(w)
                    for i in range(3):
                        for j in range(3):
                            if -lt[j]+1e-12<tw<lt[i]-1e-12: V.add((i,j,w))
    E={}
    stack=list(V); allv=set(V)
    while stack:
        v=stack.pop(); i,j,w=v
        if i==j and w==(0,0,0): E[v]=[]; continue
        Mw=[sum(M[k][m]*w[m] for m in range(3)) for k in range(3)]
        out=[]
        for pi_,p in enumerate(pre[i]):
            for qi,q in enumerate(pre[j]):
                w2=tuple(Mw[k]+q[k]-p[k] for k in range(3)); t2=t(w2)
                a_,b_=int(s[i][pi_]),int(s[j][qi])
                if -lt[b_]+1e-12<t2<lt[a_]-1e-12: out.append((a_,b_,w2))
        E[v]=out
        for u in out:
            if u not in allv: allv.add(u); stack.append(u)
    # recurrent set (noncoincidence SCC with cycle)
    idx={};low={};on=set();st=[];cnt=[0];rec=set()
    for root in allv:
        if root in idx: continue
        work=[(root,0)]
        while work:
            v,i=work.pop()
            if i==0: idx[v]=low[v]=cnt[0];cnt[0]+=1;st.append(v);on.add(v)
            ch=E[v];rc=False
            while i<len(ch):
                u=ch[i];i+=1
                if u not in idx: work.append((v,i));work.append((u,0));rc=True;break
                elif u in on: low[v]=min(low[v],idx[u])
            if rc: continue
            if low[v]==idx[v]:
                comp=[]
                while True:
                    x=st.pop();on.discard(x);comp.append(x)
                    if x==v: break
                if len(comp)>1 or v in E[v]: rec.update(comp)
            if work: p=work[-1][0]; low[p]=min(low[p],low[v])
    # endpoint chains
    def region(v):
        i,j,w=v; tw=t(w); return max(0.0,tw), min(lt[i], tw+lt[j])
    def leftchild(v):
        lo,_=region(v); best=None
        for u in E[v]:
            l2,_=region(u)
            # child regions in scaled coords: child left = (parent coords*beta) ... compare using relation: child's region left must equal beta*lo up to scaling; choose min left offset relative
        return None
    # do it concretely with positions: track absolute left end through scaling
    beta=r[0].real
    def chain_hits(v, side, steps=80):
        # absolute position x of the tracked endpoint in current level coordinates where top tile starts at 0
        lo,hi=region(v); x = lo if side==0 else hi
        seen=0
        cur=v
        for _ in range(steps):
            i,j,w=cur
            if side==0 and w==(0,0,0): return True
            if side==1 and abs(t(w)+lt[j]-lt[i])<1e-9: return True
            # children: top subtile p starts at P (abs pos beta*0 + ell(p)); child region absolute
            X=beta*x
            nxt=None
            Mw=[sum(M[k][m]*w[m] for m in range(3)) for k in range(3)]
            for pi_,p in enumerate(pre[i]):
                P=sum(lt[k]*p[k] for k in range(3))
                for qi,q in enumerate(pre[j]):
                    w2=tuple(Mw[k]+q[k]-p[k] for k in range(3)); a_,b_=int(s[i][pi_]),int(s[j][qi]); t2=t(w2)
                    if not(-lt[b_]+1e-12<t2<lt[a_]-1e-12): continue
                    l2=P+max(0.0,t2); h2=P+min(lt[a_],t2+lt[b_])
                    if (side==0 and abs(l2-X)<1e-7) or (side==1 and abs(h2-X)<1e-7):
                        nxt=(a_,b_,w2); x=X-P
            if nxt is None: return None
            cur=nxt
        return False
    L_hit=R_hit=either=0; none=[]
    for v in rec:
        if v[2]==(0,0,0): continue
        a=chain_hits(v,0); b=chain_hits(v,1)
        L_hit+=bool(a); R_hit+=bool(b); either+=bool(a or b)
        if not(a or b): none.append(v)
    return s,len(rec),L_hit,R_hit,either,len(none)
if __name__=='__main__':
    for s in [('01','02','0'),('1','222','0222'),('1','021','001')]:
        print(analyse(s))
