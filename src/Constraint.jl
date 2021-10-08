"""
	Constraint

	Abstract type to represent the different constraints of the problem
	
"""

abstract type Constraint end

"""
	isFiltrable
		
	Define if the contraint given in parameter is filtrable
	
"""

function isFiltrable end

"""
	filtrage
	
	Generic function that takes no parameter, modify the different bounds of the varaibles and return the modified variable
	
"""

function filtrage end

include("Constraints/AtMostOne.jl")
include("Constraints/Cardinalite.jl")
include("Constraints/EmptyNIntersection.jl")
include("Constraints/Intersection.jl")
include("Constraints/NUnion.jl")
