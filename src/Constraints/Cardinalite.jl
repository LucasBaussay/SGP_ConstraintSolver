"""

	| X | = n

"""

struct Cardinalite <: Constraint

	X::Variable # La variable ensembliste
	n::Int # Le cardinal de l'ensemble
	
	filtrage!::Function # Rien en paramètre et modifie les bornes des variables liées à elle (Cardinal et ensemble) et renvoie la liste des variables modifiées

end

isFiltrable(::Cardinalite) = false

function Cardinalite(X::Variable, n::Int)
	return Cardinalite(X,
						n,
						()->Vector{Variable}())
end

function fixCardinalite!(X::Variable, q::Int)
	X.cardInf = q
	X.carSup = q
end
