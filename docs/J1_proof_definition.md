# J1: statement, discharge criteria, and why it is not priority zero

Status: repository source of truth for what `J1` claims and what would settle
it at a parameter.

## Terminology declaration: J1 regime discharge

Genealogy: Schleicher-style fibers of a compact connected set, the separator
catalogue layer of `larsbx/finite-mandelbrot-research`, classical local
connectivity results for quadratic Julia sets, and theorem-tag import
discipline.

Bridge claim: conditional, per regime. `J1(c)` is discharged at a parameter
only when the finite separator stream and the classical fiber relation are
connected by named adequacy and adapter lemmas *and* the regime's local
connectivity is supplied by an accepted theorem tag or by a finite witness of
non-triviality.

Known leaks: discharging `J1` on a regime says nothing about any other
regime, and nothing about `M`. The escape from the parameter plane's single
open frontier is bought by indexing over `c`, not by strengthening anything.

Use discipline: `J1` is stated per parameter and discharged per regime. A
statement of the form "J1 holds" without a regime is malformed.

## Statement

For a parameter `c` with `K_c` connected, and admissible representatives `A`
and `B` of points of `K_c`:

```text
J1(c):  A != B                             =>  exists k. Separated_k^c(A, B)
        not exists k. Separated_k^c(A, B)  =>  SameFiber_c(A, B)
```

where `Separated_k^c(A, B)` is a finite separator certificate at catalogue
prefix `k`, built from landed dynamical rays at rational angles together with
the periodic points they land at, and `SameFiber_c` is equality through the
accepted fiber adapter -- not carrier-label equality and not display-name
equality.

The classical bridge is an import, not a result of this repository:

```text
all fibers of K_c trivial  <=>  J_c locally connected     [theorem tag]
```

## Why this is not a priority-zero conjecture

`C1` in the parameter plane is one statement of MLC strength; it can be
isolated but not closed, and everything downstream of it waits. The
dynamical-plane analogue is not one statement. Local connectivity of `J_c` is
known for hyperbolic, postcritically finite, and parabolic parameters, and is
known to **fail** for Cremer parameters and for Siegel parameters of
non-Brjuno rotation number. So `J1` is a family of obligations of very
different difficulty, and the correct top-level object is the regime ledger,
not a conjecture.

The consequence is the reason this repository exists. On a regime whose local
connectivity is a classical theorem, `J1` is a **test of the separator
calculus**: if the calculus is sound, the catalogue must stabilize there. If
it does not, the calculus is wrong, and that is detectable now. The parameter
plane offers no such test, because there the answer is unknown everywhere it
matters.

## Discharge criteria, per regime

A regime row in `docs/J1_regime_ledger.md` is discharged when all of:

1. **Witness check.** Every corpus parameter in the regime carries a witness
   verified by exact arithmetic: a cycle and its multiplier class, and a
   critical-orbit verdict that is `ESCAPES` or `PREPERIODIC`, or an explicit
   `CAPPED` where the regime forces one.
2. **Catalogue soundness.** `Separated_k^c(A, B)` implies classical separation
   by the corresponding landed dynamical rays, with accepted landing tags and
   side-witness adapters.
3. **Catalogue completeness.** Every classical separator admitted by the fiber
   definition at `c` has a normalized finite code, an accepted landing tag,
   extractable side witnesses, and fair enumeration into some finite prefix.
4. **Fiber adapter.** The separator family is exactly the family used in the
   classical fiber definition for `K_c`, with on-separator cases routed to
   boundary identification.
5. **Regime outcome.** Either an accepted local-connectivity theorem tag with
   its assumptions checked, or -- where local connectivity fails -- a finite
   witness that the catalogue permanently fails to separate a named pair.
6. **Proof object.** A finite proof object checked by the Mojo theorem kernel,
   listing the premises, rule applications, theorem-tag imports, adapter
   assumptions, and the regime it discharges.

## What never discharges a regime

```text
- a bounded search with no counterexample
- a picture, a renderer, or a shrinking unresolved set
- a decided verdict at one parameter extended to its regime by analogy
- a capped critical orbit read as a classification
- an interval test that decides attracting or repelling at quadrance exactly 1
- a Mojo computation without theorem-tag import validation
- a local-connectivity tag whose literature gate has not been run
```

## Current status

No regime is discharged. Phase 0 establishes the corpus, the witnesses, the
two agreeing implementations, and the ledger. Blocks 2 to 6 are not started,
and every local-connectivity tag in the ledger is unverified.

The first genuinely open cell is the irrationally indifferent row: `c =
(37 + 16i)/100` is exact data whose Siegel-or-Cremer status is not decided by
any finite test on the multiplier. It is the intended home of criterion 5's
second branch.
