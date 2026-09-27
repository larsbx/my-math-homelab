import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
for plane in ("vendor/python", "tools", "oracles", "reference"):
    sys.path.insert(0, str(ROOT / plane))
