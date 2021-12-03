"""

	X_1 ∪ X_2 ∪ ... ∪ X_n = {1, ..., p}

"""

#TODO : supprimer cette structure
struct NDisjointUnion <: Constraint

	X::Vector{Variable}
	domain::Vector{Int}

end

function NDisjointUnion(m::Model, X::Vector{Variable}, domain::UnitRange{Int})
	return NDisjointUnion(m, X, collect(domain))
end

function NDisjointUnion(m::Model, X::Vector{Variable}, domain::Vector{Int})

	#push!(m.varsInter, Variable(1:m.p, "F[$(length(m.varsInter)+1)]"))
	#push!(m.constraints, DisjointUnion(m.varsInter[end], X[1], X[2]))
	Variable(m, 1:m.p, "F[$(length(m.varsInter)+1)]")
	DisjointUnion(m, m.varsInter[end], X[1], X[2])

	for ind in 3:length(X)
		#push!(m.varsInter, Variable(1:m.p, "F[$(length(m.varsInter)+1)]"))
		#push!(m.constraints, DisjointUnion(m.varsInter[end], m.varsInter[end-1], X[ind]))

		Variable(m, 1:m.p, "F[$(length(m.varsInter)+1)]")
		DisjointUnion(m, m.varsInter[end], m.varsInter[end-1], X[ind])
	end

	m.varsInter[end].lowerBound = domain
	m.varsInter[end].upperBound = domain
	m.varsInter[end].cardinalSup = length(domain)
	m.varsInter[end].cardinalInf = length(domain)
	m.varsInter[end].isFixed = true

	m.varsInter[end-(length(X)-2):end]

end
