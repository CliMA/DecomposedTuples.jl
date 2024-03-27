#=
using Revise; include(joinpath("test", "dispatch_multiple_tonts.jl"))
=#
import TuplesOfNTuples as ToNT


function inner_dispatch(dtB, g!::G!, ctr, dtA, j) where {G!}
    ToNT.dispatch(g!, dtA, j, dtB, ctr)
end

function example!(dtupA, dtupB, f!, N::Int, counter)
    for i in 1:N
        ToNT.dispatch(inner_dispatch, dtupB, i, f!, counter, dtupA, i)

        # Or, via anonymous function:
        # ToNT.dispatch(dtupB, i, f!, counter, dtupA, i) do dtB, g!, ctr, dtA, j
        #     ToNT.dispatch(g!, dtA, j, dtB, ctr)
        # end

        # ToNT.dispatch(f, dtup, i, args...)
        # This unrolls to:
        #      if hasindex(tup.sparse_ntuples[1], i)
        #          inner_dispatch(dtupA.sparse_ntuples[1][i], args...)
        #      elseif hasindex(tup.sparse_ntuples[2], i)
        #          inner_dispatch(dtupA.sparse_ntuples[2][i], args...)
        #      elseif ...
        #      end

        # This unrolls to:
        #
        #      tA_i = ToNT.outer_index(dtupA, i)
        #      tB_i = ToNT.outer_index(dtupB, i)
        #      f(tA[tA_i], tB[tB_i], args...)

        # This unrolls to:
        #
        #      if hasindex(tupA.sparse_ntuples[1], i)
        #          tA = tupA.sparse_ntuples[1]
        #          if hasindex(tupB.sparse_ntuples[1], i)
        #              tB = tupB.sparse_ntuples[1]
        #              f(tA[i], tB[i], args...)
        #          elseif hasindex(tup.sparse_ntuples[2], i)
        #              tB = tupB.sparse_ntuples[2]
        #              f(tA[i], tB[i], args...)
        #          elseif ...
        #          end
        #      elseif hasindex(tupA.sparse_ntuples[2], i)
        #          tA = tupA.sparse_ntuples[2]
        #          if hasindex(tupB.sparse_ntuples[1], i)
        #              tB = tupB.sparse_ntuples[1]
        #              f(tA[i], tB[i], args...)
        #          elseif hasindex(tup.sparse_ntuples[2], i)
        #              tB = tupB.sparse_ntuples[2]
        #              f(tA[i], tB[i], args...)
        #          elseif ...
        #          end
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

struct Bar1 end
struct Bar2 end
struct Bar3 end
struct Bar4 end

function f!(::Foo1, ::Bar1, counter)
    counter[1] += 1
    return nothing
end
function f!(::Foo2, ::Bar2, counter)
    counter[1] += 100
    return nothing
end
function f!(::Foo3, ::Bar3, counter)
    counter[1] += 1000
    return nothing
end
function f!(::Foo4, ::Bar4, counter)
    counter[1] += 10000
    return nothing
end

tupA = (Foo1(), Foo2(), Foo3(), Foo4(), Foo3(), Foo3())
tupB = (Bar1(), Bar2(), Bar3(), Bar4(), Bar3(), Bar3())
dtupA = ToNT.TupleOfNTuples(tupA)
dtupB = ToNT.TupleOfNTuples(tupB)

counter = Int[0]
example!(dtupA, dtupB, f!, length(tupA), counter)
using Test
@test counter[1] == sum((1, 100, 1000 * 3, 10000))
