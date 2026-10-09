# Issue #139 literature gate: strict-zipper hitting in the non-unit PIP case

**Status:** literature baseline and stop/go decision.  
**Target:** issue #139, the strict-zipper branch of manuscript Open Problem 5.35.  
**Decision:** **proceed, but only with the narrowed adelic hitting theorem stated in §7.** None of the sources below proves that theorem. No result in this note proves overlap coincidence, balanced-pair termination, pure discrete spectrum, or the Pisot substitution conjecture for the standing non-unimodular PIP class.

## 1. Exact question and hypothesis firewall

Let (sigma) be a primitive irreducible Pisot substitution with incidence matrix (M), Perron root (\beta), and ordered prefix-digit set (F). For a bad closed recurrent overlap component (S) with no offset-zero vertex, a cycle of length (r) has an offset (w) satisfying
[
 (I-M^r)w=\sum_{k=0}^{r-1}M^{r-1-k}d_k,\qquad d_k\in F.
]
Thus its contracting representation is purely periodic. The required hit is
[
 \exists m\ge 0:\quad M^m w\in P_m(i)-P_m(j). \tag{H}
]
where (P_m(a)) is the set of Parikh vectors of prefixes of (sigma^m(a)).

The standing class permits (|det M|>1). Accordingly:

- the internal space is not silently replaced by the real contracting space;
- no discrete stable lattice, compact torus, or inverse (M^{-1}) over (mathbb Z^d) is assumed;
- strong coincidence, geometric coincidence, overlap coincidence, property (F), tiling by subtiles, and pure discrete spectrum remain distinct predicates;
- a multiple tiling or a boundary/interior statement is not promoted to the pointwise membership (H);
- the finite 4,554-specimen census is calibration, not a uniform theorem.

## 2. Transfer matrix

| Source | Actual hypotheses/mechanism | What transfers | What does not transfer |
| --- | --- | --- | --- |
| Ito–Rao (2006) | Irreducible **Pisot unit** substitution; Euclidean atomic surfaces; super-coincidence | Prefix-suffix graph-directed equations, the idea that coincidence is expressed as an intersection/equality of subtile pieces, and a model for turning digit expansions into geometric membership | The unit lattice, Euclidean-only contracting representation, and any implication that a periodic contracting address must hit a prefix-difference set in the non-unit case |
| Barge–Kwapisz (2006) | **Unimodular** Pisot substitution; geometric realization through a hyperbolic toral automorphism/stable foliation | The distinction between geometric coincidence and pure discrete spectrum; the contrapositive picture in which persistent noncoincidence survives in a residual geometric object | The toral/lattice realization when (M) is not unimodular; Cor. 9.4 or Prop. 17.2 cannot be cited with the word “unimodular” deleted |
| Akiyama–Lee (2011) | Repetitive primitive self-affine tiling, finite local complexity/representability, Meyer return set; overlap graph | The overlap algorithm and its completeness for deciding overlap coincidence; if coincidence fails, the residual noncoincident graph is Perron-critical (Theorem 4.1), explaining (\rho(N_S)=\beta) in dimension one | It detects a residual component but supplies no theorem forcing a particular periodic offset into (P_m(i)-P_m(j)); Perron-criticality is not a contradiction |
| Minervino–Thuswaldner (2014) | Irreducible non-unit Pisot substitution with a fixed point; representation space built from contracting Archimedean places and finite places dividing ((\beta)) | The correct adelic internal space, diagonal embedding, graph-directed Rauzy subtiles, compactness/local finiteness, and the non-Archimedean coordinates lost by Euclidean projection | A general coincidence theorem, property (F), exclusive tiling, or the pointwise hit (H). Their geometry repairs the ambient space, not the missing recurrence/coverage implication |
| Barge (2016) | Primitive, nonperiodic, Pisot inflation; injective on initial letters and constant on final letters | A genuine PDS theorem for a proper subclass, driven by special endpoint/branch structure | No transfer to arbitrary PIP substitutions or arbitrary strict-zipper SCCs lacking those endpoint hypotheses |
| Barge (2018) | The special combinatorics of (\beta)-substitutions for Pisot (\beta) | A non-unit-capable proof that pure discrete spectrum can be obtained by exploiting a class-specific quotient/geometric mechanism | Not a general theorem for all irreducible Pisot substitutions and not a generic periodic-address hitting lemma |

The machine-readable version is in
`schemas/p1b-strict-zipper-transfer-matrix.json`; its regression test rejects
silent removal of the unit/unimodular and class-specific hypotheses.

