struct SortWeeks <: Constraint

    LeftGroup::Variable
    RightGroup::Variable

end

function SortWeeks(model, LeftGroup, RightGroup)
    constraint = SortWeeks(LeftGroup, RightGroup)

    push!(LeftGroup.linkedConstraint, constraint)
    push!(RightGroup.linkedConstraint, constraint)

    push!(model.constraints, constraint)
end

function filtrage!(weeks::SortWeeks)

    changeVariable = Vector{Variable}(undef,3)
    nbChange = 0

    changeLeft = Change(weeks.LeftGroup)
    changeRight = Change(weeks.RightGroup)

    #### filtering LeftGroup

    if !weeks.LeftGroup.isFixed
        # v : element max de RightGroup.upperBound
        v = maximum(weeks.RightGroup.upperBound)

        c = 0
        n_UB = copy(weeks.LeftGroup.upperBound)
        changed = false

        for e in 1:length(weeks.LeftGroup.upperBound)
            if weeks.LeftGroup.upperBound[e] >= v
                deleteat!(n_UB, e-c)
                c += 1

                push!(changeLeft.removed, weeks.LeftGroup.upperBound[e])
                changed = true
            end
        end

        if changed
            nbChange += 1
            changeVariable[nbChange] = weeks.LeftGroup
        end

        weeks.LeftGroup.upperBound = n_UB

        cardSup = min(weeks.LeftGroup.cardinalSup, length(weeks.LeftGroup.upperBound))
        changeLeft.cardRemoved = cardSup - weeks.LeftGroup.cardinalSup

        weeks.LeftGroup.cardinalSup += changeLeft.cardRemoved
    end

    ##########################################################################################

    #### filtering RightGroup
    if length(weeks.LeftGroup.lowerBound) >0 && length(weeks.RightGroup.lowerBound) > 0
        v = maximum(weeks.LeftGroup.lowerBound)
        w = maximum(weeks.RightGroup.lowerBound)

        if !weeks.RightGroup.isFixed && weeks.RightGroup.cardinalSup - length(weeks.RightGroup.lowerBound) == 1 && v > w

            c = 0
            n_UB = copy(weeks.RightGroup.upperBound)
            changed = false
            for e in 1:length(weeks.RightGroup.upperBound)
                if weeks.RightGroup.upperBound[e] < v && !(weeks.RightGroup.upperBound[e] in weeks.RightGroup.lowerBound)
                    deleteat!(n_UB, e-c)
                    c += 1

                    push!(changeRight.removed, weeks.RightGroup.upperBound[e])
                    changed = true
                end
            end

            if changed
                nbChange += 1
                changeVariable[nbChange] = weeks.RightGroup
            end

            weeks.RightGroup.upperBound = n_UB

            cardSup = min(weeks.RightGroup.cardinalSup, length(weeks.RightGroup.upperBound))
            changeRight.cardRemoved = cardSup - weeks.RightGroup.cardinalSup

            weeks.RightGroup.cardinalSup += changeRight.cardRemoved
        end
    end


    ###################################################################################################

    stop = weeks.LeftGroup.cardinalInf > weeks.LeftGroup.cardinalSup
	stop |= weeks.RightGroup.cardinalInf > weeks.RightGroup.cardinalSup

    return changeVariable[1:nbChange], (changeLeft, changeRight), stop
end

function quoi()
    v1 = Variable("v1", [1,12], [1,3,4,6,10,12,14], 4, 4, Set([]), false)
    v2 = Variable("v2", [1,5,10], [1,5,9,10,11,13,16], 4, 4, Set([]), false)
    println(v1.upperBound)
    println(v2.upperBound)
    model = ModelTest()
    sg = SortWeeks(v1,v2)
    println(sg)
    filtrage!(sg)
    println(v1.upperBound)
    println(v2.upperBound)
end
