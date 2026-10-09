# Branch charter: Theorem C for Brun `7 ≤ d ≤ 10`

**Status:** planning charter, in execution. It states no theorem itself.

**Progress (2026-10-09).**
- `d = 7`: witness found at period 11 and pinned. Theorem C now covers
  `d ∈ {5, 6, 7}` (`docs/sadic-g6-brun-higher-census.md` §3).
- `d = 8`: every primitive irreducible Pisot class of period ≤ 13 (36,972
  of them) is capped at 100,000 states and length 10,000. The next step is
  period 14, or larger budgets on the classes with the smallest `|λ₂|`.
- `d = 9, 10`: not yet searched with balanced pairs.
- The symbolic-transfer branch has since given Theorem C′ for every
  `5 ≤ d ≤ 10` by import. This branch keeps supplying balanced-pair
  certificates, which need no transfer import.
Branch: `claude/brun-theorem-c-higher-d`. Phase: G3 on open cells, with G6
censuses (`docs/METHODOLOGY.md` §3).

## 1. Target

Extend Theorem C (`docs/sadic-g6-brun-higher-census.md` §3) from
`d ∈ {5, 6}` to `d ∈ {7, 8, 9, 10}`:

> **Theorem C(d) (conditional).** If the unordered Brun algorithm in
> dimension `d` satisfies the Pisot condition, then for `ν_B`-a.e. `x` the
> S-adic system `(X_{φ_B(x)}, Σ)` is a bounded natural coding of a minimal
> translation on `T^{d−1}`.

The proof of Theorem C is dimension-free except for hypothesis 3 of BST23
Theorem 3.1, a periodic Pisot point with pure discrete spectrum of the
**symbolic** system. So for each `d` this branch needs exactly one witness:

```
W(d) = an admissible Lyndon word w with
       σ_w primitive  ∧  χ_{M_w} irreducible  ∧  χ_{M_w} Pisot
       ∧  bpa_verdict(σ_w) = terminates
```

Everything before the last conjunct is budget-free and exact. The last
conjunct is a finite certificate: termination of the balanced pair algorithm,
then BST23 Proposition 6.1 (unimodular, Pisot, irreducible).

This branch imports nothing new. It relies only on gated results: BST23
Theorem 3.1, §6.5 and Proposition 6.1.

## 2. Obstacle

The `d = 6` census shows the difficulty. Only 2 of 13 Pisot orbit
representatives of period ≤ 8 terminate within 200,000 states and length
20,000. Every capped run exhausts the **length** budget, and the capped
composites have a second root of modulus about 0.89–0.94. Weak contraction
makes the irreducible balanced pairs very long. Naive census to period 8 at
`d = 7` alone has about 10⁶ periodic words.

## 3. Plan

1. **Exact Pisot prefilter (budget-free).** Census by orbits at `d = 7..10`,
   without BPA (`brun_census … orbits` with BPA budgets 0). Each periodic
   Pisot point found is already a finite-domain fact.
2. **Order by contraction (evidence only, R2).** Rank Pisot representatives by
   a floating-point estimate of `|λ₂|/λ₁`. The ranking only orders the search
   and enters no kernel decision.
3. **Structured candidates.** The witnesses found so far share a shape: a
   3-cycle `β₁₂β₂₃β₃₁`, then a chain through the new letters back to `1`:
   - `d = 5`: `β₁₂β₂₃β₃₁ · β₁₄β₄₅β₅₁`;
   - `d = 6`: `β₁₂β₂₃β₃₁ · β₁₄β₄₂β₂₅β₅₆β₆₁`.

   Search this family and its one-label mutations first.
4. **BPA with escalating budgets.** Run each candidate with escalating
   length budgets (2·10⁴ → 2·10⁶). A capped run stays inconclusive (R3) and
   is never recorded as a result.
5. **Pin each witness** in Mojo and in the independent Python `bpa.py`, as
   `test_brun_{seven..ten}_periodic_point`. Each test gets a claim receipt
   `BrunDPeriodicPointBPA` (status `finite-domain`), and the claim row is
   registered in `CLAIMS.md` and `claim_governance.toml`.
6. **State Theorem C(d)** for each `d` with a witness, on every claim surface
   in the same commit (R1).

## 4. Deliverables

- `kernel/brun_witness.mojo`: the witness search (prefilter, ordering,
  escalating BPA). It prints every candidate's verdict and budgets.
- Python oracle confirmation of each witness. The cross-check battery gains
  the witness's spectral facts.
- `docs/sadic-g6-brun-higher-census.md` §3 extended; census tables for
  `d = 7..10`, budget-free stages only, if BPA is out of reach.

## 5. Exit criteria

- **Success for `d`:** a witness `W(d)` pinned in both languages, and
  Theorem C(d) registered as a conditional theorem.
- **Stop for `d`:** no terminating witness within the largest budget. Record
  the capped candidates as evidence. Theorem C(d) then waits on the
  symbolic-transfer branch (`claude/brun-symbolic-transfer`), which would
  remove the need for BPA altogether.

## 6. Non-goals

- The Pisot condition itself; it stays numerical (BST21).
- Any statement for `d > 10`; the gate covers `d ≤ 10` only.
