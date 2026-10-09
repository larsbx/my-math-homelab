#!/usr/bin/env bash
# Only export provenance/reproduction here; computation lives in canonical Mojo.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
mojo build -I . ordered_hub_packets.mojo -o build/ordered-hub-packets
for fixture in real-secondary non-pisot-strict gf-actual; do
    case "$fixture" in
        real-secondary) key=1/02/202 ;;
        non-pisot-strict) key=1/012/1 ;;
        gf-actual) key=1/2/021 ;;
    esac
    build/ordered-hub-packets --sigma "$key" > "build/ordered-hub-$fixture.jsonl"
    cmp "../evidence/ordered-hub-packets-2026-10-06/$fixture.jsonl" "build/ordered-hub-$fixture.jsonl"
done
if build/ordered-hub-packets --sigma x/1/2 > build/ordered-hub-invalid.log 2>&1; then
    echo "ERROR: invalid ordered-hub input succeeded" >&2
    exit 1
fi
cd ..
sha256sum -c evidence/ordered-hub-packets-2026-10-06/INPUT_SHA256SUMS
sha256sum -c evidence/ordered-hub-packets-2026-10-06/SHA256SUMS
echo "PASS ordered-hub words, local offsets, source hashes, and golden replay"
