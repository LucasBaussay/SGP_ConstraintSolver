mutable struct Variable

	name::String

	lowerBound::Vector{Int}
	upperBound::Vector{Int}

	cardinalInf::Int
	cardinalSup::Int

	linkedConstraint::Set{Constraint}

	isFixed::Bool# <=> upperBound == lowerBound

end

function isFixed(var::Variable)
	return (var.cardinalInf == length(var.upperBound) || var.cardinalSup == length(var.lowerBound))
end

function fix!(var::Variable, change::Change)

	if (var.cardinalInf == length(var.upperBound)
		add = setdiff(var.upperBound, var.lowerBound)
		for elt in add
			push!(change.added, elt)
		end
		union!(var.lowerBound, add)
		var.cardinalSup = var.cardinalInf
	else
		rem = setdiff(var.upperBound, var.lowerBound)
		for elt in rem
			push!(change.removed, elt)
		end
		setdiff!(var.upperBound, rem)
		var.cardinalInf = var.cardinalSup
	end

	var.isFixed = true
	change.fixed = true


	var
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
