import collections
words={}
for l in open("../outputs/corpus_words.txt"):
    p=l.split(); words[tuple(p[:3])]=p[3:]
fails={}
for l in open("../outputs/fails.txt"):
    p=l.split()
    if 'recurrent=' not in l: continue
    rec=int(p[3].split('=')[1]); e=int(p[-1].split('=')[1])
    fails[tuple(p[:3])]=(rec,e)
