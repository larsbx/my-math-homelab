# collision_sets.mojo
#
# Finite collision-set logic for exact Misiurewicz certificates.
#
# This preserves the corrected semantic rule:
#   I_{ell,k}(H) = {(i,j): ell <= i < j <= H and k divides (j-i)}
#   F_{ell,k}(H) = all pairs 0 <= i < j <= H not in I
#
# The minimal horizon H=ell+k makes I contain only (ell, ell+k).
# Longer horizons include intended periodic-tail equalities.

fn is_intended_tail_pair(ell: Int, k: Int, i: Int, j: Int) -> Bool:
    if i < ell:
        return False
    if j <= i:
        return False
    return ((j - i) % k) == 0


fn pair_count(horizon: Int) -> Int:
    return (horizon * (horizon + 1)) // 2


fn intended_pair_count(ell: Int, k: Int, horizon: Int) -> Int:
    var count = 0
    for i in range(horizon + 1):
        for j in range(i + 1, horizon + 1):
            if is_intended_tail_pair(ell, k, i, j):
                count += 1
    return count


fn forbidden_pair_count(ell: Int, k: Int, horizon: Int) -> Int:
    return pair_count(horizon) - intended_pair_count(ell, k, horizon)


fn print_collision_partition(ell: Int, k: Int, horizon: Int):
    print("ell=", ell, " k=", k, " H=", horizon)
    print("intended tail equalities:")
    for i in range(horizon + 1):
        for j in range(i + 1, horizon + 1):
            if is_intended_tail_pair(ell, k, i, j):
                print("  I: (", i, ",", j, ")")
    print("forbidden strict exclusions:")
    for i in range(horizon + 1):
        for j in range(i + 1, horizon + 1):
            if not is_intended_tail_pair(ell, k, i, j):
                print("  F: (", i, ",", j, ")")
    print("counts: I=", intended_pair_count(ell, k, horizon), " F=", forbidden_pair_count(ell, k, horizon))
