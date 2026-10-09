# P1a aligned obstruction: fixed-edge or alternating-E normal form — 2026-10-01

**Status:** repository proof of a new finite/combinatorial reduction for the aligned
branch of #84/#138, using the already imported Barge–Diamond good-pair existence
input. This note does **not** prove ternary strong coincidence, seedwise overlap
productivity, or PSC.

## 1. Setup

Let \(\sigma\) be a primitive irreducible Pisot substitution on three letters.
Write \(h=\sigma_+\), where \(h(x)\) is the first letter of \(\sigma(x)\).

Fix one Barge–Diamond eventually coincident unordered pair
\[
G=\{a,b\}
\]
and write \(c\) for the complementary third letter.

For a closed nonproductive overlap component \(S\), every offset-zero vertex
\((i,j,0)\in S\) exposes a pair \(\{i,j\}\) that is **not** eventually
coincident. Its deterministic first-child descendant is again offset zero and
has unordered pair
\[
H(\{i,j\})=\{h(i),h(j)\}.
\]

Child closure keeps that descendant in \(S\). Therefore every pair on this
deterministic orbit remains distinct and non-eventually-coincident.

Because \(G\) is eventually coincident, no bad aligned pair can equal \(G\).
The only possible bad unordered pairs are
\[
E_a=\{a,c\},\qquad E_b=\{b,c\}.
\]

This is the existing hub-star reduction.

## 2. Aligned recurrent-cycle theorem

### Theorem 2.1 — fixed edge or alternating E

If the aligned branch of a closed nonproductive component is nonempty, then
the deterministic first-child pair dynamics contains a recurrent bad-pair
cycle of exactly one of the following two forms.

1. **Fixed-edge template.** One of \(E_a,E_b\) is fixed setwise by \(H\).
2. **Alternating-E template.**
   \[
   E_a\longleftrightarrow E_b,
   \]
   and necessarily
   \[
   h(c)=c,\qquad h(a)=b,\qquad h(b)=a.
   \]
   Hence \(h\) is endpoint type E, \(G=\{a,b\}\) is exactly its letter
   2-cycle, and the hub \(c\) is its fixed point.

No recurrent aligned bad-pair cycle of period greater than two is possible.

### Proof

Take an offset-zero vertex in the aligned branch and iterate the deterministic
first-child selector. The overlap graph is finite and child closure keeps every
iterate in the same nonproductive component, so some tail of the pair orbit is
periodic.

Every pair on that tail is distinct and avoids \(G\). On three letters there
are only the two remaining edges \(E_a,E_b\). A periodic orbit on a two-element
set has period one or two.

Period one is the fixed-edge template.

Suppose the period is two. Then
\[
H(E_a)=E_b,\qquad H(E_b)=E_a.
\]
The element \(h(c)\) belongs to both image edges, so
\[
h(c)\in E_a\cap E_b=\{c\},
\]
hence \(h(c)=c\). Now
\[
H(E_a)=\{h(a),c\}=\{b,c\}
\]
forces \(h(a)=b\), and similarly \(h(b)=a\). Thus \(h\) consists of the
2-cycle \(a\leftrightarrow b\) and the fixed point \(c\), which is endpoint
type E. The converse is immediate. ∎

### Corollary 2.2 — the alternating witness is genuinely interior

In the alternating-E template the Barge–Diamond-good pair \(G=\{a,b\}\)
never synchronizes at the left endpoint under any iterate of \(h\): its
endpoint pair alternates \((a,b)\leftrightarrow(b,a)\).

Therefore any eventual coincidence witnessing that \(G\) is Barge–Diamond
good must occur at a **positive balanced prefix**, not at the initial boundary.

This is useful extra data: the exceptional alternating template comes with an
interior equal-Parikh witness that the next proof step may try to transport
into the bad hub-star lineage.

The same theorem and corollary apply to the suffix-aligned branch after
reversing the substitution.

## 3. Exact finite classifier

