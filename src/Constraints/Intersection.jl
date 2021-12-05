"""

	F = G ∩ H

"""

struct Intersection <: Constraint

	F::Variable
	G::Variable
	H::Variable

end

import Base.show
function Base.show(io::IO, inter::Intersection)
	print(io, inter.F.name * " = " * inter.G.name * " ∩ " * inter.H.name)
end

function Intersection(model::Model, F, G, H)
	constraint = Intersection(F, G, H)
	push!(F.linkedConstraint, constraint)
	push!(G.linkedConstraint, constraint)
	push!(H.linkedConstraint, constraint)

	push!(model.constraints, constraint)

	constraint
end

function filtrage!(inter::Intersection)

	changeVariable = Vector{Variable}(undef, 3)
	nbChange = 0

	changeF = Change(inter.F)
	changeG = Change(inter.G)
	changeH = Change(inter.H)

	#Set
	if !inter.F.isFixed

		rem = setdiff(inter.F.upperBound, intersect(inter.G.upperBound, inter.H.upperBound))
		add = setdiff(intersect(inter.G.lowerBound, inter.H.lowerBound), inter.F.lowerBound)

		if !(isempty(rem) && isempty(add))
			nbChange += 1
			changeVariable[nbChange] = inter.F

			if isFixed(inter.F)
				fix!(inter.F, changeF)
			end
		end

		setdiff!(inter.F.upperBound, rem)
		union!(inter.F.lowerBound, add)

		for elt in add
			push!(changeF.added, added)
		end
		for elt in rem
			push!(changeF.removed, rem)
		end

		inter.F.cardinalInf = max(inter.F.cadinalInf, length(inter.F.lowerBound))
		inter.F.cardinalSup = min(inter.F.cardinalSup, length(inter.F.upperBound), inter.G.cardinalSup, inter.H.cardinalSup)
	end

	if !inter.G.isFixed

		rem = intersect(inter.G.upperBound, setdiff(inter.H.lowerBound, inter.F.upperBound))
		add = setdiff(inter.F.lowerBound, inter.G.lowerBound)

		if !(isempty(rem) && isempty(add))
			nbChange += 1
			changeVariable[nbChange] = inter.G

			if isFixed(inter.G)
				fix!(inter.G, changeG)
			end
		end

		setdiff!(inter.G.upperBound, rem)
		union!(inter.G.lowerBound, add)

		for elt in add
			push!(changeG.added, added)
		end
		for elt in rem
			push!(changeG.removed, rem)
		end

		inter.G.cardinalInf = max(inter.G.cadinalInf, length(inter.G.lowerBound), inter.F.cardinalInf)
		inter.G.cardinalSup = min(inter.G.cardinalSup, length(inter.G.upperBound))
	end

	if !inter.H.isFixed
		rem = intersect(inter.H.upperBound, setdiff(inter.G.lowerBound, inter.F.upperBound))
		add = setdiff(inter.F.lowerBound, inter.H.lowerBound)

		if !(isempty(rem) && isempty(add))
			nbChange += 1
			changeVariable[nbChange] = inter.H

			if isFixed(inter.H)
				fix!(inter.H, changeH)
			end
		end

		setdiff!(inter.H.upperBound, rem)
		union!(inter.H.lowerBound, add)

		for elt in add
			push!(changeH.added, added)
		end
		for elt in rem
			push!(changeH.removed, rem)
		end

		inter.H.cardinalInf = max(inter.H.cadinalInf, length(inter.H.lowerBound), inter.F.cardinalInf)
		inter.H.cardinalSup = min(inter.H.cardinalSup, length(inter.H.upperBound))
	end

	#Error
	@assert inter.F.cardinalInf <= inter.F.cardinalSup "Infeasible Problem : $(inter.F) has a problem"
	@assert inter.G.cardinalInf <= inter.G.cardinalSup "Infeasible Problem : $(inter.G) has a problem"
	@assert inter.H.cardinalInf <= inter.H.cardinalSup "Infeasible Problem : $(inter.H) has a problem"

	return changeVariable[1:nbChange], (changeF, changeG, changeH)

end
