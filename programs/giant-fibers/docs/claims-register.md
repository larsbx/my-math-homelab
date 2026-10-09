# Claims register

No statement is promoted from **draft** to **proved in this project** until its listed proof obligations are closed.

| ID | Statement | Status | Notes |
|---|---|---|---|
| G0 | A smooth split quadric surface over (mathbf F_q) has two rulings and ((q+1)^2) points. | classical | Standard finite/projective geometry. |
| G1 | A plane section of (Q^+(3,q)) is a nonsingular conic or a pair of generator lines. | classical | Tangent sections give the reducible case. |
| G2 | A nonsingular projective conic over (mathbf F_q) has (q+1) points. | classical | Standard. |
| D0 | The chosen Gram matrix and (B(x,y)=x^TGy) encode the repository’s Descartes normalization. | to formalize | Must be frozen explicitly before theorem work. |
| D1 | For split odd primes, the pencil (B(x,a)=c x_0) has singular parameters exactly (cin{0,-8}). | draft target | Requires direct discriminant/duality or audited elimination. |
| D2 | The affine count (N_c(a)) is independent of (ain X_p^{(0)}). | draft target | Full orthogonal transitivity is insufficient because the chart is distinguished. |
| D3 | Every relevant projective section loses exactly two rational points at infinity. | draft target | Must be proved from the actual boundary line/conic geometry. |
| D4 | (N_c=2p-1) for (cin{0,-8}) and (N_c=p-1) otherwise. | draft target | Depends on D1–D3. |
| D5 | The heavy-fiber probability is ((2p-1)/(p(p+1))). | conditional | Follows immediately from D4 plus (|X_p^{(0)}|=p(p+1)). |
| A0 | Primitive Apollonian orbit reductions are controlled by strong approximation away from small-prime phenomena. | literature | Use precise theorem hypotheses when applied. |
| A1 | Thin-group local-global behavior can exhibit reciprocity obstructions beyond elementary congruence admissibility. | literature | Modern counterexample results. |

## Proof obligations for the split theorem

### P0 — freeze normalization

Record (G), (Q), (B), the distinguished coordinate (x_0), characteristic exclusions, and the exact meaning of “split prime.”

### P1 — split criterion

Compute the discriminant/Witt class of the Descartes form modulo (p) and give an explicit criterion for split versus nonsplit primes, including exceptional primes where the form degenerates.

### P2 — tangent-parameter polynomial

Represent the plane (H_c(a)) as a point in dual projective space and substitute it into the dual quadric.  Derive the polynomial in (c) whose roots are singular sections.  Prove that its roots are exactly the claimed values in the chosen normalization, or correct the claim.

### P3 — anchor dependence

Either:

- identify a subgroup preserving the affine chart and show it acts transitively on anchors, or
- compute the fiber count directly for arbitrary (a), showing any anchor-dependent invariants cancel.

Do not invoke full (O(Q))-transitivity alone.

### P4 — points at infinity

Analyze
[
X_pcap{x_0=0}cap{B(x,a)=0}
]
for arbitrary admissible (a).  Prove the number of rational points removed from each projective section.

### P5 — elimination provenance

Reproduce any elimination identity used to obtain (B(a_1,a_2)in{0,-8}), with exact polynomial identities and characteristic assumptions.  Store a machine-checkable witness where practical.

### P6 — exhaustive finite-field regression

Enumerate all anchors and all (c) for a representative set of split and nonsplit primes.  This is a falsification gate, not a proof.

Only after P0–P6 are closed should D4 be labeled proved in this repository.
