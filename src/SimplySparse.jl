module SimplySparse

using Random
using SparseArrays
using Base: require_one_based_indexing

include("impl2.jl")

sparse(I,J,V::AbstractVector,m,n) = sparse(I, J, V, Int(m), Int(n), +)
sparse(I,J,V::AbstractVector{Bool},m,n) = sparse(I, J, V, Int(m), Int(n), |)

end # module SparseSparse
