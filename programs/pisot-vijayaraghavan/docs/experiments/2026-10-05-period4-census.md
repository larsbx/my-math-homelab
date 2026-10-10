# Initial period-four census — 2026-10-05

**Status:** COMPUTED finite evidence, non-authoritative.
The authoritative record is PV-PERIOD4-CENSUS in proof/claims.toml.

## Parameters

The initial scan considered positive seeds

$$
2\le a_0\le40,\qquad a_0<a_1\le80.
$$

A first length-60 suffix diagnostic found seed $(a_0,a_1)=(9,38)$
with gcd states ending in three repeats of $(1,1,2,2)$.
The seed was extended exactly to length 120 and maximal runs were inspected.
The pattern is **not** an eventual tail at this depth.

## Seed (9,38)

For $g_n=\gcd(a_n,a_{n+1})$, the length-120 sample contains the following
maximal AABB-type blocks with at least two full periods. State indices are
zero-based, and end indices are exclusive.

| start | end | state count | full periods | phase |
| ---: | ---: | ---: | ---: | --- |
| 0 | 10 | 10 | 2 | $(1,2,2,1)$ |
| 11 | 35 | 24 | 6 | $(1,1,2,2)$ |
| 36 | 60 | 24 | 6 | $(1,2,2,1)$ |
| 61 | 85 | 24 | 6 | $(2,2,1,1)$ |
| 86 | 99 | 13 | 3 | $(2,1,1,2)$ |
| 100 | 110 | 10 | 2 | $(1,2,2,1)$ |

The original table omitted the short initial block. The consolidated
regression pins all six intervals and all states outside $\{1,2\}$:

| state index | gcd value |
| ---: | ---: |
| 10 | 98 |
| 35 | 49 |
| 60 | 49 |
| 85 | 98 |
| 99 | 103 |
| 110 | 98 |
| 112 | 71 |

There are three separate six-period runs. The spikes interrupt the
period-four pattern, and the final 24 states include 103, 98, and 71.

## Interpretation

The AABB combinatorics occur for long exact blocks in a natural
nearest-integer E-sequence. Persistence must be measured by maximal run
length and boundary transitions, not just a short suffix.

This does **not** show an eventual period-four tail exists. It supplies a
transient witness whose spike transitions should be analyzed using
$(b_n,d_n,D_n)$ normalization.

## Reproduction

Install the package, then run the original capped census:

~~~bash
python -m pip install -e '.[test]'
python experiments/period4_state.py --seed-max 40 --length 120 --min-periods 3
~~~

This filters out the two shorter two-period blocks. To replay all intervals
in the table, use:

~~~bash
python experiments/period4_state.py --seed-max 40 --length 120 --min-periods 2
~~~

Both replays inspect 2,301 seeds and skip 194 seeds with half-integer ties.
The three-period cap reports one witness seed, (9,38); the two-period cap
reports 105 witness seeds. These are counts for the stated finite box only.

The diagnostic emits exact intervals, relative-defect fractions, and
first-period transition data for every detected seed. It reports seed and
tie counts and retains up to the first 50 tie reasons.
Neither finite cap proves persistence or absence of eventual tails.
