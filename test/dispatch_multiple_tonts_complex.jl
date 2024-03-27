#=
using Revise; include(joinpath("test", "dispatch_multiple_tonts_complex.jl"))
=#
import TuplesOfNTuples as DT


function inner_dispatch(dtB, g!::G!, ctr, dtA, j) where {G!}
    DT.dispatch(g!, dtA, j, dtB, ctr)
end

function example!(dtupA, dtupB, f!, N::Int, counter)
    for i in 1:N
        DT.dispatch(inner_dispatch, dtupB, i, f!, counter, dtupA, i)
    end
    return nothing
end

struct Foo1 end
struct Foo2 end
struct Foo3 end
struct Foo4 end

struct Bar1 end
struct Bar2 end
struct Bar3 end
struct Bar4 end

function f!(::Foo1, ::Bar1, counter)
    counter[1] += 1
    return nothing
end
function f!(::Foo2, ::Bar1, counter)
    counter[1] += 100
    return nothing
end
function f!(::Foo3, ::Bar4, counter)
    counter[1] += 1000
    return nothing
end
function f!(::Foo4, ::Bar2, counter)
    counter[1] += 10000
    return nothing
end
function f!(::Foo3, ::Bar3, counter)
    counter[1] += 100000
    return nothing
end

tupA = (Foo1(), Foo2(), Foo3(), Foo4(), Foo3(), Foo3()) # 1, 100, 1000, 10000, 1000, 100000
tupB = (Bar1(), Bar1(), Bar4(), Bar2(), Bar4(), Bar3()) # 1, 100, 1000, 10000, 1000, 100000
dtupA = DT.TupleOfNTuples(tupA)
dtupB = DT.TupleOfNTuples(tupB)

counter = Int[0]
example!(dtupA, dtupB, f!, length(tupA), counter)
using Test
@test counter[1] == sum((1, 100, 1000, 10000, 1000, 100000))
