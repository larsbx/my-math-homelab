# P1-B — labelled renewal program for G1b-2

**Status:** executable support program for the open renewal-finiteness gate. The labelled-word, level-scaled address, bounded joint-local, observed-loop quotient, and finite-residue layers below do **not** prove G1b-2 or G1.

## 1. Why the cumulative difference walk is insufficient

For an equal-length word pair `(u,v)`, define

```text
d_k = Parikh(u[:k]) - Parikh(v[:k]).
```

A balanced irreducible pair is a first return of this walk to zero: `d_0=d_n=0` and `d_k!=0` for `0<k<n`.

However the sequence `(d_k)` does not determine the pair. A diagonal letter step `(a,a)` has zero increment for every `a`, so the label is invisible in the cumulative walk.

The canonical regression is

```text
A = (001,100)
B = (021,120).
```

Both are irreducible balanced pairs with exactly the same difference path

```text
0 -> (1,-1,0) -> (1,-1,0) -> 0,
```

but the middle transition is `(0,0)` in `A` and `(2,2)` in `B`.

Therefore any G1b-2 proof that quotients realizable states to the unlabelled difference walk loses information required to reconstruct the state.

## 2. Canonical Mojo labelled-return representation

`kernel/psc/renewal.mojo` stores one labelled return word as:

- one packed transition label `3*top+bottom` in `0..8` per aligned position;
- the cumulative difference path as one flat `Int` array of coordinate triples;
- one exact first-return flag.

The constructor streams the word once. It does not allocate Parikh vectors, prefix slices, or per-vertex heap objects.

`LocalRenewalType` records the radius-one datum

```text
(d_k, incoming_label, outgoing_label)
```

for an interior difference vertex. This is the minimal labelled refinement of the local configurations referred to in the current G1b-2 audit.

## 3. Mathematical boundary of the labelled layer

The representation solves only an **information-loss problem**. It does not imply that the set of labelled return words is finite.

The known obstruction remains: a first-return word can revisit a finite set of nonzero difference vertices and local configurations many times before returning to zero.

Thus the next theorem must constrain which long labelled returns are **realizable under substitution renewal**, not merely which local transitions are combinatorially legal.

## 4. Level-scaled symbolic renewal address

`kernel/psc/renewal_address.mojo` adds exact substitution ancestry for an interior zero-return cut of `sigma^d(u), sigma^d(v)` without materializing those inflated words.

The cut is located inside one source supertile on each side and then descended through one substitution child at each level. Each side retains a finite symbolic digit path

```text
(parent_letter, child_index)^d.
```

Absolute source indices and inflated word length are deliberately omitted from the public relative address. What remains is:

- substitution level `d`;
- relative source-index displacement;
- exact source prefix defect `delta`;
- the two source letters;
- the two ordered digit paths;
- the level-scaled defect `M^d delta`;
- the finite partial-image correction `c`.

For an actual zero-return cut the module verifies the exact integer certificate

```text
M^d delta + c = 0.
```

This identity is the current executable meaning of a **level-scaled address**. It uses no inverse of `M` and no choice of Archimedean/non-Archimedean completion.

For census use, the implementation has two reusable preparation layers:

- `RenewalAddressTables` precomputes image lengths and image Parikh columns once for a substitution/depth;
- `RenewalPairCensusState` validates one labelled first return and caches source-supertiling boundaries and prefix Parikh vectors once.

Per-cut queries then use binary source lookup plus the level-linear digit descent rather than re-expanding words or rebuilding labelled paths.

## 5. Explicit non-unimodular regression

The canonical address tests include

```text
0 -> 1
1 -> 021
2 -> 001
```

with incidence matrix

```text
M = [[0,1,2],
     [1,1,1],
     [0,1,0]],
```

so `det M = 2`. Its characteristic polynomial is

```text
x^3 - x^2 - 2x - 2,
```

and the example is primitive irreducible Pisot. For the first-return pair `(001,100)`, the level-one interior renewal cut at position `4` has

