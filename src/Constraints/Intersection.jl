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

	stop = !(isempty(setdiff(intersect(inter.G.lowerBound, inter.H.lowerBound), inter.F.upperBound)))
	stop = stop || !(isempty(setdiff(inter.F.lowerBound, intersect(inter.G.upperBound, inter.H.upperBound))))

	changeVariable = Vector{Variable}(undef, 3)
	nbChange = 0

	changeF = Change(inter.F)
	changeG = Change(inter.G)
	changeH = Change(inter.H)

	if stop
		return [], (changeF, changeG, changeH), true

	#Set
	else
		if !inter.F.isFixed

			rem = setdiff(inter.F.upperBound, intersect(inter.G.upperBound, inter.H.upperBound))
			add = setdiff(intersect(inter.G.lowerBound, inter.H.lowerBound), inter.F.lowerBound)

			setdiff!(inter.F.upperBound, rem)
			union!(inter.F.lowerBound, add)

			cardInf = max(inter.F.cardinalInf, length(inter.F.lowerBound))
			cardSup = min(inter.F.cardinalSup, length(inter.F.upperBound), inter.G.cardinalSup, inter.H.cardinalSup)

			changeF.cardAdded = cardInf - inter.F.cardinalInf
			changeF.cardRemoved = cardSup - inter.F.cardinalSup

			inter.F.cardinalInf += changeF.cardAdded
			inter.F.cardinalSup += changeF.cardRemoved

			if !(isempty(rem) && isempty(add))
				nbChange += 1
				changeVariable[nbChange] = inter.F

				if isFixed(inter.F)
					fix!(inter.F, changeF)
				end
			end
			for elt in add
				push!(changeF.added, elt)
			end
			for elt in rem
				push!(changeF.removed, elt)
			end
		end

		if !inter.G.isFixed

			rem = intersect(inter.G.upperBound, setdiff(inter.H.lowerBound, inter.F.upperBound))
			add = setdiff(inter.F.lowerBound, inter.G.lowerBound)

			setdiff!(inter.G.upperBound, rem)
			union!(inter.G.lowerBound, add)

			cardInf = max(inter.G.cardinalInf, length(inter.G.lowerBound), inter.F.cardinalInf)
			cardSup = min(inter.G.cardinalSup, length(inter.G.upperBound))

			changeG.cardAdded = cardInf - inter.G.cardinalInf
			changeG.cardRemoved = cardSup - inter.G.cardinalSup

			inter.G.cardinalInf += changeG.cardAdded
			inter.G.cardinalSup += changeG.cardRemoved

			if !(isempty(rem) && isempty(add))
				nbChange += 1
				changeVariable[nbChange] = inter.G

				if isFixed(inter.G)
					fix!(inter.G, changeG)
				end
			end

			for elt in add
				push!(changeG.added, elt)
			end
			for elt in rem
				push!(changeG.removed, elt)
			end
		end

		if !inter.H.isFixed
			rem = intersect(inter.H.upperBound, setdiff(inter.G.lowerBound, inter.F.upperBound))
			add = setdiff(inter.F.lowerBound, inter.H.lowerBound)

			setdiff!(inter.H.upperBound, rem)
			union!(inter.H.lowerBound, add)

			cardInf = max(inter.H.cardinalInf, length(inter.H.lowerBound), inter.F.cardinalInf)
			cardSup = min(inter.H.cardinalSup, length(inter.H.upperBound))

			changeH.cardAdded = cardInf - inter.H.cardinalInf
			changeH.cardRemoved = cardSup - inter.H.cardinalSup

			inter.H.cardinalInf += changeH.cardAdded
			inter.H.cardinalSup += changeH.cardRemoved

			if !(isempty(rem) && isempty(add))
				nbChange += 1
				changeVariable[nbChange] = inter.H

				if isFixed(inter.H)
					fix!(inter.H, changeH)
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
		stop = stop || !(inter.F.cardinalInf <= inter.F.cardinalSup)
		stop = stop || !(inter.G.cardinalInf <= inter.G.cardinalSup)
		stop = stop || !(inter.H.cardinalInf <= inter.H.cardinalSup)

		changes = (changeF, changeG, changeH)
		for c in changes
			if !(isempty(c.added))
				#println("$inter ajoute $(c.added) à $(c.var)")
			end
			if !(isempty(c.removed))
				#println("$inter enlève $(c.removed) à $(c.var)")
			end
		end

		return changeVariable[1:nbChange], (changeF, changeG, changeH), stop
	end

end
