import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

import audit_manuscript  # noqa: E402


def write(root: Path, rel: str, text: str) -> Path:
    path = root / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    return path


def test_audit_accepts_current_correct_formulations(tmp_path: Path) -> None:
    write(
        tmp_path,
        "paper.tex",
        """
        The synthetic algebraic solution is $N_C=M_\\sigma^\\top$ with $P=I$.
        The matrix acts on an invariant subspace as a similar copy of $M_\sigma$.
        Then, conditional on the SCC Producer Theorem, the associated tiling
        dynamical system has pure discrete spectrum.
        """,
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 0


def test_audit_rejects_untransposed_synthetic_countermodel(tmp_path: Path) -> None:
    write(tmp_path, "bad.md", "The synthetic countermodel is N_C = M_sigma with P = I.")
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 1


def test_audit_rejects_old_cycle_exclusion_target(tmp_path: Path) -> None:
    write(tmp_path, "bad.tex", "We prove there is no recurrent noncoincident cycle.")
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 1


def test_audit_rejects_unconditional_pds_claim(tmp_path: Path) -> None:
    write(
        tmp_path,
        "bad.tex",
        "Then the associated tiling dynamical system has pure discrete spectrum.",
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 1


def test_audit_rejects_loose_subblock_language(tmp_path: Path) -> None:
    write(tmp_path, "bad.md", "N_C contains M_sigma as an invariant sub-block.")
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 1


def test_audit_accepts_parikh_intertwiner(tmp_path: Path) -> None:
    write(
        tmp_path,
        "paper.md",
        "The proved identity is P_C N_C = M_sigma P_C with rank(P_C)=3.",
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 0


def test_audit_accepts_transpose_guidance_that_quotes_bad_form(tmp_path: Path) -> None:
    write(
        tmp_path,
        "guide.md",
        "No stale N_C = M_sigma synthetic-countermodel language; it must be "
        "N_C = M_sigma^T, P = I.",
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 0


def test_audit_accepts_historical_cycle_exclusion_rejection(tmp_path: Path) -> None:
    write(
        tmp_path,
        "history.tex",
        'The earlier target "no recurrent noncoincident cycle" is false.',
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 0


def test_audit_accepts_no_longer_cycle_target_wording(tmp_path: Path) -> None:
    write(
        tmp_path,
        "ledger.md",
        'The target is no longer "there are no recurrent noncoincident cycles".',
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 0


def test_audit_rejects_bad_assignment_beside_intertwiner(tmp_path: Path) -> None:
    write(
        tmp_path,
        "bad.md",
        "P_C N_C = M_sigma P_C holds, but the synthetic countermodel sets "
        "N_C = M_sigma with P = I.",
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 1


def test_audit_accepts_latex_transpose_guidance(tmp_path: Path) -> None:
    write(
        tmp_path,
        "guide.tex",
        r"The stale N_C = M_sigma must instead be N_C = M_sigma^\top.",
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 0


def test_audit_rejects_affirmative_earlier_cycle_claim(tmp_path: Path) -> None:
    write(
        tmp_path,
        "bad.md",
        "Earlier work proves there is no recurrent noncoincident cycle.",
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 1


def test_audit_accepts_wrapped_cycle_rejection(tmp_path: Path) -> None:
    write(
        tmp_path,
        "history.tex",
        'The old target was "no recurrent noncoincident cycle"\nand is false.',
    )
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 0


@pytest.mark.parametrize(
    "text",
    [
        "Project premise: the general Pisot Substitution Conjecture is treated as closed.",
        "This is a post-PSC research programme.",
        "# Tier 2: post-PSC Growth Bridge research programme",
        "Since PSC is now proved, Tier 2 builds on it.",
        "The PSC has been settled for all Pisot substitutions.",
        "Results:\n\n- PSC is closed.\n- The corpus is finite.",
        "Avoid overclaiming.\n\n- PSC is closed.",
    ],
)
def test_audit_rejects_psc_closed_premise(tmp_path: Path, text: str) -> None:
    write(tmp_path, "bad.md", text)
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 1


@pytest.mark.parametrize(
    "text",
    [
        "Never describe overlap productivity, SCC Producer, or PSC as proved.",
        'The earlier premise that PSC is closed is withdrawn.',
        "PSC remains open; Tier 2 does not assume it.",
        "See `archive/tier2-post-psc-draft.md` for the old path.",
        "Avoid these formulations unless a proof justifies them:\n\n- \"PSC is closed.\"\n- \"BPA finiteness is solved.\"",
    ],
)
def test_audit_accepts_psc_open_framing(tmp_path: Path, text: str) -> None:
    write(tmp_path, "ok.md", text)
    assert audit_manuscript.main(["--root", str(tmp_path)]) == 0
