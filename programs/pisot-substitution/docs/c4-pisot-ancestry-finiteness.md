# C4 Pisot finiteness of multi-level cut ancestry

**Status:** uniform structural theorem for a given finite strict component. This is the first prefix-difference result in the current C4 route that uses the Pisot spectral hypothesis on the actual cut-ancestry dynamics. It does **not** prove C4, C1, G1, or PSC.

## 1. From one-step cuts to an affine ancestry recurrence

Let `T=(u,v)` and consider two prefix cuts in `sigma^n(u)` and `sigma^n(v)`. The cuts may be aligned at the top level and become asynchronous after desubstitution.

At each level, the one-step prefix-difference inflation lemma gives

```text
x_{k+1} = M x_k + c_{k+1},
```

where

- `x_k` is the Parikh difference of the two source prefixes after desubstituting down to level `k`;
- `M=M_sigma`;
- `c_{k+1}` is the difference of two proper prefixes of substitution images.

For fixed `sigma`, the digit/correction set

```text
C_sigma={c}
```

is finite.

If the original top cut is a balanced zero return, then

```text
x_n=0.
```

If the base state belongs to a fixed finite component `C`, then `x_0` belongs to the finite set of differences of prefixes of the finitely many state words in `C`.

Thus every deep zero-return ancestry is an integral affine orbit with a finite initial alphabet, finite forcing alphabet, and terminal state zero.

`reference/psc_research/prefix_ancestry.py` constructs this recurrence exactly, allowing the two source cuts to be asynchronous at every intermediate level.

## 2. Pisot ancestry finiteness theorem

Let `M` be the incidence matrix of a primitive irreducible Pisot substitution. Let `F subset Z^3` and `D subset Z^3` be finite.

Consider all finite sequences

```text
x_0,...,x_n in Z^3
```

of arbitrary length satisfying

```text
x_0 in F,
x_n=0,
x_{k+1}=M x_k+d_{k+1},   d_{k+1} in D.
```

> **Pisot Ancestry Finiteness Theorem.** There is a finite set `A=A(M,F,D) subset Z^3`, independent of `n`, containing every intermediate `x_k` of every such sequence.

### Proof

Because `M` is primitive, its Perron eigenvalue `beta>1` is simple. Because the characteristic polynomial is irreducible Pisot, every other eigenvalue has modulus strictly below one.

Over the real vector space, split

```text
R^3 = E_u direct_sum E_s,
```

where `E_u` is the one-dimensional Perron eigenspace and `E_s` is the real stable invariant subspace containing the two non-Perron conjugate directions.

Let `pi_u,pi_s` be the corresponding linear projections.

### Stable coordinates: bound forward

The spectral radius of `M|E_s` is less than one. Hence there are constants `K_s<infinity` and `0<q<1` with

```text
||M^m pi_s z|| <= K_s q^m ||pi_s z||
```

for all `m>=0`.

Iterating the recurrence forward gives

```text
pi_s x_k
 = M^k pi_s x_0
   + sum_{j=1}^k M^{k-j} pi_s d_j.
```

Since `F` and `D` are finite, both their stable projections are bounded. The geometric series therefore gives one constant `B_s`, independent of `k,n`, such that

```text
||pi_s x_k|| <= B_s.
```

### Perron coordinate: bound backward

On `E_u`, `M` acts as multiplication by `beta`. Since `x_n=0`, solve the recurrence backward:

```text
pi_u x_k
 = - sum_{j=k+1}^n M^{k-j} pi_u d_j.
```

On the Perron line, `M^{k-j}` has modulus `beta^{-(j-k)}`. Again `D` is finite, so

```text
||pi_u x_k||
 <= B_u sum_{m>=1} beta^{-m}
 < infinity
```

uniformly in `k,n`.

### Return to the integer lattice

The stable and Perron projections are both uniformly bounded, so all `x_k` lie in one bounded subset of `R^3`. But every `x_k` lies in `Z^3`, and the integer lattice is discrete. A bounded subset of `R^3` meets `Z^3` in only finitely many points.

Call that finite intersection `A`. QED.

## 3. Application to strict BPA components

