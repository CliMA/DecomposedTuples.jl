struct TupleOfSameLengthTuples{N, T}
    tups::T
end

Base.length(::TupleOfSameLengthTuples{N}) where {N} = N

function TupleOfSameLengthTuples(tups::Tuple)
    tup1 = first(tups)
    @assert all(x -> length(x) == length(tup1), tups)
    return TupleOfSameLengthTuples{length(tup1), typeof(tups)}(tups)
end
