module SimplySparse

using Random
using SparseArrays
using Base: require_one_based_indexing

function _countingsort3!(outputI, outputJ, outputV, I, J, V, Nc)
    count = fill(zero(eltype(J)), Nc+1)
    @inbounds for i in eachindex(J)
        j = J[i]
        count[j] = count[j] + 1
    end

    @inbounds for i  in 2:Nc+1
        count[i] = count[i] + count[i - 1]
    end

    @inbounds for i  in lastindex(J):-1:firstindex(J)
        j = J[i]
        # output[count[j]] = j
        k = count[j]
        outputI[k] = I[i]
        outputJ[k] = J[i]
        outputV[k] = V[i]
        count[j] = count[j] - 1
    end
    return nothing
end

function _column_pointers(Nc, J)
    colptr = fill(0, Nc+1)
    p = 1
    for c in 1:Nc
        if p > length(J)
            colptr[c] = p
        else
            cs = p
            while true
                p > length(J) && break
                J[p] != c && break
                p = p + 1
            end
            colptr[c] = cs
        end
    end
    colptr[end] = length(J) + 1
    return colptr
end

function _compress_rows!(newcolptr, newI, newV, Nc, colptr, I, V, combine)
    maxrows = maximum(diff(colptr))
    prma = fill(zero(eltype(I)), maxrows)
    newcolptr[1] = colptr[1]
    p = 1
    for c in 1:Nc
        rows = view(I, colptr[c]:colptr[c+1]-1)
        if !isempty(rows)
            vals = view(V, colptr[c]:colptr[c+1]-1)
            prm = view(prma, 1:length(rows))
            @inbounds for i = axes(rows,1)
                prm[i] = i
            end
            sort!(prm, Base.Sort.DEFAULT_UNSTABLE, Base.Order.Perm(Base.Order.Forward, rows))
            r = rows[prm[1]]
            v = vals[prm[1]]
            p = newcolptr[c]
            for j in 2:lastindex(rows)
                if rows[prm[j]] == r
                    v = combine(vals[prm[j]], v)
                else
                    newI[p] = r
                    newV[p] = v
                    r = rows[prm[j]]
                    v = vals[prm[j]]
                    p += 1
                end
            end
            newI[p] = r
            newV[p] = v
            p += 1
            newcolptr[c+1] = p
        else
            newcolptr[c+1] = p
        end
    end
    return newcolptr, resize!(newI, p-1), resize!(newV, p-1)
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
        privateI = similar(I)
        privateJ = similar(J)
        privateV = similar(V)
        _countingsort3!(privateI, privateJ, privateV, I, J, V, n)
        colptr = _column_pointers(n, privateJ)
        newcolptr = similar(colptr)
        newI = privateJ # reuse this storage
        newV = similar(V)
        _compress_rows!(newcolptr, newI, newV, n, colptr, privateI, privateV, combine)
        privateI = nothing
        privateJ = nothing
        privateV = nothing
        return SparseMatrixCSC(m, n, newcolptr, newI, newV)
    end
end
sparse(I,J,V::AbstractVector,m,n) = sparse(I, J, V, Int(m), Int(n), +)
sparse(I,J,V::AbstractVector{Bool},m,n) = sparse(I, J, V, Int(m), Int(n), |)

end # module SparseSparse