## 3. Ito–Rao: useful dictionary, non-transferable closure step

Ito and Rao construct atomic surfaces from the prefix automaton and introduce
super-coincidence in the irreducible Pisot **unit** setting. This gives the
closest dictionary to issue #139: ordered prefix digits generate a
graph-directed compact set, and coincidence becomes geometric intersection
with matching symbolic data.

The importable part is structural:

1. represent a cycle address by the corresponding eventually/purely periodic
   digit series;
2. locate that series in a graph-directed subtile;
3. express a prefix coincidence as membership in an appropriate translated
   subtile intersection.

The obstruction is exactly the one issue #139 records. Unit norm makes the
contracting realization Euclidean and keeps the relevant arithmetic module
lattice-like. If (|N(\beta)|=|det M|>1), multiplication by (\beta) is not
invertible on that lattice and finite places over primes dividing ((\beta))
carry missing information. The super-coincidence theorem therefore cannot be
used as a non-unit hit-forcing result.

**Import status:** dictionary only; not a closure theorem.

## 4. Barge–Kwapisz: the cited converse remains unimodular

Barge–Kwapisz build geometric realization for unimodular Pisot substitutions
using the stable/unstable geometry of a hyperbolic toral automorphism. Their
geometric-coincidence framework is legitimately relevant to the manuscript's
converse direction: failure of coincidence has a persistent geometric
manifestation, and geometric coincidence is tied to almost-everywhere
one-to-one realization/pure discrete spectrum.

What cannot be transferred is the carrier of the argument. For
(|det M|>1), the integer endomorphism is not a toral automorphism. Replacing
the missing inverse directions by the real stable space alone identifies
points that remain distinct at the finite places. Thus the manuscript may cite
Corollary 9.4 and Proposition 17.2 only with their unimodular hypotheses and
only for the implication actually stated there.

In particular, neither result says:

> every finite purely periodic contracting address arising from a closed
> noncoincident SCC meets a prefix-difference set.

That sentence would be the missing theorem, not a consequence of the cited
converse.

**Import status:** unimodular comparison theorem; hypothesis does not transfer.

## 5. Akiyama–Lee: complete algorithm, but no hit forcing

Akiyama–Lee's overlap algorithm is the strongest directly transferable
result. A one-dimensional irreducible Pisot substitution tiling has a Pisot
family expansion and hence a Meyer return set under the standard legal,
representable tiling hypotheses. The finite overlap graph is therefore a
complete decision object for overlap coincidence.

Theorem 4.1 gives the relevant dichotomy in graph-growth form: the
coincidence-reaching part has strictly smaller spectral radius than the full
inflation rate exactly when overlap coincidence holds; otherwise the residual
noncoincident part carries the full rate. In the present one-dimensional
notation this validates, rather than contradicts,
[
 \rho(N_S)=\beta
]
for the hard residual component.

This does **not** provide a uniform depth at which (H) must occur. The
algorithm terminates for a fixed substitution because its overlap classes are
finite; it does not turn the size of an arbitrary bad SCC or a periodic address
into a substitution-independent hitting bound. Nor does it prove that strong
coincidence eliminates every residual overlap component in the present
general class.

**Import status:** full diagnostic theorem under its tiling/Meyer hypotheses;
no pointwise or uniform hit theorem.

## 6. Minervino–Thuswaldner and Barge: what the non-unit theory repairs

Minervino–Thuswaldner replace the incomplete Euclidean stable space by a
representation space
[
 K_\sigma=K_\infty\times K_{\mathrm{fin}},
]
where (K_infty) contains the contracting Archimedean embeddings and
(K_{mathrm{fin}}) contains the completions at prime ideals dividing
((\beta)). In this product multiplication by (\beta) is contracting in
every internal coordinate. Prefix expansions define compact Rauzy subtiles
and admit graph-directed equations compatible with the substitution.

