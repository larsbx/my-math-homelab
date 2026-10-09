# C4 degree-2 synthetic factorization-realizability obstruction

**Status:** exact falsification artifact for algebra/endpoint-only proof routes. This is **not** a substitution counterexample and does not prove C4, C1, G1, or PSC.

## 1. Purpose

The current degree-2 program already constrains a hypothetical strict closed nonproductive SCC by:

- `P N = M P` with rank-three Parikh data;
- `Q S = (Lambda^2 M) Q` with rank-three `K2` data;
- `N=A+B`, `S=A-B`, `A,B>=0`;
- parity `N == S (mod 2)`;
- actual PIP substitution incidence;
- both endpoint maps nonsynchronizing;
- finite endpoint-quotient phase compatibility;
- actual irreducible balanced-word representatives for the state columns.

This note gives a three-state object satisfying **all** of those constraints simultaneously. It fails only at one final requirement:

> the proposed signed child word is not the actual irreducible zero-return factorization of `(sigma(u_T),sigma(v_T))`.

Thus the remaining theorem must genuinely use balanced-prefix factorization, not another invariant of the incidence matrices alone.

## 2. Actual PIP substitution

Use

```text
sigma(1)=2
sigma(2)=3
sigma(3)=132
```

with incidence

```text
M=N = [0 0 1]
      [1 0 1]
      [0 1 1].
```

Its characteristic polynomial is

`x^3-x^2-x-1`,

so this is an irreducible unimodular Pisot substitution.

Its actual endpoint maps, in zero-based notation, are

```text
sigma_+ = (1,2,0)   # type G
sigma_- = (1,2,1)   # type F, canonical representative (1,0,0)
```

Both are nonsynchronizing. Unlike the earlier weaker synthetic template, **no fictional endpoint map is used**.

## 3. Signed abstract derived substitution

Take

```text
S = [0  0 -1]
    [1  0  1]
    [0 -1 -1].
```

Then

```text
A=(N+S)/2 = [0 0 0]
              [1 0 1]
              [0 0 0],

B=(N-S)/2 = [0 0 1]
              [0 0 0]
              [0 1 1].
```

The ordered signed abstract child substitution is

```text
T0 -> T1^+
T1 -> T2^-
T2 -> T0^- T1^+ T2^-.
```

The signed occurrence counts recover `A,B` exactly.

## 4. Actual irreducible balanced states

Use the normalized one-based states

```text
T0 = (132, 231)
T1 = (21233, 31232)
T2 = (122313332, 312332213).
```

Each has no proper balanced-prefix cut.

Their common Parikh columns are

```text
P = [1 1 2]
    [1 2 3]
    [1 2 4],
```

and their `K2` columns in basis `(12,13,23)` are

```text
Q = [ 1 -1 1]
    [ 1  1 3]
    [-1  3 3].
```

Both matrices are invertible over `Q`. Exact checks give

`P N = M P`

and

`Q S = (Lambda^2 M) Q`.

So every algebraic column is realized by an actual irreducible balanced pair.

## 5. Actual endpoint phases also fit

For the three states, the first-letter pairs and last-letter pairs are all nonsynchronizing under the **actual** endpoint maps `sigma_+` and `sigma_-`.

Moreover the proposed first-child and last-child selectors agree with the corresponding endpoint quotient dynamics:

- type G rotates the three first-boundary pair phases according to the proposed first-child cycle;
- type F preserves its unique unordered nonsynchronizing pair phase according to the proposed last-child selector.

Thus incidence, state words, orientation counts, and endpoint quotient phases are simultaneously compatible with the same real substitution.

## 6. The sole failure: zero-return factorization

Now compute the actual irreducible factorization of each inflated pair.

The proposed abstract child counts are `1,1,3`. The actual zero-return factorization gives child counts

```text
T0: 1 child
T1: 2 children
T2: 5 children.
```

None of the three actual signed child words equals the proposed signed child word.

Most decisively, the actual inflation of `T2` contains the one-letter coincidence

```text
(3,3).
```

So the real substitution is productive exactly where the synthetic signed matrix model tries to remain closed.

This is the precise realization failure.

## 7. Interpretation

The artifact simultaneously passes:

1. PIP incidence;
2. Parikh quotient;
3. signed exterior-square quotient;
4. nonnegative positive/negative occurrence counts;
5. actual irreducible balanced-state realization of every column;
6. actual nonsynchronizing endpoint types G/F;
7. actual endpoint quotient phase compatibility.

It fails only:

8. **actual zero-return child factorization.**

Therefore the load-bearing degree-2 theorem must couple the internal ordering of substitution images to the prefix-difference walk that determines zero-return cuts.

A useful formulation is:

> **Factorization Compatibility Lemma.** A finite signed child substitution satisfying the Parikh, `K2`, orientation, and endpoint-quotient constraints cannot be a strict PIP counterexample unless its prescribed child word equals the actual decomposition of every inflated balanced pair at all zero-return cuts.

The statement is tautological as written; the research task is to derive a finite/checkable obstruction from the prefix-difference evolution that forces a mismatch or coincidence for every candidate strict template.

## 8. Next proof target

For a state `T=(u,v)`, define the prefix-difference walk

`D_T(k)=Parikh(u[:k])-Parikh(v[:k])`.

Irreducibility means `D_T(k)!=0` for every interior `k`. After substitution, each source letter expands into a short path determined by the ordered image `sigma(a)`. Actual child boundaries are exactly the return times of the concatenated expanded difference walk.

The next theorem should therefore express prescribed child-factorization compatibility as a finite transition constraint on:

- the current nonzero prefix-difference vector;
- the ordered image pair `(sigma(a),sigma(b))` at the next aligned source position;
- endpoint quotient phase;
- the required next child/state label.

The synthetic artifact is a golden negative case: any proposed finite transition system must reject it specifically at the factorization layer, not earlier.

## 9. Executable scope

`reference/psc_research/synthetic_degree2.py` contains the exact substitution, matrices, states, signed child word, endpoint checks, and actual factorization comparison.

`tests/test_synthetic_degree2.py` verifies the full claim and pins the actual factorization counts `(1,2,5)` plus the direct coincidence child of `T2`.
