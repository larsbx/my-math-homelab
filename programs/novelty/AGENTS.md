# Agent implementation policy

This file is normative. It adapts the disciplines of
`larsbx/pisot-substitution-conjecture-research` (PSC) and `larsbx/langlands-lab`
to this repository. Where it is silent, `docs/calibration.md` (promotion) and
`docs/verification.md` (hypotheses, obligations, theorems) decide.
`CONTRIBUTING.md` lists the gates.

## Authority before language

[`ESTATE.toml`](ESTATE.toml) assigns every top-level path an authority plane
([`ARCHITECTURE.md`](ARCHITECTURE.md)). The ordering rule is
authority → mathematical concern → language.

- **Python is the one canonical language.** `kernel/` is the canonical
  executable. Its arithmetic is exact (`int` and `Fraction`), and the
  `exact-kernel` numerics rule of `claim_governance.toml` enforces that.
- **`experiments/` is non-authoritative.** A driver there may produce the
  committed data behind a bounded-experiment record. A computation that backs a
  finite-domain record belongs in `kernel/`; `[migration].next` lists the
  drivers still to move.
- **Lean (`NoveltyLab/`) is a supporting oracle.** It recomputes and checks; it
  does not accept. If it disagrees with the Python kernel, the run fails closed:
  neither side wins by default.
- **TLA+ (`tla/`) is a supporting proof-dependency model.** It is generated from
  `research/ledger.json`.

## Exactness before speed

1. Never decide equality, rank, factorization, norm, a characteristic
   polynomial, or a certificate with a floating approximation. Optimize the
   exact algorithm instead.
2. A computation done modulo a large prime as a proxy for ℤ or ℚ must prove the
   lift it relies on. Example: `experiments/n2/h3_integral.py` asserts that every
   coordinate is below 2⁴⁰ before reading it as an integer. It must also state
   which direction the proxy is sound in: "different modulo P" implies
   "different over ℚ", and not conversely.
3. Impossible invariant states raise. Never return an empty structure that a
   reader could mistake for a mathematical finding.

## Shared primitives

Every octonion census here works in the same model: cayley-dickson/v1 with
parameters (−1, −1, −1). The model and its vocabulary are modules, not
something each driver rebuilds.

| Module | Provides |
|---|---|
| `experiments/n2/defect_census.py` (`C`) | structure constants, `mul`, `conj`, `norm`, `left`, matrices, `echelon`, `rank`, exact `charpoly`, `defect` |
| `experiments/n2/rank_law.py` (`R`) | `bilinear`, `nullspace`, `orthogonal_complement`, `radical`, projective pure points |
| `experiments/n2/word_defects.py` (`WD`) | `reflection`, `word_defect`, rotations of 1⊥ |

A new census imports these and folds per-sample facts into counters. It does
not re-implement multiplication, norms, ranks or characteristic polynomials,
and it does not hand-roll a second copy of one.

## Searches label themselves

A sampled census or exploratory search must:

- be seeded, with the seed in the output;
- state its budget (samples, quota or cap);
- distinguish "the budget ran out" from "the mathematics says so".

Randomness may enter a **bounded-experiment** record. It may never enter a
certificate or a **finite-domain** record. A finite-domain record rests on an
exhaustive enumeration or an explicit certificate, and its test replays that
enumeration or certificate.

## Literature stop/go gate

Run this gate before implementing a new theorem-facing diagnostic, testing a
proposed universal invariant, or promoting a lemma.

1. Do a small, targeted literature check: three to six primary sources,
   covering
   - the closest known construction,
   - the strongest relevant theorem,
   - known hypothesis boundaries and counterexamples.
2. Record a note at `docs/literature/<topic>-<YYYY-MM-DD>.md` in the format of
   [`docs/literature/README.md`](docs/literature/README.md).
3. The note ends in one of three decisions: **stop**, **redirect**, or
   **proceed with a narrowed target**.

Write new theorem-facing tests or proof code only after that decision. A
regression repair for an already reviewed contract needs no new note.

If the check shows an identity is standard, cite it and restrict any novelty
statement to the actual specialization, certificate or theorem. This gate is
literature clearance in the sense of `docs/calibration.md`. It is not a
novelty finding, and no script may promote anything to `novel result`.

## Every test names what it guards

Each `tests/test_*.py` declares one of two things:

- `GUARDS_CLAIM = "<ledger record>"` for the finite-domain or proved record
  whose evidence rests on the contract it pins;
- `GUARDS_CONTRACT = "<what it pins>"` when no ledger record is the target.

The `coverage` check of the vendored `claim_governance` package reports three
problems:

- a test that declares neither;
- a name that is in no ledger record;
- a finite-domain or proved record that no test guards.

A declaration is a link, not evidence. The assertions decide what the contract
is; the record's own proof or certificate decides that the claim follows.

