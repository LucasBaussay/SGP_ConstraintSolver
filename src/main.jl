include("Constraint.jl")
include("Variables.jl")
include("Solution.jl")

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

	while !isempty(setOfConstraint)

		verbose && println("N° de contraintes : $(length(setOfConstraint))")

		constr = pop!(setOfConstraint)

		modifiedVariables = filtrage!(constr)
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
end

function main(p::Int = 12, g::Int = 4, w::Int = 1; verbose::Bool = false)

	model = ModelTest(p, g, w)

end
