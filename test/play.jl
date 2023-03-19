module t001
using Random
using SparseArrays
using SimplySparse
using Test

function test()
    for N  in [500, 5000, 50000, 213001, 471993, 631578, 991377]
        ntries = 3
        for _ in 1:ntries
            @show N
            A = sprand(N, N, 10 * rand() / N)
            I1, J1, V1 = findnz(A)
            A = sprand(N, N, 20 * rand() / N)
            I2, J2, V2 = findnz(A)

            I = cat(I1, I2, dims=1)
            J = cat(J1, J2, dims=1)
            V = cat(V1, V2, dims=1)
            @time let
                A = sparse(I, J, V, N, N)
            end
            A = nothing
            GC.gc()

            I = cat(I1, I2, dims=1)
            J = cat(J1, J2, dims=1)
            V = cat(V1, V2, dims=1)
            @time let
                B = SimplySparse.sparse(I, J, V, N, N)
            end
            B = nothing
            GC.gc()

        end
    end
    nothing
end

test()
nothing

end # module
