#!/usr/bin/env python3
"""Rebuild the F3 Cayley-Dickson basis tensor and check its canonical digest."""
import argparse
import hashlib
import json
from pathlib import Path
import re

P=3
def add(x,y): return tuple((a+b)%P for a,b in zip(x,y))
def neg(x): return tuple((-a)%P for a in x)
def sub(x,y): return add(x,neg(y))
def conj(x):
    if len(x)==1: return x
    h=len(x)//2; return conj(x[:h])+neg(x[h:])
def mul(x,y):
    if len(x)==1: return (x[0]*y[0]%P,)
    h=len(x)//2; a,b=x[:h],x[h:]; c,d=y[:h],y[h:]
    return sub(mul(a,c),mul(conj(d),b))+add(mul(d,a),mul(b,conj(c)))
B=[tuple(1 if i==j else 0 for i in range(8)) for j in range(8)]
TABLE=[[list(mul(B[i],B[j])) for j in range(8)] for i in range(8)]
EXPECTED="747ace028b8a34fb95f5b7c39e99f3004e39ad4fb3401a7caa3b6e3a4e2e2f4b"
ROOT = Path(__file__).resolve().parents[1]


def canonical(table):
    return json.dumps({"modulus": P, "table": table}, sort_keys=True,
                      separators=(",", ":"))


def lean_table(source):
    """Read only the literal Nat-array grammar; refuse unknown syntax or shape."""
    arrays = []
    for name in ("productIndex", "productCoeff"):
        match = re.search(r"def " + name + r" : Array \(Array Nat\) := #\[(.*?)\n\]", source, re.S)
        if match is None:
            raise ValueError(f"missing literal {name}")
        literal = match.group(1)
        rows = re.findall(r"#\[([0-9,\s]+)\]", literal)
        remainder = re.sub(r"#\[[0-9,\s]+\]", "", literal)
        if remainder.strip(" ,\n\r\t"):
            raise ValueError(f"unsupported syntax in {name}")
        parsed = [json.loads("[" + row + "]") for row in rows]
        if len(parsed) != 8 or any(len(row) != 8 for row in parsed):
            raise ValueError(f"invalid dimensions in {name}")
        bound = 8 if name == "productIndex" else P
        if any(not 0 <= value < bound for row in parsed for value in row):
            raise ValueError(f"out-of-range entry in {name}")
        arrays.append(parsed)
    indices, coeffs = arrays
    return [[[coeffs[i][j] if k == indices[i][j] else 0 for k in range(8)]
             for j in range(8)] for i in range(8)]


def verify(source, exported=None):
    tensor = lean_table(source)
    if tensor != TABLE:
        raise ValueError("Lean tensor differs from independent Cayley-Dickson replay")
    payload = canonical(tensor)
    actual = hashlib.sha256(payload.encode()).hexdigest()
    if actual != EXPECTED:
        raise ValueError(f"tensor digest mismatch: {actual}")
    if exported is not None and exported != payload + "\n":
        raise ValueError("evaluated Lean tensor serialization mismatch")
    return actual


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lean-source", type=Path,
                        default=ROOT / "NoveltyLab/OctonionF3.lean")
    parser.add_argument("--lean-export", type=Path)
    args = parser.parse_args()
    try:
        digest = verify(args.lean_source.read_text(),
                        args.lean_export.read_text() if args.lean_export else None)
    except ValueError as error:
        raise SystemExit(str(error)) from error
    print(f"verified F3 tensor provenance {digest}")


if __name__ == "__main__":
    main()
