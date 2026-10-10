# Realizable target-aware BPA diagnostic — 2026-10-02

**Status: finite diagnostic. Part (b) remains open.** C4, G1 and PSC are not
promoted. This is the executable follow-up to
[issue #9's October 2 audit](https://github.com/larsbx/pisot-substitution-conjecture-research/issues/9#issuecomment-5953270122).
The [literature stop/go](target-aware-bpa-literature-gate-2026-10-02.md) precedes
the implementation.

## Executable object

`kernel/psc/target_packets.mojo` consumes a complete actual swap-seed BPA closure.
It verifies normalization, irreducibility, seed reachability, and the actual
ordered child table. A synthetic adjacency table cannot supply edges in place
of word factorization.

A packet carries the normalized BPA integer state ID, +/-1 physical side
orientation, two current occurrence indices, both incoming occurrence
addresses, the actual target-letter pair, the prefix Parikh residual, the
interior-child-boundary flag, and the incoming ordered factorization edge ID.
That edge ID is part of packet identity; repeated child occurrences are not
merged merely because they normalize to the same BPA state. Coincidence sides
are identical, but their inherited orientation is retained in the receipt.

Each address is `[source_occurrence, within_image_digit, global_position,
child_local_position]`. The factor edge records the parent, ordered child
ordinal, child ID, normalization sign, start, end and total inflated length.
Roots are actual positions in already-realized BPA words, with factor ID `-1`;
no free residual or abstract target lift is supplied by the caller. A root's
reachability from a swap seed is checked independently of the packet graph.

Both selected occurrences are inflated through their actual source images.
They continue together only when they lie in the same actual irreducible BPA
child. Split descendants are counted. Distinct balanced child spans are
disjoint, and inflation preserves their order and equal top/bottom lengths, so
their occurrence interiors cannot subsequently become the same balanced cut.
The graph does not glue those discarded descendants into an abstract six-state
letter-pair inflation map.

Substitution-local proper-prefix Parikh tables and per-state word prefixes are
precomputed. Packet interning uses a compact integer-field key; residual lookup
and incidence action use three scalar coordinates. Roots cost quadratic space
in the word lengths, subject to the packet cap; they do not recompute each
prefix in a cubic inner loop. SCC and shortest-path routines are iterative.
This is a new diagnostic, not a measured performance optimization of an older
implementation.

## Success and affine receipts

For an edge from source occurrence indices `i,j` with image digits `d,e`,

`r' = M r + lambda`,

`lambda = Parikh(sigma(top_letter)[:d]) - Parikh(sigma(bottom_letter)[:e])`.

Removing the common balanced prefix before the chosen child does not change
the residual. The physical side orientation is retained, so no unrecorded
sign flip is hidden in this formula.

Success requires both global occurrence positions to equal the start of the
same actual child, strictly inside its parent inflation, residual zero, and
the intended adjacent target pair. The default target is any immediate
diagonal; a fixed diagonal letter or right-prefix synchronization can be
requested. A zero at the parent's outer boundary is not success. A wrong
target or a matching letter at a non-balanced position is not success either.

Coincidences are terminal, following the repository BPA convention. The
reported depth concerns **localized newborn right-adjacent target events in
noncoincident BPA blocks**. It does not count a later internal diagonal inside
an already-terminal coincidence block. In particular, for arbitrary endpoint
maps this is not interchangeable with the first diagonal anywhere in an
unfactored whole-word inflation.

Replay recomputes literal inflated words, zero returns, normalization,
occurrence addresses, target classification and forcing. It does not merely
check an algebraic identity against cached expansion data. For a path of `k`
edges, the emitted forcing is the exact accumulated sum
`sum_t M^(k-1-t) lambda_t`. Accumulation uses the vendored unbounded exact
rationals, with integer results. Local machine-integer operations have explicit
image-length, word-length and potential-weight bounds. JSONL integers must be
read as integers, including the accumulated forcing coordinates.

## Outputs and limits

- Every recurrent SCC of the packet graph after successful packets are deleted,
  with all member IDs and an explicit exit flag.
- One deterministic affine cycle per recurrent SCC: the shortest return path
  for its first internal edge, not an enumeration of all cycles.
- The shortest **existential** successful target depth per source BPA SCC,
  with a replayable root and edge path. Per-state shortest depths, maximum of
  those state minima, and missing state/root counts distinguish this minimum
  from coverage of every target lineage.
- A replayable counterexample to a supplied decreasing integer potential. The
  CLI supports residual L1 and integer linear weights, strictly decreasing or
  non-increasing, on transitions whose endpoints are both target-free. The
  module accepts any per-packet integer value table. No
  violation on one graph is not a universal invariant certificate.
- Split descendants, terminal misses and packets without a target path.

A recurrent avoidance cycle can have an exit leading to a target. Finding an
existential target path does not exclude that cycle. Conversely, acyclicity
alone would need an additional no-terminal-miss/coverage argument before a
uniform hitting conclusion. State, length, packet and edge budget exhaustion
raise with nonzero exit status before a complete diagnostic verdict.

## Reproduction

From `kernel/`:

```sh
pixi run target-aware-bpa --dump
pixi run target-aware-bpa --target 2 --potential linear --weights 1 0 -1 --strict
pixi run target-aware-bpa --replay 396,820 --cycle
pixi run target-aware-bpa --sigma 1/012/1 --dump
pixi run target-aware-bpa --sigma 1/2/021 --dump
pixi run mojo run -I . tests/test_target_packets.mojo
```

The default substitution is `0 -> 1, 1 -> 02, 2 -> 202`. Its incidence cubic
is `x^3 - 2x^2 - x + 1`, with discriminant `49`; the exact PIP screen accepts
it, and the first-letter map is a permutation. The controls are fixtures, not
a new census of the standing 4,554 corpus.

| Fixture | Packets | Edges | Target-free recurrent SCCs | Source SCC shortest depths |
| --- | ---: | ---: | ---: | --- |
| Real-secondary PIP `1/02/202` | 507 | 948 | 4, all with exits | 1, 1 |
| Non-Pisot strict `1/012/1` | 46 | 82 | 1 | no target path |
| Actual G/F `1/2/021` | 153 | 235 | 1 | 1 |

The non-Pisot control's recurrent source SCC has no successful target path;
transient seed branches still produce an interior diagonal. That distinction
is preserved in the per-source receipts.

The default swap seed `(01,10)` has shortest target depth **2**, while the
source SCC minima in the table are 1. At depth 1 its inflated words are
`102` and `021`, with no interior zero return. At depth 2 they are `021202`
and `120202`, with zero-return cuts `0,3,4,5,6`. Position 1 has matching letters
but nonzero prefix residual, while position 3 is an actual interior diagonal
child start. This pins the failed second-letter and depth-one proposals.
Unequal image lengths `|sigma(0)|=1` and `|sigma(1)|=2` pin the naive
letter-pair exhaustion problem.

The existing strong G/F template still passes its algebraic and endpoint
oracle. Its three synthetic words actually factor into **1,2,5** children,
where the template proposes **1,1,3**. The third produces a diagonal `2/2`.
Canonical Mojo checks the literal factorization and accepts the actual G/F
seed closure; it does not eliminate the template by an earlier discarded
shortcut.

Full JSONL receipts and digests are under
`evidence/target-aware-bpa-2026-10-02/`. The independent Python oracle
checks their full packet and edge sets, addresses, orientation, targets, SCC
membership/exits, accumulated forcing, shortest paths, and potential failures.
`kernel/check_target_packets.sh` rebuilds the driver, compares those receipts
byte-for-byte, replays the default affine cycle, and checks CLI rejection/caps.

## Verification

The implementation was rebased onto main
`4339c0eff04531cf98529c85e8defdecae1a2d03`. The lockfile-pinned Mojo compiler
`1.1.0.dev2026090805 (34562fa1)` ran the canonical tasks directly; a full pixi
environment could not be installed because the conda-forge download was
blocked. Compiler, stdlib and MAX runtime packages were recovered from the
exact hashes in `kernel/pixi.lock`.

| Check | Result |
| --- | --- |
| Canonical `kernel/run_tests.sh` | 47 test files passed, with live contract/claim receipts |
| Latest target-packet contract | Passed, including wrong-target zeros and invented terminal edges |
| Canonical `verify.mojo` | All 10 exact certificate checks passed |
| Standing `census.mojo` | 4,554 PIP specimens; 4,554 terminated and productive; zero capped |
| `kernel/check_target_packets.sh` and evidence SHA-256 | All three exports reproduced exactly; replay, potentials, invalid inputs and all four CLI caps passed |
| Full Python suite after Mojo receipts completed | 390 passed, one optional TLC bridge skipped |
| Optional TLC bridge rerun with `TLA_TOOLS` | Passed |
| `proof/tla/check.sh` | All 14 unchanged models passed, including the expected nonproductive countermodel |
| `tools/verify_all.sh provenance` | All seven provenance, vendoring, generated-surface, source-integrity and governance gates passed |
| Full claim-governance CLI | Terminology, claims, live coverage, promotion, numerics and consistency passed |
| Manuscript audit and `git diff --check` | Passed |

Lean was not run locally because `lake` was unavailable; no Lean source is
changed. The PR's dedicated workflow repeats canonical Mojo, exact certificate,
export replay, independent oracle and claim-governance verification. The
repository's existing CI remains responsible for its other verification layers.

## Remaining research obligation

The four realizable recurrent packet SCCs in the real-secondary PIP fixture
are golden controls against asserting that arbitrary occurrence lineages must
all hit the intended target. They are not nonproductive BPA SCCs: the two
source SCCs have successful targets and all four packet SCCs have exits.
An eventual proof must specify the target-selection/coverage condition and
exclude the relevant realizable obstruction, rather than promote this local
address quotient or its finite examples to part (b). No ledger node or proof
dependency changes in this diagnostic.

## Ordered-word follow-up — 2026-10-06

The [ordered hub/offset experiment](c4-ordered-hub-offset-negative-2026-10-06.md)
keeps these receipts intact and adds separate exports. Hub-phase coherence
survives on the real-secondary recurrent supports, yet the actual two-cycle
`396,820` has physical offset `0,1,0` and nonzero Parikh defects. All controls
also have acyclic induced graphs after aligned packets are deleted, so that
finite property does not distinguish the PIP regime. The follow-up preserves
a local monovariant negative and keeps issue #9 open.
