
@inline to_tuple_of_ntuples_pairs(tup::Tuple) =
    _to_tuple_of_ntuples_pairs(((),), tup, 1)

@inline _to_tuple_of_ntuples_pairs(tont::Tuple{Tuple{}}, tup::Tuple{}, j::Int) =
    tont
@inline _to_tuple_of_ntuples_pairs(
    tont::Tuple{Tuple{}},
    tup::Tuple{<:Any},
    j::Int,
) = ((1, tup[1]),)
@inline _to_tuple_of_ntuples_pairs(
    tont::Tuple{Tuple{}},
    tup::Tuple{<:Any, <:Any},
    j::Int,
) = (((1, tup[1]),), ((2, tup[2]),))

@inline _to_tuple_of_ntuples_pairs(tont::Tuple{Tuple{}}, tup::Tuple, j::Int) =
    _to_tuple_of_ntuples_pairs((((1, Base.first(tup)),),), Base.tail(tup), 2)

@inline function appendat(t::Tuple, i::Int, elem, j::Int)
    if i == 1
        ((t[1]..., (j, elem)), Base.tail(t)...)
    else
        (t[1], appendat(Base.tail(t), i - 1, elem, j)...)
    end
end

@inline _to_tuple_of_ntuples_pairs(tont::Tuple, tup::Tuple{}, j::Int) = tont

@inline function _to_tuple_of_ntuples_pairs(tont::Tuple, tup::Tuple, j::Int)
    elem = first(tup)
    i = findfirst(x -> eltype(x) == Tuple{Int, typeof(elem)}, tont)
    if isnothing(i)
        return _to_tuple_of_ntuples_pairs(
            (tont..., ((j, elem),)),
            Base.tail(tup),
            j + 1,
        )
    else
        return _to_tuple_of_ntuples_pairs(
            appendat(tont, i, elem, j),
            Base.tail(tup),
            j + 1,
        )
    end
end
