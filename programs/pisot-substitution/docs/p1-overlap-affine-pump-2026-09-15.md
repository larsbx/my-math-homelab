# P1 overlap productivity — ordered affine-pump certificate

**Status:** repository-proved finite recurrence lemma plus exact diagnostic.
This note does **not** prove seedwise overlap productivity, exclude a closed
strict-zipper component, or prove the Pisot substitution conjecture.

Primary target: issue #84 / manuscript Open Problem 5.35.  Dependency: the
ordered prefix-grid occurrence dictionary of PR #89.

## 1. Occurrence-labelled recurrence

Represent the offset of an overlap `O=(i,j,<w,l>)` by its unique integer
coordinate `w`.  If an actual child occurrence uses the child of `sigma(i)`
following the proper prefix with Parikh vector `p` and the child of `sigma(j)`
following the proper prefix with Parikh vector `q`, then its offset coordinate
is

```text
w' = M w + q - p.                                      (1)
```

The occurrence label is the ordered tuple

```text
(top child index, bottom child index, occurrence ordinal).
```

It is essential: two occurrences can have the same child overlap type while
coming from different prefix-grid cells.  The state graph alone therefore
does not determine the ordered forcing sequence `q-p`.

### Lemma 1 (ordered affine cycle identity)

Let `O_0 -> O_1 -> ... -> O_r=O_0` be a cycle of actual child occurrences,
with ordered prefix forcing vectors `d_k=q_k-p_k`.  Then

```text
w_(k+1) = M w_k + d_k

(I - M^r) w_0 = sum_(k=0)^(r-1) M^(r-1-k) d_k.         (2)
```

Conversely, replaying the occurrence labels and checking (1) at every edge,
including return to the complete initial overlap state, certifies (2).

**Proof.** Equation (1) follows by subtracting the top child start `p` from
the bottom child start `M w+q`.  Iterating gives

```text
w_r = M^r w_0 + sum_(k=0)^(r-1) M^(r-1-k)d_k.
```

Use `w_r=w_0`.  The converse is a direct exact replay of the same recurrence.
No determinant, inverse of `M`, stable projection, or unimodularity hypothesis
is used. ∎

The affine child-edge update is standard overlap-graph machinery; compare
Akiyama--Lee (2011), equation (4.2), where multiplicities are explicitly
retained. The contribution here is the exact ordered specialization to the
swap-seed graph and its replayable certificate, not discovery of the affine
recurrence. See `p1-overlap-affine-pump-literature-gate-2026-09-15.md`.

The canonical Mojo checker uses multiplication by `beta` on the exact
`Z[beta]` offset encoding.  The equality with (1) is the coordinate identity
`<M w,l>=beta<w,l>`.  Every addition, subtraction, multiplication and Perron
sign decision is checked; overflow, a capped graph, a missing child, or an
inconsistent occurrence aborts rather than becoming evidence.

## 2. Exact extractor and golden negative

Canonical implementation:

```text
kernel/psc/overlap_affine_pump.mojo
kernel/tests/test_overlap_affine_pump.mojo
```

Independent oracle:

```text
reference/psc_research/overlap_affine_pump.py
tests/test_overlap_affine_pump.py
```

The extractor first finds recurrence after deleting coincidences and
offset-zero states, then chooses actual ordered occurrence edges inside one
recurrent component.  Its certificate stores every occurrence ordinal, both
child indices, both exact prefix starts, the forcing term, and the graph-state
indices.  Verification reconstructs the ordered occurrences and replays the
closed recurrence.

The determinant-two regression substitution

```text
0 -> 1,   1 -> 0 2 1,   2 -> 0 0 1
```

has a certified six-edge zero-shift-free affine cycle.  This is a golden
countermodel to the overstrong claim that PIP or non-unimodularity alone
forbids zero-shift-free recurrence.  Its seed-patch overlap graph is productive,
so the cycle is **not** a closed nonproductive component and is not a
counterexample to Open Problem 5.35.

## 3. Exact boundary of the result

Lemma 1 proves an algebraic identity for a supplied finite occurrence cycle.
It does not prove any of the following:

- that a recurrent zero-shift-free SCC is child-closed;
- that it is nonproductive;
- that a formal pump is globally realizable with the required context;
- that deleting or repeating its loop preserves recognizability context;
- that the affine identity forces a zero shift;
- that finitely many tested substitutions give a universal bound.

The six-edge golden cycle shows why the next theorem must use the extra
normal-form hypotheses, not cycle algebra alone.

## 4. Next universal obligation: recognizability plus the full internal space

Assume the closed irreducible nonproductive strict-zipper component supplied
by Proposition 2.1 of `p1-overlap-minimal-obstruction-2026-09-14.md`.  Every
infinite occurrence path then has an ordered affine address.  Recurrence gives
pump identities of the form (2), while child closure requires **every** actual
child occurrence to remain in the component.

The targeted literature check shows that a context/realization bridge must
precede the proposed lemma. Recognizability recovers substitution cuts in the
aperiodic substitution system; it does not by itself justify pump deletion,
and the swap word `ab` is not assumed legal. The next lemma to prove is
therefore deliberately recorded as open:

> **Periodic-patch context bridge (open).** For the iterated periodic swap
> patch, attach a finite paired prefix-suffix context to each occurrence such
> that equality of contexts at an affine repeat is sufficient for symbolic
> pumping, while unequal contexts are detected within a substitution-dependent
> recognizability radius.

The final phrase matters.  When `|det M| != 1`, the internal representation
may have non-Archimedean/profinite factors.  A proof may use the contracting
Archimedean conjugates together with those factors, but it may not replace
their image by a discrete Euclidean stable lattice.  The immediate research
program is therefore:

1. enrich the pump certificate with periodic-patch left/right prefix-suffix
   context;
2. test whether equal affine states with unequal contexts occur, preserving
   the smallest witness as a golden countermodel;
3. formulate the exact local-to-global splicing condition;
4. only after that, determine which explicitly cited property of the complete
   non-unit representation space could force a boundary hit; do not assume a
   universal separation theorem in advance.

This separates the finite diagnostic from the universal theorem rather than
using a corpus or a projected-lattice heuristic as a completeness argument.
