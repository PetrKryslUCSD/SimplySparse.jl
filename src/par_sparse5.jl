using ChunkSplitters
using UnicodePlots
using .QuickSort3: parallel_quicksort3!

function _find_breaks(J, nchunks)
    chunkl = Int(round(length(J) / nchunks))
    achs = []
    p = 1
    while p <= length(J)
        s = p
        f = min(p + chunkl, length(J))
        sc = J[s]
        fc = J[f]
        while f <= length(J) &&  J[f] == fc
            f += 1
        end
        f -= 1
        @assert J[f] == fc
        push!(achs, (columns = (sc, fc), chunk = (s, f)))
        p = f + 1
    end
    return achs
end

function _thread_work(smsi, I, J, V, m, n)
    sc, fc = smsi[2]
    from, to = smsi[1]
    S = SparseArrays.sparse(view(I, from:to), view(J, from:to), view(V, from:to), m, n)
    return ((from, to), (sc, fc), S)
end

function _merge(sms)
    S = sms[1][3]
    sc, fc = sms[1][2]
    colptr = S.colptr
    rowval = S.rowval
    nzval = S.nzval
    m = S.m
    n = S.n
    S = nothing
    for i in 2:length(sms)
        s = sms[i][3]
        sc, fc = sms[i][2]
        colptr[sc:end] .+= (s.colptr[sc:end] .- 1)
        rowval = cat(rowval, s.rowval, dims=1)
        nzval = cat(nzval, s.nzval, dims=1)
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
        @time begin
            parallel_quicksort3!(J, I, V)
        end
        # @time begin
        #     sortperm!(p, J; initialized=true)
        #     J = J[p]
        #     I = I[p]
        #     V = V[p]
        # end
        nthr = Base.Threads.nthreads()
        @time achs = _find_breaks(J, nthr)
        sms = [(ch.chunk, ch.columns, spzeros(m, n)) for ch in achs]
        @time begin
            Base.Threads.@threads for i in 1:length(sms)
                sms[i] = _thread_work(sms[i], I, J, V, m, n)
                # display(spy(s, canvas=DotCanvas))
            end
        end

        return @time _merge(sms)
    end
end


par_sparse(I,J,V::AbstractVector,m,n) = par_sparse(I, J, V, Int(m), Int(n), +)
par_sparse(I,J,V::AbstractVector{Bool},m,n) = par_sparse(I, J, V, Int(m), Int(n), |)
