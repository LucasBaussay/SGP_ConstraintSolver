"""

	F = G ∪ H

"""

struct DisjointUnion <: Constraint

	F::Variable
	G::Variable
	H::Variable

end

import Base.show
function Base.show(io::IO, inter::DisjointUnion)
	print(io, inter.F.name * " = " * inter.G.name * " ∪ " * inter.H.name)
end

function DisjointUnion(model::Model, F, G, H)
	constraint = DisjointUnion(F, G, H)
	push!(F.linkedConstraint, constraint)
	push!(G.linkedConstraint, constraint)
	push!(H.linkedConstraint, constraint)

	push!(model.constraints, constraint)

	constraint
end

function filtrage!(union::DisjointUnion)

	return []

end
