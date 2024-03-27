#=
using Revise; include(joinpath("test", "dispatch_basic.jl"))
=#
import TuplesOfNTuples as DT

function example!(dtup, f, N::Int, counter)
    for i in 1:N # cannot be unrolled
        # f(i, tup, args...) where tup is in args.
        args = (counter,)

        # Inlined, and fully unrolled

        DT.dispatch(f, dtup, i, args...) # effectively calls f(tup[i], args...)

        # This unrolls to:
        #
        #      if hasindex(tup.sparse_ntuples[1], i)
        #          fun(tup.sparse_ntuples[1][i], args...)
        #      elseif hasindex(tup.sparse_ntuples[2], i)
        #          fun(tup.sparse_ntuples[2][i], args...)
        #      elseif ...
        #      end
        #
        #  where tup.sparse_ntuples[j][i] is equivalent to tup[i]
        #
        # Two important points about this design are:
        #  - tup.sparse_ntuples[1] is inferred, because 1 is not a dynamic index
        #  - tup.sparse_ntuples[1][i] is inferred, because tup.sparse_ntuples[1] an NTuple
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
dtup = DT.TupleOfNTuples(tup)

counter = Int[0]
example!(dtup, f!, length(tup), counter)

import InteractiveUtils
# InteractiveUtils.@code_warntype example!(dtup, f!, length(tup), counter)
using Test
@test counter[1] == sum((1, 100, 1000, 10000))

@inferred DT.dispatch(f!, dtup, 1, counter)


nothing
