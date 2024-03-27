#=
using Revise; include(joinpath("test", "tuple_of_ntuples.jl"))
=#
import TuplesOfNTuples as DT

function main!(tup)
    for i in 1:3
        dtup = DT.TupleOfNTuples(tup)
    end
    return nothing
end
struct Foo1 end
struct Foo2 end
struct Foo3 end
struct Foo4 end

tup = (Foo1(), Foo2(), Foo3(), Foo4())
main!(tup)
p_allocated = @allocated main!(tup)
using Test
@test_broken p_allocated == 0

tup = (Foo1(), Foo2(), Foo3(), Foo4(), Foo3(), Foo3())
dtup = DT.TupleOfNTuples(tup)
@test dtup.sparse_ntuples[1][1] === tup[1]
@test dtup.sparse_ntuples[2][2] === tup[2]
@test dtup.sparse_ntuples[3][3] === tup[3]
@test dtup.sparse_ntuples[4][4] === tup[4]
@test dtup.sparse_ntuples[3][5] === tup[5]
@test dtup.sparse_ntuples[3][6] === tup[6]
