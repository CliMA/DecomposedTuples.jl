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
