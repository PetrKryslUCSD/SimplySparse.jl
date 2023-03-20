module t001
using Random
using SparseArrays
using SimplySparse
using ProfileView
using DataDrop
using Test

function testA()
    I = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "I.h5"))
    J = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "J.h5"))
    V = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "V.h5"))
    N = 1328319

    @time let
        A = sparse(I, J, V, N, N)
    end
end
function testB()
    I = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "I.h5"))
    J = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "J.h5"))
    V = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "V.h5"))
    N = 1328319

    @time let
        B = SimplySparse.sparse(I, J, V, N, N)
        # @profview SimplySparse.sparse(I, J, V, N, N)
        # @show nnz(B)
    end
end

testA()
testA()
testB()
testB()

nothing

end # module
