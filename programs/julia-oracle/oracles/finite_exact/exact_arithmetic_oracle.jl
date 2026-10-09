#!/usr/bin/env julia

using JuliaOracleLab

function main(args)::Int
    length(args) == 1 || begin
        println(stderr, "usage: exact_arithmetic_oracle.jl TRANSCRIPT")
        return 2
    end
    lines = filter(!isempty, strip.(readlines(args[1])))
    errors = JuliaOracleLab.ExactArithmeticOracle.compare_transcript(lines)
    if !isempty(errors)
        println(stderr, "Exact-arithmetic property probe disagrees with the Julia oracle:")
        foreach(error -> println(stderr, error), errors)
        return 1
    end
    println("OK: property probe agrees with the Julia oracle on 300 integer and 200 rational cases.")
    println("EVIDENCE ONLY: this result does not accept a certificate or prove a claim.")
    return 0
end

exit(main(ARGS))
