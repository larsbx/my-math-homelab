"""Compare the written defect identities as formal integer polynomials.

The indeterminate t stands for lambda*alpha**n. This checks the displayed
algebra itself, not the infinite-tail hypotheses or other proof obligations.
"""

import ast
import re
from pathlib import Path

import pytest


ROOT = Path(__file__).resolve().parents[1]


def _multiply(left, right):
    result = {}
    for lmonomial, lcoefficient in left.items():
        for rmonomial, rcoefficient in right.items():
            monomial = tuple(sorted(lmonomial + rmonomial))
            result[monomial] = result.get(monomial, 0) + lcoefficient * rcoefficient
    return result


def _polynomial(expression):
    """Expand a restricted arithmetic AST into monomials with integer coefficients."""

    def expand(node):
        if isinstance(node, ast.Constant) and type(node.value) is int:
            return {(): node.value}
        if isinstance(node, ast.Name) and node.id in {"t", "a", "x", "y", "z"}:
            return {(node.id,): 1}
        assert isinstance(node, ast.BinOp), "unsupported polynomial syntax"
        left = expand(node.left)
        if isinstance(node.op, ast.Pow):
            assert isinstance(node.right, ast.Constant) and node.right.value == 2
            return _multiply(left, left)
        right = expand(node.right)
        if isinstance(node.op, ast.Mult):
            return _multiply(left, right)
        assert isinstance(node.op, (ast.Add, ast.Sub)), "unsupported operation"
        sign = 1 if isinstance(node.op, ast.Add) else -1
        result = left.copy()
        for monomial, coefficient in right.items():
            result[monomial] = result.get(monomial, 0) + sign * coefficient
        return result

    result = expand(ast.parse(expression, mode="eval").body)
    return {
        monomial: coefficient
        for monomial, coefficient in result.items()
        if coefficient
    }


def _documented_rhs(path):
    source = (ROOT / path).read_text()
    blocks = re.findall(r"\\\[(.*?)\\\]|\$\$(.*?)\$\$", source, re.DOTALL)
    expansions = [
        block
        for pair in blocks
        for block in pair
        if re.match(r"\s*c_n=\\lambda\\alpha\^n", block)
    ]
    assert len(expansions) == 1, "expected exactly one displayed defect expansion"
    rhs = expansions[0].split("=", 1)[1].split(r"\tag", 1)[0].strip().removesuffix(".")
    rhs = rhs.replace(r"\varepsilon", "e")
    for latex, name in (
        (r"\lambda\alpha^n", "t"),
        (r"\alpha", "a"),
        ("e_{n+2}", "z"),
        ("e_{n+1}", "y"),
        ("e_n", "x"),
        (r"\cdot", "*"),
        (r"\bigl", ""),
        (r"\bigr", ""),
    ):
        rhs = rhs.replace(latex, name)
    rhs = re.sub(r"\s+", "", rhs)
    tokens = re.findall(r"[taxyz]|[0-9]+|[()+*^\-]", rhs)
    assert "".join(tokens) == rhs, "unsupported notation in the displayed identity"
    expression = []
    previous = ""
    for token in tokens:
        # TeX juxtaposition is multiplication, including 2*alpha*e_(n+1).
        if (previous.isalnum() or previous == ")") and (
            token.isalnum() or token == "("
        ):
            expression.append("*")
        expression.append("**" if token == "^" else token)
        previous = token
    return "".join(expression)


@pytest.mark.parametrize("path", ["docs/defect-reconstruction.md", "docs/dossier.md"])
def test_documented_defect_expansion_is_an_exact_polynomial_identity(path):
    # Derive c_n directly from a_n=t+x, a_(n+1)=alpha*t+y, a_(n+2)=alpha^2*t+z.
    expected = _polynomial("(t+x)*(a**2*t+z)-(a*t+y)**2")
    documented = _documented_rhs(path)
    assert _polynomial(documented) == expected
    # The reported typo must fail: adding the bracket loses its t multiplier.
    assert "t*(" in documented
    broken = documented.replace("t*(", "t+(", 1)
    assert _polynomial(broken) != expected
