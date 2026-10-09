# C4 endpoint-core normal form

**Status:** finite-map classification proved; PIP/SCC elimination remains open.

This note is the first reduction in issue #9. It classifies exactly the finite
endpoint dynamics that can support a nonsynchronizing boundary on a three-letter
alphabet.

The endpoint maps of a substitution are

- `sigma_+(a) = first(sigma(a))`,
- `sigma_-(a) = last(sigma(a))`.

For either map `h`, an adjacent ordered pair `(a,b)` evolves under the product
map

`H(a,b) = (h(a), h(b))`.

It synchronizes precisely when some iterate of `H` reaches the diagonal.
Therefore a boundary that remains nonsynchronizing forever is governed entirely
by the off-diagonal recurrent dynamics of `H`.

## 1. Seven map types

There are `3^3 = 27` self-maps of a three-letter alphabet. Up to simultaneous
relabeling of domain and codomain, there are exactly seven functional-graph
types.

The table uses zero-based canonical representatives solely for compactness.

| Type | Canonical `h` | Functional graph | Class size | Nonsync ordered pairs | Recurrent nonsync core |
|---|---|---|---:|---:|---:|
| A | `(0,0,0)` | one fixed point, two direct leaves | 3 | 0 | 0 |
| B | `(0,0,1)` | one fixed point, tail of length two | 6 | 0 | 0 |
| C | `(0,0,2)` | two fixed points, one leaf | 6 | 4 | 2 |
| D | `(0,1,2)` | three fixed points | 1 | 6 | 6 |
| E | `(0,2,1)` | one fixed point plus a 2-cycle | 3 | 6 | 6 |
| F | `(1,0,0)` | a 2-cycle plus one leaf | 6 | 4 | 2 |
| G | `(1,2,0)` | one 3-cycle | 2 | 6 | 6 |

The class sizes sum to 27.

### Proposition 1 — completeness

Every map on three letters is conjugate to exactly one row A--G.

### Proof

A finite functional graph is a disjoint union of directed cycles with rooted
in-trees feeding the cycle vertices. On three vertices the possible cycle
partitions and tree attachments are exhausted as follows.

- One 1-cycle and no other cycle: the remaining two vertices either both map
  directly to the fixed point (A), or form a tail of length two into it (B).
- Two 1-cycles: the remaining vertex feeds one of them (C).
- Three 1-cycles: identity (D).
- One 1-cycle plus one 2-cycle: E.
- One 2-cycle and no other cycle: the remaining vertex feeds one cycle vertex
  (F).
- One 3-cycle: G.

These functional graphs are pairwise non-isomorphic, so the conjugacy classes
are distinct. The executable enumeration in `psc_research.endpoint_core`
independently enumerates all 27 maps and reproduces exactly the seven canonical
representatives and class sizes. QED.

## 2. Product-map obstruction cores

Let

`NSync(h) = {(a,b): a != b and h^n(a) != h^n(b) for every n >= 0}`.

Let `Core(h)` be the subset of `NSync(h)` consisting of periodic points of
`h x h`. These are the recurrent off-diagonal endpoint-pair states.

The exact cores for the seven canonical maps are:

```text
A (0,0,0): ()
B (0,0,1): ()
C (0,0,2): ((0,2),(2,0))
D (0,1,2): all six ordered distinct pairs
E (0,2,1): all six ordered distinct pairs
F (1,0,0): ((0,1),(1,0))
G (1,2,0): all six ordered distinct pairs
```

Thus only A and B are globally synchronizing. Any hypothetical
nonsynchronizing endpoint regime must use one of the five types C--G.

The core orbit periods are at most three:

- C: fixed ordered pairs between the two fixed points;
- D: every ordered pair fixed;
- E: three product 2-cycles;
- F: one product 2-cycle on the underlying letter 2-cycle;
- G: two product 3-cycles.

### Proposition 2 — global endpoint synchronization eliminates SCC Producer counterexamples

If either `sigma_+` or `sigma_-` is globally synchronizing (type A or B), then
every balanced pair is productive. In particular SCC Producer holds for that
substitution without using the Pisot property or BPA finiteness.

### Proof

Let `T=(u,v)` be any noncoincident balanced pair. The position `0` is a
zero-return boundary. Its right adjacent pair is `(u[0],v[0])`; if `sigma_+` is
globally synchronizing, the Boundary Synchronization Lemma turns that boundary
into a coincidence sibling after finitely many further inflations.

