# G2 slice: directive shifts, the incidence cocycle, balance

**Status:** kernel specification with its claims; statuses as in
`claim_governance.toml` and `CLAIMS.md`.

Canonical: `kernel/sadic/{directive,cocycle,balance}.mojo`. Oracle:
`reference/sadic_reference`. Cross-check: `kernel/vectors.mojo` together with
`tools/cross_check.py`.

## Conventions

- Letters and labels are 0-based. The BST19 letter `i` is `i-1` here.
- `M[i][j] = |σ(j)|_i`, so `M_{σ∘τ} = M_σ M_τ`.
- A directive word `w = w₀…w_{n-1}` has composite `σ_w = σ_{w₀}∘…∘σ_{w_{n-1}}`
  and prefix matrix `M_w = M_{w₀}…M_{w_{n-1}}`, which is BST19's `M_{[0,n)}`.
- A **directive shift** is a finite substitution set plus a deterministic
  automaton over its labels. A full shift has one state.
- Families:
  - `arnoux_rauzy(d)`: BST19 (3.1), `α_i(i) = i`, `α_i(j) = j i`.
  - `brun3()`: BST19 (3.4), `β₁, β₂, β₃`, whose incidence matrices are the
    linear Brun matrices (3.3).

## Exact predicates

| Function | Decides | Status of the output |
|---|---|---|
| `prefix_matrix` | `M_w` in checked arithmetic | exact, or raises on overflow (inconclusive) |
| `first_positive_prefix` | least `n` with `M_{w[:n]} > 0` | exact |
| `positive_blocks` | minimal words with `M_w > 0`, admissible from some state | exact. These are the cylinders BST19-3.3 asks for |
| `cross_ratio_bound` | `Θ(M) = max m_ij m_kl / (m_il m_kj)` for `M > 0` | exact rational; `log Θ` is the Hilbert diameter of `M R^d_+` (Birkhoff 1957) |
| `balance` | balance of a finite word, with a witness factor pair | exact |
| `image_balance` | balance of `σ_w(a)` | exact **lower bound** on the balance constant of `L_σ` for every `σ` with prefix `w` |

Lyapunov exponents are evidence only (rule R2) and have no place in this kernel.

## Claims guarded by `kernel/tests/test_sadic_g2.mojo`

- **ImageBalanceLowerBound** (proved). For every directive sequence `σ` with
  prefix `w` and every letter `a`, the balance constant of `L_σ` is at least
  the balance of `σ_w(a)`.

  *Proof.* By BST19 §2.2, `L_σ` contains every factor of `σ_{[0,n)}(a)` with
  `n = |w|`, and `σ_{[0,n)} = σ_w`. Any pair of equal-length factors of
  `σ_w(a)` is therefore a pair in `L_σ`. ∎
- **SturmianImageBalance** (finite-domain theorem). For every directive word
  `w` over the two-letter Arnoux–Rauzy substitutions with `1 ≤ |w| ≤ 10`, and
  each letter `a`, the word `σ_w(a)` is 1-balanced. This calibrates the
  kernel against the classical balance of Sturmian factors.
- **BrunPositiveBlocks** (finite-domain theorem). The minimal positive blocks
  of the Brun full shift up to length 5 are: none of length at most 3, six of
  length 4, thirty of length 5. In particular `β₃⁴` has the positive matrix
  `[[1,1,1],[1,1,2],[2,1,3]]` with `Θ = 3`. So the positive-cylinder hypothesis
  of BST19-3.3 is met by a length-4 cylinder.

The Tribonacci calibration (balance 2 along `(α₁α₂α₃)^k`, `k ≤ 4`) is
recorded as **evidence** that matches the known 2-balance of the Tribonacci
word. It is not imported as a theorem here.
