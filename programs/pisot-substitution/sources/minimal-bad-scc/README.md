# Minimal-bad-SCC proposal source record

**Status:** preserved historical proposal; its assertions are not live proof
inputs. Import/review date: 2026-10-02.

| Field | Record |
| --- | --- |
| Original filename | `MINIMAL_BAD_SCC_SETUP_NOTE.pdf` |
| Printed title | *Minimal bad SCC setup for the general PSC* |
| Origin | User-supplied document associated with the April 29, 2026 minimal-bad-SCC / inversion-dynamics discussion |
| Original upload timestamp | 2026-04-29 21:07:45 UTC (file metadata; not an authorship or review date) |
| Printed author/date | Neither is supplied in the document |
| PDF producer metadata | Creation/modification timestamp reports April 9, 2026; this does not establish when the proposal was approved or reviewed |
| Extent | Four pages, 167,325 bytes |
| SHA-256 | `0bae1b1dd6a68f9035bb3a9e2d622e042ec0b0919a170e5ebdc35bc093d68a83` |
| Repository snapshot | [Original PDF](MINIMAL_BAD_SCC_SETUP_NOTE.pdf), copied byte-for-byte without corrections |
| Live interpretation | [Routing and stop/go note](../../docs/minimal-bad-scc-track-routing.md) |

## Pinpoint source inventory

- Page 1, §1: S1–S4. S2 states SRE failure as existence of a periodic
  noncoincident cycle; S3 specifies minimality in the small-regime subautomaton.
- Pages 1–2, §2: six propositions, 2.1–2.6. The source refers to a restricted
  inheritance theorem, finiteness engine and dichotomy note without locators.
- Page 2, §3: common-cut intervals and bracket types (Definition 3.2).
- Page 3, §4: return map (Definition 4.1), including the unsupported unchanged
  recognizability-radius assertion in Proposition 4.2 and its use in Remark 4.3.
- Pages 3–4, §§5–6: inversion return equation and RS1–RS4 proposals.
- Page 4, §7: the unresolved exclusion target, described by the source as the
  theorem that would close PSC. This historical description is not adopted.

The original PDF remains the source of what was proposed, including its gaps.
The routing note, README, live claim map and proof records determine current
status. No earlier assessment's proposition count or “completed program”
wording overrides this source inventory or the live ledger.

Verify from the repository root:

```sh
sha256sum -c sources/minimal-bad-scc/SHA256SUMS
```

The provenance mode of `tools/verify_all.sh` runs this check. Digest mismatch
refuses verification; the preserved source must not be silently overwritten.
