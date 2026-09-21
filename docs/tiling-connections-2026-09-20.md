# Tiling connections: what the estate can hand across, and the first thing handed

**Status:** research-direction note, dated 2026-09-20, carrying two theorems
of this repository -- section 2.2, that the partition is Markov, and section
3.3, which classifies the postcritically finite parameters of `Q(i)` -- and
the rung that computes what they describe (`tools/markov.py`,
`src/markov.mojo`, `tests/test_markov.py`). The note states a programme; the
theorems are unconditional and are not part of the programme's speculation.

## 0. The goal, stated so it can fail

The estate's question is whether the structures this repository computes
exactly have exact counterparts in other self-similar objects, and whether
the models themselves relate. "Relates to" is not a claim until it names the
two objects and the map between them, so this note admits a connection only
in the form:

> an object this repository produces exactly, a named kernel elsewhere in the
> estate that consumes exactly that type, and the statement that the two are
> the same object under a stated identification.

Anything weaker is listed in section 7 as a direction, not as a bridge.

## 1. The two sides, inventoried

**The tiling side lives in `larsbx/finite-math-kernels`.** What is built:

| Kernel | Object | Relevant operation |
| --- | --- | --- |
| `substitution_dynamics/substitution.mojo` | a substitution on a finite alphabet | `incidence()`, the letter-occurrence matrix |
| `substitution_dynamics/tuning.mojo` | tuning patterns, the star product | pattern to constant-length substitution |
| `substitution_dynamics/sadic.mojo` | finite directive prefixes | composite, determined kneading prefix |
| `substitution_dynamics/coincidence.mojo` | column coincidence | the predicate, for constant length |
| `substitution_dynamics/automaton.mojo`, `substitution_dynamics/words.mojo`, `substitution_dynamics/balanced_pairs.mojo`, `substitution_dynamics/discrepancy.mojo` | words and their automata | finite combinatorics |
| `finite_linear_algebra/mat3.mojo` | `3x3` integer matrices | `charpoly()`, `det`, `adjugate`, `has_rational_root` |
| `finite_linear_algebra/qlinalg.mojo` | exact rational matrices, any size | `rref`, `rank`, `nullspace`, `in_span` |
| `finite_linear_algebra/madic_ball.mojo` | `m`-adic balls | exact ball arithmetic |
| `finite_linear_algebra/qpoly.mojo` | exact polynomials over `Q` | division, gcd, squarefree part, root bound, Sturm chain, `largest_root_bracket`, `charpoly` in any dimension |

The last row is new, and it is this note's own doing: item 2 below named the
general-size characteristic polynomial and the largest-root isolation as
missing, and `docs/exact-polynomial-root-isolation-spec.md` in that
repository is the answer. It is vendored here as of 2026-09-21, pinned in
`vendored.toml` like every other package this repository borrows. What is still **not** built there is the Pisot
screen the ledger scope `primitive Pisot substitutions` is named for: no
module decides irreducibility, forms a minimal polynomial, or locates a root
by quadrance. The ledger records the scope; no module computes it.

**The dynamical side is this repository.** What is built and exact:
critical-orbit verdicts over `Q(i)` (`tools/julia_reference.py`), preperiodic
certificates and multiplicities (`docs/preperiodic-certificates.md`), rational
angles under doubling on `Q/Z` (`docs/angle-types-and-landing.md`), the
three-valued classifier and its refinement theorem
(`docs/enclosure-width-lemma.md`), the finite separator and the permanent
non-separation witness, real-axis ray certificates, Taylor models, and scaled
boxes.

The two sides share an arithmetic (`finite_exact`) and share nothing else.
This note is about the first object that can cross.

## 2. What crosses: the transition matrix

At a real parameter with a finite critical orbit the postcritical set cuts a
compact real interval into finitely many pieces, and which piece covers which
is a `0/1` matrix. That matrix is the type `Substitution.incidence()` returns
and the type `Mat3.charpoly()` consumes. It is the bridge, and it is exact
integer data with no approximation anywhere in its construction.

### 2.1 The objects

Let `c` be rational with a finite critical orbit and let

```text
P = {0} u {f^k(0) : k >= 1},      f(z) = z^2 + c
```

with elements `p_0 < p_1 < ... < p_m`, and `I_i = [p_(i-1), p_i]` for
`1 <= i <= m`. Define

```text
A[i][j] = 1  iff  I_j is contained in f(I_i),   else 0.
```

`tools/markov.py` computes `P`, the intervals, and `A` in exact rational
arithmetic; `src/markov.mojo` computes the same over `Q`, and
`tests/test_markov.py` compares the two transcripts.

