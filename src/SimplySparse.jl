module SimplySparse

using Random
using SparseArrays
using Base: require_one_based_indexing

@static if VERSION > v"1.8.5"
    include("impl4.jl")
else
    include("impl2.jl")
end

sparse(I,J,V::AbstractVector,m,n) = sparse(I, J, V, Int(m), Int(n), +)
sparse(I,J,V::AbstractVector{Bool},m,n) = sparse(I, J, V, Int(m), Int(n), |)

end # module SparseSparse
