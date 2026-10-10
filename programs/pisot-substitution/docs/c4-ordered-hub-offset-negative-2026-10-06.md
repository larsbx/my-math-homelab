# Ordered hub words and an offset-descent negative — 2026-10-06

**Status: finite diagnostic and golden counterexample to a proposed local
monovariant.** Issue #9 stays open. C4, G1 and PSC retain their existing claim
status. No strict PIP counterexample component is produced.

## 1. Inputs and scope

Base: `c2bd9a09555a91c6ebf65e3b477121c9dc5a554b`. The three retained
`evidence/target-aware-bpa-2026-10-02/*.jsonl` receipts are unchanged. Their
digests are copied to `evidence/ordered-hub-packets-2026-10-06/INPUT_SHA256SUMS`.
The [literature gate](c4-ordered-hub-literature-gate-2026-10-06.md) precedes the
experiment.

The new canonical Mojo module is `kernel/psc/packet_hub_analysis.mojo`, with
driver `kernel/ordered_hub_packets.mojo`. It reconstructs the same complete
actual BPA/packet graphs and reads their ordered factor tables. The old export
replay checks that this reconstruction matches the retained receipts
byte-for-byte; the new export records every row for every hub on each recurrent
support, not only the child selected by one avoidance cycle.

Each fixture uses fixed caps of 20,000 BPA states, physical state length
10,000, 200,000 packets and 2,000,000 packet edges. Exhausting any cap refuses
the run before a complete diagnostic export. These are three retained fixtures,
not a new substitution census.

A packet SCC is not a strict BPA SCC. In particular, the PIP supports below
have coincidence children. The strict `DerivedSystem` constructor and the
good-edge bridge keep their existing domain; no productive support is fed to
them as a strict component.

## 2. The four PIP supports and both controls

The common hub column is **endpoint/actual-first-child compatibility on the
listed support**, not a certificate that a candidate edge is eventually
coincident. A dash means there is no compatible common hub.

| Receipt / packet SCC | Packets | BPA support IDs | Compatible hub / phase | BPA support strict child-closed? | Packet SCC has an exit? |
| --- | ---: | --- | --- | --- | --- |
| Real-secondary / 0 | 2 | 7, 8 | 0 or 1 / 1 | No | Yes |
| Real-secondary / 1 | 2 | 7, 8 | 0 or 1 / 1 | No | Yes |
| Real-secondary / 2 | 58 | 7, 8, 9 | 0 or 1 / 1 | No | Yes |
| Real-secondary / 3 | 2 | 1, 4 | 2 / 0 | No | Yes |
| Non-Pisot strict / 0 | 24 | 0, 2 | 1 / 1 | Yes | Yes |
| Actual G/F / 0 | 54 | 1, 2, 3, 5, 6 | — | No | Yes |

The packet exit flag and BPA child closure concern different graphs. In the
non-Pisot control a packet may leave its recurrent packet SCC while staying
in the strict BPA component or ending as a target miss. Its recurrent source
BPA component still has no target path, as the retained diagnostic states.
The total packet/edge counts remain `507/948`, `46/82` and `153/235` for
real-secondary, non-Pisot strict and actual G/F, respectively. Both PIP source
SCCs retain successful target paths alongside the four avoiding packet SCCs.

Write `D` for an undefined residual on a diagonal child and `H` for an
undefined residual because the child first pair lacks the chosen hub. Both
export as `-1`, never as a parity bit. All entries below remain in actual order.

| Fixture / hub | Normalized parent | Ordered children (state ID, raw sign) | Ordered hub word |
| --- | --- | --- | --- |
| Real-secondary / 0 or 1 | `7 = 021/120` | `(8,−)` | `1` |
| Real-secondary / 0 or 1 | `8 = 022021/120202` | `(9,−),(5,+),(7,−),(5,+),(6,+),(5,+)` | `1,D,1,D,D,D` |
| Real-secondary / 0 or 1 | `9 = 022021/120220` | `(9,−),(5,+),(8,−)` | `1,D,1` |
| Real-secondary / 2 | `1 = 02/20` | `(4,+)` | `0` |
| Real-secondary / 2 | `4 = 1202/2021` | `(1,+),(5,+),(7,+),(5,+),(6,+),(5,+)` | `0,D,H,D,D,D` |
| Non-Pisot / 1 | `0 = 01/10` | `(0,−),(2,+)` | `1,1` |
| Non-Pisot / 1 | `2 = 12/21` | `(0,+),(2,−)` | `1,1` |

