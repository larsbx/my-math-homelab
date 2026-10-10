import sys; from boxproto import analyse; from radii import member
X,C,Y=0,1,2
pts=[tuple(map(int,a.split(','))) for a in sys.argv[1:]]
sets={}
for p,q,r in pts:
    S,info=analyse(member(p,q,r,(X,X,C,X))); sets[(p,q,r)]=S; print((p,q,r),info['rec'],info['deep'],flush=True)
base=sets[pts[0]]
for k,S in sets.items(): print(k,'same as first' if S==base else f'diff +{len(S-base)} -{len(base-S)}')
