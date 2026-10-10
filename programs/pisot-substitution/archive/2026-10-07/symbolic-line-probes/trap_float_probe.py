import numpy as np, itertools, sys
from box_radii_float_probe import member, mat
X,C,Y=0,1,2
def trap(p,q,r,ends=(X,X,C,X)):
    s=member(p,q,r,ends); M=mat(s)
    ev,vl=np.linalg.eig(M.T); k=np.argmax(ev.real); beta=ev[k].real
    ell=vl[:,k].real; ell=ell/ell[2]
    lam=[ev[i] for i in range(3) if i!=k][0]; u=vl[:,[i for i in range(3) if i!=k][0]]; u=u/u[2]
    pre=lambda w,n: np.array([w[:n].count(a) for a in range(3)])
    digits=[pre(s[b],qq)-pre(s[a],pp) for a in range(3) for b in range(3) for pp in range(len(s[a])) for qq in range(len(s[b]))]
    Cb=max(abs(u@d) for d in digits)/(1-abs(lam))
    lmax=ell.max()
    # lattice points with |ell.w|<lmax and |u.w|<=Cb : search a big box
    pts=[w for w in itertools.product(range(-8,9),range(-30,31),range(-30,31)) if abs(ell@w)<lmax and abs(u@np.array(w))<=Cb]
    W=np.array(pts)
    return round(beta,3), round(abs(lam),3), round(Cb,2), len(pts), list(np.abs(W).max(axis=0))
for qv in [2,3,4,5,7,10,15,25]:
    print(qv, trap(2*qv+2,qv,qv+1))
