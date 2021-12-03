mutable struct Variable

	name::String

	lowerBound::Vector{Int}
	upperBound::Vector{Int}

	cardinalInf::Int
	cardinalSup::Int

	linkedConstraint::Set{Constraint}

	isFixed::Bool# <=> upperBound == lowerBound

end

import Base.show
function Base.show(io::IO, var::Variable)
	print(io, var.name)
end

function Variable(model, domain, name::String = "X")
	var = Variable(domain, name)
	push!(model.varsInter, var)

	var
end

function Variable(domain::UnitRange{Int}, name::String = "X")
	return Variable(collect(domain), name)
end

function Variable(domain::Vector{Int}, name::String = "X")

	lb = Vector{Int}()
	ub = domain[:]

	cardinalInf = 0
	cardinalSup = length(domain)

	linkedConstraint = Set{Constraint}()

	return Variable(name,
					lb,
					ub,
					cardinalInf,
					cardinalSup,
					linkedConstraint,
					false)

end
