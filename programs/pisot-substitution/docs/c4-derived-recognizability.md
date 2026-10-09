# C4 derived recognizability after cyclic decomposition

**Status:** uniform structural theorem for a finite strict recurrent PIP component. This note uses the PIP spectral hypothesis and Mossé recognizability, but it does **not** prove C4, C1, G1, or PSC.

## 1. Input from the strict component

Let `C` be a finite closed recurrent noncoincident SCC and let

```text
tau_C(T)=ordered normalized children of sigma(T)
```

be the derived substitution from `docs/c4-derived-cut-address.md`.

Because `C` is a strongly connected component, the directed incidence graph of `tau_C` is strongly connected. Its incidence matrix is therefore irreducible. Let

```text
h = gcd{directed cycle lengths in the graph of tau_C}
```

be its graph period.

The standard cyclic decomposition partitions `C` into classes

```text
C_0,...,C_{h-1}
```

such that every edge moves from `C_j` to `C_{j+1 mod h}`. Consequently `tau_C^h` preserves each class, and the restricted substitution

```text
rho_j = tau_C^h | C_j
```

has primitive incidence matrix.

`reference/psc_research/derived_dynamics.py` computes `h`, the cyclic classes, and these primitive power restrictions exactly.

## 2. Perron eigenvalue of each power restriction

For a strict closed component, the Parikh intertwiner already gives

```text
P_C N_C = (M_sigma) P_C,
rank(P_C)=3,
rho(N_C)=beta.
```

The irreducible matrix `N_C` has period `h`. Standard Perron–Frobenius cyclic decomposition says that every diagonal irreducible block of `N_C^h` has Perron eigenvalue

```text
beta^h.
```

Those blocks are exactly the incidence matrices of the substitutions `rho_j` above.

Thus each `rho_j` is a primitive substitution with Perron expansion `beta^h`.

## 3. PIP forces the primitive derived substitutions to be aperiodic

The remaining hypothesis needed for Mossé recognizability is aperiodicity.

> **Derived aperiodicity theorem.** If `beta` is a non-rational Pisot number, no primitive cyclic-class substitution `rho_j` above can generate a periodic substitution subshift.

### Proof

Assume some primitive `rho=rho_j` has periodic subshift. Replacing `rho` by a positive power does not change periodicity and preserves primitivity, so choose a power having a one-sided fixed point. Let the primitive period word of that fixed point be `w`, so the fixed point is

```text
w w w ... .
```

Because the source period repeats, `rho(w)` also repeats periodically and has the same primitive root `w`. After taking another power if needed to return the phase to the start of `w`, there is an integer `k>=1` with

```text
rho^q(w)=w^k.
```

Hence the exponential word-length growth of `rho^q` is the integer `k`. For a primitive substitution that growth rate is its Perron eigenvalue. But the Perron eigenvalue of `rho^q` is

```text
(beta^h)^q = beta^(hq).
```

Therefore

```text
beta^(hq)=k in Z_{>0}.
```

Now apply any nontrivial algebraic embedding sending `beta` to a Pisot conjugate `alpha`. The same rational integer is fixed by the embedding, so

```text
alpha^(hq)=k.
```

But `|alpha|<1`, while `k>=1`, a contradiction. QED.

In the standing PIP cubic regime, `beta` is irreducible of degree three and is therefore non-rational, so the theorem applies.

## 4. Derived recognizability theorem

Each `rho_j` is now

- primitive;
- aperiodic.

Mossé recognizability therefore applies to every `rho_j`.

> **Derived recognizability theorem.** For each cyclic class `C_j` there exists a finite radius `R_j` such that the `rho_j`-supertile boundaries in every point of its substitution hull are determined by radius-`R_j` derived-state context.

Taking

```text
R_tau = max_j R_j
```

gives one finite context radius after phase-decimating the derived hierarchy by `h` levels.

Thus inherited/newborn balanced-pair boundaries are not merely known from the construction: after passing to the period-`h` derived system they are **locally recognizable from a bounded derived-state context**.

## 5. Why the PIP hypothesis is essential

Consider

```text
A -> B
B -> A A.
```

Its graph is strongly connected with period `2` and Perron eigenvalue `sqrt(2)`. Squaring and restricting to the two cyclic classes gives

```text
A -> A A,
B -> B B.
```

Both restrictions are primitive one-letter substitutions, but their subshifts are periodic. Here

```text
(sqrt(2))^2=2
```

is exactly the integer expansion factor allowed by periodicity. The non-Perron conjugate is `-sqrt(2)`, not contracting, so the Pisot contradiction is unavailable.

The repository's primitive non-Pisot strict calibration supplies a period-1 version of the same warning: its derived substitution is

```text
A -> A B
B -> A B,
```

which is graph-primitive but generates the periodic word `ABAB...`.

So the theorem really uses the PIP conjugate condition; graph primitivity alone is insufficient.

## 6. Dual recognizability state

PR #31 supplies legal radius-`R_sigma` contexts for suitably chosen deep physical zero returns, so Mossé recognizability for `sigma` can decide the top and bottom source-supertile boundary flags locally.

The present theorem supplies radius-`R_tau` derived-state contexts that decide the inherited/newborn flag in the period-`h` derived hierarchy.

A sufficiently deep selected cut can therefore be decorated by two independently recognizable finite boundary structures:

```text
sigma-side data:
  ancestry defect, local offsets, legal top/bottom contexts,
  top sigma-boundary flag, bottom sigma-boundary flag;

derived-side data:
  cyclic phase, derived left/right context,
  inherited/newborn tau-boundary flag.
```

All coordinates are finite.

This is the first point in the C4 route where both hierarchies involved in the intertwining relation can be made locally detectable.

## 7. What this still does not prove

Local recognizability of both hierarchies does not itself force their boundaries to coincide. A substitution factor map can carry one recognizable hierarchy into another with a nontrivial finite offset/address cocycle.

The next theorem must control exactly that cocycle.

In the gauge-trivial orientation case,

```text
sigma U = U tau_C,
sigma V = V tau_C.
```

After passing to `h` levels, the same equations hold with `sigma^h` and `tau_C^h`. The natural next object is therefore the **hierarchy-offset cocycle**: for a derived supertile boundary, record the bounded source-supertile address of its image under `U` and under `V`.

A C4 counterexample would require a recurrent cocycle state that

- remains newborn on the derived side when appropriate;
- remains misaligned on at least one sigma side;
- and keeps every genuine balanced boundary endpoint-nonsynchronizing.

The next task is to prove that such a recurrent offset cocycle is impossible in the PIP strict regime, or preserve an explicit counterexample and enlarge the state again.
