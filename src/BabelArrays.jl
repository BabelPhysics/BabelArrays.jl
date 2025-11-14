#=
  @ author: ChenyuBao <chenyu.bao@outlook.com>
  @ date: 2025-11-07 15:06:55
  @ license: MIT
  @ language: Julia
  @ declaration: Mutable arrays running in kernel on any devices.
  @ description: BabelArrays.jl -> Main module of BabelArrays.jl
 =#

module BabelArrays

export unsafe_real
export AbstractBabelArray
export BabelScalar, BabelVector, BabelMatrix, BabelSquareMatrix, BabelVecOrMat
export BArray
export BScalar, BVector, BMatrix, BSquareMatrix, BVecOrMat

@inline function unsafe_real(T::Type{<:AbstractFloat}, x::Real)::T
    return T(x)
end

@inline function unsafe_real(T::Type{<:Integer}, x::Integer)::T
    return T(x)
end

@inline function unsafe_real(T::Type{<:Integer}, x::AbstractFloat)::T
    return unsafe_trunc(T, floor(x))
end

import StaticArrays
import StaticArraysCore
import StaticArraysCore: tuple_prod
import StaticArraysCore: Size

# * ==================== AbstractBabelArray ==================== * #

abstract type AbstractBabelArray{S, T <: Real, P} <: StaticArraysCore.StaticArray{S, T, P} end

const BabelScalar{T <: Real} = AbstractBabelArray{Tuple{}, T, 0}
const BabelVector{N, T <: Real} = AbstractBabelArray{Tuple{N}, T, 1}
const BabelMatrix{M, N, T <: Real} = AbstractBabelArray{Tuple{M, N}, T, 2}
const BabelSquareMatrix{N, T <: Real} = AbstractBabelArray{Tuple{N, N}, T, 2}
const BabelVecOrMat{T} = Union{BabelVector{<:Any, T}, BabelMatrix{<:Any, <:Any, T}}

@inline function Base.Tuple(a::AbstractBabelArray{S, T, P})::NTuple{tuple_prod(S), T} where {S <: Tuple, T <: Real, P}
    L = tuple_prod(S)
    return ntuple(i -> getindex(a, i), L)
end

@inline function Base.strides(a::AbstractBabelArray{S, T, P}) where {S <: Tuple, T <: Real, P}
    return Base.size_to_strides(1, size(a)...)
end

@inline function StaticArrays.similar_type(::Type{SA}, ::Type{T}, s::Size{S}) where {SA <: AbstractBabelArray, T, S}
    return StaticArrays.mutable_similar_type(T, s, StaticArrays.length_val(s))
end

# * ==================== BArray ==================== * #

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

@inline function _row(a::BArray{S, T, P})::Int where {S <: Tuple, T <: Real, P}
    return getfield(a, :row_)
end

@inline function _col(a::BArray{S, T, P})::Int where {S <: Tuple, T <: Real, P}
    return getfield(a, :col_)
end

@inline function _data(a::BArray{S, T, P}) where {S <: Tuple, T <: Real, P}
    return getfield(a, :data_).x
end

@inline function Base.getindex(a::BArray{S, T, P}, i::Int) where {S <: Tuple, T <: Real, P}
    # ! key function for StaticArrays: a[i]
    return @inbounds _data(a)[_row(a), _col(a) - 1 + i]
end

@inline function Base.setindex!(a::BArray{S, T, P}, v::Real, i::Int) where {S <: Tuple, T <: Real, P}
    # ! key function for StaticArrays: a[i] = v
    @inbounds _data(a)[_row(a), _col(a) - 1 + i] = unsafe_real(T, v)
end

# * ==================== Constructors ==================== * #

@inline function BArray{S, T, P}(
    row::Integer,
    col::Integer,
    data::AbstractArray{T, 2},
)::BArray{S, T, P} where {S <: Tuple, T <: Real, P}
    return BArray{S, T, P}(Int(row), Int(col), Ref{typeof(data)}(data))
end

@inline function BArray{S}(
    row::Integer,
    col::Integer,
    data::AbstractArray{T, 2},
)::BArray{S, eltype(data), length(S.parameters)} where {S <: Tuple, T <: Real}
    return BArray{S, eltype(data), length(S.parameters)}(Int(row), Int(col), Ref{typeof(data)}(data))
end

@inline function BArray{S, T}(
    row::Integer,
    col::Integer,
    data::AbstractArray{T, 2},
)::BArray{S, T, length(S.parameters)} where {S <: Tuple, T <: Real}
    return BArray{S, T, length(S.parameters)}(Int(row), Int(col), Ref{typeof(data)}(data))
end

@inline function BArray{S, T, P}()::StaticArraysCore.MArray{S, T, P, tuple_prod(S)} where {S <: Tuple, T <: Real, P}
    return StaticArrays.MArray{S, T, P, tuple_prod(S)}(ntuple(i -> zero(T), tuple_prod(S)))
end

@inline function BArray{S, T, P}(
    x::NTuple{L, T},
)::StaticArraysCore.MArray{S, T, P, tuple_prod(S)} where {S <: Tuple, T <: Real, P, L}
    return StaticArrays.MArray{S, T, P, tuple_prod(S)}(ntuple(i -> x[i], tuple_prod(S)))
end

@inline function BArray{S, T, P}(
    ::UndefInitializer,
)::StaticArraysCore.MArray{S, T, P, tuple_prod(S)} where {S <: Tuple, T <: Real, P}
    return StaticArrays.MArray{S, T, P, tuple_prod(S)}(ntuple(i -> zero(T), tuple_prod(S)))
end

@inline function BArray{S, T, P}(
    x::Base.Tuple,
)::StaticArraysCore.MArray{S, T, P, tuple_prod(S)} where {S <: Tuple, T <: Real, P}
    return StaticArrays.MArray{S, T, P, tuple_prod(S)}(x)
end

# * ========== include ==========* #

include("Constructors.jl")

end # module BabelArrays
