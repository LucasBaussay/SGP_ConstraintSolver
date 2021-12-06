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

	if (var.cardinalInf == length(var.upperBound))
		add = setdiff(var.upperBound, var.lowerBound)

		for elt in add
			push!(change.added, elt)
		end
		union!(var.lowerBound, add)
		change.cardRemoved += vars.cardinalInf - var.cardinalSup
		var.cardinalSup = var.cardinalInf
	else
		rem = setdiff(var.upperBound, var.lowerBound)
		for elt in rem
			push!(change.removed, elt)
		end
		setdiff!(var.upperBound, rem)
		change.cardAdded += var.cardinalSup - var.cardinalInf
		var.cardinalInf = var.cardinalSup
	end

	var.isFixed = true
	change.fixed = true


	var
end

function forced!(var::Variable, value::Union{Int, Nothing})

	change = Change(var)

	if value == nothing
		cardSup = var.cardinalInf - var.cardinalSup
		var.cardinalSup += cardSup
		change.cardRemoved += cardSup

		rem = setdiff(var.upperBound, var.lowerBound)
		for elt in rem
			push!(change.removed, elt)
		end
		setdiff!(var.upperBound, rem)

		change.fixed = true

	else

		union!(var.lowerBound, [value])
		push!(change.added, value)
		cardInf = max(length(var.lowerBound), var.cardinalInf)

		change.cardAdded += cardInf - var.cardinalInf
		var.cardinalInf += change.cardAdded

		if isFixed(var)
			fix!(var, change)
		end
	end
	return change
end

function unforced!(var::Variable, change::Change)

	if change.fixed
		var.isFixed = false
	end

	union!(var.upperBound, change.removed)
	setdiff!(var.lowerBound, change.added)

	var.cardinalInf -= change.cardAdded
	var.cardinalSup -= change.cardRemoved

	var

end




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
