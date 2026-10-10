# C4-B endpoint-quotient signature reduction

**Status:** proved finite combinatorial reduction; does **not** prove C4, C1,
G1, or PSC.

This note compresses the endpoint-core normal form further before any
Pisot-specific elimination is attempted.

## 1. Synchronization quotients

For an endpoint map `h:A->A`, define

`a ~_h b  <=>  h^n(a)=h^n(b) for some n>=0`.

This is an equivalence relation. Let `q_h:A->Q_h` be the quotient map. The map
`h` induces a permutation `pi_h` of `Q_h`, because

`a ~_h b  <=>  h(a) ~_h h(b)`.

An ordered pair synchronizes exactly when its two letters have the same quotient
class. Therefore persistent nonsynchronization depends only on two distinct
classes of `Q_h`, not on transient letters inside those classes.

For the three-letter counterexample regime, global synchronization has already
been eliminated. Hence `|Q_h|` is 2 or 3. The five endpoint types C--G are
exactly the five quotient-permutation cycle shapes

- `(2,id)` — C,
- `(2,(12))` — F,
- `(3,id)` — D,
- `(3,(12))` — E,
- `(3,(123))` — G.

## 2. State endpoint signature

Let `T=(u,v)` be a noncoincident balanced-pair state. Let `q_+` and `q_-` be
the synchronization quotients of `sigma_+` and `sigma_-`.

Define the **unoriented endpoint signature**

`Sig(T) = (L(T), R(T))`,

where

`L(T) = { q_+(u[0]), q_+(v[0]) }`,

`R(T) = { q_-(u[-1]), q_-(v[-1]) }`.

The braces denote unordered two-element sets.

### Lemma 1 — side-swap invariance

`Sig(u,v)=Sig(v,u)`.

**Proof.** Swapping the two sides only reverses the order in each endpoint pair;
the quotient-class sets are unordered. QED.

Thus `Sig` is well-defined on the normalized BPA state, where `(u,v)` and
`(v,u)` are identified.

### Lemma 2 — nonproductive signatures are genuinely two-element

If `T` belongs to a nonproductive SCC, then both `L(T)` and `R(T)` have two
distinct quotient classes.

**Proof.** If the two left endpoint letters have the same `q_+` class, their
orbits coalesce under `sigma_+`; the zero-return boundary at position 0 is then
a Boundary Synchronization Lemma witness. The right-end statement is the same
argument with `sigma_-` at the terminal zero-return boundary. Either case would
make `T` productive. QED.

## 3. At most nine signatures, with type-specific bounds

For a quotient with `q` classes, the number of unordered distinct class pairs is
`binom(q,2)`. In the counterexample regime `q<=3`, so each side has at most
three possible nonsynchronizing labels.

Therefore

`|{Sig(T)}| <= binom(|Q_+|,2) * binom(|Q_-|,2) <= 3*3 = 9`.

This bound is independent of the size or word lengths of the balanced-pair
automaton.

For a two-class endpoint quotient there is only one unordered nonsynchronizing
pair. In particular types C and F have no residual pair-label choice at that
side; their difference survives only in the quotient permutation acting on
individual classes, not in the unordered outer-pair label itself.

Hence the sharper bound depends only on whether each endpoint type has quotient
size 2 (`C,F`) or 3 (`D,E,G`):

| endpoint-type regime | left labels | right labels | max combined signatures |
|---|---:|---:|---:|
| `{C,F}` x `{C,F}` | 1 | 1 | **1** |
| `{C,F}` x `{D,E,G}` | 1 | 3 | **3** |
| `{D,E,G}` x `{C,F}` | 3 | 1 | **3** |
| `{D,E,G}` x `{D,E,G}` | 3 | 3 | **9** |

Thus many endpoint-type pairs collapse C4-C to a one-state or three-state
projected template before any substitution-specific argument is used.

## 4. Inherited-boundary phase

Under one inflation, the left outer endpoint pair evolves by
`pi_+ x pi_+` and the right outer pair by `pi_- x pi_-`. Passing to unordered
class pairs gives a permutation action on the side labels.

On three classes these side-label periods are at most three:

- quotient identity: period 1;
- quotient transposition: one fixed unordered pair and one 2-cycle of the other
  two labels;
- quotient 3-cycle: one 3-cycle on the three unordered pair labels.

On two classes the unique unordered pair is fixed, even when the quotient
permutation swaps the two classes.

Thus inherited outer-boundary signatures have no unbounded phase variable.

## 5. Projection of a closed SCC

Let `C` be a closed nonproductive recurrent noncoincident SCC. Every
noncoincident child of a state in `C` remains in `C`, and by nonproductivity no
coincidence child exists.

Form the directed **signature graph** `G_sig(C)`:

- vertices are signatures `Sig(T)` attained by states `T in C`;
- draw `Sig(T) -> Sig(U)` whenever `U` is a child block of `T` and both lie in
  `C`.

By Lemma 2 every vertex is one of the finite nonsynchronizing signatures above.
Because `C` is recurrent, there is an infinite path in `C`; its signature
projection is an infinite path in this finite graph. Hence:

### Proposition — short signature recurrence

Every closed nonproductive recurrent SCC contains a projected endpoint-signature
cycle of length at most **9**. More sharply, the cycle length is at most **1**,
**3**, or **9** according to the endpoint-type regimes in the table above.

This is only a cycle of endpoint signatures; it does not assert that the full
balanced-pair state repeats within that number of steps.

## 6. Reduced C4-C target

C4-C therefore need not search arbitrary endpoint histories. A hypothetical
counterexample yields a finite periodic template consisting of:

1. a signature cycle of length at most 1, 3, or 9 according to endpoint types;
2. for each transition, a one-step child block inside the closed SCC;
3. the newborn zero-return cuts that separate the child blocks;
4. the requirement that every adjacent endpoint pair at those cuts belongs to
   distinct synchronization quotient classes.

The next computational task is to enumerate which endpoint quotient-type pairs
and which sink-SCC signatures actually occur in the exact PIP corpus, then use
those observations only as calibration for a general template elimination.
