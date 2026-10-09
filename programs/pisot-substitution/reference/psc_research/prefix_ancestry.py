"""Multi-level ancestry for substitution prefix cuts.

Each desubstitution step lifts two possibly asynchronous prefix cuts through one
substitution layer.  If x_k is the Parikh difference of the two prefixes at
level k, then exactly

    x_{k+1} = M x_k + c_{k+1},

where c_{k+1} is a difference of two proper image-prefix Parikh vectors.

For a top-level zero return, x_n=0.  The companion proof note shows that under
the PIP spectral hypothesis, if x_0 ranges over a finite base set then every
intermediate integral x_k lies in a finite depth-independent set: stable
coordinates are bounded forward, and the Perron coordinate is bounded backward
from x_n=0.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence

from .bpa import State, Substitution, alphabet_size, apply_substitution, apply_substitution_n, parikh
from .fixed_vector import add as _add, matvec as _matvec, sub as _sub
from .intertwiner import substitution_incidence
from .prefix_difference import (
    Vector,
    asynchronous_prefix_difference,
    local_image_prefix_vector,
    locate_inflated_cut,
)


@dataclass(frozen=True)
class AncestryStep:
    """One exact affine desubstitution relation x_level=M*x_source+c."""

    level: int
    top_output_cut: int
    bottom_output_cut: int
    top_source_cut: int
    bottom_source_cut: int
    top_offset: int
    bottom_offset: int
    source_difference: Vector
    correction: Vector
    output_difference: Vector

    @property
    def source_index_offset(self) -> int:
        return self.top_source_cut - self.bottom_source_cut

    @property
    def output_index_offset(self) -> int:
        return self.top_output_cut - self.bottom_output_cut

    @property
    def source_aligned_on_both_sides(self) -> bool:
        return self.top_offset == 0 and self.bottom_offset == 0


@dataclass(frozen=True)
class AncestryPath:
    """Low-to-high sequence of affine ancestry steps."""

    depth: int
    steps: tuple[AncestryStep, ...]

    @property
    def defects(self) -> tuple[Vector, ...]:
        if not self.steps:
            return ()
        return (self.steps[0].source_difference,) + tuple(
            step.output_difference for step in self.steps
        )

    @property
    def corrections(self) -> tuple[Vector, ...]:
        return tuple(step.correction for step in self.steps)

    @property
    def ends_at_zero(self) -> bool:
        return bool(self.steps) and all(x == 0 for x in self.steps[-1].output_difference)

    def repeated_defects(self, *, nonzero_only: bool = False) -> tuple[Vector, ...]:
        seen: set[Vector] = set()
        repeated: set[Vector] = set()
        for defect in self.defects:
            if nonzero_only and not any(defect):
                continue
            if defect in seen:
                repeated.add(defect)
            seen.add(defect)
        return tuple(sorted(repeated))


def asynchronous_inflated_prefix_step(
    sigma: Substitution,
    top_word: Sequence[int],
    bottom_word: Sequence[int],
    top_output_cut: int,
    bottom_output_cut: int,
    *,
    level: int = 1,
) -> AncestryStep:
    """Lift two independent cuts through one substitution layer exactly."""
    if level < 1:
        raise ValueError("level must be positive")
    size = alphabet_size(sigma)
    top_image = apply_substitution(sigma, top_word)
    bottom_image = apply_substitution(sigma, bottom_word)
    if top_output_cut < 0 or top_output_cut > len(top_image):
        raise ValueError("top output cut outside inflated word")
    if bottom_output_cut < 0 or bottom_output_cut > len(bottom_image):
        raise ValueError("bottom output cut outside inflated word")

    i, r = locate_inflated_cut(sigma, top_word, top_output_cut)
    j, s = locate_inflated_cut(sigma, bottom_word, bottom_output_cut)
    source = asynchronous_prefix_difference(top_word, bottom_word, i, j, size)
    top_local = local_image_prefix_vector(sigma, top_word, i, r, size)
    bottom_local = local_image_prefix_vector(sigma, bottom_word, j, s, size)
    correction = _sub(top_local, bottom_local)
    output = _sub(
        parikh(top_image[:top_output_cut], size),
        parikh(bottom_image[:bottom_output_cut], size),
    )
    reconstructed = _add(_matvec(substitution_incidence(sigma), source), correction)
    if reconstructed != output:
        raise AssertionError("multi-level prefix ancestry identity failed")

    return AncestryStep(
        level=level,
        top_output_cut=top_output_cut,
        bottom_output_cut=bottom_output_cut,
        top_source_cut=i,
        bottom_source_cut=j,
        top_offset=r,
        bottom_offset=s,
        source_difference=source,
        correction=correction,
        output_difference=output,
    )


def multilevel_prefix_ancestry(
    sigma: Substitution,
    state: State,
    depth: int,
    top_cut: int,
    bottom_cut: int | None = None,
) -> AncestryPath:
    """Desubstitute a pair of cuts through ``depth`` levels.

    ``top_cut`` and ``bottom_cut`` are positions in sigma^depth(state).  For a
    balanced top-level zero return they are equal, but lower source cuts are
    allowed to become asynchronous.  Returned steps are ordered level 1..depth.
    """
    if depth < 1:
        raise ValueError("depth must be at least one")
    size = alphabet_size(sigma)
    u0, v0 = state
    if parikh(u0, size) != parikh(v0, size):
        raise ValueError("multi-level ancestry requires a balanced base state")
    if bottom_cut is None:
        bottom_cut = top_cut

    top = top_cut
    bottom = bottom_cut
    descending: list[AncestryStep] = []
    for level in range(depth, 0, -1):
        top_source_word = apply_substitution_n(sigma, u0, level - 1)
        bottom_source_word = apply_substitution_n(sigma, v0, level - 1)
        step = asynchronous_inflated_prefix_step(
            sigma,
            top_source_word,
            bottom_source_word,
            top,
            bottom,
            level=level,
        )
        descending.append(step)
        top = step.top_source_cut
        bottom = step.bottom_source_cut

    steps = tuple(reversed(descending))
    for k in range(len(steps) - 1):
        if steps[k].output_difference != steps[k + 1].source_difference:
            raise AssertionError("adjacent ancestry levels do not share the same defect")
    return AncestryPath(depth=depth, steps=steps)


def top_zero_return_ancestry(
    sigma: Substitution,
    state: State,
    depth: int,
    cut: int,
) -> AncestryPath:
    """Ancestry of an aligned zero-return cut in sigma^depth(state)."""
    size = alphabet_size(sigma)
    u, v = state
    top = apply_substitution_n(sigma, u, depth)
    bottom = apply_substitution_n(sigma, v, depth)
    if len(top) != len(bottom):
        raise AssertionError("balanced iterates have unequal length")
    if cut < 0 or cut > len(top):
        raise ValueError("cut outside top-level words")
    if parikh(top[:cut], size) != parikh(bottom[:cut], size):
        raise ValueError("requested cut is not a zero return")
    path = multilevel_prefix_ancestry(sigma, state, depth, cut, cut)
    if not path.ends_at_zero:
        raise AssertionError("zero-return ancestry did not end at zero")
    return path
