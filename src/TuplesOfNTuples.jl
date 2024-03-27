module TuplesOfNTuples

import OrderedCollections

struct SparseContainer{SIM, T}
    data::T
    function SparseContainer(
        compressed_data::T,
        sparse_indices::Tuple,
    ) where {T}
        if !all(
            map(x -> eltype(compressed_data) .== typeof(x), compressed_data),
        )
            error("non-uniform eltype")
        end
        sparse_index_map = zeros(Int, maximum(sparse_indices))
        for i in 1:length(sparse_index_map)
            i in sparse_indices || continue
            sparse_index_map[i] = findfirst(k -> k == i, sparse_indices)
        end
        sparse_index_map = Tuple(sparse_index_map)
        return new{sparse_index_map, T}(compressed_data)
    end
end
Base.parent(sc::SparseContainer) = sc.data
@inline Base.getindex(st::SparseContainer{SIM}, i::Int) where {SIM} =
    Base.getindex(st.data, SIM[i])

# TODO: can we avoid allocations / do this in a recursive way?
function decompose_to_dict_values(tup::Tuple)
    dict = OrderedCollections.OrderedDict()
    for (i, t) in enumerate(tup)
        k = typeof(t)
        index_entry = (i, t)::Tuple{Int, k}
        if haskey(dict, k)
            dict[k] = (dict[k]..., index_entry)
        else
            dict[k] = (index_entry,)
        end
    end
    return Tuple(values(dict))
end

function extract_entries_and_indices(dict_vals)
    return map(dict_vals) do vals
        indices = map(x -> first(x), vals)
        entries = map(x -> last(x), vals)
        SparseContainer(entries, indices)
    end
end

"""
    TupleOfNTuples

Decompose a `Tuple` into a collection of `NTuples`,
which can be indexed in a similar way to the original
tuple:

```julia
import TuplesOfNTuples as DT
tup = (Foo1(), Foo2(), Foo3(), Foo4(), Foo3(), Foo3())
dtup = DT.TupleOfNTuples(tup)
@test dtup.sparse_ntuples[1][1] === tup[1]
@test dtup.sparse_ntuples[2][2] === tup[2]
@test dtup.sparse_ntuples[3][3] === tup[3]
@test dtup.sparse_ntuples[4][4] === tup[4]
@test dtup.sparse_ntuples[3][5] === tup[5]
@test dtup.sparse_ntuples[3][6] === tup[6]
```
"""
struct TupleOfNTuples{SC}
    sparse_ntuples::SC
    # TODO: specialize on NTuple input
    function TupleOfNTuples(tup::Tuple)
        dict_vals = decompose_to_dict_values(tup)
        sparse_ntuples = extract_entries_and_indices(dict_vals)
        SC = typeof(sparse_ntuples)
        return new{SC}(sparse_ntuples)
    end
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