```text
delta = (1,-1,0)
M delta = (-1,0,-1)
c       = ( 1,0, 1),
```

hence the certificate closes exactly. The inherited level-two cut is also pinned.

This regression exists specifically to prevent a later implementation from silently introducing `|det M|=1` through division, a Euclidean lattice model, or an inverse-incidence address.

## 6. Address data does not replace labels

The relative address is an auxiliary coordinate, not a state quotient.

For the two labelled collision words

```text
A = (001,100)
B = (021,120),
```

the non-unimodular regression above gives the same relative level-one address at their corresponding inflated renewal cuts, even though their labelled first-return words are different.

Therefore the canonical object for continuing G1b-2 work must retain **both**:

```text
labelled first-return data + relative level-scaled address.
```

Any proposal that discards the labelled word because the address matches is rejected by the tests.

## 7. Non-unimodular firewall

No address introduced by this program may assume:

- `|det M|=1`;
- purely Euclidean internal space;
- discreteness of `pi_s(Z^A)` by itself;
- finite return types merely because the integer certificate is bounded.

If the correct arithmetic completion has a profinite/non-Archimedean factor, it must remain first-class. The symbolic digit paths are intentionally representation-neutral so they can later feed the appropriate product completion rather than prejudging it.

## 8. What remains open

The exact identity

```text
M^d delta + c = 0
```

is necessary structure, not the renewal-finiteness theorem. As `d` varies, digit strings may still grow without bound.

The next mathematical target is now sharper:

```text
bounded discrepancy
+ realizable labelled first returns
+ exact substitution-digit ancestry
=> a uniform-discreteness / finite-local-return statement across all levels.
```

The executable program should census **joint labelled-address local types**, retain counterexamples to proposed identifications, and identify which additional arithmetic coordinate is required in the non-unimodular case. A profinite valuation/residue coordinate is admissible; replacing it by an unjustified Euclidean lattice is not.

## 9. Bounded joint-local falsification layer

`kernel/psc/joint_local_type.mojo` tests candidate finite local projections rather than assuming one is complete. For fixed source radius `r` and digit-window size `w`, it retains:

- relative source-index displacement;
- exact source prefix defect;
- the two selected source letters;
- radius-`r` source-letter context on both sides, with one exterior sentinel;
- the first `w` and last `w` symbolic digit pairs on both sides.

It intentionally omits absolute indices, total inflated length, substitution depth, `M^d delta`, the correction vector, and the middle of a long digit path. For fixed `r,w` the stored context/window size is depth-independent, making this a legitimate candidate finite local type once the already-bounded defect alphabet is supplied.

The canonical tests record two opposite facts.

### 9.1 Full level-one address can still be too coarse

For

```text
A = (001,100), cut 4
B = (021,120), cut 6,
```

under the determinant-2 Pisot substitution above, the **entire** level-one relative address agrees. With source radius `0`, the selected source letters also agree, so the joint projection collides even with `w=1`, which at depth one retains the full digit path.

Radius `1` separates this particular collision because it sees the preceding source letters

```text
A: 0/0
B: 2/2.
```

This proves only that immediate source context repairs this example. It does not prove radius one sufficient in general.

### 9.2 One-level head/tail windows can miss middle ancestry

For the strict pair

```text
(01,10)
```

at substitution depth `4`, the certified zero returns at cuts `35` and `40` have different full symbolic addresses. However:

- the source pair and selected source positions are the same;
- radius `2` already exposes the complete two-letter source words plus sentinels;
- the first one and last one digit pairs on both sides agree.

Thus the `(r=2,w=1)` joint projection still collides even though the full addresses differ. A two-level head/tail window separates this particular pair of cuts.

Again, this is a falsification/calibration result, not a universal bound. The required window could grow, or a different arithmetic coordinate could be necessary.

## 10. Observed symbolic quotient and 2-primary residue probe

`kernel/psc/loop_quotient_census.mojo` keeps the full certified address only for finite collision diagnostics. It does not add the unbounded full address to the proposed finite state.

