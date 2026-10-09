"""PROOF_CERTIFICATE.md rendered as executable, exact checks.

Each entry of the certificate's §13 verification checklist becomes one `Check`.
Nothing that can be derived is transcribed: the seed matrices, characteristic
polynomials, traces and the dimension of `W_3` are all recomputed from the seed
words and the definitions.

Scope. These checks certify the *finite algebra* of the Spectral module. They do
not establish the SCC-level statements of §12, and they do not establish
hypothesis G1 (finiteness of `B_sigma`). See docs/verification-architecture.md.
"""

from finite_linear_algebra.mat3 import Mat3, identity3, has_rational_root
from psc.pisot import is_pip, has_equal_row_sums
from finite_linear_algebra.qlinalg import rank, in_span
from psc.seeds import length7_seeds, certificate_seed_matrices
from finite_linear_algebra.tensor3 import tensor_cube_apply, theta, is_zero27, zeros27, idx3
from psc.w3 import w3_basis, certificate_w3_basis, in_w3, spans_same_space
from psc.words import Pair, is_zero, is_balanced, k1, k2, k3


struct Check(Copyable, Movable, Writable):
    var name: String
    var passed: Bool
    var detail: String

    def __init__(out self, name: String, passed: Bool, detail: String):
        self.name = name
        self.passed = passed
        self.detail = detail

    def write_to[W: Writer](self, mut w: W):
        w.write("[", "PASS" if self.passed else "FAIL", "] ", self.name)
        if self.detail.byte_length() > 0:
            w.write("  -- ", self.detail)


def pip_corpus(bound: Int = 2) -> List[Mat3]:
    """Every PIP incidence matrix with entries in `0..bound`."""
    var out = List[Mat3]()
    var n = bound + 1
    for i in range(n * n * n * n * n * n * n * n * n):
        var e = List[Int]()
        var t = i
        for _ in range(9):
            e.append(t % n)
            t //= n
        var m = Mat3(e)
        if is_pip(m):
            out.append(m^)
    return out^


def scaled_identity(c: Int) -> Mat3:
    return identity3().scale(c)


def q_target1(m: Mat3, x: List[Int]) -> List[Int]:
    """`Q(M) x = (M^{(x)3} - det(M) I)^2 x`, the PIP-Locus Target 1 polynomial vector."""
    var d = m.det()
    var y = tensor_cube_apply(m, x)
    var z = zeros27()
    for i in range(27):
        z[i] = y[i] - d * x[i]
    var y2 = tensor_cube_apply(m, z)
    var out = zeros27()
    for i in range(27):
        out[i] = y2[i] - d * z[i]
    return out^


def run_all(corpus_bound: Int = 2) -> List[Check]:
    var checks = List[Check]()
    var seeds = length7_seeds()
    var certA = certificate_seed_matrices()
    var qb = w3_basis()
    var cb = certificate_w3_basis()

    # -- 1 / 2: the shuffle-kernel sector -------------------------------------
    checks.append(Check("C1  dim W_3 = 8 (derived as ker S)", len(qb) == 8,
                        "dim = " + String(len(qb))))
    checks.append(Check("C2  certificate basis b_1..b_8 spans ker S",
                        spans_same_space(cb, qb), ""))

    # -- 3: seeds are balanced with K_1 = K_2 = 0 ------------------------------
    var ok = True
    for k in range(len(seeds)):
        if not (is_balanced(seeds[k]) and seeds[k].length() == 7
                and is_zero(k1(seeds[k])) and is_zero(k2(seeds[k]))):
            ok = False
    checks.append(Check("C3  six length-7 seeds: balanced, K_1 = 0, K_2 = 0", ok,
                        String(len(seeds)) + " seeds"))

    # -- 4 / 5: K_3(s_k) lands in W_3 -----------------------------------------
    ok = True
    for k in range(len(seeds)):
        if not in_w3(k3(seeds[k])):
            ok = False
    checks.append(Check("C4  K_3(s_k) in W_3 for every seed", ok, ""))

    # -- 6 / 7: derived seed matrices agree with the certificate tables --------
    ok = True
    for k in range(len(seeds)):
        if theta(k3(seeds[k])) != Mat3(certA[k]):
            ok = False
    checks.append(Check("C5  Theta(K_3(s_k)) equals certificate A_k", ok, ""))

    var props = True
    var traces = String("")
    for k in range(len(seeds)):
        var a = theta(k3(seeds[k]))
        var chi = a.charpoly()
        var ones: List[Int] = [1, 1, 1]
        var img = a.apply(ones)
        var lam = img[0]
        var eig = (img[1] == lam and img[2] == lam and (lam == 2 or lam == -2))
        if not (not a.is_zero() and a.trace() == 0 and a.det() != 0
                and (a * a).trace() == 6 and eig and has_rational_root(chi)):
            props = False
        traces += String(lam) + " "
    checks.append(Check(
        "C6  A_k: nonzero, traceless, rank 3, tr(A_k^2) = 6, A_k(1,1,1)^T = lambda(1,1,1)^T",
        props, "lambda_k = " + traces))

    # -- 10: the Theta intertwining identity, over the PIP corpus --------------
    var corpus = pip_corpus(corpus_bound)
    var inter = True
    for i in range(len(corpus)):
        var m = corpus[i].copy()
        var d = m.det()
        for k in range(len(seeds)):
            var x = k3(seeds[k])
            var y = tensor_cube_apply(m, x)
            # Theta(M^{(x)3} x) . M == det(M) . M . Theta(x)   (inverse cleared)
            if theta(y) * m != (m * theta(x)).scale(d):
                inter = False
    checks.append(Check("C7  Theta(M^{(x)3} x) M = det(M) M Theta(x) on the PIP corpus",
                        inter, String(len(corpus)) + " PIP matrices x 6 seeds"))

    # C8 certifies invariance of all of W_3, so test an actual 8-vector basis,
    # not merely the six K_3 seed tensors (whose span has dimension 3).
    var invar = True
    for i in range(len(corpus)):
        var m = corpus[i].copy()
        for k in range(len(cb)):
            if not in_w3(tensor_cube_apply(m, cb[k])):
                invar = False
    checks.append(Check("C8  W_3 is M^{(x)3}-invariant on the PIP corpus", invar,
                        String(len(corpus)) + " PIP matrices x 8 basis vectors"))

    # -- Section 7: PIP-Locus Target 1, verified on the corpus -----------------
    var t1 = True
    for i in range(len(corpus)):
        for k in range(len(seeds)):
            if is_zero27(q_target1(corpus[i], k3(seeds[k]))):
                t1 = False
    checks.append(Check("C9  Target 1: (Phi_3 - det M)^2 K_3(s_k) != 0 on the PIP corpus",
                        t1, String(len(corpus) * len(seeds)) + " instances"))

    # -- Section 7 corollary: no PIP has equal row sums ------------------------
    var rows = True
    for i in range(len(corpus)):
        if has_equal_row_sums(corpus[i]):
            rows = False
    checks.append(Check("C10 no PIP incidence matrix has all row sums equal", rows, ""))

    return checks^