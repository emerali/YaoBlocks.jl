using LinearAlgebra, LinearMaps

export BlockMap

struct BlockMap{T, GT <: AbstractBlock} <: LinearMap{T}
    block::GT

    BlockMap(block::GT) where GT <: AbstractBlock =
        new{datatype(block), GT}(block)
end

function Base.show(io::IO, A::BlockMap{T}) where T
    println(io, "Quantum Circuit Block as LinearMap{$T}")
    print(io, A.block)
end

function LinearMaps.A_mul_B!(y::AbstractVecOrMat{T1}, op::BlockMap{T2}, x::AbstractVecOrMat{T3}) where {T1, T2, T3}
    error("Do not use BlockMap on different precisions, this is not supported.")
end

function LinearMaps.A_mul_B!(y::AbstractVecOrMat{T}, op::BlockMap{T}, v::AbstractVecOrMat{T}) where T
    copyto!(y, v)
    apply!(ArrayReg(y), op.block)
    return y
end


# NOTE: do not overload operator on different element type
#       we don't support this to error when there is performance
#       issue due to conversion.
Base.:(*)(op::BlockMap{T}, v::VT) where {T, VT <: AbstractVecOrMat{T}} =
    mul!(similar(v), op, v)

"""
    opnorm(A::BlockMap, p::Real=2)

[`opnorm`](@ref) for quantum circuit blocks.
"""
LinearAlgebra.opnorm(A::BlockMap, p::Real=2) = opnorm(mat(A.block), p)
LinearAlgebra.ishermitian(A::BlockMap) = ishermitian(A.block)
LinearAlgebra.issymmetric(A::BlockMap) = issymmetric(A.block)
Base.size(bm::BlockMap) = (1 << nqubits(bm.block), 1 << nqubits(bm.block))