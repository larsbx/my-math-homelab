"""Mojo include roots for this repository's entrypoints.

The canonical kernel lives under `kernel/mojo/` in domain packages, and the
vendored packages under `vendor/mojo/` (ESTATE.toml, planes kernel and
vendor). Every Mojo run from Python goes through `mojo_run`, with the
repository root as the working directory.
"""

INCLUDE = ("-I", "kernel/mojo", "-I", "vendor/mojo")


def mojo_run(entry: str, mojo: str = "mojo") -> list[str]:
    return [mojo, "run", *INCLUDE, entry]
