"""

	F = G ∩ H
	
"""

struct Intersection <: Constraint
	
	F::Variable
	G::Variable
	H::Variable
	
	filtrage!::Function

end

isFiltrable(::Intersection) = false

function filtrageInter!(F, G, H)

	#Set
	if !F.isFixed
		intersect!(F.upperBound, G.upperBound, H.upperBound)
		union!(F.lowerBound, intersect(G.lowerBound, H.lowerBound))
		
		F.cardinalInf = max(F.cadinalInf, length(F.lowerBound))
		F.cardinalSup = min(F.cardinalSup, length(F.upperBound))
	end
	
	if !G.isFixed
		setdiff!(G.upperBound, setdiff(H.lowerBound, F.upperBound))
		union!(G.lowerBound, F.lowerBound)
		
		G.cardinalInf = max(G.cadinalInf, length(G.lowerBound))
		G.cardinalSup = min(G.cardinalSup, length(G.upperBound))
	end
	
	if !H.isFixed
		setdiff!(H.upperBound, setdiff(G.lowerBound, F.upperBound))
		union!(H.lowerBound, F.lowerBound)
		
		H.cardinalInf = max(H.cadinalInf, length(H.lowerBound))
		H.cardinalSup = min(H.cardinalSup, length(H.upperBound))
	end
	
	#Error
	@assert F.cardinalInf <= F.cardinalSup "Infeasible Problem : $F has a problem"
	@assert G.cardinalInf <= G.cardinalSup "Infeasible Problem : $H has a problem"
	@assert H.cardinalInf <= H.cardinalSup "Infeasible Problem : $H has a problem"	

end
