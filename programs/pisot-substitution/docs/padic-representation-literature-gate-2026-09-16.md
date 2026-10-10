# Literature gate — a real times p-adic box carrier

## Proposed step

Round-two item R7 carries a "p-adic module" as one of its four parts, inherited
from round-one item B7, "shared real times 2-adic box kernel". B7's state line
records the gap precisely: `kernel/psc/finite_cokernel_address.mojo` computes
`Z^3 / M^k Z^3` classes exactly, and there is no p-adic module in
`larsbx/finite-math-kernels`.

The proposal as inherited was a carrier in that monorepo built from scalar
`Z_p`:

1. exact `Z_p` arithmetic at a declared precision `k`, as a residue together
   with the ball radius `p^(-k)` it stands for;
2. a combined box, one closed rational interval per Archimedean coordinate and
   one scalar `p`-adic ball per finite place;
3. the same fail-closed discipline the rational intervals already carry, where
   unknown containment or sign is never promoted to equality.

Item 3 survives review. Items 1 and 2 do not: finding 5 exhibits a computed
obstruction to the scalar design on this repository's own canonical
substitution, and finding 6 states what has to replace it.

This review asks whether that carrier is a known construction, which of its
hypotheses transfer to the standing PIP regime, which known families break a
naive version, and — the question that turned out to matter — whether the step
it serves is the next one.

