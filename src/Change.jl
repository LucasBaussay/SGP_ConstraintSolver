mutable struct Change

    var::Variable
    added::Set{Int}
    removed::Set{Int}

    fixed::Bool
end

function Change(var::Variable)

    return Change(var,
                    Set{Int}(),
                    Set{Int}(),
                    false)
end
