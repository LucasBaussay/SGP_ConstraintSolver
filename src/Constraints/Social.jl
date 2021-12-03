"""

	|X ∩ Y| <= 1

"""

function Social(model::Model, X::Variable, Y::Variable)

	Variable(model, 1:model.p, "F[$(length(model.varsInter)+1)]")
	constraint = Intersection(model, model.varsInter[end], X, Y)

	model.varsInter[end].cardinalSup = 1

	constraint
end
