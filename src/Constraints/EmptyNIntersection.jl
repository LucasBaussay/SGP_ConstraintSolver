"""

	X_1 ∩ X_2 ∩ ... ∩ X_n = ∅
	
"""

struct EmptyNIntersection <: Constraint
	
	X::Vector{Variable}
	
	filtrage!::Function
	
end

isFiltrable(::EmptyNIntersection) = false

function EmptyNIntersection(X)
	return EmptyNIntersection(X, 
								filtrage)
end
