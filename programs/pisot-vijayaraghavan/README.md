# Pisot–Vijayaraghavan problem research

A research estate for the classical Pisot–Vijayaraghavan (PV) problem:

> If $\alpha>1$ and there is $\lambda\neq 0$ with
> $\|\lambda\alpha^n\|\to 0$, must $\alpha$ be algebraic (hence Pisot)?

Here $\|x\|=\min_{m\in\mathbb Z}|x-m|$ is distance to the nearest integer.

**Current status:** open. This repository does **not** claim a solution.

The authority split follows larsbx/langlands-lab and
larsbx/finite-math-kernels:

- ESTATE.toml declares the estate layout and pinned governance dependency.
- kernel/ contains exact integer/rational identities.
- proof/claims.toml is the authoritative claim ledger.
- tests/ supplies finite evidence and conformance checks.
- experiments/ contains non-authoritative searches.
- docs/dossier.md explains claims and their limits.
- docs/roadmap.md records the active frontier and proof obligations.

No computation promotes itself to a theorem. Imported results stay imported;
failed proofs are explicitly withdrawn.

## Audited starting point

For an integer sequence $(a_n)$, write

$$
c_n=a_n a_{n+2}-a_{n+1}^2,\qquad
H_n^{(k)}=\det(a_{n+i+j})_{0\le i,j<k}.
$$

The banked identities and reductions are:

1. A PV witness yields an expanding eventual nearest-integer E-sequence with
   $c_n=o(a_n)$. The [converse reconstruction](docs/defect-reconstruction.md)
   is now **PROVED** for a positive integer tail whose late ratios stay
   above some fixed $b>1$. Two tail sums give a unique witness and an
   explicit error bound. Unbounded growth alone is insufficient.
2. Desnanot–Jacobi gives $H_n^{(2)}=c_n$ and

   $$
   a_{n+2}H_n^{(3)}=c_n c_{n+2}-c_{n+1}^2.
   $$

3. In the expanding regime, $c_n=o(a_n^{1/2})$ forces
   $H_n^{(3)}=0$ eventually. The [standalone theorem](docs/square-root-barrier.md)
   gives a tail recurrence and a Pisot endpoint of degree at most two;
   the big-O boundary permits a degree-three trace sequence.
4. With $g_n=\gcd(a_n,a_{n+1})$,
   $g_ng_{n+1}\mid c_n$. If adjacent gcds are bounded by $G$, a prime
   $p>G$ dividing $c_n$ satisfies $p\nmid a_na_{n+1}a_{n+2}$.
   This is local freshness, with no fresh-prime-mass conclusion.
5. The exact transport congruence

   $$
   a_n^2c_{n+1}+c_n^2\equiv 0\pmod{a_{n+1}}
   $$

   supplies no independent mesoscopic leverage.
6. Exact two-step gcd returns give a local primitive scaling reduction;
   the coprime-tail quadratic-residue problem remains **OPEN**.

The [exponential-window manuscript](docs/exponential-window-hankel.md)
closes **PV-H3**: under an expanding ratio limit and exponential defect
saving $\gamma<1$, the rank-one bound gives fixed-layer vanishing, the
contiguous-layer bridge gives constant tail recurrence, and the integer
lattice and error bound give the Pisot endpoint. The strict size is
$\lfloor1/(1-\gamma)\rfloor+2$, including reciprocal-integer boundaries.
The [normalized-defect manuscript](docs/defect-reconstruction.md) also
proves polynomial-defect equivalence for real $A>0$ and excludes unit
roots once a rational recurrence is independently established.
Pisot's square-summability recurrence theorem is explicitly **IMPORTED**;
its corollary gives the Pisot endpoint for $A>1/2$. The bound at
$A=1/2$, even little-o, does not by itself supply square summability.
The general recurrence gap and bounded-gcd period-four/coprime-tail
frontiers remain **OPEN**. No PV counterexample is asserted for the
remaining decay ranges.

## Period-four experiment lane

Two states already admit the no-two-step-return word
$(A,A,B,B,A,A,B,B,\ldots)$.
docs/frontier-period4.md records the symbolic proof obligations.

The exact census records seed $(9,38)$ with three separate six-period
blocks at length 120, interrupted by gcd spikes. This is **COMPUTED**
finite evidence, not an eventual-tail claim. Parameters, intervals, and
reproduction are in docs/experiments/2026-10-05-period4-census.md.

## Layout

~~~text
ESTATE.toml
AGENTS.md
ARCHITECTURE.md
CONTRIBUTING.md
kernel/
  pv_exact.py
  pv/identities.py
  pv/hankel.py
  pv/reconstruction.py
proof/claims.toml
tests/
experiments/period4_state.py
tools/check_claims.py
docs/
  dossier.md
  roadmap.md
  exponential-window-hankel.md
  defect-reconstruction.md
  square-root-barrier.md
  frontier-period4.md
  audit/2026-10-05-thread-audit.md
  experiments/2026-10-05-period4-census.md
.github/workflows/ci.yml
~~~

## Verification

~~~bash
python -m pip install -e '.[test]'
python -m pytest
python tools/check_claims.py
python experiments/period4_state.py --seed-max 40 --length 120 --min-periods 3
~~~

CI also checks the pinned estate layout. Canonical arithmetic uses Python
integers and fractions.Fraction; floating point is forbidden in the kernel
and proof-relevant tests.
