struct SparseContainer{SIM, T}
    data::T
end

Base.parent(sc::SparseContainer) = sc.data

function SparseContainer(compressed_data::T, sparse_indices::Tuple) where {T}
    if !all(x -> eltype(compressed_data) .== typeof(x), compressed_data)
        error("non-uniform eltype")
    end
    sparse_index_map = zeros(Int, maximum(sparse_indices))
    for i in 1:length(sparse_index_map)
        i in sparse_indices || continue
        sparse_index_map[i] = findfirst(k -> k == i, sparse_indices)
    end
    sparse_index_map = Tuple(sparse_index_map)
    return SparseContainer{sparse_index_map, T}(compressed_data)
end
@inline Base.getindex(st::SparseContainer{SIM}, i::Int) where {SIM} =
    Base.getindex(st.data, SIM[i])

function hasindex(sc::SparseContainer{SIM}, i::Int) where {SIM}
    if 1 ≤ i ≤ length(SIM)
        return SIM[i] ≠ 0
    else
        return false
    end
end
