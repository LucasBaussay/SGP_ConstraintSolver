"""

	F = G ∪ H

"""

struct DisjointUnion <: Constraint

	F::Variable
	G::Variable
	H::Variable

end

import Base.show
function Base.show(io::IO, unionConst::DisjointUnion)
	print(io, unionConst.F.name * " = " * unionConst.G.name * " ∪ " * unionConst.H.name)
end

function DisjointUnion(model::Model, F, G, H)
	constraint = DisjointUnion(F, G, H)
	push!(F.linkedConstraint, constraint)
	push!(G.linkedConstraint, constraint)
	push!(H.linkedConstraint, constraint)

	push!(model.constraints, constraint)

	constraint
end

function filtrage!(unionConst::DisjointUnion)

	changeVariable = Vector{Variable}(undef, 3)
	nbChange = 0

	changeF = Change(unionConst.F)
	changeG = Change(unionConst.G)
	changeH = Change(unionConst.H)

	#Set
	if !unionConst.F.isFixed

		rem = setdiff(unionConst.F.upperBound, union(unionConst.G.upperBound, unionConst.H.upperBound))
		add = setdiff(union(unionConst.G.lowerBound, unionConst.H.lowerBound), unionConst.F.lowerBound)

		if !(isempty(rem) && isempty(add))
			nbChange += 1
			changeVariable[nbChange] = F
		end

		setdiff!(unionConst.F.upperBound, rem)
		union!(unionConst.F.lowerBound, add)

		for elt in add
			push!(changeF.added, added)
		end
		for elt in rem
			push!(changeF.removed, rem)
		end

		unionConst.F.cardinalInf = max(unionConst.F.cardinalInf, length(unionConst.F.lowerBound))
		unionConst.F.cardinalSup = min(unionConst.F.cardinalSup, length(unionConst.F.upperBound))
	end

	if !unionConst.G.isFixed

		rem = intersect(unionConst.G.upperBound, unionConst.F.lowerBound, unionConst.H.lowerBound)
		add = setdiff(setdiff(unionConst.F.lowerBound, unionConst.H.upperBound), unionConst.G.lowerBound)

		if !(isempty(rem) && isempty(add))
			nbChange += 1
			changeVariable[nbChange] = G
		end

		setdiff!(unionConst.G.upperBound, rem)
		union!(unionConst.G.lowerBound, add)

		for elt in add
			push!(changeG.added, added)
		end
		for elt in rem
			push!(changeG.removed, rem)
		end

		unionConst.G.cardinalInf = max(unionConst.G.cardinalInf, length(unionConst.G.lowerBound))
		unionConst.G.cardinalSup = min(unionConst.G.cardinalSup, length(unionConst.G.upperBound))
	end

	if !unionConst.H.isFixed
		rem = intersect(unionConst.H.upperBound, unionConst.F.lowerBound, unionConst.G.lowerBound)
		add = setdiff(setdiff(unionConst.F.lowerBound, unionConst.G.upperBound), unionConst.H.lowerBound)

		if !(isempty(rem) && isempty(add))
			nbChange += 1
			changeVariable[nbChange] = H
		end

		setdiff!(unionConst.H.upperBound, rem)
		union!(unionConst.H.lowerBound, add)

		for elt in add
			push!(changeH.added, added)
		end
		for elt in rem
			push!(changeH.removed, rem)
		end

		unionConst.H.cardinalInf = max(unionConst.H.cardinalInf, length(unionConst.H.lowerBound))
		unionConst.H.cardinalSup = min(unionConst.H.cardinalSup, length(unionConst.H.upperBound))
	end

	#Error
	@assert unionConst.F.cardinalInf <= unionConst.F.cardinalSup "Infeasible Problem : $(unionConst.F) has a problem"
	@assert unionConst.G.cardinalInf <= unionConst.G.cardinalSup "Infeasible Problem : $(unionConst.G) has a problem"
	@assert unionConst.H.cardinalInf <= unionConst.H.cardinalSup "Infeasible Problem : $(unionConst.H) has a problem"

	return changeVariable[1:nbChange], (changeF, changeG, changeH)

end
