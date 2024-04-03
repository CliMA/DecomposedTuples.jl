module AdaptExt

import TuplesOfNTuples as ToNT
isdefined(Base, :get_extension) ? (using Adapt) : (using ..Adapt)
import Adapt

function Adapt.adapt_structure(to, tonts::ToNT.TupleOfNTuples{N}) where {N}
    sparse_ntuples = Adapt.adapt(to, tonts.sparse_ntuples)
    return ToNT.TupleOfNTuples{N, typeof(sparse_ntuples)}(sparse_ntuples)
end

function Adapt.adapt_structure(to, sc::ToNT.SparseContainer{SIM}) where {SIM}
    data = Adapt.adapt(to, sc.data)
    ToNT.SparseContainer{SIM, typeof(data)}(data)
end

end # module
