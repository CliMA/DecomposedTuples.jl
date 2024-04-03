module TuplesOfNTuples

include("sparse_container.jl")
include("to_tuple_of_ntuples.jl")

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

function hasindex(sc::SparseContainer{SIM}, i::Int) where {SIM}
    if 1 ≤ i ≤ length(SIM)
        return SIM[i] ≠ 0
    else
        return false
    end
end

"""
    dispatch(f::F, sparse_ntuples::Tuple, i, args...)

Perform an unrolled loop over `j ∈ 1:length(sparse_ntuples)` and call
    `f(sparse_ntuples[j][i], args...)` if `hasindex(sparse_ntuples[j], i)`
"""
function dispatch end

@inline function dispatch(f::F, sparse_ntuples::Tuple, i, args...) where {F}
    if hasindex(first(sparse_ntuples), i)
        f(first(sparse_ntuples)[i], args...)
    else
        dispatch(f, Base.tail(sparse_ntuples), i, args...)
    end
end

@inline function dispatch(
    f::F,
    sparse_ntuples::Tuple{<:Any},
    i,
    args...,
) where {F}
    if hasindex(first(sparse_ntuples), i)
        f(first(sparse_ntuples)[i], args...)
    end
end

@inline function dispatch(f::F, sparse_ntuples::Tuple{}, i, args...) where {F} end

@inline dispatch(f::F, tonts::TupleOfNTuples, i, args...) where {F} =
    dispatch(f, tonts.sparse_ntuples, i, args...)

end # module
