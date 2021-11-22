struct Model

	X::Array{Variable, 2}
	varsInter::Vector{Variable}
	
	constraints::Set{Constraint}
	
end

#dict{Variable, Set{Constraint}}

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

		
