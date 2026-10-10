"""The six length-7 K_2-zero seed pairs S_7 of PROOF_CERTIFICATE.md §4.

Only the *words* are stored. The seed matrices A_k, their characteristic
polynomials, traces and eigenvectors are derived by the kernel; nothing from
the certificate's tables §6 is transcribed.
"""

from psc.words import Pair


def _pair(u: List[Int], v: List[Int]) -> Pair:
    """Build a pair from 1-based letters, shifting to the internal 0-based alphabet."""
    var a = List[Int]()
    var b = List[Int]()
    for i in range(len(u)):
        a.append(u[i] - 1)
    for i in range(len(v)):
        b.append(v[i] - 1)
    return Pair(a, b)


def length7_seeds() -> List[Pair]:
    var out = List[Pair]()
    var u0: List[Int] = [1, 2, 2, 3, 3, 1, 2]
    var v0: List[Int] = [2, 3, 1, 1, 2, 2, 3]
    var u1: List[Int] = [1, 2, 3, 3, 1, 1, 2]
    var v1: List[Int] = [3, 1, 1, 2, 2, 3, 1]
    var u2: List[Int] = [1, 3, 2, 2, 1, 1, 3]
    var v2: List[Int] = [2, 1, 1, 3, 3, 2, 1]
    var u3: List[Int] = [1, 3, 3, 2, 2, 1, 3]
    var v3: List[Int] = [3, 2, 1, 1, 3, 3, 2]
    var u4: List[Int] = [2, 1, 3, 3, 2, 2, 1]
    var v4: List[Int] = [3, 2, 2, 1, 1, 3, 2]
    var u5: List[Int] = [2, 3, 3, 1, 1, 2, 3]
    var v5: List[Int] = [3, 1, 2, 2, 3, 3, 1]
    out.append(_pair(u0, v0))
    out.append(_pair(u1, v1))
    out.append(_pair(u2, v2))
    out.append(_pair(u3, v3))
    out.append(_pair(u4, v4))
    out.append(_pair(u5, v5))
    return out^


def certificate_seed_matrices() -> List[List[Int]]:
    """The A_k printed in PROOF_CERTIFICATE.md §6, row-major.

    Kept *only* as an independent cross-check target for the derived Theta(K_3(s_k)).
    """
    var out = List[List[Int]]()
    var a0: List[Int] = [-2, 3, -3, -3, 4, -3, -3, 3, -2]
    var a1: List[Int] = [-4, 3, 3, -3, 2, 3, -3, 3, 2]
    var a2: List[Int] = [4, -3, -3, 3, -2, -3, 3, -3, -2]
    var a3: List[Int] = [2, 3, -3, 3, 2, -3, 3, 3, -4]
    var a4: List[Int] = [-2, 3, -3, -3, 4, -3, -3, 3, -2]
    var a5: List[Int] = [-2, -3, 3, -3, -2, 3, -3, -3, 4]
    out.append(a0^)
    out.append(a1^)
    out.append(a2^)
    out.append(a3^)
    out.append(a4^)
    out.append(a5^)
    return out^
