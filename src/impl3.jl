
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
    # In this loop, we calculate how many row and tries there are in the COO
    # list for each column
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

    rowval = similar(I)
    nzval = similar(V)
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

function _compress_rows!(newcolptr, newrowval, newnzval, m, n, colptr, rowval, nzval, combine)
    maxrows = maximum(diff(colptr))
    prma = fill(zero(eltype(rowval)), maxrows)
    scratcha = fill(zero(eltype(rowval)), maxrows)
    newcolptr[1] = colptr[1]
    p = 1
    for c in 1:n
        rows = view(rowval, colptr[c]:colptr[c+1]-1)
        if !isempty(rows)
            vals = view(nzval, colptr[c]:colptr[c+1]-1)
            prm = view(prma, 1:length(rows))
            @inbounds for i in axes(rows,1)
                prm[i] = i
            end
            sortperm!(prm, rows; scratch=scratcha)
            r = rows[prm[1]]
            v = vals[prm[1]]
            p = newcolptr[c]
            @inbounds for j in 2:lastindex(rows)
                pj = prm[j]
                if rows[pj] == r
                    v = combine(vals[pj], v)
                else
                    newrowval[p] = r
                    newnzval[p] = v
                    r = rows[pj]
                    v = vals[pj]
                    p += 1
                end
            end
            newrowval[p] = r
            newnzval[p] = v
            p += 1
            newcolptr[c+1] = p
        else
            newcolptr[c+1] = p
        end
    end
    return newcolptr, resize!(newrowval, p-1), resize!(newnzval, p-1)
end

function sparse(I::AbstractVector{Ti}, J::AbstractVector{Ti}, V::AbstractVector{Tv}, m::Integer, n::Integer, combine) where {Tv,Ti<:Integer}
    require_one_based_indexing(I, J, V)
    coolen = length(I)
    if length(J) != coolen || length(V) != coolen
        throw(ArgumentError(string("the first three arguments' lengths must match, ",
          "length(I) (=$(length(I))) == length(J) (= $(length(J))) == length(V) (= ",
          "$(length(V)))")))
    end
    if Base.hastypemax(Ti) && coolen >= typemax(Ti)
        throw(ArgumentError("the index type $Ti cannot hold $coolen elements; use a larger index type"))
    end
    if m == 0 || n == 0 || coolen == 0
        if coolen != 0
            if n == 0
                throw(ArgumentError("column indices J[k] must satisfy 1 <= J[k] <= n"))
            elseif m == 0
                throw(ArgumentError("row indices I[k] must satisfy 1 <= I[k] <= m"))
            end
        end
        return SparseMatrixCSC(m, n, fill(one(Ti), n+1), Vector{Ti}(), Vector{Tv}())
    else
        colptr, rowval, nzval = _unsorted_csc(I, J, V, m, n)
        newcolptr = similar(colptr)
        # newrowval = similar(rowval) # reuse I?
        # newnzval = similar(V) # reuse V?
        newrowval, newnzval = I, V
        _compress_rows!(newcolptr, newrowval, newnzval, m, n, colptr, rowval, nzval, combine)
        # @show newcolptr, newrowval, newnzval
        return SparseMatrixCSC(m, n, newcolptr, newrowval, newnzval)
    end
end
