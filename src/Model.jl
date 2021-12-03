struct Model

	X::Array{Variable, 2}
	varsInter::Vector{Variable}

	constraints::Set{Constraint}

	p::Int
	g::Int
	w::Int

end

import Base.show
function Base.show(io::IO, model::Model)

	println(io, "Liste des variables : ")
	if (model.g*model.w + length(model.varsInter) <= 10)
		for g in 1:model.g
			for w in 1:model.w
				println(io, "      ", model.X[g, w])
			end
		end
		for var in model.varsInter
			println(io, "      ", var)
		end
	else
		if model.g * model.w <= 8
			for g in 1:model.g
				for w in 1:model.w
					println(io, "      ", model.X[g, w])
				end
			end
			for i in 1:(8 - model.g*model.w)
				println(io, "      ", model.varsInter[i])
			end
		else
			g = 1
			w = 1
			ind = 1
			while ind <= 8
				println(io, "      ", model.X[g, w])
				w += 1
				if w > model.w
					w = 1
					g += 1
				end
			end
		end
		println(io, "      ", "...")
	end
	if model.constraints != Set{Constraint}()
		println(io)
		println(io, "Liste des contraintes : ")
		constr = collect(model.constraints)
		if length(constr) <= 10
			for constraint in model.constraints
				println(io, "      ", constraint)
			end
		else
			for ind in 1:8
				println(io, "      ", constr[ind])
			end
			println(io, "      ", "...")
		end

	end

end

#dict{Variable, Set{Constraint}}
"""
function Model_v1(p::Int, g::Int, w::Int)

	q = p ÷ g

	X = Array{Variable, 2}(undef, g, w)
	constraints = Set{Constraint}()

	for ind1 in 1:g
		for ind2 in 1:w
			X[ind1, ind2] = VariableGroupe(p, q)
		end
	end

	nInter = []
	nUnion = []

	for indW in 1:w
		for indG in 1:g
			fixCardinalite!(X[indG, indW], q)
		end

		push!(nInter, EmptyNIntersection(X[1:g, indW])
		push!(nUnion, NUnion(X[1:g, indW], p))

"""

function ModelTest(p::Int = 12, g::Int = 4, w::Int = 1)
	q = p ÷ g

	X = Array{Variable, 2}(undef, g, w)
	constraints = Set{Constraint}()

	for ind1 in 1:g
		for ind2 in 1:w
			X[ind1, ind2] = Variable(1:p, "X[$(ind1), $(ind2)]")
		end
	end

	model = Model(X,
				Vector{Variable}(),
				Set{Constraint}(),
				p, g, w)


	for indW in 1:w

		for indG in 1:g
			Cardinalite(model, X[indG, indW], q)
		end

		NDisjointUnion(model, X[1:end, indW], 1:p)

		for indG1 in 1:(g-1)
			for indG2 in (indG1+1):g
				EmptyIntersection(model, X[indG1, indW], X[indG2, indW])
			end
		end
	end

	for indW1 in 1:(w-1)
		for indW2 in (indW1+1):w
			for indG1 in 1:g
				for indG2 in 1:g

					Social(model, X[indG1, indW1], X[indG2, indW2])
				end
			end
		end
	end

	return model

end
