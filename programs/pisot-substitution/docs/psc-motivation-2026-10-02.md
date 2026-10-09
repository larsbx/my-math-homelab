# PSC motivation and scope note — 2026-10-02

## Audit target

This note records why the Pisot Substitution Conjecture (PSC) remains worth pursuing in this repository after the current roadmap narrowed the live theorem target to overlap productivity. It is an orientation document only: it does **not** promote PSC, finite BPA, SCC Producer, realization, concentration, wedge productivity, or any finite-domain census result beyond the status already recorded in the claim ledger, roadmap, and README.

## Motivation summary

The practical mathematical use of PSC is not that it is an engineering primitive. Its use is structural: it asks when a finite local substitution rule forces global order.

In the substitution/tiling setting, the target global order is pure discrete spectrum (PDS). PDS says that the dynamical system has the spectral behavior of a compact group rotation. In tiling language, this is the mathematical form of quasicrystalline order: not periodic, but still rigid enough to have a discrete spectral/diffraction signature under the hypotheses where the standard spectral-diffraction bridges apply.

The repository's current program is valuable because it tries to replace that global statement with finite, checkable mechanisms:

- bounded discrepancy;
- finite seed-patch overlap graphs;
- overlap productivity;
- endpoint-aligned prefix/suffix boundary hitting;
- coincidence density;
- audited import of the density-to-PDS theorem;
- stronger but parallel finite-BPA, SCC, realization, and MEF/collar programs.

This makes PSC useful even before a general proof: every failed or surviving obstruction must be localized as an explicit finite object, a status-tagged bridge, or an imported theorem with audited hypotheses.

## What the repository currently licenses

The current README and docs index already enforce the central status boundary:

```text
primitive irreducible Pisot
=> bounded discrepancy                                  [PROVED]
=> finite seed-patch overlap graph                      [PROVED]
=> one swap seed has only productive reachable overlaps [OPEN]
=> coincidence density one / dense good set             [PROVED]
=> pure discrete spectrum                               [IMPORTED theorem]
```

Therefore the motivation must be stated around the open productivity gate, not around a completed PSC proof. The shortest route is useful because it isolates a single remaining premise on the PDS path. The stronger routes remain useful because they classify how a counter-obstruction would have to look if the shortest route cannot be closed directly.

## Why this belongs in the repo

The repository is now dense with claim-status files, finite certificates, exact-census notes, and proof-route audits. That is correct for mathematical hygiene, but it makes the larger reason for the work easy to lose. A short motivation note gives future contributors and auditors a non-promotional answer to the basic question:

> What is the use of the PSC program?

The answer should be:

> It is a finite, computable attempt to explain when local symbolic substitution laws force global quasicrystalline order, and to expose the exact obstruction if they do not.

## Status-safe formulation

Use this wording in future summaries:

> PSC remains open. The current repository program is useful because it reduces the global PDS target to explicit finite or audited components. The shortest live route has one open gate, overlap productivity from a selected swap seed. Parallel finite-BPA, SCC, concentration, wedge-productivity, realization, and collar programs are retained because they classify possible obstructions and may supply stronger structure, but none of them should be presented as already proving PSC.

Avoid these formulations unless a future proof and ledger update justify them:

- "PSC is closed."
- "The finite corpus proves the general conjecture."
- "BPA finiteness is solved generally."
- "Formal recurrence is the same thing as global realization."
- "All-seed productivity follows from one-seed productivity."
- "SCC Producer / concentration / wedge productivity is solved generally."

## Audit finding

The documentation already has strong status firewalls and current-state surfaces, especially the README, `docs/README.md`, the roadmap, proof ladder, claim-source map, and audit notes. The missing piece was an explicit motivation/orientation document that explains why the work matters without weakening those firewalls. This note fills that gap and deliberately avoids changing any theorem-status surface.
