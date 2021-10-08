# "Je peux te sniffer ?" Louise Oct. 2021


"""
	
	Pour les bornes :
		- Soit on fait une liste chainée et du coup l'accès au plus petit est easy
		- Soit on fait un Set qui retiens les bornes Inf et Sup
		- Soit on fusionne les deux, et on créer une liste chainée qui retient le min et le max.

"""

mutable struct Variable

	lowerBound::LinkedList{Int}
	upperBound::LinkedList{Int}
	
	cardinalInf::Int
	cardinalSup::Int
	
	linkedConstraint::Vector{Constraint}
	
	isFixed::Bool

end
