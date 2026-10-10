# Branch charter: from flow to symbolic pure discrete spectrum

**Status:** planning charter, now executed. It states no theorem itself.

**Outcome (2026-10-09): success.** Sirvent–Solomyak 2002 Corollary 5.2 is
(T), verified from the primary text, without unimodularity (gate §9).
Corollary B″ and Theorem C′ are in `docs/sadic-g6-brun-higher-census.md` §5.
The plan below is kept as written.
Branch: `claude/brun-symbolic-transfer`. Phases: G0 (literature gate), then
G3 on open cells (`docs/METHODOLOGY.md` §3).

## 1. Target

Corollary B′ (`docs/sadic-g6-brun-higher-census.md` §2) gives pure discrete
spectrum of the tiling **flow** `(Ω_σ, R)` for every Pisot periodic Brun
point, in every dimension. BST23 Theorem 3.1 asks for pure discrete spectrum
of the **symbolic** system `(X_σ, Σ)`. The repository has not imported the
transfer between the two (gate §8, Barge16-R4.2: "cited only").

Gate and import a transfer theorem of the form

> **(T)** Let `σ` be primitive, unimodular and Pisot, with irreducible
> characteristic polynomial. If `(Ω_σ, R)` has pure discrete spectrum, so
> does `(X_σ, Σ)`.

Then:

- **Corollary B″.** Every primitive irreducible unimodular Pisot Brun
  composite has symbolic pure discrete spectrum, in every dimension. The
  proof is Theorem B, Lemma Rev, Barge 2016 Theorem 3.13 and (T).
- **Theorem C′ (conditional).** For every `d` where BST23 §6.5 holds
  (`d ≥ 3`; the gate pins `d ≤ 10`) and an exact PIP periodic point exists,
  the Pisot condition is the only missing hypothesis of BST23 Theorem 3.1.
  The balanced pair algorithm is no longer needed.

## 2. Candidate sources (to be read; nothing here is verified)

| Key | Candidate statement | Gate status |
|---|---|---|
| CS03 | Clark–Sadun, *When size matters: subshifts and their related tiling spaces*, ETDS 23 (2003). For Pisot substitutions, the suspension's tile lengths do not affect pure-point-ness; this gives an equivalence between the `R`-action and the `Z`-action. | to read: exact hypotheses (irreducible? unimodular?) and the exact conclusion |
| BKw06 | Barge–Kwapisz, *Geometric theory of unimodular Pisot substitutions*, Amer. J. Math. 128 (2006). Pure discrete spectrum ⇔ geometric coincidence, for both the `Z` and `R` actions, under unimodular irreducible Pisot. | to read |
| Barge16-R4.2 | Barge 2016 Remark 4.2 cites both for β-substitutions. | verified as a citation only |

If the sources need a coincidence condition rather than flow PDS, record that
as the hypothesis (R4) and decide it exactly. The kernel already runs the
balanced pair algorithm. A strong-coincidence decider would be the next
predicate.

## 3. Plan

1. **G0 gate §9.** Read CS03 and BKw06 from the primary text. Pin the
   hypotheses and the conclusion, and mark each entry *verified* or
   *cited only*. If neither verifies, stop here and record why.
2. **Hypothesis fidelity (R4).** Check each hypothesis of (T) on Brun
   composites:
   - unimodular: `det β_{i,j} = 1`, closed under composition;
   - primitive and irreducible: kernel predicates;
   - Pisot: kernel predicate;
   - the tile-length convention: Barge's natural lengths versus the constant
     lengths of the symbolic suspension.
3. **State Corollary B″ and Theorem C′** with the statuses the gate allows
   (`proved` resting on imports, or `conditional`).
4. **Calibration (negative and positive controls).**
   - Every composite that passes the BPA in the `d = 4, 5, 6` censuses must
     be consistent with B″.
   - A reducible-χ composite must fall outside B″'s hypotheses. No claim is
     made about it.
5. **Extend the census.** At `d = 7..10`, the exact PIP count (budget-free)
   then supplies Theorem C′'s periodic point directly.

## 4. Deliverables

- `docs/literature-gate-2026-10-09.md` §9: transfer entries with exact
  hypotheses.
- A new section in `docs/sadic-g6-brun-higher-census.md`: Corollary B″,
  Theorem C′.
- Claims registered on every surface (`CLAIMS.md`,
  `claim_governance.toml`), with receipts from the kernel tests that check
  the hypotheses (unimodularity, irreducibility, Pisot) on the pinned
  points.

## 5. Exit criteria

- **Success:** (T) is verified from primary text with hypotheses Brun
  composites satisfy. B″ and C′ are then registered.
- **Partial:** (T) needs an extra hypothesis such as strong coincidence. That
  hypothesis becomes a kernel predicate and the next target.
- **Stop:** neither source verifies. Theorem C stays tied to balanced-pair
  witnesses (branch `claude/brun-theorem-c-higher-d`).

## 6. Relation to the Theorem C branch

The two branches attack the same hypothesis of BST23 Theorem 3.1 from
opposite ends:
- The Theorem C branch supplies a finite certificate per dimension, with no
  import.
- This branch supplies one import that covers every dimension.

Either one closes a cell of the G0 matrix. Both together give independent
confirmation at `d = 5, 6`.
