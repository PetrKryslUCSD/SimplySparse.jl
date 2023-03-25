using ChunkSplitters
using UnicodePlots

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
        s = Base.Semaphore(1)
        sms = []
        Base.Threads.@threads for ch in chunks(1:n, nthr)
            # @show ch[1][1], ch[1][end]
            colptr, rowval, nzval = _unsorted_csc_subset(I, J, V, m, n, ch[1][1], ch[1][end])
            newcolptr = similar(colptr)
            newrowval = similar(rowval) # reuse I?
            newnzval = similar(nzval) # reuse V?
            _compress_rows!(newcolptr, newrowval, newnzval, m, n, colptr, rowval, nzval, combine)
            Base.acquire(s) do
                push!(sms, SparseMatrixCSC(m, n, newcolptr, newrowval,
                    newnzval))
            end
            # display(spy(s, canvas=DotCanvas))
        end
        return +(sms...)
# @show         nthr = Base.Threads.nthreads()
#         return let ch =  chunks(1:n, nthr)[1]
#             # @show ch[1][1], ch[1][end]
#             @time colptr, rowval, nzval = _unsorted_csc_subset(I, J, V, m, n, ch[1][1], ch[1][end])
#             newcolptr = similar(colptr)
#             newrowval = similar(rowval) # reuse I?
#             newnzval = similar(nzval) # reuse V?
#             @time _compress_rows!(newcolptr, newrowval, newnzval, m, n, colptr, rowval, nzval, combine)
#             S = SparseMatrixCSC(m, n, newcolptr, newrowval,
#                     newnzval)
#         end
    end
end


par_sparse(I,J,V::AbstractVector,m,n) = par_sparse(I, J, V, Int(m), Int(n), +)
par_sparse(I,J,V::AbstractVector{Bool},m,n) = par_sparse(I, J, V, Int(m), Int(n), |)
