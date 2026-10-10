# P1b strict zipper: M-adic carry reduction — 2026-10-01

**Status:** repository proof of an exact finite-place reduction and recurrence
equivalence for #139. The reduction supplies a sound M-adic prefilter; after
integral descaling, its candidates follow the existing affine overlap
recurrence. Quotient iteration alone does not yet supply a forcing theorem;
a separate finite-quotient completeness or coverage theorem remains possible.
It does **not** prove AdelicPeriodicOffsetHitting, overlap productivity, or PSC.
#84, #138, #139, and PSC remain open.

## 1. Descaled prefix-difference candidates

For ordered letters i,j, let

```text
D_m(i,j) = P_m(i) - P_m(j)
```

be the difference of proper-prefix Parikh sets.

Define the descaled integral candidate set

```text
Z_m(i,j) = { z in Z^3 : M^m z in D_m(i,j) }.
```

This is the part of the level-m prefix-difference set that survives the
strongest level-m finite cokernel

```text
Z^3 / M^m Z^3
```

followed by exact integral descaling.

For an overlap offset w, the existing boundary-hitting criterion becomes

```text
M^m w in D_m(i,j)
iff
w in Z_m(i,j).
```

Thus the strict-zipper target is exactly eventual membership of its realized
offset in these descaled candidate sets.

## 2. Finite-place zero-class lemma

### Lemma 2.1

If an overlap (i,j,w) has an offset-zero descendant at level m, then some
occurrence-labelled d in D_m(i,j) satisfies

```text
d in M^m Z^3.
```

Equivalently, the corresponding prefix difference is zero in

```text
Z^3 / M^m Z^3.
```

Therefore, if no proper-prefix occurrence pair survives the zero class at
level m, a level-m hit is impossible.

### Proof

A hit gives d = M^m w for some d in D_m(i,j). Since w is integral, the
membership follows.

This is one-sided. A zero-class survivor is not a hit: it has the form
d = M^m z for a unique integral z, and the hit occurs only when z = w.

For unimodular M, M^m Z^3 = Z^3, so every prefix difference survives. The
filter correctly contributes no information in the unit case.

## 3. Exact carry recursion

### Theorem 3.1 — descaled candidates obey the overlap affine update

For m >= 0,

```text
z in Z_(m+1)(i,j)
```

if and only if there are occurrences

```text
sigma(i) = p a s
sigma(j) = q b t
```

and a state z' in Z_m(a,b) such that

```text
z' = M z + pi(q) - pi(p).
```

The occurrences are part of the witness; repeated child letters at different
positions are not identified.

### Proof

A proper prefix of sigma^(m+1)(i) that enters the occurrence sigma^m(a) after
the first-level prefix p has Parikh vector

```text
M^m pi(p) + u,  with u in P_m(a).
```

Similarly the bottom prefix has the form

```text
M^m pi(q) + v,  with v in P_m(b).
```

Their difference is

```text
d_(m+1) = M^m (pi(p) - pi(q)) + (u-v).
```

Now z is in Z_(m+1)(i,j) precisely when d_(m+1) = M^(m+1) z for some such
occurrence pair. Rearranging gives

```text
u-v = M^m ( M z + pi(q) - pi(p) ).
```

Hence

```text
z' := M z + pi(q) - pi(p)
```

lies in Z_m(a,b). Every step reverses, so the condition is also sufficient.

## 4. The key architectural consequence

The update

```text
z' = M z + pi(q) - pi(p)
```

is exactly the occurrence-labelled overlap child recurrence

```text
w' = M w + pi(q) - pi(p).
```

Therefore the family Z_m is not a new dynamical state space. It is the
**reverse zero-offset basin of the same affine overlap dynamics**:

```text
w in Z_m(i,j)
iff
(i,j,w) has an occurrence-labelled length-m path to offset zero.
```

The conclusion is recurrence equivalence:

> **Deeper M-adic quotient iteration alone does not yet supply the missing
> forcing theorem for #139.** Once a zero-class prefix difference is integrally
> descaled, its carry recursion is precisely the existing affine overlap
> recurrence.

The finite-place quotient can discard impossible prefix pairs before exact
comparison. The identity does not show that every relevant realized orbit
enters the reverse zero-offset basin, and it does not rule out proving that
coverage through a finite quotient with a separate completeness map.

A closure argument still needs an occurrence-compatible completeness or
coverage theorem. Possible routes include a complete finite-quotient argument,
Rauzy-subtile geometry, Archimedean-plus-finite-place coverage, or another
complete recurrence theorem. None is supplied by the carry identity alone.

## 5. Canonical exact diagnostic

Canonical Mojo support is in

- `kernel/psc/overlap_madic_filter.mojo`;
- `kernel/tests/test_overlap_madic_filter.mojo`.

The diagnostic enumerates occurrence-labelled proper-prefix pairs and retains
only differences in M^m Z^3, using the exact M-adic lattice carrier from
finite_linear_algebra. A configured word cap raises and is never reported as
a negative result.

On the determinant-two golden regression

```text
0 -> 1
1 -> 0 2 1
2 -> 0 0 1
```

the ordered pair (1,2) at level two has word lengths 7 and 5, hence 35
proper-prefix occurrence pairs. Exactly 11 survive the zero class in
Z^3 / M^2 Z^3.

This is an exact finite-domain fact and demonstrates that the non-unit
finite-place filter is nontrivial.

On the unimodular Tribonacci substitution

```text
0 -> 0 1
1 -> 0 2
2 -> 0
```

the level-two pair (0,1) has 12 proper-prefix occurrence pairs and all 12
survive, as required because the cokernel is trivial.

The diagnostic explicitly exports the non-claim that a zero-class survivor
proves a hit.

## 6. Relation to the adelic target

The M-adic quotient is a conservative integral shadow of the finite-place
coordinates required in the non-unit representation. It does **not** replace
the full Minervino–Thuswaldner representation and is not called a local-field
model.

The current strict-zipper route can now be separated into three layers:

1. **finite-place compatibility:** the prefix difference survives
   Z^3 / M^m Z^3;
2. **integral carry state:** descaling gives z in Z_m(i,j), whose recursion is
   exactly the overlap affine update;
3. **forcing / coverage:** prove that a realized periodic strict-zipper
   offset must enter this reverse zero basin.

Layers 1–2 are now exact. Layer 3 is AdelicPeriodicOffsetHitting and remains
open.

## 7. Next admissible theorem

Using a deeper cokernel alone refines the same affine carry information. A
finite-quotient route remains admissible if it supplies a proved completeness
or coverage map forcing every relevant orbit into the reverse zero basin.
That theorem remains open.

One admissible target is:

> **Occurrence-compatible adelic coverage lemma (open).** For a child-closed
> realized strict-zipper SCC, the full adelic periodic orbit of at least one
> vertex must enter the graph-directed prefix-difference subtile corresponding
> to its occurrence-labelled reverse zero basin.

A weaker theorem about closure, positive measure, multiple tiling, or an
untyped difference of Rauzy subtiles remains insufficient.

## 8. Generality firewall

No inverse of M over Z^3 is assumed. No unimodularity, Euclidean-only internal
space, global realization, legality of the swap word, or finite-search
completeness assumption is introduced.
