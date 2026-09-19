# Giant Fibers in Finite Fields and Thin Groups

This repository studies exact finite-field geometry of the Descartes quadric and its arithmetic interface with Apollonian thin groups.

## Central object

Let (Q(x)=x^T Gx) be the Descartes quadratic form over an odd finite field and (B(x,y)=x^TGy).  Write

[
X_p={[x]inmathbf P^3(mathbf F_p):Q(x)=0}
]

and, in the affine chart (x_0=1),

[
N_c(a)=#{bin X_p^{(0)}:B(a,b)=c}.
]

The current Descartes-specific draft predicts, at split primes,

[
N_c(a)=
egin{cases}
2p-1,&cin{0,-8},\
p-1,&	ext{otherwise}.
end{cases}
]

Geometrically, the proposed mechanism is that the two heavy fibers are reducible hyperplane sections: pairs of ruling lines on the split quadric.

## Status discipline

The formula above is a **research target**, not a repository theorem yet.  The general geometry of split quadrics is classical, but several Descartes/chart-specific steps require an explicit audit.  In particular, transitivity of the full orthogonal group on isotropic lines does **not by itself** imply anchor-independence in a fixed affine chart, because a general orthogonal transformation need not preserve (x_0=1).

See:

- `docs/literature-review.md` — current academic context and connections;
- `docs/claims-register.md` — proved/classical/draft/conjectural separation;
- `docs/research-agenda.md` — prioritized theorem and computation program;
- `research/experiment-protocol.md` — exact-enumeration falsification protocol;
- `research/sources.yaml` — machine-readable source map.

## Research layers

1. **Classical finite geometry:** hyperbolic and elliptic quadrics, rulings, tangent/secant sections, Witt theory.
2. **Descartes-specific local geometry:** exact exceptional parameters, chart counts, split/nonsplit classification.
3. **Prime-power arithmetic:** (p)-adic lifting and local densities modulo (p^k).
4. **Thin-group dynamics:** congruence images, expansion, random walks, orbit-vs-ambient statistics.
5. **Local-global synthesis:** separating ambient geometric irregularities from reciprocity/thin-orbit obstructions.
6. **Higher-dimensional analogues:** Soddy-Gossett/Apollonian-type quadrics and exceptional-section strata.

## Computational policy

Exact experiments are first-class but evidentiary: they may falsify, classify, or suggest a theorem, never replace a proof.  Mojo is the intended first-class implementation language for exact finite-field kernels.  No floating-point or transcendental arithmetic is needed for the core program.
