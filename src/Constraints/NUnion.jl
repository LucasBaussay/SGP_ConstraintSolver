"""

	X_1 ∪ X_2 ∪ ... ∪ X_n = {1, ..., p}
	
"""

struct NUnion <: Constraint

	X::Vector{Variable}
	p::Int
	
	filtrage!::Function
	
end

isFiltrable(::NUnion) = false
