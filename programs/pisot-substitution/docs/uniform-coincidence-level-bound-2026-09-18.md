# Uniform strong-coincidence level bound: first gate

**Status:** proved conditional mathematical bound, executable on the shared
powered-field kernel's stated domain, plus a proved negative control for two
naive uniformizations. This note does **not** prove strong
coincidence for the ternary irreducible Pisot family, seedwise overlap
productivity, Open Problem 5.35, or the Pisot substitution conjecture.

Primary target: issue #84. Dependencies: the exact affine coincidence
automaton introduced in PR #122 and the hypothesis firewall summarized in the
issue.

## 1. Proposed uniform statement

Let (A_{\sigma,i,j}) be the reachable deterministic affine automaton whose
states are ((a,b,\delta)), with

[
\delta' = M_\sigma\delta+
  \pi(\text{top proper prefix})-
  \pi(\text{bottom proper prefix}).
]

The intended target is a constant (B_3), independent of the ternary PIP
substitution, such that whenever a pair has a strong coincidence, its least
coincidence level is at most (B_3). A stronger useful target would also prove
that every pair language is nonempty.

## 2. What the existing automaton proves

Write C(sigma,i,j) for the forward-reachable states from which an accepting
state is reachable (the coaccessible core).

**Proposition 2.1 (fixed-substitution graph bound).** If
(L(A_{\sigma,i,j})\neq\varnothing), then its least accepted word has length
at most (|C_{\sigma,i,j}|-1).

**Proof.** Breadth-first search returns a shortest accepting run. Such a run
cannot repeat a state: deleting the segment between two occurrences would give
a shorter run with the same endpoint. Every state on it can reach the accepting endpoint, so it lies in the
coaccessible core. The run uses each such state at most once. ∎

Consequently, if

[
R(\sigma)=\max_{i<j}|C_{\sigma,i,j}|,
]

and all three pair languages are nonempty, the strong-coincidence level is at
most (R(\sigma)-1). Canonical executable support is
`kernel/psc/coincidence_level_bound.mojo`. The proposition is graph-theoretic and
has no height hypothesis. The present executable inherits
`powered_field`'s incidence-entry ceiling of 64; an input beyond that ceiling
raises and is inconclusive rather than false.

This separates two uncontrolled obligations:

1. **nonemptiness:** prove each pair language is nonempty; the finite-state
   argument does not do this;
2. **uniform size:** bound (R(\sigma)) independently of (\sigma);
3. **executable arithmetic domain:** remove or replace the current fixed-width
   powered-field entry ceiling before claiming a family-wide implementation.

Even a uniform bound for the conditional depth would not by itself establish
Issue #84. It would become useful only together with a uniform nonemptiness or
finite-reduction argument.

## 3. Parameters exposed by the spectral proof

The finiteness proof bounds the expanding coordinate using

[
\frac{\max_t |v^Tt|}{\beta-1}
]

and each contracting coordinate using

[
\frac{\max_t |u_r^Tt|}{1-|\beta_r|}.
]

Turning these coordinate bounds into an integer-state count additionally uses
the covolume/conditioning of the eigenbasis. Thus the direct estimate presently
depends on:

- the proper-prefix translation set (T_\sigma);
- the Perron and conjugate spectral gaps;
- the eigenbasis conditioning (equivalently, a discriminant/covolume control);
- the exact intersection of the resulting spectral box with
  (\mathbb Z^3).

The first and third items cannot be replaced silently by a fixed image-length
or bounded-entry assumption; neither assumption belongs to the standing
regime.

## 4. Exact negative control: unbounded height inside the regime

For every integer (n\ge3), define

[
\sigma_n(0)=1,\qquad \sigma_n(1)=2,\qquad
\sigma_n(2)=0\,2^n.
]

Its incidence matrix is

[
M_n=\begin{pmatrix}0&0&1\\1&0&0\\0&1&n\end{pmatrix},
qquad
\chi_n(x)=x^3-nx^2-1.
]

This is a primitive unimodular irreducible Pisot family:

- primitivity follows from the directed 3-cycle and the loop at (2);
- (det M_n=1);
- the only possible rational roots of (chi_n) are (pm1), and neither is
  a root for (n\ge3), so the cubic is irreducible;
