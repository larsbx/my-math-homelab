exec(open("a2.py").read().split("cnt=collections")[0])
rows=[]
for k,(r,e) in fails.items():
    if e>0:
        m=M(words[k]); rows.append((r, abs(det(m)), 'cx' if disc(m)<0 else 're', k, words[k], e))
rows.sort()
for x in rows[:25]: print(x)
