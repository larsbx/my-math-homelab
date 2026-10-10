module ParabolicIndexOracle

using ..JuliaOracleLab: OracleOutcome, agrees, disagrees, oracle_error

export GQ, root_one, root_minus_one, root_i, root_minus_i,
       parabolic_index, compare_fixture, low_q_fixtures

const Q = Rational{BigInt}
const GQ = Complex{Q}

rat(n::Integer, d::Integer=1)::Q = BigInt(n) // BigInt(d)
gq(re::Integer, im::Integer=0)::GQ = complex(rat(re), rat(im))
gq_frac(re_num::Integer, re_den::Integer, im_num::Integer=0, im_den::Integer=1)::GQ =
    complex(rat(re_num, re_den), rat(im_num, im_den))

root_one() = gq(1)
root_minus_one() = gq(-1)
root_i() = gq(0, 1)
root_minus_i() = gq(0, -1)

function reciprocal(value::GQ)::GQ
    norm = real(value)^2 + imag(value)^2
    iszero(norm) && throw(DivideError())
    return complex(real(value) / norm, -imag(value) / norm)
end

function germ_step(state::Vector{GQ}, lambda::GQ)::Vector{GQ}
    n = length(state)
    squared = fill(zero(GQ), n)
    for i in eachindex(state), j in eachindex(state)
        degree = (i - 1) + (j - 1)
        degree >= n && continue
        squared[degree + 1] += state[i] * state[j]
    end
    return [lambda * state[k] + squared[k] for k in eachindex(state)]
end

function germ_iterate(lambda::GQ, q::Int, max_degree::Int)::Vector{GQ}
    q >= 1 || throw(ArgumentError("q must be positive"))
    max_degree >= 1 || throw(ArgumentError("max_degree must be positive"))
    state = fill(zero(GQ), max_degree + 1)
    state[2] = one(GQ)
    for _ in 1:q
        state = germ_step(state, lambda)
    end
    return state
end

function reciprocal_series(coeffs::Vector{GQ}, order::Int)::Vector{GQ}
    isempty(coeffs) && throw(ArgumentError("empty series"))
    iszero(coeffs[1]) && throw(DivideError())
    out = fill(zero(GQ), order + 1)
    out[1] = reciprocal(coeffs[1])
    for n in 1:order
        total = zero(GQ)
        for k in 1:n
            k + 1 <= length(coeffs) || continue
            total += coeffs[k + 1] * out[n - k + 1]
        end
        out[n + 1] = -(out[1] * total)
    end
    return out
end

function parabolic_index(lambda::GQ, q::Int)::GQ
    q >= 1 || throw(ArgumentError("q must be positive"))
    lambda^q == one(GQ) || throw(ArgumentError("lambda must be an exact q-th root of unity"))

    max_degree = 2q + 1
    iterate = germ_iterate(lambda, q, max_degree)
    identity = fill(zero(GQ), max_degree + 1)
    identity[2] = one(GQ)
    difference = identity .- iterate

    all(iszero, difference[1:(q + 1)]) ||
        throw(ArgumentError("parabolic multiplicity is below q+1"))

    p_coeffs = difference[(q + 2):(2q + 2)]
    length(p_coeffs) == q + 1 || throw(ArgumentError("insufficient jet order"))
    iszero(p_coeffs[1]) && throw(DivideError())

    return reciprocal_series(p_coeffs, q)[q + 1]
end

function low_q_fixtures()
    return [
        (root_one(), 1, gq(0)),
        (root_minus_one(), 2, gq_frac(1, 8)),
        (root_i(), 4, gq_frac(1447, 4624, -365, 4624)),
        (root_minus_i(), 4, gq_frac(1447, 4624, 365, 4624)),
    ]
end

function compare_fixture(lambda::GQ, q::Int, expected::GQ)::OracleOutcome
    try
        return parabolic_index(lambda, q) == expected ? agrees : disagrees
    catch
        return oracle_error
    end
end

end
