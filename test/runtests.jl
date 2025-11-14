#=
  @ author: ChenyuBao <chenyu.bao@outlook.com>
  @ date: 2025-11-14 14:04:27
  @ license: MIT
  @ language: Julia
  @ declaration: Mutable arrays running in kernel on any devices.
  @ description:
 =#

using Test
using StaticArrays
using BabelArrays

@testset "unsafe_real" begin
    type_vec = [Int32, Int64, Float32, Float64]
    for T1 in type_vec, T2 in type_vec
        for x in [-2.5, 0, 3.7]
            @test unsafe_real(T1, unsafe_real(T2, x)) isa T1
        end
    end
end

@testset "types" begin
    @test BabelScalar{Float64} === AbstractBabelArray{Tuple{}, Float64, 0}
    @test BabelVector{3, Int32} === AbstractBabelArray{Tuple{3}, Int32, 1}
    @test BabelMatrix{2, 4, Float32} === AbstractBabelArray{Tuple{2, 4}, Float32, 2}
    @test BabelSquareMatrix{5, Int64} === AbstractBabelArray{Tuple{5, 5}, Int64, 2}

    _T = Float32
    data = randn(_T, 3, 8)
    @test BScalar(1, 1, data) isa BArray{Tuple{}, _T, 0}
    @test BVector{3}(1, 1, data) isa BArray{Tuple{3}, _T, 1}
    @test BMatrix{2, 4}(1, 1, data) isa BArray{Tuple{2, 4}, _T, 2}
    @test BSquareMatrix{2}(1, 1, data) isa BArray{Tuple{2, 2}, _T, 2}
end

@testset "types" begin
    _T = Float32
    data = randn(_T, 3, 8)
    bscalar = BScalar(1, 1, data)
    bvector = BVector{3}(1, 1, data)
    bmatrix = BMatrix{2, 4}(1, 1, data)
    bsquarematrix = BSquareMatrix{2}(1, 1, data)

    @test size(bscalar) == ()
    @test size(bvector) == (3,)
    @test size(bmatrix) == (2, 4)
    @test size(bsquarematrix) == (2, 2)
end
