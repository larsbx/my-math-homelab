# Growing PIP research corpus

This directory is an **append-only research corpus**, separate from the
repository's theorem-facing 4,554-member short-image corpus.

The standing corpus remains exactly the primitive irreducible Pisot
substitutions on three letters with every image length at most three. Existing
finite-domain claims continue to mean that exact set.

The growing corpus starts at exact maximum image length four. Band `L`
contains every non-erasing three-letter substitution whose images have length
at most `L` and at least one image has length exactly `L`. The three band
blocks are ordered by the first image coordinate that has the new length, so
`(L, band_offset)` is a stable permanent specimen address.

## Daily growth

`.github/workflows/grow-corpus-daily.yml` runs once per day and screens a
default budget of 50,000 previously unseen candidates. The workflow writes to
the long-lived `corpus/daily-growth` branch rather than silently changing
the theorem corpus on `main`.

Each daily shard:

- is screened canonically by Mojo's exact `psc.pisot.is_pip` predicate;
- uses MAX-backed deterministic `parallel_fold` across candidates;
- replays every admitted specimen with the independent Python exact oracle;
- samples rejections independently as a false-negative guard;
- records the exact band interval and characteristic cubic;
- names the SHA-256 of the previous shard, forming an append-only hash chain;
- is indexed in `index.jsonl`.

The mutable cursor is `state.json`. State advances only after the whole shard
passes replay, and shard filenames are interval-derived, so a failed or
restarted cron run cannot silently skip work.

## Authority boundary

Membership here means only:

> this explicit substitution was exactly screened as primitive irreducible
> Pisot by the declared kernel revision and replayed as recorded.

It does **not** mean that length-three-only overlap kernels accept it, that a
bounded BPA search terminated, or that any theorem previously proved over the
4,554 corpus has widened scope.

Promotion from this research corpus into a larger finite-domain theorem corpus
requires a separate reviewed domain extension and new completeness regression.

## Manual run

From the repository root:

```bash
python3 tools/grow_corpus.py \
  --state experiments/growing-corpus/state.json \
  --shard-root experiments/growing-corpus/shards \
  --budget 50000 \
  --workers 4
```

The operational image-length cap is currently 8. Hitting it is a hard failure,
not permission to continue with an unaudited larger enumeration.
