# Terminology Use Manifest

Status: repository terminology control surface.

This manifest is the bridge between the terminology registry and the linter. It does not define mathematics. It records which project-specific expressions are allowed in ordinary prose, which files own their definitions, and which terms require explicit local declarations when used outside their home context.

The goal is to keep the project readable to mathematicians already working near complex dynamics, arithmetic dynamics, computable analysis, rational ray combinatorics, and formal verification.

## Rules

1. Prefer recognizable field language.
2. Use project terms only when they are registered.
3. A cross-pollinated bridge term must state whether it is:
   - theorem-backed;
   - conditional;
   - definition-only;
   - analogy-only.
4. If a bridge term claims an isomorphism or exact correspondence, the text must name the theorem/proof obligation that justifies it.
5. Every novel bridge term must list known leaks.
6. At rank 2, circle language is undefined. Use quadrance or polynomial constraint language instead.
7. Mojo is the first-class finite proof-object theorem kernel, but external analytic theorems remain theorem-tag imports.

## Registered project terms currently allowed

The following terms may appear without a full local declaration only because they are registered in `docs/terminology-registry.md`:

- `PointVertex`
- `rank-2 coordinate record`
- `finite rational-ray nest`
- `SeparatorCatalogueAdequacy`
- `persistent non-separation`
- `persistent wake ambiguity`
- `Mojo theorem kernel`
- `residual directive carrier`
- `separated-pair density`
- `exact-type catalogue`
- `prefix obstruction`

## Terms requiring local declaration outside C1 files

These terms are allowed freely only inside files whose path begins with `docs/C1_`, `kernel/mojo/c1/`, or `tests/test_C1_`. Outside that context, they require a local terminology declaration or an explicit pointer to the registry:

- `finite rational-ray nest`
- `persistent non-separation`
- `residual directive carrier`
- `separated-pair density`
- `persistent wake ambiguity`
- `wake ambiguity`
- `SeparatorCatalogueAdequacy`
- `SeparatorCatalogueSoundness`
- `SeparatorCatalogueCompleteness`
- `side-assignment witness`
- `separator code`
- `prefix obstruction`
- `exact-type catalogue` — home files also include `kernel/mojo/certificates/misiurewicz_catalogue.mojo`, `reference/python/c1/misiurewicz_catalogue_reference.py`, and `schemas/regime_correspondences.toml`.

Deprecated migration-only term:

- `catalogue extensionality` — use only when explicitly marked deprecated or legacy; new claims must use `SeparatorCatalogueAdequacy`, `SeparatorCatalogueSoundness`, or `SeparatorCatalogueCompleteness`.

## Terms requiring theorem-tag status

The following phrases must be accompanied by a theorem tag, local proof obligation, or explicit conditional status:

- `fiber triviality`
- `MLC`
- `local connectivity`
- `rational-ray landing`
- `separation line`
- `wake membership`
- `classical separation`
- `imported theorem tag`

## High-risk bridge phrases

The linter should treat the following as suspicious unless governed by a declaration:

- `isomorphic to`
- `equivalent to`
- `corresponds exactly`
- `same as`
- `nothing but`
- `just a`
- `proof by analogy`
- `canonical analogy`
- `obvious isomorphism`

## Circle/rank-2 ban

The terms `circle`, `unit circle`, `disk`, `arc`, `circumference`, and `analytic locus` are not valid rank-2 objects. A file may mention them only to reject them, or when discussing a higher incidence layer with an explicit declaration that rank-2 itself has no such primitive.
