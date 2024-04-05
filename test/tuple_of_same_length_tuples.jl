#=
using Revise; include(joinpath("test", "tuple_of_same_length_tuples.jl"))
=#
import TuplesOfNTuples as ToNT

function main!(tups)
    for i in 1:3
        dtup = ToNT.TupleOfSameLengthTuples(tups)
    end
    return nothing
end
struct FooA1 end
struct FooA2 end
struct FooA3 end
struct FooA4 end
struct FooB1 end
struct FooB2 end
struct FooB3 end
struct FooB4 end
struct FooC1 end
struct FooC2 end
struct FooC3 end
struct FooC4 end

tup1 = (FooA1(), FooA2(), FooA3(), FooA4())
tup2 = (FooB1(), FooB2(), FooB3(), FooB4())
tup3 = (FooC1(), FooC2(), FooC3(), FooC4())
tups = (tup1, tup2, tup3)
main!(tups)
p_allocated = @allocated main!(tups)
using Test
@test p_allocated == 0

stups = ToNT.TupleOfSameLengthTuples(tups)
@test stups.tups[1][1] === tups[1][1]
@test stups.tups[1][2] === tups[1][2]
@test stups.tups[1][3] === tups[1][3]
@test stups.tups[1][4] === tups[1][4]

@test stups.tups[2][1] === tups[2][1]
@test stups.tups[2][2] === tups[2][2]
@test stups.tups[2][3] === tups[2][3]
@test stups.tups[2][4] === tups[2][4]

@test stups.tups[3][1] === tups[3][1]
@test stups.tups[3][2] === tups[3][2]
@test stups.tups[3][3] === tups[3][3]
@test stups.tups[3][4] === tups[3][4]


# dtup = ToNT.TupleOfNTuples((Foo1(),))
# @test dtup.sparse_ntuples[1][1] === tup[1]
