# Audit: what the finite regime can bring to Theorem K's open tail — 2026-10-08

**Scope:** `main@340d6ae`. On 2026-10-08, after PR #240, a session proposed
three ways to bring finite-regime machinery to the open part of Theorem K's
family. The machinery comes from this repository's finite-domain results and
from the `larsbx/finite-math-kernels` packages. This note checks each claim
in that advice against the code, the ledger and one new measurement.

**Verdict:** one proposal is **refuted on its main premise**, one is
**sound in direction but rests on a false invariance claim**, and one is
**confirmed with its cost stated correctly**. No claim status, ledger node or
theorem text changes. #138, #139, G1 and PSC stay open.

The open part is in
[`p1a-a1-prime-2026-10-05.md`](p1a-a1-prime-2026-10-05.md) §3m. It is
`s = +1`, `Delta >= 2`, `Z_2 >= 3` and `s = −1`, `Delta <= −2`, `Z_2 >= 4`.
The latest cover figures are in the side-notes ledger's 2026-10-08 entries.

## 1. The advice, as given

1. **Use Theorem Ω's box automaton as the exact per-member oracle.**
   `psc/vertex_coincidence.decide_vertex_coincidence` would replace
   `coincidence_level` in the cover's point decisions and in the independent
   membership checks. Two reasons were given:
   - **Speed.** The independent `zy | yz` check could decide only 39 of
     1,772 members, because single `coincidence_level` calls took more than
     60 s.
   - **Strength.** The verdict is formal productivity (FP), so pure discrete
     spectrum (PDS) through Lee–Moody–Solomyak, not just `{o, y}`
     coincidence.
2. **Close the open-tail run tree by a cycle argument.** Reduce each
   open-tail pattern to a canonical *type*: its revealed prefix and suffix
   shapes, with the region normalized by translating run-length variables.
   Find cycles of the type graph with `finite_graph`'s Tarjan SCC. Close an
   SCC by induction on the opaque tail's length. Two premises were given:
   - **Ends only.** Certificates read at most 2–4 revealed runs from either
     end of each word.
   - **Translation invariance.** The region constraints, meaning the q-lift's
     affine forms and Lemma P1, are invariant under translating run-length
     variables.
3. **Use Theorem L's symbolic-line method on one-variable leftovers.**
   Hand a region with one free variable to `psc/symbolic_line.mojo`, which
   decides a one-parameter family for every `q >= q0` by parametric
   Sturm–Tarski queries. The advice noted that `symbolic_line` assumes
   single-run images and would need generalizing.
4. **Leave aside** `finite_polynomial`, `root_isolation` and
   `rational_dynamics`, none of which is vendored here.

## 2. Findings

