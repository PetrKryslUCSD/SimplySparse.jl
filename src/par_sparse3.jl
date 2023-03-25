using ChunkSplitters
using UnicodePlots

function _make(I, J, V, m, n, combine, from, to)
    times = Float64[]
    start = time()
    colptr, rowval, nzval = _unsorted_csc_subset(I, J, V, m, n, from, to)
    push!(times, time()-start); start = time()
    newcolptr = similar(colptr)
    newrowval = similar(rowval) # reuse I?
    newnzval = similar(nzval) # reuse V?
    _compress_rows!(newcolptr, newrowval, newnzval, m, n, colptr, rowval, nzval, combine)
    push!(times, time()-start); start = time()
    S = SparseMatrixCSC(m, n, newcolptr, newrowval,
        newnzval)
    return S, times
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
        overallstart = time()
        tasks = []
        for ch in chunks(1:n, nthr-1)
            t = Base.Threads.@spawn let from = $ch[1][1], to = $ch[1][end]
                S, times = _make(I, J, V, m, n, combine, from, to)
            end
            push!(tasks, t)
            # display(spy(s, canvas=DotCanvas))
        end
        # @info "Fetch started in $(time() - overallstart)"
        start = time()
        overalltimes = []
        S = spzeros(m, n)
        for t in  tasks
            tS, times = fetch(t)
            S += tS
            push!(overalltimes, times)
        end
        push!(overalltimes, time()-start)
        # @info "Fetch finished in $(time() - overallstart)"
        @show overalltimes
        return S
    end
end


par_sparse(I,J,V::AbstractVector,m,n) = par_sparse(I, J, V, Int(m), Int(n), +)
par_sparse(I,J,V::AbstractVector{Bool},m,n) = par_sparse(I, J, V, Int(m), Int(n), |)
