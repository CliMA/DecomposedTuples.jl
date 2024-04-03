#=
using Revise; include(joinpath("test", "runtests.jl"))
=#
using Test
using SafeTestsets

#! format: off
@safetestset "sparse_containers" begin; @time include("sparse_containers.jl"); end
@safetestset "tuple_of_ntuples" begin; @time include("tuple_of_ntuples.jl"); end
@safetestset "dispatch_basic" begin; @time include("dispatch_basic.jl"); end
@safetestset "dispatch_regular_tuple" begin; @time include("dispatch_regular_tuple.jl"); end
@safetestset "dispatch_example1" begin; @time include("dispatch_example1.jl"); end
@safetestset "dispatch_example2" begin; @time include("dispatch_example2.jl"); end
@safetestset "dispatch_multiple_tonts" begin; @time include("dispatch_multiple_tonts.jl"); end
@safetestset "dispatch_multiple_tonts_complex" begin; @time include("dispatch_multiple_tonts_complex.jl"); end
@safetestset "extensions" begin; @time include("extensions.jl"); end
#! format: on