This transfers decisively: the projected offset in issue #139 must be the
full diagonal/adelic representation (Phi'(w)), not merely its real
contracting coordinates. It also supplies the right topology in which to ask
for recurrence or coverage.

But compactness, multiple tiling, and graph-directed invariance do not imply
that a specified periodic point belongs to a specified difference of finite
prefix sets. Boundary multiplicity is especially insufficient: an
almost-everywhere covering theorem cannot decide one distinguished periodic
point.

Barge's class theorems show two valid ways extra structure can close the gap:

- endpoint rigidity (initial-letter injectivity and a common final letter);
- the special quotient/combinatorics of (\beta)-substitutions.

Those mechanisms are positive controls. They are not properties of arbitrary
PIP substitutions and must not be abstracted away as “Pisot inflation alone.”

**Import status:** full ambient-space correction plus class-specific positive
controls; no general strict-zipper closure.

## 7. Exact residual theorem obligation

After all transferable results are imported, issue #139 reduces to the
following statement.

### Adelic periodic-offset hitting theorem (open)

Let (sigma) be a primitive irreducible Pisot substitution, not assumed
unimodular, satisfying the repository's standing legality/realizability
hypotheses and the strong-coincidence dependency isolated in P1a. Let (S)
be a finite closed recurrent component of the realized ordered-overlap graph.
Assume:

1. (S) contains no offset-zero vertex;
2. every vertex of (S) is represented by an actual overlap occurrence;
3. every cycle address in (S) satisfies the exact affine cycle equation;
4. the associated address has no vanishing tail.

Then one must prove, uniformly in (|S|), that some vertex
((i,j,w)in S) and some (mge0) satisfy
[
 M^m win P_m(i)-P_m(j).
]

Equivalently, in the full Minervino–Thuswaldner representation space, the
adelic image of at least one periodic offset orbit must meet the cylinder/subtile
difference corresponding to an actual common prefix boundary.

“Uniformly in (|S|)” means either:

- a bound (mle B(sigma,mathcal D)) independent of the chosen SCC and
  derived from stated substitution data; or
- a compactness/recurrence theorem which proves existence without enumerating
  progressively stronger necessary conditions.

A theorem only asserting compactness, accumulation, positive measure,
multiple covering, Perron-critical growth, or a lower bound on first-hit depth
does not discharge this obligation.

## 8. Stop/go decision

**Stop** the following routes unless a missing implication is first proved:

- Euclidean contracting projection alone for (|det M|>1);
- importing super-coincidence or geometric coincidence without unit or
  unimodular hypotheses;
- treating (\rho(N_S)=\beta) as a contradiction;
- adding collars, congruences, or cycle identities as another necessary layer
  without a completeness or uniformity theorem;
- inferring a pointwise hit from an almost-everywhere tiling statement.

**Proceed** with one narrowed route:

1. encode each realized cycle offset in the full adelic representation space;
2. identify the exact graph-directed subtile-difference cylinder representing
   (H), including finite-place coordinates;
3. seek a recurrence/coverage lemma for the *finite set of periodic offset
   orbits of a closed realized SCC*;
4. require the lemma to yield the uniform existence statement in §7;
5. preserve the determinant-two affine pump and the nonseparating collar
   specimen as negative controls.

No theorem-facing Mojo instrumentation is authorized by this note until step 2
has a mathematically specified predicate and step 3 has a proposed complete
statement. When that exists, the implementation must be Mojo-first, exact, and
replayable under `AGENTS.md`.

## 9. Primary sources

1. Shunji Ito and Hui Rao, “Atomic surfaces, tilings and coincidence I.
   Irreducible case,” *Israel Journal of Mathematics* 153 (2006), 129–155.
   [doi:10.1007/BF02771781](https://doi.org/10.1007/BF02771781).
2. Marcy Barge and Jarosław Kwapisz, “Geometric theory of unimodular Pisot
   substitutions,” *American Journal of Mathematics* 128 (2006), 1219–1282.
   [doi:10.1353/ajm.2006.0035](https://doi.org/10.1353/ajm.2006.0035).
3. Shigeki Akiyama and Jeong-Yup Lee, “Algorithm for determining pure
   pointedness of self-affine tilings,” *Advances in Mathematics* 226 (2011),
   2855–2883.
   [doi:10.1016/j.aim.2010.07.019](https://doi.org/10.1016/j.aim.2010.07.019).
4. Milton Minervino and Jörg Thuswaldner, “The geometry of non-unit Pisot
   substitutions,” *Annales de l'Institut Fourier* 64 (2014), 1373–1417.
   [doi:10.5802/aif.2884](https://doi.org/10.5802/aif.2884).
5. Marcy Barge, “Pure discrete spectrum for a class of one-dimensional
   substitution tiling systems,” *Discrete and Continuous Dynamical Systems*
   36 (2016), 1159–1173.
   [arXiv:1403.7826](https://arxiv.org/abs/1403.7826).
6. Marcy Barge, “The Pisot conjecture for (\beta)-substitutions,”
   *Ergodic Theory and Dynamical Systems* 38 (2018), 2009–2034.
   [arXiv:1505.04408](https://arxiv.org/abs/1505.04408).
