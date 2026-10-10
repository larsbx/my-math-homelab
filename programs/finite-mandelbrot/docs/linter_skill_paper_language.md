# Linter skill: field-facing paper language

Status: enforced manuscript-writing skill.

Use this skill whenever editing files under `paper/`.

## Purpose

Mathematical papers in this repository must be legible to human mathematicians in complex dynamics, computable analysis, and arithmetic/algebraic dynamics. They must not rely on repository-private labels, implementation slogans, or internal proof-route names.

The paper may discuss finite certificates, rational parameter rays, fibers, landing theorems, interval certificates, algebraic computation, and proof checking. It must state the mathematics in field-standard language.

## Command

```bash
python3 tools/audit_paper_language.py
```

Run this before committing any manuscript change.

## What the audit rejects

The audit rejects project-internal language in `paper/*.tex`, including:

- private conjecture labels such as `C1`;
- repository names such as `finite-mandlebrot-research`;
- implementation-language names such as `Mojo`;
- proof-engineering phrases such as `theorem kernel`;
- repository compounds such as `separator-catalogue`;
- deprecated phrases such as `catalogue extensionality`;
- internal proof-route labels such as `ResidualClosureNoMissingLinks`, `ExitClosureForC1`, `ResidualFrontierRefinement`, and `ResidualDescentContradiction`;
- planning labels such as `PRIORITY_ZERO` and `OPEN_FRONTIER`.

## Preferred replacements

Use ordinary mathematical prose:

- `the main conjecture` instead of `C1`;
- `finite rational-ray separation certificates` instead of `separator-catalogue`;
- `adequacy of finite rational-ray separation certificates` instead of `catalogue extensionality`;
- `finite proof checker` or `proof-object checker` instead of `theorem kernel`;
- `finite record`, `finite certificate state`, or `finite incidence data` instead of `carrier`;
- `open problem`, `remaining analytic difficulty`, or `fiber-triviality problem` instead of repository status labels.

## Required paper posture

Every field-facing manuscript must:

1. state the quadratic family and Mandelbrot-set context;
2. use rational parameter-ray and fiber terminology in the standard sense;
3. distinguish finite certificate checks from imported analytic theorems;
4. cite core literature on parameter rays, fibers, and orbit portraits;
5. explicitly say that the finite certificate criterion is not by itself a proof of Mandelbrot local connectivity.

## Scope

This skill applies to `paper/*.tex` only. Internal documents, source files, tests, and CI scripts may still use repository-specific names when they are useful for engineering and proof-object organization.
