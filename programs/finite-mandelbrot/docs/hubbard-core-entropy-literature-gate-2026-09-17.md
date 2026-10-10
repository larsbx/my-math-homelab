# Literature gate — a census of the algebraic type of core entropy

## Proposed step

Round-one item B8, carried into round-two item R7, proposes:

> For a postcritically finite quadratic parameter, the Hubbard tree map is Markov
> on edges and its transition matrix `A_c` is a non-negative integer matrix with
> `rho(A_c) = exp(h_core(c))`. Deliverable: for all Misiurewicz parameters with
> `(l, k)` in a box, the exact algebraic type of `exp(h_core)` — Pisot, Salem, or
> other Perron — and for the Pisot cases the balanced-pair algorithm run on the
> induced edge substitution.

B8's own text set the condition this note discharges: *"Whether 'Pisot core
entropy' has been characterized in the literature must be searched before any
claim."* It also recorded the blocker, that the Pisot test was cubic-only. That
blocker is gone: the degree-`n` screen merged as `PSC: 31effdb`.

This review asks whether the census is already answered, which hypotheses
transfer, which families break it, and where the code can actually live.

## Decision

**Proceed. The census population stays the whole declared box; what narrows is
where the exact screen applies, and two claims are withheld.**

The census is not foreclosed, and it is worth more than the first draft of this
note allowed: fixing the degree to two leaves *both* the image question and the
fiber question open (finding 1). The population must not be narrowed to the
primitive subfamily — that is where the screen decides, and the satellite and
renormalizable strata are reported separately rather than dropped, per finding 3.
Three things have to be fixed before any code is written: the census
must partition by primitivity rather than assume it, it must not present itself
as computing the Thurston set or the Master Teapot, and it needs the screen to
be reachable, which today it is not.

## Findings

### 1. The image set is characterised. The fiber is not, and that is the census

Thurston's theorem settles the question **for multimodal maps of unrestricted
degree**: a positive real `h` is the topological entropy of a postcritically
finite self-map of the interval if and only if `exp(h)` is a **weak Perron
number**, a real positive algebraic integer at least as large as the modulus of
each of its Galois conjugates.[^1] [^2] Every weak Perron number is realised
there, by some continuous multimodal postcritically finite interval map.[^8]

**Fixing the degree does not inherit that answer, and the first draft of this
note wrongly said it did.** Restricting to degree two is described in the
literature as the point where the question becomes more subtle: for postcritically
finite maps of restricted degree the dynamics impose complicated restrictions on
which Perron numbers are attainable as `exp(h)`, and *describing those numbers* is
stated as the problem.[^8] Thurston's own degree-two work went to the Galois
conjugates of the growth rates of real quadratic postcritically finite
polynomials, and found the fractal structure now called the Thurston set — which
is what one does when the image is not yet characterised.[^8]

So there are two open questions here, not one, and the census bears on both:

- **the image**, restricted to degree two: which weak Perron numbers in `[1, 2]`
  actually occur as `exp(h_core)` of a quadratic Hubbard tree map;
- **the fiber**: which parameters give which value. The survey literature states
  this direction too — describing the shape of the Master Teapot or the Thurston
  set is *a step toward characterising which weak Perron numbers arise as the
  growth rates of which* postcritically finite interval maps.[^3]

B8's census — fix a box of Misiurewicz types `(l, k)`, report the algebraic type
of each `exp(h_core)` — is a finite sample of the fiber, and its value set is a
finite sample of the degree-two image. Neither is foreclosed.

Searching for a characterisation of *Pisot* core entropy specifically returned
none. That is weak evidence and is recorded as such: it means no such result
surfaced, not that none exists. Any write-up must repeat the search against a
mathematician's reading rather than rely on this note.

### 2. The growth rate is confined to `[1, 2]`, which makes the target set small and largely known

For a quadratic Hubbard tree the transition matrix has a strong constraint.
Because `f_c : T_c -> T_c` is surjective and at most two-to-one, every row of `A`
sums to `1` or `2`, so

```text
1 <= lambda <= 2,        lambda = rho(A_c) = exp(h_core(c)).
```

This is stated and used directly in the core-entropy literature.[^4] It is the
single most useful fact for scoping the census, because the Pisot numbers in
that window are unusually well understood:

- the smallest Pisot number is the plastic constant `1.3247...`, the real root of
  `z^3 - z - 1`, identified by Salem and proved minimal by Siegel, both 1944;[^5]
- the set of Pisot numbers is closed, also Salem 1944, and its smallest limit
  point is the golden ratio `1.6180...`;[^5]
- every Pisot number below the golden ratio is known explicitly, by Dufresnoy
  and Pisot 1955.[^5]

