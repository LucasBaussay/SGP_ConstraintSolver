include("Constraint.jl")

mutable struct Variable

	lowerBound::Vector{Int}
	upperBound::Vector{Int}
	
	cardinalInf::Int
	cardinalSup::Int
	
	linkedConstraint::Set{Constraint}
	
	isFixed::Bool# <=> upperBound == lowerBound

end

function Variable(domain::Vector{Int})

	lb = Vector{Int}()
	ub = domain[:]
	
	cardinalInf = 0
	cardinalSup = length(domain)
	
	linkedConstraint = Set{Constraint}()
	
	return Variable(lb,
					ub,
					cardinalInf,
					cardinalSup,
					linkedConstraint,
					false)

end
