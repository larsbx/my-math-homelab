#!/usr/bin/env python3
"""Compatibility shim.

Canonical reference implementation: reference/python/polynomial/poly_reference.py
This path remains temporarily for historical callers; new code must import or
execute the reference-plane implementation directly.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from reference.python.polynomial.poly_reference import *  # noqa: F401,F403,E402

if __name__ == "__main__":
    raise SystemExit(main())
