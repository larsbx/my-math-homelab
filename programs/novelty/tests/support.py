"""Shared test plumbing: repository paths and loading scripts by path."""
import importlib.util
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
for sub in ("kernel", "vendor"):
    if str(ROOT / sub) not in sys.path:
        sys.path.insert(0, str(ROOT / sub))


def load(rel: str, name: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / rel)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module