So a census reporting "Pisot" **below the golden ratio** is reporting membership
in a set that is explicitly enumerated. That is a reason to be *more* careful
rather than less: such a hit is checkable against a known list, and one that is
not on the list is a bug in the census before it is a discovery.

The check does not extend upward. Between the golden ratio and `2` the Pisot
numbers are not given by any comparable explicit enumeration, so a hit there is
neither confirmed nor impugned by a list, and treating an unlisted value in that
range as an error would reject correct output.

At the top of the range `lambda = 2` occurs, at `c = -2`. Two is a rational
integer and therefore trivially Pisot, and reporting it as an interesting Pisot
case would be an artefact.

### 3. Perron–Frobenius transfers, and its failure set is named exactly

The census wants to feed `A_c` to the repository's existing exact screens. Those
screens carry hypotheses: `is_pip` requires a **primitive** matrix with an
**irreducible** characteristic polynomial, and the degree-`n` screen decides root
location only, refusing irreducibility above degree three.

The failure set is not vague. `A` is reducible or imprimitive precisely when
`f_c` is simply or crossed renormalizable with `c-hat != 0`, or `c` is an
immediate satellite centre; and for beta-type Misiurewicz points `A` is
irreducible and primitive.[^4] Two consequences:

- The census must **partition** its box by that condition and report the classes
  separately. Filtering the awkward parameters out silently would turn a
  hypothesis into a selection effect, and the beta-type family is the clean
  subfamily where the screen applies as written.
- In the imprimitive case the characteristic polynomial factors as
  `x^k P(x^p)`.[^4] An irreducibility test on the raw characteristic polynomial
  will therefore correctly answer "reducible", and that answer must **not** be
  recorded as "not Pisot". It is a statement about the matrix's periodicity, not
  about the arithmetic of `lambda`. The screen already separates root location
  from irreducibility and refuses rather than guessing; the census has to respect
  that separation at the reporting layer too.

### 4. The Master Teapot is a different object, and the census must not claim it

The Thurston set and the Master Teapot are built from the **closure of the set of
Galois conjugates** of growth rates.[^3] [^6] The census asks, for one parameter
at a time, whether every conjugate of `lambda` lies strictly inside the unit
circle. Those are related — both concern conjugates against the unit circle, and
the Teapot literature studies exactly the persistence of roots inside it — but
they are not the same question, and one does not compute the other.

A finite census of individual parameters is a sample of the fiber. It is not an
approximation to a closure, and a picture produced from it is not a Teapot. This
note records the distinction in advance because it is the obvious way for the
write-up to overclaim.

### 5. Negative controls the census must carry

| Control | Case | What it catches |
| --- | --- | --- |
| Core entropy zero | `h = 0`, so `lambda = 1` | a Pisot number is `> 1`, so these are outside the question, not negative answers to it[^7] |
| The Chebyshev endpoint | `c = -2`, `lambda = 2` | a rational integer is trivially Pisot; reporting it as a find is an artefact |
| Satellite and renormalizable | `A` reducible or imprimitive | the screen's hypotheses fail; `x^k P(x^p)` reads as reducible for a reason unrelated to `lambda` |
| Beta-type Misiurewicz | `A` irreducible and primitive | the clean subfamily; if the census disagrees with the screen here, the census is wrong |
| Salem candidates | conjugates on the unit circle | Salem numbers exist below 2, so the screen's circle test is live rather than decorative |
| A known Pisot value | plastic constant, golden ratio | a reported Pisot hit below the golden ratio must appear on the Dufresnoy–Pisot list |

### 6. The screen is not reachable from here, and the fix is not extraction

A structural blocker, found by reading `vendored.toml` rather than the
literature. This repository vendors `finite_exact`, `claim_governance` and
`substitution_dynamics` from the kernels monorepo. It does **not** vendor
`finite_linear_algebra`, and the degree-`n` Pisot screen is not in the monorepo at
all — it lives in the Pisot repository, which this one does not vendor from.

So B8's prerequisite is delivered but unreachable from the repository that holds
the tree combinatorics.

**The first draft of this note then prescribed the wrong remedy.** It said
extraction to the kernels monorepo was the only policy-compliant route and
declared implementation unlicensed until that happened. This repository's own
extraction plan says the opposite: the shared library's scope explicitly excludes
Pisot tests, and PIP-specific predicates and characteristic-polynomial tests stay
in the Pisot repository, which "computes" while claims and certificate checklists
remain there.[^9] Extraction is therefore not merely *not the only* route; it is
the one route the stated plan rules out.

What is left, and the choice belongs to whoever writes the census:

1. run the census in the Pisot repository, which already holds the screen,
   consuming tree data exported from here;
2. compute the transition matrices here and export them, letting the
   classification happen where the screen lives;
