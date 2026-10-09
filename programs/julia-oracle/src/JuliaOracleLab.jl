module JuliaOracleLab

export OracleOutcome, agrees, disagrees, inconclusive, oracle_error
export OracleBinding, validate_binding, validate_registry_entry
export canonical_bigint_bytes, compare_bytes
export ExactArithmeticOracle, ParabolicIndexOracle, LoopGainOracle

@enum OracleOutcome agrees disagrees inconclusive oracle_error

struct OracleBinding
    oracle_id::String
    version::VersionNumber
    domain_repository::String
    claim_id::String
    checker_repository::String
    boundary_id::String
    exactness::Symbol
end

const ALLOWED_EXACTNESS = Set((:exact, :interval, :numerical, :mixed))
const REQUIRED_REGISTRY_KEYS = Set((
    "schema", "oracle_id", "version", "domain_repository", "claim_id",
    "checker_repository", "boundary_id", "exactness", "result_vocabulary",
    "julia_compat",
))
const OPTIONAL_REGISTRY_KEYS = Set(("manifest_digest",))
const RESULT_VOCABULARY = [
    "agrees", "disagrees", "inconclusive", "oracle_error",
]

function validate_binding(binding::OracleBinding)::Bool
    fields = (
        binding.oracle_id,
        binding.domain_repository,
        binding.claim_id,
        binding.checker_repository,
        binding.boundary_id,
    )
    all(value -> !isempty(value), fields) || return false
    binding.exactness in ALLOWED_EXACTNESS || return false
    return true
end

function validate_registry_entry(entry::AbstractDict)::Bool
    keys_as_strings = Set(string(key) for key in keys(entry))
    REQUIRED_REGISTRY_KEYS ⊆ keys_as_strings || return false
    keys_as_strings ⊆ union(REQUIRED_REGISTRY_KEYS, OPTIONAL_REGISTRY_KEYS) || return false

    get(entry, "schema", nothing) == "julia-oracle-entry/v1" || return false
    get(entry, "exactness", nothing) in string.(collect(ALLOWED_EXACTNESS)) || return false
    get(entry, "result_vocabulary", nothing) == RESULT_VOCABULARY || return false

    for key in ("oracle_id", "domain_repository", "claim_id", "checker_repository", "boundary_id", "julia_compat")
        value = get(entry, key, nothing)
        value isa AbstractString && !isempty(value) || return false
    end

    try
        VersionNumber(get(entry, "version", ""))
    catch
        return false
    end
    return true
end

function canonical_bigint_bytes(value::Integer)::Vector{UInt8}
    sign_byte = value == 0 ? UInt8(0) : value > 0 ? UInt8(1) : UInt8(2)
    magnitude = abs(big(value))
    magnitude_bytes = UInt8[]
    while magnitude != 0
        magnitude, remainder = divrem(magnitude, 256)
        push!(magnitude_bytes, UInt8(remainder))
    end
    reverse!(magnitude_bytes)

    byte_len = UInt64(length(magnitude_bytes))
    result = UInt8[sign_byte]
    for shift in 56:-8:0
        push!(result, UInt8((byte_len >> shift) & 0xff))
    end
    append!(result, magnitude_bytes)
    return result
end

compare_bytes(actual::AbstractVector{UInt8}, expected::AbstractVector{UInt8})::OracleOutcome =
    actual == expected ? agrees : disagrees

# Oracles live in their own authority plane (ESTATE.toml): oracles/<domain>/.
include(joinpath("..", "oracles", "finite_exact", "ExactArithmeticOracle.jl"))
include(joinpath("..", "oracles", "quadratic_dynamics", "ParabolicIndexOracle.jl"))
include(joinpath("..", "oracles", "pisot_substitutions", "LoopGainOracle.jl"))

end
