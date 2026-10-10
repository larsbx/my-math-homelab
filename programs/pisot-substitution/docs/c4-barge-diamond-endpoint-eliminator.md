# C4 Barge-Diamond endpoint eliminator

**Status:** proved uniform reduction for alphabet-3 strict PIP components. It eliminates endpoint type G on both sides. Combined with the earlier global synchronization theorem eliminating A/B, a strict PIP counterexample can use only endpoint types C/D/E/F. It does **not** prove C4, C1, G1, or PSC.

## 1. Literature input

Barge and Diamond, *Coincidence for substitutions of Pisot type*, Bull. Soc. Math. France **130** (2002), 619–626, DOI 10.24033/bsmf.2433, Theorem 1, prove:

> For a Pisot substitution on an alphabet with at least two letters, there are distinct letters `a,b` whose unit segments `I_a,I_b` are eventually coincident under inflation/substitution.

Their notion is geometric strong coincidence: `I_a` and `I_b` are eventually coincident when some equal iterate of the two unit segments contains a common translated letter-segment. The proof uses Pisot stable contraction, a bounded tube around the unstable line, finiteness of segment configurations up to translation, and a repeated-configuration contradiction with the fact that the unstable line contains no nonzero lattice point.

Only the existence conclusion of their Theorem 1 is used below.

## 2. Eventual coincidence at a balanced boundary forces productivity

Let `T=(u,v)` be balanced and let `k` be a zero-return boundary:

```text
Parikh(u[:k]) = Parikh(v[:k]).
```

Suppose `k<|u|` and write

```text
a=u[k],  b=v[k].
```

The two letter-segments `I_a,I_b` start at the same lattice vertex of the two strands, because the prefixes before the boundary have equal abelianization.

Assume `I_a,I_b` are eventually coincident. Then for some `n`, `F_sigma^n(I_a)` and `F_sigma^n(I_b)` contain the same segment. Inflating the equal-Parikh prefixes translates both of those iterated letter-strands by the same lattice vector. Hence the same common segment occurs in the two sides of `sigma^n(T)`.

Therefore `sigma^n(T)` has a coincidence block, and `T` is productive.

So in a **strict nonproductive** component, every distinct right-adjacent pair at every zero-return boundary must be a pair of letters that is *not* eventually coincident.

This statement is stronger than endpoint-map nonsynchronization: Barge-Diamond eventual coincidence may occur at an interior balanced prefix, not only through repeated first-letter maps.

## 3. Deterministic first-child orbit

Let

```text
h = sigma_+
h(a) = first letter of sigma(a).
```

Take any state `T` in a strict child-closed component and let its first letters be the distinct pair `{a,b}`. They must be distinct, since equal first letters would already give a coincidence child.

The raw first child of `sigma(T)` starts with

```text
{h(a), h(b)}.
```

Normalization may exchange the two sides, but it does not change the unordered pair. Since the component is child-closed and nonproductive, this first child is again strict. Iterating the deterministic first-child selector therefore gives the unordered pair orbit

```text
{a,b}, {h(a),h(b)}, {h^2(a),h^2(b)}, ...
```

and **every distinct pair appearing on this orbit must be non-eventually-coincident** in the Barge-Diamond sense.

## 4. Type G is impossible

For alphabet three, endpoint type G is a 3-cycle on letters. Its induced action on the three unordered distinct pairs

```text
{1,2}, {1,3}, {2,3}
```

is also a 3-cycle. Thus the orbit of any distinct pair visits all three unordered letter pairs.

If `sigma_+` had type G in a strict nonproductive component, Section 3 would force **all three** letter pairs to be non-eventually-coincident.

Barge-Diamond Theorem 1 says at least one distinct letter pair *is* eventually coincident for a Pisot substitution. Contradiction.

Hence:

> **Prefix-G eliminator.** An alphabet-3 strict PIP component cannot have prefix endpoint map of type G.

This argument does not use finiteness of the strict component; child closure and nonproductivity suffice once the substitution is Pisot.

