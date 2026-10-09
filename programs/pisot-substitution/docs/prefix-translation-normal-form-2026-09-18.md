# Prefix-translation recurrence normal form: stop/go gate

**Status:** exact algebraic reduction and negative control. This note does **not**
prove a substitution-independent coincidence-level bound, nonemptiness of any
previously undecided coincidence language, strong coincidence for the ternary
irreducible Pisot family, seedwise overlap productivity, or the Pisot
substitution conjecture.

Primary target: issue #84. This is the next direct-bound slice after PRs #125
and #127.

## 1. Question

For a substitution with incidence matrix \(M\), the affine coincidence
automaton evolves by

\[
\delta_{r+1}=M\delta_r+t_r,\qquad
t_r\in T_\sigma,
\]

where \(T_\sigma\) is the finite set of differences of proper-prefix Parikh
vectors. PR #127 reduced the conditional coincidence-level problem to bounding
the coaccessible core of this automaton.

The proposed next step was to reduce every prefix translation modulo the
characteristic recurrence. The reduction is valid, but the coefficients and
digits are not uniform over the standing ternary PIP family.

## 2. Exact cubic normal form

Write

\[
\chi_M(X)=X^3-c_2X^2-c_1X-c_0.
\]

Define integer triples \(r_m=(a_m,b_m,d_m)\) by

\[
r_0=(1,0,0),\quad r_1=(0,1,0),\quad r_2=(0,0,1),
\]
\[
r_{m+3}=c_2r_{m+2}+c_1r_{m+1}+c_0r_m.
\]

**Proposition 2.1 (characteristic-recurrence normal form).** For every
\(m\geq0\),

\[
M^m=a_mI+b_mM+d_mM^2.
\]

Consequently, a length-\(k\) affine path starting at zero has

\[
\delta_k
 =\sum_{r=0}^{k-1}M^{k-1-r}t_r
 =A_k+MB_k+M^2D_k,
\]

where

\[
(A_k,B_k,D_k)
 =\sum_{r=0}^{k-1}
   (a_{k-1-r}t_r,b_{k-1-r}t_r,d_{k-1-r}t_r)
\]

are integer vectors.

**Proof.** Cayley–Hamilton gives
\(M^3=c_2M^2+c_1M+c_0I\). The three initial identities are immediate, and
multiplication by \(M\) gives the displayed recurrence. Substitution into the
unrolled affine recurrence proves the second statement. ∎

This is an exact integral normal form. It introduces no diagonalizability,
unimodularity, legality, finite-injectivity, recognizability, or Euclidean-only
internal-space hypothesis.

## 3. Why this is not a finite reduction

The map

\[
(A,B,D)\longmapsto A+MB+M^2D
\]

has a large kernel. Bounding the represented state \(\delta\) in its three
algebraic embeddings does not separately bound the nine integer coordinates
of \((A,B,D)\). Conversely, bounding the recurrence coefficients requires
control of \(c_0,c_1,c_2\), which is not supplied by the PIP hypothesis.

Thus the normal form becomes a finite reduction only after supplying a
canonical representative theorem with a substitution-independent bounded
fundamental domain, or an equivalent uniform separation/covolume statement.
Neither is proved here.

## 4. Exact negative control

For

\[
\sigma_n(0)=1,\qquad \sigma_n(1)=2,\qquad
\sigma_n(2)=0\,2^n\quad(n\geq3),
\]

the incidence characteristic polynomial is

\[
\chi_n(X)=X^3-nX^2-1.
\]

Hence the recurrence coefficient \(c_2=n\) is unbounded. Moreover, proper
prefixes of \(\sigma_n(2)\) have Parikh vectors

\[
0,\ e_0,\ e_0+e_2,\ldots,e_0+(n-1)e_2,
\]

so the prefix-translation alphabet also has unbounded coordinate height.

Nevertheless PR #125 proved explicit balanced-prefix witnesses for every
letter pair by level four. Therefore neither a uniform bound on the raw
characteristic coefficients nor a uniform bound on the raw digit height is a
necessary intermediate theorem. Any successful uniform argument must exploit
cancellation, a canonical quotient, or coaccessibility more directly.

This family does **not** show that the coaccessible-core size is unbounded.

