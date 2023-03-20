# module t001
# using Random
# using SparseArrays
# using SimplySparse
# using Test

# function test()
#     for N  in [500, 5000, 50000, 213001, 471993, 631578, 991377]
#         ntries = 3
#         for _ in 1:ntries
#             @show N
#             A = sprand(N, N, 10 * rand() / N)
#             I1, J1, V1 = findnz(A)
#             A = sprand(N, N, 20 * rand() / N)
#             I2, J2, V2 = findnz(A)

#             I = cat(I1, I2, dims=1)
#             J = cat(J1, J2, dims=1)
#             V = cat(V1, V2, dims=1)
#             @time let
#                 A = sparse(I, J, V, N, N)
#             end
#             A = nothing
#             GC.gc()

#             I = cat(I1, I2, dims=1)
#             J = cat(J1, J2, dims=1)
#             V = cat(V1, V2, dims=1)
#             @time let
#                 B = SimplySparse.sparse(I, J, V, N, N)
#             end
#             B = nothing
#             GC.gc()

#         end
#     end
#     nothing
# end

# test()
# nothing

# end # module

# module t001
# using Random
# using SparseArrays
# using SimplySparse
# using ProfileView
# using Test

# function test()
#     for N  in [631578, ]
#         ntries = 1
#         for _ in 1:ntries
#             @show N
#             A = sprand(N, N, 100 * rand() / N)
#             I1, J1, V1 = findnz(A)
#             A = sprand(N, N, 200 * rand() / N)
#             I2, J2, V2 = findnz(A)

#             I = cat(I1, I2, dims=1)
#             J = cat(J1, J2, dims=1)
#             V = cat(V1, V2, dims=1)
#             @time let
#                 A = sparse(I, J, V, N, N)
#             end
#             A = nothing
#             GC.gc()

#             I = cat(I1, I2, dims=1)
#             J = cat(J1, J2, dims=1)
#             V = cat(V1, V2, dims=1)
#             @time let
#                 B = SimplySparse.sparse(I, J, V, N, N)
#                 @profview B = SimplySparse.sparse(I, J, V, N, N)

#             end
#             B = nothing
#             GC.gc()

#         end
#     end
#     nothing
# end

# test()
# nothing

# end # module

# function _countingsortperm!(perm, counts, data)
#     for i in eachindex(data) # @inbounds
#         j = data[i]
#         counts[j] += 1
#     end

#     for i in 2:length(counts) # @inbounds
#         counts[i] = counts[i] + counts[i - 1]
#     end

#     for i in lastindex(data):-1:firstindex(data) # @inbounds
#         j = data[i]
#         k = counts[j]
#         perm[k] = i
#         counts[j] -= 1
#     end
#     return nothing
# end

# function _sort!(arr)
# # Sorting using a single loop
#     j = 0
#     while true
#         j += 1
#         (j > length(arr)-1) && break
# # Checking the condition for two simultaneous elements of the array
#         if (arr[j] > arr[j + 1])
# # Swapping the elements.
#             temp = arr[j];
#             arr[j] = arr[j + 1];
#             arr[j + 1] = temp;
# # updating the value of j = -1 so after getting updated for j++ in the loop it
# # becomes 0 and the loop begins from the start.
#             j = 0;
#         end
#     end
#     return arr;
# end

# module t008
# function _sortperm!(perm, arr)
# # Sorting using a single loop
#     j = 0
#     while true
#         j += 1
#         (j > length(arr)-1) && break
#         if (arr[j] > arr[j + 1])
#             # Swapping the elements.
#             temp = arr[j];
#             arr[j] = arr[j + 1];
#             arr[j + 1] = temp;
#             temp = perm[j];
#             perm[j] = perm[j + 1];
#             perm[j + 1] = temp;
#             # so that after update the loop begins from the start.
#             j = 0;
#         end
#     end
#     return perm;
# end

# using BenchmarkTools
# data = [
# 15140
#  57938
#    404
#  19884
#  48345
#   1698
#    524
#  36170
#  59967
#  29684
#  62501
#  29673
#  11843
#  48039
#    524
#  36170
#  59967
#  29684
#  32069
#   7373
#  35366]
#  data = vcat(data, data, data)

