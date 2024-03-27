# TuplesOfNTuples.jl

A Julia package for converting non-uniform `Tuple`s into a `Tuple` of `NTuple`s.

This package allows users to effectively index into a non-homogeneous tuple with dynamic indexes in a type-stable (and gpu-friendly) way, assuming that the given tuple can be transformed a-priori into a `TupleOfNTuples`. Here is an example:

```julia
import TuplesOfNTuples as ToNT

function example!(tonts, f, N::Int, counter)
    for i in 1:N # cannot be unrolled
        # f(i, tup, args...) where tup is in args.
        args = (counter,)

        # Inlined, and fully unrolled
        ToNT.dispatch(f, tonts, i, args...) # effectively calls f(tup[i], args...)

        # This unrolls to:
        #
        #      if hasindex(tup.sparse_ntuples[1], i)
        #          fun(tup.sparse_ntuples[1][i], args...)
        #      elseif hasindex(tup.sparse_ntuples[2], i)
        #          fun(tup.sparse_ntuples[2][i], args...)
        #      elseif ...
        #      end
        #
        #  where tup.sparse_ntuples[j][i] is equivalent to tup[i]
        #
        # Two important points about this design are:
        #  - tup.sparse_ntuples[1] is inferred, because 1 is not a dynamic index
        #  - tup.sparse_ntuples[1][i] is inferred, because tup.sparse_ntuples[1] an NTuple
    end
    return nothing
end

struct Foo1 end
struct Foo2 end
struct Foo3 end
struct Foo4 end

function f!(::Foo1, counter)
    counter[1]+=1
    return nothing
end
function f!(::Foo2, counter)
    counter[1]+=100
    return nothing
end
function f!(::Foo3, counter)
    counter[1]+=1000
    return nothing
end
function f!(::Foo4, counter)
    counter[1]+=10000
    return nothing
end

tup = (Foo1(), Foo2(), Foo3(), Foo4())
tonts = ToNT.TupleOfNTuples(tup)

counter = Int[0]
example!(tonts, f!, length(tup), counter)
using Test
@test counter[1] == sum((1,100,1000,10000))

@inferred ToNT.dispatch(f!, tonts, 1, counter)
```
