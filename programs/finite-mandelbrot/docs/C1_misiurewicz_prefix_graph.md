# C1 Misiurewicz prefix graphs and the obstruction extractor

Status: definition-level finite extractor reporting obstructions on declared prefixes; no negative control for the Misiurewicz class, and no theorem-status change.

This note delivers round-two item R5 of `docs/cross-pollination-round-two-2026-09-16.md`, section N3. It runs the obstruction extractor of the Pisot overlap route on the finite graphs the exact-type catalogue of `docs/C1_misiurewicz_catalogue.md` supplies, and it is what round-one B6 was the prerequisite for.

## Terminology declaration: prefix obstruction

Genealogy: This is the recurrent-core normal form that `larsbx/pisot-substitution-conjecture-research` extracts from its overlap graph (`docs/p1-overlap-minimal-obstruction-2026-09-14.md`, `mojo/psc/overlap_obstruction.mojo`), and abstractly the finite obstruction object route F1 asks for in `docs/C1_F1_obstruction_extraction.md`. The graph-theoretic content, a backward productivity fixpoint followed by sink components, is standard.

Bridge claim: Definition-only project term. A `prefix obstruction` of a separator prefix is a sink component of the pairs that no iterate of doubling separates. It is a statement about one finite prefix graph, not about any parameter and not about any fibre.

Known leaks: One prefix is not every prefix. An empty obstruction set at a prefix says nothing about a finer one, and persistent non-separation quantifies over all of them. A refusal at the bound is not an empty obstruction set, and the two must never be read alike.

Use discipline: Use in C1 files or with a pointer to this registry, and only for sink components of one named prefix. A prefix obstruction does not locate a parameter, does not decide a fibre, and does not settle C1.

## The pipeline

For an exact type `(l, k)` with denominator `den`, the graph is built in `Z/den`:

| Stage | Object |
| --- | --- |
| vertices | the forward orbit closure of the catalogue under doubling |
| pairs | the unordered non-diagonal pairs of vertices |
| productive | separated by the prefix now, or with a productive successor |
| nonproductive | the rest: the pairs no iterate ever separates |
| sinks | the sink components of the nonproductive set, of two kinds |
| dichotomy | each *cyclic* sink is a boundary or an interior obstruction |

Two points are separated by the prefix exactly when some two-ray separator puts them on **open** sides that are opposite.

A point equal to either ray of a separator is `OnSeparator`, not a side. `docs/C1_wake_membership_soundness.md` states the strict interval condition, that a probe equal to a separator boundary is a structural equality case and not a separation proof, and `docs/C1_side_assignment_witnesses.md` says only `Left` and `Right` may prove separation. So a pair one of whose points lies on the ray stays undecided by that separator. A half-open convention, which would put the two rays on opposite sides and report them as separated, manufactures evidence both documents forbid.

One consequence is worth stating because it is easy to mistake for a bug: a separator whose two rays are adjacent has an empty open arc, so it decides nothing at all.

Productivity is computed backwards from the separated pairs, exactly as the overlap route computes it backwards from its coincidences. **Forward closedness of the nonproductive set is then a lemma rather than a computation**: a nonproductive pair cannot have a productive successor, because a separation reached from the successor is reached from the pair one step earlier. Computing a forward closure instead would be wrong, since it would admit images that the prefix does separate.

Doubling is a function, so the pair graph has out-degree at most one and every component either falls into one cycle or ends at a merging pair. No strongly-connected-component search is needed, which is the one place the mirror is simpler than the overlap route, whose graph branches and which runs an iterative Tarjan pass.

## Merging pairs

Two points with the same image, that is differing by `den / 2`, give a pair with no successor. Such a pair is never separated, so it is nonproductive. Counting it productive would be the substantive error available here: those two addresses are precisely the ones doubling can never tell apart, so they are an obstruction and not a discharge.

A merging pair has no outgoing edge, so its component is a singleton nothing leaves: it is a **terminal sink**, not a transient vertex. The nonproductive set therefore has sinks of two kinds, and `merging` counts the terminal ones exactly, `sink_components` the total.

Terminal sinks are deliberately kept out of the boundary and interior counts. That dichotomy asks whether a *cycle* meets a separator boundary, and a terminal pair has no cycle to ask about; putting it in either bucket would report a third phenomenon, two addresses with a common image, as one of the two the overlap route named.

They are also why the obstruction-free test is the whole nonproductive set rather than its cyclic sinks: over the denominator `4`, the type `(2, 1)` with no separator at all has six nonproductive pairs, two of them terminal sinks, and no cycle whatsoever.

## The dichotomy

The split transfers term by term from the overlap route:

| Overlap route | Here |
| --- | --- |
| aligned obstruction: a child start coincides, some child has zero shift | **boundary**: some point on the cycle is a separator endpoint, so the object may lie on the separation line itself, the `BoundaryEqualityCandidate` of `docs/C1_canonical_carrier_content.md` |
| strict-zipper obstruction: no zero-shift child, one side advances at each step | **interior**: no separator boundary is ever hit, so the prefix is not fine enough, which is `CarrierTooCoarse` |

The dichotomy is a property of the prefix, not of the cycle. Over the denominator `14`, the period-three orbit `3/7 -> 6/7 -> 5/7` is an interior obstruction for the prefix with first rays `1, 2, 3`, and the same cycle becomes a boundary obstruction for the prefix with first rays `1, 2, 5`, because that prefix makes `6/14` an endpoint.

