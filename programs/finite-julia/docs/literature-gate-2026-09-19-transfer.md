# Literature gate — the filled-Julia transfer

## Proposed step

`docs/literature-gate-2026-09-19.md`, finding 1, split the `J1` bridge in two
and left the second half ungated:

```text
K_c locally connected  <=>  J_c locally connected
    [FilledJuliaLocalConnectivityTransfer: NOT GATED]
```

The fiber theory this repository imports is stated for a compact connected
full set, and the object it is stated about is the filled Julia set `K_c`. The
ledger, the regime names, and the classical results cited for each regime all
speak of `J_c`. Something has to carry one to the other, and until now nothing
did.

## Decision

**Gated, and discharged by two named imports plus an assembly step that is
this repository's own and is written out below rather than imported.**

The two directions have different sources and are recorded separately. Neither
is a result of this repository; the step that puts them together is, and that
is why it is spelled out rather than cited.

## Findings

### 1. `K_c` locally connected implies `J_c` locally connected, by Torhorst

Torhorst's theorem: the boundary of each complementary domain of a locally
connected continuum is itself a locally connected continuum.[^1]

For `c` with connected Julia set, `K_c` is a compact connected full set, so
its complement has exactly one component, the basin of infinity, whose
boundary is `J_c = ∂K_c`. Applying the theorem to the continuum `K_c` gives
`J_c` locally connected.

The qualification is that the theorem is about a continuum, which is a
*connected* compact set. The escaping regime, where `K_c` is a Cantor set, is
outside its hypotheses, which is consistent with the ledger: that row is
`NOT_APPLICABLE_DISCONNECTED` and carries no `J1` expectation.

Tag: `TorhorstBoundaryOfComplementaryDomain` (ACCEPTED, theorem number not
checked against a printed page).

### 2. `J_c` locally connected implies `K_c` locally connected, through Carathéodory

If `J_c` is locally connected then, by Carathéodory's theorem on conformal
extension, the Riemann map of the basin of infinity extends continuously to
the boundary, every external ray lands, and every point of `J_c` is the
landing point of one.[^2] The induced equivalence on the circle is the
`d`-invariant lamination of the polynomial, the quotient of the closed disk by
that lamination is homeomorphic to `K_c`, and the quotient map is
continuous.[^3]

Tag: `CaratheodoryLaminationModel` (ACCEPTED, theorem number not checked).

### 3. The assembly is this repository's, and is elementary

Finding 2 exhibits `K_c` as a continuous image of the closed unit disk, which
is a compact locally connected space; a continuous image of a compact locally
connected space under a quotient map is locally connected. That is the step
this repository supplies. It is elementary and it is not imported: a reader
who rejects it rejects the transfer, and the two findings above survive
independently.

Recording it here rather than burying it in a tag is the point of the split.
The repository's rule is that classical conclusions enter as named imports and
are not silently reproved; an assembly of two imports is not a classical
conclusion, and calling it one would have been the dishonest option.

## Verdict

| Tag | Verdict |
| --- | --- |
| `TorhorstBoundaryOfComplementaryDomain` | ACCEPTED (finding 1) |
| `CaratheodoryLaminationModel` | ACCEPTED (finding 2) |
| `FilledJuliaLocalConnectivityTransfer` | **DISCHARGED** for `c` with connected `K_c`, by findings 1-3, with the assembly step owned here |

The transfer is discharged only where `K_c` is connected. That is exactly
where `J1` is stated, so nothing else in the repository needs it.

## What this gate did not do

It did not verify any theorem number against a printed text, obtain the cited
works in full, or check a proof. It did not make any verified column of the
ledger depend on a tag, and no such dependency exists.

[^1]: M. Torhorst (1918). The boundary of each complementary domain of a locally connected continuum is a locally connected continuum; if the continuum has no cut point the boundary is a simple closed curve. Stated and quantified in *On the lambda function and a quantification of Torhorst Theorem*, Topology and its Applications. https://www.sciencedirect.com/science/article/abs/pii/S0166864122002474
[^2]: Carathéodory's theorem on conformal mapping: a conformal map of the disk onto a Jordan-type domain extends continuously to the closure exactly when the boundary is locally connected. https://en.wikipedia.org/wiki/Carath%C3%A9odory%27s_theorem_(conformal_mapping)
[^3]: The lamination model of a locally connected Julia set: rays land, the induced circle equivalence is the invariant lamination, and the quotient is the set. See *Locally connected models for Julia sets*, arXiv:0809.3754, and J. Milnor, *Dynamics in One Complex Variable*, on external rays and landing. https://arxiv.org/pdf/0809.3754
