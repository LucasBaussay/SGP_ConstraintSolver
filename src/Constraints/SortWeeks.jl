struct SortWeeks <: Constraint

    LeftGroup::Variable
    RightGroup::Variable

    filtrage!::Function

end

isFiltrable(::SortWeeks) = false

function filtrageWeeks!(LeftGroup, RightGroup)
    #### filtering LeftGroup

    # v : element max de RightGroup.lowerBound
    v = max(RightGroup.lowerBound)

    c = 0
    for e in LeftGroup.upperBound
        if e >= v
            deleteat!(LeftGroup.upperBound, findfirst(isequal(e)))
            c += 1
        end
    end

    ####

    #### filtering RightGroup


    ####

    @assert LeftGroup.cardinalInf <= LeftGroup.cardinalSup "Infeasible Problem : $LeftGroup has a problem"
	@assert RightGroup.cardinalInf <= RightGroup.cardinalSup "Infeasible Problem : $RightGroup has a problem"
end