### 2.2 Theorem (the partition is Markov, and `A` is its transition matrix)

**`P` is forward invariant and finite; `f` is monotone on each `I_i`; `f(I_i)`
is exactly the union of the `I_j` with `A[i][j] = 1`, a consecutive block; and
`[p_0, p_m]` is forward invariant.**

*Proof.* `f(0) = c` is in `P` and `f(f^k(0)) = f^(k+1)(0)` is in `P`, so `P`
is forward invariant, and it is finite by hypothesis.

`0` is an element of `P`, hence a partition point, hence never interior to an
`I_i`; `f` is monotone on each half-line bounded by `0`, so it is monotone on
`I_i` and `f(I_i)` is the interval with endpoints `f(p_(i-1))` and `f(p_i)`.

Both of those endpoints lie in `P` by forward invariance, so they are
partition points, so the interval between them is the union of the
consecutive `I_j` they bracket -- which is the set `A[i][j] = 1` picks out,
since an `I_j` with rational endpoints is contained in an interval with
rational endpoints exactly when the two inequalities `A` tests hold.

Finally `f(I_i)` has endpoints in `P`, hence inside `[p_0, p_m]`, for every
`i`. []

Nothing in that proof is a limit, an import, or an estimate. It is the reason
`0` is a partition point whether or not it is postcritical: a partition that
omits it is not one this theorem covers.

### 2.3 The identification, including its transpose

`Substitution.incidence()` in the kernels repository returns
`M[i][j] = occurrences of letter i in sigma(j)`: the **column** convention,
where a column is an image. `A` above is the **row** convention, where a row
is a source interval. The two are transposes. A transpose changes no
eigenvalue, so the growth quantity is the same; it does change which vector
is which, so a consumer that reads eigenvectors must transpose first. This
note records the convention difference because getting it wrong is silent.

## 3. What the bridge is worth over `Q(i)`: exactly five parameters

The obvious next question is how many parameters feed the bridge. Over this
repository's Phase 0 parameter domain the answer is a finite list, and it is
a theorem rather than a census.

### 3.1 Lemma (a non-integral parameter has an infinite critical orbit)

**Let `R` be `Z` or `Z[i]` and let `c = a/q` in its fraction field, in lowest
terms with `q` not a unit. Then the critical orbit is infinite.**

*Proof.* Write `z_n = f^(n-1)(c)`, so `z_1 = c = a/q`. Claim: `z_n = a_n /
q^(2^(n-1))` with `a_n` coprime to `q`. It holds at `n = 1`. If `z_n = a_n /
q^k` with `k >= 1` and `gcd(a_n, q) = 1`, then

```text
z_(n+1) = a_n^2 / q^(2k) + a / q = (a_n^2 + a q^(2k-1)) / q^(2k)
```

and `2k - 1 >= 1`, so the numerator is congruent to `a_n^2` modulo `q` and is
coprime to `q`. The exponent doubles, so the denominators are pairwise
distinct and so are the `z_n`. []

`Z[i]` is a unique factorisation domain, which is all the proof used of it.

### 3.2 Lemma (a large parameter escapes)

**If `N(c) > 4` then the critical orbit escapes**, where `N(x, y) = x^2 + y^2`.

*Proof.* `N(z_1) = N(c) > 4` and `N(z_1) >= N(c)`. Suppose `N(z_n) > 4` and
`N(z_n) >= N(c)`. Then `|z_(n+1)| >= |z_n|^2 - |c| >= |z_n|^2 - |z_n| =
|z_n|(|z_n| - 1)`, and `|z_n| > 2` gives `|z_n| - 1 > |z_n|/2`, so

```text
N(z_(n+1)) > N(z_n)^2 / 4 = N(z_n) * (N(z_n)/4) > N(z_n) > 4.
```

Both hypotheses are preserved and the quadrance grows by a factor above
`N(z_n)/4 > 1` at every step, so it is unbounded. []

The inequality is written with moduli for readability and is used only
through its squared form, which is the rational statement
`N(z_(n+1)) > N(z_n)^2 / 4`; no modulus is computed anywhere and no square
root is taken. It is the threshold form of `docs/escape-criterion.md` with
the one extra step that the threshold `max(4, N(c))` needs at `n = 1`.

### 3.3 Theorem (the postcritically finite parameters of `Q(i)`)

**`c` in `Q(i)` has a finite critical orbit exactly when**

```text
c in {0, -1, -2, i, -i}.
```

