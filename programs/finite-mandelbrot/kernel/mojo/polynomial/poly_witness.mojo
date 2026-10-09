# poly_witness.mojo
#
# Certificate-facing polynomial witness records.
#
# These records preserve the proof obligations for exact polynomial arithmetic:
# - build Q_n(C) by Q_{n+1}=Q_n^2+C;
# - compute R_{ell,k}=Q_{ell+k}-Q_ell;
# - squarefree only, never lower-factor gcd stripping;
# - prove P=sqfree(R) through a gcd(R,R') witness and exact division.
#
# The executable arithmetic backend is still staged. This module is the stable
# verifier contract that a later exact PolyZ implementation must satisfy.


struct PolyId:
    var name_code: Int64
    var degree: Int64

    fn __init__(inout self, name_code: Int64, degree: Int64):
        self.name_code = name_code
        self.degree = degree


struct CriticalOrbitBuildWitness:
    var max_n: Int64
    var recurrence_checked: Bool

    fn __init__(inout self, max_n: Int64, recurrence_checked: Bool):
        self.max_n = max_n
        self.recurrence_checked = recurrence_checked


struct ReturnPolynomialWitness:
    var ell: Int64
    var k: Int64
    var q_ell: PolyId
    var q_ell_plus_k: PolyId
    var return_poly: PolyId
    var subtraction_checked: Bool

    fn __init__(
        inout self,
        ell: Int64,
        k: Int64,
        q_ell: PolyId,
        q_ell_plus_k: PolyId,
        return_poly: PolyId,
        subtraction_checked: Bool,
    ):
        self.ell = ell
        self.k = k
        self.q_ell = q_ell
        self.q_ell_plus_k = q_ell_plus_k
        self.return_poly = return_poly
        self.subtraction_checked = subtraction_checked


struct SquarefreeWitness:
    var raw_return: PolyId
    var derivative: PolyId
    var gcd_rrp: PolyId
    var squarefree_poly: PolyId
    var gcd_witness_checked: Bool
    var exact_division_checked: Bool

    fn __init__(
        inout self,
        raw_return: PolyId,
        derivative: PolyId,
        gcd_rrp: PolyId,
        squarefree_poly: PolyId,
        gcd_witness_checked: Bool,
        exact_division_checked: Bool,
    ):
        self.raw_return = raw_return
        self.derivative = derivative
        self.gcd_rrp = gcd_rrp
        self.squarefree_poly = squarefree_poly
        self.gcd_witness_checked = gcd_witness_checked
        self.exact_division_checked = exact_division_checked


fn squarefree_witness_valid(w: SquarefreeWitness) -> Bool:
    return w.gcd_witness_checked and w.exact_division_checked


fn reject_lower_factor_gcd_stripping(attempted: Bool) -> Bool:
    # Returns true exactly when no forbidden global stripping was attempted.
    # Exact-type is certified only by pointwise exclusions on the isolated box.
    return not attempted


struct PolyCertificateHeader:
    var orbit_witness: CriticalOrbitBuildWitness
    var return_witness: ReturnPolynomialWitness
    var squarefree_witness: SquarefreeWitness
    var attempted_lower_factor_stripping: Bool

    fn __init__(
        inout self,
        orbit_witness: CriticalOrbitBuildWitness,
        return_witness: ReturnPolynomialWitness,
        squarefree_witness: SquarefreeWitness,
        attempted_lower_factor_stripping: Bool,
    ):
        self.orbit_witness = orbit_witness
        self.return_witness = return_witness
        self.squarefree_witness = squarefree_witness
        self.attempted_lower_factor_stripping = attempted_lower_factor_stripping


fn poly_certificate_header_valid(h: PolyCertificateHeader) -> Bool:
    return (
        h.orbit_witness.recurrence_checked and
        h.return_witness.subtraction_checked and
        squarefree_witness_valid(h.squarefree_witness) and
        reject_lower_factor_gcd_stripping(h.attempted_lower_factor_stripping)
    )
