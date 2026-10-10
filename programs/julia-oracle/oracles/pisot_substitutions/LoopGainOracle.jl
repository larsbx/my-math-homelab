module LoopGainOracle

using ..JuliaOracleLab: OracleOutcome, agrees, disagrees, oracle_error

export LoopGainEdge, validate_graph, reduced_incidence,
       cycle_lattice_basis, cycle_gain_generators,
       cycle_lattice_rank, gain_rank_over_q,
       compare_cycle_rank, compare_gain_rank

const Q = Rational{BigInt}

struct LoopGainEdge
    source::Int
    target::Int
    gain::Vector{BigInt}
end

LoopGainEdge(source::Int, target::Int, gain::AbstractVector{<:Integer}) =
    LoopGainEdge(source, target, BigInt.(gain))

function validate_graph(vertex_count::Int, edges::AbstractVector{LoopGainEdge})::Int
    vertex_count >= 1 || throw(ArgumentError("vertex_count must be positive"))
    isempty(edges) && return 0
    dimension = length(first(edges).gain)
    dimension >= 1 || throw(ArgumentError("gain coordinates must be nonempty"))
    for edge in edges
        1 <= edge.source <= vertex_count ||
            throw(ArgumentError("edge source outside vertex range"))
        1 <= edge.target <= vertex_count ||
            throw(ArgumentError("edge target outside vertex range"))
        length(edge.gain) == dimension ||
            throw(ArgumentError("gain dimensions disagree"))
    end
    return dimension
end

function reduced_incidence(
    vertex_count::Int, edges::AbstractVector{LoopGainEdge}
)::Matrix{BigInt}
    validate_graph(vertex_count, edges)
    # Delete the last vertex row. The full incidence matrix has one redundant
    # row in every connected component; retaining fewer equations never changes
    # the kernel for a graph whose other component rows are still present.
    rows = max(vertex_count - 1, 0)
    matrix = zeros(BigInt, rows, length(edges))
    for (column, edge) in enumerate(edges)
        edge.source <= rows && (matrix[edge.source, column] -= 1)
        edge.target <= rows && (matrix[edge.target, column] += 1)
    end
    return matrix
end

function rref(matrix::Matrix{Q})
    rows, columns = size(matrix)
    out = copy(matrix)
    pivots = Int[]
    pivot_row = 1
    for column in 1:columns
        pivot_row > rows && break
        found = nothing
        for row in pivot_row:rows
            if !iszero(out[row, column])
                found = row
                break
            end
        end
        found === nothing && continue
        row = found::Int
        if row != pivot_row
            saved = copy(out[pivot_row, :])
            out[pivot_row, :] = out[row, :]
            out[row, :] = saved
        end
        pivot = out[pivot_row, column]
        out[pivot_row, :] ./= pivot
        for other in 1:rows
            other == pivot_row && continue
            factor = out[other, column]
            iszero(factor) && continue
            out[other, :] .-= factor .* out[pivot_row, :]
        end
        push!(pivots, column)
        pivot_row += 1
    end
    return out, pivots
end

function integer_nullspace_basis(matrix::Matrix{BigInt})::Matrix{BigInt}
    rows, columns = size(matrix)
    columns == 0 && return zeros(BigInt, columns, 0)
    rational = Q.(matrix)
    reduced, pivots = rref(rational)
    pivot_set = Set(pivots)
    free = [column for column in 1:columns if !(column in pivot_set)]
    basis = zeros(BigInt, columns, length(free))

    for (basis_column, free_column) in enumerate(free)
        basis[free_column, basis_column] = 1
        for (row, pivot_column) in enumerate(pivots)
            coefficient = -reduced[row, free_column]
            denominator(coefficient) == 1 ||
                throw(ArgumentError(
                    "incidence nullspace unexpectedly required a nonintegral basis coefficient"
                ))
            basis[pivot_column, basis_column] = numerator(coefficient)
        end
    end

    # Independent replay of B * basis == 0.
    product = matrix * basis
    all(iszero, product) ||
        throw(ArgumentError("computed cycle-lattice basis does not close"))
    return basis
end

function cycle_lattice_basis(
    vertex_count::Int, edges::AbstractVector{LoopGainEdge}
)::Matrix{BigInt}
    incidence = reduced_incidence(vertex_count, edges)
    return integer_nullspace_basis(incidence)
end

cycle_lattice_rank(vertex_count::Int, edges::AbstractVector{LoopGainEdge}) =
    size(cycle_lattice_basis(vertex_count, edges), 2)

function cycle_gain_generators(
    vertex_count::Int, edges::AbstractVector{LoopGainEdge}
)::Matrix{BigInt}
    dimension = validate_graph(vertex_count, edges)
    basis = cycle_lattice_basis(vertex_count, edges)
    isempty(edges) && return zeros(BigInt, 0, 0)

    gain_matrix = zeros(BigInt, dimension, length(edges))
    for (column, edge) in enumerate(edges), row in 1:dimension
        gain_matrix[row, column] = edge.gain[row]
    end
    return gain_matrix * basis
end

function rational_rank(matrix::Matrix{BigInt})::Int
    _, pivots = rref(Q.(matrix))
    return length(pivots)
end

gain_rank_over_q(vertex_count::Int, edges::AbstractVector{LoopGainEdge}) =
    rational_rank(cycle_gain_generators(vertex_count, edges))

function compare_cycle_rank(
    vertex_count::Int, edges::AbstractVector{LoopGainEdge}, expected::Int
)::OracleOutcome
    try
        return cycle_lattice_rank(vertex_count, edges) == expected ? agrees : disagrees
    catch
        return oracle_error
    end
end

function compare_gain_rank(
    vertex_count::Int, edges::AbstractVector{LoopGainEdge}, expected::Int
)::OracleOutcome
    try
        return gain_rank_over_q(vertex_count, edges) == expected ? agrees : disagrees
    catch
        return oracle_error
    end
end

end