Likewise the terminal position `|u|=|v|` is a zero-return boundary. Its left
adjacent pair is `(u[-1],v[-1])`; global synchronization of `sigma_-` again
forces a coincidence sibling.

Thus global synchronization of either endpoint map makes every balanced pair
productive. QED.

Hence any counterexample to SCC Producer must have **both** endpoint maps in
types C--G. This is the first unconditional eliminator in C4.

## 3. One-step core-entry theorem for three letters

### Proposition 3

For every self-map `h` of a three-letter alphabet and every ordered pair
`(a,b)`, exactly one of the following occurs:

1. the pair synchronizes; or
2. the pair already belongs to `Core(h)`; or
3. the pair does not initially belong to `Core(h)`, and after **one** application
   of `h x h` it enters `Core(h)` for the first time.

In particular, there is no nonsynchronizing transient of length greater than
one.

### Proof

Check the seven complete map types above.

- A and B have no nonsynchronizing pairs.
- C has only pairs involving its two eventual fixed-point basins. A pair using
  the leaf enters the ordered fixed-point pair after one step.
- D and E have no transient vertices, so every nonsynchronizing pair is already
  recurrent.
- F has one transient leaf. Every nonsynchronizing pair using it enters the
  ordered pair of the two cycle vertices after one step.
- G has no transient vertices.

The property is invariant under relabeling. QED.

`tests/test_endpoint_core.py` also checks this proposition exhaustively over all
27 maps and every ordered distinct pair.

## 4. Synchronization quotient

Define `a ~_h b` when the forward orbits of `a` and `b` eventually coalesce at
the same iterate. This is an equivalence relation. Because `a ~_h b` iff
`h(a) ~_h h(b)`, the map `h` induces a bijection on the quotient classes.
Consequently nonsynchronization is equivalent to lying in distinct quotient
classes, and the quotient-class phase is periodic from the start.

For three letters, the quotient has size at most three, so its induced
permutation has order at most three. This gives a cleaner normal form than
tracking transient letters individually: all persistent endpoint obstruction
data is a finite quotient class together with a phase modulo 1, 2, or 3.

## 5. Consequence for a hypothetical nonproductive sink SCC

The Boundary Synchronization Lemma says that a boundary adjacent pair that
synchronizes under `sigma_+` or `sigma_-` yields a coincidence sibling after a
finite number of further inflations. Therefore a genuinely nonproductive
boundary lineage must remain in `NSync`.

Proposition 3 sharpens this on three letters: after at most one endpoint-map
step, every such lineage lies in one of the periodic cores C--G and thereafter
has period 1, 2, or 3. Equivalently, in the synchronization quotient it is
periodic from the start.

So C4 does **not** need to reason about arbitrary endpoint transients. The
remaining counterexample normal form can assume periodic endpoint-core data
almost immediately.

This does not by itself prove that the relevant boundary lineage recurs inside
a closed balanced-pair SCC, nor does it prove that an interior newborn boundary
must occur. Those are the next steps.

## 6. Reduced C4 program

The remaining work is now:

### C4-B — couple core dynamics to balanced-pair recurrence

For a hypothetical closed nonproductive recurrent SCC `C`, build the finite
boundary-signature transition system whose records include:

- the balanced-pair state/type;
- left and right adjacent endpoint pairs at inherited and newborn cuts;
- their C--G core type / quotient class and phase;
- which child block in `C` inherits each boundary.

Because all endpoint-core phases have period at most three, any repeated SCC
state/signature produces a short periodic boundary template.

### C4-C — enumerate periodic nonsynchronizing templates

Use recurrence/pigeonhole to reduce the contradiction hypothesis to finitely
many periodic templates. The goal is a canonical list rather than random
examples.

### C4-D — eliminate the templates

Attempt eliminators in increasing strength:

1. primitivity / required letter occurrence;
2. irreducibility of the characteristic polynomial;
3. Pisot stable-direction contraction and exact algebraic relations;
4. spectral mass leakage only for templates that survive 1--3.

Any surviving template is an explicit open obstruction candidate and must be
preserved rather than silently discarded.

## 7. Executable reference

- `reference/psc_research/endpoint_core.py` — exact classification, synchronization
  quotient, and product-core dynamics;
- `kernel/endpoint_core_catalog.mojo` — deterministic report, CI-pinned;
- `tests/test_endpoint_core.py` — exhaustive three-letter regressions.

This finite-map layer has no floating point and no substitution-specific
assumptions.
