#!/usr/bin/env python3
"""Advance the append-only growing PIP research corpus by one deterministic budget.

The canonical acceptance decision is the Mojo `psc.pisot.is_pip` kernel.
Every admitted row is independently replayed here with the Python exact oracle
before state advances. Existing finite-domain theorem corpora are untouched.
"""

from __future__ import annotations

import argparse
import hashlib
import itertools
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "reference"))

from psc_research import pip_screen as oracle  # noqa: E402

STATE_SCHEMA = "psc-growing-corpus-state/v1"
SHARD_SCHEMA = "psc-growing-corpus-shard/v1"
INDEX_SCHEMA = "psc-growing-corpus-index/v1"
DEFAULT_BUDGET = 50_000
DEFAULT_WORKERS = 4
DEFAULT_ORACLE_STRIDE = 257


def image_word_count(max_len: int) -> int:
    if max_len < 0:
        raise ValueError("image length must be nonnegative")
    return sum(3**n for n in range(1, max_len + 1))


def band_total(max_len: int) -> int:
    if max_len < 1:
        raise ValueError("band image length must be positive")
    current = image_word_count(max_len)
    previous = image_word_count(max_len - 1)
    return current**3 - previous**3


def words_up_to(max_len: int) -> list[tuple[int, ...]]:
    return [
        w
        for n in range(1, max_len + 1)
        for w in itertools.product(range(3), repeat=n)
    ]


def band_indices(max_len: int, offset: int) -> tuple[int, int, int]:
    total = band_total(max_len)
    if not 0 <= offset < total:
        raise ValueError("band offset lies outside the band")
    w = image_word_count(max_len)
    previous = image_word_count(max_len - 1)
    new_words = w - previous

    block_a = new_words * w * w
    if offset < block_a:
        i, r = divmod(offset, w * w)
        j, k = divmod(r, w)
        return previous + i, j, k

    q = offset - block_a
    block_b = previous * new_words * w
    if q < block_b:
        i, r = divmod(q, new_words * w)
        j, k = divmod(r, w)
        return i, previous + j, k

    q -= block_b
    i, r = divmod(q, previous * new_words)
    j, k = divmod(r, new_words)
    return i, j, previous + k


def sigma_key_for_offset(max_len: int, offset: int) -> str:
    words = words_up_to(max_len)
    i, j, k = band_indices(max_len, offset)
    return "/".join("".join(str(x) for x in words[t]) for t in (i, j, k))


def oracle_sigma(key: str) -> dict[int, tuple[int, ...]]:
    parts = key.split("/")
    if len(parts) != 3 or any(not part for part in parts):
        raise ValueError(f"malformed substitution key: {key!r}")
    sigma: dict[int, tuple[int, ...]] = {}
    for letter, part in enumerate(parts, start=1):
        if any(ch not in "012" for ch in part):
            raise ValueError(f"substitution key lies outside alphabet 0..2: {key!r}")
        sigma[letter] = tuple(int(ch) + 1 for ch in part)
    return sigma


def oracle_is_pip(key: str) -> tuple[bool, tuple[int, int, int]]:
    sigma = oracle_sigma(key)
    matrix = oracle.mat(sigma)
    t, u, d = oracle.charpoly(matrix)
    verdict = (
        oracle.primitive(matrix)
        and oracle.irreducible(t, u, d)
        and oracle.pisot(t, u, d)
    )
    return verdict, (-d, u, -t)


def parse_driver_output(text: str) -> tuple[dict[str, str], list[tuple[int, str, tuple[int, int, int]]]]:
    header: dict[str, str] = {}
    accepted: list[tuple[int, str, tuple[int, int, int]]] = []
    for raw in text.splitlines():
        if not raw:
            continue
        fields = raw.split("\t")
        if fields[0] == "A":
            if len(fields) != 6:
                raise ValueError(f"malformed accepted row: {raw!r}")
            accepted.append(
                (
                    int(fields[1]),
                    fields[2],
                    (int(fields[3]), int(fields[4]), int(fields[5])),
                )
            )
            continue
        if len(fields) < 2:
            raise ValueError(f"malformed driver header: {raw!r}")
        header[fields[0]] = "\t".join(fields[1:])
    required = {
        "schema",
        "max_image_length",
        "start_offset",
        "screened",
        "accepted",
        "next_offset",
        "band_total",
        "columns",
    }
    missing = required - header.keys()
    if missing:
        raise ValueError(f"driver output lacks headers: {sorted(missing)}")
    if header["schema"] != SHARD_SCHEMA:
        raise ValueError(f"unexpected shard schema: {header['schema']!r}")
    if int(header["accepted"]) != len(accepted):
        raise ValueError("accepted count disagrees with emitted rows")
    return header, accepted


