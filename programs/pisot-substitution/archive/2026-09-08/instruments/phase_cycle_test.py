"""
Test the reviewer's Lemma 4.5 gap: does a phase cycle inside a coincidence run necessarily
emit COMPLETE sigma-cuttings (return to offset 0 on each side), or can it return to a nonzero
offset pair (alpha,beta), emitting a mid-image cyclic fragment?

Phase state = (source-offset on u-side within current image, source-offset on v-side).
A cycle returns to the same phase state. 'Complete cutting' needs the cycle to span whole
images on each side, i.e. return to offset 0. We reconstruct the phase walk along coincidence
runs and check whether recurring phase states have offset (0,0) or nonzero.
"""
import numpy as np
import psc_core as P
import census
from balanced_pair import build_bpa, standard_seeds

def phase_walk(u, v, s):
    """Walk the inflated pair (sigma(u), sigma(v)) tracking, at each output tile position k,
    the phase = (which source letter on u-side and offset within its image, same for v).
    Return list of (k, phase) along maximal coincidence runs (where output tiles agree)."""
    iu=s.apply_word(u); iv=s.apply_word(v)
    # build source-offset map for each side: position -> (source_index, offset_in_image)
    def offmap(word):
        m=[]
        for si,letter in enumerate(word):
            img=s.images[letter]
            for off in range(len(img)):
                m.append((si,off,len(img)))
        return m
    ou=offmap(u); ov=offmap(v)
    L=min(len(iu),len(iv),len(ou),len(ov))
    phases=[]; k=0
    while k<L:
        if iu[k]!=iv[k]: k+=1; continue
        j=k
        run=[]
        while j<L and iu[j]==iv[j]:
            # phase = (offset within u-image, offset within v-image)
            run.append((ou[j][1], ov[j][1], ou[j][2], ov[j][2]))
            j+=1
        phases.append(run); k=j
    return phases

n=0; cycles_zero=0; cycles_nonzero=0; runs_with_recur=0
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>120: break
    try: bpa=build_bpa(s,standard_seeds(s),max_states=2000)
    except Exception: continue
    if not bpa.finite: continue
    for st in list(bpa.states)[:200]:
        for run in phase_walk(st[0],st[1],s):
            # find recurring phase (offu,offv) within the run
            seen={}
            for idx,ph in enumerate(run):
                key=(ph[0],ph[1])
                if key in seen:
                    runs_with_recur+=1
                    # cycle between seen[key] and idx; does it return to offset (0,0)?
                    if key==(0,0): cycles_zero+=1
                    else: cycles_nonzero+=1
                    break
                seen[key]=idx
print(f"specimens {n}; runs with a recurring phase: {runs_with_recur}")
print(f"  recurring phase at offset (0,0) [COMPLETE cutting]: {cycles_zero}")
print(f"  recurring phase at NONZERO offset [mid-image fragment]: {cycles_nonzero}")
print()
print("If cycles_nonzero > 0, Lemma 4.5's 'complete cutting' is NOT automatic from a phase")
print("cycle (confirms reviewer): a cycle can recur at nonzero offset, emitting a cyclic")
print("fragment that is not sigma(a)=W=sigma(b) for complete source words.")
