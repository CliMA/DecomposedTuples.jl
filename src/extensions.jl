import Adapt

function Adapt.adapt_structure(to, tonts::TupleOfNTuples{N}) where {N}
    sparse_ntuples = Adapt.adapt(to, tonts.sparse_ntuples)
    return TupleOfNTuples{N, typeof(sparse_ntuples)}(sparse_ntuples)
end

function Adapt.adapt_structure(to, sc::SparseContainer{SIM}) where {SIM}
    data = Adapt.adapt(to, sc.data)
    SparseContainer{SIM, typeof(data)}(data)
end

function Adapt.adapt_structure(to, tonts::TupleOfSameLengthTuples{N}) where {N}
    sparse_tuples = Adapt.adapt(to, tonts.sparse_tuples)
    return TupleOfSameLengthTuples{N, typeof(sparse_tuples)}(sparse_tuples)
end
