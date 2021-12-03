"""

	| X | = n

There is no filtrage on it, only pre-treatment

"""

function Cardinalite(model::Model, X::Variable, n::Int)
	X.cardinalInf = n
	X.cardinalSup = n
end
