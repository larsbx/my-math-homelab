# C4 first-child hub phase

**Status:** exact finite normal form for the deterministic first-child selector after the Barge–Diamond hub reduction. It does **not** prove C4, C1, G1, or PSC.

## 1. Setup

Fix a Barge–Diamond eventually-coincident pair `G={a,b}` and let `c` be the complementary hub letter. In a strict nonproductive alphabet-3 regime, every right-boundary first pair must avoid `G` and therefore belongs to the two-edge star

```text
{a,c}, {b,c}.
```

Let `h=sigma_+` be the prefix endpoint map. For a strict state with canonical ordered first pair `(u0,v0)`, the raw first child begins with

```text
(h(u0), h(v0)).
```

A candidate first pair is **viable** for `(h,G)` only if its entire forward pair orbit remains distinct and never hits the good edge `G`. Hitting the diagonal gives endpoint synchronization; hitting `G` gives Barge–Diamond eventual coincidence and hence productivity.

Because there are only three unordered distinct letter pairs, this viability condition is finite.

## 2. First-child hub residual

Canonical normalization orders the two distinct first letters, so the canonical side carrying `c` is determined by the first pair alone.

For a viable parent pair `p`, define

```text
r_+(p) = parent hub side XOR physical first-child hub side.
```

This is exactly the hub residual bit on the distinguished first-child occurrence. No interior word data are needed.

`kernel/psc/hub_selector.mojo` computes `r_+` directly from `h`, the good edge, and the pair.

## 3. Uniform phase theorem for C-F

Exhausting all 27 endpoint self-maps and all three choices of good edge gives:

- **type C:** every viable pair has `r_+=0`; among all conjugate maps/good-edge placements, 12 have phase 0 and 6 have no viable strict pair;
- **type D:** every placement is viable and has `r_+=0` (3 map/good-edge cases);
- **type E:** every placement is viable; 3 cases have phase 0 and 6 have phase 1;
- **type F:** every viable pair has `r_+=1`; 12 cases have phase 1 and 6 have no viable strict pair.

Most importantly:

> **For every fixed C/D/E/F endpoint map and fixed Barge–Diamond-good edge, all viable strict first pairs have one common first-child hub residual bit.**

There is no mixed C-F case.

Thus the deterministic first-child selector carries a well-defined binary phase

```text
q_+(h,G) in {0,1}
```

whenever any strict first-pair orbit is possible at all.

## 4. Immediate eliminations

The `-1` return from `strict_star_selector_phase` means there is no distinct pair whose endpoint orbit can remain strict while avoiding the chosen good edge.

Hence, if the actual Barge–Diamond-good edge occupies one of those forbidden C/F placements, that endpoint type is eliminated outright before any hierarchy-offset argument.

This is a conditional placement eliminator, not a universal elimination of C or F: Barge–Diamond guarantees existence of at least one good edge but does not specify which edge it is.

## 5. Relation to the hub/orientation cocycle

PR #40 identifies the full child-orientation sign cochain with a hub-side residual after a vertex gauge. The present theorem restricts that residual only on the **distinguished first-child edge** from each parent.

Along the first-child selector, every viable state therefore contributes the same bit `q_+(h,G)`. On a finite selector cycle of length `m`, the orientation monodromy parity is consequently

```text
m * q_+(h,G) mod 2,
```

because the hub-side vertex gauge telescopes around the cycle.

This is an exact cycle constraint, but it is not yet the Perron phase of the full child graph: interior newborn-child occurrences remain unconstrained by this theorem.

## 6. Why this is useful

The active C4 state now has three compatible finite layers:

1. Barge–Diamond reduces strict first pairs to a two-edge hub star;
2. PR #40 interprets every child orientation sign as a hub-side residual up to vertex gauge;
3. the present theorem makes the residual on the deterministic first-child selector constant.

The next load-bearing task is therefore to control the **ordered residual word across all child occurrences of a parent**, especially the interior newborn children. Any extension from the selector phase to the whole child word must be proved from balanced-factorization geometry; it is not assumed here.