## 5. Suffix type G is also impossible

Define the reversed substitution

```text
sigma^R(a) = reverse(sigma(a)).
```

It has the same incidence matrix as `sigma`, hence the same primitive/irreducible/Pisot spectral data. Word reversal sends a balanced pair `(u,v)` to `(reverse(u),reverse(v))` and conjugates inflation by `sigma` to inflation by `sigma^R`. Therefore strict child closure/nonproductivity is preserved under reversal.

The prefix endpoint map of `sigma^R` is exactly the suffix endpoint map `sigma_-` of `sigma`.

Applying the prefix-G eliminator to `sigma^R` gives:

> **Suffix-G eliminator.** An alphabet-3 strict PIP component cannot have suffix endpoint map of type G.

## 6. Combined endpoint normal form

The earlier global endpoint theorem already eliminates types A and B: if either endpoint map is globally synchronizing, every balanced pair is productive, without requiring Pisot or G1.

The Barge-Diamond argument now eliminates G in the PIP strict regime.

Therefore any hypothetical alphabet-3 strict PIP component must satisfy

```text
sigma_+ in {C,D,E,F},
sigma_- in {C,D,E,F}.
```

The nominal endpoint-type counterexample space drops from the previous `5 x 5` C–G grid to a `4 x 4` C–F grid.

This is a necessary condition only. Types C–F are not asserted realizable by strict PIP components.

## 7. Hub-letter corollary

Choose one Barge-Diamond eventually-coincident pair `{a,b}` and let `c` be the third letter.

By Section 2, a strict zero-return boundary can never have adjacent pair `{a,b}`. Since an alphabet of three letters has only three unordered distinct pairs, every remaining strict boundary pair is one of

```text
{a,c}, {b,c}.
```

Hence:

> **Hub-letter normal form.** Once one Barge-Diamond-good pair is fixed, there is a single complementary letter `c` that occurs on at least one side of **every** distinct right-adjacent zero-return boundary in a strict nonproductive regime.

Thus the right-boundary pair alphabet collapses to a two-edge star centered at `c`. In an oriented state one may record a binary **hub-side bit** indicating whether the top or bottom side carries `c`; normalization/orientation then acts on this bit by an explicit `F_2` flip.

This is a structural consequence only. It does not yet identify the hub-side cocycle with the orientation signing from `kernel/finite_graph/signing.mojo` (vendored); that requires a separate child-occurrence compatibility proof.

The same statement applies to left-adjacent boundaries after reversing the substitution.

## 8. Canonical Mojo support

`kernel/psc/bd_endpoint.mojo` contains only the finite part of the argument:

- exact unordered-pair encoding;
- endpoint-pair orbit masks;
- coalescence detection;
- verification that every type-G map acts transitively on all three unordered distinct pairs;
- complementary hub-letter and two-edge-star checks;
- the combined A/B/G type filter.

`kernel/tests/test_bd_endpoint.mojo` exhausts all 27 self-maps of the three-letter alphabet. It pins that there are two type-G maps and both have full pair-orbit mask `0b111` from every distinct pair, and it checks the two-edge hub normal form for each possible choice of good pair.

The Barge-Diamond existence theorem itself is a cited mathematical input, not something the finite Mojo test claims to prove.

## 9. Consequence for the active C4 route

The hierarchy-offset/recognizability state from PR #37 should no longer spend effort on type-G endpoint regimes. A recurrent strict offset cycle, if one exists, must live entirely in the C/D/E/F endpoint normal form and, after fixing a Barge-Diamond-good pair, in a two-edge hub-star boundary alphabet.

The next useful question is now sharper: can the remaining C–F endpoint dynamics support a recurrent legal hierarchy-offset cycle while preserving the hub-star constraint and avoiding the **global eventual-coincidence relation**, not merely the weaker endpoint-synchronization relation?

A promising finite refinement is therefore the hub-side bit along actual child occurrences. The next proof obligation is to relate that bit to the existing `Z/2` child orientation/signing cocycle without assuming they coincide.