*Proof.* By 3.1 such a `c` lies in `Z[i]`; by 3.2 it satisfies `N(c) <= 4`;
there are thirteen such Gaussian integers, and
`tools/markov.py::gaussian_pcf_parameters` decides each by exact orbit
verdict. The five above are preperiodic and the other eight escape. []

The five are `0` (periodic, period 1), `-1` (period 2), `-2` (preperiod 2,
period 1), and `i`, `-i` (preperiod 2, period 2). Four of them are already
rows of `tools/parameter_corpus.py`; `-i` is the complex conjugate of the
dendrite parameter and is dynamically conjugate to it.

**Consequence for the bridge.** Only `-2`, `-1`, and `0` are real, and of
those `0` has a one-point postcritical set and no partition at all. The whole
of the Phase 0 parameter domain therefore supplies exactly **two**
transition matrices, of sizes `2` and `1`. Enriching the bridge is not a
matter of searching harder: it requires the **algebraic** half of the
roadmap's Phase 4, where `c` is a root of an exact integer polynomial rather
than an element of `Q(i)`.

It is specifically that half. Phase 4 also escalates `c` to an interval, and
that escalation cannot serve this bridge at all: section 2.1 needs the
postcritical set as points, sorted, and a finite critical orbit is detected
by an exact equality, which an enclosure does not decide -- overlap is never
equality. An interval parameter buys coverage of the parameter plane and
gives up the verdict this construction is built on. `ROADMAP.md` separates
the two escalations for that reason.

## 4. What the rung computes, and what came out

`tools/markov.py` and `src/markov.mojo`:

- `postcritical_points(c)` -- the sorted finite set `P`, or a refusal;
- `partition(c)` -- the intervals and `A`, or a refusal;
- `characteristic_polynomial(A)` -- `det(x I - A)` by Faddeev-LeVerrier,
  exact over `Q`, any size;
- `growth_bracket(p)` -- a pair of rationals at which `p` has opposite signs,
  bracketing *a* root in `[1, 2]`. Not the largest one: bisection converges to
  whichever root the sign changes lead it to. This is the Python oracle's
  method. `src/markov.mojo` asks the vendored `largest_root_bracket` instead,
  which isolates the largest by a Sturm chain, so the two are checked against
  the roots they should bracket rather than against each other.

Both sides refuse rather than guess. A parameter whose critical orbit neither
closes nor escapes -- every parabolic one, and by section 3.1 every
non-integral rational one -- makes the coordinates double in size at every
step, so the loop carries a budget as well as a step count. The budget is
counted in `BigZ` limbs, which are base `10^9`, so the Python oracle computes
the same quantity with one comparison and the two transcripts can be compared
rather than merely resemble each other. An exhausted budget returns no
partition; it never returns a partial one.

Measured:

| `c` | `P` | `A` | `det(x I - A)` | growth bracket |
| --- | --- | --- | --- | --- |
| `0` | `{0}` | -- | -- | no partition |
| `-1` | `{-1, 0}` | `(1)` | `x - 1` | `1` exactly |
| `-2` | `{-2, 0, 2}` | `((1,1),(1,1))` | `x^2 - 2x` | `[2097151/1048576, 2]` |

The bracket for `-2` is a bisection result, not a root: the polynomial has
opposite signs at its two endpoints, which is the whole of the claim. `2` is
in fact a root, and the bisection is not the thing that establishes that.

As a check on the polynomial routine against a matrix whose answer is not
from this repository, `((1,1),(1,0))` gives `x^2 - x - 1` and a bracket
around `1.618034`.

## 5. Why `-1` gives `1` and `-2` gives `2`, without importing entropy

The statement this repository can make is a count, and it needs no theory at
all. The number of admissible paths with `n` edges in the graph `A` describes
is the sum of the entries of `A^n`, by induction on `n`. At `c = -2`, where
`A` is the all-ones `2x2` matrix, that sum is `2^(n+1)`; at `c = -1`, where
`A` is `(1)`, it is `1`. Both are finite facts about a matrix, checked in
`tests/test_markov.py`.

Two further statements are available and are **not** made here. That the
Perron root is the exponential growth rate of that count is Perron-Frobenius;
it is standard, this repository does not restate it, and nothing above
depends on it. That the growth rate is the topological entropy of `f` on
`[p_0, p_m]` is the classical theory of Markov partitions and symbolic
dynamics; it would enter as a tag, `MarkovTransitionIsEntropy`, and **no such
tag has been opened, so nothing here may be read as an entropy statement**.

## 6. The Pisot question, stated exactly and answered degenerately

