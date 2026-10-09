# Session probe behind the A1′ note — 2026-10-05

The exploratory sweep cited in `docs/p1a-a1-prime-2026-10-05.md` §3a, with its
saved output. It is **provenance, not canonical code** (AGENTS.md): a Python
prototype in the sanctioned oracle layer, not a certificate. The theorems the
note states — Lemma D0, Propositions A, B and D, Corollaries C3, D1 and D2 —
are proved by hand there and do not rest on this probe. The probe supplies one
thing only: the exploratory evidence table, labelled as such.

| file | what it is |
| --- | --- |
| `a1prime_normal_form_sweep.py` | sweeps the Proposition D normal form `sigma(x) = x y^p s_x`, `sigma(c) = c y^q s_c`, `sigma(y) = t y^r s_y` over three stated budgets, keeps the PIP members with `|det M| = 2`, and decides A1′ by scanning for a shared tile |
| `a1prime_normal_form_sweep.out` | its output, re-run for this archive |
| `a1prime_theorem_check.py` | independent check of Theorem E's proof skeleton (note §3b): at every `|det M| = 2` point of the four classes it verifies that each lemma's *named* position is a shared tile, that every PIP point satisfies `f(1) < 0` and `f(-1) < 0`, and that the PIP points outside the lemmas are exactly the 27 listed. It checks named positions rather than searching, so it tests the proofs |
| `a1prime_theorem_check.out` | its output at bound 22: 1,988 named witnesses, none failing; 1,404 PIP points satisfying both inequalities; residue equal to the predicted list in all four classes |

**Method.** Equal Parikh prefixes have equal length, because the components of
a Parikh vector sum to the word length. So a common vertex of
`u = sigma^infinity(x)` and `w = sigma^infinity(c)` is an index `s` with
`pi(u[0:s]) = pi(w[0:s])`, and a shared tile is such an `s` with
`u[s] = w[s]`. That makes the search one linear scan with two integer
counters — no floating point, no rational arithmetic, no lattice reduction.
The PIP screen is `reference/psc_research/pip_screen.py`, which is exact
(Sturm sequences).

**Budget, and what an exhausted budget means.** Three nested ranges,
`p, q, r <= 5`, `<= 8` and `<= 11`, each with a word-length cap of 2,000,000
letters. A member whose shared tile is not found within the cap is reported in
its own column, `A1' not witnessed within the cap`, and is **not** counted as
a verdict either way. That column is zero on all three budgets. A member with
a parameter outside the range is not covered at all.

**What the output says.** 174, 420 and 766 PIP members with `|det M| = 2`;
A1′ witnessed on every one; coincidence level at most 7 throughout; and the
level distribution's tail is *identical* across the three budgets — 8 members
at level 4, 2 at level 5, 2 at level 6, 2 at level 7 — while only the level-2
and level-3 counts grow. The 14 members of level at least 4 form 7 mirror
pairs under the relabelling `x <-> c`, all with `p, q, r <= 3`.

**Ported.** `kernel/a1_normal_form_census.mojo` with
`kernel/tests/test_a1_normal_form.mojo` is now the canonical computation, and
the note cites it. It decides each member with the canonical exact
`psc.coincidence_formula.coincidence_level` rather than this probe's ad-hoc
scan, so a negative there is a verdict and the driver raises on one. It
reproduces this probe cell for cell at bounds 5 and 8 — 174 and 420 members,
level histograms 96/64/8/2/2/2 and 268/138/8/2/2/2, the same 14 deep members.
This probe is kept only as provenance: it is what found the result first, and
its bound-11 row is the one figure the Mojo regression does not pin.
