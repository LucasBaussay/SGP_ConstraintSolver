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

	stop = !(isempty(intersect(inter.H.lowerBound, inter.G.lowerBound)))

	changeVariable = Vector{Variable}(undef, 3)
	nbChange = 0

	changeG = Change(inter.G)
	changeH = Change(inter.H)

	if stop
		return [], (changeG, changeH), stop
	else

		#Set
		if !inter.G.isFixed

			rem = intersect(inter.G.upperBound, inter.H.lowerBound)

			setdiff!(inter.G.upperBound, rem)
			cardSup = min(inter.G.cardinalSup, length(inter.G.upperBound))

			changeG.cardRemoved = cardSup - inter.G.cardinalSup

			inter.G.cardinalSup += changeG.cardRemoved

			if !(isempty(rem))
				nbChange += 1
				changeVariable[nbChange] = inter.G

				if isFixed(inter.G)
					fix!(inter.G, changeG)
				end
			end

			for elt in rem
				push!(changeG.removed, elt)
			end

		end

		if !inter.H.isFixed
			rem = intersect(inter.H.upperBound, inter.G.lowerBound)

			setdiff!(inter.H.upperBound, rem)
			cardSup = min(inter.H.cardinalSup, length(inter.H.upperBound))

			changeH.cardRemoved = cardSup - inter.H.cardinalSup

			inter.H.cardinalSup += changeH.cardRemoved

			if !(isempty(rem))
				nbChange += 1
				changeVariable[nbChange] = inter.H

				if isFixed(inter.H)
					fix!(inter.H, changeH)
				end
			end

			for elt in rem
				push!(changeH.removed, elt)
			end

		end

		#Error
		stop = stop || !(inter.G.cardinalInf <= inter.G.cardinalSup)
		stop = stop || !(inter.H.cardinalInf <= inter.H.cardinalSup)

		changes = (changeG, changeH)
		for c in changes
			if !(isempty(c.added))
				# println("$inter ajoute $(c.added) à $(c.var)")
			end
			if !(isempty(c.removed))
				# println("$inter enlève $(c.removed) à $(c.var)")
			end
		end

		return changeVariable[1:nbChange], (changeG, changeH), stop
	end

end
