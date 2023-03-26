module QuickSort3

const SEQ_THRESH = 2^9

@inline function partition3!(A, B, C, pivot, left,right)
    @inbounds while left <= right
        while A[left] < pivot
            left += 1
        end
        while A[right] > pivot
            right -= 1
        end
        if left <= right
            A[left], A[right] = A[right], A[left]
            B[left], B[right] = B[right], B[left]
            C[left], C[right] = C[right], C[left]
            left += 1
            right -= 1
        end
    end
    return (left,right)
end

function quicksort3!(A, B, C, i=1, j=length(A))
    if j > i
        left, right = partition3!(A, B, C, A[(j+i) >>> 1], i, j)
        quicksort3!(A, B, C, i, right)
        quicksort3!(A, B, C, left, j)
    end
end

function parallel_quicksort3!(A, B, C, i=1, j=length(A))
    if j-i <= SEQ_THRESH
        quicksort3!(A, B, C, i, j)
        return
    end
    left, right = partition3!(A, B, C, A[(j+i) >>> 1], i, j)
    t = Threads.@spawn parallel_quicksort3!(A, B, C, $i, $right)
    parallel_quicksort3!(A, B, C, left, j)
    wait(t)
    return
end

end # module

# module tmod001
# using Random
# using SparseArrays

# using Main.QuickSort: quicksort3!, pquicksortperm!
# using Test

# function test(n)
#     b = rand(n)
#     perm = collect(1:n)

#     for i = 1:1
#         print("Parallel  : ")
#         a1 = copy(b); p1 = copy(perm);
#         @time        pquicksortperm!(a1, p1);
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
