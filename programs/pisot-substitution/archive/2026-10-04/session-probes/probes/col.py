exec(open("a3.py").read().split("tab=collections")[0])
def shaped(w,O):
    for x in w:
        if len(x)==1:
            if int(x) in O: return False
        else:
            if int(x[0]) not in O or int(x[-1]) not in O: return False
            if any(int(c) in O for c in x[1:-1]): return False
    return True
tab=collections.Counter(); cls={}
import itertools
for k,w in words.items():
    m=M(w)
    free = not any(inLam(m,ab(x[:i])) for x in w for i in range(1,len(x)))
    Os=[O for r in (1,2,3) for O in itertools.combinations(range(3),r) if shaped(w,set(O))]
    tab[(free, len(Os))]+=1
    if free: cls.setdefault(tuple(sorted(Os)),[]).append(w)
print(tab)
for O,ws in cls.items(): print(O, len(ws), ws[:4])
