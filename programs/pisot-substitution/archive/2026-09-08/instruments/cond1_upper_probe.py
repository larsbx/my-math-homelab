"""
The residual of condition (1) on the b1=0 stratum is the UPPER bound r <= C_comp - 1,
where r = #nonzero roots of q = chi_{N_C}/chi_M and C_comp = #components of G0^ER(Sigma_C).

We cannot build Sigma_C (no trapped object). BUT we can test the ANALOGOUS inequality on
the geometric overlap N_C of PRODUCING SCCs to see whether 'r <= C_comp-1' is even
structurally plausible, or whether producing N_C routinely violate it (which would mean the
upper bound is special to the trapped/homological-Pisot case and NOT a generic fact — i.e.
condition (1) genuinely needs the homological-Pisot hypothesis, not derivable from b1=0).

For a producing SCC chi_M does NOT divide chi_NC (gcd=1, audited). So 'q' isn't defined the
same way. Instead measure the RAW quantity: r0 = #nonzero eigenvalues of N_C, and compare
to the component structure. The point is to see whether nonzero spectrum is 'large' (r0 ~ |C|)
generically — if so, the trapped case (which needs r = C_comp-1, tiny) is a measure-zero
spectral coincidence, confirming condition (1) is a strong NON-GENERIC constraint = the real
content, not a free consequence of b1=0.
"""
import numpy as np
from psc_core import incidence_matrix
from balanced_pair import build_bpa, standard_seeds
from scc_matrix import recurrent_sccs, within_scc_matrix
import census

n=0; rows=[]
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>150: break
    try: bpa=build_bpa(s,standard_seeds(s),max_states=3000)
    except Exception: continue
    for comp in recurrent_sccs(bpa):
        if not (2<=len(comp)<=400): continue
        NC=within_scc_matrix(s,bpa,comp)
        if NC.size==0: continue
        ev=np.linalg.eigvals(NC.astype(float))
        r0=int(sum(abs(e)>1e-6 for e in ev))
        rows.append((len(comp), r0))
import statistics
C=[a for a,_ in rows]; R=[b for _,b in rows]
ratios=[b/a for a,b in rows if a>0]
print(f"sampled {n} PIP; {len(rows)} recurrent SCCs")
print(f"  |C| range {min(C)}-{max(C)}; nonzero-spectrum r0 range {min(R)}-{max(R)}")
print(f"  r0/|C| ratio: median {statistics.median(ratios):.3f}, min {min(ratios):.3f}, max {max(ratios):.3f}")
print(f"  fraction with r0 <= 2 (=k-1, the 'tiny residual' regime): {sum(b<=2 for b in R)/len(R):.3f}")
print("INTERPRETATION: if r0 is typically ~|C| (ratio near 1), then 'r <= C_comp-1' is a")
print("strong non-generic constraint -> condition (1) is genuine content needing hom-Pisot,")
print("NOT derivable from b1=0 alone. That CONFIRMS condition (1) is the real open residual.")
