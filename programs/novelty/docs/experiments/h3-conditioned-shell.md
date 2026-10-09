# H3: exact integral shells and operator-quotiented collisions

**Status: bounded experiment. H3 remains open.** Since this experiment was
written, PR #27 supplied a separate written proof numbered paper Theorem
3.32 (`WordDefectG2Determined`), still pending independent review. The
original October 4 evidence recorded Conjecture 3.32 as experimental; the
current summary records only the experiment's bounded status and open H3.
This experiment and its audit do not review or promote that proof.
No statistical significance,
expansion, synthesis, integral descent, or theorem promotion is claimed.

This follows the integral pilot merged in PR #24, using
`main@664fcc39f104a08fddc7c255d0c925b6262d035f`, which includes its exact
all-pairs null correction and follows merged PR #23
(`b5dbb2623a1bf49f41fe33f16cf8ff7e025dd423`). The pilot's separation of
operator collisions from value-only collisions is retained. Its
characteristic-polynomial sharing counts are replaced here by explicit
conditioning on the letters' Gram data and the requested extra invariants.
The pilot's raw counts are historical evidence, not quotient sample sizes.

## Algebra, shell, and sampling contract

Use the existing `cayley-dickson/v1` convention with parameters
`(-1,-1,-1)`, basis `e_0=1,e_1,...,e_7`, and the kernel's multiplication
table. The order for this computation is the coordinate subring **Z⁸**;
the structure constants are integers and `N(x)=sum x_i²`. This is not a
choice of an E₈/maximal order. The experiment does not settle the initial
N2 dossier's E₈ or building questions.

For the sampled rows take

`S_p = {x in Z⁸ : sum x_i² = p}`, `p in {3,5}`.

Enumerate coordinates lexicographically, using integer square roots only.
The sizes 448 and 2,016 agree with the existing integral pilot. The
eligible generator population contains the lexicographic minimum of each
size-two conjugation orbit: `x < conjugate(x)`. Real fixed points are
excluded. Thus each sampled orbit contributes exactly two different
letters, and the conjugate-index convention has no ambiguity.

For `(p,m,seed)`, rank that population by the pair

`(sha256(compact_JSON(["h3-shell/v1", p, seed, x])), x)`.

Here compact JSON has sorted keys, separators `(',', ':')`, UTF-8 encoding,
and integer coordinates. Take the first `m` elements, in rank order, and
append their conjugates in the same order. No Python random generator,
floating point, or hash-table iteration order chooses an input. The output
also records every generator and its digest, so replay does not require
trusting the sampler.

The four sampled configurations were fixed before their results were
inspected:

| p | m before conjugates | seed | word length |
|---|---:|---:|---:|
| 3 | 10 | 1 | 4 |
| 3 | 10 | 2 | 4 |
| 5 | 8 | 1 | 4 |
| 3 | 5 | 1 | 5 |

Each also has a length-two row for single-defect conditioning. These
configurations are separate corpora and are never pooled into one null.

The letters have norm `p`; their conjugates are **p times their inverses**
over Q. A reduced word excludes adjacent conjugate *indices*, not a claim
that the unnormalised integral generators form a free group. With `k=2m`
letters, enumerate every reduced length-`n` index tuple in lexicographic
order: there are `k(k-1)^(n-1)` tuples.

## Exact arithmetic and the quotient

For each word retain both

`v = (...((a_1 a_2) a_3)... a_n)` and `P = L_a1 ... L_an`.

Values and operator entries are unbounded Python integers, directly
computed from the pinned kernel structure constants. There is no finite
modulus, centered lift, or modular-equality assumption in these statistics.
`P` acts on column vectors, with its rightmost factor acting first. The
independent recursive-kernel tests verify this orientation and the left-comb
value separately; they are different evaluation operations.

Inside each value fibre, quotient by **equal integer operator products**:

`u ~ w iff (v(u), P(u)) = (v(w), P(w))`.

