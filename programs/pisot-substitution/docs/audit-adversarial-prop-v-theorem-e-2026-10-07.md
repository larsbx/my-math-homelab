# Adversarial audit: Proposition V and Theorem E — 2026-10-07

**Scope:** `main@6eb9c06`. Targets:
Proposition V of [`p1b-vertex-coincidence-box-2026-10-02.md`](p1b-vertex-coincidence-box-2026-10-02.md) §2
(with the Lemma C / Theorem B imports of
[`p1b-strict-zipper-periodic-pair-2026-10-02.md`](p1b-strict-zipper-periodic-pair-2026-10-02.md) §§3–4),
and Theorem E of [`p1a-a1-prime-2026-10-05.md`](p1a-a1-prime-2026-10-05.md) §§3a–3b
(with Proposition C and Lemma P of the box note §5.6b).

**Brief:** disprove either statement if possible.

**Verdict:** **no disproof.** Neither statement fails, and no step of either
proof fails. Every step was re-derived by hand. Every computational step was
re-run with code written for this audit, which imports nothing from the
repository. The findings are four presentation defects (§3); none changes a
statement or a claim status. This is one adversarial reader, not the
independent human review both notes still ask for.

## 1. Theorem E

*Statement.* Let `sigma` be PIP on three letters, catch-up-free, with `|det M| = 2`.
If `h = sigma_+` fixes distinct `x, c`, then `{x, c}` is eventually coincident.

| Attack | Outcome |
| --- | --- |
| **Hypothesis leak: does the class escape Proposition D's normal form?** Enumerated, straight from the definitions (`h(0)=0`, `h(1)=1`, `|det M| = 2`, no proper nonempty image prefix in `M Z^3`, PIP), every substitution with images of length ≤ 5, without assuming the normal form | 34 members at length ≤ 4 and 68 at length ≤ 5. **None** leaves the normal form, and the decider (§4) finds `{0,1}` coincident on all of them (levels ≤ 7). |
| Lemma D0, Propositions C and D by hand | Sound. Prop C's converse: `f(x_1) = 1` (odd prefix), `f(x_k) = 0` for `1 < k < L` (difference of two odd prefixes), `f(x_L) = 1` (even column). D0: `O = A` forces every image to have length 2, so `beta = 2`. D: a length-one image `sigma(a) = a` contradicts primitivity. `h` cannot fix all three letters, because `sigma(y)` starts in `{x, c}`. |
| §3b.2 determinant table, §3b.5 `f(±1)` table | Re-derived symbolically for all 16 endings (sympy). Both tables agree entry for entry. |
| §3b.3 exclusions | Sound: zero rows (non-primitive), rank ≤ 2 (`det = 0`), left eigenvector `(1, −1, 0)` with eigenvalue 2. |
| Lemma P1 | Sound. It uses only `beta > 1`, `|beta_{2,3}| < 1`, and the fact that real/complex-pair products `(1 ∓ beta_2)(1 ∓ beta_3)` are positive. |
| Lemmas L_BC, L_D, L_A by hand | Each Parikh cancellation and each letter condition re-derived. The positions agree with the note: L_A gives `|sigma(P)| + 1 = p + q + 6 + q(r+2)` for `r = q + 1`, and `|sigma(P)| + 2 = p + q + 5 + q(r+2)` for `r = q − 1`. |
| Lemmas on the words | At every PIP `|det M| = 2` point of the four classes with `p, q, r ≤ 30` (2,526 points), the named position was checked on `sigma^n(x)`, `sigma^n(c)`: **0 failures**. |
| §3b.7 residue | Every line bound re-derived from the symbolic `f(±1)`. The uncovered PIP set at bound 30 is **exactly the 27 listed**. All 27, and every member with `max(p,q,r) ≤ 14`, are coincident by the independent decider. |

## 2. Proposition V

*Statement.* `𝔅` is the inflation closure of a finite start set containing
every overlap with `|w_m| ≤ R_m`. Then (1) every cycle vertex of the overlap
graph lies in `𝔅`, and (2) PPVC(`sigma`) holds iff every vertex of `𝔅` has an
offset-zero descendant.

