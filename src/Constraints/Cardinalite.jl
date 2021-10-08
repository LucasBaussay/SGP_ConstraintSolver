"""

	| X | = n

"""

struct Cardinalite <: Constraint

	X::Variable # La variable ensembliste
	n::Int # Le cardinal de l'ensemble
	
	filtrage::Function # Rien en paramètre et modifie les bornes des variables liées à elle (Cardinal et ensemble) et renvoie la liste des variables modifiées

end

isFiltrable(::Cardinalite) = false
