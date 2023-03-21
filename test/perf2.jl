module t001
using Random
using SparseArrays
using SimplySparse
using DataDrop
using Test

function load_data()
    which = "h20"
    I = DataDrop.retrieve_matrix(joinpath(pwd(), "test", which, "I.h5"))
    J = DataDrop.retrieve_matrix(joinpath(pwd(), "test", which, "J.h5"))
    V = DataDrop.retrieve_matrix(joinpath(pwd(), "test", which, "V.h5"))
    N = maximum(I)
    return N, I, J, V
end

function testA()
    N, I, J, V = load_data()
    @info "Built in"
    @time let
        A = sparse(I, J, V, N, N)
    end
    GC.gc()
end
function testB()
    N, I, J, V = load_data()
    @info "SimplySparse"
    @time let
        B = SimplySparse.sparse(I, J, V, N, N)
        # @profview SimplySparse.sparse(I, J, V, N, N)  #
        # @show nnz(B)
    end
    GC.gc()
end

testB()
testB()
testA()
testA()

nothing

end # module
