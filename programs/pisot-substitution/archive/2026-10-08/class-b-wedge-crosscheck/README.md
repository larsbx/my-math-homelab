# Class B wedge cross-check — 2026-10-08

A second certificate of part of Theorem C
(`docs/p1b-symbolic-cone-2026-10-08.md`), written in parallel with it. It used a
second engine: the line engine `psc.symbolic_line` with its coefficient ring
generalised to `Q[s, d]`. Its decision procedures are separate from Theorem C's,
but it shares `symbolic_line`'s primitives with `psc.symbolic_cone` (see that
note §4). That engine is not on `main`, because it duplicates
`psc.symbolic_cone`. It is kept at commit `5ee3f0f`, the second parent of the
`ours` merge `8a9c88a`. That merge is in `main`'s history because the PR was
merged with a merge commit, not squashed. Reproduce with `git checkout 5ee3f0f`, then
`cd kernel`, then:

    mojo run -I . symbolic_wedge_certificate.mojo wedge 1
    mojo run -I . symbolic_wedge_certificate.mojo wedge -1

- `cones.out` holds the four two-parameter cones of the wedge `q < p < 2q`:

  | cone | parameters | `q`, `p` |
  | --- | --- | --- |
  | A | `(e, d)` | `q = e + 2d`, `p = 2e + 3d` |
  | B | `(s, e)` | `q = 2s + e`, `p = 3s + e` |

  Each is certified on a quadrant and cross-checked against the exact kernel
  at four points.
- `boundary.out` holds the 54 lines that cover the rest of the wedge, each
  certified as a line (symbolic part and exact finite part). A family is
  `[p0, pt, pd, q0, qt, qd, branch]`, followed by `q0`, the symbolic vertices,
  PIP / not PIP / outside below `q0`, and wall-clock seconds.

Provenance, not a proof. The proof is Theorem C.
