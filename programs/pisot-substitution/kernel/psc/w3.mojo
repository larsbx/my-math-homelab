"""The printed W_3 basis of the spectral certificate.

`w3_basis`, `in_w3`, and `spans_same_space` are the general shuffle-kernel
mechanics of the vendored `finite_linear_algebra` package and are re-exported
here for the certificate and its tests. The certificate's printed basis (§3)
is reproduced below so the two can be compared.
"""

from finite_linear_algebra.tensor3 import idx3, zeros27
from finite_linear_algebra.w3 import in_w3, spans_same_space, w3_basis


def _vec(entries: List[Int]) -> List[Int]:
    """Sparse `[a, b, c, coeff, ...]` triple-plus-coefficient form to a 27-vector."""
    var v = zeros27()
    var i = 0
    while i < len(entries):
        v[idx3(entries[i] - 1, entries[i + 1] - 1, entries[i + 2] - 1)] = entries[i + 3]
        i += 4
    return v^


def certificate_w3_basis() -> List[List[Int]]:
    """The eight vectors b_1..b_8 printed in PROOF_CERTIFICATE.md §3."""
    var out = List[List[Int]]()
    var b1: List[Int] = [1,1,2, 1, 1,2,1, -2, 2,1,1, 1]
    var b2: List[Int] = [1,2,2, 1, 2,1,2, -2, 2,2,1, 1]
    var b3: List[Int] = [1,1,3, 1, 1,3,1, -2, 3,1,1, 1]
    var b4: List[Int] = [1,3,2, -1, 2,1,3, 1, 2,3,1, -1, 3,1,2, 1]
    var b5: List[Int] = [1,2,3, 1, 1,3,2, -1, 2,3,1, -1, 3,2,1, 1]
    var b6: List[Int] = [2,2,3, 1, 2,3,2, -2, 3,2,2, 1]
    var b7: List[Int] = [1,3,3, 1, 3,1,3, -2, 3,3,1, 1]
    var b8: List[Int] = [2,3,3, 1, 3,2,3, -2, 3,3,2, 1]
    out.append(_vec(b1))
    out.append(_vec(b2))
    out.append(_vec(b3))
    out.append(_vec(b4))
    out.append(_vec(b5))
    out.append(_vec(b6))
    out.append(_vec(b7))
    out.append(_vec(b8))
    return out^
