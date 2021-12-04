include("../Constraint.jl")

struct SortWeeks <: Constraint

    LeftGroup::Variable
    RightGroup::Variable

    filtrage!::Function

end

isFiltrable(::SortWeeks) = false

function filtrageWeeks!(LeftGroup, RightGroup)
    #### filtering LeftGroup

    # v : element max de RightGroup.lowerBound
    v = maximum(RightGroup.lowerBound)

    c = 0
    n_UB = copy(LeftGroup.upperBound)
    
    for e in 1:length(LeftGroup.upperBound)
        if LeftGroup.upperBound[e] >= v
            deleteat!(n_UB, e-c)
            c += 1
        end
    end

    LeftGroup.upperBound = n_UB

    ####

    #### filtering RightGroup


    ####

    @assert LeftGroup.cardinalInf <= LeftGroup.cardinalSup "Infeasible Problem : $LeftGroup has a problem"
	@assert RightGroup.cardinalInf <= RightGroup.cardinalSup "Infeasible Problem : $RightGroup has a problem"
end

function quoi()
    v1 = Variable("v1", [1,4,8], [1,4,6,8,9,12], 4, 4, Set([]), false)
    v2 = Variable("v2", [1,7,10], [1,5,7,8,10,12,14], 4, 4, Set([]), false)
    println(v1.upperBound)
    filtrageWeeks!(v1,v2)
    println(v1.upperBound)
end