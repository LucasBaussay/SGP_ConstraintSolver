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
	changeVariable = Vector{Variable}(undef, 3)
	nbChange = 0

	changeG = Change(inter.G)
	changeH = Change(inter.H)

	#Set
	if !inter.G.isFixed

		rem = intersect(inter.G.upperBound, inter.H.lowerBound)

		if !(isempty(rem))
			nbChange += 1
			changeVariable[nbChange] = G
		end

		setdiff!(inter.G.upperBound, rem)

		for elt in rem
			push!(changeG.removed, rem)
		end

		inter.G.cardinalSup = min(inter.G.cardinalSup, length(inter.G.upperBound))
	end

	if !inter.H.isFixed
		rem = intersect(inter.H.upperBound, inter.G.lowerBound)

		if !(isempty(rem))
			nbChange += 1
			changeVariable[nbChange] = H
		end

		setdiff!(inter.H.upperBound, rem)

		for elt in rem
			push!(changeH.removed, rem)
		end

		inter.H.cardinalSup = min(inter.H.cardinalSup, length(inter.H.upperBound))
	end

	#Error
	@assert inter.G.cardinalInf <= inter.G.cardinalSup "Infeasible Problem : $(inter.G) has a problem"
	@assert inter.H.cardinalInf <= inter.H.cardinalSup "Infeasible Problem : $(inter.H) has a problem"

	return changeVariable[1:nbChange], (changeG, changeH)

end