No PF-critical or full-rank check appears here, for the same reason it appears nowhere in the overlap route: those are proved invariants of what the extractor returns, not filters the extractor applies.

## Where the prefix comes from

`docs/C1_admissible_separator_codes.md` requires both rays of a separator to be landed by accepted theorem tags and the pair to be declared co-landing, and it forbids a generic landing tag. Addresses alone cannot supply that evidence, so **nothing here builds a prefix out of addresses**. A separator arrives with a landing tag or it is refused, and the tag is the caller's declared hypothesis rather than a fact computed here. That is the division of labour the same document states: the finite core checks that a code has the correct finite shape and attaches theorem tags for the classical landing facts.

An earlier draft of this module generated a prefix by pairing consecutive points of the forward closure. That was wrong twice over. It invented co-landing evidence it had no basis for, and because every vertex became a cut, every vertex fell in its own arc, so the result restated the construction instead of testing anything. No sweep of that kind appears here or in the reference.

`period_orbit` offers one honest source of rays: the periodic orbits of doubling. Those rays are periodic and the addresses of a Misiurewicz catalogue are strictly preperiodic, so such a prefix never contains a point it is asked to separate. The landing tag is still the caller's to declare.

## What the extractor actually reports

On the catalogue of exact type `(1, 3)` over the denominator `14`, under the declared period-three prefix of the rays `1/7, 2/7, 4/7`:

| Quantity | Value |
| --- | --- |
| vertices | 12 |
| undecided at the prefix | 37 |
| nonproductive | 20 |
| merging | 2 |
| boundary obstructions | 2 |
| interior obstructions | 0 |

That prefix does not decide this class, and the module says so rather than reading as clean. This is a report about one declared prefix. It is not a negative control for the class, and nothing here is evidence about the imported tag `KnownTrivialFiberClass`.

## The negative control

Round-two item R5 asked for the negative control the first draft of N3 promised and could not supply: a case whose verdict is fixed by an argument rather than by the code, and whose separators carry a co-landing that is declared rather than derived from the points being separated. It is a control on **this extractor**, not on the class.

Over the denominator `21` the forward closure of `9` is `{9, 15, 18}`, the period-three orbit `3/7 -> 6/7 -> 5/7`. The declared separator is the pair `1/7` and `2/7`, the two rays that co-land at the root of the period-three component; over `21` they are `3` and `6`. That co-landing is an imported classical fact about a root, and neither ray is a point of the orbit.

Every point of the orbit lies strictly outside the arc from `3` to `6`, so no separator ever puts two of them on opposite sides. Doubling carries the orbit onto itself, so all three pairs are nonproductive and lie on one cycle. No point of the orbit is `3` or `6`, so that cycle meets no separator boundary, and the dichotomy must call it interior.

| Declared prefix | vertices | undecided | nonproductive | merging | boundary | interior | verdict |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| `1/7, 2/7` | 3 | 3 | 3 | 0 | 0 | 1 | obstruction |
| `1/7, 2/7` and `1/3, 2/3` | 3 | 1 | 0 | 0 | 0 | 0 | clean |

The second row is the other direction, decided the same way: the rays `1/3` and `2/3` co-land at the root of the period-two component and are `7` and `14` over `21`; the arc from `7` to `14` holds `9` and neither `15` nor `18`, so the orbit is split, and the single pair left undecided at the prefix is separated one doubling later. An extractor that always reported an obstruction fails the second row; one that always reported a clean graph fails the first. This is also the first case in which the interior branch of the dichotomy is exercised at all: the pinned `(1, 3)` report above has no interior obstruction.

The control says nothing about any fibre. The same three points are an obstruction under one declared prefix and clean under the other, which is the point: a verdict here is about a prefix, never about a parameter.

## Bounds and fail-closed behaviour

One constant governs the graph. Vertices live in `Z/den`, so `MAX_PREFIX_GRAPH_DENOMINATOR` caps the vertex count and the pair count together, and the Python reference carries the same constant so the two agree on every refusal. Of the 64 exact types with both indices at most eight, 29 are within the bound and 35 are past it.

A denominator past the bound, a mismatched or malformed separator list, an untagged or unknown landing tag, and an out-of-range point are all refused before any graph is built. **A refusal is never an empty answer.** An empty obstruction set is a positive verdict about a complete graph, so `obstruction_free` requires acceptance, and a bounded search that failed never reads as a clean verdict. This is UW-2: a bounded failed search is not persistent evidence.

## Non-claims

`obstruction_free_proves_fibre_triviality`, `extractor_decides_persistent_nonseparation`, and `bounded_refusal_is_evidence_of_no_obstruction` all return `False`. This note does not claim:

- that C1 is proved, or that any fibre is trivial;
- that an empty obstruction set at one prefix implies one at a finer prefix;
- that any ray pair co-lands; every landing tag here is a declared hypothesis;
- that a prefix obstruction locates a parameter or identifies a fibre;
- that the extractor decides persistent non-separation, which quantifies over every prefix.

## Next target

The extractor reports sink components by kind. The next local target is to emit the smallest interior obstruction as a replayable witness rather than a count, which is the countermodel-retention step the overlap route also lists as future work.