Each test docstring says which side is computed and what the match
instantiates, for example: "2 N(xy − yx) = det Gram_B(1, x, y): τ is a
function of the Gram matrix". This is the langlands-lab rule. A theorem quoted
to interpret a match is imported, not verified, and the ledger records it with
the `imported_theorem` kind.

## Generated surfaces

These are functions of their sources. Regenerate them with their tool and
never hand-edit them.

| Surface | Source | Tool |
|---|---|---|
| `docs/ledger-index.md`, `tla/*`, the generated `[[claim]]` block of `claim_governance.toml` | `research/ledger.json` | `tools/seal_ledger.py`, then `proof_records.generate_ledgers` |
| `data/**/*.json` | the script named in its ledger `replay` | `<script> --check` |
| `paper/*/tables/*` | `data/` | `make_tables.py` |

Content-addressed identifiers in `research/ledger.json` are resealed with
`tools/seal_ledger.py`, never edited by hand.

## Vendored packages

`vendor/` holds byte-for-byte copies from `larsbx/finite-math-kernels`, pinned
in `vendored.toml` and checked by `vendor/vendoring/check_vendored_sync.py`.

- Never patch a vendored file, add a file beside one, or re-implement locally
  what a package provides.
- To change one, change it upstream, re-vendor, and re-pin with
  `check_vendored_sync.py pin NAME COMMIT`. Then update the
  `finite-math-kernels` `[[dep]]` pin in `ESTATE.toml` (`ARCHITECTURE.md`
  gives the digest).

## Fail closed, and which way closed points

"Fail closed" has two meanings, and they point in opposite directions.
Applied by effect:

| Operation | Closed means | Because |
|---|---|---|
| A census cap or quota is reached | refuse to conclude | an exhausted budget is not a verdict; a capped run reports as capped |
| A certificate check cannot decide | refuse to promote | a claim keeps the status its evidence earns |
| A generated surface disagrees with its source | refuse the run (`--check`) | disagreement is drift, not a new fact |
| A toolchain is missing in CI | refuse the job | `verify_all.sh` exits 3 on a skip, and CI treats that as failure |
| A claim is to be retired | refuse to retire | withdrawal is history; an uncertain claim stays live and visibly wrong rather than vanishing |
| Committed data or a certificate is to be replaced | refuse to overwrite | the committed record is what a reader replays |

The first four refuse to *proceed*; the last two refuse to *destroy*. When a
new gate is added, state which column it belongs in. If that is not obvious,
it belongs in the second column, because destruction cannot be undone.

Retiring a claim whose refutation is clear is a deliberate, attributable act:
a `KILL-nn` entry in `research/retired_claims.json` with its reason and
salvage. What fails closed is the *uncertain* case.

## Claim discipline

- State exactly what a change establishes, and no more.
- A search that stopped at a limit says where it stopped.
- A bounded failure is not an absence.
- A translation preserves or lowers authority; it never raises it.
- "Verified" unqualified is not a claim. Say verified *by what*: an exhaustive
  census, a sampled census, a certificate, a Lean check, or a written proof
  awaiting review.
- A written proof stays `pending` until an independent review is recorded
  (`docs/calibration.md`).

## Hooks

`.claude/settings.json` enforces the mechanical parts of this policy in Claude
Code sessions opened in this repository. All three hooks are implemented in
`.claude/hooks/guard.py`.

| Event | What it does | Fail-closed column |
|---|---|---|
| SessionStart | `session-start.sh` provisions Python and the pinned Lean toolchain, and records the outcome in `.claude/provision-status` (a SessionStart hook cannot block the session) | refuse to proceed: in a web session, the commit gate below refuses commits until the status reads `ok` |
| Before Edit or Write | denies hand edits to `vendor/`, `data/`, `tla/`, `docs/ledger-index.md`, `paper/*/tables/`, the generated `[[claim]]` block of `claim_governance.toml`, and a vendored estate audit; the denial names the regeneration command | refuse to proceed |
| After Edit or Write of `research/ledger.json` | reseals identifiers and regenerates every ledger surface | refuse to proceed: a failure blocks with the generator's output |
| After Edit or Write of `vendored.toml` or `ESTATE.toml` | checks the vendoring pins (`tools/estate_pins.py`) | refuse to proceed |
| Before a Bash `git commit` | resolves the message the commit will record (`-m`, `-F` files, `-C`/`-c`/`--fixup`/`--squash` commits, `--amend`), denies one that names a model identifier, and denies an editor-composed message it cannot inspect; then runs `scripts/verify_all.sh fast` (a few seconds) and denies the commit on any failure | refuse to proceed |

The hooks are a convenience, not the gate. CI runs the full gates
regardless, and a contributor without Claude Code runs
`scripts/verify_all.sh`.

## Pull requests

Use `.github/PULL_REQUEST_TEMPLATE.md`. Its *What this does not establish*
section is required, and it is the section reviewers read first.
`.claude/skills/steward/SKILL.md` is the procedure for driving a pull request
to green.
