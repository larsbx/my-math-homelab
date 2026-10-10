#!/usr/bin/env bash
# Fetch the papers read for the literature gates into refs-local/ (gitignored)
# and verify each against the SHA-256 of the copy read on 2026-10-03/04.
# The repository is public and the papers are not openly licensed, so the
# repository pins and quotes them (literature-quotes.md) but does not
# redistribute them; this restores the exact copies for local, personal use.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p refs-local
fetch() {  # name url sha256
    curl -sSfL -o "refs-local/$1" "$2"
    echo "$3  refs-local/$1" | sha256sum -c -
}
fetch baker-barge-kwapisz-2006-aif-56-7.pdf https://www.numdam.org/item/10.5802/aif.2238.pdf \
    1a3683a0e7eaef3e11a0492857da5ee7471b710aca00cf6fc3083910b23f8ce8
fetch barge-2015-arxiv-1505.04408v2.pdf https://arxiv.org/pdf/1505.04408v2 \
    4edde4708c136439f11b0ffe2747ce9c758246790fd47564ee6fe97536d1b0b8
fetch barge-diamond-2002-bsmf-130-4.pdf https://www.numdam.org/item/10.24033/bsmf.2433.pdf \
    c7f0f79628217c13cda86f374751e125017253d3d69755103e1c637942d333ab
