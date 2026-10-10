# Literature gate — ordered overlap affine pumps

## Proposed step

The proposed strict-zipper program was:

1. retain ordered child occurrences;
2. certify the affine recurrence `w'=Mw+q-p` and repeated-state pumps;
3. use recognizability and a non-unimodular internal representation to exclude
   every closed recurrent zero-shift-free component.

This review asks whether that sequence duplicates known machinery or silently
uses hypotheses unavailable for the swap-seed problem.

The collected bibliographic metadata and claim-level source annotations are
in `sources/issue-84/README.md`, with reusable BibTeX in
`sources/issue-84/references.bib`.

## Decision

**Proceed with the finite certificate, but redirect the next theorem step.**

The affine edge recurrence is established overlap-graph machinery, not a new
theorem. PR #91 remains useful because it specializes that machinery to the
repository's exact seed-patch graph, preserves the order and multiplicity of
actual prefix-grid occurrences, fails closed, and retains replayable pump
certificates. The next step should not jump directly from a repeated affine
state to an adelic contradiction. It should first prove a context/realization
bridge for occurrences in the iterated periodic swap patch.

## Findings

### 1. The affine overlap edge is prior art

Akiyama and Lee define the multiple edge between potential overlaps by an
affine update of the translation coordinate under expansion plus the
difference of child digit vectors. They explicitly state that retaining edge
multiplicity is essential for distinguishing real overlaps from potential
ones. Their residual/coincidence graph criterion compares spectral radii under
the Meyer hypothesis.[^1]

The one-dimensional prefix formula

```text
w' = M w + q - p
```

is the Parikh-coordinate specialization of that standard child-overlap
update. Therefore PR #91 should claim novelty only for:

- its application to the repository's swap-seed graph rather than a realized
  substitution-tiling overlap graph;
- preservation of geometric occurrence order, not merely type multiplicity;
- exact fail-closed replay and golden countermodels.

This also confirms that occurrence multiplicity must remain part of every
later spectral or pump argument.

### 2. Prefix-suffix automata are the natural address language

Canterini and Siegel encode primitive-substitution dynamics by paths in a
prefix-suffix automaton and relate those paths to the associated adic system.[^2]
That is the established language for the ordered prefix choices currently
stored as pump digits. A new context certificate should therefore be stated as
a paired prefix-suffix path with a finite collar, rather than as an unqualified
"affine state."

The useful research question is not whether the affine state repeats, but
whether the repeated paired path has the same admissible left and right
extensions in the periodic swap-patch hierarchy.

### 3. Recognizability supplies unique cuts, not pump deletion

Mossé recognizability, in the effective form of Durand and Leroy, gives a
computable local radius for recovering substitution cuts for primitive
aperiodic morphisms.[^3] It does **not** say that deleting a loop between two
equal affine states preserves a legal bi-infinite context, nor does it force a
common boundary between two distinct substituted configurations.

There is an additional hypothesis mismatch: the repository deliberately does
not require `ab` to be a legal language factor. A recognizability theorem on
the substitution subshift cannot be applied directly to the formal swap seed.
The correct object is the periodic tiling by `ab`, compared with its translate,
and its iterated substituted patches. A local context bridge must be proved for
that object before subshift recognizability can be invoked.

This is the main redirection produced by the review.

### 4. Non-unit geometry validates the warning, not the contradiction

Minervino and Thuswaldner construct Rauzy fractals for non-unit Pisot
substitutions in a representation space contained in an open subring of the
adele ring; finite-place factors are part of the geometry.[^4] This supports
the repository firewall against replacing the internal image by a Euclidean
stable lattice.

It does not provide the needed exclusion automatically. Tiling, separation,
or unique-representation conclusions in that framework have their own
hypotheses. PR #91 must therefore refer to the complete representation space
as a candidate setting, not to an already available "internal-space separation
property" for every PIP substitution.

### 5. Existing overlap theory suggests a nearer checkpoint

Akiyama--Lee's criterion treats the residual graph with edge multiplicities
and shows why a residual component containing real overlaps can carry full
expansion growth.[^1] Before constructing an adelic invariant, the cheaper
question is whether the seed-patch occurrence multigraph can be related to the
multiple-edge graph of the iterated periodic swap patch strongly enough to
transfer its growth accounting.

This does not identify the seed graph with the complete realized-overlap graph
of a substitution tiling. It asks for a narrower, seed-relative dictionary,
consistent with the Barge--Štimac--Williams periodic-patch bridge already used
in the manuscript.

## Revised next theorem program

1. **Periodic-patch context record.** Attach bounded left/right ancestry to
   every ordered overlap occurrence in `sigma^n(ab)` versus `sigma^n(ba)`.
2. **Recognizability checkpoint.** Use an explicit recognizability radius only
   after proving that the recorded context determines the relevant supertile
   cuts in those iterated patches.
3. **Pump compatibility test.** Test repeated affine states for equality of
   paired prefix-suffix context. Preserve the smallest mismatch as a golden
   countermodel; do not test loop deletion first.
4. **Seed-relative growth bridge.** Compare the occurrence multigraph and its
   multiplicities with the standard overlap multiple-edge construction.
5. **Non-unit representation step.** Invoke the full Archimedean/finite-place
   representation only for context-compatible survivors, with every imported
   tiling or separation hypothesis stated explicitly.

The first new executable after this review should therefore be a
**context-equality diagnostic**, not a general pump-deletion checker or a
Euclidean contraction test.

## Sources

[^1]: Shigeki Akiyama and Jeong-Yup Lee, “[Algorithm for determining pure pointedness of self-affine tilings](https://arxiv.org/abs/1003.2898),” *Advances in Mathematics* 226 (2011), 2855–2883, doi:10.1016/j.aim.2010.07.019. See especially the multiple-edge update (4.2), the requirement to retain multiplicities, and Theorem 4.1.
[^2]: Vincent Canterini and Anne Siegel, “[Automate des préfixes-suffixes associé à une substitution primitive](https://doi.org/10.5802/jtnb.327),” *Journal de Théorie des Nombres de Bordeaux* 13 (2001), 353–369.
[^3]: Fabien Durand and Julien Leroy, “[The constant of recognizability is computable for primitive morphisms](https://arxiv.org/abs/1610.05577),” *Journal of Integer Sequences* 20 (2017), Article 17.4.5.
[^4]: Milton Minervino and Jörg Thuswaldner, “[The geometry of non-unit Pisot substitutions](https://doi.org/10.5802/aif.2884),” *Annales de l’Institut Fourier* 64 (2014), 1373–1417; [arXiv:1402.2002](https://arxiv.org/abs/1402.2002).
