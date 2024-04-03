"""
    TupleOfNTuples

Decompose a `Tuple` into a `Tuple` of `NTuples`,
which can be indexed in a similar way to the original
tuple:

```julia
import TuplesOfNTuples as ToNT
tup = (Foo1(), Foo2(), Foo3(), Foo4(), Foo3(), Foo3())
dtup = ToNT.TupleOfNTuples(tup)
@test dtup.sparse_ntuples[1][1] === tup[1]
@test dtup.sparse_ntuples[2][2] === tup[2]
@test dtup.sparse_ntuples[3][3] === tup[3]
@test dtup.sparse_ntuples[4][4] === tup[4]
@test dtup.sparse_ntuples[3][5] === tup[5]
@test dtup.sparse_ntuples[3][6] === tup[6]
```
"""
struct TupleOfNTuples{N, SC}
    sparse_ntuples::SC
end
Base.length(::TupleOfNTuples{N}) where {N} = N
function TupleOfNTuples(tup::Tuple)
    tup_ntup_pairs = to_tuple_of_ntuples_pairs(tup)
    indices = map(vals -> map(x -> first(x), vals), tup_ntup_pairs)
    entries = map(vals -> map(x -> last(x), vals), tup_ntup_pairs)
    sparse_ntuples = ntuple(length(tup_ntup_pairs)) do i
        SparseContainer(entries[i], indices[i])
    end
    SC = typeof(sparse_ntuples)
    return TupleOfNTuples{length(tup), SC}(sparse_ntuples)
end
