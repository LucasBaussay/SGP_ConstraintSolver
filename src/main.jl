include("Constraint.jl")
include("Variables.jl")

function getFiltrableModel(model::Vector{Constraint})
	
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

	setOfConstraint = getFiltrableModel(model)
	solution = Solution()
	
	while setOfConstraint != Set{Constraint}()
	
		verbose && println("N° de contraintes : $(length(setOfConstraint))")
	
		constr = pop!(setOfConstraint)
		
		modifiedVariables = constr.filtrage!()
		union!(setOfConstraint, modifiedVariables.linkedConstraint)
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

function main(model::Model, verbose::Bool = false)

	

end
