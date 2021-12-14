struct SortGroups <: Constraint

    UpGroup::Variable
    DownGroup::Variable

end

function SortGroups(model, UpGroup, DownGroup)
    constraint = SortGroups(UpGroup, DownGroup)

    push!(UpGroup.linkedConstraint, constraint)
    push!(DownGroup.linkedConstraint, constraint)

    push!(model.constraints, constraint)
end

function filtrage!(groups::SortGroups)

    changeVariable = Vector{Variable}(undef, 3)
    nbChange = 0

    changeUp = Change(groups.UpGroup)
    changeDown = Change(groups.DownGroup)

    #### filtering DownGroup

    if !groups.DownGroup.isFixed
        # v : minimum element of UpGroup.upperBound
        v = minimum(groups.UpGroup.upperBound)

        c = 0
        n_UB = copy(groups.DownGroup.upperBound) # new Upper Bound

        changed = false
        for e in 1:length(groups.DownGroup.upperBound)
            if groups.DownGroup.upperBound[e] <= v # élément plus petit que le plus petit élément possible d'un groupe au dessus => ne peut pas être placé
                deleteat!(n_UB, e-c)
                c += 1

                push!(changeDown.removed, groups.DownGroup.upperBound[e])
                changed = true
            end
        end

        if changed
            nbChange += 1
            changeVariable[nbChange] = groups.DownGroup
        end

        groups.DownGroup.upperBound = n_UB

        cardSup = min(groups.DownGroup.cardinalSup, length(groups.DownGroup.upperBound))
        changeDown.cardRemoved = cardSup - groups.DownGroup.cardinalSup

        groups.DownGroup.cardinalSup += changeDown.cardRemoved
    end

    ####################################################################################

    #### filtering UpGroup
    if length(groups.DownGroup.lowerBound) > 0 && length(groups.UpGroup.lowerBound) > 0
        v = minimum(groups.DownGroup.lowerBound)
        w = minimum(groups.UpGroup.lowerBound)

        if !groups.UpGroup.isFixed && groups.UpGroup.cardinalSup - length(groups.UpGroup.lowerBound) == 1 && v < w # il ne reste plus qu'un élément à placer

            c = 0
            n_UB = copy(groups.UpGroup.upperBound)
            changed = false
            for e in 1:length(groups.UpGroup.upperBound)
                if groups.UpGroup.upperBound[e] > v && !(groups.UpGroup.upperBound[e] in groups.UpGroup.lowerBound)
                    deleteat!(n_UB, e-c)
                    c += 1

                    push!(changeUp.removed, groups.UpGroup.upperBound[e])
                    changed = true
                end
            end

            if changed
                nbChange += 1
                changeVariable[nbChange] = groups.UpGroup
            end

            groups.UpGroup.upperBound = n_UB

            cardSup = min(groups.UpGroup.cardinalSup, length(groups.DownGroup.upperBound))
            changeUp.cardRemoved = cardSup - groups.UpGroup.cardinalSup

            groups.UpGroup.cardinalSup += changeUp.cardRemoved
        end
    end

    ####################################################################################

    stop = groups.UpGroup.cardinalInf > groups.UpGroup.cardinalSup
	stop |= groups.DownGroup.cardinalInf > groups.DownGroup.cardinalSup

    return changeVariable[1:nbChange], (changeUp, changeDown), stop
end

function quoi()
    v1 = Variable("v1", [8,10,11], [3,6,8,9,10,11,13], 4, 4, Set([]), false)
    v2 = Variable("v2", [7,14,16], [5,7,12,14,15,16], 4, 4, Set([]), false)
    println(v1.upperBound)
    println(v2.upperBound)
    model = ModelTest()
    sg = SortGroups(v1,v2)
    println(sg)
    filtrage!(sg)
    println(v1.upperBound)
    println(v2.upperBound)
end
