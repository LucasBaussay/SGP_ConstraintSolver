include("Constraint.jl")

mutable struct Variable

	lowerBound::Vector{Int}
	upperBound::Vector{Int}
	
	cardinalInf::Int
	cardinalSup::Int
	
	linkedConstraint::Vector{Constraint}
	
	isFixed::Bool

end
