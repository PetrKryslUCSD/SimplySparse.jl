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
        # newcolptr = similar(colptr)
        # newrowval = similar(rowval) # reuse I?
        # newnzval = similar(V) # reuse V?
        newcolptr, newrowval, newnzval = I, J, V
        _compress_rows!(newcolptr, newrowval, newnzval, m, n, colptr, rowval, nzval, combine)
        # @show newcolptr, newrowval, newnzval
        return SparseMatrixCSC(m, n, newcolptr, newrowval, newnzval)
    end
end


sparse(I,J,V::AbstractVector,m,n) = sparse(I, J, V, Int(m), Int(n), +)
sparse(I,J,V::AbstractVector{Bool},m,n) = sparse(I, J, V, Int(m), Int(n), |)
