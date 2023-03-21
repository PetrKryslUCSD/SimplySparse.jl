module t001
using Random
using SparseArrays
using SimplySparse
using SortingAlgorithms
using SortingLab
using DataDrop
using Test

function test()
    data = DataDrop.retrieve_matrix(joinpath(pwd(), "test", "J.h5"))
    # data = [5, 2, 3, 3, 1, 60, 7, 44]


    v = deepcopy(data)
    prm = collect(1:length(v))
    @time sort!(prm, Base.Sort.DEFAULT_UNSTABLE, Base.Order.Perm(Base.Order.Forward, v))
    # @show prm

    v = deepcopy(data)
    prm = collect(1:length(v))
    @time SortingLab.sorttwo!(v, prm);

    # v = deepcopy(data)
    # @time p = fsortperm(v);
    # @show p

    # v = deepcopy(data)
    # @time SortingAlgorithms.sort!(prm, alg=HeapSort, Base.Order.Perm(Base.Order.Forward, v))
    # v = deepcopy(data)
    # @time SortingAlgorithms.sort!(prm, alg=CombSort, Base.Order.Perm(Base.Order.Forward, v))
end


test()


nothing

end # module
