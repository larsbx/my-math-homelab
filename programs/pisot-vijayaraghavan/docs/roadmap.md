# Research roadmap

PV is open. Authoritative statuses are in proof/claims.toml; finite
experiments do not close proof obligations.

## Completed milestone — exponential defect window (issue #2)

PV-EXP-WINDOW, PV-HANKEL-RANK-BRIDGE, and their PV-H3 composition are PROVED.
The [manuscript proof](exponential-window-hankel.md) establishes the strict
size condition $(k-1)(1-\gamma)>1$, its least size
$\lfloor1/(1-\gamma)\rfloor+2$, all reciprocal-integer boundary cases,
singular-layer descent, constant recurrence coefficients, and the Pisot
endpoint for this exponential-saving regime.

The bridge uses one fixed size at every late starting index. It does not
give recurrence from a finite census, sparse shifts, or moving sizes.
The withdrawn limsup argument is not used.

## Completed milestone — normalized-defect proof interfaces

[Reconstruction](defect-reconstruction.md) now proves
PV-REDUCTION-CONVERSE with a uniform ratio floor above one, including the
two-tail error bound and the exact `a_n=n` negative control for weaker
growth hypotheses. It proves PV-POLY-EQUIV for real `A>0` after establishing
exponential comparability, and PV-SALEM-EXCLUSION conditional on an
independently established rational recurrence. The latter uses an Abel
estimate to exclude unit-circle poles; recurrence is not inferred from
vanishing error.

The [standalone square-root note](square-root-barrier.md) gives the
degree-at-most-two Pisot endpoint and its big-O degree-three boundary.
Pisot's 1938 Chapter III, Theorem I is pinned as PV-L2-RECURRENCE
(**IMPORTED**). Its proved corollary PV-POLY-L2-RANGE closes the Pisot
endpoint for `A>1/2` and for square-summable witnesses generally.

## Priority 1 — the remaining recurrence interface

1. Obtain a recurrence for the general vanishing-error/subexponential
   regime outside an independently verified recurrence or summability
   hypothesis. Polynomial equivalence is banked; it is not a collapse
   argument.
2. Audit stronger published decay criteria before presenting any remaining
   numerical decay range as new work. In particular, `O(n^-1/2)` or even
   `o(n^-1/2)` does not automatically imply square summability, as exact
   rational block controls show. These are not PV counterexamples.

The general PV problem remains open. The imported square-sum criterion
alone does not close polynomial bounds `0<A<=1/2`; this roadmap does not
claim a complete literature classification of that range.

## Priority 2 — two-state period-four frontier

Attack $(A,A,B,B,A,A,B,B,\ldots)$ and its shifts under bounded gcd and
residual subexponential defect decay, using the full transition data

$$
g_{n+1}=b_nd_n,\qquad b_n=\gcd(v_n,h_n),\qquad d_n\mid g_n,\qquad
D_n=\frac{c_n}{g_ng_{n+1}}\in\mathbb Z.
$$

Deliverables:

- four-step primitive-pair normal form and four-phase transition table;
- $(b_n,d_n,D_n)$ valuation cycle;
- exact persistence-depth census with replayable witnesses and spike
  transitions;
- negative controls for constant, period-two, gcd-one, and tied rounding.

The existing seed $(9,38)$ is a transient witness only. Issue #3 tracks
persistence depth; issue #4 tracks the symbolic normal form.
See docs/frontier-period4.md and the committed census note.

## Priority 3 — small-prime mass, return blocks, and coprime tails

For nonzero defects, separate the prime factors in
$S=\{p:p\le G\}$ from the complementary fresh-prime part.
Treat large $S$-parts by valuation dynamics and large complementary parts by
freshness/run/projective methods. Prove the relevant mass lower bound before
using a fresh-prime-mass argument.

Treat two-step returns as local coprime-normalized quadratic-residue
instances; identify the additional input needed to glue them.
PV-COPRIME-TAIL remains OPEN. Transport is background algebra.

## Deferred

Three-state Plücker/cycle identities are conditional special-case salvage.
They stay off the critical path until period four is understood.
