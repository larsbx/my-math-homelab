# Kneading data from a cut, and the tuning pattern it lands on

**Status:** derivation and rung, dated 2026-09-21. It carries one theorem of
this repository, section 3, and one identification, section 4, which is a
statement about types and a pinned constant rather than about dynamics.
Item 3 of `docs/tiling-connections-2026-09-20.md`, section 7, asked for a
re-encoding and said it was "not new mathematics"; section 2 below is the
part of it that is not re-encoding, and it is a convention that would have
been silent if chosen wrong.

## 1. The cut, and why it is not the one the ray certificates use

`docs/ray-certificates.md` cuts at `y = 0`, the real axis, because that is
where the escaping real half-lines are. Kneading data is a different cut:

```text
CRITICAL_CUT = Cut.of(1, 0, 0),     the line x = 0
```

the vertical line through the critical point. For a real parameter the
critical orbit is real, so the real-axis cut is met by every iterate and
decides nothing; the critical cut decides every iterate that is not the
critical point itself.

The word is the three-valued side of that cut, read off the enclosure, one
letter per step:

```text
critical_itinerary(c, n)[k] = letter(side(CRITICAL_CUT, F^(k+1)(0))),   k < n
```

`None` as soon as a step is undecided or the coordinates outgrow the budget.
A step is undecided exactly when the enclosure meets `x = 0`, which for an
exact singleton means the iterate **is** the critical point -- the classical
`*` of a superattracting kneading sequence, and section 3 is what to do with
it. A word with a gap in it is not a word.

## 2. The letter convention, and the reason it is not arbitrary

```text
letter(NEGATIVE) = 1,        letter(POSITIVE) = 0
```

The left side is `1`. That is the opposite of the reading a coordinate sign
suggests, and it is the right one: `f'(x) = 2x` is negative exactly on the
negative side, so a step through `x < 0` is the orientation-reversing one,
and the parity convention the kernels implement as `dgp_twist` is the parity
of the number of orientation-reversing steps
(`docs/tuning-substitutions-spec.md`, section 1.3, in
`larsbx/finite-math-kernels`). Counting `1`s has to count reversals or the
twist is the wrong bit.

Nothing above proves the convention is the classical one. What pins it is
section 4: the kernels pin `PERIOD_DOUBLING = ((1,), True)` from combinatorics
alone, and the only real superattracting parameter this repository has
produces `(1,)` under this convention and `(0,)` under the other. A test
would fail loudly under the wrong choice, which is the whole reason to
compute the pattern rather than describe it.

## 3. Theorem (a superattracting parameter yields a prefix, exactly)

**Let `c` be real with a superattracting cycle of period `p`, that is, a
critical orbit of preperiod `0` and period `p`. Then the critical itinerary
is decided at every step `1, ..., p - 1` and undecided at step `p`, and the
decided part is a word of length `p - 1` over `{0, 1}`.**

*Proof.* Preperiod `0` and period `p` means `f^p(0) = 0` and the iterates
`f^k(0)` for `1 <= k < p` are distinct from each other and from `0`, because
a repeat before `p` would be a shorter period. A singleton enclosure at a
nonzero rational does not meet `x = 0`, so each of those steps is decided; the
`p`-th is the critical point itself, so it is not. []

The word is what `tuning_prefix` returns. Two degenerate readings are refused
rather than papered over:

- `p = 1`, the parameter `c = 0`: the prefix is empty, and an empty prefix is
  not a tuning pattern. `TuningPattern.checked` rejects it upstream and this
  repository does not construct one. The same parameter has no Markov
  partition either (`docs/tiling-connections-2026-09-20.md`, section 4), and
  for the same reason: one point is not a structure.
- a parameter with preperiod above `0` -- every Misiurewicz one -- has no
  return to the critical point, so it has a kneading *sequence* and not a
  tuning pattern. `tuning_prefix` refuses; `critical_itinerary` still gives
  the word, of whatever length is asked for.

## 4. The identification, executed rather than described

The kernels' `substitution_dynamics/tuning.mojo` takes a non-empty word over
`{0, 1}` and a twist and returns a constant-length substitution on two
letters:

```text
tau_{A',eps}(s) = A' . (s xor eps)
```

`kernel/kneading.mojo` hands it the word section 3 computes, with the parity
twist, and `TuningPattern.substitution()` returns the substitution. At
`c = -1` this repository computes the prefix `(1,)` from the dynamics of
`z^2 - 1` and the kernels return

```text
tau = ((1, 1), (1, 0))
```

which is the constant `tests/substitution_dynamics/test_tuning.mojo` pins
upstream from combinatorics that never mention a Julia set. That coincidence
is the bridge: an object computed here from an orbit lands on an object
pinned there from words.

**What the identification is.** A word this repository computes has the type
the kernels' tuning layer consumes, and on the one parameter where both sides
have a value, the values agree. That is a statement about types and one
constant.

**What it is not.** That `tau` describes tuning in the parameter plane -- that
the substitution acts on kneading sequences as renormalization acts on
parameters -- is the classical content, and it is the consumer's import in
the kernels' own words (`docs/tuning-substitutions-spec.md`, section 5). No
tag is opened here and none is used. This repository has computed a word and
handed it over.

## 5. What the parameter domain allows

By section 3.3 of `docs/tiling-connections-2026-09-20.md` the postcritically
finite parameters of `Q(i)` are `{0, -1, -2, i, -i}`. Of those:

| `c` | kind | what this layer yields |
| --- | --- | --- |
| `0` | superattracting, `p = 1` | empty prefix; no pattern |
| `-1` | superattracting, `p = 2` | prefix `(1,)`, twist `True`, `tau = ((1,1),(1,0))` |
| `-2` | Misiurewicz | kneading sequence `1 0 0 0 ...`; no pattern |
| `i`, `-i` | not real | the critical cut decides, but the orbit is not on a line and no kneading order is claimed |

So the exact-parameter domain supplies **one** tuning pattern, as it supplied
two transition matrices and one of those was `1x1`. The constraint is the
same one, and so is the answer to it: the algebraic half of Phase 4.

The itinerary itself is not restricted to those five. Any real rational
parameter whose orbit avoids the critical point has a decided word of any
requested length -- `c = -7/4` gives `1 0 1 1 0 1 1 0`, `c = -3/2` gives
`1 0 1 1 1 1 1 0` -- and those are kneading prefixes, which is what the
kernels' s-adic layer consumes. What they are not is patterns, because
nothing returns to the critical point.

## 6. What this does not claim

It does not claim the word is the classical kneading sequence in any sense
beyond section 4's pinned constant, does not order the interval, does not
mention laps or the Milnor-Thurston invariant, and does not say that two
parameters with the same word are related. It discharges no block of
`docs/J1_proof_definition.md` and takes no theorem tag.
