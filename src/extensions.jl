import Adapt

function Adapt.adapt_structure(to, tonts::TupleOfNTuples{N}) where {N}
    sparse_ntuples = Adapt.adapt(to, tonts.sparse_ntuples)
    return TupleOfNTuples{N, typeof(sparse_ntuples)}(sparse_ntuples)
end

function Adapt.adapt_structure(to, sc::SparseContainer{SIM}) where {SIM}
    data = Adapt.adapt(to, sc.data)
    SparseContainer{SIM, typeof(data)}(data)
end
