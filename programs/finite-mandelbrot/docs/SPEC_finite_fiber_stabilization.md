# SPEC_finite_fiber_stabilization

Status: draft theorem-spec. Highest-priority project target.

## 0. Purpose

This spec isolates the project's central conjecture:

```text
finite rational-ray nest stabilization
iff
triviality of Mandelbrot fibers
iff
MLC.
```

The spec does not attempt to prove MLC. Its contribution is to identify the exact finite certificate objects whose global stabilization is equivalent to the classical obstruction.

## 1. Finite ontology

The certificate core has no analytic points, measured angles, real numbers, transcendental functions, or limits.

Allowed finite carriers:

- `Vertex`
- `PointVertex`, meaning a vertex whose payload is a finite set of vertices
- `RootHandle(poly, box, witness)`
- `RayAddr(num, den)` in `Q/Z`
- `DyadicBox`
- `SeparationLine`
- `FiniteNest_k`
- theorem-tag identifiers

A point, when named, means only:

```text
PointVertex({RootHandle, RayAddressSet, DyadicBox, ...})
```

## 2. Separation-line grammar

A finite separation line is a certificate-bearing record:

```text
SeparationLine := {
  schema: "SeparationLine/V1",
  ray_addr_left: RayAddr,
  ray_addr_right: RayAddr,
  landing_anchor_kind: AnchorKind,
  landing_anchor: RootHandle | ComponentRootHandle | TheoremTaggedAnchor,
  landing_theorem_tag: TheoremTag,
  separated_carriers: Pair<CarrierID, CarrierID>,
  proof_payload: CombWitness
}
```

### 2.1 Anchor kinds

```text
AnchorKind :=
  MisiurewiczAnchor
| ParabolicRootAnchor
| HyperbolicBoundaryAnchor
| TheoremTaggedGenericAnchor
```

Only the first three are established-case anchors. `TheoremTaggedGenericAnchor` is not allowed to assert singleton fiber behavior.

### 2.2 Separation predicate

The finite predicate is:

```text
Separates(line, A, B) -> Bool
```

where `A` and `B` are finite carriers such as `PointVertex`, `RootHandle`, `NestCarrier`, or symbolic fiber labels.

Inside the finite core, this predicate is checked by:

1. rational ray-address order;
2. finite combinatorial side-of-line data;
3. theorem-tagged landing anchor;
4. incidence membership of the carriers being separated.

No analytic geometry is used inside the certificate.

## 3. Fiber relation as separation nonexistence

Define the finite relation:

```text
SameFiber_k(A, B)
```

meaning no certified separation line of depth at most `k` separates `A` and `B`.

Define the meta-level relation:

```text
SameFiber(A, B) := for all k, SameFiber_k(A, B).
```

This universal quantification is outside any finite certificate. Each `SameFiber_k` check is finite.

Bridge claim:

```text
SameFiber(A, B)
```

matches Schleicher's fiber relation when `A` and `B` are interpreted through the theorem-tag boundary.

## 4. Finite nest grammar

For a symbolic fiber label or address `tau`, define a finite nest record:

```text
FiniteNest := {
  schema: "FiniteNest/V1",
  tau_id: TauID,
  depth: Nat,
  separation_lines_used: List<SeparationLineID>,
  carrier: NestCarrier,
  dyadic_cover: List<DyadicBox>,
  diameter_bound: Q,
  incidence_vertex: Vertex,
  theorem_tags_used: List<TheoremTag>
}
```

Every field is finite.

## 5. Refinement predicate

A refinement certificate is finite:

```text
Refines(N_k, N_{k+1}) :=
  same tau_id
  depth(N_{k+1}) = depth(N_k)+1
  every carrier in N_{k+1} is contained in carrier of N_k
  every dyadic box in N_{k+1} is contained in some dyadic box of N_k
  separation_lines_used(N_k) subset separation_lines_used(N_{k+1})
  diameter_bound(N_{k+1}) <= diameter_bound(N_k)
```

No limiting statement appears here.

## 6. Stabilization as meta-scheme

A finite certificate can only prove bounded-depth facts. Stabilization is a meta-level scheme:

```text
Stabilizes(tau) :=
  for every positive rational epsilon,
  there exists k such that
  diameter_bound(FiniteNest(tau,k)) < epsilon.
```

This statement is not inside any finite certificate payload. It is the theorem target.

## 7. Highest-priority conjecture C1

```text
C1: Global finite nest stabilization iff MLC.
```

Expanded:

```text
(for all tau, Stabilizes(tau))
iff
(all Mandelbrot fibers are trivial)
iff
MLC.
```

The first equivalence is the project's finite reformulation target.
The second equivalence is theorem-tagged through Schleicher's fiber framework.

## 8. Established cases

The finite program should first recover established cases:

### 8.1 Misiurewicz anchors

For Misiurewicz root handles, the finite certificate supplies:

- squarefree localization;
- same-box forbidden-collision exclusion;
- rational ray-address datum;
- theorem tag for rational-ray landing;
- theorem tag for Misiurewicz fiber triviality;
- incidence `PointVertex`.

Result: finite nest stabilizes at that anchor in the established sense.

### 8.2 Hyperbolic component boundary anchors

For hyperbolic boundary anchors, the finite certificate supplies:

- component/root combinatorics;
- rational ray-address landing data where available;
- theorem tag for boundary fiber triviality;
- separation-line incidence data.

Result: established-case stabilization.

## 9. Open frontier

Generic boundary carriers do not receive unconditional singleton certificates.

The generic branch may produce:

```text
FiniteNest_0, FiniteNest_1, FiniteNest_2, ...
```

Each finite stage is valid. The claim that the nest stabilizes is exactly the MLC-level obstruction.

Invalid claims:

- generic co-landing is unconditionally finitely certified;
- every generic fiber is singleton by construction;
- dyadic shrinking alone proves fiber triviality;
- renderer convergence proves MLC.

## 10. Blocks removed from critical path

Deferred until after C1 theorem-spec is stable:

- full bigint implementation;
- hash-root finalization;
- renderer/pixel pipeline;
- finite-field shadow experiments;
- performance optimization;
- general Krawczyk acceleration.

Allowed now:

- separation-line grammar;
- finite nest grammar;
- refinement predicate;
- established-case examples;
- theorem-tag registry;
- tests enforcing no analytic drift.

## 11. Acceptance criteria for this spec

The spec is stable when it includes:

1. formal `SeparationLine` schema;
2. formal `FiniteNest` schema;
3. finite `Refines` predicate;
4. meta-level `Stabilizes` scheme;
5. exact theorem-tag boundary;
6. established Misiurewicz case;
7. established hyperbolic-boundary case;
8. explicit generic open frontier;
9. no analytic point or trig primitives;
10. no implementation task treated as proof of C1.
