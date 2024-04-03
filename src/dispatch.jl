function _dispatch end

@inline function _dispatch(
    f::F,
    transform,
    osn,
    sparse_ntuples::Tuple,
    i,
    args::Tuple,
) where {F}
    if hasindex(first(sparse_ntuples), i)
        f(transform(first(sparse_ntuples)[i]), args...)
    else
        _dispatch(f, transform, osn, Base.tail(sparse_ntuples), i, args)
    end
end

@inline function _dispatch(
    f::F,
    transform,
    osn,
    sparse_ntuples::Tuple{<:Any},
    i,
    args::Tuple,
) where {F}
    if hasindex(first(sparse_ntuples), i)
        f(transform(first(sparse_ntuples)[i]), args...)
    end
end

@inline function _dispatch(
    f::F,
    transform,
    osn,
    sparse_ntuples::Tuple{},
    i,
    args,
) where {F} end

@inline _dispatch(
    f::F,
    transform,
    osn,
    tonts::TupleOfNTuples,
    i,
    args,
) where {F} =
    _dispatch(f, transform, tonts.sparse_ntuples, tonts.sparse_ntuples, i, args)

struct InnerClosure{F, T, A}
    f::F
    transform::T
    args::A
end
@inline (ic::InnerClosure)(args...) =
    _dispatch(ic.f, ic.transform, ic.args..., args)

@inline inner_dispatch(
    f::F,
    tonts::TupleOfNTuples,
    i,
    transform = identity,
) where {F} =
    InnerClosure(f, transform, (tonts.sparse_ntuples, tonts.sparse_ntuples, i))


struct OuterClosure{F, T, A}
    f::F
    transform::T
    args::A
end
@inline (ic::OuterClosure)(x::X, y::Y, z::Z) where {X, Y, Z} =
    _dispatch(ic.f, ic.transform, ic.args..., (x, y, z))
@inline (ic::OuterClosure)(x::X, y::Y) where {X, Y} =
    _dispatch(ic.f, ic.transform, ic.args..., (x, y))
@inline (ic::OuterClosure)(x::X) where {X} =
    _dispatch(ic.f, ic.transform, ic.args..., (x,))

@inline outer_dispatch(
    f::F,
    tonts::TupleOfNTuples,
    i,
    transform = identity,
) where {F} =
    OuterClosure(f, transform, (tonts.sparse_ntuples, tonts.sparse_ntuples, i))