Canonical Mojo support is in kernel/psc/hub_selector.mojo and
kernel/tests/test_hub_selector.mojo.

The new functions compute the eventual cycle period of a viable hub-star pair
and recognize the forced alternating-E template.

Exhausting all \(27\) endpoint self-maps and all three choices of good edge
gives \(81\) endpoint/good-edge placements:

| recurrent strict-star template | placements |
| --- | ---: |
| no viable bad pair orbit | 45 |
| fixed bad edge | 33 |
| alternating-E | 3 |

The count is a regression for the hand proof, not its logical basis.

Combining with the existing first-child hub-phase theorem gives one further
exact distinction:

- the alternating-E template has selector hub residual \(q_+=0\);
- fixed-edge templates occupy the remaining viable C/D/E/F placements.

No conclusion about the full child-orientation cocycle is inferred from this
selector-only phase.

## 4. What this removes from P1a

The aligned route no longer needs to reason about an arbitrary recurrent
endpoint-pair orbit.

After choosing one Barge–Diamond-good pair, the universal aligned obstruction
is reduced to two explicit symbolic templates:

    A1  fixed bad hub edge
    A2  hub fixed + good-edge letters swapped (alternating type E)

Endpoint type G is already eliminated; A/B synchronize; every longer pair
cycle is now excluded.

This is a strict reduction of #138, not a proof of #138.

## 5. Next proof obligations

*Update 2026-10-05: A1 and A2 are one obligation.* Theorem C of
[`p1a-template-collapse-2026-10-05.md`](p1a-template-collapse-2026-10-05.md)
proves that passing to `\sigma^2` turns every viable template into the case
where `h` fixes **both** letters of a bad edge pointwise: a fixed edge is
permuted by `h`, so `h\circ h` fixes it pointwise, and in the alternating
template `h\circ h` is the identity. Primitivity, irreducibility, the Pisot
property, the good pair, the badness of the edge and the closed nonproductive
component all transfer to `\sigma^2`. So **A2 follows from A1 restricted to
case (i)**, and the surviving obligation is the single statement A1′ there,
which in classical form reads: *two distinct one-sided fixed points of a PIP
substitution on three letters, anchored at a common point, share a tile.* That
note's §4 records, from Barge–Diamond (2002) itself, why A1′ is a special case
of the open ternary strong coincidence problem rather than a corollary of the
import. The two subsections below are kept as the original statement of the
obligations.


### A1 — fixed-edge forcing

Let \(P\in\{\{a,c\},\{b,c\}\}\) be a bad edge with \(H(P)=P\).
The next load-bearing theorem must exploit substitution words, not only the
endpoint map:

> **Fixed-edge interior-forcing lemma (open).** Under the PIP hypotheses and
> a Barge–Diamond-good complementary edge, a setwise fixed bad edge cannot
> remain non-eventually-coincident through every balanced prefix context of a
> closed nonproductive aligned component.

A valid proof must identify the exact balanced-prefix transport mechanism. It
may not replace eventual coincidence by endpoint synchronization.

### A2 — alternating-E transport

Here \(h(c)=c\), \(h(a)=b\), \(h(b)=a\), and Corollary 2.2 supplies an
interior balanced-prefix coincidence for \(G=\{a,b\}\).

The next theorem is narrower:

> **Alternating-E interior-witness transport (open).** Show that the interior
> Barge–Diamond witness for \(G\) must occur as a right-adjacent zero-return
> pair in some descendant of either bad star edge \(E_a\) or \(E_b\), or
> derive a contradiction with closed nonproductivity.

If this transport lemma holds, the alternating template is eliminated
immediately because a good pair at a zero-return boundary makes the state
productive.

## 6. Generality firewall

Nothing here assumes legality of a swap word, unique decodability as an
independent premise, finite BPA/G1, finite injectivity, unimodularity, a
Euclidean-only internal representation, or computational completeness.

The Barge–Diamond input used is only existence of one eventually coincident
letter pair.
