exec(open("feat.py").read())
print(len(fails))
cnt=collections.Counter(); cntall=collections.Counter()
for k,w in words.items():
    f=tuple(x[0] for x in w); l=tuple(x[-1] for x in w)
    tag=(len(set(f)), len(set(l)))
    cntall[tag]+=1
    if k in fails: cnt[(tag, 'total' if fails[k][1]==0 else 'partial')]+=1
print(sorted(cntall.items())); print(sorted(cnt.items()))
for k,(r,e) in list(fails.items())[:30]:
    print(k, words[k], r, e)