Each equivalence class has weight one. Alias multiplicities are reported
only in raw diagnostics. A fibre with `r` different operators contributes
`r(r-1)/2` value-only collision pairs, regardless of how many words realise
each operator. Simply deleting equal-operator pairs from a word-weighted
count does not produce this statistic.

The value is included in the equivalence key so the value map on the
quotient is well-defined without an unproved assertion that the operator
determines the left-comb value. The output separately counts operators
appearing with multiple values; none occur in this bounded corpus.

The letters' Gram/form labels need not descend to this quotient. The primary
representative is the lexicographically first word in each class; a second
analysis uses the last word. Report the number of classes with differing
classical or enriched labels among aliases. Both policies and their
denominators are retained, even when they give different answers. The
sensitivity check is not a proof of independence from all possible
representative choices.

## Conditioning and matched controls

Let `B(x,y)=2 sum x_i y_i`, the paper's polar form. The classical label is
the full ordered Gram matrix of `(1,a_1,...,a_n)`: stored as `B(1,1)`,
then all `B(1,a_i)`, then the upper triangle of the letters' Gram matrix.

For length two, append `dim Q`, computed by rational row elimination on
`(1,x,y,xy)`. The sampled single-defect rows have dimensions 2 and 4;
dimension 3 is absent here, rather than being inferred from the finite-field
unipotent examples. Unit tests separately cover dimensions 1, 2 and 4.
The pending anisotropic corollary in PR #24 is not promoted by these tests.

For length four or five, append **every** increasing-index triple and
quadruple evaluation on the pure parts `p_i=a_i-a_i[0]`:

`phi(p,q,r)=B(pq,r)`;

`psi(p,q,r,s)=B(p(qr)-(pq)r,s)`.

The associator sign agrees with the paper and `word_g2.py`. Repeated
generator indices give zero alternating-form entries. There are four phi
and one psi coordinates at length four, ten phi and five psi coordinates
at length five. Full characteristic polynomials are not conditioning labels
and are not used in the quotient or collision statistics.

For each classical and enriched stratum `s`, with `n_s` quotient units and
value multiplicities `n_(s,v)`, retain the normalized second factorial
collision moment

`sum_v n_(s,v)(n_(s,v)-1) / (n_s(n_s-1))`.

It is undefined for a singleton, which is explicitly counted. Cell
histograms retain the exact sizes, distinct-value counts, collision-pair
counts and number of cells; no zero-collision or unsupported cells are
silently removed.

The form-sharing comparison uses blocks matching **both** the classical
Gram label and `trace(v)=2v[0]`. Compare extra-label agreement on collision
pairs with agreement on different-value pairs in these blocks. The output
retains the exact numerator and denominator, a reduced rational enrichment
ratio, and `null` when a comparison is unsupported. It also gives the exact
expected number of matching labels on the collision graph under uniformly
permuting the extra labels *within* each block. This expectation is computed
combinatorially, with a small exhaustive-permutation regression oracle.
There is no Monte Carlo significance test. Pairs share words, quotient
units, generators and value fibres, so they are not independent trials.

## Exploratory support panels and bounded results

The sampled rows had 4,240 raw value-only collision pairs but only **98**
after quotienting, with **zero** collisions matching a classical Gram
stratum under either representative policy. This is insufficient matched
support, not evidence that H3 is false.

Five structured panels were then added to seek support. All five panels
tried are retained and labeled `exploratory_support_panel`; their results
are not confirmatory estimates for the sampled shell population:

- `unit-p1`: all seven size-two conjugation orbits of pure coordinate units,
  ordered by the same SHA contract. This is a norm-one calibration corpus.
- `axis-12347-p5`: bases `2-e_j`, `j in (1,2,3,4,7)`, and their conjugates.
- `coordinate-1234-p3` and `coordinate-1247-p3`: for every pair `i<j` of the
  named axes use bases `1-e_i-e_j`, `1-e_i+e_j`, followed by their conjugates.
