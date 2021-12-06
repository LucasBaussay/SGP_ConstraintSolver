struct Solution
    X::Array{Set{Int}, 2}
end

function Solution(model::Model)
    @assert length(model.varsNotFixed) == 0 "Mais il se passe quoi là ..."

    X = Array{Set{Int}, 2}(undef, model.g, model.w)

    for g in 1:model.g
        for w in 1:model.w
            X[g, w] = model.X[g, w].lowerBound
        end
    end

    return Solution(X)
end
