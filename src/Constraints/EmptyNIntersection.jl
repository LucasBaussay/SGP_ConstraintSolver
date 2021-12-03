
"""

	X_1 ∩ X_2 ∩ ... ∩ X_n = ∅

"""

struct EmptyNIntersection <: Constraint

	X::Vector{Variable}

end

function EmptyNIntersection(m::Model, X::Vector{Variable})

	#push!(m.varsInter, Variable(1:m.p, "F[$(length(m.varsInter)+1)]"))
	Variable(model, 1:m.p, "F[$(length(m.varsInter)+1)]")
	Intersection(m, m.varsInter[end], X[1], X[2])

	for ind in 3:(length(X)-1)
		# push!(m.varsInter, Variable(1:m.p, "F[$(length(m.varsInter)+1)]"))
		Variable(model, 1:m.p, "F[$(length(m.varsInter)+1)]")
		Intersection(m, m.varsInter[end], m.varsInter[end-1], X[ind])
	end

	EmptyIntersection(m, m.varsInter[end], X[end])

	m.varsInter[end-(length(X)-2):end]

end