# perm = collect(1:length(data))
# x = deepcopy(data)
# p = deepcopy(perm)

#  # @btime begin x .= data; _sort!(x); end
#  @btime begin x .= data; p .= perm; _sortperm!(p, x); end
#  @btime begin x .= data; sort!(x); end
#  @btime begin x .= data; sort!(p, Base.Sort.DEFAULT_UNSTABLE, Base.Order.Perm(Base.Order.Forward, x)); end
# nothing
# end

# #  counts = fill(0, maximum(data)+1)
# #  perm = collect(1:length(data))
# x .= data; p .= perm; _sortperm!(p, x); @show p
# data[p] == x


#  _countingsortperm!(perm, counts, data)

#  @show perm
# @show data[perm]
# counts[data] .= 0
# @show sum(counts)


# module t001
# using Random
# using SparseArrays
# using SimplySparse
# using ProfileView
# using DataDrop
# using Test

# function testA()
#     I = DataDrop.retrieve_matrix("I.h5")
#     J = DataDrop.retrieve_matrix("J.h5")
#     V = DataDrop.retrieve_matrix("V.h5")
#     N = 1328319

#     @time let
#         A = sparse(I, J, V, N, N)
#     end
# end
# function testB()
#     I = DataDrop.retrieve_matrix("I.h5")
#     J = DataDrop.retrieve_matrix("J.h5")
#     V = DataDrop.retrieve_matrix("V.h5")
#     N = 1328319

#     @time let
#         @profview        B = SimplySparse.sparse(I, J, V, N, N)
#         # @show nnz(B)
#     end
# end

# testA()
# ## testA()
# testB()
# # testB()

# nothing

