# Issue #84 source collection — ordered overlap and context route

This directory collects and annotates the primary sources used by the
pre-proof literature gate for the ordered affine-pump and recognizability
program. It records stable public locations and claim-level relevance; it does
not vendor copyrighted article text.

## Source inventory

| ID | Source | Stable identifiers | Collected material | Role |
|---|---|---|---|---|
| `AL11` | S. Akiyama and J.-Y. Lee, *Algorithm for determining pure pointedness of self-affine tilings*, Adv. Math. 226 (2011), 2855–2883 | [arXiv:1003.2898](https://arxiv.org/abs/1003.2898); [doi:10.1016/j.aim.2010.07.019](https://doi.org/10.1016/j.aim.2010.07.019) | Abstract, definitions of real/potential overlaps, multiple-edge update (4.2), Theorem 4.1 and its residual-graph discussion | Closest prior construction |
| `CS01` | V. Canterini and A. Siegel, *Automate des préfixes-suffixes associé à une substitution primitive*, JTNB 13 (2001), 353–369 | [doi:10.5802/jtnb.327](https://doi.org/10.5802/jtnb.327) | Prefix-suffix path encoding and adic-system interface | Established address language |
| `DL17` | F. Durand and J. Leroy, *The constant of recognizability is computable for primitive morphisms*, JIS 20 (2017), 17.4.5 | [arXiv:1610.05577](https://arxiv.org/abs/1610.05577) | Primitive aperiodic recognizability and computable-radius scope | Recognizability boundary |
| `MT14` | M. Minervino and J. Thuswaldner, *The geometry of non-unit Pisot substitutions*, AIF 64 (2014), 1373–1417 | [arXiv:1402.2002](https://arxiv.org/abs/1402.2002); [doi:10.5802/aif.2884](https://doi.org/10.5802/aif.2884) | Non-unit representation space, finite-place factors, Rauzy-fractal interfaces | Non-unimodular geometry boundary |

## Claim-level annotations

### `AL11` — overlap edges and multiplicity

**Result used.** Equation (4.2) updates an overlap translation by the expansive
map and a difference of child digits. The paper builds a multiple-edge graph
and explicitly says multiplicity is essential when separating real overlaps
from potential overlaps. Theorem 4.1 compares the coincidence-leading and
residual spectral radii for a self-affine tiling whose return-vector set is
Meyer.

**Transfers to issue #84.** The algebraic form of the child update and the need
to retain multiple child occurrences transfer directly. PR #91's
`w'=Mw+q-p` is the one-dimensional Parikh-coordinate specialization.

**Does not transfer automatically.** The repository's seed-patch graph is
generated from a periodic swap patch and is not identified with the complete
potential-overlap graph of one globally realized substitution tiling. The
Meyer residual-graph theorem therefore cannot simply be quoted to close
seedwise productivity.

**Decision.** Proceed with exact ordered replay, but do not claim the recurrence
as new. Prioritize a seed-relative occurrence/growth dictionary before seeking
new spectral invariants.

### `CS01` — prefix-suffix addresses

**Result used.** Primitive-substitution orbits admit a coding by paths in the
prefix-suffix automaton, with a measure-theoretic relation to the associated
adic system.

**Transfers to issue #84.** The ordered pairs of proper prefixes in an overlap
ancestry are naturally paired prefix-suffix paths. This supplies field-standard
language for the context record.

**Does not transfer automatically.** Equality of the current letters and
affine offset is weaker than equality of prefix-suffix paths or their two-sided
extensions. The source does not supply a pump-deletion theorem for paired
overlap paths.

**Decision.** Context keys must contain ordered path and extension data; an
affine state alone is not a sufficient splicing state.

### `DL17` — effective recognizability

**Result used.** Primitive aperiodic morphisms are recognizable, and a
recognizability constant can be bounded effectively from finite substitution
data.

**Transfers to issue #84.** Once an occurrence is placed in an admissible
substitution configuration, a finite collar can recover its supertile cut.
This supports a bounded context diagnostic.

**Does not transfer automatically.** Recognizability neither equates two
different tilings nor forces their cuts to coincide. More importantly, issue
#84 does not require `ab` to be a legal factor. Recognizability on the
substitution subshift cannot be applied to the formal swap word without first
building the periodic-patch context bridge.

**Decision.** Compute or cite a recognizability radius only after defining the
iterated periodic-patch context to which it is applied. Do not implement loop
deletion first.

### `MT14` — non-unit representation space

**Result used.** Rauzy fractals for non-unit Pisot substitutions live in a
representation space inside an open subring of the adele ring. The construction
includes non-Archimedean places associated with the non-unit expansion and
relates Dumont--Thomas numeration, substitution dynamics, model sets, and
domain exchanges.

**Transfers to issue #84.** It validates the firewall: in the non-unimodular
case, the Euclidean contracting image alone is not the complete arithmetic
state space.

**Does not transfer automatically.** The paper's tiling, domain-exchange, and
representation conclusions have stated substitution/numeration hypotheses.
It does not say that every formal seed-patch affine pump is separated, nor that
a persistent nonzero overlap offset contradicts PIP by itself.

**Decision.** Defer an adelic diagnostic until a context-compatible survivor
exists. At that point name the exact MT14 space and theorem being imported,
including every extra hypothesis.

## Cross-source conclusion

The cheapest defensible next step is:

```text
ordered overlap occurrence
-> paired prefix-suffix ancestry plus periodic-patch collar
-> context equality/mismatch certificate
-> seed-relative occurrence-growth comparison
-> only then, full non-unit representation-space analysis.
```

The review rejects two premature experiments:

1. testing whether affine recurrence alone forbids cycles (`AL11` already
   explains the multiple-edge setting, and PR #91 has a productive six-cycle);
2. testing pump deletion from equality of `(top,bottom,w)` alone (`CS01` and
   `DL17` show why address and admissible context are missing).

## Reproducibility metadata

Sources were checked on 2026-09-15 at the stable identifiers above. The
project notes use paraphrases and pinpoint theorem/equation references rather
than vendoring article text. If a cited source is revised, re-check the exact
version and update this manifest before changing a theorem claim.
