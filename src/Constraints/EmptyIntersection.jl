"""

	G ∩ H = ∅

"""

struct EmptyIntersection <: Constraint

	G::Variable
	H::Variable

end

import Base.show
function Base.show(io::IO, inter::EmptyIntersection)
	print(io, inter.G.name * " ∩ " * inter.H.name * " = ∅")
end

function EmptyIntersection(model, G, H)
	constraint = EmptyIntersection(G, H)
	push!(G.linkedConstraint, constraint)
	push!(H.linkedConstraint, constraint)

	push!(model.constraints, constraint)

	constraint
end

function filtrage!(inter::EmptyIntersection)

	@assert isempty(intersect(inter.H.lowerBound, inter.G.lowerBound)) "Infeasible"

	changeVariable = Vector{Variable}(undef, 3)
	nbChange = 0

	changeG = Change(inter.G)
	changeH = Change(inter.H)

	#Set
	if !inter.G.isFixed

		rem = intersect(inter.G.upperBound, inter.H.lowerBound)

		if !(isempty(rem))
			nbChange += 1
			changeVariable[nbChange] = inter.G

			if isFixed(inter.G)
				fix!(inter.G, changeG)
			end
		end

		setdiff!(inter.G.upperBound, rem)

		for elt in rem
			push!(changeG.removed, rem)
		end

		cardSup = min(inter.G.cardinalSup, length(inter.G.upperBound))

		changeG.cardRemoved = cardSup - inter.G.cardinalSup

		inter.G.cardinalSup += changeG.cardRemoved
	end

	if !inter.H.isFixed
		rem = intersect(inter.H.upperBound, inter.G.lowerBound)

		if !(isempty(rem))
			nbChange += 1
			changeVariable[nbChange] = inter.H

			if isFixed(inter.H)
				fix!(inter.H, changeH)
			end
		end

		setdiff!(inter.H.upperBound, rem)

		for elt in rem
			push!(changeH.removed, rem)
		end

		cardSup = min(inter.H.cardinalSup, length(inter.H.upperBound))

		changeH.cardRemoved = cardSup - inter.H.cardinalSup

		inter.H.cardinalSup += changeH.cardRemoved
	end

	#Error
	@assert inter.G.cardinalInf <= inter.G.cardinalSup "Infeasible Problem : $(inter.G) has a problem"
	@assert inter.H.cardinalInf <= inter.H.cardinalSup "Infeasible Problem : $(inter.H) has a problem"

	return changeVariable[1:nbChange], (changeG, changeH)

end
