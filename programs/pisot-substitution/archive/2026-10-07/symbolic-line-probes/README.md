# Session probes behind Theorem L — 2026-10-07

Exploratory scripts behind `docs/p1b-catch-up-free-ppvc-2026-10-07.md` and
`docs/p1b-symbolic-line-2026-10-07.md`, with saved output. They are
**provenance, not canonical code** (AGENTS.md). The canonical computation is
`kernel/psc/symbolic_line.mojo` with `kernel/symbolic_line_certificate.mojo`
and `kernel/tests/test_symbolic_line.mojo`.

| file | what it is |
| --- | --- |
| `symbolic_line_series_prototype.py` | the symbolic seed-overlap closure of the class B line `x -> x y^(2q+2) x, c -> c y^q x, y -> c y^(q+1) x`, deciding signs and floors from Laurent expansions of `beta` in `1/q` (exact rationals; eventual signs only, no threshold) — a different decision method from the Mojo port's parametric Sturm–Tarski queries |
| `symbolic_line_series_prototype.out` | its output: `beta = q + 4 − 3/q + 14/q^2 − …`, `ell → (2, 1, 1)`, closures of 116, 114 and 117 vertices from the three seeds (119 in union), all offsets constant, every vertex with an offset-zero descendant |
| `box_graph_float_probe.py`, `box_radii_float_probe.py` | **floating-point** box-graph prototype used only to look for structure past the exact kernel's image-length cap; its counts were checked against the exact kernel on five members before use |
| `recurrent_set_compare_probe.py` | compares recurrent sets of that prototype across members (found the constant 120-vertex set on the line) |
| `trap_float_probe.py`, `trap_float_probe.out` | the one-step contracting trapping region along the line: finite but slowly growing (413 to 593 lattice points for `q = 2..25`), which is why the certificate uses the seed closure instead |

**Never a certificate.** The float probes decide realness with a tolerance;
nothing in a proof rests on them.
