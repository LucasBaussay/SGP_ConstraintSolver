"""

	| F | <= 1
	
"""

struct AtMostOne <: Constraint

	F::Variable
	
	filtrage::Function
	
end

isFiltrable(::AtMostOne) = false