- its discriminant is (-4n^3-27<0), so the two non-Perron roots are a complex
  conjugate pair;
- the positive root satisfies (\beta_n>n), and the product of the conjugate
  pair is (1/\beta_n), hence each has modulus
  (\beta_n^{-1/2}<1).

But (max_a|\sigma_n(a)|=n+1) and the height of (M_n) is (n). Therefore
neither bounded image length nor bounded incidence entries can be inserted as
a hidden compactness premise, even on the unimodular branch. This does **not**
prove that (R(\sigma_n)) is unbounded; it proves only that a uniform estimate
must exploit cancellation or arithmetic structure beyond those raw bounds.
The Mojo regression checks representative family members through incidence
entry 63 solely to guard this encoding, and checks that member 65 is explicitly
refused by the present field kernel. That refusal is an implementation boundary,
not a restriction on the proved algebraic family.


## 5. Height cancellation occurs in this family

The same family is not a counterexample to a uniform coincidence level.
For every n at least 3 it has explicit balanced-prefix witnesses:

- pair (1,2), level 3, position 3: the two words begin with `1022...`
  and `2102...`; both prefixes have Parikh vector (1,1,1), and both
  position-3 letters are 2;
- pair (0,1), level 4, position 3: this is the preceding witness after using
  `sigma^4(0)=sigma^3(1)`;
- pair (0,2), level 4, position n+4: both prefixes have Parikh vector
  (2,1,n+1), and both letters at that position are 2.

Thus the strong-coincidence level is at most 4 throughout this unbounded-height
family. This is a genuine cancellation result: raw digit and matrix height grow,
but the needed balanced-prefix pattern does not. It does not imply a bound for
arbitrary ternary PIP substitutions. The Mojo regression reconstructs the
inflated words and checks these witnesses for representative n; the displayed
word identities are the proof for all n.

## 6. Literature stop/go decision

Barge's two-letter theorem proves strong coincidence in degree two, but does
not provide the desired ternary quantitative bound. Arnoux--Ito formulate the
strong-coincidence condition used here. Akiyama--Lee and Akiyama clarify the
relationship between strong and overlap coincidence under their stated
hypotheses; they do not supply a substitution-independent coincidence level
for all ternary PIP substitutions. The automata/numeration literature supplies
finite-state constructions for a fixed Pisot system, with the system fixing the
digit set and machine.

**Decision: proceed narrowly.** The graph bound is valid and worth recording,
but the next theorem must bound the spectral lattice-point count through
arithmetic invariants of irreducible cubic Pisot matrices. Do not run a larger
short-image census as a substitute. First test whether the characteristic
polynomial coefficients and the prefix-translation set admit a cancellation
that removes matrix height; otherwise retain a parameterized theorem.

Primary sources:

- M. Barge, “Coincidence for substitutions of Pisot type,” *Bull. Soc. Math.
  France* 130 (2002), 619–635.
- P. Arnoux and S. Ito, “Pisot substitutions and Rauzy fractals,” *Bull. Belg.
  Math. Soc. Simon Stevin* 8 (2001), 181–207.
- S. Akiyama and J.-Y. Lee, “Overlap coincidence to strong coincidence in
  substitution tiling dynamics,” *European J. Combin.* 39 (2014), 233–243.
- S. Akiyama, “Strong coincidence and overlap coincidence,” arXiv:1509.04471.

## 7. Theorem/non-claim boundary

Repository-proved:

- Proposition 2.1 with the exact coaccessible core, which is never larger
  than the full reachable affine state set;
- the algebraic PIP/unimodular properties of the family (\sigma_n);
- unbounded image length and matrix height in that family;
- a strong-coincidence upper bound of 4 for that family, by the explicit
  balanced-prefix witnesses above.

Not proved:

- a family-wide executable beyond the current powered-field entry ceiling;
- a uniform bound on (R(\sigma));
- a uniform bound on the least coincidence level;
- nonemptiness of every pair language;
- overlap productivity or PSC.

No legality-of-`ab`, finite injectivity, unique decodability, unimodularity,
Euclidean-only internal space, global-realization, or census-completeness
hypothesis is added.
