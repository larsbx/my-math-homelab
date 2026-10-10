# C4 newborn birth-event transducer

**Status:** exact finite normal form for newborn zero-return creation in a given finite strict component. It does **not** prove C4, C1, G1, or PSC.

## 1. Why birth events, not persistent misalignment

PR #29 proves that an interior zero return born inside the image of an irreducible balanced state is misaligned with at least one level-1 `sigma` source-image grid. But once that same physical balanced boundary is inflated again, it is inherited: it is the image of a whole balanced prefix and is therefore aligned with source-image boundaries on both sides.

So the correct recurrent object is **not one physical cut that stays misaligned forever**. It is the finite type of the many newborn cuts created at successive levels.

PR #32 makes this precise. For a strict component `C`,

```text
tau_C(T) = ordered normalized children of sigma(T)
```

and every depth-`n` newborn boundary is an internal split of one occurrence of `tau_C(S)` for some state `S` appearing in `tau_C^(n-1)(T)`.

## 2. Canonical one-step newborn birth event

For each normalized parent `T in C` and each internal split

```text
tau_C(T) = R_1 ... R_j | R_(j+1) ... R_m,
```

there is a canonical physical cut in `(sigma(u_T),sigma(v_T))` after the first `j` child blocks.

`reference/psc_research/birth_event.py` records the following data for that split:

- parent `T` and split index `j`;
- adjacent normalized child states;
- raw-to-normalized orientation signs of those two child occurrences;
- asynchronous source-prefix defect `E`;
- local correction digit `c_sigma`;
- top/bottom source indices and within-image offsets;
- the letters immediately to the left and right of the balanced boundary on both sides;
- whether the left endpoint pair synchronizes under `sigma_-`;
- whether the right endpoint pair synchronizes under `sigma_+`.

This canonical record is the **one-step newborn birth-event type**. Because `C` is finite and every `tau_C(T)` is finite, there are only finitely many such types.

## 3. Deep occurrences must retain the orientation cocycle

The normalized word `tau_C^n(T)` does not by itself retain physical top/bottom orientation. A normalized state occurrence may appear in canonical orientation or with its two raw sides swapped.

Let the accumulated occurrence orientation be

```text
o in {+1,-1}.
```

It evolves by the orientation cocycle from PR #13: if a canonical child occurrence has sign `eps`, then the child orientation is

```text
o_child = o_parent * eps.
```

Therefore the one-step catalog is stored canonically, but a **physical deep occurrence** must transform the catalog entry when `o=-1`:

```text
E            -> -E
c_sigma      -> -c_sigma
top/bottom source indices -> swap
top/bottom offsets        -> swap
(a,b) endpoint pair       -> (b,a)
child occurrence signs    -> negate.
```

The physical cut and normalized child labels do not change. Endpoint synchronizability also does not change, since eventual coalescence is symmetric under swapping the two entries.

`oriented_derived_word` carries the accumulated sign through arbitrary derived depth; `orient_birth_event` converts the canonical event into its actual physical data; `newborn_occurrences` returns these oriented physical events.

This correction is essential. In the strict non-Pisot calibration, the first `A` occurrence at depth 2 is reversed. Its physical endpoint pairs are the swapped versions of the canonical `A` event, not the canonical pairs themselves.

## 4. Completeness at every depth

Let

```text
W = tau_C^(n-1)(T) = S_1 ... S_k.
```

Then

```text
tau_C^n(T) = tau_C(S_1) ... tau_C(S_k).
```

By PR #32, the newborn boundaries at depth `n` are exactly the internal boundaries inside these displayed words `tau_C(S_i)`.

Therefore every depth-`n` newborn boundary is an occurrence of exactly one canonical key

```text
(S_i, split_index),
```

together with the accumulated physical orientation of that occurrence. Conversely every internal split of every displayed `tau_C(S_i)` is a depth-`n` newborn boundary.

Hence the one-step catalog plus the orientation cocycle is a **complete physical alphabet of newborn creation events at all depths**.

## 5. Endpoint condition forced by strictness

Suppose `C` is genuinely strict and child-closed: no descendant child is a coincidence and every noncoincident child remains in `C`.

Take any newborn event. If its right adjacent letter pair belongs to `Sync_+`, repeated inflation of that boundary eventually makes the right endpoint letters coincide. The Boundary Synchronization Lemma then produces a single-tile coincidence factor. The same holds on the left using `Sync_-`.

Either outcome contradicts strict child closure. Therefore every newborn event of a hypothetical strict counterexample must satisfy

```text
left endpoint pair  notin Sync_-
right endpoint pair notin Sync_+.
```

Because synchronization is invariant under swapping the pair, it is enough to check this on the canonical catalog; every oriented physical occurrence has the same yes/no synchronization status.

This is only a **necessary** condition. It is the local event form of the current C4 obstruction, not a proof that such a strict component cannot exist.

## 6. Calibration

For the repository's primitive non-Pisot strict component

```text
sigma:
1 -> 2
2 -> 123
3 -> 2

A=(12,21)
B=(23,32)

tau_C:
A -> A B
B -> A B,
```

there are exactly two canonical one-step newborn types:

```text
(A, split 1)
(B, split 1).
```

The canonical `A` event has

```text
A^- | B^+
left endpoint  (1,2)
right endpoint (2,3),
```

while the canonical `B` event has

```text
A^+ | B^-
left endpoint  (2,1)
right endpoint (3,2).
```

All four endpoint pairs are nonsynchronizing under the appropriate endpoint maps.

At derived depth 1 the oriented word from `A^+` is

```text
A^- B^+.
```

Thus the first depth-2 newborn event is a **reversed `A` occurrence**. Its physical data are

```text
left endpoint  (2,1)
right endpoint (3,2)
```

with `E` and `c_sigma` negated and both child signs reversed. The regression suite pins this exact correction.

At depth three, newborn boundary indices remain

```text
1,3,5,7,
```

but their occurrence orientations are part of the event state rather than being discarded by normalization.

## 7. Relation to dual recognizability

PR #31 supplies legal finite `sigma`-contexts around suitably chosen deep cuts. PR #33 supplies recognizability of the period-decimated derived hierarchy in the PIP regime. The present event catalog sits exactly between them:

```text
derived internal split
      |
      v
canonical event key (parent, split)
      + accumulated Z/2 orientation
      |
      v
physical birth-event data
(E, offsets, endpoint pairs, child signs)
      |
      v
local sigma cut context.
```

A recurrent C4 obstruction therefore reduces to recurrent occurrences of finitely many **oriented** birth-event types, each with nonsynchronizing endpoints, embedded in two locally recognizable hierarchies.

## 8. Next target

The remaining quantity should be an address state attached to a birth-event occurrence: as the occurrence is desubstituted, record the finite relative position of its asynchronous top/bottom source cuts with respect to the exact derived zero-return block hierarchy.

The next theorem should seek a dichotomy of the form

```text
recurrent nonsynchronizing oriented birth-event address
    => incompatible recognizable hierarchy offset
       or a synchronizing boundary.
```

Any proof must use more than finite recurrence; the non-Pisot calibration above supplies a periodic nonsynchronizing oriented event system.
