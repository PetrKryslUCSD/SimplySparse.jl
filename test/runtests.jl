
module tmod001
using Random
using SparseArrays
using SimplySparse
using SimplySparse.QuickSort: quicksort!, parallel_quicksort!
using Test

function test(n)
    b = rand(n)
    perm = collect(1:n)

    for i = 1:5
        # print("Parallel  : ")
        a1 = copy(b); p1 = copy(perm);
        # @time
        parallel_quicksort!(a1, p1);
        # print("Sequential: ")
        a2 = copy(b); p2 = copy(perm);
        # @time
        quicksort!(a2, p2);
        # println("")
        @test a1 == sort(a1)
        @test a1 == a2
        @test p1 == sortperm(b)
        @test p2 == sortperm(b)
        @test b[p1] == sort(b)
        @test b[p2] == sort(b)
    end
end

test(2^21)

nothing

end # module

module t001
using Random
using SparseArrays
using SimplySparse
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
            B = SimplySparse.sparse(I, J, V, N, N)

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
using SimplySparse
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
                # @show Nr, Nc
                # @show I, J, V
                B = SimplySparse.sparse(I, J, V, Nr, Nc)

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
#     B = SimplySparse.sparse(I, J, V, Nr, Nc)
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
using SimplySparse
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
                B = SimplySparse.sparse(I, J, V, Nr, Nc)

                @test A - B == spzeros(Nr, Nc)
            end
        end
    end
    nothing
end

test()
nothing

end # module

module t004
using Random
using SparseArrays
using SimplySparse
using Test

function test()
    Nr, Nc = 1, 1
    I = Int32[]
    J = Int32[]
    V = Int32[]
    B = SimplySparse.sparse(I, J, V, Nr, Nc)

    @test B == spzeros(Nr, Nc)
    nothing
end

test()
nothing

end # module

module t005
using Random
using SparseArrays
using SimplySparse
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
            B = SimplySparse.par_sparse(I, J, V, N, N)

            @test A - B == spzeros(N, N)
        end
    end
    nothing
end

test()
nothing

end # module
