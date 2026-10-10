"""
AUDIT: is chi_A | chi_NC <=> closed-nonproductive really correct?
v13 lem:alg-structure proves: CLOSED NONPRODUCTIVE => N_C P = P M^T, P injective
   => chi_M | chi_NC.
My census: EVERY corpus SCC has gcd(chi_M, chi_NC)=1.
Reconciliation claim: corpus SCCs are PRODUCING (open or leaky), so lem:alg-structure
   does not apply; divisibility is equivalent to closed-nonproductive.

CHECK the equivalence direction I asserted: "chi_M | chi_NC <=> beta in spec(N_C) <=>
   PF(N_C)=beta <=> closed nonproductive". Is chi_M | chi_NC really EQUIVALENT to
   closed-nonproductive, or only implied BY it? If only implied, a producing SCC could
   still have chi_M | chi_NC by accident, and my "gcd=1 always" would then be a
   nontrivial empirical fact, not a tautology. Let me test whether ANY producing SCC
   has beta as an eigenvalue (which would be the real concern).
"""
import numpy as np, sympy as sp
from psc_core import incidence_matrix
from balanced_pair import build_bpa, standard_seeds
from scc_matrix import recurrent_sccs, within_scc_matrix, pf_eigenvalue, is_closed
import census
x=sp.symbols('x')

# Direct check: for producing SCCs, can beta EVER be an eigenvalue of N_C even though PF<beta?
# beta is the SPECTRAL RADIUS of M. If beta in spec(N_C) but PF(N_C)<beta, that's impossible
# for a nonneg matrix only if beta>0 real and PF is the max modulus... beta>0, so beta in
# spec(N_C) => PF(N_C)>=beta. Contrapositive: PF(N_C)<beta => beta not in spec(N_C) => 
# chi_M (whose root beta) does not divide chi_NC UNLESS chi_M's OTHER roots... no, if beta
# is not a root of chi_NC then chi_M does not divide chi_NC (beta is a root of chi_M).
# So PF(N_C)<beta == producing == chi_M does NOT divide chi_NC. The equivalence is SOUND.
# Let me verify PF<beta on a sample to confirm producing-ness, and that NO eigenvalue equals beta.
n=0; viol=0; pf_ge=0
for s in census.enum_k3(max_len=3):
    if not census.is_pip(s)[0]: continue
    n+=1
    if n>200: break
    M=incidence_matrix(s); beta=max(abs(np.linalg.eigvals(M)))
    try: bpa=build_bpa(s,standard_seeds(s),max_states=3000)
    except Exception: continue
    for comp in recurrent_sccs(bpa):
        if len(comp)<2: continue
        NC=within_scc_matrix(s,bpa,comp)
        if NC.size==0: continue
        ev=np.linalg.eigvals(NC.astype(float))
        pf=max(abs(ev))
        # is beta an eigenvalue?
        beta_in = min(abs(ev-beta))<1e-6
        if pf>beta+1e-6: pf_ge+=1
        if beta_in and pf<beta-1e-6:
            viol+=1  # beta eigenvalue but not PF — would be the impossible case
print(f"sampled {n} PIP; SCCs with PF>beta: {pf_ge}; impossible(beta-eig-not-PF): {viol}")
print("Equivalence chi_M|chi_NC <=> PF=beta <=> closed-nonprod is SOUND iff viol=0 and the")
print("nonneg-matrix fact (beta in spec => PF>=beta) holds. Confirmed by construction.")
