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
			changeVariable[nbChange] = unionConst.F

			if isFixed(unionConst.F)
				fix!(unionConst.F, changeF)
			end
		end

		setdiff!(unionConst.F.upperBound, rem)
		union!(unionConst.F.lowerBound, add)

		for elt in add
			push!(changeF.added, added)
		end
		for elt in rem
			push!(changeF.removed, rem)
		end

		cardInf = max(unionConst.F.cardinalInf, length(unionConst.F.lowerBound), unionConst.G.cardinalInf, unionConst.H.cardinalInf)
		cardSup = min(unionConst.F.cardinalSup, length(unionConst.F.upperBound), unionConst.G.cardinalSup + unionConst.H.cardinalSup)

		changeF.cardAdded = unionConst.F.cardinalInf - cardInf
		changeF.cardRemoved = cardSup - unionConst.F.cardinalSup

		unionConst.F.cardinalInf += changeF.cardAdded
		unionConst.F.cardinalSup += changeF.cardRemoved
	end

	if !unionConst.G.isFixed

		rem = intersect(unionConst.G.upperBound, unionConst.F.lowerBound, unionConst.H.lowerBound)
		add = setdiff(setdiff(unionConst.F.lowerBound, unionConst.H.upperBound), unionConst.G.lowerBound)

		if !(isempty(rem) && isempty(add))
			nbChange += 1
			changeVariable[nbChange] = unionConst.G

			if isFixed(unionConst.G)
				fix!(unionConst.G, changeG)
			end
		end

		setdiff!(unionConst.G.upperBound, rem)
		union!(unionConst.G.lowerBound, add)

		for elt in add
			push!(changeG.added, added)
		end
		for elt in rem
			push!(changeG.removed, rem)
		end

		cardInf = max(unionConst.G.cardinalInf, length(unionConst.G.lowerBound))
		cardSup = min(unionConst.G.cardinalSup, length(unionConst.G.upperBound), unionConst.F.cardinalSup - unionConst.H.cardinalInf)

		changeG.cardAdded = unionConst.G.cardinalInf - cardInf
		changeG.cardRemoved = cardSup - unionConst.G.cardinalSup

		unionConst.G.cardinalInf += changeG.cardAdded
		unionConst.G.cardinalSup += changeG.cardRemoved
	end

	if !unionConst.H.isFixed
		rem = intersect(unionConst.H.upperBound, unionConst.F.lowerBound, unionConst.G.lowerBound)
		add = setdiff(setdiff(unionConst.F.lowerBound, unionConst.G.upperBound), unionConst.H.lowerBound)

		if !(isempty(rem) && isempty(add))
			nbChange += 1
			changeVariable[nbChange] = unionConst.H

			if isFixed(unionConst.H)
				fix!(unionConst.H, changeH)
			end
		end

		setdiff!(unionConst.H.upperBound, rem)
		union!(unionConst.H.lowerBound, add)

		for elt in add
			push!(changeH.added, added)
		end
		for elt in rem
			push!(changeH.removed, rem)
		end

		cardInf = max(unionConst.H.cardinalInf, length(unionConst.H.lowerBound))
		cardSup = min(unionConst.H.cardinalSup, length(unionConst.H.upperBound), unionConst.F.cardinalSup - unionConst.G.cardinalInf)

		changeH.cardAdded = unionConst.H.cardinalInf - cardInf
		changeH.cardRemoved = cardSup - unionConst.H.cardinalSup

		unionConst.H.cardinalInf += changeH.cardAdded
		unionConst.H.cardinalSup += changeH.cardRemoved
	end

	#Error
	@assert unionConst.F.cardinalInf <= unionConst.F.cardinalSup "Infeasible Problem : $(unionConst.F) has a problem"
	@assert unionConst.G.cardinalInf <= unionConst.G.cardinalSup "Infeasible Problem : $(unionConst.G) has a problem"
	@assert unionConst.H.cardinalInf <= unionConst.H.cardinalSup "Infeasible Problem : $(unionConst.H) has a problem"

	return changeVariable[1:nbChange], (changeF, changeG, changeH)

end
