# C4 prefix-difference return calculus

**Status:** two exact structural lemmas, uniform in the size of the component. These lemmas do not prove C4, C1, G1, or PSC. No Pisot contraction is used yet.

## 1. Why this is the next object

The balanced-pair child decomposition is defined by returns of the aligned prefix-difference walk

```text
D_T(k) = Parikh(u[:k]) - Parikh(v[:k])
```

for a balanced pair `T=(u,v)`.

All recent matrix invariants forget some information about where these returns occur. The strong G/F synthetic obstruction survives those coarser constraints and fails only when the actual zero-return factorization is imposed. The present calculus therefore works directly with prefix cuts.

## 2. Asynchronous source cuts

After substitution, the two source letters covering the same output position need not have the same source index because image lengths may differ.

For source words `u,v` define

```text
E_T(i,j) = Parikh(u[:i]) - Parikh(v[:j]).
```

Let

```text
L_u(i) = |sigma(u[:i])|,
L_v(j) = |sigma(v[:j])|.
```

For an output cut `t`, choose the canonical indices and proper within-image offsets

```text
L_u(i) <= t < L_u(i+1),   r=t-L_u(i),
L_v(j) <= t < L_v(j+1),   s=t-L_v(j),
```

with the terminal boundary represented by `(i,r)=(|u|,0)` and similarly below.

Let `q_sigma(a,r)` be the Parikh vector of the length-`r` prefix of `sigma(a)`, with zero at a terminal boundary.

## 3. Exact inflation law

Let `M=M_sigma`. Then at every aligned output cut,

> **Prefix-Difference Inflation Lemma**
>
> ```text
> D_{sigma(T)}(t)
>   = M E_T(i,j)
>     + q_sigma(u_i,r) - q_sigma(v_j,s).
> ```

### Proof

The top prefix of `sigma(u)` ending at `t` consists of the full images of `u[:i]` followed by the proper prefix `sigma(u_i)[:r]`. Its Parikh vector is

```text
M Parikh(u[:i]) + q_sigma(u_i,r).
```

The bottom prefix has the analogous expression. Subtraction gives the formula. QED.

The implementation checks the reconstructed vector against direct prefix counting at every call.

## 4. Finite ancestry-defect alphabet

Define the local correction

```text
c = q_sigma(u_i,r) - q_sigma(v_j,s).
```

For fixed `sigma`, only finitely many proper image prefixes exist, so the possible values of `c` form a finite set `C_sigma`.

At a zero return,

```text
D_{sigma(T)}(t)=0,
```

hence

```text
M E_T(i,j) = -c.
```

Under the standing assumption `det(M)!=0`, each correction `c` has at most one rational preimage, and a real zero-return cut requires that preimage to be integral.

Therefore:

> **Finite Ancestry-Defect Lemma.** For fixed `sigma`, the asynchronous source-prefix differences occurring below one-step zero returns belong to a finite set depending only on `sigma`, not on `T` or on the size of a hypothetical SCC.

Since

```text
sum(E_T(i,j)) = i-j,
```

the source-index misalignment of every one-step zero return is bounded by a constant `K_sigma` depending only on `sigma`.

For the three-letter standing regime, the executable helper computes this bound exactly using the adjugate of `M` and the finite local-correction alphabet.

### Inherited cuts

If `k` is already a zero return of `T`, then the two substituted prefixes have the same output length. At the inherited cut

```text
t = |sigma(u[:k])| = |sigma(v[:k])|
```

we have

```text
i=j=k, r=s=0, E_T(k,k)=0, c=0.
```

Thus inherited cuts are the zero-offset special case of the same formula.

The converse is deliberately **not** claimed: a newborn cut can have zero source-index offset while retaining a nonzero Parikh source defect or nontrivial local position.

## 5. Uniform bounded-gap returns in a strict component

Let `C` be a finite nonempty set of normalized irreducible balanced-pair states such that

1. every state is noncoincident; and
2. every normalized child of every state lies again in `C`.

Call this **strict child closure**. A closed nonproductive SCC has this property: a coincidence child would make it productive, and a noncoincident child outside the SCC would violate closure.

Set

```text
B_C = max{|u| : (u,v) in C}.
```

> **Uniform Return-Gap Lemma.** For every `T in C` and every `n>=0`, the maximum distance between consecutive zero-return boundaries in `sigma^n(T)` is at most `B_C`.

### Proof

At depth one, the zero-return decomposition of `sigma(T)` cuts it into child states in `C`; every child block has length at most `B_C`.

Inductively substitute each child and refactor it. Strict child closure keeps every depth-`n` descendant block in `C`, so `sigma^n(T)` is tiled by balanced descendant blocks of length at most `B_C`. Every boundary between adjacent descendant blocks is a zero return of the full inflated pair. Hence the full set of zero returns has gaps no larger than `B_C`. QED.

This theorem is independent of `|C|` and independent of the Pisot property.

## 6. Negative control: dense returns are not enough

For

```text
1 -> 2
2 -> 123
3 -> 2
```

the primitive non-Pisot BPA has the strict closed nonproductive component

```text
((12),(21)),
((23),(32)).
```

Its block bound is `B_C=2`, and direct regression through six inflations finds maximum zero-return gap exactly 2 at every depth.

Therefore a proposed argument of the form

```text
bounded-gap zero returns => contradiction
```

is false without additional Pisot/recognizability structure.

This negative control is retained intentionally.

## 7. What the two lemmas buy

Together the lemmas give the exact inputs the audit called for:

- **many returns:** a strict finite component forces zero returns at uniformly bounded output gaps through arbitrarily deep inflations;
- **finite ancestry states:** every one-step return pulls back to one of finitely many asynchronous source-prefix defects and bounded source-index offsets.

The remaining theorem must make one of these finite phenomena incompatible with PIP recurrence.

Two candidate mechanisms remain distinct:

### A. Pisot stable-direction route

Project the asynchronous prefix defects into the stable conjugate space. The homogeneous part contracts under `M`, but the within-image correction is a bounded forcing term. A valid theorem must therefore handle an **affine forced recurrence**, not reuse the withdrawn predecessor-contraction inequality.

Any proposed scalar/norm inequality must be tested against the non-Pisot strict component and the exact PIP BPA corpus before promotion.

### B. Recognizability alignment route

The finite ancestry-defect alphabet is a natural offset-state space. If a recurrent child boundary remains persistently misaligned with source/supertile boundaries through desubstitution, finiteness gives a repeatable offset regime. The target is to show, using recognizability or the proved unique supertile hierarchy, that such a recurrent nonzero regime is impossible or forces a synchronizing boundary.

## 8. Next proof obligations

1. Define the correct multi-level ancestry state for a cut that is zero-return at the current level but may pull back to unequal source indices.
2. Determine whether the affine stable projection admits a bounded complete invariant or a contraction-plus-forcing fixed set.
3. Formulate recognizability in terms of the bounded source-index/local-image offset state.
4. Search for persistent nonzero offset cycles in the exact corpus and in the non-Pisot negative control before claiming an alignment lemma.

`reference/psc_research/prefix_difference.py` implements the exact one-step calculus and finite regressions. `tests/test_prefix_difference.py` checks the identity on named BPA states and the strict-component return bound on the non-Pisot negative control.
