# Calibration and promotion policy

## Default rule

A statement derived from classical foundations is presumed to be a corollary,
known result, or folklore. The burden is on the repository to identify what is
new: an effective/certified construction, a non-associative extension, a
statistical theorem, or a synthesis across previously separate literatures.

## Allowed labels

1. **candidate** — proposed, not literature-cleared.
2. **literature-cleared candidate** — bounded search recorded; still not a
   novelty claim.
3. **experimental result** — reproducible finite computation with parameters,
   code revision, and output hash.
4. **proved result** — proof and hypotheses checked; novelty remains separate.
5. **artifact contribution** — implementation or formalization contribution
   with comparison against existing software/formal libraries.
6. **novel result** — permitted only after explicit human review of a dated
   prior-art dossier.

No script may promote an entry to `novel result`.

## Required evidence

Each candidate must record:

- an exact statement with field, characteristic, integrality, and quotient
  conventions;
- nearest known results and exact delta;
- search sources, queries, dates, and exclusions;
- falsification tests and boundary cases;
- reproducible commands, parameters, seeds, output hashes, and software
  versions;
- a claim ledger distinguishing theorem, computation, heuristic, and question.

## Stop conditions

Stop and revise rather than promote when the mathematical object is not
well-defined, a normalization changes the target group, a unit action changes
the sample space, a certificate omits hypotheses, or an experiment reports
only successful cases.

## Proof review and linked surfaces

A written proof remains pending until its independent review is recorded.
Owner-directed promotion alone does not set `proof_reviewed = true`. A true
review flag requires nonempty `independent_reviewer` and `review` evidence;
these fields record an actual review, rather than creating one.

`N1-T01` links to `ZeroDivisorCertificateSoundness` through `ledger_record`.
The registry checker compares its class with the ledger-derived status.
The generated governance policy also checks its theorem-document and registry
surfaces. Missing links and mismatched promotions fail verification.
