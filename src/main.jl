include("Constraint.jl")
include("Variables.jl")
include("Solution.jl")

include("Change.jl")

include("Model.jl")

include("Preprocessing.jl")

mutable struct Compteur
	ind::Int
end

function Arc_Consistency(model::Model, setOfConstraint::Union{Set{Constraint}, Nothing} = nothing; verbose::Bool = false)

	stop = false

	if setOfConstraint == nothing
		setOfConstraint = copy(model.constraints)
	end
	dictChanges = Dict{Variable, Change}(var => Change(var) for var in model.varsInter)

	for g in 1:model.g
		for w in 1:model.w
			dictChanges[model.X[g, w]] = Change(model.X[g, w])
		end
	end

	while !isempty(setOfConstraint) && !stop

		verbose && println("N° de contraintes : $(length(setOfConstraint))")

		constr = pop!(setOfConstraint)

		modifiedVariables, changes, stop = filtrage!(constr)

		for change in changes
			union!(dictChanges[change.var].added, change.added)
			union!(dictChanges[change.var].removed, change.removed)

			dictChanges[change.var].cardAdded += change.cardAdded
			dictChanges[change.var].cardRemoved += change.cardRemoved

			dictChanges[change.var].fixed |= change.fixed

			stop |= change.cardAdded < 0
			stop |= change.cardRemoved > 0
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

	vars = append!([model.X[g, w] for g in 1:model.g for w in 1:model.w], model.varsInter)

	for var in vars
		if isFixed(var) && !var.isFixed
			fix!(var, dictChanges[var])
		end
	end

	filter!(var-> !(var.isFixed), model.varsNotFixed)

	# !stop && println("Yo : ", map(x->x.cardAdded, values(dictChanges)))


	return dictChanges, stop
end

#TODO
#
# Je doids gérer le cas d'erreur -> SI on tombre sur une solution non faisable ca fait quoi
# Faire les fonctions unforced, returnParent, Solution(model)

function branch(model = ModelTest(); nbAppel::Int = 1, verbose::Bool = false, debug::Real = Inf, compteur::Compteur = Compteur(0))


	# println("N° : ", compteur.ind)
	filter!(var-> !(var.isFixed), model.varsNotFixed)

	changes = Dict{Variable, Change}()
	changes, stop = Arc_Consistency(model)

	if stop
		returnParent!(changes, model)
		return nothing, false
	else
	@assert compteur.ind <= debug "Mwahahaahahahahhahahahaha"


		# println("Profondeur : $nbAppel")

		mini = Inf
		varToTest = nothing
		indVar = 1

		nbVarToTest = length(model.varsNotFixed)

		if nbVarToTest > 0

			while indVar <= nbVarToTest && mini > 1
				var = model.varsNotFixed[indVar]
				if length(var.upperBound) - length(var.lowerBound) < mini
					mini = length(var.upperBound) - length(var.lowerBound)
					varToTest = var
				end
				indVar += 1
			end

			valueToTest = union(setdiff(varToTest.upperBound, varToTest.lowerBound), [nothing])
			nbValueToTest = length(valueToTest)
			sol = nothing
			stop = false
			indValue = 1

			# println("_______________")
			# println("Variable : ", varToTest)
			# println("Valeurs : ", valueToTest)
			# println("_______________")

			while !stop && indValue <= nbValueToTest
				value = valueToTest[indValue]

				if value != nothing || varToTest.cardinalInf == length(varToTest.lowerBound)
					if value == nothing || value in varToTest.upperBound
						#println()
						#println("On force $varToTest à $value")

						changeForce = forced!(varToTest, value, model)
						# println("$varToTest : $(varToTest.lowerBound)")

						# println("	"^(nbAppel-1), "lowerBound : ", varToTest.lowerBound)
						# println("	"^(nbAppel-1), "upperBound : ", varToTest.upperBound)

						compteur.ind += 1
						sol, stop = branch(model, nbAppel = nbAppel + 1, compteur = compteur, debug = debug)
						#println()
						#println("On déforce $varToTest pour $value")

						# println("	"^(nbAppel-1), "Après")
						# println("	"^(nbAppel-1), "lowerBound : ", varToTest.lowerBound)
						# println("	"^(nbAppel-1), "upperBound : ", varToTest.upperBound)
						# println()
						# println("	"^(nbAppel-1), sol, " - ", stop)

						unforced!(varToTest, changeForce, model)



					end
				end
				indValue += 1
			end
			returnParent!(changes, model)
			return sol, stop
		else
			return Solution(model), true
		end
	end



end


function modelFixed()
	model = main()
	model.X[1, 1].lowerBound = [1, 2, 3]
	model.X[2, 1].lowerBound = [4, 5, 6]
	model.X[3, 1].lowerBound = [7, 8, 9]
	model.X[4, 1].lowerBound = [10, 11, 12]

	model.X[1, 1].upperBound = [1, 2, 3]
	model.X[2, 1].upperBound = [4, 5, 6]
	model.X[3, 1].upperBound = [7, 8, 9]
	model.X[4, 1].upperBound = [10, 11, 12]

	for x in model.X[:, 1]
		x.isFixed = true
	end
	model.X[4, 1].isFixed = false

	model.varsInter[1].lowerBound = [1, 2, 3, 4, 5, 6]
	model.varsInter[2].lowerBound = [1, 2, 3, 4, 5, 6, 7, 8, 9]
	model.varsInter[3].lowerBound = [1, 2, 3, 4, 5, 6 ,7, 8, 9, 10, 11 ,12]

	model.varsInter[1].upperBound = [1, 2, 3, 4, 5, 6]
	model.varsInter[2].upperBound = [1, 2, 3, 4, 5, 6, 7, 8, 9]
	model.varsInter[3].upperBound = [1, 2, 3, 4, 5, 6 ,7, 8, 9, 10, 11 ,12]

	for f in model.varsInter
		f.isFixed = true
	end

	return model
end

function debug(ind::Int)
	model = ModelTest(6, 3, 2)

	try
		test = branch(model, debug = ind)
	catch y
		println(y)
	end
	return model
end

function main(p = 4, g = 2, w = 2)
	model = ModelTest(p, g, w)

	preprocessing(model)
	sol, stop = branch(model)

	return sol, stop
end
