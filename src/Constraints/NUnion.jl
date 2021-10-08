"""

	X_1 Union X_2 Union ... Union X_n = {1, ..., p}
	
"""

struct NUnion <: Constraint

	X::Vector{Variable}
	p::Int
	
	filtrage::Function
	
end

isFiltrable(::NUnion) = false
