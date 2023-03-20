module t001
using Random
using SparseArrays
using SimplySparse
using ProfileView
using DataDrop
using Test

function load_data()
    I = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "h8", "I.h5"))
    J = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "h8", "J.h5"))
    V = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "h8", "V.h5"))
    N = 1328319
    return N, I, J, V
end

function testA()
    N, I, J, V = load_data()

    @time let
        A = sparse(I, J, V, N, N)
    end
end
function testB()
    N, I, J, V = load_data()

    @time let
        B = SimplySparse.sparse(I, J, V, N, N)
        # @profview SimplySparse.sparse(I, J, V, N, N)  #
        # @show nnz(B)
    end
end

testA()
testA()
testB()
testB()

nothing

end # module