def run_mojo_shard(
    mojo_dir: Path, max_len: int, start: int, count: int, workers: int
) -> tuple[dict[str, str], list[tuple[int, str, tuple[int, int, int]]]]:
    proc = subprocess.run(
        [
            "pixi",
            "run",
            "mojo",
            "run",
            "-I",
            ".",
            "growing_corpus_census.mojo",
            str(max_len),
            str(start),
            str(count),
            str(workers),
        ],
        cwd=mojo_dir,
        text=True,
        capture_output=True,
        check=False,
    )
    if proc.returncode:
        sys.stderr.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        raise RuntimeError(f"Mojo growing-corpus shard failed with exit {proc.returncode}")
    return parse_driver_output(proc.stdout)


def verify_shard(
    max_len: int,
    start: int,
    count: int,
    header: dict[str, str],
    accepted: list[tuple[int, str, tuple[int, int, int]]],
    oracle_stride: int,
) -> None:
    expected_total = band_total(max_len)
    if (
        int(header["max_image_length"]) != max_len
        or int(header["start_offset"]) != start
        or int(header["screened"]) != count
        or int(header["next_offset"]) != start + count
        or int(header["band_total"]) != expected_total
    ):
        raise ValueError("driver shard metadata disagrees with requested slice")

    accepted_offsets: set[int] = set()
    for offset, key, chi in accepted:
        if offset in accepted_offsets:
            raise ValueError(f"duplicate accepted band offset: {offset}")
        accepted_offsets.add(offset)
        if not start <= offset < start + count:
            raise ValueError(f"accepted offset outside requested slice: {offset}")
        if sigma_key_for_offset(max_len, offset) != key:
            raise ValueError(f"accepted substitution identity mismatch at offset {offset}")
        verdict, oracle_chi = oracle_is_pip(key)
        if not verdict:
            raise ValueError(f"Mojo admitted a specimen the independent oracle rejects: {key}")
        if oracle_chi != chi:
            raise ValueError(f"characteristic polynomial mismatch for {key}")

    if oracle_stride < 1:
        raise ValueError("oracle stride must be positive")
    for offset in range(start, start + count, oracle_stride):
        key = sigma_key_for_offset(max_len, offset)
        verdict, _ = oracle_is_pip(key)
        if verdict != (offset in accepted_offsets):
            raise ValueError(
                f"sampled Mojo/Python PIP disagreement at L={max_len}, offset={offset}"
            )


def load_state(path: Path) -> dict:
    state = json.loads(path.read_text(encoding="utf-8"))
    if state.get("schema") != STATE_SCHEMA:
        raise ValueError("growing corpus state schema mismatch")
    for key in (
        "alphabet",
        "next_max_image_length",
        "next_band_offset",
        "total_screened",
        "total_accepted",
        "max_image_length_cap",
        "last_shard_sha256",
    ):
        if key not in state:
            raise ValueError(f"growing corpus state lacks {key}")
    if state["alphabet"] != 3:
        raise ValueError("growing corpus alphabet must remain three")
    return state


def canonical_shard(
    *,
    max_len: int,
    start: int,
    count: int,
    total: int,
    previous_sha256: str,
    accepted: Iterable[tuple[int, str, tuple[int, int, int]]],
) -> bytes:
    lines = [
        f"# schema={SHARD_SCHEMA}",
        f"# max_image_length={max_len}",
        f"# start_offset={start}",
        f"# screened={count}",
        f"# next_offset={start + count}",
        f"# band_total={total}",
        f"# previous_sha256={previous_sha256}",
        "offset\tsubstitution\tchi0\tchi1\tchi2",
    ]
    for offset, key, chi in accepted:
        lines.append(f"{offset}\t{key}\t{chi[0]}\t{chi[1]}\t{chi[2]}")
    return ("\n".join(lines) + "\n").encode()


