struct Change

    var::Variable
    added::Set{Int}
    removed::Set{Int}

end

function Change(var::Variable)

    return Change(var,
                    Set{Int}(),
                    Set{Int}())
end
