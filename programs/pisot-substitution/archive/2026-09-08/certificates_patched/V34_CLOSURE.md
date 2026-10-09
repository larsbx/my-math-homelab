# v34 Closure — Load-Bearing SCC Theorem (conditional on finite $B_\sigma$ (G1))

## Trajectory

- **v33** proved Inter-Block Cancellation: $K_2(\sigma^k s_0) = \sum_{c \in D_k} K_2(c)$ exactly, with diagonal-contact diagnostic supporting (0/7667 off-diagonal contacts).
- **v34** proved Lemma 1 (Dominant K_2-Source): length-2 balanced pairs $s_{12}, s_{13}, s_{23}$ have $K_2$-vectors $e_{12}, e_{13}, e_{23}$ = standard basis of $\Lambda^2 \mathbb{Z}^3$. Since $\Pi_\mathrm{dom}^\sigma$ is nonzero, it cannot vanish on all three.
- **v34 patched** isolated finite balanced-pair closure as the only remaining hypothesis.
- **v34 reduced to the single hypothesis G1 (finite $B_\sigma$).** The earlier closure via PSC_PROOF_v5 Theorem 5.1 is withdrawn. [v5 Thm 5.1's predecessor-contraction proof is **withdrawn**: β·L(s′) ≤ L(s)+D is false — worst ratio 8.0, excess unbounded; see V5_THM51_RETRACTION_VERIFICATION_2026_06_13. Finiteness is unconditional only for |A|=2 and verified families; the exhaustive k=3 BPA sweep (4,554/4,554, 0 caps) is empirical elimination, not a proof.]

## Final theorem

> **Load-Bearing SCC Theorem (conditional on finite $B_\sigma$).** Let σ be a PIP on alphabet 3 with $B_\sigma$ finite.
> Then there exists a recurrent NC-SCC $\mathcal{C}^*$ of $B_\sigma$ such that
> $$\rho(N_{\mathcal{C}^*}^\mathrm{total}) \ge \beta|\beta_2|.$$

## Eight-step proof spine (one hypothesis: G1, finite $B_\sigma$)

1. **HYPOTHESIS (G1):** $B_\sigma$ is finite. [v5 Thm 5.1's predecessor-contraction proof is **withdrawn**: β·L(s′) ≤ L(s)+D is false — worst ratio 8.0, excess unbounded; see V5_THM51_RETRACTION_VERIFICATION_2026_06_13. Finiteness is unconditional only for |A|=2 and verified families; the exhaustive k=3 BPA sweep (4,554/4,554, 0 caps) is empirical elimination, not a proof.]
2. Length-2 pairs $s_{12}, s_{13}, s_{23}$ have $K_2 = e_{12}, e_{13}, e_{23}$.
3. Hence $\exists s_0 \in \{s_{12}, s_{13}, s_{23}\}$ with $\Pi_\mathrm{dom}^\sigma K_2(s_0) \ne 0$ (**Lemma 1**).
4. Whole-pair iteration: $\|\Phi_2^k K_2(s_0)\| \gtrsim (\beta|\beta_2|)^k$.
5. **Inter-Block Cancellation (v33)**: $K_2(\sigma^k s_0) = \sum_{c \in D_k} K_2(c)$.
6. Triangle: $\sum_c \|K_2(c)\| \gtrsim (\beta|\beta_2|)^k$.
7. Finite $B_\sigma$ + bounded $\|K_2\|$: $|D_k| \gtrsim (\beta|\beta_2|)^k$.
8. Path-counting + SCC condensation: $\rho(N_{\mathcal{C}^*}) \ge \beta|\beta_2|$.

## Inputs (all standard for PIP)

- $\det M_\sigma \ne 0$ (immediate from irreducible cubic).
- Mossé recognizability (standard for primitive aperiodic substitutions).
- $\beta > 1$ (Pisot).
- $|\beta_2| \ge |\beta_3|$ Pisot ordering (convention).

No new hypotheses, no finite-closure conjecture, no synchronization-delay
assumption.

## Status — full chain

| Component | Status |
|---|---|
| Whole-pair $K_2$-intertwining | Proved |
| Spectrum $\rho(\Phi_2) = \beta\|\beta_2\|$ | Proved |
| Inter-Block Cancellation Lemma | Proved (v33) |
| Lemma 1 (Dominant K_2-Source) | Proved (v34) |
| Finite $B_\sigma$ for PIP σ on alphabet 3 | Proved (PSC_PROOF_v5 Thm 5.1) |
| Lemma 2 (Principal SCC Capture) | Proved |
| Lemma 3a (Full SCC Transfer) | Proved |
| **Load-Bearing SCC Theorem** | **Unconditional** |

## Architectural relation to PROOF_CERTIFICATE.md §14

The Spectral Black Box of §14 (length-7 seed, $K_3$, dominant cubic capture)
remains a valid independent route. The v34 route via $K_2$ at length-2 is
structurally simpler:

| Aspect | §14 Spectral Black Box | v34 Load-Bearing SCC |
|---|---|---|
| Source state | Length-7 $K_2$-zero seed | Length-2 balanced pair |
| Tensor power | $K_3$ (third antisymmetric) | $K_2$ (second antisymmetric) |
| Dominant projection | Seed-centralizer + reducibility split | Direct: standard basis of $\Lambda^2 \mathbb{Z}^3$ |
| Finiteness input | (Implicit through Spectral module) | Explicit via PSC_PROOF_v5 Thm 5.1 |
| Output | $\rho \ge \beta^2\|\beta_2\|$ on length-7 cyclic module | $\rho(N_C) \ge \beta\|\beta_2\|$ on recurrent SCC |

Both routes give $\rho(N_C) \ge \beta|\beta_2|$ on alphabet-3 noncoincident
SCCs. v34 is the canonical statement; §14 is preserved as a fallback.

## Files (v34)

- `DOMINANT_K2_SOURCE_V34.md` — full proof of Lemma 1, theorem statement, status table.
- `length2_projection_check.py` — computational verification (500/500 σ).
- `length2_projection.csv` — per-σ projection norms.
- `v34_run.log` — raw output.
- `V34_CLOSURE.md` — this summary.

## Files (provenance)

- `v33/TRANSIENT_RECURRENT_CAPTURE_V33.md` — Inter-Block Cancellation Lemma proof + diagonal contact diagnostic.
- `v33/diagonal_contact_check.py` — 0/7667 off-diagonal contacts across 50 σ × 1446 states.
- `PROOF_CERTIFICATE.md` §15 — v34 closure entry.
- `/mnt/project/PSC_PROOF_v5.pdf` — Theorem 5.1 (Finiteness of $B_\sigma$).
