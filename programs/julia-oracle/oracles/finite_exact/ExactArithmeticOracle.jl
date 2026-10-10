module ExactArithmeticOracle

export SEED, Z_CASES, Q_CASES, expected_lines, compare_transcript,
       encode_z_token, encode_q_token

const SEED = UInt64(11400714819323198485)
const Z_CASES = 300
const Q_CASES = 200
const MAX_LIMBS = 6
const BASE = big(10)^9

mutable struct Xorshift64Star
    state::UInt64
end

function next!(rng::Xorshift64Star)::UInt64
    x = rng.state
    x ⊻= x >> 12
    x ⊻= x << 25
    x ⊻= x >> 27
    rng.state = x
    return x * UInt64(2685821657736338717)
end

function random_integer!(rng::Xorshift64Star)::BigInt
    if next!(rng) % UInt64(4) == 0
        return BigInt(next!(rng) % UInt64(2001)) - 1000
    end
    count = Int(next!(rng) % UInt64(MAX_LIMBS)) + 1
    value = BigInt(0)
    scale = BigInt(1)
    for _ in 1:count
        pick = next!(rng)
        limb = pick % UInt64(5) == 0 ? BASE - 1 : BigInt(pick % UInt64(10^9))
        value += limb * scale
        scale *= BASE
    end
    if value != 0 && next!(rng) % UInt64(2) == 1
        value = -value
    end
    return value
end

function random_nonzero_integer!(rng::Xorshift64Star)::BigInt
    value = random_integer!(rng)
    return value == 0 ? BigInt(1) : value
end

random_rational!(rng::Xorshift64Star) =
    random_integer!(rng) // random_nonzero_integer!(rng)

function canonical_bigint_bytes(value::Integer)::Vector{UInt8}
    sign = value == 0 ? UInt8(0) : value > 0 ? UInt8(1) : UInt8(2)
    magnitude = abs(BigInt(value))
    bytes = UInt8[]
    while magnitude != 0
        magnitude, remainder = divrem(magnitude, 256)
        push!(bytes, UInt8(remainder))
    end
    reverse!(bytes)
    result = UInt8[sign]
    length64 = UInt64(length(bytes))
    for shift in 56:-8:0
        push!(result, UInt8((length64 >> shift) & 0xff))
    end
    append!(result, bytes)
    return result
end

encode_z_token(value::Integer) = join(canonical_bigint_bytes(value), ".")
encode_q_token(value::Rational{BigInt}) =
    string(encode_z_token(numerator(value)), ".", encode_z_token(denominator(value)))
flag(value::Bool) = value ? "1" : "0"

function expected_lines()::Vector{String}
    rng = Xorshift64Star(SEED)
    lines = String[
        "HEADER exact-arithmetic-property-probe 1 $(SEED) $(Z_CASES) $(Q_CASES) 0",
    ]
    for index in 0:(Z_CASES - 1)
        a, b = random_integer!(rng), random_integer!(rng)
        quotient = if b == 0
            ("rejected", "rejected")
        else
            quotient_value, remainder_value = divrem(a, b)
            (encode_z_token(quotient_value), encode_z_token(remainder_value))
        end
        push!(lines, join((
            "Z", string(index), encode_z_token(a), encode_z_token(b),
            encode_z_token(a + b), encode_z_token(a - b), encode_z_token(a * b),
            flag(a < b), flag(a == b), encode_z_token(gcd(a, b)),
            quotient[1], quotient[2], "1",
        ), " "))
    end
    for index in 0:(Q_CASES - 1)
        a, b = random_rational!(rng), random_rational!(rng)
        quotient = b == 0 ? "rejected" : encode_q_token(a / b)
        push!(lines, join((
            "Q", string(index), encode_q_token(a), encode_q_token(b),
            encode_q_token(a + b), encode_q_token(a - b), encode_q_token(a * b),
            quotient, flag(a < b), flag(a <= b), flag(a == b), "1",
        ), " "))
    end
    push!(lines, "END")
    return lines
end

function compare_transcript(actual::AbstractVector{<:AbstractString})::Vector{String}
    expected = expected_lines()
    errors = String[]
    length(actual) == length(expected) ||
        push!(errors, "transcript has $(length(actual)) lines, expected $(length(expected))")
    for (line_number, (wanted, got)) in enumerate(zip(expected, actual))
        wanted == got && continue
        wanted_tokens, got_tokens = split(wanted), split(got)
        limit = min(length(wanted_tokens), length(got_tokens))
        first = findfirst(i -> wanted_tokens[i] != got_tokens[i], 1:limit)
        token = first === nothing ? limit + 1 : first
        wanted_token = token <= length(wanted_tokens) ? repr(wanted_tokens[token]) : "'<none>'"
        got_token = token <= length(got_tokens) ? repr(got_tokens[token]) : "'<none>'"
        push!(errors, "line $(line_number) token $(token - 1): expected $(wanted_token), got $(got_token)")
        if length(errors) >= 20
            push!(errors, "... further mismatches suppressed")
            break
        end
    end
    return errors
end

end
