# Hypothesis-first verification protocol

The repository separates four layers:

1. **Definitions** fix objects and conventions.
2. **Hypotheses** delimit the domain of a claim.
3. **Verification obligations** test definitions, certificates, computations, or
   cited reductions.
4. **Theorems** may be entered only when every referenced hypothesis and
   obligation is verified.

At present the theorem ledger is intentionally empty.

## Status meanings

Hypotheses use `proposed`, `pinned`, `verified`, or `refuted`.

- `proposed`: wording or scope remains under review.
- `pinned`: exact statement and source locator are stable, but its use has not
  yet been independently verified.
- `verified`: evidence identified by `verified_by` exists and passes.
- `refuted`: a counterexample or scope failure is recorded.

Obligations use `open`, `verified`, or `failed`. A theorem must not depend
on a merely pinned hypothesis.

## Verification classes

- **structural**: schema, dependency, and status-transition checks.
- **computational**: deterministic tests with exact inputs and output digests.
- **certificate**: an independent checker validates a finite witness.
- **formal**: a proof assistant checks a theorem under declared hypotheses.
- **literature**: a cited theorem is matched line-by-line to the exact use,
  including hypotheses and normalization.

Literature verification is not novelty verification.

## Derivation gate

A theorem record must contain a nonempty exact statement, hypotheses,
obligations, proof artifact, and claim class. The validator rejects:

- missing or non-verified dependencies;
- cycles in dependency records;
- experimental evidence presented as a proof;
- theorem identifiers not namespaced by candidate;
- novelty claims in the theorem ledger.

Theorems derived later should therefore be conservative mathematical results.
Novelty remains a separate human-reviewed decision.
