module SimpleSparse

using Random
using SparseArrays

function _countingsort3!(outputI, outputJ, outputV, I, J, V, Nc)
    count = fill(zero(eltype(J)), Nc+1)
    for i in eachindex(J) # @inbounds
        j = J[i]
        count[j] = count[j] + 1
    end

    for i  in 2:Nc+1 # @inbounds
        count[i] = count[i] + count[i - 1]
    end

    for i  in lastindex(J):-1:firstindex(J) # @inbounds
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

function _compress_rows(Nc, colptr, I, V)
    maxrows = maximum(diff(colptr))
    prma = fill(zero(eltype(I)), maxrows)
    newI = similar(I)
    newV = similar(V)
    newcolptr = similar(colptr)
    newcolptr[1] = colptr[1]
    p = 1
    for c in 1:Nc
        rows = view(I, colptr[c]:colptr[c+1]-1)
        if !isempty(rows)
            vals = view(V, colptr[c]:colptr[c+1]-1)
            prm = view(prma, 1:length(rows))
            for i = axes(rows,1) # @inbounds
                prm[i] = i
            end
            sort!(prm, Base.Sort.DEFAULT_UNSTABLE, Base.Order.Perm(Base.Order.Forward, rows))
            # sortperm!(prm, rows)
            r = rows[prm[1]]
            v = vals[prm[1]]
            p = newcolptr[c]
            for j in 2:lastindex(rows)
                if rows[prm[j]] == r
                    v += vals[prm[j]]
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
    newI = newI[1:p-1]
    newV = newV[1:p-1]
    return newcolptr, newI, newV
end

function sparse(inputI, inputJ, inputV, Nr, Nc)
    I = similar(inputI)
    J = similar(inputJ)
    V = similar(inputV)

    _countingsort3!(I, J, V, inputI, inputJ, inputV, Nc)
    colptr = _column_pointers(Nc, J)
    newcolptr, newI, newV = _compress_rows(Nc, colptr, I, V)

    return SparseMatrixCSC(Nr, Nc, newcolptr, newI, newV)
end

end # module SparseSparse
