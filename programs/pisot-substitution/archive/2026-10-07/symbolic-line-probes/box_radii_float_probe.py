import numpy as np, itertools, sys
X,C,Y=0,1,2
def member(p,q,r,ends):
    sx,sc,t,sy=ends
    return [[X]+[Y]*p+[sx],[C]+[Y]*q+[sc],[t]+[Y]*r+[sy]]
def mat(s):
    M=np.zeros((3,3));
    for b,w in enumerate(s):
        for a in w: M[a,b]+=1
    return M
def radii(s):
    M=mat(s); ev,vl=np.linalg.eig(M.T)
    k=np.argmax(ev.real); beta=ev[k].real; ell=np.abs(vl[:,k].real); ell/=ell.min()
    # field embeddings: ell components are polys in beta; get conjugate eigvecs
    others=[i for i in range(3) if i!=k]
    pre=lambda w,n: np.array([w[:n].count(a) for a in range(3)])
    digits=set()
    for a in range(3):
        for b in range(3):
            for p in range(len(s[a])):
                for q in range(len(s[b])):
                    d=tuple(pre(s[b],q)-pre(s[a],p)); digits.add(d)
    D=np.array(sorted(digits)).T  # 3 x n
    # coordinates: w -> (ell.w, conj embeddings) ; use left eigenvectors of all eigenvalues
    L=vl.T  # rows = left eigenvectors (of M^T eig => left of M)
    # normalize rows so that row k is ell
    tot=0; R=[]
    lmax=ell.max()
    bounds=[]
    for i in others:
        lam=abs(ev[i]); row=L[i]/ (L[k]@np.ones(3)) # scale arbitrary but consistent: use exact relation via inverse below
        bounds.append(None)
    # invert: w = Linv @ (coords); coords_k=ell.w in (-lmax,lmax); coords_i bounded by max|row_i . d|/(1-|lam_i|)
    Lk=np.vstack([ell]+[L[i] for i in others])
    Linv=np.linalg.inv(Lk)
    cb=[lmax]+[np.max(np.abs(L[i]@D))/(1-abs(ev[i])) for i in others]
    rad=[sum(abs(Linv[m,j])*cb[j] for j in range(3)) for m in range(3)]
    return beta, [abs(ev[i]) for i in others], [int(np.ceil(x)) for x in rad]
ends=(X,X,C,X)  # class B
if __name__=="__main__":
  for (p,q,r) in [(2,1,2),(4,1,2),(4,2,3),(8,3,4),(12,5,6),(20,9,10),(40,19,20),(8,1,2),(20,1,2),(50,1,2),(50,30,31),(100,60,61)]:
    print((p,q,r), radii(member(p,q,r,ends)))
