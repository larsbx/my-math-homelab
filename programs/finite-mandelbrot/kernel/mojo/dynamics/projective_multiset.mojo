# projective_multiset.mojo
#
# Exact finite-field shadow for z |-> z^2 + c on P^1(F_p).
#
# This module records projective classes and effective zero-cycle
# multiplicities.  It does not import an analytic topology or assert that an
# affine F_p orbit lands on the infinity divisor.  For the polynomial
# morphism [X:Z] |-> [X^2 + c Z^2 : Z^2], infinity is fixed and totally
# ramified, with pullback multiplicity 2^n after n iterates.

comptime MAX_FIELD_MODULUS = 1048576

struct OrbitSignature(ImplicitlyCopyable):
    var tail: Int
    var period: Int
    var rejected: Bool

    def __init__(out self, tail: Int, period: Int, rejected: Bool):
        self.tail = tail
        self.period = period
        self.rejected = rejected

    def accepted(self) -> Bool:
        return not self.rejected


struct ParameterCycle(ImplicitlyCopyable):
    """One coefficient of an effective zero-cycle on the affine parameter
    chart, graded by the critical tail-cycle signature."""

    var residue: Int
    var multiplicity: Int
    var tail: Int
    var period: Int
    var rejected: Bool

    def __init__(out self, residue: Int, multiplicity: Int, tail: Int, period: Int, rejected: Bool):
        self.residue = residue
        self.multiplicity = multiplicity
        self.tail = tail
        self.period = period
        self.rejected = rejected

    def valid(self) -> Bool:
        return not self.rejected and self.residue >= 0 and self.multiplicity >= 0 and self.tail >= 0 and self.period >= 1


def field_residue(value: Int, prime: Int) -> Int:
    var out = value % prime
    if out < 0:
        out += prime
    return out


def quadratic_step(value: Int, parameter: Int, prime: Int) -> Int:
    return field_residue(value * value + parameter, prime)


def critical_orbit_signature(parameter: Int, prime: Int) -> OrbitSignature:
    """Exact tail and period of zero under z |-> z^2 + c over F_p.

    `prime` is an explicit precondition supplied by the caller.  The routine
    rejects values below two and otherwise terminates after at most p + 1
    stored residues by finiteness.
    """
    if prime < 2 or prime > MAX_FIELD_MODULUS:
        return OrbitSignature(0, 0, True)
    var seen = List[Int]()
    var value = 0
    for _ in range(prime + 1):
        for index in range(len(seen)):
            if seen[index] == value:
                return OrbitSignature(index, len(seen) - index, False)
        seen.append(value)
        value = quadratic_step(value, parameter, prime)
    return OrbitSignature(0, 0, True)


def enters_critical_cycle(seed: Int, parameter: Int, prime: Int) -> Bool:
    var signature = critical_orbit_signature(parameter, prime)
    if not signature.accepted():
        return False
    var critical = 0
    for _ in range(signature.tail):
        critical = quadratic_step(critical, parameter, prime)
    var value = field_residue(seed, prime)
    for _ in range(prime + 1):
        var cycle_value = critical
        for _ in range(signature.period):
            if value == cycle_value:
                return True
            cycle_value = quadratic_step(cycle_value, parameter, prime)
        value = quadratic_step(value, parameter, prime)
    return False


def critical_basin_multiplicity(parameter: Int, prime: Int) -> Int:
    """Number of affine residues entering the critical eventual cycle."""
    if prime < 2 or prime > MAX_FIELD_MODULUS:
        return -1
    var count = 0
    for seed in range(prime):
        if enters_critical_cycle(seed, parameter, prime):
            count += 1
    return count


def parameter_cycle(parameter: Int, prime: Int) -> ParameterCycle:
    var signature = critical_orbit_signature(parameter, prime)
    if not signature.accepted():
        return ParameterCycle(0, 0, 0, 0, True)
    return ParameterCycle(
        field_residue(parameter, prime),
        critical_basin_multiplicity(parameter, prime),
        signature.tail,
        signature.period,
        False,
    )


def infinity_pullback_multiplicity(iterates: Int) -> Int:
    """Coefficient of the infinity divisor in (F_c^n)^*[infinity].

    Fixed-width execution is deliberately bounded; -1 means rejected.
    """
    if iterates < 0 or iterates > 60:
        return -1
    return 1 << iterates


def affine_orbit_lands_at_infinity(parameter: Int, seed: Int, prime: Int) -> Bool:
    """Polynomial morphisms preserve the affine chart.

    The arguments are retained to make the quantified finite-field statement
    explicit. Invalid moduli also fail closed.
    """
    _ = parameter
    _ = seed
    if prime < 2 or prime > MAX_FIELD_MODULUS:
        return False
    return False


def projective_multiset_smoke() -> Bool:
    # Over F_5 with c = 1, the critical orbit is 0,1,2,0: tail 0, period 3.
    var signature = critical_orbit_signature(1, 5)
    var coefficient = parameter_cycle(1, 5)
    return (
        signature.accepted() and signature.tail == 0 and signature.period == 3 and
        coefficient.valid() and coefficient.residue == 1 and
        coefficient.multiplicity == 5 and
        infinity_pullback_multiplicity(0) == 1 and
        infinity_pullback_multiplicity(5) == 32 and
        infinity_pullback_multiplicity(61) == -1 and
        not affine_orbit_lands_at_infinity(1, 0, 5)
    )
