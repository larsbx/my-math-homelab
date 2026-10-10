# Literature gate — the cut catalogue against the ray catalogue

## Proposed step

`docs/finite-separator.md` replaced the ray-pair separator with a catalogue of
exact rational cuts, and named the gap it left:

```text
the cut catalogue separates exactly what a landed ray-pair catalogue separates
    [CutCatalogueRayEquivalence: NOT GATED, NOT USED]
```

It was named so that nothing would use it by accident. It was not classified,
and the governance route it falls under requires that: a novel bridge term
must say whether its claim is a theorem, a conditional theorem, a definition,
or an analogy (`docs/terminology-governance.md`, Route B). This gate
classifies it.

Unlike every other gate in this repository, the statement here is not
anyone's theorem. It is this repository's own claim, written last, and the
question is not whether a source states it but whether it is true.

## Decision

**REJECTED.** The two separators are not equivalent, and the failure is not a
technicality at the edges: **a ray-pair separator cannot separate any two
points of the interior of `K_c`, ever, and a cut can.** The claim is false in
that direction for every parameter with nonempty interior, which is most of
the corpus.

It is not repairable by weakening to one direction either. Section 3 says
why.

## Findings

### 1. A ray-pair separator is blind inside `K_c`

A dynamical ray lies in the basin of infinity, which is the complement of
`K_c`. A ray pair landing at a common point `z_0` therefore meets `K_c` only
at `z_0`, and `z_0` is in the boundary. So the separating curve does not meet
the **interior** of `K_c` at all, and the interior lies entirely within one
of the curve's complementary components.

**No ray pair separates two interior points of `K_c`.** No finite collection
of them does either, for the same reason applied to each.

### 2. A cut is not blind there

At `c = 0` the boxes of radius `1/16` around `1/4` and `-1/4` both have
quadrance at most `13/128`, so both are well inside the interior of `K_0`,
and the cut `x = 0` separates them at step zero. This is checked rather than
asserted: `tests/test_separator.py`, and the same holds at every parameter
where the interior is nonempty.

Findings 1 and 2 together refute the claim.

### 3. Why the direction cannot simply be weakened

The obvious repair is to keep only the inclusion that might survive -- every
ray separation is matched by some cut. That is true and useless. Any two
distinct points are separated by some straight line, so an *unrestricted* cut
catalogue matches everything trivially, and `docs/finite-separator.md`
section 5 already says an unrestricted catalogue makes the question vacuous.
Against a **declared finite** catalogue, which is the only version with
content, neither inclusion holds: a finite set of cuts need not match a given
ray pair, and by finding 1 no set of ray pairs matches a cut that separates
inside the interior.

So there is no weaker true statement of the same shape. What the classical
reading needs is not a translation of cuts but a different construction --
pieces built from rays -- and this repository has no certificate for a ray.

### 4. The rejection is informative, not merely negative

The two separators are blind in different places **by design**, and saying so
is worth more than the tag was. The classical separator is deliberately blind
inside `K_c`, because the fiber of an interior point is not a question the
theory asks: the component is the answer. The cut separator has no such
discipline and will happily cut a Fatou component in half.

That is a leak, and it is now a declared one: a class of level-`k`
non-separation was already forbidden from being called a fiber
(`docs/terminology-registry.md`), and the reason is no longer only that the
relation is intransitive. It is also that the relation cuts where the
classical one does not.

## Verdicts

| Tag | Where named | Verdict |
| --- | --- | --- |
| `CutCatalogueRayEquivalence` | `docs/finite-separator.md` section 7, `docs/J1_proof_definition.md` amendment | **REJECTED** (findings 1-3), and not repairable in that form |

## What this gate did not do

It did not judge the classical fiber theory, which is not in question here.
It did not show that the cut separator is useless -- it separates, soundly,
and `docs/permanent-non-separation.md` shows what its limits look like from
inside. It did not find a replacement bridge, and it does not claim none
exists: it claims this one does not, and that the search for one starts from
rays rather than from cuts.
