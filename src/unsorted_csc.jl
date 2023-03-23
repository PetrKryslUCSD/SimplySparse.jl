
# Compute the CSR form's row counts and store them shifted forward by one in csrrowptr
function _unsorted_csc(I, J, V, m, n, only_sparsity_pattern = false)
    colptr = fill(zero(eltype(J)), n+1)
    coolen = length(I)
    length(J) >= coolen || throw(ArgumentError("J need length >= length(I) = $coolen"))
    only_sparsity_pattern || length(V) >= coolen || throw(ArgumentError("V need length >= length(I) = $coolen"))
    IONE = eltype(I)(1)
    JONE = eltype(J)(1)
    m = eltype(I)(m)
    n = eltype(J)(n)
    # In this loop, we calculate how many rows there are in the COO
    @inbounds for k in 1:coolen # @inbounds
        Jk = J[k]
        if 1 > Jk || n < Jk
            throw(ArgumentError("Column indices J[k] must satisfy 1 <= J[k] <= n"))
        end
        colptr[Jk+1] += JONE
    end

    # Compute the CSC form's column pointers and store them shifted forward by
    # one in colptr
    countsum = JONE
    colptr[1] = JONE
    @inbounds for i in 2:(n+1) # @inbounds
        temp = colptr[i]
        colptr[i] = countsum
        countsum += temp
    end

    rowval = similar(I, eltype(I), countsum);
    nzval = similar(V, eltype(V), countsum)
    # Counting-sort the column and nonzero values from I and V into rowval
    # and nzval. Tracking write positions in colptr corrects the column
    # pointers
    @inbounds for k in 1:coolen # @inbounds
        Ik, Jk = I[k], J[k]
        if IONE > Ik || m < Ik
            throw(ArgumentError("Row indices I[k] must satisfy 1 <= I[k] <= m"))
        end
        p = colptr[Jk+1]
        @assert p >= IONE "index into rowval exceeds typemax(eltype(I))"
        colptr[Jk+1] = p + JONE
        rowval[p] = Ik
        if !only_sparsity_pattern
            nzval[p] = V[k]
        end
    end
    return colptr, rowval, nzval
end
