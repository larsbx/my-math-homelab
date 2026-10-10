#!/usr/bin/env python3
"""Audit mathematical terminology governance.

This is not a theorem checker. It enforces repository hygiene:

- risky bridge/isomorphism language must be governed;
- novel bridge terms must include genealogy and leak discipline;
- rank-2 files must not introduce circle/locus primitives;
- a project terminology registry and use manifest must exist;
- deprecated C1 bridge terminology must not be used for new non-migration claims.

The engine is the vendored `lexical_audit` package; this file is the policy.
Every occurrence of a phrase is read, in comments and prose alike, and passes
only with a marker of the named context within 140 characters of its start.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from lexical_audit import (  # noqa: E402
    ContextRule,
    Declaration,
    DeclarationRule,
    Document,
    Policy,
    Requirement,
    Scope,
    all_of,
    contains,
    run,
)

SCAN_ROOTS = ("docs", "kernel", "vendor/mojo")
REGISTRY = "docs/terminology-registry.md"
USE_MANIFEST = "docs/terminology-use-manifest.md"

REQUIRED_DECLARATION_FIELDS = (
    "Terminology declaration:",
    "Genealogy:",
    "Bridge claim:",
    "Known leaks:",
    "Use discipline:",
)
DECLARATION = Declaration("Terminology declaration:", REQUIRED_DECLARATION_FIELDS)

RISKY_PHRASES = (
    "obvious isomorphism",
    "canonical analogy",
    "essentially the same",
    "same as",
    "just a",
    "nothing but",
    "isomorphic to",
    "equivalent to",
    "corresponds exactly",
    "proof by analogy",
)

NEGATING_CONTEXT = (
    "not ",
    "no ",
    "without ",
    "unless ",
    "forbidden",
    "disallow",
    "reject",
    "blocked",
    "must not",
    "cannot",
    "does not",
    "is not",
)

MIGRATION_CONTEXT = (
    "deprecated",
    "legacy",
    "replaces",
    "rather than",
    "migration",
    "old term",
)

RANK2_DOCUMENT = "docs/rank2-coordinate-substrate.md"
RANK2_OPERATOR = "kernel/mojo/arithmetic/rank2_operator.mojo"

RANK2_BANNED_LOCI = (
    "unit circle",
    "circle object",
    "circle primitive",
    "disk object",
    "arc object",
    "circumference",
    "analytic locus",
)

REGISTRY_REQUIRED_TERMS = (
    "PointVertex",
    "rank-2 coordinate record",
    "finite rational-ray nest",
    "SeparatorCatalogueAdequacy",
    "persistent non-separation",
    "persistent wake ambiguity",
    "Mojo theorem kernel",
    "exact-type catalogue",
    "prefix obstruction",
)

C1_SCOPED_TERMS = (
    "finite rational-ray nest",
    "persistent non-separation",
    "persistent wake ambiguity",
    "wake ambiguity",
    "SeparatorCatalogueAdequacy",
    "SeparatorCatalogueSoundness",
    "SeparatorCatalogueCompleteness",
    "side-assignment witness",
    "separator code",
    "exact-type catalogue",
    "prefix obstruction",
)

DEPRECATED_TERMS = (
    "catalogue extensionality",
)

C1_SCOPED_PREFIXES = (
    "docs/C1_",
    "kernel/mojo/c1/",
    "tests/test_C1_",
)

LEGACY_C1_MIGRATION_FILES = (
    "docs/C1_catalogue_extensionality.md",
    "docs/C1_catalogue_extensionality_proof_consolidation.md",
    "docs/alignment_audit_deep_research_findings.md",
    "docs/linter_skill_paper_language.md",
)

ALLOWLIST = (
    "docs/terminology-governance.md",
    "docs/terminology-registry.md",
    "docs/terminology-use-manifest.md",
    "tests/test_terminology_governance.py",
    "tests/test_terminology_registry.py",
    "tests/test_terminology_use_manifest.py",
)

USE_MANIFEST_SECTIONS = (
    "## Registered project terms currently allowed",
    "## Terms requiring local declaration outside C1 files",
    "## Terms requiring theorem-tag status",
    "## High-risk bridge phrases",
    "## Circle/rank-2 ban",
)


def scan(exclude: tuple[str, ...] = ()) -> Scope:
    """Every `.md`, `.mojo` and `.py` under the scan roots, vendored Mojo included."""
    return Scope(tuple(f"{base}/**/*{suffix}" for base in SCAN_ROOTS for suffix in (".md", ".mojo", ".py")), exclude)


POLICY = Policy(
    title="Terminology governance audit",
    stop_on_documents=False,
    documents=(
        Document(REGISTRY, f"{REGISTRY}: required terminology registry is missing", (
            contains("## Established field terms", f"{REGISTRY}: missing established field terms section"),
            contains("## Project terms with declarations", f"{REGISTRY}: missing project declaration section"),
            contains("## Deprecated project terms", f"{REGISTRY}: missing deprecated project terms section"),
            *(contains(term, f"{REGISTRY}: missing governed term {term!r}") for term in REGISTRY_REQUIRED_TERMS),
            Requirement(r"Terminology declaration:\s*.", f"{REGISTRY}: too few terminology declarations",
                        minimum=len(REGISTRY_REQUIRED_TERMS)),
            Requirement(all_of(r"Terminology declaration:\s*.", *map(re.escape, REQUIRED_DECLARATION_FIELDS)),
                        f"{REGISTRY}: declaration blocks must include genealogy, bridge claim, known leaks, and use discipline"),
        )),
        Document(USE_MANIFEST, f"{USE_MANIFEST}: required terminology use manifest is missing", (
            *(contains(section, f"{USE_MANIFEST}: missing section {section!r}") for section in USE_MANIFEST_SECTIONS),
            *(contains(term, f"{USE_MANIFEST}: missing scoped term {term!r}") for term in C1_SCOPED_TERMS),
            Requirement(r"\A(?![\s\S]*catalogue extensionality)|(?i:deprecated)",
                        f"{USE_MANIFEST}: legacy catalogue extensionality must be marked deprecated"),
        )),
    ),
    rules=(
        DeclarationRule(scan(), DECLARATION, "{path}: terminology declaration missing fields: {missing}"),
        ContextRule(
            scan(ALLOWLIST), RISKY_PHRASES,
            "{path}: risky phrase '{term}' requires terminology declaration with genealogy and leaks",
            context=NEGATING_CONTEXT, exempt_declared=DECLARATION,
        ),
        ContextRule(
            scan(LEGACY_C1_MIGRATION_FILES), DEPRECATED_TERMS,
            "{path}: deprecated term '{term}' requires migration/deprecation context; "
            "use SeparatorCatalogueAdequacy/Soundness/Completeness",
            context=MIGRATION_CONTEXT,
        ),
        ContextRule(
            scan(ALLOWLIST + tuple(f"{prefix}*" for prefix in C1_SCOPED_PREFIXES)), C1_SCOPED_TERMS,
            "{path}: C1-scoped term '{term}' requires local declaration or registry pointer outside C1 files",
            context=NEGATING_CONTEXT, exempt_declared=DECLARATION, exempt_if_contains=(REGISTRY,),
        ),
        # The rank-2 substrate may name a locus to deny it; the operator may not name one at all.
        ContextRule(Scope((RANK2_DOCUMENT,)), RANK2_BANNED_LOCI, "{path}: rank-2 locus phrase '{term}' is not allowed",
                    context=NEGATING_CONTEXT),
        ContextRule(Scope((RANK2_OPERATOR,)), RANK2_BANNED_LOCI, "{path}: rank-2 locus phrase '{term}' is not allowed"),
    ),
)


if __name__ == "__main__":
    sys.exit(run(ROOT, POLICY))