Inside one exact bounded-projection collision class, two observations are joined only when their full addresses exhibit an exact observed one-level synchronous extension. The connected components generated by those edges form a **corpus-relative diagnostic quotient**. This avoids the stronger and unjustified operation of deleting arbitrary occurrences from every address.

For the determinant-2 substitution and seed `(01,10)`, the three staircase collisions from depth caps `D=3..7` at window `D-2` all lie in the already identified synchronous `(1,2)` recurrence components. Thus those three collisions are regular on this corpus; this remains an empirical classification, not a finiteness theorem.

The more severe calibration fixes `(r,w)=(2,1)` and takes all certified cuts through depth `7`. The exact Mojo census gives

```text
raw bounded-projection collision pairs              12466
pairs identified by observed synchronous components   946
residual collision pairs                            11520
```

Allowing the inserted top and bottom digit pairs to differ, while still requiring an exact insertion at one common ancestry level, produces `392` direct observed edges but **the same** `946` connected collision pairs and the same `11520` residual pairs. Therefore the residual family is not explained by merely adding more one-level synchronous digit labels.

One retained residual witness is

```text
left:  depth 5, cut 53
       top digits    [1,1, 2,0, 0,0, 1,1, 2,2]
       bottom digits [1,2, 1,1, 2,0, 0,0, 1,2]

right: depth 2, cut 6
       top digits    [1,1, 2,2]
       bottom digits [1,2, 1,2].
```

Both have source-index displacement `1` and the same bounded `(r=2,w=1)` projection.

Because `det M=2`, the next finite probe refines only the **residual** symbolic collisions by the coordinatewise residue of the exact scaled defect `M^d delta` modulo powers of two. The exact bounded-corpus regression is:

| modulus | residual pairs still agreeing | pairs separated by the residue |
|---:|---:|---:|
| 2 | 11,520 | 0 |
| 4 | 10,944 | 576 |
| 8 | 6,694 | 4,826 |
| 16 | 4,652 | 6,868 |
| 32 | 4,652 | 6,868 |

The plateau from modulus `16` to `32` is only a fact about this finite corpus. It is not evidence that modulus `16` is globally sufficient. More importantly, a same-depth survivor is already present: depth `7`, cuts `583` and `576`, have exactly the same scaled defect

```text
(-84,-100,-44).
```

This exposes a structural limitation of the scaled-defect coordinate. For a fixed substitution level `d`, equality of the source defect `delta` already forces equality of `M^d delta`; therefore **no function of the scaled defect alone** can distinguish same-level bounded-projection collisions with the same `delta`. Higher powers of two cannot repair that middle-ancestry loss.

The next arithmetic candidate should therefore retain sidewise ancestry information rather than only the difference certificate. A natural non-unimodular target is to evaluate the individual top and bottom prefix translations in finite cokernel quotients such as

```text
Z^3 / M^k Z^3,
```

whose finite size is controlled by `|det M|^k`. This is only a research direction at present. It must be implemented and falsified on retained witnesses before it can enter any proof of G1b-2.

## 11. Acceptance criteria for the current support layers

- exact labels survive collisions of the cumulative difference path;
- strict first-return input validation fails closed, including the empty word;
- local labelled types are reproducible in canonical Mojo tests;
- inflated zero-return addresses are computed without materializing inflated words;
- the integer certificate `M^d delta + c = 0` is verified exactly;
- a determinant-2 Pisot substitution is a canonical regression;
- relative-address collisions do not erase labelled distinctions;
- bounded joint-local projections retain explicit collision counterexamples;
- observed symbolic recurrence is quotiented only through exact certified edges and connected components;
- residual collisions remain explicit after the symbolic quotient;
- finite 2-primary scaled-defect residues are treated as diagnostics, not as a claimed state completion;
- positive refinements are recorded only as corpus-level separations, never as completeness claims;
- no current module makes a finiteness claim;
- further work must prove a uniform finite-local-return/discreteness statement or identify and justify the missing non-Archimedean coordinate rather than infer finiteness from a bounded empirical window.
