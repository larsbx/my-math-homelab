"""The Mojo toolchain is pinned: no MAX or Mojo package floats."""

import re
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


MODULAR_PACKAGE = re.compile(
    r"conda\.modular\.com/max/[a-z0-9-]+/(?P<name>[a-z0-9-]+?)-(?P<version>\d[^-/]*)-[^-/]+\.conda"
)


def test_every_modular_package_in_the_lock_is_pinned_in_the_manifest():
    """A fresh solve may not move any MAX or Mojo package: each one the lock
    takes from the Modular channel is pinned by `==` to its locked version."""
    manifest = tomllib.loads((ROOT / "pixi.toml").read_text(encoding="utf-8"))
    locked = {
        m["name"]: m["version"]
        for m in MODULAR_PACKAGE.finditer((ROOT / "pixi.lock").read_text(encoding="utf-8"))
    }
    assert {"mojo", "mojo-compiler", "mojo-python"} <= set(locked)
    assert {name: manifest["dependencies"].get(name) for name in locked} == {
        name: f"=={version}" for name, version in locked.items()
    }
