module t001
using Random
using SparseArrays
using SimpleSparse
using Test

function test()
    for N  in [500, 5000, 50000]
        ntries = 100
        for _ in 1:ntries
            A = sprand(N, N, 2.3 / N)
            I1, J1, V1 = findnz(A)
            A = sprand(N, N, 9.1 / N)
            I2, J2, V2 = findnz(A)

            I = cat(I1, I2, dims=1)
            J = cat(J1, J2, dims=1)
            V = cat(V1, V2, dims=1)
            A = sparse(I, J, V, N, N)

            I = cat(I1, I2, dims=1)
            J = cat(J1, J2, dims=1)
            V = cat(V1, V2, dims=1)
            B = SimpleSparse.sparse(I, J, V, N, N)

            @test A - B == spzeros(N, N)
        end
    end
    nothing
end

test()
nothing

end # module


module t002
using Random
using SparseArrays
using SimpleSparse
using Test

function test()
    ntries = 100
    for _ in 1:ntries
        for Nc  in [1, 5, 7, 13]
            for Nr  in [1, 4, 8, 71]
                # @show Nr, Nc
                A = sprand(Nr, Nc, 0.83)
                I1, J1, V1 = findnz(A)
                A = sprand(Nr, Nc, 0.67)
                I2, J2, V2 = findnz(A)

                I = cat(I1, I2, dims=1)
                J = cat(J1, J2, dims=1)
                V = cat(V1, V2, dims=1)
                A = sparse(I, J, V, Nr, Nc)

                I = cat(I1, I2, dims=1)
                J = cat(J1, J2, dims=1)
                V = cat(V1, V2, dims=1)
                B = SimpleSparse.sparse(I, J, V, Nr, Nc)

                @test A - B == spzeros(Nr, Nc)
            end
        end
    end
    nothing
end

# function test1()
#     Nc  = 1
#     Nr  = 4

#     A = sparse([1, 2, 3], [1, 1, 1], [4.42953e-02, 1.18950e+00, 9.50385e-02], 4, 1)
#     @show A

#     I, J, V = ([1, 2, 3], [1, 1, 1], [4.42953e-02, 1.18950e+00, 9.50385e-02])
#     B = SimpleSparse.sparse(I, J, V, Nr, Nc)
#     @show B

#     @test A - B == spzeros(Nr, Nc)

#     nothing
# end

test()
nothing

end # module

module t003
using Random
using SparseArrays
using SimpleSparse
using Test

function test()
    ntries = 100
    for _ in 1:ntries
        for Nc  in [1, 5, 7, 13, 80, 99]
            for Nr  in [1, 4, 8, 71, 213]
                # @show Nr, Nc
                A = sprand(Nr, Nc, rand())
                I1, J1, V1 = findnz(A)
                A = sprand(Nr, Nc, rand())
                I2, J2, V2 = findnz(A)

                I = cat(I1, I2, dims=1)
                J = cat(J1, J2, dims=1)
                V = cat(V1, V2, dims=1)
                A = sparse(I, J, V, Nr, Nc)

                I = cat(I1, I2, dims=1)
                J = cat(J1, J2, dims=1)
                V = cat(V1, V2, dims=1)
                B = SimpleSparse.sparse(I, J, V, Nr, Nc)

                @test A - B == spzeros(Nr, Nc)
            end
        end
    end
    nothing
end

test()
nothing

end # module