IDs 5 and 6 in the real-secondary fixture are `2/2` and `0/0`. For SCCs 0
and 1, state 9 in the first child of state 8 lies outside the recurrent
support. Its position is retained. Removing either it or the intervening
diagonal would erase the order information at issue.

The first-child phase agrees with every **defined** child bit in these PIP
rows and in the non-Pisot strict rows. This observation has no discriminatory
force between those controls. A total phase word on a strict component cannot
be replaced by a word that silently deletes undefined children of a productive
component.

The actual G/F support visits all three unordered first-letter pairs, so no
single hub applies to the whole support. Individual rows still have meaningful
partial words: for example state `6 = 021/210` at hub 2 has `H,0`. The original
synthetic G/F guard remains intact: its proposed child counts `1,1,3` differ
from the actual counts `1,2,5`. Its rejection remains at literal factorization.

## 3. Candidate and precise counterexample

Test the following proposed local step for an offset-based proof:

> On an actual target-free occurrence SCC of a PIP substitution, suppose a
> common compatible hub has constant residual phase on the actual internal
> child occurrences. Then the potential `V=|i-j|` is nonincreasing on those
> transitions, including selection of an interior child factor.

This candidate is false. The real-secondary substitution is

```text
0 -> 1, 1 -> 02, 2 -> 202.
```

Its exact PIP screen accepts the incidence matrix

```text
M = [[0,1,1], [1,0,0], [0,1,2]],
char(M) = x^3 - 2x^2 - x + 1.
```

Packet SCC 0 has the actual cycle `209 --396--> 429 --820--> 209`. Edge 91
supplies a realized source-occurrence entry into packet 209; the export pins
the root witness `[91,396]` through the first cycle edge. Every edge replays
against literal inflation and zero-return factorization.

| Packet | Normalized state / physical sign | In-child cuts `(i,j)` | Exact defect | `i-j` | Incoming factor |
| --- | --- | --- | --- | ---: | --- |
| 209 | 8 / − | `(4,4)` | `(-1,1,0)` | 0 | 16: state 7, ordinal 0, span `[0,6)` |
| 429 | 7 / + | `(2,1)` | `(1,-1,1)` | 1 | 19: state 8, ordinal 2, span `[7,10)` of length 13 |

Edge 396 selects an actual interior child factor and raises `V` from 0 to 1.
Edge 820 returns `V` to 0. For either hub 0 or hub 1, both actual factor
residuals are 1. The factor ordinal word is `2,0`; it is not a first-child-only
cycle.

The affine identities provide an independent exact check:

```text
r_429 = M r_209 + (0,0,0),
r_209 = M r_429 + (-1,0,-1).
```

Neither packet is successful. Packet 209 is physically aligned **inside** its
irreducible block at position 4, where its Parikh defect is nonzero. Its two
equal positions are not an actual balanced-child boundary. Packet 429 selects
different positions inside its child. Selecting an interior factor is distinct
from selecting that factor's balanced start.

Repeating the cycle also refutes eventual permanent physical alignment of
arbitrary such occurrence lineages. Moreover, no function of a repeating
finite local offset snapshot can strictly decrease on every edge of this
two-cycle: its value would have to be smaller than itself after two steps.
This does not reject a potential whose domain is restricted by an additional
proved strict legal-tower/coverage condition.

## 4. Hierarchy-offset coordinates and their domain

`local_factor_offset` uses the existing `RelativeHierarchyOffset` record for a
verified **depth-one incoming-parent partition**, retaining exact defect,
incoming proper-prefix correction, physical cut displacement, in-block
offsets, both state IDs/orientations and packed radius-one ordered contexts.
The context convention matches `hierarchy_offset.mojo`: left neighbor then
current block. The sentinel marks the end of this finite parent, not the end
of a bi-infinite legal context.