- `coordinate-cycle-12347-p3`: the same bases for the five edges
  `(1,2),(2,3),(3,4),(4,7),(7,1)`, with the smaller index carrying `-1`.

The primary, first-representative results are:

| Corpus | Reduced words | Quotient collision pairs | Gram/trace-matched collision pairs | Same phi/psi label on matched collisions | Enrichment vs matched noncollisions |
|---|---:|---:|---:|---:|---:|
| Sampled p=3, m=10, seed=1 | 137,180 | 92 | 0 | unsupported | unsupported |
| Sampled p=3, m=10, seed=2 | 137,180 | 6 | 0 | unsupported | unsupported |
| Sampled p=5, m=8, seed=1 | 54,000 | 0 | 0 | unsupported | unsupported |
| Sampled p=3, m=5, length 5 | 65,610 | 0 | 0 | unsupported | unsupported |
| Exploratory units p=1 | 30,758 | 350 | 144 | 104/144 | 2.86 |
| Exploratory axes p=5 | 7,290 | 0 | 0 | unsupported | unsupported |
| Exploratory coordinates 1234, p=3 | 292,008 | 112,524 | 1,343 | 1,019/1,343 | 2.04 |
| Exploratory coordinates 1247, p=3 | 292,008 | 25,200 | 2,192 | 2,192/2,192 | 1.00; constant within matched blocks |
| Exploratory cycle 12347, p=3 | 137,180 | 44,788 | 1,407 | 775/1,407 | 1.13 |

The last-representative ratios for the three informative structured panels
are approximately 2.93, 2.03 and 1.13. The panel with constant labels within
matched blocks has zero
informative blocks: its perfect sharing is a negative control for treating
shared forms as enrichment. The complex-line negative control, using bases
`1+2e_1` and `2+e_1` and their conjugates, has many operator aliases and
zero quotient value-only collisions.

The supported result is the reproducible separation of alias effects,
sample-support failure, and panel-dependent descriptive form enrichment.
This is not a test of characteristic-polynomial determination over all
fields (the separate written proof of paper Theorem 3.32 awaits review),
and does not settle H3. An extension
needs a fresh sampled corpus with nonzero matched support and declared
representative conventions; the structured panels are not that replication.

## Evidence, replay, and regression coverage

Run from the repository root with Python 3.12+; only the standard library is
required. The evidence was generated using CPython 3.12.14:

```sh
python experiments/n2/h3_conditioned.py
python experiments/n2/h3_conditioned.py --check
python experiments/n2/h3_conditioned.py --replay
python -m unittest discover -s tests -p test_h3_conditioned.py -v
```

`data/n2/h3-conditioned-v1.json` records the dated contract, all inputs,
source-file digests, raw and quotient counts, both policies, support
diagnostics, cell histograms and negative controls. Its certificate digest
binds the **decompressed canonical JSON**, avoiding dependence on zlib or
gzip-header versions.

`data/n2/h3-conditioned-certificates-v1.json.gz` retains every collision
fibre, with every operator class represented by
`[first word ID,last word ID,alias multiplicity]`. IDs are base-`k` integers,
first letter most significant, decoded at the declared length. Replay
recomputes full integer matrices for both words in every class, verifies
that they share the stored value/operator, and verifies that all operators
within a collision fibre are different. Thus each fibre certifies its
complete graph of value-only collision pairs. `--check` additionally
reenumerates every word and checks completeness, multiplicities, labels and
both summaries; replay alone does not certify that enumeration was complete.

Also retain the pilot's length-three value-only witness, an operator-alias
witness per supported row, matched different-value controls, and the
existing finite-field phi-only and psi-only falsifiers. Characteristic
polynomials are used only to replay these pre-existing falsifiers, not as
experiment labels. The regressions check kernel arithmetic and matrix
orientation independently, all form coordinates/signs, boundary ranks,
deterministic sampling, enumeration counts, true quotient weighting, an
exhaustive small permutation null, certificate coverage/digests, and
mutated values/operators/word IDs/multiplicities.