## 5. Parameters that remain genuinely uncontrolled

After this reduction, a direct cardinality estimate still has four distinct
inputs:

1. the image of \(T_\sigma\) in the chosen canonical quotient;
2. the Perron completion reserve, including the factor
   \((\beta-1)^{-1}\);
3. the contracting reserves, including
   \((1-|\beta_2|)^{-1}\) and \((1-|\beta_3|)^{-1}\);
4. the separation/covolume needed to count integer states in the resulting
   spectral region.

The negative control above establishes that raw characteristic and digit
height cannot replace item 1. It does not yet establish logical independence
of items 2–4. Those dependencies remain named obligations, not assumptions and
not claims of necessity.

## 6. Closest affine-overlap construction

Akiyama–Lee, *Algorithm for determining pure pointedness of self-affine
tilings* (2011), is the closest prior construction. Its equation (4.2) updates
an overlap translation by the expansive map plus a difference of child digits,
the same algebraic pattern specialized here to

\[
\delta' = M\delta+
 \pi(\text{top proper prefix})-
 \pi(\text{bottom proper prefix}).
\]

The following transfers:

- the affine child-update form;
- the need to retain multiple edges when distinct child occurrences have the
  same endpoint state;
- the possibility that a residual real-overlap component carries the full
  expansion spectral radius.

The following does **not** transfer automatically:

- its graph is the potential-overlap graph of a globally realized self-affine
  tiling, while issue #84 also uses formal periodic swap seeds and does not
  assume that \(ab\) is a legal factor;
- its residual spectral-radius criterion uses the Meyer property and the
  complete overlap construction;
- neither that theorem nor the fixed-substitution finiteness of potential
  overlaps supplies a substitution-independent bound on the number of
  coaccessible affine states;
- it therefore cannot turn Proposition 2.1 into a uniform coincidence-level
  bound or prove seedwise overlap productivity.

Accordingly the affine recurrence is prior structure, not a novelty claim. The
new point of this note is only the cubic integral specialization and the exact
identification of why it fails to be a uniform finite reduction.

## 7. Stop/go decision

**Proceed, narrowed.** Do not pursue a bound on the unreduced recurrence
coefficients. Do not infer a strict residual spectral-radius inequality merely
from noncoincidence or boundary language. The next admissible target is one of:

- a canonical quotient or representative theorem for coaccessible
  translations whose bounds are invariant under the large kernel above; or
- an exact parametric family separating one of the spectral-gap,
  conditioning, and lattice-separation dependencies.

A computation may measure candidate canonical representatives, but finite
corpus evidence cannot certify a family-wide fundamental domain.

## 8. Literature boundary

The closest construction and exact transfer boundary are:

- S. Akiyama and J.-Y. Lee,
  [“Algorithm for determining pure pointedness of self-affine tilings”](https://arxiv.org/abs/1003.2898),
  especially equation (4.2) and Theorem 4.1;
- the repository's claim-level source record at
  sources/issue-84/README.md.

Canterini–Siegel supplies the established prefix-suffix address language:
V. Canterini and A. Siegel,
[“Automate des préfixes-suffixes associé à une substitution primitive”](https://doi.org/10.5802/jtnb.327).

The modern automata treatment confirms that Pisot-related Dumont–Thomas
addition is finite-state for a fixed system, not uniformly bounded over all
substitutions:
O. Carton, J.-M. Couvreur, M. Delacourt, and N. Ollinger,
[“Addition in Dumont–Thomas Numeration Systems in Theory and Practice”](https://arxiv.org/abs/2406.09868).

The relation between strong and overlap coincidence has additional stated
hypotheses and does not provide the missing uniform cardinality estimate:
S. Akiyama and J.-Y. Lee,
[“Overlap coincidence to strong coincidence in substitution tiling dynamics”](https://arxiv.org/abs/1403.0377);
S. Akiyama,
[“Strong coincidence and overlap coincidence”](https://arxiv.org/abs/1509.04471).

## 9. Hypothesis firewall

No legality of \(ab\), finite injectivity, unique decodability,
prefix/suffix-permutation condition, unimodularity, discreteness of a stable
projection, Euclidean-only internal space, global realization, or
census-completeness assumption is introduced.
