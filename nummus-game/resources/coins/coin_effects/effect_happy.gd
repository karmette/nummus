extends Effect

func effect(stats: Dictionary, side: int):
	if side == Sides.HEADS:
		RecursiveEffect.add_recurring_effect(WeightModifier.favor_heads.bind(0.25), 1)
	elif side == Sides.TAILS:
		RecursiveEffect.add_recurring_effect(WeightModifier.favor_heads.bind(0.25), 1)
func pre_effect(_stats: Dictionary):
	pass
