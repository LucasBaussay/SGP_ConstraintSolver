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

	stop =  !(isempty(intersect(unionConst.G.lowerBound, unionConst.H.lowerBound)))
	stop = stop || !(isempty(setdiff(union(unionConst.G.lowerBound, unionConst.H.lowerBound), unionConst.F.upperBound)))
	stop = stop || !(isempty(setdiff(unionConst.F.lowerBound, union(unionConst.G.upperBound, unionConst.H.upperBound))))

	changeVariable = Vector{Variable}(undef, 3)
	nbChange = 0

	changeF = Change(unionConst.F)
	changeG = Change(unionConst.G)
	changeH = Change(unionConst.H)

	if stop
		return [], (changeF, changeG, changeH), true
	else

		#Set
		if !unionConst.F.isFixed

			rem = setdiff(unionConst.F.upperBound, union(unionConst.G.upperBound, unionConst.H.upperBound))
			add = setdiff(union(unionConst.G.lowerBound, unionConst.H.lowerBound), unionConst.F.lowerBound)

			setdiff!(unionConst.F.upperBound, rem)
			union!(unionConst.F.lowerBound, add)

			cardInf = max(unionConst.F.cardinalInf, length(unionConst.F.lowerBound), unionConst.G.cardinalInf, unionConst.H.cardinalInf)
			cardSup = min(unionConst.F.cardinalSup, length(unionConst.F.upperBound), unionConst.G.cardinalSup + unionConst.H.cardinalSup)

			changeF.cardAdded = cardInf - unionConst.F.cardinalInf
			changeF.cardRemoved = cardSup - unionConst.F.cardinalSup

			unionConst.F.cardinalInf += changeF.cardAdded
			unionConst.F.cardinalSup += changeF.cardRemoved

			if !(isempty(rem) && isempty(add))
				nbChange += 1
				changeVariable[nbChange] = unionConst.F

				if isFixed(unionConst.F)
					fix!(unionConst.F, changeF)
				end
			end

			for elt in add
				push!(changeF.added, elt)
			end
			for elt in rem
				push!(changeF.removed, elt)
			end
		end

		if !unionConst.G.isFixed

			rem = intersect(unionConst.G.upperBound, unionConst.F.lowerBound, unionConst.H.lowerBound)
			add = setdiff(setdiff(unionConst.F.lowerBound, unionConst.H.upperBound), unionConst.G.lowerBound)

			setdiff!(unionConst.G.upperBound, rem)
			union!(unionConst.G.lowerBound, add)

			cardInf = max(unionConst.G.cardinalInf, length(unionConst.G.lowerBound))
			cardSup = min(unionConst.G.cardinalSup, length(unionConst.G.upperBound), unionConst.F.cardinalSup - unionConst.H.cardinalInf)

			changeG.cardAdded = cardInf - unionConst.G.cardinalInf
			changeG.cardRemoved = cardSup - unionConst.G.cardinalSup

			unionConst.G.cardinalInf += changeG.cardAdded
			unionConst.G.cardinalSup += changeG.cardRemoved

			if !(isempty(rem) && isempty(add))
				nbChange += 1
				changeVariable[nbChange] = unionConst.G

				if isFixed(unionConst.G)
					fix!(unionConst.G, changeG)
				end
			end

			for elt in add
				push!(changeG.added, elt)
			end
			for elt in rem
				push!(changeG.removed, elt)
			end
		end

		if !unionConst.H.isFixed
			rem = intersect(unionConst.H.upperBound, unionConst.F.lowerBound, unionConst.G.lowerBound)
			add = setdiff(setdiff(unionConst.F.lowerBound, unionConst.G.upperBound), unionConst.H.lowerBound)

			setdiff!(unionConst.H.upperBound, rem)
			union!(unionConst.H.lowerBound, add)

			cardInf = max(unionConst.H.cardinalInf, length(unionConst.H.lowerBound))
			cardSup = min(unionConst.H.cardinalSup, length(unionConst.H.upperBound), unionConst.F.cardinalSup - unionConst.G.cardinalInf)

			changeH.cardAdded = cardInf - unionConst.H.cardinalInf
			changeH.cardRemoved = cardSup - unionConst.H.cardinalSup

			unionConst.H.cardinalInf += changeH.cardAdded
			unionConst.H.cardinalSup += changeH.cardRemoved

			if !(isempty(rem) && isempty(add))
				nbChange += 1
				changeVariable[nbChange] = unionConst.H

				if isFixed(unionConst.H)
					fix!(unionConst.H, changeH)
				end
			end

			for elt in add
				push!(changeH.added, elt)
			end
			for elt in rem
				push!(changeH.removed, elt)
			end
		end

		#Error
		stop = stop || !(unionConst.F.cardinalInf <= unionConst.F.cardinalSup)
		stop = stop || !(unionConst.G.cardinalInf <= unionConst.G.cardinalSup)
		stop = stop || !(unionConst.H.cardinalInf <= unionConst.H.cardinalSup)

		changes = (changeF, changeG, changeH)
		for c in changes
			if !(isempty(c.added))
				#println("$unionConst ajoute $(c.added) à $(c.var)")
			end
			if !(isempty(c.removed))
				#println("$unionConst enlève $(c.removed) à $(c.var)")
			end
		end

		return changeVariable[1:nbChange], (changeF, changeG, changeH), stop
	end

end
