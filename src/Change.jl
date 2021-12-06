mutable struct Change

    var::Variable
    added::Set{Int}
    removed::Set{Int}

    fixed::Bool
    cardAdded::Int
    cardRemoved::Int
end

function Change(var::Variable)

    return Change(var,
                    Set{Int}(),
                    Set{Int}(),
                    false,
                    0,
                    0)
end
