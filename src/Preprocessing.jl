function preprocessing(model::Model)

    ## Fixing 1st week

    q = model.p ÷ model.g

    for i in 1:model.g
        sol = Vector{Int}(undef, q)
        for j in 1:q
            sol[j] = (i-1)*q + j
        end
        model.X[i,1].upperBound = sol
        model.X[i,1].lowerBound = sol
        fix!(model.X[i, 1], Change(model.X[i, 1]))
    end

    ## model.X[i,1].isFixed = true (??)

    ## Fixing 1st element of first q groups (or g if g < q, but the problem is infeasible when w > 1)

    for i in 2:model.w
        for j in 1:min(q,model.g)
            push!(model.X[j,i].lowerBound, j)
        end
    end
end

function quoi()
    model = ModelTest()
    preprocessing(model)
end
