# Literature gate — the degree-`n` Pisot screen

## Proposed step

A decision procedure that, for a monic integer polynomial `p` of any degree,
answers exactly one question:

> does `p` have exactly one root outside the closed unit disc, with that root
> real and greater than one?

The repository already answers it at degree three in `psc.pisot`, using a
cubic-specific identity. The proposed extension sends the unit circle to the
imaginary axis by the Möbius substitution `z = (1 + w) / (1 - w)`, then counts
right-half-plane roots of the image with a Routh array over exact rationals.

This review asks whether that construction is already known, which of its
hypotheses survive the transfer, and which known families break it.

No PDF snapshots were imported for this review, so there is nothing under
`sources/` to cite. The entries under [Sources](#sources) are
bibliographic references to standard literature, not verified snapshots.

## Decision

**Proceed, with the claim narrowed to an exact fail-closed implementation of a
standard criterion.**

The construction is textbook root-location machinery — Schur–Cohn composed with
the bilinear transform and Routh–Hurwitz — and nothing about it is new. What
the repository does not already have is that machinery carried out over exact
rationals, refusing rather than guessing at every point where the classical
statement has a gap. The work therefore merges as an implementation, and the
module must not be written as if the method were a contribution.

Two claims are explicitly withheld:

- the screen does **not** decide irreducibility above degree three, and
- a refusal is **not** a negative result.

## Findings

### 1. The construction is Schur–Cohn by way of the bilinear transform

Schur and Cohn settled the count of roots of a polynomial inside a circle.[^1]
[^2] Hurwitz settled the count in a half-plane.[^3] The bilinear (Cayley,
Möbius) map carries one problem to the other, and composing it with the
Routh–Hurwitz test is the standard route in both the polynomial-geometry
literature and discrete-time control, where it appears as the Jury test.[^4]
[^5]

The field's terms for what this module computes are *root location relative to
the unit circle*, *Schur stability* (all roots inside), and *the Jury table*.
The module should use "screen" for its own verdict and leave those terms to
the literature, since it computes neither a Schur–Cohn matrix nor a Jury table.

The consequence for the repository is a restriction, not a licence: the module
may claim an exact and fail-closed implementation at degree `n`, and nothing
about the method.

### 2. The singular-case rule transfers; the stability reading of it does not

A Routh array can stall in two ways: a leading entry vanishes while the row
does not, or an entire row vanishes. The vanishing row is the classical
singular case, and the classical remedy — continue from the derivative of the
auxiliary polynomial the row above represents — is standard.[^6] It transfers
directly, and it must, because without it every reciprocal polynomial stalls
the array, `x^2 - 3x + 1` among them, whose root 2.618... is an ordinary Pisot
number.

What does **not** transfer is the reading usually attached to that remedy. In
stability work the vanishing row is itself the answer: the system is not
asymptotically stable, and the auxiliary polynomial is computed to locate the
axis roots, not to dismiss them. Completing the array restores a count of
right-half-plane roots, but the completed sign sequence no longer records that
there were roots on the axis at all. A screen built on the completed count
alone therefore reads a polynomial whose conjugates sit *on* the unit circle as
though they sat inside it.

That is not a hypothetical. It is the second of the two defects differential
testing found in this module, and it is why the implementation pairs the Routh
count with a separate unit-circle test rather than trusting the count to be
silent about the circle.

### 3. Only one of the two Routh singularities is handled, and the bound is real

A Routh array stalls in two distinct ways, and the literature treats them
separately. The vanishing row is handled here, as above. The other is a
**first-column zero in a row that is not itself zero**, and this module
implements none of its classical remedies — it refuses.

That refusal is a genuine capability bound, not a formality. `x^3 - 3x^2 - 3x - 3`
is a Pisot polynomial: its roots are 3.951... and a conjugate pair of modulus
0.871... . Its image under the transform is `4w^3 + 12w - 8`, whose second Routh
row is `[0, -8]`, so the screen refuses it.

The bound has a sharper consequence for how a refusal may be recorded. On the
imaginary axis that image has constant real part `-8`, so it has no axis root
whatsoever. A refusal therefore carries **no** implication about the unit
circle, in either direction. Writing "refused" into a census column that means
"has a conjugate on the circle" would be manufacturing evidence, and the module
now says so at every surface that returns the sentinel, with
`known_first_column_refusal` naming the witness and
`refusal_means_root_on_unit_circle` pinning the non-claim.

Lifting the bound is possible — the standard routes are the epsilon
perturbation of the offending entry and the reversal `w -> 1/w`, which
preserves the half-plane count when `q(0) != 0` — but each needs its own
correctness and termination argument, so neither is attempted here. This is
recorded as the screen's first known limitation rather than smoothed over.

### 4. The cubic identity does not generalise

`psc.pisot.is_pisot_charpoly` decides the conjugate-pair case from
`beta * |beta_2|^2 = det`: with one real root and one conjugate pair, the pair
lies inside the unit disc exactly when `chi(det) < 0`. The identity is a
statement about a degree-three factorisation of the determinant and has no
degree-four analogue; the product of the moduli of two conjugate pairs does not
separate them.

The existing cubic decider also carries a hypothesis its docstring states and
its caller enforces: it is applied to irreducible cubics. On a reducible cubic
such as `x^3 - 2x^2` it returns `False` for a polynomial whose root location is
in fact one root outside, real and greater than one, because its case split
counts distinct real roots. That is not a defect in either routine. It marks
where root location and the PIP regime are different questions, and the
cross-check between the two in `tests/test_pisot_screen.mojo` is restricted to
irreducible cubics for exactly that reason.

### 5. Root location is not the Pisot property

A Pisot number is an algebraic integer greater than one whose *conjugates* —
the other roots of its **minimal** polynomial — lie in the open unit disc.[^8]
A screen applied to a reducible polynomial answers a question about that
polynomial's roots, not about any number's conjugates. `x^2 - x - 6` factors as
`(x - 3)(x + 2)`, and no verdict about its root location says anything about
whether 3 is a Pisot number, which it is, by a different polynomial.

Algorithms that search for Pisot numbers themselves, rather than classify a
given polynomial, are a separate line: Boyd enumerates the Pisot and Salem
numbers in an interval of the real line by a construction over their minimal
polynomials.[^7] This module is not that, and must not be described as it.

The module therefore reports root location and irreducibility separately, and
refuses irreducibility above degree three rather than reusing a rational-root
test that cannot see a product of two irreducible quadratics. Deciding
irreducibility at degree four and above needs a factorisation algorithm of the
Zassenhaus or van Hoeij kind, which is out of scope here and is not attempted.

### 6. Negative controls, and what each one catches

Every family below is pinned in `tests/test_pisot_screen.mojo` and in
`tests/test_pisot_screen.py`.

| Family | Example | What it catches |
| --- | --- | --- |
| Salem polynomials | `x^4 - x^3 - x^2 - x + 1` | a completed Routh array reading circle roots as interior roots |
| Kronecker / cyclotomic | `x^4 + 1`, `x^2 + 1` | all roots on the circle, no root outside[^10] |
| Reciprocal Pisot pairs | `x^2 - 3x + 1`, `x^2 - 4x + 1` | the vanishing row; a naive array refuses genuine Pisot numbers |
| Roots at `z = 1` or `z = -1` | `x + 1`, `x^2 - 1` | the transform's zero and its pole, which must be settled before the array |
| Lone root below `-1` | `x + 2` | one root outside the disc that is not greater than one |
| Reducible with Pisot-shaped roots | `x^3 - 2x^2` | the boundary between root location and the PIP regime |
| Degree one | `x - 2` | irreducible, yet it has a rational root |
| Product of irreducible quadratics | `(x^2 + 1)^2` | no rational root, so the rational-root test proves nothing |
| Unresolved first-column zero | `x^3 - 3x^2 - 3x - 3` | a Pisot polynomial this method refuses, with no circle root to blame |

Salem's construction is the reason the first row exists: he exhibited algebraic
integers with one conjugate outside the unit circle and the rest *on* it,[^9]
which is precisely the configuration a right-half-plane count cannot
distinguish from the Pisot one once its array has been completed.

## What this gate does not license

1. **No novelty claim.** The module implements a known criterion exactly. Any
   write-up that presents the Möbius-plus-Routh route as new is wrong.
2. **No irreducibility above degree three.** The screen refuses, and a caller
   that wants the Pisot property of a *number* must supply an irreducibility
   certificate from elsewhere.
3. **No reading of a refusal in either direction.** A refusal means the array
   did not resolve. It is not a negative result, and it is equally not evidence
   of a root on the unit circle; finding 3 gives a refused specimen that is
   Pisot and has no circle root. A caller must handle the refusal, not convert
   it into a verdict.
4. **No claim of completeness at any degree.** The screen decides, refuses, or
   is wrong, and the first two are distinguishable only because the second is
   reported honestly. Finding 3 bounds where it refuses.
5. **No replacement of `psc.pisot`.** The cubic decider remains the one the PIP
   test calls. The screen extends the reach of the same question; it does not
   supersede a routine that is cross-checked against it.

## Sources

[^1]: Issai Schur, "Über Potenzreihen, die im Innern des Einheitskreises beschränkt sind," *Journal für die reine und angewandte Mathematik* 147 (1917), 205–232, and 148 (1918), 122–145.
[^2]: Arthur Cohn, "Über die Anzahl der Wurzeln einer algebraischen Gleichung in einem Kreise," *Mathematische Zeitschrift* 14 (1922), 110–148.
[^3]: Adolf Hurwitz, "Über die Bedingungen, unter welchen eine Gleichung nur Wurzeln mit negativen reellen Teilen besitzt," *Mathematische Annalen* 46 (1895), 273–284.
[^4]: Eliahu I. Jury, *Theory and Application of the z-Transform Method*, Wiley, 1964. The discrete-time stability table and its relation to the Routh–Hurwitz test.
[^5]: Morris Marden, *Geometry of Polynomials*, 2nd ed., Mathematical Surveys 3, American Mathematical Society, 1966. Root location relative to a circle, and its reduction to a half-plane by a bilinear map.
[^6]: Felix R. Gantmacher, *The Theory of Matrices*, Vol. 2, Chelsea, 1959, Chapter XV, on the Routh–Hurwitz problem including the singular cases of the array.
[^7]: David W. Boyd, "Pisot and Salem numbers in intervals of the real line," *Mathematics of Computation* 32 (1978), 1244–1260.
[^8]: Marie-José Bertin, Annette Decomps-Guilloux, Marthe Grandet-Hugot, Martine Pathiaux-Delefosse and Jean-Pierre Schreiber, *Pisot and Salem Numbers*, Birkhäuser, 1992.
[^9]: Raphaël Salem, "A remarkable class of algebraic integers. Proof of a conjecture of Vijayaraghavan," *Duke Mathematical Journal* 11 (1944), 103–108.
[^10]: Leopold Kronecker, "Zwei Sätze über Gleichungen mit ganzzahligen Coefficienten," *Journal für die reine und angewandte Mathematik* 53 (1857), 173–175.
