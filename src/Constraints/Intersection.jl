"""

	F = G Inter H
	
"""

struct Intersection <: Constraint
	
	F::Variable
	G::Variable
	H::Variable
	
	filtrage::Function

end

isFiltrable(::Intersection) = false
