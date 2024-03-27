#=
using Revise; include(joinpath("test", "dispatch_example1.jl"))
=#
import TuplesOfNTuples as ToNT

function example!(tonts, f, N::Int, counter)
    for i in 1:N
        ToNT.dispatch(f, tonts, i, counter)
    end
    return nothing
end

struct Foo1 end

function f!(::Foo1, counter)
    counter[1] += 1
    return nothing
end

tup = (Foo1(), Foo1(), Foo1(), Foo1(), Foo1())
dtup = ToNT.TupleOfNTuples(tup)

counter = Int[0]
example!(dtup, f!, length(tup), counter)
using Test
@test counter[1] == 5

@inferred ToNT.dispatch(f!, dtup, 1, counter)
