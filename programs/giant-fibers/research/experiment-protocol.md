# Exact experiment protocol

The experiment layer exists to falsify claims, discover missing cases, and emit replayable evidence.

## Arithmetic rules

- Work over exact finite fields/rings only.
- No floating point.
- No real/complex analytic surrogates.
- Normalize projective representatives deterministically.
- Record every exceptional characteristic explicitly.

## Baseline enumeration

For each prime (p):

1. construct (Gmod p);
2. test nondegeneracy and determine Witt type;
3. enumerate projective null points (X_p);
4. enumerate chart points (X_p^{(0)});
5. for every anchor (ain X_p^{(0)}), count every (N_c(a));
6. group anchors by observed fiber profile;
7. compare the exceptional (c)-set with the dual-quadric tangent condition.

The test must fail if two anchors have different profiles while anchor-independence is asserted.

## Required prime coverage

Include:

- every odd prime below a modest bound for exhaustive regression;
- both split and nonsplit primes;
- all characteristics dividing coefficients/discriminants as explicit exceptional cases;
- randomly selected larger primes after the exhaustive small-prime pass.

## Certificate output

Each run should emit a deterministic record containing:

- prime/modulus;
- Gram matrix hash;
- normalization/version identifier;
- Witt type;
- (|X_p|), (|X_p^{(0)}|);
- anchor identifier;
- vector of fiber counts indexed by (c);
- tangent/singular parameters derived algebraically;
- checksum of the full enumeration.

## Prime-power phase

For (p^k), distinguish primitive/normalized lifts and record the Jacobian rank at the mod-(p) reduction.  Regular and singular fibers must be reported separately.

## Thin-orbit phase

Given Apollonian generators:

- enumerate the congruence orbit where feasible;
- compare orbit support with the ambient cone/quadric;
- record random-walk total-variation or chi-square diagnostics against the exact target;
- never interpret finite walk convergence as a proof of expansion.