# end # module


    # module t001
    # using Random
    # using SparseArrays
    # using SimplySparse
    # using ProfileView
    # using Test

    # function test()
    #     ntries = 1
    #     # for _ in 1:ntries
    #     #     for N  in [12, ]
    #     #         @show N
    #     #         A = sprand(N, N, 0.3)
    #     #         I1, J1, V1 = findnz(A)
    #     #         A = sprand(N, N, 0.7)
    #     #         I2, J2, V2 = findnz(A)

    #     #         I = cat(I1, I2, dims=1)
    #     #         J = cat(J1, J2, dims=1)
    #     #         V = cat(V1, V2, dims=1)
    #     #         @show I, J, V

    #     #         B = SimplySparse.sparse(I, J, V, N, N)

    #     #     end
    #     # end
    #     N = 12
    #     (I, J, V) = ([1, 1, 2, 2, 2, 2, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12], [2, 3, 1, 5, 9, 11, 2, 1, 4, 8, 9, 1, 3, 4, 7, 8, 10, 3, 5, 6, 8, 11, 1, 4, 7, 10, 11, 1, 2, 3, 4, 5, 9, 12, 7, 8,
    #     5, 6, 9, 12, 5, 7, 11, 12, 1, 3, 6, 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 1, 2, 4, 6, 7, 8, 10, 12, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12,  1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 1, 2, 3, 5, 7, 8, 9, 11, 12, 1, 2, 4, 5, 7, 9, 10, 11, 12, 1, 4, 6, 7, 8, 11, 1, 2, 3, 6, 7, 10, 11, 12, 3, 5, 6, 7, 9, 10, 12, 2, 3, 4, 5, 7, 9, 10, 11, 12, 1, 2, 3, 4, 5, 8, 11, 12], [7.34541e-01, 3.79205e-01, 3.10559e-01, 1.89196e-01, 5.02568e-01, 8.71701e-01, 5.07631e-01, 9.20705e-01, 1.00559e-01, 5.40836e-01, 7.98029e-01, 2.39612e-01, 8.21467e-01, 8.39167e-01, 9.35728e-01, 3.81726e-01, 7.09849e-01, 3.74736e-01, 5.46708e-01, 3.57350e-01, 8.33607e-01, 9.73897e-01, 5.19343e-01, 8.88829e-01, 2.04298e-01, 6.76946e-01, 2.33848e-01, 4.01331e-01, 2.32622e-01, 9.31044e-01, 5.81856e-01, 4.02288e-01, 6.32099e-02, 5.38391e-01, 9.52544e-01, 7.89291e-01, 2.64078e-01, 3.80723e-01, 7.91680e-01, 7.22894e-01, 1.26045e-01, 5.51714e-01, 1.51864e-02, 7.56613e-01, 5.19834e-01, 8.19176e-01, 1.03291e-01, 9.44283e-01, 5.39432e-01, 8.13954e-01, 6.11897e-01, 5.97695e-01, 9.83576e-01, 2.55639e-01, 8.59856e-01, 1.88421e-01, 4.70798e-01, 8.78104e-01, 8.42733e-01, 1.70173e-01, 1.25848e-01, 3.45855e-02, 8.02016e-02, 3.41804e-01, 7.53995e-01, 2.25891e-01, 7.05785e-01, 8.81775e-01, 2.76650e-01, 6.41885e-01, 4.47554e-01, 4.36233e-01, 2.42341e-01, 3.69906e-01, 1.37225e-01, 5.46043e-01, 8.77275e-01, 8.56452e-01, 8.36087e-01, 3.69421e-01, 4.16663e-01, 2.43876e-01, 8.35690e-01, 7.31361e-01, 6.13043e-02, 3.11421e-01, 8.36708e-01, 6.50448e-01, 5.36828e-01, 5.74137e-01, 1.09374e-01, 6.18298e-01, 6.90447e-01, 1.52608e-01, 7.91031e-01, 2.10818e-01, 8.85300e-01, 3.72425e-01, 8.10336e-01, 2.74992e-01, 7.83801e-02, 8.43886e-01, 6.83286e-01, 1.41830e-01, 7.60970e-01, 4.93709e-01, 4.35611e-01, 3.59794e-02, 7.88401e-01, 5.30044e-01,
    #     1.05079e-01, 4.13622e-01, 7.56162e-01, 6.95105e-01, 3.02221e-01, 5.13967e-01, 6.06776e-01, 9.84795e-01, 1.15254e-01, 8.04268e-01, 4.95615e-01, 3.58455e-01, 6.32448e-01, 5.53014e-01, 1.80003e-01, 9.00692e-01, 2.01465e-01, 5.94034e-01, 1.38014e-01, 3.67868e-01, 5.52147e-01, 9.14473e-01, 1.08158e-01, 8.68587e-01, 1.09116e-01, 4.93053e-01, 5.05353e-01, 8.82375e-01, 6.50712e-01, 2.09775e-01, 8.35552e-01, 8.78878e-01, 1.83486e-02, 2.59980e-01, 3.51839e-01, 4.86591e-01, 7.45851e-01, 7.83441e-01, 2.13515e-01, 9.63249e-01, 3.70507e-01, 2.79614e-01])
    #     @show sort(J)
    #     B = SimplySparse.sparse(I, J, V, N, N)
    #     nothing
    # end

    # test()
    # nothing

    # end # module


module mt001
using Random
using SparseArrays
using SimplySparse
using ProfileView
using Test

function test()
    ntries = 1
    # for _ in 1:ntries
    #     for N  in [12, ]
    #         @show N
    #         A = sprand(N, N, 0.3)
    #         I1, J1, V1 = findnz(A)
    #         A = sprand(N, N, 0.7)
    #         I2, J2, V2 = findnz(A)

    #         I = cat(I1, I2, dims=1)
    #         J = cat(J1, J2, dims=1)
    #         V = cat(V1, V2, dims=1)
    #         @show I, J, V

    #         B = SimplySparse.sparse(I, J, V, N, N)

    #     end
    # end
    (Nr, Nc) = (4, 1)
    (I, J, V) = ([1, 2, 3, 1, 2, 4], [1, 1, 1, 1, 1, 1], [0.6976804523441354, 0.1730260193308485, 0.33524886657616804, 0.7699142576510188, 0.8495482510000932, 0.5539873737363903])
    B = SimplySparse.sparse(I, J, V, Nr, Nc)
    nothing
end

test()
nothing

end # module

