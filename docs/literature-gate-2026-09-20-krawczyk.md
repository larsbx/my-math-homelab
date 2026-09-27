# Literature gate — the Krawczyk uniqueness test

## Proposed step

`docs/preperiodic-certificates.md` section 2 checks a strict inclusion and
reads it as "this box holds exactly one root". The check is this repository's
arithmetic; the reading is not:

```text
K(Z) strictly inside Z  =>  R has exactly one zero in Z, and it is simple
    [KrawczykMooreUniqueness: NOT GATED]
```

`docs/rational-interval-arithmetic-spec.md` section 2.4 already names
"contraction-type uniqueness theorems (Krawczyk, Brouwer)" as what strict
inclusion is the hypothesis of, and names them without judging them. Phase 2
is the first thing in this repository to depend on one.

There is a second step hidden in the first, and it is the one worth checking:
the theorem is stated for a map of `R^n`, and `R^c_{l,k}` is a polynomial in
one complex variable.

## Decision

**ACCEPTED, and the complex reading is an instance rather than an analogy.**
The certificate stays an import: what the code returns is the hypothesis, and
no verified column depends on the conclusion.

## Findings

### 1. The statement is the one being used

Moore's test: with `K(x_0, [x]) = x_0 - C F(x_0) + (Id - C DF([x]))([x] - x_0)`
for a linear isomorphism `C`, if `K(x_0, [x])` is contained in the interior of
`[x]`, then `F` has exactly one zero in `[x]`, and `DF` is an isomorphism
there, so the zero is simple.[^1][^2] The operator this repository computes is
that one, with `C = Y = 1/R'(m)` and `x_0 = m` the exact centre.

The theorem allows any isomorphism `C`, which is why the floating-point
literature uses an approximate inverse. Taking the exact inverse is a special
case of the hypothesis, not a strengthening of the theorem.

### 2. The complex reading is an instance

Identify `C` with `R^2`. A complex-differentiable `R` has real derivative
`DF(z)` equal to the matrix of multiplication by `R'(z)`, so `C = Y` as a
complex scalar *is* `DF(m)^{-1}` as a real-linear isomorphism, and
`Id - C DF([x])` is the matrix of `1 - Y R'(Z)`. The box `Z` is a rectangle in
either reading, so the inclusion test is the same test.

The only place the two readings could differ is the enclosure: the real form
would enclose the four matrix entries independently, while the complex product
encloses `{a b}` directly. Both contain the true set and the complex one is at
least as tight, so the hypothesis checked here implies the hypothesis of the
theorem as stated. That direction is the one that matters; the converse is not
claimed and is not needed.

### 3. What the hypothesis does not give

The theorem gives existence, uniqueness, and simplicity in `Z`. It gives no
bound on where in `Z`, no type, and nothing at all when the inclusion fails --
a failed inclusion is not evidence of no root, which is the exclusion
certificate's separate job. The repository's prose says this already; the gate
records that the theorem does not secretly say more.

## Verdicts

| Tag | Where used | Verdict |
| --- | --- | --- |
| `KrawczykMooreUniqueness` | `docs/preperiodic-certificates.md` section 2, `reference/preperiodic.py`, `quadratic_orbit/preperiodic.mojo` | ACCEPTED, including the complex instance (findings 1-2) |

## What this gate did not do

It did not verify a theorem number against a printed text, obtain the cited
works in full, or check a proof. It did not make any verified column of any
ledger depend on a tag. It did not judge Brouwer's theorem, which the cited
proofs use and this repository does not name.

[^1]: R. E. Moore, *A Test for Existence of Solutions to Nonlinear Systems*, SIAM Journal on Numerical Analysis 14 (1977), 611-615. The test that a Krawczyk image contained in the interior of a box gives a unique solution in that box.
[^2]: The operator and its existence-uniqueness statement in the form used here, with `C` any linear isomorphism and the conclusion that the solution is non-degenerate: *Certified surface approximations using the interval Krawczyk test*. https://www.arxiv.org/pdf/2602.07718
