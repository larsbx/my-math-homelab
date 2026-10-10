"""Conjugates of powers of `sigma` in Barge's PDS class.

Barge (2016) proves pure discrete spectrum for a primitive, non-periodic
substitution with Pisot inflation that is *injective on initial letters and
constant on final letters* (hypotheses as audited in
docs/p1b-strict-zipper-literature-gate-2026-09-21.md). Reversing every image
preserves the spectrum, so the *mirror* class is covered too, and powers and
their maximal left/right rotations have the same spectrum. The exact
membership decision is `substitution_dynamics.barge_class`, over any
alphabet; this module is its view on substitutions given as image lists.

A witness gives PDS for `sigma` by Barge's theorem, hence PPVC by Theorem S
(docs/p1b-vertex-coincidence-box-2026-10-02.md §5.1). This module decides
membership exactly; it proves nothing about specimens without a witness.
"""

from substitution_dynamics import barge_class as sd
from substitution_dynamics.barge_class import (
    BargeWitness,
    KIND_DIRECT,
    KIND_LEFT_ROTATION,
    KIND_NONE,
    KIND_RIGHT_ROTATION,
)
from substitution_dynamics.substitution import Substitution


def _images(t: List[List[Int]]) -> Substitution:
    # Trusted constructor over len(t) letters: unvalidated, as before.
    return Substitution(t.copy(), len(t))


def injective_on_initial(t: List[List[Int]]) -> Bool:
    return sd.injective_on_initial(_images(t))


def injective_on_final(t: List[List[Int]]) -> Bool:
    return sd.injective_on_final(_images(t))


def constant_on_initial(t: List[List[Int]]) -> Bool:
    return sd.constant_on_initial(_images(t))


def constant_on_final(t: List[List[Int]]) -> Bool:
    return sd.constant_on_final(_images(t))


def in_barge_class(t: List[List[Int]]) -> Bool:
    """Injective on initial letters and constant on final letters."""
    return sd.in_barge_class(_images(t))


def in_mirror_class(t: List[List[Int]]) -> Bool:
    """Constant on initial letters and injective on final letters."""
    return sd.in_mirror_class(_images(t))


def common_prefix_length(t: List[List[Int]]) -> Int:
    return sd.common_prefix_length(_images(t))


def common_suffix_length(t: List[List[Int]]) -> Int:
    return sd.common_suffix_length(_images(t))


def rotate_left(t: List[List[Int]], k: Int) -> List[List[Int]]:
    """`tau(a) = u^{-1} t(a) u` for the common prefix `u` of length `k`."""
    return sd.rotate_left(_images(t), k).images.copy()


def rotate_right(t: List[List[Int]], k: Int) -> List[List[Int]]:
    """`tau(a) = v t(a) v^{-1}` for the common suffix `v` of length `k`."""
    return sd.rotate_right(_images(t), k).images.copy()


def barge_witness(sigma: List[List[Int]], max_power: Int) raises -> BargeWitness:
    """The least power `n <= max_power` at which `sigma^n` or its maximal left
    or right rotation lies in Barge's class or its mirror."""
    return sd.barge_witness(_images(sigma), max_power)
