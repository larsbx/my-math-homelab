# Literature gate — the itinerary is the external angle

## Proposed step

`docs/ray-certificates.md` computes, for a box in the escape region, which
side of the real axis each of its iterates lies on. That word is a finite
sound invariant. The classical reading is that it is something much more
specific:

```text
the itinerary digits are the binary expansion of the external angle
    [ExternalAngleItinerary: NOT GATED]
```

This gate judges it before anything uses it, which is the order the escape
criterion taught: that one was found relying on an unnamed import after the
fact.

## Decision

**ACCEPTED for a real parameter with connected `K_c`, with the partition
stated rather than assumed, and with the boundary case excluded.**

## Findings

### 1. The statement

The Böttcher coordinate conjugates `f_c` to `z -> z^2` near infinity and
extends over the whole basin when `K_c` is connected. Under that conjugacy
the external angle doubles at each step, so the binary digits of the angle
are exactly the record of which half of the cut basin each iterate lands
in.[^1] For a real parameter the cut is the real axis (section 2 of the note
proves the two halves of it that this repository needs), so the digit is the
sign of the imaginary part.

### 2. The hypothesis is connectivity, and it bites

The conjugacy extends over the whole basin only when `K_c` is connected. The
`escaping` row of `docs/J1_regime_ledger.md` has an escaping critical orbit,
so its `K_c` is a Cantor set and the statement is unavailable there.

The ray certificate refuses at that parameter for an unrelated reason -- no
real fixed point, so no invariant segment -- and the two refusals should not
be confused. One is about the real axis, the other about the basin.

### 3. What a digit is not

A digit is a side, and a side is decided on the **enclosure**. The itinerary
is therefore a statement about every point of the box, which is stronger than
a statement about one angle, and it is undefined rather than approximate when
a step straddles the axis. The import supplies the reading of a decided word;
it does not supply a word where the arithmetic declines to give one.

### 4. The angles this reaches

Only angles whose orbits stay decidable. The certificate says nothing about
which angle a given box carries until enough digits are decided, and a finite
word names a dyadic interval of angles rather than an angle. Reading a finite
itinerary as *the* angle of a point would be an overclaim the gate does not
license.

## Verdicts

| Tag | Where used | Verdict |
| --- | --- | --- |
| `ExternalAngleItinerary` | `docs/ray-certificates.md` section 4; nothing executable yet | ACCEPTED, real parameter with connected `K_c` (findings 1-2), with findings 3 and 4 as limits on the reading |

## What this gate did not do

It did not verify a theorem number against a printed text or obtain the cited
work in full. It did not judge the Böttcher construction itself, which the
statement rests on and this repository does not name. It made no ledger
column depend on a tag.

[^1]: J. Milnor, *Dynamics in One Complex Variable: Introductory Lectures*, the sections on the Böttcher coordinate and external rays: the coordinate conjugates the polynomial to `z -> z^2` near infinity, extends over the basin when the filled Julia set is connected, and carries the external angle to the doubling map. https://arxiv.org/abs/math/9201272
