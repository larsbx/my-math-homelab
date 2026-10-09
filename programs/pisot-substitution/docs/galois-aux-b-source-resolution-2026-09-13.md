# Source resolution: Galois propagation and aux-B

**Status:** resolved provenance audit. This note distinguishes the historical
degree-three Galois argument, the now self-contained degree-two carrier lemma,
and the open concentration problem. It does not prove concentration or SCC
Producer.

## Resolution

The phrase “Galois propagation / aux-B” combined three different statements.
They do not share one missing source.

| Statement | Authoritative source | Status |
| --- | --- | --- |
| Dominant capture for the six special length-seven `K2=0` seed defects `K3(s_k)` | `archive/2026-09-08/certificates_patched/PROOF_CERTIFICATE.md`, §§8–10, imported by commit `013fbedc3b799934fc9eca9ef8b64c0e680ed26b` | Historical theorem with exact finite-algebra support; it is seed-specific and degree three |
| A closed nonproductive carrier with some nonzero `K2` has full rational wedge span and hence nonzero projection in every wedge eigencoordinate | `manuscripts/PSC_balanced_pair_state_2026-09-13.tex`, Theorem 5.16(i) and Proposition 5.20, merged by commit `318370f92c47f0251f16fd6c6c275fb819912739` | Repository-proved; no separate Galois source is required |
| Every strict component has nonzero `K2` (“concentration”, formerly aux-B) | same manuscript, Open Problem “Concentration” | Open; there is no proof source to import |
| Nonzero-`K2` strict components are productive | same manuscript, Open Problem “Wedge productivity” | Open; full wedge span does not prove productivity |

## Why the carrier propagation is self-contained

For a closed nonproductive component `C`, signed block additivity gives

```text
(Lambda^2 M) span_Q{K2(T): T in C} = span_Q{K2(T): T in C}.
```

Theorem 5.16(i) proves directly that the characteristic polynomial of
`Lambda^2 M` is irreducible over `Q` when the cubic characteristic polynomial
of `M` is irreducible. Therefore the invariant rational span is either zero or
all of `Lambda^2 Q^3`. In the nonzero case no nonzero real linear functional,
including any wedge eigenfunctional, vanishes on every carrier vector.

This replaces the reported later “Galois wedge propagation” as used in the
carrier argument. Galois conjugacy is one way to describe why irreducibility
forbids a proper rational invariant subspace; it is not an additional theorem
or source dependency here.

## What the archived Galois certificate actually proves

Sections 8–10 of `PROOF_CERTIFICATE.md` concern the degree-three free-Lie
representation `Phi3`, not `Lambda^2 M`. They split the non-determinant factor
according to the `S3` or `A3` Galois group of the irreducible cubic and prove
dominant capture for six explicit length-seven seed tensors. Section 11 states
the SCC transfer only conditionally on a carrier already having nonzero
dominant projection. Section 12 explicitly lists “No pure `K2`-zero SCC exists”
among the statements not proved by the certificate.

Consequently this certificate cannot be cited as a proof of aux-B, carrier
existence, or productivity.

## Provenance conclusion

The full reachable-history audit remains correct that no `PSC_PROOF_v16` file
was found. The revised conclusion is narrower:

- no missing v16 source is needed for the degree-two span implication, because
  it has been independently reconstructed and audited on `main`;
- the historical degree-three Galois argument is already preserved at an exact
  path and commit;
- aux-B is not “source-pending”; it is an open conjectural implication with
  formulation provenance at commits `af46a0e` and `1297174`;
- no claim here supplies the missing proof of concentration or wedge
  productivity.