A **Pisot number** is a real algebraic integer above `1` all of whose other
conjugates have quadrance below `1`. Whether a substitution's incidence
matrix has a Pisot Perron root is the hypothesis under which the tiling
theory of the kernels repository's `primitive Pisot substitutions` scope
operates.

For the two matrices section 4 produces the question has an answer, and it is
degenerate in both directions.

At `c = -1` the matrix is `(1)` and its only root is `1`. A Pisot number is
above `1`, so `1` is not one, and there is nothing further to test.

At `c = -2` the characteristic polynomial is `x^2 - 2x = x (x - 2)` and the
largest real root is `2`. The minimal polynomial of `2` over `Q` is `x - 2`,
which has no other root, so the condition on the other conjugates holds
vacuously and **`2` is a Pisot number** -- trivially, as every rational
integer above `1` is. The root `0` of the characteristic polynomial is not a
conjugate of `2`; it belongs to a different minimal polynomial, and a screen
that tested the characteristic polynomial's roots instead of the minimal
one's would be testing the wrong set.

So the tiling question, over the whole of the Phase 0 parameter domain, comes
back: no growth at one parameter, a trivial Pisot number at the other. The
non-trivial question -- a Pisot root whose conjugates are a real constraint --
needs a transition matrix whose characteristic polynomial is irreducible of
degree at least `2`, and section 3 proves there is none over `Q(i)`. That is
a precise statement of what Phase 4 buys.

## 7. Candidate bridges, ranked by what each still needs

1. **Transition matrix to incidence matrix.** Built (section 2). Needs
   nothing. Exercised by two parameters.
2. **Perron root to Pisot screen.** Built as far as it goes. The
   characteristic polynomial in any dimension and `largest_root_bracket` are
   upstream in `finite_linear_algebra/qpoly.mojo`; as of this rung the
   package is vendored here and `src/markov.mojo` calls them instead of
   carrying its own copy of the first. `tools/markov.py` keeps its own of
   both, because it is the independent oracle and a differential pair with
   one implementation in it is not one. The two brackets answer different
   questions -- the oracle bisects a sign change and lands on whichever root
   that leads to, the kernel isolates the largest by a Sturm chain -- so
   neither is in the transcript the two compare, and each is checked against
   the root it is supposed to bracket. What is still missing is the Pisot
   condition itself: irreducibility, the minimal polynomial, and a
   root-location test by quadrance. None of the three exists anywhere in the
   estate.
3. **Kneading data to tuning substitution.** The parameter-plane program
   already computes tunings (`angle_tuning` in
   `larsbx/finite-mandelbrot-research`); the dynamical-plane counterpart is
   the itinerary of `tools/ray.py` against a separator. Needs the itinerary
   to be read as a word over the kernels' alphabet, which is a re-encoding,
   not new mathematics.
4. **Doubling on `Q/Z` to a constant-length substitution.** `tools/angle.py`
   computes preperiod and period of a rational angle exactly; the doubling
   map is the length-2 substitution the kernels model. Needs a statement of
   what the identification preserves, which is the part that is missing.
5. **`madic_ball` to anything here.** No identification found. Listed so that
   the absence is on the record rather than implied -- and it needs saying
   twice now, because item 2 vendored the package whole and the module is
   sitting in `src/finite_linear_algebra/` unused. That is a fact about how
   packages are vendored, not a connection.

## 8. Rendering, and the doctrine it inherits

`docs/atlas-dataset.md` in `larsbx/finite-mandelbrot-research` settled this
already and the settlement transfers: the exact objects are emitted once, by
the canonical module, and a consumer that wants to draw them computes its own
positions and says so. Positions are conventional layout; the audit there
fails if a float reaches an emitted section.

For this bridge the emitted objects are `P`, `A`, the characteristic
polynomial, and the growth bracket -- all exact integers and rationals. A
drawing of the partition is a drawing of a layout choice. It proves nothing,
and the note says so here so that a later picture cannot be mistaken for
evidence.

## 9. What this note does not claim

It does not claim an entropy, a measure, or a spectrum. It does not claim
that any Julia set is a tiling, is self-similar in the substitution sense, or
carries a substitution system; it claims that one matrix computed here has
the same type as one matrix computed there, and section 2.2 proves what that
matrix is. It takes no theorem tag and discharges no block of
`docs/J1_proof_definition.md`. Section 3 is a classification of a parameter
domain, not of dynamics: it says which `c` in `Q(i)` are postcritically
finite, and nothing about what the corresponding Julia sets are.
