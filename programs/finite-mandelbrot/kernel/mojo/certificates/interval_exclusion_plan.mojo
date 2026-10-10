# interval_exclusion_plan.mojo
#
# Mojo-native replacement target for reference/python/interval/interval_exclusion_reference.py.
#
# This file is deliberately contract-shaped until the bigint rational backend is
# certificate-ready. The goal is to specify the exact computation surface that
# must replace the Python reference oracle.


struct OrbitIntervalRequest:
    var ell: Int
    var period: Int
    var horizon: Int

    fn __init__(inout self, ell: Int, period: Int, horizon: Int):
        self.ell = ell
        self.period = period
        self.horizon = horizon


struct ExclusionResult:
    var total_forbidden: Int
    var excluded_forbidden: Int
    var failed_count: Int

    fn __init__(inout self, total_forbidden: Int, excluded_forbidden: Int, failed_count: Int):
        self.total_forbidden = total_forbidden
        self.excluded_forbidden = excluded_forbidden
        self.failed_count = failed_count

    fn all_excluded(self) -> Bool:
        return self.failed_count == 0 and self.excluded_forbidden == self.total_forbidden


fn intended_pair(ell: Int, period: Int, i: Int, j: Int) -> Bool:
    # Intended tail equality: i >= ell and period divides j-i.
    # Pre-tail pairs remain forbidden even if their distance is a multiple of the period.
    if i < ell:
        return False
    return ((j - i) % period) == 0


fn count_forbidden_pairs(ell: Int, period: Int, horizon: Int) -> Int:
    var total = 0
    for i in range(horizon + 1):
        for j in range(i + 1, horizon + 1):
            if not intended_pair(ell, period, i, j):
                total += 1
    return total


fn demo_c_minus_2_forbidden_count() -> Int:
    return count_forbidden_pairs(2, 1, 3)


fn demo_m41_forbidden_count() -> Int:
    return count_forbidden_pairs(4, 1, 6)


fn verify_exclusion_result(result: ExclusionResult) -> Bool:
    # Native implementation must only return true when every forbidden pair was
    # checked on the same ComplexIntervalBox used for localization.
    return result.all_excluded()


# Native replacement target:
#
# fn q_orbit_interval(cbox: ComplexIntervalBox, horizon: Int) -> List[ComplexIntervalBox]
#     Q[0] = 0
#     Q[n+1] = Q[n]^2 + cbox
#
# fn hij_interval(qs: List[ComplexIntervalBox], i: Int, j: Int) -> ComplexIntervalBox
#     return qs[j] - qs[i]
#
# fn excludes_zero(z: ComplexIntervalBox) -> Bool
#     return z.re.excludes_zero() or z.im.excludes_zero()
#
# fn verify_exact_type_exclusions(cbox: ComplexIntervalBox, request: OrbitIntervalRequest) -> ExclusionResult
#     build q_orbit_interval(cbox, request.horizon)
#     for each forbidden pair, verify excludes_zero(hij_interval(...))
#
# This must be implemented over normalized rational endpoints, not Float64.
