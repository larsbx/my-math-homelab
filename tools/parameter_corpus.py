"""The parameter corpus: the single source of the Phase 0 regime table.

Every row is exactly representable Gaussian-rational data plus the witness a
checker needs, and every claim a row makes is either verified by
`tools/julia_reference.py` (the `VERIFIED` columns of the generated ledger) or
declared as a named, unverified theorem tag (the `TAG` columns). Nothing here
is established by having been written down.

Generated surfaces are rendered from this table by
`tools/make_regime_ledger.py`; a hand-edited surface fails
`make_regime_ledger.py --check` rather than drifting.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from fractions import Fraction as F

from gaussian_q import GQ
from julia_reference import MultiplierClass


class Regime(Enum):
    """Declared parameter regime. The multiplier class and the critical-orbit
    verdict that justify it are checked; the name itself proves nothing."""

    HYPERBOLIC_CENTER = "HYPERBOLIC_CENTER"
    MISIUREWICZ = "MISIUREWICZ"
    PARABOLIC = "PARABOLIC"
    IRRATIONALLY_INDIFFERENT = "IRRATIONALLY_INDIFFERENT"
    ESCAPING = "ESCAPING"


class LocalConnectivity(Enum):
    """What is claimed about local connectivity of `J_c`, and on whose word."""

    TAGGED_LOCALLY_CONNECTED = "TAGGED_LOCALLY_CONNECTED"
    NOT_APPLICABLE_DISCONNECTED = "NOT_APPLICABLE_DISCONNECTED"
    OPEN = "OPEN"


class TagStatus(Enum):
    """What `docs/literature-gate-2026-09-19.md` returned for a row's tag.

    A tag is a named import. `NONE` means the row imports nothing, which is
    what an open cell must do; it never means a tag was assumed.
    """

    ACCEPTED_WITH_QUALIFICATION = "ACCEPTED_WITH_QUALIFICATION"
    NONE = "NONE"


class J1Expectation(Enum):
    """What the separator catalogue must do here if `J1` is sound.

    This column is the point of the corpus: `STABILIZES` rows are the
    confirmation cases, and an `OPEN` row is where a finite non-triviality
    witness would be the deliverable rather than a stabilization proof.
    """

    STABILIZES = "STABILIZES"
    UNDECIDED = "UNDECIDED"
    NOT_APPLICABLE = "NOT_APPLICABLE"


#: The gate that judged every tag below.
GATE = "docs/literature-gate-2026-09-19.md"


@dataclass(frozen=True, slots=True)
class Parameter:
    key: str
    name: str
    c: GQ
    cycle: tuple[GQ, ...] | None
    regime: Regime
    multiplier_class: MultiplierClass | None
    orbit_signature: str
    local_connectivity: LocalConnectivity
    theorem_tag: str | None
    tag_status: TagStatus
    j1_expectation: J1Expectation
    note: str


#: `lam = (3 + 4i)/5`: unit quadrance, degree 2 over `Q`, not a root of unity.
NIVEN_MULTIPLIER = GQ.of(F(3, 5), F(4, 5))

CORPUS: tuple[Parameter, ...] = (
    Parameter(
        key="c0",
        name="superattracting fixed",
        c=GQ.of(0),
        cycle=(GQ.of(0),),
        regime=Regime.HYPERBOLIC_CENTER,
        multiplier_class=MultiplierClass.SUPERATTRACTING,
        orbit_signature="PREPERIODIC(l=0, k=1)",
        local_connectivity=LocalConnectivity.TAGGED_LOCALLY_CONNECTED,
        theorem_tag="DouadyHubbardHyperbolicLocallyConnected",
        tag_status=TagStatus.ACCEPTED_WITH_QUALIFICATION,
        j1_expectation=J1Expectation.STABILIZES,
        note="J_0 is the quadrance-1 locus. It is not a circle at rank 2, and no arc, angle, or circumference is available from it.",
    ),
    Parameter(
        key="basilica",
        name="period-2 centre",
        c=GQ.of(-1),
        cycle=(GQ.of(0), GQ.of(-1)),
        regime=Regime.HYPERBOLIC_CENTER,
        multiplier_class=MultiplierClass.SUPERATTRACTING,
        orbit_signature="PREPERIODIC(l=0, k=2)",
        local_connectivity=LocalConnectivity.TAGGED_LOCALLY_CONNECTED,
        theorem_tag="DouadyHubbardHyperbolicLocallyConnected",
        tag_status=TagStatus.ACCEPTED_WITH_QUALIFICATION,
        j1_expectation=J1Expectation.STABILIZES,
        note="Attracting-cycle certificate with a superattracting witness; the interior is the pullback of the immediate basin.",
    ),
    Parameter(
        key="dendrite",
        name="Misiurewicz dendrite",
        c=GQ.of(0, 1),
        cycle=(GQ.of(-1, 1), GQ.of(0, -1)),
        regime=Regime.MISIUREWICZ,
        multiplier_class=MultiplierClass.REPELLING,
        orbit_signature="PREPERIODIC(l=2, k=2)",
        local_connectivity=LocalConnectivity.TAGGED_LOCALLY_CONNECTED,
        theorem_tag="TanYinGeometricallyFiniteLocallyConnected",
        tag_status=TagStatus.ACCEPTED_WITH_QUALIFICATION,
        j1_expectation=J1Expectation.STABILIZES,
        note="Postcritically finite with empty interior: the IN certificate has nothing to certify, so the classifier is OUT-or-UNKNOWN here.",
    ),
    Parameter(
        key="chebyshev",
        name="Chebyshev endpoint",
        c=GQ.of(-2),
        cycle=(GQ.of(2),),
        regime=Regime.MISIUREWICZ,
        multiplier_class=MultiplierClass.REPELLING,
        orbit_signature="PREPERIODIC(l=2, k=1)",
        local_connectivity=LocalConnectivity.TAGGED_LOCALLY_CONNECTED,
        theorem_tag="TanYinGeometricallyFiniteLocallyConnected",
        tag_status=TagStatus.ACCEPTED_WITH_QUALIFICATION,
        j1_expectation=J1Expectation.STABILIZES,
        note="Degenerate real case: the exclusion machinery must handle a Julia set carried by one rational segment.",
    ),
    Parameter(
        key="cauliflower",
        name="parabolic, multiplier 1",
        c=GQ.of(F(1, 4)),
        cycle=(GQ.of(F(1, 2)),),
        regime=Regime.PARABOLIC,
        multiplier_class=MultiplierClass.PARABOLIC,
        orbit_signature="CAPPED(BIT_BUDGET, n=16)",
        local_connectivity=LocalConnectivity.TAGGED_LOCALLY_CONNECTED,
        theorem_tag="TanYinGeometricallyFiniteLocallyConnected",
        tag_status=TagStatus.ACCEPTED_WITH_QUALIFICATION,
        j1_expectation=J1Expectation.STABILIZES,
        note="Fail-closed case: the multiplier has quadrance exactly 1, so an interval test that decides attracting or repelling here is unsound.",
    ),
    Parameter(
        key="parabolic_minus_one",
        name="parabolic, multiplier -1",
        c=GQ.of(F(-3, 4)),
        cycle=(GQ.of(F(-1, 2)),),
        regime=Regime.PARABOLIC,
        multiplier_class=MultiplierClass.PARABOLIC,
        orbit_signature="CAPPED(BIT_BUDGET, n=16)",
        local_connectivity=LocalConnectivity.TAGGED_LOCALLY_CONNECTED,
        theorem_tag="TanYinGeometricallyFiniteLocallyConnected",
        tag_status=TagStatus.ACCEPTED_WITH_QUALIFICATION,
        j1_expectation=J1Expectation.STABILIZES,
        note="Root of the period-2 component: the same fail-closed obligation with a negative multiplier.",
    ),
    Parameter(
        key="parabolic_i",
        name="parabolic, multiplier i",
        c=GQ.of(F(1, 4), F(1, 2)),
        cycle=(GQ.of(0, F(1, 2)),),
        regime=Regime.PARABOLIC,
        multiplier_class=MultiplierClass.PARABOLIC,
        orbit_signature="CAPPED(BIT_BUDGET, n=16)",
        local_connectivity=LocalConnectivity.TAGGED_LOCALLY_CONNECTED,
        theorem_tag="TanYinGeometricallyFiniteLocallyConnected",
        tag_status=TagStatus.ACCEPTED_WITH_QUALIFICATION,
        j1_expectation=J1Expectation.STABILIZES,
        note="The third of the four Gaussian-rational roots of unity, reached by c = lam (2 - lam) / 4 at lam = i.",
    ),
    Parameter(
        key="niven",
        name="irrationally indifferent",
        c=GQ.of(F(37, 100), F(4, 25)),
        cycle=(GQ.of(F(3, 10), F(2, 5)),),
        regime=Regime.IRRATIONALLY_INDIFFERENT,
        multiplier_class=MultiplierClass.IRRATIONALLY_INDIFFERENT,
        orbit_signature="CAPPED(BIT_BUDGET, n=15)",
        local_connectivity=LocalConnectivity.OPEN,
        theorem_tag=None,
        tag_status=TagStatus.NONE,
        j1_expectation=J1Expectation.UNDECIDED,
        note="Exactly representable data, open dynamics, and open twice over: whether the rotation number of lam = (3 + 4i)/5 is Brjuno decides Siegel against Cremer, and even a Siegel disk leaves local connectivity turning on whether the critical point lies on its boundary. Neither is a finite test on the multiplier.",
    ),
    Parameter(
        key="escaping",
        name="escaping critical orbit",
        c=GQ.of(1),
        cycle=None,
        regime=Regime.ESCAPING,
        multiplier_class=None,
        orbit_signature="ESCAPES(n=3)",
        local_connectivity=LocalConnectivity.NOT_APPLICABLE_DISCONNECTED,
        theorem_tag="FatouJuliaEscapingCantorSet",
        tag_status=TagStatus.ACCEPTED_WITH_QUALIFICATION,
        j1_expectation=J1Expectation.NOT_APPLICABLE,
        note="K_c is disconnected, and the imported fiber theory is stated for compact connected full sets, so the question the other rows answer is not posed here; the escape certificate is.",
    ),
)

BY_KEY = {row.key: row for row in CORPUS}

#: Trap witnesses, by corpus key: a box and the period whose iterate maps it
#: strictly inside itself (`docs/three-valued-classifier.md`). A trap is a
#: witness like a cycle is: it is declared here and verified by
#: `tools/box_classifier.py` before any verdict rests on it. A parameter
#: absent from this table has no trap *in this table*, which is not a claim
#: that none exists -- though for a parabolic parameter none does, and for a
#: parameter with empty interior there is nothing to trap.
TRAPS: dict[str, tuple[tuple[F, F, F, F], int]] = {
    "c0": ((F(-1, 4), F(1, 4), F(-1, 4), F(1, 4)), 1),
    "basilica": ((F(-1, 8), F(1, 8), F(-1, 8), F(1, 8)), 2),
    # The parabolic petal. It is anchored at the parabolic fixed point `1/2`
    # rather than centred anywhere, which is why a search that shrinks toward
    # a midpoint never finds it, and it is invariant without being strictly
    # invariant, which is why it was once thought not to exist.
    "cauliflower": ((F(1, 4), F(1, 2), F(-1, 4), F(1, 4)), 1),
}
