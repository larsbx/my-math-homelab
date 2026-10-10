# C4 relative hierarchy-offset state

**Status:** finite-state reduction for a given finite strict component, implemented canonically in Mojo. It does **not** prove C4, C1, G1, or PSC.

## 1. Purpose

PRs #29–#35 reduce deep zero-return ancestry to two simultaneously visible hierarchies:

1. the original `sigma` supertile hierarchy, with arbitrarily long legal ancestry towers;
2. the derived strict-component substitution hierarchy `tau_C`, with canonical balanced-block addresses and recognizability after cyclic decomposition.

A desubstituted top zero return generally becomes asynchronous: at a source depth `k`, its top and bottom cuts occur at physical positions `i` and `j` in the two sides of `sigma^k(T)`. The absolute positions and absolute derived-block indices grow with depth and are not finite-state.

The correct coordinate is their **relative hierarchy offset**.

## 2. Mojo-first representation

`kernel/psc/derived_system.mojo` constructs the derived substitution once.

At construction time it:

- normalizes every irreducible balanced component state;
- validates balance, noncoincidence, irreducibility, and strict child closure;
- interns each state to one integer ID;
- computes the ordered child-ID word of every state;
- records one `+1/-1` raw-orientation sign per child occurrence;
- stores each state's physical balanced-block length.

String state keys are used only at this one-time interning boundary. Repeated derived expansion uses integer state IDs and one orientation bit only.

The primary constructor is `relative_hierarchy_offset_from_defect`. It consumes the exact ancestry defect already carried by the prefix-difference descent and therefore does **not** re-expand both `sigma^k` side words just to recompute that defect. The slower `relative_hierarchy_offset` wrapper independently reconstructs the physical side words and is retained as a verification oracle. Canonical Mojo regressions require both paths to agree on the calibration.

This is deliberately different from the Python prototype: the hot representation is designed for Mojo rather than translating tuple/dictionary objects mechanically.

## 3. Relative state

For asynchronous source cuts `(i,j)`, let

```text
x = Parikh(top[:i]) - Parikh(bottom[:j]).
```

Then exactly

```text
i-j = sum(x).
```

The common zero-return block partition at that source depth is the word `tau_C^k(T)`. Locate `i` and `j` in this same partition. If their block indices are `b_top,b_bottom`, define

```text
Delta_block = b_top-b_bottom.
```

Every strict-component block has positive integral physical length, so crossing one derived boundary costs at least one physical symbol. Hence

```text
|Delta_block| <= |i-j| = |sum(x)|.
```

The canonical `RelativeHierarchyOffset` stores only:

- fixed 3-coordinate ancestry defect `x`;
- fixed 3-coordinate outgoing correction digit;
- physical cut difference `i-j`;
- relative derived block-index difference;
- top/bottom in-block offsets;
- top/bottom integer state IDs and orientation signs;
- fixed-radius packed derived contexts.

Exterior context positions use one integer sentinel. No absolute depth or absolute block index is retained.

## 4. Finiteness

PR #30 proves that, in a strict PIP component, ancestry defects belong to a finite depth-independent set. Therefore `sum(x)` and hence `Delta_block` range over finite sets.

All other coordinates are visibly finite for fixed `C` and fixed context radius:

- correction digits come from the finite image-prefix alphabet;
- state IDs range over `0..|C|-1`;
- orientations are `+/-1`;
- in-block offsets are bounded by `B_C=max |T|`;
- packed derived contexts use finitely many oriented state symbols plus one sentinel.

Thus the relative hierarchy-offset alphabet is finite independently of ancestry depth.

`state_space_upper_bound` provides a coarse explicit overcount. The proof uses only finiteness; the implementation need not materialize the entire product space.

## 5. Orientation correctness

The parent orientation is physical, not cosmetic. If an occurrence of normalized state `(u,v)` has sign `-1`, its actual top/bottom words are `(v,u)`. The Mojo implementation therefore swaps the base words **before** computing the asynchronous Parikh defect and propagates the same sign through integer-indexed derived expansion.

This incorporates the orientation bug caught during PR #34 directly into the new representation rather than reintroducing canonical-orientation data at deeper levels.

## 6. Calibration

For the repository primitive non-Pisot strict component

```text
1 -> 2
2 -> 123
3 -> 2

A=(12,21)
B=(23,32),
```

state IDs are `A=0,B=1` and the oriented derived rules are

```text
A -> A^- B^+
B -> A^+ B^-.
```

At source depth one, top cut `1` and bottom cut `2` give

```text
x=(-1,0,0),
i-j=-1,
Delta_block=-1,
top=(A^-, offset 1),
bottom=(B^+, offset 0).
```

With radius one, packed contexts are

```text
top:    [sentinel, A^-]
bottom: [A^-, B^+].
```

The regression also checks the physically reversed parent, where the defect and relative block displacement change sign and the propagated orientations swap accordingly.

## 7. What remains

Finiteness and recurrence still do not themselves contradict strictness. The non-Pisot calibration has a periodic finite offset process.

The next C4 step must use **PIP + dual recognizability + endpoint nonsynchronization** to constrain cycles of these relative states. In particular, along arbitrarily long legal towers, a repeated relative state should be tested for whether pumping it creates two incompatible recognizable `sigma`/`tau_C` decompositions of the same legal context, or whether some additional finite address datum is still missing.

This is now the preferred implementation surface for that test: new executable work should extend the integer-indexed Mojo state/transducer rather than the older Python hierarchy-offset prototype.
