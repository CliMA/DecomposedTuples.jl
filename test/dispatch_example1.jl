#=
using Revise; include(joinpath("test", "dispatch_example1.jl"))
=#
import TuplesOfNTuples as DT

function example!(tonts, f, N::Int, counter)
    for i in 1:N
        DT.dispatch(f, tonts, i, counter)
    end
    return nothing
end

struct Foo1 end
struct Foo2 end
struct Foo3 end
struct Foo4 end

function f!(::Foo1, counter)
    counter[1] += 1
    return nothing
end
function f!(::Foo2, counter)
    counter[1] += 100
    return nothing
end
function f!(::Foo3, counter)
    counter[1] += 1000
    return nothing
end
function f!(::Foo4, counter)
    counter[1] += 10000
    return nothing
end

tup = (Foo1(), Foo2(), Foo3(), Foo4(), Foo3(), Foo3())
dtup = DT.TupleOfNTuples(tup)

counter = Int[0]
example!(dtup, f!, length(tup), counter)
using Test
@test counter[1] == sum((1, 100, 1000 * 3, 10000))

@inferred DT.dispatch(f!, dtup, 1, counter)
