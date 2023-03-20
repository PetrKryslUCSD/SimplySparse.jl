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


module t001
using Random
using SparseArrays
using SimplySparse
using ProfileView
using DataDrop
using Test

function testA()
    I = DataDrop.retrieve_matrix("I.h5")
    J = DataDrop.retrieve_matrix("J.h5")
    V = DataDrop.retrieve_matrix("V.h5")
    N = 1328319

    @time let
        A = sparse(I, J, V, N, N)
    end
end
function testB()
    I = DataDrop.retrieve_matrix("I.h5")
    J = DataDrop.retrieve_matrix("J.h5")
    V = DataDrop.retrieve_matrix("V.h5")
    N = 1328319

    @time let
        @profview        B = SimplySparse.sparse(I, J, V, N, N)
        # @show nnz(B)
    end
end

testA()
## testA()
testB()
# testB()

nothing

end # module
