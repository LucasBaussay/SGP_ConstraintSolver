include("../Constraint.jl")

struct SortGroups <: Constraint

    UpGroup::Variable
    DownGroup::Variable

    filtrage!::Function

end

isFiltrable(::SortGroups) = false

function filtrageGroups!(UpGroup, DownGroup)

    #### filtering DownGroup

    # v : minimum element of UpGroup.upperBound
    v = minimum(UpGroup.upperBound)
    # si ordonné, v = UpGroup.upperBound[1]

    c = 0
    n_UB = copy(DownGroup.upperBound)

    for e in 1:length(DownGroup.upperBound)
        if DownGroup.upperBound[e] <= v
            deleteat!(n_UB, e-c)
            c += 1
        end
    end

    DownGroup.upperBound = n_UB

    #DownGroup.cardinalSup -= c

    ####

    #### filtering UpGroup


    ####

    @assert UpGroup.cardinalInf <= UpGroup.cardinalSup "Infeasible Problem : $UpGroup has a problem"
	@assert DownGroup.cardinalInf <= DownGroup.cardinalSup "Infeasible Problem : $DownGroup has a problem"
end

function quoi()
    v1 = Variable("v1", [5,9], [2,5,9,11], 4, 4, Set([]), false)
    v2 = Variable("v2", [7,10], [1,2,4,5,7,10], 4, 4, Set([]), false)
    println(v2.upperBound)
    filtrageGroups!(v1,v2)
    println(v2.upperBound)
end