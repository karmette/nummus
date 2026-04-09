class_name EffectWaggy extends MintEffect

func _init():
	value = .1
	effect_object = WeightModifier.new()
	effect = Callable(effect_object, "favor_tails")