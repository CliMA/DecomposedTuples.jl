#=
using Revise; include(joinpath("test", "extensions.jl"))
=#

import Adapt
import TuplesOfNTuples as ToNT
using Test

tonts = ToNT.TupleOfNTuples((1, 2, 3))
@test hasmethod(Adapt.adapt_structure, typeof((nothing, tonts)))
