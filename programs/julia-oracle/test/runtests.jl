using Test
using JuliaOracleLab

@testset "authority-safe result vocabulary" begin
    @test Set(instances(OracleOutcome)) == Set((agrees, disagrees, inconclusive, oracle_error))
    @test !(:accepted in propertynames(JuliaOracleLab))
    @test !(:proved in propertynames(JuliaOracleLab))
    @test !(:authorized in propertynames(JuliaOracleLab))
end

@testset "checker binding is mandatory" begin
    valid = OracleBinding(
        "finite-integer.bigz.canonical-bytes",
        v"0.1.0",
        "larsbx/finite-math-kernels",
        "bigz-canonical-bytes",
        "larsbx/finite-math-kernels",
        "shared-finite-kernel",
        :exact,
    )
    @test validate_binding(valid)

    missing_checker = OracleBinding(
        "finite-integer.bigz.canonical-bytes", v"0.1.0",
        "larsbx/finite-math-kernels", "bigz-canonical-bytes", "",
        "shared-finite-kernel", :exact,
    )
    @test !validate_binding(missing_checker)
end

@testset "canonical BigInt golden vectors" begin
    @test bytes2hex(canonical_bigint_bytes(big"0")) == "000000000000000000"
    @test bytes2hex(canonical_bigint_bytes(big"1")) == "01000000000000000101"
    @test bytes2hex(canonical_bigint_bytes(big"-1000000001")) == "0200000000000000043b9aca01"

    encoded = canonical_bigint_bytes(big"256")
    @test bytes2hex(encoded) == "0100000000000000020100"
end

@testset "oracle comparison is explicit" begin
    expected = canonical_bigint_bytes(big"-1000000001")
    @test compare_bytes(copy(expected), expected) == agrees

    corrupted = copy(expected)
    corrupted[end] ⊻= 0x01
    @test compare_bytes(corrupted, expected) == disagrees
end

@testset "registry entries fail closed" begin
    entry = Dict{String, Any}(
        "schema" => "julia-oracle-entry/v1",
        "oracle_id" => "finite-integer.bigz.canonical-bytes",
        "version" => "0.1.0",
        "domain_repository" => "larsbx/finite-math-kernels",
        "claim_id" => "bigz-canonical-bytes",
        "checker_repository" => "larsbx/finite-math-kernels",
        "boundary_id" => "shared-finite-kernel",
        "exactness" => "exact",
        "result_vocabulary" => ["agrees", "disagrees", "inconclusive", "oracle_error"],
        "julia_compat" => "1.11",
    )
    @test validate_registry_entry(entry)

    unknown_critical = copy(entry)
    unknown_critical["acceptance_authority"] = true
    @test !validate_registry_entry(unknown_critical)

    missing_checker = copy(entry)
    delete!(missing_checker, "checker_repository")
    @test !validate_registry_entry(missing_checker)

    expanded_vocabulary = copy(entry)
    expanded_vocabulary["result_vocabulary"] = [
        "agrees", "disagrees", "inconclusive", "oracle_error", "accepted",
    ]
    @test !validate_registry_entry(expanded_vocabulary)
end

@testset "exact arithmetic transcript oracle" begin
    oracle = JuliaOracleLab.ExactArithmeticOracle
    @test oracle.encode_z_token(big"0") == "0.0.0.0.0.0.0.0.0"
    @test oracle.encode_z_token(big"-1000000001") ==
        "2.0.0.0.0.0.0.0.4.59.154.202.1"
    @test oracle.encode_q_token(big"-2" // big"4") ==
        "2.0.0.0.0.0.0.0.1.1.1.0.0.0.0.0.0.0.1.2"

    transcript = oracle.expected_lines()
    @test length(transcript) == 1 + oracle.Z_CASES + oracle.Q_CASES + 1
    @test isempty(oracle.compare_transcript(transcript))

    corrupted = copy(transcript)
    tokens = split(corrupted[2])
    tokens[5] = "0.0.0.0.0.0.0.0.0"
    corrupted[2] = join(tokens, " ")
    @test !isempty(oracle.compare_transcript(corrupted))
end


@testset "exact quadratic parabolic-index oracle" begin
    oracle = JuliaOracleLab.ParabolicIndexOracle
    for (lambda, q, expected) in oracle.low_q_fixtures()
        @test oracle.parabolic_index(lambda, q) == expected
        @test oracle.compare_fixture(lambda, q, expected) == agrees
    end

    wrong = oracle.low_q_fixtures()[3]
    @test oracle.compare_fixture(wrong[1], wrong[2], zero(oracle.GQ)) == disagrees

    nonroot = Complex{Rational{BigInt}}(big(1)//big(2), big(0)//big(1))
    @test oracle.compare_fixture(nonroot, 4, zero(oracle.GQ)) == oracle_error
end


@testset "loop-gain cycle lattice oracle" begin
    oracle = JuliaOracleLab.LoopGainOracle

    triangle = [
        oracle.LoopGainEdge(1, 2, [1, 0]),
        oracle.LoopGainEdge(2, 3, [0, 1]),
        oracle.LoopGainEdge(3, 1, [1, 1]),
    ]
    @test oracle.cycle_lattice_rank(3, triangle) == 1
    triangle_gains = oracle.cycle_gain_generators(3, triangle)
    @test size(triangle_gains) == (2, 1)
    @test abs.(triangle_gains[:, 1]) == BigInt[2, 2]
    @test oracle.compare_cycle_rank(3, triangle, 1) == agrees
    @test oracle.compare_gain_rank(3, triangle, 1) == agrees

    parallel = [
        oracle.LoopGainEdge(1, 2, [1]),
        oracle.LoopGainEdge(1, 2, [3]),
    ]
    @test oracle.cycle_lattice_rank(2, parallel) == 1
    parallel_gains = oracle.cycle_gain_generators(2, parallel)
    @test size(parallel_gains) == (1, 1)
    @test abs(parallel_gains[1, 1]) == 2

    loop = [oracle.LoopGainEdge(1, 1, [7])]
    @test oracle.cycle_lattice_basis(1, loop) == reshape(BigInt[1], 1, 1)
    @test oracle.cycle_gain_generators(1, loop) == reshape(BigInt[7], 1, 1)

    tree = [
        oracle.LoopGainEdge(1, 2, [2]),
        oracle.LoopGainEdge(2, 3, [5]),
    ]
    @test oracle.cycle_lattice_rank(3, tree) == 0
    @test size(oracle.cycle_gain_generators(3, tree), 2) == 0

    malformed = [oracle.LoopGainEdge(1, 3, [1])]
    @test oracle.compare_cycle_rank(2, malformed, 0) == oracle_error

    mixed = [
        oracle.LoopGainEdge(1, 2, [1]),
        oracle.LoopGainEdge(2, 1, [1, 2]),
    ]
    @test_throws ArgumentError oracle.cycle_gain_generators(2, mixed)
end
