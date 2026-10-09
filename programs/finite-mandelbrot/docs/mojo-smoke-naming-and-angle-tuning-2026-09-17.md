# Named smoke cases, and angle tuning in Mojo — 2026-09-17

Status: engineering record.

Governed terms appearing here are used in the sense
`docs/terminology-registry.md` gives them; this note declares none of its own
and claims nothing about any of them.

**Scope.** An engineering change to how the Mojo layer reports itself and to
where one computation lives. No mathematical claim changes, and no certificate
or proof-object contract moves. Every previously passing check still passes.

## 1. The smoke suite names its cases

`run_smoke_tests` was one chain of about fifty `if not case(): return False`
branches, so a failure printed a single bare `FAIL`. Which contract broke, and
whether anything after it also broke, were both invisible; the first failure
masked the rest.

`kernel/mojo/smoke/smoke_report.mojo` (since moved upstream and vendored back as
`vendor/mojo/mojo_smoke/report.mojo`) replaces the chain with a named case. `SmokeReport`
records a name and a verdict, prints `[PASS] name` or `[FAIL] name` as it
goes, and keeps counting after a failure, so one run names every broken
contract. The suite now reports 58 cases, up from the roughly fifty the chain
ran, because grouped conditions became separate named cases.

A deliberate break of the catalogue now reports:

```text
finite-regime Mandelbrot smoke suite: 1 of 58 cases FAILED
  failed: Misiurewicz exact-type catalogue
```

The reporter has a self-test, which records a deliberate failure into a silent
report: a printed `[FAIL]` should only ever mean a real one.

## 2. Python no longer asserts Mojo behaviour by reading Mojo source

Twenty-six assertions across eight test files checked that the smoke suite was
wired to a kernel by matching the source substring `if not X_smoke():`. That
says the text is present. It does not say the case ran, and it does not say it
passed; it also breaks on any rewrite that preserves behaviour, which is how
this change first surfaced them.

`tests/conftest.py` now exposes `mojo_smoke`, which runs `kernel/mojo/smoke/smoke_tests.mojo`
once per session and parses the named verdicts. Each of those assertions became
`assert mojo_smoke.case_passed("<case>")`. The difference is not cosmetic:
breaking `checked_q_smoke` so that it returns `False` leaves the old assertion
passing and fails the new one.

Reading source is still right for what is genuinely a property of the text,
and those tests are untouched: no floating-point literal, a regime-
correspondence marker, a non-claim that returns `False`.

## 3. Exact angle tuning is computed in Mojo

`tools/kneading_reference.py` held `tune_angle`, Douady's tuning of a periodic
angle by a component, with no Mojo counterpart. The Mojo side checked its star
product against the resulting angles as literals — `2/5`, `7/17`, `8/17`,
`10/63`, `82/511` — so the substitution side was executed here and the angle
side was not.

`kernel/mojo/dynamics/angle_tuning.mojo` computes it: `angle_period` reads the exact period of
a rational address under doubling, `binary_block` reads its leading digits, and
`tuned_angle` substitutes the two root-ray blocks of a component into the
digits of the tuned angle, over `2^(nq) - 1`. All arithmetic is checked
fixed-width integer arithmetic, and the period product is refused past 62
rather than wrapped.

`C1_residual_directive_carrier` now derives each of the five instances instead
of quoting it, including the repeated level, which is a repeated tuning. The
Python function stays as the independent oracle it was always described as,
and still runs in CI.

## 4. One helper, not three

`_same`, a hand-written list equality, existed in two modules, and the new
module would have made three. Mojo compares `List[Int]` directly, so all three
are deleted rather than consolidated.

## 5. Verification

- the Mojo smoke suite: 58 cases, all passing, and a deliberate break names the case it broke;
- the Python suite: 493 tests passing, against 492 before;
- every CI step green, including the vendoring digests, the terminology, exact-arithmetic, no-trig, no-points, backend-manifest, paper-language and claim-governance audits, and all five reference oracles.
