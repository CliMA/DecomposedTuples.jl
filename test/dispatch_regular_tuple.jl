#=
using Revise; include(joinpath("test", "dispatch_regular_tuple.jl"))
=#

#####
##### Test codewarntype for regular tuples
#####
function example_regular_tuple!(tup, f, N::Int, counter)
    for i in 1:N # cannot be unrolled
        f(tup[i], counter)
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

tup = (Foo1(), Foo2(), Foo3(), Foo4())
counter = Int[0]
example_regular_tuple!(tup, f!, length(tup), counter)
using Test
@test counter[1] == sum((1, 100, 1000, 10000))
import InteractiveUtils
# has Base.getindex(tup, i)::Any
# InteractiveUtils.@code_warntype example_regular_tuple!(tup, f!, length(tup), counter)

buf = IOBuffer()
InteractiveUtils.code_warntype(
    buf,
    example_regular_tuple!,
    (typeof(tup), typeof(example_regular_tuple!), Int64, Vector{Int64}),
)
s = String(take!(buf));
@test occursin("Base.getindex(tup, i)::ANY", s)

nothing
