module SimplySparse

using Random
using SparseArrays
using Base: require_one_based_indexing



@static if VERSION > v"1.8.5"
    include("impl3.jl")
else
    include("impl2.jl")
    include("par_impl3.jl")
end

end # module SparseSparse
