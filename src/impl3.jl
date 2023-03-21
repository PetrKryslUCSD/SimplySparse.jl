include("unsorted_csc.jl")

function _compress_rows!(newcolptr, newrowval, newnzval, m, n, colptr, rowval, nzval, combine)
    maxrows = maximum(diff(colptr))
    prma = fill(zero(eltype(rowval)), maxrows)
    scratcha = fill(zero(eltype(rowval)), maxrows)
    resize!(newcolptr, length(colptr))
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
            sortperm!(prm, rows; initialized=true, scratch=scratcha)
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

include("sparse.jl")
