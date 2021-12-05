include("Constraint.jl")
include("Variables.jl")
include("Solution.jl")

include("Change.jl")

include("Model.jl")

function getFiltrableModel(model::Model)

	setOfConstraint = Set{Constraint}()

	for constr in model.constraints
		if isFiltrable(constr)
			if isRewritable(constr)
				push!(setOfConstraint, rewrite(constr))
			else
				push!(setOfConstraint, constr)
			end
		else
			error("The constraint $(typeof(constr)) is not handled") #Bof on s'en fout
		end
	end

	return setOfConstraint
end

function Arc_Consistency(model::Model, verbose::Bool = false)

	setOfConstraint = copy(model.constraints)
	solution = Solution()
	dictChanges = Dict{Variable, Change}(var => Change(var) for var in model.varsInter)

	for g in 1:model.g
		for w in 1:model.w
			dictChanges[model.X[g, w]] = Change(model.X[g, w])
		end
	end

	while !isempty(setOfConstraint)

		verbose && println("N° de contraintes : $(length(setOfConstraint))")

		constr = pop!(setOfConstraint)

		modifiedVariables, changes = filtrage!(constr)

		for change in changes
			union!(dictChanges[change.var].added, change.added)
			union!(dictChanges[change.var].removed, change.removed)
		end

		for var in modifiedVariables
			union!(setOfConstraint, var.linkedConstraint)
		end

	end
	#=
	if modelNotFixed(model)
		println("WIP : Branch-And-Bound")
	elseif isEmpty(model)
		return solution
	else
		solution = createSolution(model)
	end

	return solution
	=#

	return dictChanges
end

function main(p::Int = 12, g::Int = 4, w::Int = 1; verbose::Bool = false)

	model = ModelTest(p, g, w)

end

function branch(model = ModelTest())



end
