#!/usr/bin/env python3
"""Repository scaffold checks.

These lightweight source checks complement the Mojo execution wired into CI.
They enforce the design invariant and verify that expected demo entrypoints
remain in the staged Mojo files.
"""

from __future__ import annotations

from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_no_forbidden_trig_tokens_in_src() -> None:
    result = subprocess.run(
        [sys.executable, str(ROOT / "tools" / "audit_no_trig.py")],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    assert result.returncode == 0, result.stdout + result.stderr


def test_rational_arithmetic_demo_entrypoints_exist() -> None:
    text = read("vendor/mojo/finite_exact/rat_q.mojo")
    assert "def demo_q_normalization()" in text
    assert "def demo_q_order()" in text


def test_interval_demo_entrypoints_exist() -> None:
    text = read("vendor/mojo/finite_exact/closed_q.mojo")
    assert "def demo_interval_mul()" in text
    assert "def demo_complex_quadrance_point()" in text


def test_ray_address_not_angle_api() -> None:
    text = read("kernel/mojo/arithmetic/rational_trig.mojo") + read("kernel/mojo/dynamics/ray_address.mojo")
    assert "struct RayAddr64" not in text
    assert "double_mod_one" in text
    assert "RatAngle" not in text
    assert "double_angle" not in text
