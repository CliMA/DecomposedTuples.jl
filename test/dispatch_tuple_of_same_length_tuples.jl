#=
using Revise; include(joinpath("test", "dispatch_tuple_of_same_length_tuples.jl"))
=#
import TuplesOfNTuples as ToNT

@inline function recurse(js::Tuple, tups::Tuple, counter, i::Int)
    if first(js) == i
        tups1 = map(x -> first(x), tups)
        tup_args = map(x -> x.obj, tups1)
        counter = f!(tup_args..., counter)
    end
    recurse(Base.tail(js), map(x -> Base.tail(x), tups), counter, i)
end

@inline recurse(js::Tuple{}, tups::Tuple, counter, i::Int) = counter

@inline function recurse(js::Tuple{Int}, tups::Tuple, counter, i::Int)
    if first(js) == i
        tups1 = map(x -> first(x), tups)
        tup_args = map(x -> x.obj, tups1)
        counter = f!(tup_args..., counter)
    end
    return counter
end

function example!(
    toslts::ToNT.TupleOfSameLengthTuples,
    f!,
    N::Int,
    counter::Int,
)
    for i in 1:N
        L = length(toslts)
        nt = ntuple(ξ -> ξ, L)
        counter = recurse(nt, toslts.tups, counter, i)
    end
    return counter
end

struct Foo1 end
struct Foo2 end
struct Foo3 end
struct Foo4 end

struct Bar1 end
struct Bar2 end
struct Bar3 end
struct Bar4 end

struct Baz1 end
struct Baz2 end
struct Baz3 end
struct Baz4 end

struct Bin1 end
struct Bin2 end
struct Bin3 end
struct Bin4 end

f!(::Foo1, ::Bar1, ::Baz1, ::Bin1, counter::Int) = counter + 1
f!(::Foo2, ::Bar2, ::Baz2, ::Bin2, counter::Int) = counter + 10
f!(::Foo3, ::Bar3, ::Baz3, ::Bin4, counter::Int) = counter + 100
f!(::Foo4, ::Bar4, ::Baz4, ::Bin4, counter::Int) = counter + 1000
f!(::Foo3, ::Bar3, ::Baz3, ::Bin3, counter::Int) = counter + 10000

tupA = (Foo1(), Foo2(), Foo3(), Foo4(), Foo3(), Foo3())
tupB = (Bar1(), Bar2(), Bar3(), Bar4(), Bar3(), Bar3())
tupC = (Baz1(), Baz2(), Baz3(), Baz4(), Baz3(), Baz3())
tupD = (Bin1(), Bin2(), Bin4(), Bin4(), Bin3(), Bin3())
tupA = map(x -> (; obj = x), tupA)
tupB = map(x -> (; obj = x), tupB)
tupC = map(x -> (; obj = x), tupC)
tupD = map(x -> (; obj = x), tupD)

toslts = ToNT.TupleOfSameLengthTuples((tupA, tupB, tupC, tupD))

counter = 0
counter = example!(toslts, f!, length(tupA), counter)
using Test
@test counter == sum((1, 10, 100, 1000, 2 * 10_000))

#=
i = 1
fA = ToNT.inner_dispatch(f!, As, i, x->x.objA)
fB = ToNT.outer_dispatch(fA, Bs, i, x->x.objB)
fC = ToNT.outer_dispatch(fB, Cs, i, x->x.objC)
fD = ToNT.outer_dispatch(fC, Ds, i, x->x.objD)

fD(counter)
@code_typed fD(counter)

using JET
using BenchmarkTools
@benchmark example!(toslts, f!, length(tupA), counter)
using Cthulhu
example!(toslts, f!, length(tupA), counter)
@test_opt example!(toslts, f!, length(tupA), counter)
@descend example!(toslts, f!, length(tupA), counter)
@code_warntype example!(toslts, f!, length(tupA), counter)
=#
