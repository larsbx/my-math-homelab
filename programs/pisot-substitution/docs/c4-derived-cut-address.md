# C4 derived substitution and canonical zero-return addresses

**Status:** exact word-level normal form for a given finite strict child-closed component. It does **not** prove C4, C1, G1, or PSC.

## 1. The strict component is itself a substitution system

Let `C` be a finite set of normalized irreducible balanced states such that every child of every state is noncoincident and remains in `C`.

For `T in C`, inflate the normalized representative and factor at all zero returns. Record the resulting **ordered normalized child states**:

```text
tau_C(T) = T_1 T_2 ... T_m.
```

This defines a non-erasing substitution on the finite alphabet `C`.

The orientation sign of each raw child is deliberately suppressed here. Side swap does not change the normalized state label, child order, or physical block length. The `Z/2` cocycle from `docs/c4-orientation-monodromy.md` is the correct extra layer when raw top/bottom word identities are needed.

## 2. Exact recursive factorization theorem

> **Derived factorization theorem.** For every `T in C` and every `n>=0`, the ordered normalized irreducible balanced factors of
>
> ```text
> (sigma^n(u_T), sigma^n(v_T))
> ```
>
> are exactly the letters of `tau_C^n(T)`.

### Proof

At `n=0`, `T` is irreducible, so the factor word is the one-letter word `T`.

Assume the factor word at level `n` is

```text
R_1 ... R_k = tau_C^n(T).
```

Inflating the raw pair inflates each balanced block separately. Every old zero-return boundary remains a zero-return boundary after substitution because equal Parikh prefixes remain equal under `M_sigma`. Hence the factorization of the next iterate is obtained by concatenating, in order, the irreducible factorizations of each `sigma(R_i)`.

If an occurrence of `R_i` is raw-swapped relative to its normalized representative, inflating swaps the two sides of every raw child but does not change the normalized child labels or their order. Thus its normalized child word is still `tau_C(R_i)`.

Concatenating gives

```text
tau_C(R_1) ... tau_C(R_k) = tau_C^(n+1)(T).
```

This proves the induction. QED.

The executable cross-check is `verify_derived_factorization` in `reference/psc_research/derived_factorization.py`.

## 3. Physical cuts become symbolic addresses

Each derived letter `R=(x,y)` has a physical block length `|x|=|y|`. Therefore a derived word

```text
R_1 ... R_k
```

has canonical physical boundary positions

```text
0,
|R_1|,
|R_1|+|R_2|,
...,
sum_i |R_i|.
```

By the theorem above these are **exactly** the zero-return boundaries in `sigma^n(T)`.

Thus every physical zero return has a canonical block index in `tau_C^n(T)`, with well-defined neighboring derived states and a fixed-radius derived-state context. This address retains information that the Parikh-defect ancestry alone discards.

## 4. Inherited/newborn lineage is ordinary substitution lineage in tau_C

Let

```text
W = tau_C^(n-1)(T) = R_1 ... R_k.
```

Then

```text
tau_C^n(T) = tau_C(R_1) ... tau_C(R_k).
```

The boundaries between the displayed `tau_C(R_i)` blocks are precisely the zero returns inherited from level `n-1`. Every other interior derived-letter boundary lies inside one of the words `tau_C(R_i)` and is newborn at level `n`.

So the existing inherited/newborn zero-return distinction has an exact symbolic reformulation:

- **inherited:** a level-1 `tau_C`-supertile boundary in the derived word;
- **newborn:** an internal boundary of a level-1 `tau_C`-supertile.

No recognizability of `tau_C` is required for this finite construction; it follows from the known recursive factorization itself.

## 5. Calibration

For the primitive non-Pisot strict component

```text
A=(12,21)
B=(23,32)
```

under

```text
1 -> 2
2 -> 123
3 -> 2,
```

the normalized derived substitution is

```text
A -> A B
B -> A B.
```

Hence

```text
tau_C^3(A)=A B A B A B A B.
```

Every state has physical length 2, so the physical zero returns are

```text
0,2,4,6,8,10,12,14,16.
```

At derived depth 3, inherited block indices are

```text
0,2,4,6,8,
```

and newborn indices are

```text
1,3,5,7.
```

The physical cut at `10` therefore has block index `5`, with radius-2 derived context

```text
B A | B A.
```

The regression suite verifies both the direct physical factorization and this symbolic address.

## 6. Why this matters for recognizability

PR #31 gives a finite local cut germ in the **original substitution** coordinates. The present theorem gives the same cut a finite symbolic address in the **derived strict-component substitution**.

A useful next recognizability state can therefore combine

```text
(original ancestry defect,
 original within-image offsets,
 legal radius-R sigma-contexts,
 derived left/right state context,
 derived inherited/newborn flag,
 orientation sign/phase if needed).
```

Every coordinate is finite once `C`, `sigma`, and `R` are fixed.

This is stronger than merely knowing that some ancestry defect repeats. A repeated state now says that the same local sigma-cut geometry recurs at the same kind of symbolic boundary in the recursively generated balanced-pair factor word.

## 7. Remaining gap

The finite derived address still does not by itself imply a contradiction. The strict non-Pisot calibration above has a perfectly periodic derived substitution and never reaches coincidence.

The load-bearing question is now:

> In the PIP regime, can a recurrent **newborn**, endpoint-nonsynchronizing derived boundary carry a recurrent legal sigma-cut germ indefinitely without becoming an inherited sigma-supertile boundary or forcing boundary synchronization?

This is the precise place to bring in Mossé recognizability, the endpoint synchronization quotient, and the orientation cover. A proof must use more than finiteness or derived periodicity alone.
