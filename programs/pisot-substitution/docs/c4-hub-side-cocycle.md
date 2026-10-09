# C4 hub-side cocycle

**Status:** exact finite bridge between the Barge-Diamond hub normal form and the existing `Z/2` child-orientation signing. It does **not** prove C4, C1, G1, or PSC.

## 1. Input

After the Barge-Diamond endpoint eliminator, fix one eventually-coincident letter pair `{a,b}` and let `c` be the complementary hub letter. In a strict nonproductive alphabet-3 regime every distinct right-adjacent zero-return boundary pair is `{a,c}` or `{b,c}`. Hence every strict state begins with `c` on exactly one side.

For a normalized derived state `S`, define

```text
x_c(S) = 0  if the canonical top side starts with c,
         1  if the canonical bottom side starts with c.
```

For a raw child occurrence `e:T->S`, let `b(e)=0` for positive canonical orientation and `b(e)=1` when the raw child is the reversed representative.

## 2. Physical hub-side identity

Normalization swaps top and bottom exactly when `b(e)=1`. Therefore the side carrying the hub in the **physical raw child** is

```text
y_c(e) = x_c(S) + b(e) mod 2.
```

Compare that physical child side with the canonical hub side of the parent:

```text
r_c(e) = y_c(e) + x_c(T)
       = b(e) + x_c(T) + x_c(S) mod 2.
```

Thus `r_c` is exactly the child-orientation cochain after the vertex gauge `x_c`.

This is the desired finite bridge: the abstract orientation sign now has a direct boundary interpretation. `r_c(e)=0` means the physical child carries the hub on the same side as the canonical parent; `r_c(e)=1` means the opposite side.

## 3. Perron phase is unchanged on one SCC

PR #38 classifies a signed strongly connected support graph by the cohomology class

```text
b(e) = z(src)+z(dst)+q lambda(e) mod 2.
```

Replacing `b` by

```text
r_c(e)=b(e)+x_c(src)+x_c(dst)
```

is a vertex gauge transformation. Hence the existence and value of the Perron phase `q` are unchanged.

This comparison is an **SCC-level statement**. A `DerivedSystem` can be constructed directly with a reducible support even though the strict-component builder normally supplies an SCC. The canonical Mojo helper therefore checks strong connectivity explicitly and fails closed before invoking the signing solver when the support is not one SCC.

The canonical Mojo implementation verifies phase equality exactly by running the existing signing solver on both edge lists. This is a finite computation supporting an elementary `F_2` identity; it is not a spectral proof by itself.

## 4. Mojo-first implementation

`kernel/psc/hub_cocycle.mojo` builds the hub data directly on the integer-indexed `DerivedSystem`:

- validates that the chosen hub occurs in every state's first pair exactly once;
- stores one canonical hub-side bit per state;
- computes the physical hub side of every raw child occurrence from the child state ID and orientation bit;
- computes the gauge residual `r_c`;
- checks that Perron-phase comparisons are made on one strongly connected support;
- converts both the original and hub-gauged cochains to `SignedEdge` lists for the PR #38 Perron-phase solver.

No string state keys or Python object graphs enter the hot path. The SCC predicate is a one-time validation path, not part of ancestry enumeration.

## 5. Calibration

For the primitive non-Pisot strict component

```text
1 -> 2
2 -> 123
3 -> 2

A=(12,21), B=(23,32), hub=2,
A -> A^- B^+,
B -> A^+ B^-.
```

Using zero-based letters, the canonical hub sides are

```text
x(A)=1, x(B)=0.
```

Both physical children of `A` carry the hub on top and both physical children of `B` carry it on bottom. Consequently all four hub residual bits are `1`. The original sign cochain and the hub residual both have Perron phase `q=1`.

A second regression rewrites the same two-state data into two disconnected self-loops and verifies that the support is rejected as non-SCC before a Perron-phase comparison is permitted.

This is a negative control, not a PIP witness.

## 6. Remaining theorem

The hub gauge does not by itself force Perron compatibility or synchronization. The remaining information is the **word of physical hub-side bits across each ordered child factorization**.

The next load-bearing question is:

> Can a strict PIP component support an ordered derived child system whose hub-side words, recurrent hierarchy-offset states, endpoint C/D/E/F dynamics, and Perron signing all remain compatible without meeting an eventually-coincident letter pair?

Any next executable attack should operate on the Mojo integer-indexed derived system and these hub-side occurrence words, not return to an unstructured recognizability offset.