| # | Claim | Verdict | Evidence |
| --- | --- | --- | --- |
| 1a | The box automaton is faster than `coincidence_level` on Theorem K's members | **Refuted** | Measured on members of the `s = −1` leaf `zy \| yz` (table below). The box automaton is roughly 70–95 times slower on the two small members, twice as slow on the slow member (9, 7, 0), and does not finish (7, 9, 1) within 180 s, which `coincidence_level` decides in 58 s. Its graph has 27,000–65,000 states even at `a, b <= 9`. |
| 1b | The box automaton's verdict is stronger than `{o, y}` coincidence | **Confirmed** | `productive` is Theorem Ω's FP ([`pds-certificate-from-the-box-automaton-2026-10-07.md`](pds-certificate-from-the-box-automaton-2026-10-07.md)). FP makes every potential overlap productive, the aligned overlap `(o, y, 0)` included. That gives `{o, y}` coincidence, and PDS through consequence (a). Every member measured was `productive`. |
| 1c | The 39 of 1,772 figure | **Confirmed** | `test_every_zy_yz_member_lies_in_the_q_lift_claim` in `kernel/tests/test_odd_letter_family_certificate.mojo` decides only the members with `a <= 7`, `b <= 8`. |
| 2a | Certificates read at most 2–4 revealed runs from the ends | **Confirmed, with its scope** | Side-notes ledger, 2026-10-06, excursion route: at most 2 runs through length 10 exhaustively, and at most 4 in seeded samples at lengths 40–60. This counts **with** the Lemma Φ5/Φ5′ suffix and lagged cuts. Without them the need grows with length. It is finite evidence, not a bound proved for every length. |
| 2b | The region constraints are invariant under translating run-length variables | **False as stated** | Lemma P1 is not invariant. In `zy \| yz`, `f(−1) = ae + a − 2b + 2`. Shifting `a` by one changes `f` by `e + 1`, so a region cut by `f <= −1` is not mapped into itself. Under the q-lift, `q_j = n_j e` moves to `q_j + e` when `n_j` moves by one, so the forms transform affinely, not identically. A sound type abstraction needs a map that sends each region **into** the region of the type it is identified with. A translation does not do that. Monotonicity in a variable might, and so might identifying regions only up to an affine map that preserves every form. That is a lemma to prove before any cycle is closed. |
| 2c | Induction on the opaque tail is well-founded | **Confirmed, restated** | For a fixed member, every refinement reveals one of its finitely many runs. So each member lies on a finite branch, and induction on the member's number of unrevealed runs is well-founded. The cycle argument must still show that closing an SCC covers each member along *its own* finite branch. |
| 3a | `symbolic_line` assumes images `f y^(n(q)) l` with one `y`-run | **Confirmed** | Module docstring of `kernel/psc/symbolic_line.mojo`. Theorem K's images `o w_i o` have several runs, so the generalization the advice names is needed. |
| 3b | Leftovers are often effectively one-variable | **Confirmed as an observation** | Side-notes ledger, 2026-10-07/08 q-lift entries: the earlier staircases ran along one variable (`a`, or one run length), and the round-3 closure of `zy \| yzy` came from a single value split, `n_0 = 3`. This is not shown for the 11 patterns that still time out. |
| 4 | `finite_polynomial`, `root_isolation`, `rational_dynamics` are not vendored, and add little here | **Confirmed (not vendored); the judgement stands as a judgement** | `vendored.toml` lists none of them. The Pisot and irreducibility screen (`finite_linear_algebra.qpoly` Sturm chains) and the q-lift's exact Lemma P1 cut already cover what `finite_polynomial` would add. No concrete lemma was offered for the Christoffel-word idea behind `rational_dynamics`. |

### The measurement behind 1a

Probe: `experiments/z2-route/boxtime.mojo`. It runs
`decide_vertex_coincidence_screened` or `coincidence_level(sigma, 0, 1)` on
`sigma(o) = y`, `sigma(y) = o z^a y^b o`, `sigma(z) = o y^(b+2+e) z^(a+1) o`.
Each run is a single call under `timeout 180`, on a shared 4-core container,
so the times are wall-clock and approximate.

| `(a, b, e)` | box automaton | `coincidence_level` |
| --- | --- | --- |
| (3, 3, 0) | 47,359 states, productive, D = 14, 3.9 s | level 5, 0.05 s |
| (4, 4, 0) | 27,157 states, productive, D = 8, 4.4 s | level 4, 0.05 s |
| (9, 7, 0) | 64,997 states, productive, D = 10, 105.6 s | level 4, 51.9 s |
| (7, 9, 1) | did not finish in 180 s | level 4, 58.2 s |
| (9, 30, 4) | did not finish in 180 s | did not finish in 180 s |

(5, 6, 1) was also tried. Its characteristic polynomial is reducible, so it
is not a member, and both deciders refuse it.

## 3. What follows for the order of work

- **Item 1 is demoted to a cross-check.** The box automaton is worth running
  where it finishes, because it upgrades a member's verdict to FP. It does
  not make the independent membership check exhaustive.
- **Item 2 remains the only route seen to unbounded run counts.** Before any
  code is written, it needs a stated and proved *region-transfer lemma*
  replacing the false invariance claim (2b): for which maps does a
  certificate valid on one type's region transfer to another's? Monotonicity
  of the Lemma P1 cut in a run variable is a candidate to check first.
- **Item 3 stands as stated,** including the generalization `symbolic_line`
  needs for multi-run images.

## 4. What this note does not establish

- It audits advice. It proves nothing about Theorem K's family.
- The timing figures are single runs of each decider on five points of one
  leaf, with a 180 s cap; three runs were capped. A capped run is
  inconclusive, not a verdict.
- 2a is finite evidence. 2b is a counterexample to the claim *as stated*. It
  does not show that no type abstraction can work.
