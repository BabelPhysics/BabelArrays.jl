#=
  @ author: ChenyuBao <chenyu.bao@outlook.com>
  @ date: 2025-11-14 16:29:19
  @ license: MIT
  @ language: Julia
  @ declaration: Mutable arrays running in kernel on any devices.
  @ description:
 =#

#=
struct BArray{S, T <: Real, P} <: AbstractBabelArray{S, T, P}
    row_::Int
    col_::Int
    data_::Ref
end
const BScalar{T <: Real} = BArray{Tuple{}, T, 0}
const BVector{N, T <: Real} = BArray{Tuple{N}, T, 1}
const BMatrix{M, N, T <: Real} = BArray{Tuple{M, N}, T, 2}
const BSquareMatrix{N, T <: Real} = BArray{Tuple{N, N}, T, 2}
const BVecOrMat{T} = Union{BVector{<:Any, T}, BMatrix{<:Any, <:Any, T}}
=#

@inline function BScalar(row::Integer, col::Integer, data::AbstractArray{T, 2}) where {T <: Real}
    return BScalar{T}(row, col, data)
end

@inline function BVector{N}(row::Integer, col::Integer, data::AbstractArray{T, 2}) where {N, T <: Real}
    return BVector{N, T}(row, col, data)
end

@inline function BMatrix{M, N}(row::Integer, col::Integer, data::AbstractArray{T, 2}) where {M, N, T}
    return BMatrix{M, N, T}(row, col, data)
end

@inline function BSquareMatrix{N}(row::Integer, col::Integer, data::AbstractArray{T, 2}) where {N, T <: Real}
    return BSquareMatrix{N, T}(row, col, data)
end
