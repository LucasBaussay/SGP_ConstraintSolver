struct SortGroups <: Constraint

    UpGroup::Variable
    DownGroup::Variable

    filtrage!::Function

end

isFiltrable(::SortGroups) = false

function filtrageGroups!(UpGroup, DownGroup)

    #### filtering DownGroup

    # v : minimum element of UpGroup.upperBound
    v = min(UpGroup.upperBound)
    # si ordonné, v = UpGroup.upperBound[1]

    c = 0
    for e in DownGroup.upperBound
        if e <= v
            deleteat!(DownGroup.upperBound, findfirst(isequal(e)))
            c += 1
        end
    end

    DownGroup.cardinalSup -= c

    ####

    #### filtering UpGroup


    ####

    @assert UpGroup.cardinalInf <= UpGroup.cardinalSup "Infeasible Problem : $UpGroup has a problem"
	@assert DownGroup.cardinalInf <= DownGroup.cardinalSup "Infeasible Problem : $DownGroup has a problem"
end