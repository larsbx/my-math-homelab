# P1-B — exact affine-ancestry pump calibration

**Status:** exact finite certificate advancing the open G1b-2 renewal-finiteness gate. It removes the hard finite counter-calibration retained by the sidewise-cokernel audit; it does **not** prove a uniform pump-normalization theorem or G1b-2.

## Exact recurrence

For a certified relative renewal address, let `q_t` be the difference of the proper-prefix Parikh vectors preceding the selected top and bottom children at ancestry level `t`. The canonical Mojo implementation constructs

```text
x_0 = source_defect,
x_(t+1) = M x_t + q_t.
```

It retains the paired current letters together with `x_t` at every level. Direct expansion gives

```text
x_d = M^d source_defect + sum_(t=0)^(d-1) M^(d-1-t) q_t = 0,
```

which is the existing exact zero-return certificate written level by level. Incidence and proper-prefix data are precomputed once per substitution, leaving only fixed-size integer arithmetic and indexed lookups in each trace step. All `601` certified observations in the canonical determinant-two, single-seed, depth-at-most-seven corpus close under this recurrence.

## Resolution of the unique sidewise-abelian survivor

The sidewise-cokernel audit retained exactly one pair with equal bounded joint-local projection and equal exact top/bottom prefix translations:

```text
(depth 7, cut 14) versus (depth 5, cut 14).
```

The exact affine traces show:

- both traces have the same initial paired affine state;
- the depth-seven trace first repeats that state at levels `0` and `2`;
- deleting its first two transitions leaves six states;
- those six states agree exactly with the complete depth-five trace.

There is also a proper internal repeat at levels `1` and `3`. Deleting those two ordered top/bottom edges yields exactly the independently certified depth-five address, digit for digit. Thus the longer observation is an exact two-level affine pump extension of the shorter one without relying only on a boundary repeat. The apparent hard survivor is explained by a repeatable symbolic ancestry loop once order is retained.

The same canonical predicate recovers the previously known three right-edge recurrence witnesses: each depth-four address has a proper one-edge repeat at levels `1` and `2`, and deletion produces the independently certified depth-three address exactly.

## What remains open

This finite certificate does not yet justify deleting such a loop in every globally realizable balanced-pair occurrence. The next theorem target is:

> **Affine pump-normalization lemma.** Under a fixed discrepancy bound, every realizable labelled first-return address containing a repeated paired affine state can be shortened at that loop while preserving the relevant realizability/context class; every loop-free normalized trace belongs to a finite set.

The statement must be proved without unimodularity, without treating a stable projection of `Z^A` as a lattice, and without discarding labels or ordered prefix-suffix data. Its second clause still requires a uniform bound on loop-free affine states; the present corpus supplies evidence, not that bound.
