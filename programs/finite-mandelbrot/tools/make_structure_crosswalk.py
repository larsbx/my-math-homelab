#!/usr/bin/env python3
"""Write docs/structure_crosswalk.json from the atlas and the crosswalk.

The surface joins `schemas/structure_names.toml` and
`schemas/structure_crosswalk.toml` into one typed graph that declares its own
classes and relations, for consumers such as `larsbx/math-vizops` to draw
without deriving anything. The checks live in
`reference/python/atlas/structure_crosswalk_reference.py`; this script refuses
to write a graph those checks reject, including any anchor in this repository
that no longer occurs in its file. (Anchors in sibling repositories need their
checkouts, and emitter sections need the Mojo toolchain; both are checked by
tests/test_structure_crosswalk.py.)

Usage: make_structure_crosswalk.py [--check]
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.atlas import structure_crosswalk_reference as cw  # noqa: E402


def main(argv: list[str]) -> int:
    table, atlas = cw.load(), cw.atlas_by_id()
    errors = cw.table_errors(table, atlas) + [m for o in table["occurrence"] for m in cw.datum_errors(o, atlas)]
    errors += [m for o in table["occurrence"] if o["repo"] == cw.REPOSITORY for m in cw.anchor_errors(o, cw.ROOT)]
    if errors:
        print("refused:\n  " + "\n  ".join(errors))
        return 1
    text, path = cw.render(cw.build(table, atlas)), ROOT / cw.SURFACE
    if "--check" in argv:
        if not path.is_file() or path.read_text(encoding="utf-8") != text:
            print(f"{cw.SURFACE} is stale: run python3 tools/make_structure_crosswalk.py")
            return 1
        print(f"{cw.SURFACE} is current.")
        return 0
    path.write_text(text, encoding="utf-8")
    print(f"wrote {cw.SURFACE}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
