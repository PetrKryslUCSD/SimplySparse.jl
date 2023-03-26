using ChunkSplitters
using UnicodePlots

function _lt(x, y)
    x[1] < y[1]
end
function _merge(m, n, ss)
    ss = sort(ss; lt= _lt)
    sc, fc = ss[1][1], ss[1][2]
    colptr = ss[1][3]
    rowval = ss[1][4]
    nzval = ss[1][5]
    for i in 2:length(ss)
        @assert fc < ss[i][1] "$(fc) vs $(ss[i][1])"
        sc, fc = ss[i][1], ss[i][2]
        colptr[sc:end] .+= (ss[i][3][sc:end] .- 1)
        rowval = cat(rowval, ss[i][4], dims=1)
        nzval = cat(nzval, ss[i][5], dims=1)
    end
    return SparseMatrixCSC(m, n, colptr, rowval, nzval)
end

function par_sparse(I::AbstractVector{Ti}, J::AbstractVector{Ti}, V::AbstractVector{Tv}, m::Integer, n::Integer, combine) where {Tv,Ti<:Integer}
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
        nthr = Base.Threads.nthreads()
        ss = [(1, 1, [1], [1], [0.0]) for _ in 1:nthr]
        Base.Threads.@threads for ch in chunks(1:n, nthr)
            # @show ch
            @time begin
                colptr, rowval, nzval = _unsorted_csc_subset(I, J, V, m, n, ch[1][1], ch[1][end])
                newcolptr = similar(colptr)
                newrowval = similar(rowval)
                newnzval = similar(nzval)
                _compress_rows!(newcolptr, newrowval, newnzval, m, n, colptr, rowval, nzval, combine)
                ss[ch[2]] = (ch[1][1], ch[1][end], newcolptr, newrowval, newnzval)
                # @show ss[end][1:2]
                # display(spy(s, canvas=DotCanvas))
            end
        end
        return @time _merge(m, n, ss)
    end
end


par_sparse(I,J,V::AbstractVector,m,n) = par_sparse(I, J, V, Int(m), Int(n), +)
par_sparse(I,J,V::AbstractVector{Bool},m,n) = par_sparse(I, J, V, Int(m), Int(n), |)
