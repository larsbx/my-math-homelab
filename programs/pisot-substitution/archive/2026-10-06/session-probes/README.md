# Session probes behind Theorem H — 2026-10-06

The Python prototype that found the parametric witness-path method of
`docs/p1a-a1-prime-2026-10-05.md` §3d, with its saved output. It is
**provenance, not canonical code** (AGENTS.md): the canonical computation is
`kernel/psc/cone_witness.mojo` with `kernel/swap_family_certificate.mojo` and
`kernel/tests/test_swap_family_certificate.mojo`, which the note cites. The
prototype was written first and independently of the Mojo port; the two reach
the same cover, so it doubles as a cross-check in a second language.

| file | what it is |
| --- | --- |
| `cone_witness_prototype.py` | affine forms, segment images, and the breadth-first search for constant-offset witness paths on a cone |
| `swap_cover_prototype.py` | the per-branch quadrants of the five swap classes and the cover recursion (cone, Lemma P1 cut, or split) |
| `swap_cover_prototype.out` | its output at witness level at most 5 and depth 8: no failure on any branch |
| `swap_cover_validate.py` | instantiates every cone at its sample points and checks the named position on the actual words; then checks that every PIP member with `|det M| = 2`, `p, q, r <= 12`, screened by `reference/psc_research/pip_screen.py`, lies in a cone or is a residual point |
| `swap_cover_validate.out` | its output: all sample checks pass; 639 PIP members of the five classes, 629 in cones, residue exactly the ten points of the note's §3d.3 table |

**Scope.** The prototype runs the five classes only; the Mojo certificate also
runs their five mirrors directly. Neither appeals to the other.

Run from the repository root: `python3 archive/2026-10-06/session-probes/swap_cover_prototype.py 5 8`
and `python3 archive/2026-10-06/session-probes/swap_cover_validate.py 4 12`.
