#=
using Revise; include(joinpath("test", "dispatch_example1.jl"))
=#
import DecomposedTuples as DT

function example!(decomposed_tup, f, N::Int, counter)
    for i in 1:N
        DT.dispatch(f, decomposed_tup, i, counter)
    end
    return nothing
end

struct Foo1 end

function f!(::Foo1, counter)
    counter[1] += 1
    return nothing
end

tup = (Foo1(), Foo1(), Foo1(), Foo1(), Foo1())
dtup = DT.DecomposedTuple(tup)

counter = Int[0]
example!(dtup, f!, length(tup), counter)
using Test
@test counter[1] == 5

@inferred DT.dispatch(f!, dtup, 1, counter)
