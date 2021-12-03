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

	#Set
	if !inter.F.isFixed
		Fup = intersect(inter.F.upperBound, inter.G.upperBound, inter.H.upperBound)
		Fdown = union(inter.F.lowerBound, intersect(inter.G.lowerBound, inter.H.lowerBound))

		if sort(inter.F.upperBound) != sort(Fup) || sort(inter.F.lowerBound) != sort(Fdown)
			nbChange += 1
			changeVariable[nbChange] = F
		end

		inter.F.upperBound = Fup
		inter.F.lowerBound = Fdown

		inter.F.cardinalInf = max(inter.F.cadinalInf, length(inter.F.lowerBound))
		inter.F.cardinalSup = min(inter.F.cardinalSup, length(inter.F.upperBound))
	end

	if !inter.G.isFixed
		Gup = setdiff(inter.G.upperBound, setdiff(inter.H.lowerBound, inter.F.upperBound))
		Gdown = union(inter.G.lowerBound, inter.F.lowerBound)

		if sort(inter.G.upperBound) != sort(Gup) || sort(inter.G.lowerBound) != sort(Gdown)
			nbChange += 1
			changeVariable[nbChange] = G
		end

		inter.G.upperBound = Gup
		inter.G.lowerBound = Gdown

		inter.G.cardinalInf = max(inter.G.cadinalInf, length(inter.G.lowerBound))
		inter.G.cardinalSup = min(inter.G.cardinalSup, length(inter.G.upperBound))
	end

	if !inter.H.isFixed
		Hup = setdiff(inter.H.upperBound, setdiff(inter.G.lowerBound, inter.F.upperBound))
		Hdown = union(inter.H.lowerBound, inter.F.lowerBound)

		if sort(inter.H.upperBound) != sort(Hup) || sort(inter.H.lowerBound) != sort(Hdown)
			nbChange += 1
			changeVariable[nbChange] = H
		end

		inter.H.upperBound = Hup
		inter.H.lowerBound = Hdown

		inter.H.cardinalInf = max(inter.H.cadinalInf, length(inter.H.lowerBound))
		inter.H.cardinalSup = min(inter.H.cardinalSup, length(inter.H.upperBound))
	end

	#Error
	@assert inter.F.cardinalInf <= inter.F.cardinalSup "Infeasible Problem : $(inter.F) has a problem"
	@assert inter.G.cardinalInf <= inter.G.cardinalSup "Infeasible Problem : $(inter.G) has a problem"
	@assert inter.H.cardinalInf <= inter.H.cardinalSup "Infeasible Problem : $(inter.H) has a problem"

	return changeVariable[1:nbChange]

end