| Attack | Outcome |
| --- | --- |
| Step 1 (radii) | Sound. The child offset is `t' = beta t + <ell, pi(q) − pi(p)>`. Periodicity gives the convergent series for `sigma_k(t_0)`, hence `|sigma_k(t_0)| ≤ B_k`. `|t_0| < ell_max` because the tiles meet. `w_m = Tr(theta_m t)` because `Tr(theta_m ell_a) = delta_{ma}`; this needs the `ell_a` to be `Q`-independent, which irreducibility gives. |
| Step 1 numerically | The radii were recomputed independently (mpmath, 60 digits). Every interior-occurrence pair with integral `w_0` was enumerated: Tribonacci `r ≤ 7` (164 pairs), the cube specimen `r ≤ 5` (1,007), the golden pump `r ≤ 7` (730). Largest `max_m |w_m|/R_m`: 0.48, 0.09 and 0.12. No pair is near the boundary. |
| (⇐) via Theorem B(2), (3) | Sound. (b) ⇒ (a) of B(3): a common vertex at depth `m` survives to depth `rk ≥ m`, because inflation keeps vertices and `Phi_c^{rk}` fixes both tilings. All 1,901 pairs above share a vertex. Their first offset-zero depths are 3, 10 and 8, within the published `K_V` of 3, 17 and 15. |
| (⇒) via Lemma C + converse of Theorem B | Sound. `Y` is closed and finite, and every overlap has a child, so `Y` has a terminal SCC. A cycle in it containing a non-leftmost edge and a non-rightmost edge has its composite fixed point in the open region. That fixed point is `<ell, pi(P)>/(beta^r − 1)` in tile-A coordinates. So an interior fixed point makes `P` and `U` nonempty, and the same holds for `Q`, `V` on the B side. `w_r = w_0` is (1). The tilings `T(i, P)` are legal whether or not `v_0` occurs between legal tilings, so the vertices of `𝔅` that are not realised geometrically do no harm. |
| Finiteness of `𝔅`, start-set superset | Sound. Contracting conjugates obey `|sigma_k(t_{n+1})| ≤ mu_k |sigma_k(t_n)| + C_k`, and `Z⟨ell⟩` embeds as a lattice. Solving the third coordinate from the slab `|t| < ell_max` enumerates a superset of the box. By the second remark, a superset changes no verdict. |

**Why a disproof was never on the table.** By Theorem S, a failure of PPVC is a
counterexample to the Pisot conjecture. Likewise, a PIP member of Theorem E's
class with `{x, c}` not coincident would violate the strong coincidence
conjecture. Either outcome would require a counterexample to an open
conjecture that no one has found, so the realistic targets were the proofs and
their finite inputs. Those are what this audit attacked.

## 3. Findings (presentation only)

*Applied 2026-10-07* to [`p1a-a1-prime-2026-10-05.md`](p1a-a1-prime-2026-10-05.md) §§3b.3, 3b.6 and 3b.7. No statement changed. The unreachable L_BC clause has also been removed from `lemma_witness` in `kernel/a1_normal_form_census.mojo`. `test_a1_normal_form.mojo` passes unchanged, with 453 witnesses and the 27-point residue.

1. **Theorem E, "position" is a prefix length.** The lemmas name the position
   of the shared tile as the length of the common prefix (a 0-based index).
   Read as 1-based, 2,499 of the 2,526 named positions fail. The note should
   say "after a common prefix of length …".
2. **Lemma L_BC, a dead branch.** The clause `r = q = 0` and `s_y = x` never
   fires. Class B needs `|r − q| = 1`, and class C has `s_y = c`. It is
   harmless and can go.
3. **§3b.3, a second reason for two exclusions.** Endings `(x,c,x,x)` and
   `(x,c,c,c)` have `det M = ∓4(p − r)` and `∓4(q − r)`, so `|det M| = 2` is
   impossible there before primitivity is consulted.
4. **§3b.7, implicit line ranges.** The ranges of `n` are left implicit. The
   line `(n, n+1, 1)` at `n = 0`, i.e. `(0, 1, 1)`, has `f(−1) = −2 < 0`. It is
   excluded only by `f(1) = 0`, through the `(0, 1, n)` line. The table's
   "none" is right but rests on that row.

## 4. Reproduction

The scripts and their outputs are in
[`archive/2026-10-07/session-probes/`](../archive/2026-10-07/session-probes/).
They are provenance, not canonical code (AGENTS.md).

- `common.py` holds the primitives. PIP is primitivity, the rational-root test
  and Pisot roots at 60 digits. `coincidence_level` decides strong coincidence
  by breadth-first search on the overlap graph restricted to meeting tiles. It
  returns a level, or `None` only after exhausting the finite closure. On 300
  random PIP specimens, 900 pairs, it was cross-checked against a direct
  shared-tile scan of `sigma^n(a)`, `sigma^n(b)`, with 0 mismatches. Overlap
  tests use 60-digit floats. An exact boundary case would be `<ell, d> = ell_i`,
  i.e. `d = e_i`, and is excluded by the strict inequality and a `10^−40`
  margin. This is an oracle, not a certificate.
- `enum_e.py L`: the direct enumeration (§1, row 1).
- `tables.py`: the symbolic tables.
- `sweep_nf.py N`: named positions, the residue, and the decisions.
- `propv.py R`: radii, integral centre pairs, and shared vertices.
