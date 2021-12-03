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
	changeG = Change(inter.G)
	changeH = Change(inter.H)

	changeVariable = Vector{Variable}(undef, 2)
	nbChange = 0

	if !inter.G.isFixed

		rem = intersect(inter.G.upperBound, inter.H.lowerBound)
		for elt in rem
			push!(changeG.removed, elt)
		end

		if !isempty(rem)
			nbChange += 1
			changeVariable[nbChange] = inter.G
		end

		setdiff!(inter.G.upperBound, inter.H.lowerBound)
		inter.G.cardinalSup = min(inter.G.cardinalSup, length(inter.G.upperBound))
	end

	if !inter.H.isFixed

		rem = intersect(inter.H.upperBound, inter.G.lowerBound)
		for elt in rem
			push!(changeH.removed, elt)
		end

		if !isempty(rem)
			nbChange += 1
			changeVariable[nbChange] = inter.H
		end

		setdiff!(inter.H.upperBound, inter.G.lowerBound)
		inter.H.cardinalSup = min(inter.H.cardinalSup, length(inter.H.upperBound))
	end

	#Error
	@assert inter.G.cardinalInf <= inter.G.cardinalSup "Infeasible Problem : $(inter.G) has a problem"
	@assert inter.H.cardinalInf <= inter.H.cardinalSup "Infeasible Problem : $(inter.H) has a problem"

	return changeVariable[1:nbChange]

end
