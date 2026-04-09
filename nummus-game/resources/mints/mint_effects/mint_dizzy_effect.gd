class_name EffectDizzy extends MintEffect

func _init():
	value = .1
	effect_object = WeightModifier.new()
	effect = Callable(effect_object, "favor_heads")
