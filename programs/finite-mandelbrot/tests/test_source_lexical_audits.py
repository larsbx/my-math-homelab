from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
sys.path.insert(0, str(ROOT / "vendor" / "python"))

from claim_governance.lexing import mask_comments_and_strings
from audit_no_trig import TOKEN_RE


def test_mask_preserves_code_and_line_numbers():
    source = 'fn degree(p: Poly) -> Int:\n    return p.degree # angle and sin\n'
    masked = mask_comments_and_strings(source)
    assert "fn degree" in masked
    assert "return p.degree" in masked
    assert "angle" not in masked
    assert masked.count("\n") == source.count("\n")


def test_mask_removes_single_and_multiline_string_literals():
    source = 'var label = "sin degrees"\n"""polar angle\nunit circle"""\ncos(x)\n'
    masked = mask_comments_and_strings(source)
    assert "sin" not in masked
    assert "degrees" not in masked
    assert "polar angle" not in masked
    assert "unit circle" not in masked
    assert "cos(x)" in masked
    assert masked.count("\n") == source.count("\n")


def test_mask_handles_escaped_quotes():
    source = 'var label = "not \\"cos\\" code"\ntan(x)\n'
    masked = mask_comments_and_strings(source)
    assert "cos" not in masked
    assert "tan(x)" in masked


def test_no_trig_pattern_covers_general_transcendentals():
    for expression in ["sin(x)", "exp(x)", "log(x)", "sqrt(x)", "unit circle"]:
        assert TOKEN_RE.search(expression)
    assert TOKEN_RE.search("# sqrt(x)")
    assert not TOKEN_RE.search(mask_comments_and_strings("# sqrt(x)\nvar q = x * x\n"))


def test_lexical_audits_use_the_vendored_masker():
    # The masker is the vendored claim_governance one (pinned in vendored.toml);
    # the former local copy, tools/source_tokens.py, is gone.
    assert not (ROOT / "tools" / "source_tokens.py").exists()
    # The exact-arithmetic audit is a policy over the vendored engine, which
    # masks with the same vendored lexer.
    sources = [ROOT / "tools" / audit for audit in ("audit_no_trig.py", "audit_no_points.py")]
    sources.append(ROOT / "vendor" / "python" / "exact_arithmetic_audit" / "audit.py")
    for path in sources:
        src = path.read_text(encoding="utf-8")
        assert "from claim_governance.lexing import mask_comments_and_strings" in src
        assert "source_tokens" not in src
    policy = (ROOT / "tools" / "audit_exact_arithmetic.py").read_text(encoding="utf-8")
    assert "from exact_arithmetic_audit import" in policy
    assert "source_tokens" not in policy


def test_vendored_masker_keeps_a_backslash_continued_string_open():
    # Where the vendored masker differs from the former local copy: a
    # backslash-newline continues a single-quoted string, and an escaped quote
    # does not close a triple-quoted one. No governed source exercised either
    # case, so every audit verdict is unchanged.
    masked = mask_comments_and_strings('x = "a\\\nsin(y)"\ncos(z)\n')
    assert "sin" not in masked and "cos(z)" in masked
    masked = mask_comments_and_strings('"""a \\""" sin(y) """\ncos(z)\n')
    assert "sin" not in masked and "cos(z)" in masked
