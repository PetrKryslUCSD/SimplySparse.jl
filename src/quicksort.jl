module QuickSort

const SEQ_THRESH = 2^9

@inline function partition!(A, perm, pivot, left,right)
    @inbounds while left <= right
        while A[left] < pivot
            left += 1
        end
        while A[right] > pivot
            right -= 1
        end
        if left <= right
            A[left], A[right] = A[right], A[left]
            perm[left], perm[right] = perm[right], perm[left]
            left += 1
            right -= 1
        end
    end
    return (left,right)
end

function quicksort!(A, perm, i=1, j=length(A))
    if j > i
        left, right = partition!(A, perm, A[(j+i) >>> 1], i, j)
        quicksort!(A, perm, i, right)
        quicksort!(A, perm, left, j)
    end
end

function parallel_quicksort!(A, perm, i=1, j=length(A))
    if j-i <= SEQ_THRESH
        quicksort!(A, perm, i, j)
        return
    end
    left, right = partition!(A, perm, A[(j+i) >>> 1], i, j)
    t = Threads.@spawn parallel_quicksort!(A, perm, $i, $right)
    parallel_quicksort!(A, perm, left, j)
    wait(t)
    return
end

end # module

# module tmod001
# using Random
# using SparseArrays

# using Main.QuickSort: quicksort!, parallel_quicksort!
# using Test

# function test(n)
#     b = rand(n)
#     perm = collect(1:n)

#     for i = 1:1
#         print("Parallel  : ")
#         a1 = copy(b); p1 = copy(perm);
#         @time        parallel_quicksort!(a1, p1);
#         print("Sequential: ")
#         a2 = copy(b); p2 = copy(perm);
#         @time        quicksort!(a2, p2);
#         println("")
#         @test a1 == sort(a1)
#         @test a1 == a2
#         @test p1 == sortperm(b)
#         @test p2 == sortperm(b)
#         @test b[p1] == sort(b)
#         @test b[p2] == sort(b)
#     end
# end

# # test(129048)
# test(129808048)

# nothing

# end # module