For the negative above, contexts are `[20,17]` and `[11,14]`: sentinel/state
8−, and state 5−/state 7+, respectively. The full local snapshots, including
correction and physical orientation, repeat on the two-cycle; merely adding
their fields does not remove it.

Every packet edge keeps both selected occurrences in the same actual child.
Consequently its local `Delta_block` is 0, even when `i-j` is nonzero. This is
a restriction of the packet object, not an alignment theorem. The strict
ancestry construction permits asynchronous source cuts in distinct derived
blocks; the retained packet graph discards split descendants. The new
instrument does not manufacture those missing legal tower transitions.

On the non-Pisot strict control, canonical regressions compare **every**
recurrent packet snapshot against `relative_hierarchy_offset`, with literal
side reconstruction, depth one and radius one. Defect, correction, cut/block
displacement, offsets, state IDs after remapping, orientations and contexts
agree. On productive PIP supports only the finite partition snapshot is
asserted; the strict legal-ancestry theorem is not imported.

## 5. Second candidate: exclude persistent physical misalignment

Delete the physically aligned packets from each retained recurrent SCC and
test the resulting induced graph for recurrence. All six induced graphs are
acyclic. The surviving vertex counts are `1,1,26,0` for the four PIP SCCs,
8 for the non-Pisot control and 24 for actual G/F.

This finite property holds even on the non-Pisot strict negative. The PIP
SCCs still contain 1, 1, 22 and 0 aligned packets with **nonzero** Parikh
defect. The two controls contain 8 and 14. Thus recurring visits to physical
alignment do not give balanced alignment or the intended target. This is not
a uniform cycle-exclusion or coverage result.

## 6. Reproduction and next obligation

From `kernel/`:

```sh
pixi run ordered-hub-packets --sigma 1/02/202
pixi run ordered-hub-packets --sigma 1/012/1
pixi run ordered-hub-packets --sigma 1/2/021
pixi run mojo run -I . tests/test_packet_hub_analysis.mojo
pixi run bash check_target_packets.sh
pixi run bash check_ordered_hub.sh
```

From the repository root:

```sh
python -m pytest tests/test_ordered_hub_evidence.py tests/test_target_packet_evidence.py
```

The independent Python oracle reconstructs raw child words, hub sides, all
local offset fields and source witnesses from the retained literal receipts.
New JSONL exports and their digests are in
`evidence/ordered-hub-packets-2026-10-06/`. The canonical workflow runs both
old and new byte-for-byte export checks.

The next uniform step must connect a strict, child-closed legal cut regime to
balanced alignment or synchronization, with a stated coverage condition. A
repeating packet coordinate or a recurring physical alignment alone supplies
neither the equal legal word contexts needed by recognizability nor the missing
strictness premise. This negative retires the tested local offset descent;
it leaves the strict-component route available for a correctly restricted
argument.

## 7. Verification

The exact Mojo compiler `1.1.0.dev2026090805` was reconstructed from the three
SHA-256-verified packages pinned in `kernel/pixi.lock`; no toolchain or package
pin changed. The `pixi` launcher and Lean's `lake` were unavailable locally.

| Check | Result |
| --- | --- |
| `kernel/run_tests.sh` with the pinned compiler | All 60 test files reached passing claim/contract receipts, including the four new counter-calibrations |
| `verify.mojo` | All 10 exact certificate checks passed |
| Standing `census.mojo` | 4,554 PIP builds terminated, 0 capped, 4,554 productive |
| Old and new export replay scripts | All three old exports and all three new exports matched byte-for-byte; digests and invalid-input checks passed |
| Independent targeted Python oracles | 14 tests passed across ordered-hub, original target-packet and synthetic controls |
| `tools/verify_all.sh` | All 12 run checks passed, including the full Python suite and all 14 TLA models; the script skipped its Mojo launcher layer and Lean |
| Claim governance, including live receipt coverage | All six checks passed after the complete Mojo run |
| Generated ledger/catalogue, vendored pins and source integrity | Passed; claim ledger and formal dependency files are unchanged |

The manually executed Mojo suite, certificates and census cover the script's
skipped Mojo layer. Lean was not run; no Lean source changed. Finish the Mojo
suite before auditing live receipts: its file is incomplete while tests are
still running.
