# Total-length separation sweep — exact finite evidence

Source: `9a59dcd4a8fe22958ab2d36cfa8ab8c9c5ce7aab`, merged by PR #184 as
`7c7cf103a7ca1743ea8065b230249ace8855637f`.

[Successful run 36966474792](https://github.com/larsbx/pisot-substitution-conjecture-research/actions/runs/36966474792),
artifact `11210858208`. `evidence.zip` preserves that artifact byte-for-byte,
including all 24,486 specimen outcomes and the passing canonical test receipts.
`summary.json` derives the radius distribution, every exceptional specimen,
canonical orbit counts and all emitted proper-power witnesses from the log.
`SHA256SUMS` binds both files. No theorem or ledger status changes.

Replay from the repository root:

```sh
(cd mojo && pixi run separation-radius-total-length-sweep)
python scripts/check_separation_receipts.py
python -m pytest tests/test_separation_receipts.py
(cd archive/2026-10-02/separation-radius-total-length && sha256sum -c SHA256SUMS)
```

The independent Python receipt checker screens the complete total-length
class with the existing exact Python PIP oracle, then checks membership,
order, accounting, relabelling/reversal representatives and power witnesses.
It does **not** independently recompute separation radii. Negative controls
reject missing completion, missing specimens, inconclusive records and an
altered histogram.

Budgets: overlap states 20,000; collared states 2,000,000; radii 0–12;
proper-power witness levels 1–6. A power witness supplies structural
nonseparation under the existing occurrence contract. Otherwise any cap
refuses completion. The complete run has 23,634 finite radii, 852 witnessed
obstructions and zero inconclusive specimens. All 12 specimens above radius
6 separate at radius 9 in the single orbit represented by `012001/2/0`.

#84, #138, #139 and PSC remain open. This is not a reconstruction of the lost
criterion, a universal finite radius bound, or a new pump-lift survey.