3. extract only the general linear algebra, already a listed extraction
   candidate, and keep the Pisot predicate itself in the Pisot repository.[^9]

None of these is blocked. The observation that stands is narrow: the screen is
not callable from this repository today, so a census written here cannot classify
`lambda` without one of the arrangements above.

## What this gate licenses, and what it does not

1. **Licensed:** a census over a declared box of Misiurewicz types `(l, k)`,
   partitioned by whether `A_c` is primitive with irreducible characteristic
   polynomial, reporting root location where the screen decides and refusing
   where it does not.
2. **Not licensed:** any claim that Thurston's multimodal realisation settles the
   degree-two image. It does not, per finding 1; a finite census may report which
   values it observed, and may not report that set as characterised.
3. **Not licensed:** presenting the census, or any picture drawn from it, as the
   Thurston set or the Master Teapot. Those are closures of conjugate sets; this
   is a finite sample of a fiber.
4. **Not licensed:** reading "reducible characteristic polynomial" as "not Pisot"
   in the imprimitive case, where the factorisation `x^k P(x^p)` records the
   matrix's periodicity instead.
5. **Not licensed:** duplicating the screen into this repository. The vendoring
   policy forbids a second copy, and the extraction plan keeps the Pisot
   predicate in the Pisot repository, so the census must be arranged around
   finding 6 rather than around a copy.
6. **Not licensed:** reporting a Pisot hit below the golden ratio without checking
   it against the known list. In that range the answer is enumerated, so an
   unlisted hit is a defect until shown otherwise. Above the golden ratio no such
   list applies and the check must not be extended there.
7. **Not licensed:** narrowing the census population to the primitive subfamily.
   The screen's reach narrows; the population does not, or the result is a
   selection effect rather than a census.

## Sources

Retrieved 2026-09-17. Bibliographic detail is recorded as the sources present it; no PDF snapshots were imported, so nothing here is a verified snapshot.

[^1]: William P. Thurston, "Entropy in dimension one," in *Frontiers in Complex Dynamics*, Princeton University Press, 2014.
[^2]: Ethan Dickmann, Marissa Domat, Michael Hill, Sanghoon Kwak, Juliana Ospina, Priyam Patel and Alina Rechkin, "[Thurston's Theorem: Entropy in Dimension One](https://arxiv.org/abs/2209.15102)," arXiv:2209.15102. An expository modernisation; it states the weak Perron characterisation and supplies an ergodicity proof missing from the original.
[^3]: Harrison Bray, Diana Davis, Kathryn Lindsey and Chenxi Wu, "[The Shape of Thurston's Master Teapot](https://arxiv.org/pdf/1902.10805)," and "[A characterization of Thurston's Master Teapot](https://www.cambridge.org/core/journals/ergodic-theory-and-dynamical-systems/article/characterization-of-thurstons-master-teapot/A24092C6CDE1AEA04E7023E59C4D9224)," *Ergodic Theory and Dynamical Systems*.
[^4]: Wolf Jung, "[Core entropy and biaccessibility of quadratic polynomials](https://arxiv.org/abs/1401.4792)," arXiv:1401.4792. The row-sum bound `1 <= lambda <= 2`, the definition of the edge transition matrix, and Lemma 3.9.4 for exactly when `A` is reducible or imprimitive.
[^5]: [Pisot number](https://mathworld.wolfram.com/PisotNumber.html), Wolfram MathWorld, for the plastic constant as the smallest Pisot number (Salem 1944, Siegel 1944), closedness of the set (Salem 1944), the golden ratio as smallest limit point, and the Dufresnoy–Pisot 1955 enumeration below it.
[^6]: Giulio Tiozzo, "[Continuity of core entropy of quadratic polynomials](https://www.math.utoronto.ca/tiozzo/docs/continuity.pdf)," *Inventiones Mathematicae*, 2016; and Kathryn Lindsey, Giulio Tiozzo and Chenxi Wu, "[Master Teapots and Entropy Algorithms for the Mandelbrot Set](https://arxiv.org/abs/2112.14590)," arXiv:2112.14590, for the principal-vein analogues.
[^7]: "[Polynomials with core entropy zero](https://arxiv.org/abs/2205.13704)," arXiv:2205.13704.
[^8]: Giulio Tiozzo, "[Galois conjugates of entropies of real unimodal maps](https://arxiv.org/pdf/1310.7647)," arXiv:1310.7647, for the multimodal realisation of every weak Perron number, for the statement that fixing the degree makes the question subtler, and for the degree-two restrictions on attainable Perron numbers being the problem to describe.
[^9]: `docs/library-extraction-candidates-2026-09-14.md`, sections 3 and 4: the shared library's scope excludes Pisot tests, PIP-specific predicates and cubic characteristic-polynomial tests stay in the Pisot repository, and spectral claims stay there too.