No PDF snapshots were imported for this review, so there is nothing under
`sources/` to cite. The entries under [Sources](#sources) are
bibliographic references to standard literature, not verified snapshots.

## Decision

**Proceed with the carrier only. Do not invoke it, and do not rank it as the
next theorem step.**

Three findings shape that decision: the step it serves is not next (finding 4),
the design it inherited does not work (finding 5), and what replaces it is two
objects rather than one (finding 6).

A carrier is legitimate infrastructure, and a ball with an explicit radius is
the exact analogue of what `finite_exact/closed_interval.mojo` already does for
the reals. Building one asserts nothing. But it must be the right ball:
review of the first draft showed that the scalar `Z_p` design cannot model the
quotient it was supposed to check against, so the licensed carrier is the
`M`-adic one. See findings 5 and 6.

The theorem step it exists to serve is **not** next, and this gate exists to say
so before the work is spent. See finding 4.

## Findings

### 1. The finite-place factor is not optional in this regime, and that is settled

For a non-unit Pisot substitution the representation space is not Euclidean.
Siegel gives the representation of non-unimodular substitutive dynamical
systems with the finite-place factors present,[^1] and Minervino and
Thuswaldner construct the Rauzy fractals in a space contained in an open
subring of the adele ring.[^2] The survey of the Pisot substitution conjecture
states the unimodular and non-unimodular settings separately for this
reason.[^3]

The standing regime does **not** settle this either way, and the first draft of
this note overstated it. `README.md` admits any `sigma` with
`det M_sigma != 0` and says in terms that unimodularity is not assumed, so the
regime contains both the unit and the non-unit branch; the unimodular negative
control in finding 7 is itself a case inside it. What `README.md` states is the
stronger discipline that a general theorem must not *silently add*
unimodularity, nor a purely Euclidean internal-space model where a
non-unimodular argument needs more structure.

So the accurate scoping is by branch, not by regime. On the **non-unit branch**,
which the canonical determinant-two regression inhabits,
`finite_cokernel_address.mojo` observes a cokernel `Z^3 / M^k Z^3` of order
`2^k`, and there the finite-place structure is forced rather than chosen. On the
unit branch it is absent. A carrier must therefore handle the non-unit branch
without assuming it, which is the same discipline `README.md` already imposes.

### 2. What transfers is the carrier, and only the carrier

Three things transfer cleanly.

- **Finite precision with an explicit radius.** A `p`-adic number known modulo
  `p^k` is a ball of radius `p^(-k)`, and arithmetic on such balls is standard
  zealous `p`-adic computation, with the loss of precision under division and
  under Hensel lifting well understood.[^4] Nothing here is new.
- **The conservative-filter contract.** A `p`-adic ball is the same kind of
  object as a closed rational interval: it may certify a difference is non-zero,
  and it may return unknown, and the second must never be read as the first.
  `docs/rational-interval-arithmetic-spec.md` in the monorepo already fixes that
  contract, and the `p`-adic side should inherit it verbatim rather than invent a
  second one.
- **The addressing.** Dumont--Thomas numeration is the standard addressing of
  prefix data for substitutions,[^5] and the repository's exact renewal
  addresses already mirror it, so the carrier has a caller-side language.

### 3. What does not transfer is every conclusion

- **The unimodular geometric theory.** Barge and Kwapisz prove a geometric
  theory of *unimodular* Pisot substitutions.[^6] Its conclusions are not
  available at `|det M| = 2`, and the repository's existing refusal to replace
  the internal image by a Euclidean stable lattice is correct.
- **Tiling and separation in the adelic setting.** Having the representation
  space is not having a separation property in it. The constructions in the
  non-unit setting carry their own hypotheses, Meyer and coincidence conditions
  among them,[^2] [^3] and `docs/p1-overlap-affine-pump-literature-gate-2026-09-15.md`
  already recorded that PR #91 must treat the complete representation space as a
  candidate setting rather than an available property. That finding stands and
  this gate does not weaken it.
- **Computability as evidence.** No result licenses concluding productivity, or
  excluding a zero-shift-free cycle, from the fact that one can compute in the
  representation space. A carrier that can evaluate a difference exactly is not
  an argument that the difference is non-zero.

### 4. The step this serves is not the next step

This is the finding that changed the decision, and it comes from the
repository's own surfaces rather than from the literature.

`archive/2026-10-06/status-snapshots/completion-ledger-2026-09-14.md` states the shortest route and its single
open premise, overlap productivity for one swap seed, and then names the next
open obligation: context-preserving recognizability **plus** separation in the
full non-unimodular internal representation.

`docs/p1-overlap-collar-2026-09-16.md` then settled the first half in the
negative direction. The radius-`m` collar recursion is exact, the
determinant-two graph has separation radius `1`, and the golden pump lifts to a
collared cycle at every tested radius, so bounded-context equality cannot by
itself exclude zero-shift-free recurrence. The ledger records what that leaves:
**the splicing and tiling-dictionary bridge remains open.**

The affine-pump gate's revised program is explicit about the order. Its step 5,
the non-unit representation step, is to be invoked "only for context-compatible
survivors". Step 4, the seed-relative growth bridge, is the open one. So the
`p`-adic module is a step-5 tool while step 4 is unsettled.

The consequence is not "stop". A carrier is not a step, and a kernel that exists
before it is needed is better than one improvised under argumentative pressure.
The consequence is that **building it must not be reported as progress on
overlap productivity**, and that R7's ranking of it alongside the other three
parts overstates its position in the route.

### 5. The scalar design fails on this repository's own canonical substitution

This is a computed obstruction, not a stylistic preference, and it came out of
review of the first draft.

Take the canonical determinant-two substitution of
`kernel/tests/test_overlap_collar.mojo`, `0 -> 1`, `1 -> 021`, `2 -> 001`, whose
incidence matrix and square are

```text
M   = [[0,1,2],[1,1,1],[0,1,0]]      det M   = 2
M^2 = [[1,3,1],[1,3,3],[1,1,1]]      det M^2 = 4
```

The Smith invariants are

| `k` | invariants of `M^k` | `Z^3 / M^k Z^3` |
| --- | --- | --- |
| 1 | `(1, 1, 2)` | `Z/2` |
| 2 | `(1, 2, 2)` | `Z/2 x Z/2` |
| 3 | `(1, 2, 4)` | `Z/2 x Z/4` |

At `k = 2` the quotient is `Z/2 x Z/2`, which is not cyclic, while a scalar
`Z_2` ball at precision `2` is `Z/4`, which is. They have the same order and
different group structure, so they are not the same object, and the two cannot
be checked against each other.

That kills the differential test the first draft claimed, and it kills the
design that test was meant to validate. It also shows why one scalar precision
cannot express the filtration at all: the invariant sequence
`(1,1,2)`, `(1,2,2)`, `(1,2,4)` changes shape with `k`, and a single exponent
`p^(-k)` has no room to record that.

### 6. What has to replace it

Two objects, kept distinct:

- **The `M`-adic ball.** The filtration `Z^3 ⊃ M Z^3 ⊃ M^2 Z^3 ⊃ ...` is the
  one the existing diagnostic already uses, and the honest carrier is a coset of
  `M^k Z^3` in `Z^3` with that lattice as its radius. This is not `p`-adic; it is
  `M`-adic, and it is where a differential test against
  `finite_cokernel_address.mojo` is legitimate, because both then decide the same
  membership question — one by lattice coset, the other by Cramer's-rule
  divisibility.
- **The local-field factor.** For the adelic picture the finite places are places
  of the number field `Q(beta)`, not of `Q`, so the factors are completions `K_v`
  with their own uniformizers and ramification indices.[^1] [^2] A carrier that
  flattens these to scalar `Q_p` discards exactly the ramification that makes the
  non-unit case different from the unit one.

The carrier is therefore two carriers, and the cheaper one is the one with a
checkable contract. The `M`-adic ball should be built first, and the local-field
factor should not be attempted until something needs it.

### 7. Negative controls the carrier must satisfy

| Control | Case | What it catches |
| --- | --- | --- |
| Unimodular substitution | `det M = 1` or `det M = -1` | the finite-place factor is trivial; a carrier that manufactures a non-trivial `p`-adic component here is wrong |
| A prime not dividing `det M` | `p = 3`, `det M = 2` | the `p`-adic factor is trivial, so using it is a category error, not a refinement |
| The determinant-two regression | `det M = 2`, `k = 2` | `Z^3 / M^2 Z^3` is `Z/2 x Z/2`, not `Z/4`: an `M`-adic ball must reproduce the group structure, and a scalar `Z_2` ball provably cannot |
| Precision exhaustion | a difference that is zero to precision `k` | must answer unknown, never zero: a ball containing zero is not the point zero |
| The golden zero-shift-free cycle | six edges, inside a productive graph | recurrence alone excludes nothing, and the carrier must not be presented as resolving it |

The third row is what makes the `M`-adic carrier checkable rather than merely
plausible, and it is also the row that refuted the scalar design. Against
`finite_cokernel_address.mojo` the `M`-adic ball is an independent
implementation of the same membership question, so the two can be differentially
tested; a scalar `Z_p` ball is not, per finding 5.

## What this gate licenses, and what it does not

1. **Licensed:** an exact `M`-adic ball carrier, a coset of `M^k Z^3` with that
   lattice as its radius, plus a combined box pairing it with one closed
   rational interval per Archimedean coordinate, in the kernels monorepo, with a
   spec document beside `docs/rational-interval-arithmetic-spec.md`, inheriting
   its unknown-is-not-equality contract, and differentially tested against
   `finite_cokernel_address.mojo` on the membership question they share.
2. **Not licensed:** a carrier built from scalar `Z_p` with one precision per
   rational prime. Finding 5 refutes it on the canonical substitution, and
   finding 6 says what the local-field factor would actually require.
3. **Not licensed:** any separation, tiling, or unique-representation property in
   the representation space.
4. **Not licensed:** any statement that the carrier advances overlap
   productivity, the open premise of the shortest route, or the splicing and
   tiling-dictionary bridge.
5. **Not licensed:** reporting R7's p-adic part as delivered when the carrier
   lands. The carrier is the part that is available now; the step it serves is
   behind an open obligation, and the delivery ledger should say which of the two
   it is recording.

## Sources

[^1]: Anne Siegel, "Représentation des systèmes dynamiques substitutifs non unimodulaires," *Ergodic Theory and Dynamical Systems* 23 (2003), 1247–1273.
[^2]: Milton Minervino and Jörg Thuswaldner, "[The geometry of non-unit Pisot substitutions](https://doi.org/10.5802/aif.2884)," *Annales de l'Institut Fourier* 64 (2014), 1373–1417; [arXiv:1402.2002](https://arxiv.org/abs/1402.2002).
[^3]: Shigeki Akiyama, Marcy Barge, Valérie Berthé, Jeong-Yup Lee and Anne Siegel, "On the Pisot substitution conjecture," in *Mathematics of Aperiodic Order*, Progress in Mathematics 309, Birkhäuser, 2015, 33–72.
[^4]: Xavier Caruso, "[Computations with p-adic numbers](https://arxiv.org/abs/1701.06794)," *Les cours du CIRM* 5 (2017). Zealous, lazy and relaxed arithmetic, and precision loss.
[^5]: Jean-Marie Dumont and Alain Thomas, "Systèmes de numération et fonctions fractales relatifs aux substitutions," *Theoretical Computer Science* 65 (1989), 153–169.
[^6]: Marcy Barge and Jarosław Kwapisz, "Geometric theory of unimodular Pisot substitutions," *American Journal of Mathematics* 128 (2006), 1219–1282.
