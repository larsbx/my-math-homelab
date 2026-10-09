# P1 overlap productivity — first prefix-suffix context checkpoint

**Status:** exact finite negative calibration. This note does not prove the
periodic-patch context bridge, recognizability compatibility, overlap
productivity, or the Pisot substitution conjecture.

## Question

PR #91 certifies ordered affine cycles with

```text
w' = M w + q - p.
```

The issue-84 literature gate requires a symbolic context checkpoint before
any loop deletion or adelic-separation argument. The first, deliberately
small question is whether equality of the affine child state
`(top,bottom,w)` determines even the one-step paired prefix-suffix address of
the child occurrence.

For an occurrence selecting positions `i` in `sigma(a)` and `j` in
`sigma(b)`, record

```text
(a, b, i, j,
 sigma(a)[:i], sigma(a)[i+1:],
 sigma(b)[:j], sigma(b)[j+1:]).
```

This is the full symbolic context inside the two parent supertiles at one
inflation step. It is not yet a collar in the iterated periodic swap patch.

## Exact diagnostic and golden mismatch

Canonical implementation:

```text
kernel/psc/overlap_context.mojo
kernel/tests/test_overlap_context.mojo
```

Independent oracle:

```text
reference/psc_research/overlap_context.py
tests/test_overlap_context.py
```

On the determinant-two substitution

```text
0 -> 1,   1 -> 0 2 1,   2 -> 0 0 1,
```

the first deterministic mismatch reaches seed-patch graph state `9` from
two actual ordered occurrences. Their top contexts agree, but the bottom
proper suffixes are respectively

```text
(2,1)  and  (0,1)
```

in zero-based notation. Thus the same affine overlap state does not determine
the one-step symbolic address. The certificate recomputes both records from
the substitution tables and occurrence ordinals; capped graphs and invalid
ordinals fail closed.

## Meaning and limitation

This is a countermodel to the inference

```text
equal affine state  =>  equal symbolic pump context.
```

It does not show that the two occurrences remain distinguishable at every
ancestry depth, and it does not show that context-compatible affine repeats
cannot exist. In particular it neither identifies the seed-patch graph with
the complete realized-overlap graph nor licenses deletion or repetition of a
cycle.

The next finite construction should carry a depth-`k` paired ancestry collar
in the iterated periodic patches `sigma^n(ab)` and `sigma^n(ba)`, preserving
left/right boundary symbols across parent-super-tile boundaries. It should
then report the least depth at which each affine collision separates, while
retaining any collision surviving the tested depth as a finite survivor—not
as evidence of a universal recognizability bound.

## Literature status

This checkpoint implements the first executable prescribed by
`p1-overlap-affine-pump-literature-gate-2026-09-15.md`. Canterini--Siegel
supplies the prefix-suffix address language; Durand--Leroy supplies an
effective recognizability scope only for admissible substitution dynamics.
Neither source turns this one-step seed-relative record into a pump-deletion
theorem. No new literature search is required for this already reviewed
regression slice; the depth-`k` collar must remain inside the hypotheses and
stop/go decision recorded there.