Let `C` be a finite strict child-closed component. The previous return-gap theorem guarantees arbitrarily deep zero returns in iterates of its states, and the base-prefix differences form a finite set `F_C`.

The local image-prefix correction set `C_sigma` is finite independently of `C`.

Therefore every desubstitution ancestry of every zero-return cut in every `sigma^n(T)`, `T in C`, passes through one finite integral defect set

```text
A(sigma,C).
```

This is stronger than the one-step source-offset bound: the **entire depth of the ancestry** is finite-state at the Parikh-defect level.

## 4. Finite-pigeon consequence

For arbitrarily deep zero returns, ancestry paths have arbitrarily many levels but vertices in the fixed finite set `A(sigma,C)`. Hence sufficiently deep paths repeat an ancestry defect and contain a directed cycle in the affine digit graph

```text
x --c--> Mx+c,
```

with `c in C_sigma`.

This is the first rigorous finite-pigeon mechanism in the current C4 route that is derived from the actual prefix-difference factorization and Pisot contraction rather than from a guessed predecessor-length inequality.

It is still only a reduction. A cycle in this ancestry graph is not automatically contradictory.

## 5. Negative control inside the PIP regime

The overstrong statement

```text
Pisot ancestry finiteness => every ancestry cycle is zero/aligned
```

is false.

For Tribonacci

```text
1 -> 12
2 -> 13
3 -> 1
```

start from the legal seed

```text
T=(12,21).
```

At depth 6, output position 51 is an actual zero-return cut. Its exact ancestry defect sequence is

```text
( 1,-1, 0)
( 0, 1,-1)
(-1, 0, 1)
( 1,-1, 0)
( 0, 1,-1)
( 0, 0, 1)
( 0, 0, 0).
```

Thus a genuine PIP substitution already contains a nonzero repeated ancestry loop. The first three correction digits are

```text
(0,0,0), (-1,0,0), (1,0,0).
```

`tests/test_prefix_ancestry.py` pins this example exactly.

So the next theorem cannot be "Pisot forbids nonzero ancestry cycles." The missing information must use the **strict nonproductive / nonsynchronizing boundary regime**, or recognizability of the symbolic cut contexts, or both.

## 6. Relation to Pisot numeration

The recurrence

```text
x_{k+1}=M x_k+c_{k+1}
```

is a matrix-radix analogue of finite-digit expansions in a Pisot base. The proof above is the familiar two-sided boundedness mechanism: contracting conjugate directions are controlled forward, while the expanding Perron direction is controlled backward from a fixed terminal value.

This note uses that genealogy only as intuition. The theorem is proved directly in finite-dimensional linear algebra and lattice discreteness; no external numeration theorem is imported.

## 7. What recognizability must now act on

The one-step calculus also proves that an interior zero return from an irreducible parent cannot be a level-1 source-image boundary on both sides: if both within-image offsets were zero, invertibility of `M` would pull the cut back to an old balanced cut, contradicting irreducibility.

Thus every C4-relevant newborn boundary has a nontrivial **relative cut-offset state** at birth.

The next state space should therefore augment the finite ancestry defect `x` by finite local data:

- top and bottom source letters adjacent to the cut;
- proper within-image offsets on both sides;
- endpoint synchronization-quotient labels;
- enough bounded symbolic context to invoke a recognizability radius.

The Pisot theorem above supplies finiteness of the only apparently unbounded coordinate, namely the ancestry Parikh defect.

## 8. Next proof target

A hypothetical strict PIP SCC now implies:

1. zero returns at uniformly bounded output gaps through all depths;
2. arbitrarily deep newborn/misaligned cuts, since bounded child blocks cannot cover exponentially growing iterates with permanently constant block count;
3. a finite multi-level ancestry-defect alphabet by the Pisot theorem;
4. therefore recurrent finite ancestry/offset patterns.

The load-bearing question is whether a recurrent **nonsynchronizing, misaligned** ancestry pattern is compatible with substitution recognizability.

The next branch should formalize that relative cut state and attempt the implication

```text
recurrent bounded ancestry offset + strict nonsynchronization
    => eventual supertile alignment or synchronizing boundary.
```

That implication is open. Any counterexample found to a proposed version must be preserved before the statement is strengthened.
