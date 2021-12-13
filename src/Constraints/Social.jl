"""

	|X ∩ Y| <= 1

"""

function Social(model::Model, X::Variable, Y::Variable)

	F = Variable(model, 1:model.p, "F[$(length(model.varsInter)+1)]")
	constraint = Intersection(model, F, X, Y)

	F.cardinalSup = 1

	constraint
end
