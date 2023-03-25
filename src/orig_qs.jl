const SEQ_THRESH = 1 << 9

@inline function partition!(A, pivot, left,right)
    @inbounds while left <= right
      while A[left] < pivot
        left += 1
      end
      while A[right] > pivot
        right -= 1
      end
      if left <= right
        A[left], A[right] = A[right], A[left]
        left += 1
        right -= 1
      end
    end

  return (left,right)
end

function quicksort!(A, i=1, j=length(A))
  if j > i
    left, right = partition!(A, A[(j+i) >>> 1], i, j)
    quicksort!(A,i,right)
    quicksort!(A,left,j)
  end
  return
end

function parallel_quicksort!(A,i=1,j=length(A))
  if j-i <= SEQ_THRESH
    quicksort!(A, i, j)
    return
  end
  left, right = partition!(A, A[(j+i) >>> 1], i, j)
  t = Threads.@spawn parallel_quicksort!(A,i,right)
  parallel_quicksort!(A,left,j)
  wait(t)

  return
end

function test(n)
  b = rand(n)

  for i = 1:5
    print("Parallel  : ")
    a1 = copy(b); @time parallel_quicksort!(a1);
    print("Sequential: ")
    a2 = copy(b); @time quicksort!(a2);
    println("")
    @assert a1 == sort(a1)
    @assert a1 == a2
  end

end

test(157000000)
