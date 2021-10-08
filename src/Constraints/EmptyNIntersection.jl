"""

	X_1 Inter X_2 Inter ... Inter X_n = Ensemble vide
	
"""

struct EmptyNIntersection <: Constraint
	
	X::Vector{Variable}
	
	filtrage::Function
	
end

isFiltrable(::EmptyNIntersection) = false
