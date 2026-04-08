class_name EffectDizzy extends Effect

func effect(stats: Dictionary, side):
	CommonEffects.WeightModifier.favor_heads(.1)
func pre_effect(_stats: Dictionary):
	pass # Don't change if there is no pre effect
func yes():
	CommonEffects.WeightModifier.favor_heads(.1)