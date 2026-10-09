# C4 finite-corpus first-defect census

**Status:** exact finite calibration over the established 4,554-member alphabet-3 PIP corpus with image lengths `<= 3`. This is **not** a proof of a general defect-degree bound, G1, C1, C4, or PSC.

This note records the exact first scattered-subword defect distribution of every reachable noncoincident BPA state in the finite corpus and the normal form of the rare degree-3 states.

## 1. Exact defect-degree distribution

Every balanced-pair state has `K1=0`. `kernel/defect_degree_census.mojo` computes `K2`, `K3`, and `K4` by streaming integer recurrences and classifies the first nonzero defect as degree 2, 3, 4, or `>=5` (meaning zero through degree four).

The exact result is:

| scope | noncoincident states | degree 2 | degree 3 | degree 4 | degree >=5 |
|---|---:|---:|---:|---:|---:|
| all reachable | 385,926 | 385,902 | 24 | 0 | 0 |
| recurrent SCC states | 369,486 | 369,462 | 24 | 0 | 0 |
| noncoincident sink-SCC states | 368,610 | 368,586 | 24 | 0 | 0 |

Across all 4,554 PIP substitutions:

- `0` substitutions have a reachable degree-4-or-higher state;
- `0` have a recurrent degree-4-or-higher state;
- `0` have a sink degree-4-or-higher state;
- all BPA constructions terminate below the established cap.

This is much stronger finite evidence than the abstract balanced-pair universe: an exact irreducible ternary balanced pair of length 12 is known with `K1=K2=K3=0` and `K4!=0`, so first degree four genuinely exists outside this PIP reachability corpus. `tests/test_multidegree_sieve.py` preserves that counter-calibration.

## 2. The 24 degree-3 occurrences

`kernel/degree3_catalog.mojo` prints every reachable state with `K2=0` and `K3!=0`. The exact catalogue has:

- `12` PIP substitutions containing a degree-3 state;
- `24` state occurrences total;
- all `24` recurrent;
- all `24` in the unique noncoincident sink SCC;
- lengths exactly `9` and `19`, two degree-3 states per such substitution.

Thus the live degree-3 phenomenon in this finite corpus is **not** the length-7 seed family from the old Spectral Black Box.

## 3. Relabeling/reversal normal form

The Mojo catalogue performs the theorem-relevant exact checks (centralizer
membership, two-step coincidence leakage, and strict-component detection).
`kernel/psc/degree3_taxonomy.mojo` adds the relabeling and reversal
classification, printed by the catalogue itself as the `DEGREE3_*` lines that
CI pins; `kernel/tests/test_census_library.mojo` regresses it against the known
orbit. The former Python oracle `tools/analyze_degree3_catalog.py` is
retired: the taxonomy is canonical Mojo, like the census that produces it.

There are exactly **four normalized state relabeling classes** (Mojo uses zero-based letters):

```text
length 9:
  011202001|120001120
  011212001|120011120

length 19:
  0011202220010011202|2001001120212022001
  0102211211000102211|2110010201022112110
```

There are exactly **two substitution conjugacy classes**:

```text
011 / 2 / 120
1 / 210 / 002
```

The two substitution classes are exchanged by reversing every substitution image. The two length-9 state classes are exchanged by word reversal, and likewise the two length-19 classes.

The six certified length-7 seed pairs form one six-element alphabet-relabeling orbit. **None** of the 24 live degree-3 occurrences lies in that seed orbit.

## 4. Spectral normal form of the 24 states

The catalogue analyzer reconstructs each substitution incidence matrix and each `A=Theta(K3)` exactly from the emitted state words.

All 12 substitutions carrying degree-3 states have

```text
det M = 1,
chi_M(t) = t^3 - 2 t^2 - 1.
```

For every one of the 24 degree-3 state occurrences:

- `|det Theta(K3)| = 2`;
- `tr(Theta(K3)^2) = 6`;
- `Theta(K3)` **does not commute with** the corresponding `M`.

Hence none of the finite-corpus degree-3 defects lies in the determinant/centralizer eigenspace `W_det`.

This is exactly the condition the general signed degree-3 theorem says a hypothetical **strict closed nonproductive** SCC would have to satisfy: because `Q3 S = Phi3 Q3` and `rho(S)<=beta`, its entire degree-3 defect image must lie in `W_det`. The live finite-corpus states violate that necessary closed-counterexample condition.

## 5. Exact leakage pattern

The same analyzer independently reconstructs balanced-pair cutting from the substitution words. The 24 occurrences follow one transition pattern up to relabeling/reversal:

- each of the 12 length-9 degree-3 states inflates to **one** irreducible child;
- that unique child is the corresponding length-19 degree-3 state;
- each length-19 degree-3 state inflates to **five** irreducible children;
- exactly **one** of those five is a direct coincidence pair.

Therefore every finite-corpus degree-3 state reaches a coincidence within at most **two** inflations.

The spectral and graph pictures line up: the rare `K2=0` states are noncentralizer and cannot remain inside a strict closed counterexample; concretely, they leak to a coincidence after the 9 -> 19 transition.

## 6. Consequence for the proof program

The general signed first-defect theorem remains necessary because degree four exists abstractly. However, within the exact 4,554-PIP reachability corpus, every noncoincident state is already controlled by the degree-2 or degree-3 representation layers:

1. degree 2: `Q2 S = (Lambda^2 M) Q2`;
2. degree 3: `Q3 S = Phi3 Q3` in `W3`.

Moreover, every live degree-3 occurrence is explicitly excluded from the strict closed-counterexample normal form by the centralizer test and visibly leaks to coincidence. Thus the finite corpus's only large unresolved *structural* population is degree 2.

This does **not** prove that a general PIP BPA has no degree-4 state, that every degree-3 state belongs to the four classes above, or that degree-2 recurrent SCCs must leak. Those remain general proof obligations. It only says the statements above hold exhaustively in the stated 4,554-substitution corpus.

## 7. Finite-corpus degree-three exclusion theorem

**Proposition (bounded PIP corpus).** Among the 4,554 primitive ternary
substitutions with irreducible Pisot characteristic polynomial and nonempty
images of length at most three, no fully constructed reachable balanced-pair
automaton contains a strict recurrent component whose first nonzero
scattered-subword defect has degree three.

This is an exhaustive finite theorem with an explicit domain, not a theorem for
arbitrary PIP substitutions and not a finiteness theorem for balanced-pair
automata. The computation fails closed if the state cap is reached. For every
candidate recurrent component it checks directly that every noncoincident child
stays in the component, that no coincidence child occurs, that `K2` vanishes on
every state, and that `K3` is nonzero somewhere.

If a future corpus or implementation change produces a survivor,
`kernel/degree3_catalog.mojo` prints a `D3_COUNTERMODEL_BEGIN` record followed by
every exact state word and child edge before CI rejects the changed zero-count.
This makes the obstruction replayable and prevents the regression gate from
discarding counterevidence.

The proof uses neither G1b-2 nor the source-pending Galois-propagation claim.
The general input is only the proved first-defect result: a hypothetical strict
component with first defect degree three must have its `K3` image in the
determinant eigenspace, equivalently its `Theta(K3)` matrices commute with the
incidence matrix. In the bounded corpus all 24 reachable degree-three states
fail this necessary condition and, independently, all reach a coincidence in
at most two inflations.