def append_index(index_path: Path, record: dict) -> None:
    index_path.parent.mkdir(parents=True, exist_ok=True)
    with index_path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, sort_keys=True, separators=(",", ":")) + "\n")


def advance(
    *,
    state_path: Path,
    shard_root: Path,
    budget: int,
    workers: int,
    oracle_stride: int,
    kernel_revision: str,
) -> list[Path]:
    if budget < 1:
        raise ValueError("daily candidate budget must be positive")
    if workers < 1:
        raise ValueError("worker count must be positive")

    state = load_state(state_path)
    mojo_dir = ROOT / "kernel"
    index_path = state_path.parent / "index.jsonl"
    written: list[Path] = []
    remaining = budget

    while remaining:
        max_len = int(state["next_max_image_length"])
        if max_len > int(state["max_image_length_cap"]):
            raise RuntimeError(
                "growing corpus reached its audited operational image-length cap"
            )
        total = band_total(max_len)
        start = int(state["next_band_offset"])
        if not 0 <= start < total:
            raise ValueError("state band offset lies outside current band")
        count = min(remaining, total - start)

        header, accepted = run_mojo_shard(mojo_dir, max_len, start, count, workers)
        verify_shard(max_len, start, count, header, accepted, oracle_stride)

        previous = str(state["last_shard_sha256"])
        payload = canonical_shard(
            max_len=max_len,
            start=start,
            count=count,
            total=total,
            previous_sha256=previous,
            accepted=accepted,
        )
        digest = hashlib.sha256(payload).hexdigest()
        end = start + count - 1
        relative = Path(f"L{max_len:04d}") / f"{start:012d}-{end:012d}.tsv"
        path = shard_root / relative
        if path.exists():
            raise RuntimeError(f"refusing to overwrite existing corpus shard {path}")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(payload)

        append_index(
            index_path,
            {
                "schema": INDEX_SCHEMA,
                "path": str(relative.as_posix()),
                "sha256": digest,
                "previous_sha256": previous,
                "max_image_length": max_len,
                "start_offset": start,
                "screened": count,
                "accepted": len(accepted),
                "kernel_revision": kernel_revision,
            },
        )

        state["total_screened"] = int(state["total_screened"]) + count
        state["total_accepted"] = int(state["total_accepted"]) + len(accepted)
        state["last_shard_sha256"] = digest
        state["last_shard"] = str(relative.as_posix())
        next_offset = start + count
        if next_offset == total:
            state["next_max_image_length"] = max_len + 1
            state["next_band_offset"] = 0
        else:
            state["next_band_offset"] = next_offset

        written.append(path)
        remaining -= count

    tmp = state_path.with_suffix(".tmp")
    tmp.write_text(json.dumps(state, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    os.replace(tmp, state_path)
    return written


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--state", type=Path, required=True)
    parser.add_argument("--shard-root", type=Path, required=True)
    parser.add_argument("--budget", type=int, default=DEFAULT_BUDGET)
    parser.add_argument("--workers", type=int, default=DEFAULT_WORKERS)
    parser.add_argument("--oracle-stride", type=int, default=DEFAULT_ORACLE_STRIDE)
    parser.add_argument("--kernel-revision", default=os.environ.get("GITHUB_SHA", "local"))
    args = parser.parse_args()

    written = advance(
        state_path=args.state,
        shard_root=args.shard_root,
        budget=args.budget,
        workers=args.workers,
        oracle_stride=args.oracle_stride,
        kernel_revision=args.kernel_revision,
    )
    state = load_state(args.state)
    print(
        "growing corpus advanced:",
        f"shards={len(written)}",
        f"total_screened={state['total_screened']}",
        f"total_accepted={state['total_accepted']}",
        f"next=L{state['next_max_image_length']}:{state['next_band_offset']}",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
