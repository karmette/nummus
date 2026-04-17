class_name EffectOldAbe extends Effect

func effect(stats: Dictionary, side):
	if side == Sides.HEADS:
		CommonEffects.EnemyModifier.do_damage(stats.on_heads.damage)
func pre_effect(_stats: Dictionary):
		WeightModifier.favor_heads(0.5)
func recurring(stats: Dictionary, state: int) -> Dictionary:
	return stats
