mutable struct Change

    var
    added::Set{Int}
    removed::Set{Int}

    fixed::Bool
    cardAdded::Int
    cardRemoved::Int
end

function Change(var)

    return Change(var,
                    Set{Int}(),
                    Set{Int}(),
                    false,
                    0,
                    0)
end
